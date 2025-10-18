# Neovim Configuration

This is a LazyVim-style Neovim configuration that follows modern conventions and best practices.

## Structure

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── config/
│   │   ├── autocmds.lua     # Autocmd definitions
│   │   ├── keymaps.lua       # Keymap definitions
│   │   ├── lazy.lua          # Lazy.nvim bootstrap
│   │   └── options.lua       # Vim options
│   └── plugins/
│       ├── core.lua          # Core plugins (colorscheme, LSP, treesitter)
│       ├── lsp.lua           # LSP configuration
│       └── lazyvim.lua        # LazyVim-style plugins
```

## Features

### Core Plugins

- **Colorscheme**: onedarkpro.nvim
- **LSP**: nvim-lspconfig with mason.nvim
- **Completion**: nvim-cmp
- **Syntax**: nvim-treesitter
- **Comments**: Comment.nvim

### LazyVim-style Plugins

- **which-key.nvim**: Keymap help and discovery
- **conform.nvim**: Code formatting
- **todo-comments.nvim**: TODO highlighting and navigation
- **telescope.nvim**: Fuzzy finder
- **harpoon**: File navigation
- **markdown-preview.nvim**: Markdown preview

### Key Features

- **Leader key**: `<space>` (standard LazyVim)
- **Local leader**: `\`
- **OS-adaptive keybinds**: macOS and Linux support
- **Auto-formatting**: On save with LSP fallback
- **Which-key integration**: Press any key to see available mappings

## Key Mappings

### General

- `<leader>`: Show which-key menu
- `<C-s>`: Save file
- `<C-r>`: Reload configuration

### Navigation

- `<leader>ff`: Find files
- `<leader>fg`: Live grep
- `<leader>fb`: Buffers
- `<leader>fr`: Recent files

### LSP

- `<leader>cf`: Format buffer
- `<leader>cd`: Line diagnostics
- `]d`/`[d`: Next/previous diagnostic
- `]e`/`[e`: Next/previous error
- `]w`/`[w`: Next/previous warning

### TODO Comments

- `<leader>st`: Show todos
- `<leader>sT`: Show todos/fix/fixme
- `]t`/`[t`: Next/previous todo

### Harpoon

- `<leader>a`: Add file to harpoon
- `<C-e>`: Toggle harpoon menu
- `<C-h>`, `<C-t>`, `<C-n>`, `<C-s>`: Quick jump to harpoon files

## Installation

1. Ensure you have Neovim 0.9+ installed
2. The configuration will automatically bootstrap lazy.nvim
3. Open Neovim and let it install the plugins
4. LSP servers will be installed automatically via mason

## VSCode/Cursor Integration

This configuration supports VSCode Neovim extension for seamless integration with Cursor IDE:

### Setup in Cursor:

1. Install the "VSCode Neovim" extension (`asvetliakov.vscode-neovim`)
2. The configuration automatically detects VSCode/Cursor environment
3. UI-heavy plugins (telescope, which-key, harpoon) are disabled in VSCode
4. LSP and core editing features work normally

### Key Features in Cursor:

- **Terminal Toggle**: `Cmd+E` (uses toggleterm.nvim)
- **Go to Definition**: `Cmd+Enter` (matches Cursor's default)
- **Go to Declaration**: `Cmd+Shift+Enter`
- **Buffer Navigation**: `Cmd+Shift+H/L` for previous/next buffer
- **All your custom keybinds** from Neovim work in Cursor

### VSCode-specific Configuration:

- `lua/config/vscode.lua` - Detects VSCode environment and adjusts settings
- UI plugins are automatically disabled in VSCode/Cursor
- LSP and core editing features remain fully functional

## Customization

- Add new plugins in `lua/plugins/`
- Modify keymaps in `lua/config/keymaps.lua`
- Change options in `lua/config/options.lua`
- Add autocmds in `lua/config/autocmds.lua`
- VSCode-specific settings in `lua/config/vscode.lua`
