# Contributing

This is a personal dotfiles repository, but contributions are welcome!

## For Issues

Feel free to open issues for:
- Bug reports in scripts (cwf, gwf, utilities)
- Documentation improvements or clarifications
- Cross-platform compatibility issues
- Suggestions for better organization

## For Pull Requests

Contributions are appreciated! Please:
- Keep changes focused and well-documented
- Test on both Linux and macOS if the change affects both platforms
- Run `make test` to ensure scripts pass ShellCheck
- Update relevant documentation in `docs/`
- Follow existing code style and patterns

**Note:** All PRs require passing CI checks (ShellCheck + structure validation) before merging.

## Forking and Adapting

This repository is designed to be forked and customized! The structure is:
- `home/` → Files symlinked to your home directory
- `bin/` → Executable scripts (add to your PATH)
- `macos/` and `linux/` → Platform-specific configs
- `docs/` → All documentation

Feel free to:
- Remove components you don't need
- Add your own scripts to `bin/`
- Customize configs in `home/`
- Adapt the Makefile for your setup

## Philosophy

**cwf and gwf are personal tools** - They're tailored to my workflow and reference work-specific paths. They're included as examples, but not designed for general open-source use. You're welcome to adapt them for your needs!

**AI-native development** - This repo embraces Claude Code, MCP servers, and AI-first workflows. If you have improvements to AI integration, please share!

## License

MIT License - See LICENSE file for details.
