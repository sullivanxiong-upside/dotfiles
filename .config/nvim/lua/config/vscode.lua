-- VSCode/Cursor specific configuration
-- This file detects when running in VSCode/Cursor and adjusts settings accordingly

if vim.g.vscode then
   -- VSCode extension configuration
   -- Disable UI-heavy plugins that don't work well in VSCode
   vim.g.loaded_telescope = 1
   vim.g.loaded_which_key = 1
   vim.g.loaded_harpoon = 1
   vim.g.loaded_toggleterm = 1
   
   -- Keep LSP and basic editing features
   -- These will work fine in VSCode
   
   -- Adjust some settings for VSCode environment
   vim.opt.number = false  -- VSCode handles line numbers
   vim.opt.relativenumber = false
   
   print("VSCode/Cursor environment detected - UI plugins disabled")
else
   -- Regular Neovim - all features enabled
   print("Standard Neovim environment - all features enabled")
end

