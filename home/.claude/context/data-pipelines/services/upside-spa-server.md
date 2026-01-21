# Upside SPA Server

## Purpose

The `upside-spa-server` is a lightweight Go web server that serves React Single Page Applications (SPAs) with **runtime configuration injection**. This solves the problem of needing different environment configurations (dev, staging, production) without rebuilding Docker images for each environment.

**Location:** `go/upside-spa-server/`

## Key Concept: Runtime Config Injection

Instead of baking configuration into the React build (which would require separate images per environment), this server:

1. Serves static React build artifacts
2. Dynamically exposes environment variables via `/__env.js` endpoint
3. React app loads this script to access `window.__UPSIDE_VARS`

This allows **one Docker image to run in all environments** by changing environment variables at deployment time.

## Architecture

### Multi-Stage Docker Build (`react-spa.Dockerfile`)

```
Stage 1: Node build
  - Builds workbench React app → apps/workbench/dist
  - Uses pnpm + turbo for monorepo builds

Stage 2: Go build
  - Compiles upside-spa-server → static binary
  - CGO disabled for portability

Stage 3: Runtime
  - Combines React dist + Go server
  - Uses Python base image (quay.io/rfcurated/python:3.11.14)
  - Entrypoint: /srv/server
```

## Endpoints

### `GET /__env.js`
- Returns JavaScript: `window.__UPSIDE_VARS = Object.freeze({...})`
- Exposes environment variables based on whitelist/prefix rules
- `Cache-Control: no-store` (always fetch fresh config)
- **Security:** Only logs keys, not values

### `GET /healthz`, `GET /readyz`
- Kubernetes health probes
- Returns 200 OK

### Static File Serving
- Serves from `DIST_DIR` (default `/srv`)
- Unknown paths → `index.html` (SPA routing fallback)
- Smart caching:
  - `index.html`: `Cache-Control: no-cache` (check for updates)
  - Hashed assets: `Cache-Control: public, max-age=31536000, immutable`
  - `__env.js`: `Cache-Control: no-store`

## Configuration

### Environment Variables

- **`UPSIDE_ENV_WHITELIST`**: Comma-separated list of allowed env vars (e.g., `API_URL,ENVIRONMENT`)
- **`UPSIDE_ENV_PREFIX`**: Optional prefix filter (e.g., `UPSIDE_PUBLIC_` allows all vars starting with that)
- **`LISTEN`**: Server address (default `:8080`)
- **`DIST_DIR`**: Static assets root (default `/srv`)

### Example: Whitelisting Pattern

```go
// Only these vars are exposed to the browser:
// 1. Explicitly whitelisted vars
// 2. Vars with the allowed prefix

vars := map[string]string{}
for _, e := range os.Environ() {
    k, v := parseEnvVar(e)
    if inWhitelist(k) || hasPrefix(k) {
        vars[k] = v
    }
}
```

## Deployment

### Used By

- **Workbench app** (`drr-workbench-ui` in all environments)
  - Stage: deployed via `.github/workflows/stage-build-deploy.yaml`
  - Shadow-prod: deployed via `.github/workflows/shadow-prod-deploy-pipelines.yaml`
  - Prod: deployed via `.github/workflows/prod-build-deploy.yaml`
  - Helm chart: `charts/drr_workbench_ui/`

### Build Process

```bash
# CI builds via GitHub Actions (.github/workflows/go-build.yaml)
cd go/upside-spa-server
go build ./...

# Docker build (via react-spa.Dockerfile)
docker build -f react-spa.Dockerfile -t drr-workbench-ui:latest .
```

### Local Development

```bash
# Run against local React build
cd go/upside-spa-server
LISTEN=:8080 DIST_DIR=../../apps/workbench/dist go run .

# Or use built binary
go build -o server .
LISTEN=:8080 DIST_DIR=../../apps/workbench/dist ./server
```

## How React App Uses Config

1. React app includes `<script src="/__env.js"></script>` in HTML
2. Server generates JavaScript with whitelisted env vars
3. React code accesses via `window.__UPSIDE_VARS.API_URL`, etc.
4. No rebuild needed - just change K8s env vars and restart pod

## Security Considerations

- **Whitelist-based exposure**: Only explicitly allowed vars are exposed to browser
- **No value logging**: Server only logs environment variable keys, never values
- **Immutable object**: `Object.freeze()` prevents tampering in browser
- **No secrets**: Never put sensitive data in vars exposed via this pattern

## Gotchas

1. **Requires script tag in HTML**: React app must load `/__env.js` before accessing config
2. **Cache-Control critical**: Wrong caching breaks runtime config updates
3. **Browser-safe only**: Don't use this pattern for server-side secrets
4. **SPA routing fallback**: All unknown paths serve `index.html` - ensure API calls use distinct paths like `/api/*`

## Related Files

- **Server code**: `go/upside-spa-server/main.go`
- **Dockerfile**: `react-spa.Dockerfile` (multi-stage build)
- **CI/CD**: `.github/workflows/go-build.yaml`, `.github/workflows/*-deploy.yaml`
- **Helm chart**: `charts/drr_workbench_ui/`
- **Workbench app**: `apps/workbench/` (React SPA)

## Future Improvements (from README)

> Dockerfile/runtime image will be added once the SPA changes (env script tag) land on main.

This suggests the pattern may expand to other SPAs beyond workbench.
