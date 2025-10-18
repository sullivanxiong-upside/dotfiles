-- Autocmds configuration
-- This file contains all autocmd definitions

-- Auto-reload configuration when config files change
vim.api.nvim_create_autocmd("BufWritePost", {
   pattern = { "*.lua" },
   callback = function()
      -- Only reload if it's a config file
      local file = vim.fn.expand("%")
      if string.find(file, "config/") or string.find(file, "plugins/") then
         vim.cmd("source %")
         vim.notify("Configuration reloaded!", vim.log.levels.INFO)
      end
   end,
   desc = "Reload config on save",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
   callback = function()
      vim.highlight.on_yank()
   end,
   desc = "Highlight on yank",
})

-- Auto-save on focus lost
vim.api.nvim_create_autocmd("FocusLost", {
   callback = function()
      if vim.bo.modified and not vim.bo.readonly then
         vim.cmd("silent! write")
      end
   end,
   desc = "Auto-save on focus lost",
})

