# VSCode Neovim Integration Guide

## Quick Setup

### 1. Install VSCode Neovim Extension in Cursor

1. Open Cursor
2. Go to Extensions (Cmd+Shift+X)
3. Search for "VSCode Neovim"
4. Install the extension by `asvetliakov`

### 2. Configuration is Already Done!

The following has been configured automatically:

- ✅ **Neovim Path**: `$HOME/.nix-profile/bin/nvim`
- ✅ **Config Path**: `~/.config/nvim/init.lua`
- ✅ **VSCode Detection**: Automatically disables UI plugins in Cursor
- ✅ **Keybinds**: All your custom keybinds work in Cursor

### 3. Test the Integration

After installing the extension and reloading Cursor:

1. **Terminal Toggle**: Press `Cmd+E` - should open/close terminal
2. **Go to Definition**: Press `Cmd+Enter` on a symbol
3. **Buffer Navigation**: Press `Cmd+Shift+H` or `Cmd+Shift+L`
4. **Your Custom Keybinds**: All your existing Neovim keybinds should work

## What Works in Cursor

### ✅ Fully Supported:

- All your custom keybinds from Neovim
- LSP features (go to definition, hover, etc.)
- Comment toggling
- Line movement (Alt+J/K)
- Tab navigation
- Copy/paste operations
- File operations

### ❌ Disabled in Cursor (UI plugins):

- Telescope (fuzzy finder)
- Which-key (keymap help)
- Harpoon (file navigation)
- Toggleterm (terminal - replaced with Cursor's terminal)

## Troubleshooting

### If keybinds don't work:

1. Reload Cursor window (Cmd+Shift+P → "Developer: Reload Window")
2. Check that the extension is enabled
3. Verify Neovim path in settings

### If you see errors:

1. Check the Output panel → "VSCode Neovim" for error messages
2. Ensure Neovim is installed at the configured path
3. Test Neovim works standalone: `nvim --version`

## Configuration Files

- **Cursor Settings**: `.config/cursor/User/settings.json` - VSCode Neovim config
- **Neovim Config**: `.config/nvim/` - Your full Neovim configuration
- **VSCode Detection**: `.config/nvim/lua/config/vscode.lua` - Environment detection

## Benefits

- **Unified Experience**: Same keybinds in Neovim and Cursor
- **No Duplication**: No need to maintain separate keybind configs
- **Full LSP Support**: All your LSP servers work in Cursor
- **Performance**: Uses actual Neovim as backend (faster than Vim extension)
