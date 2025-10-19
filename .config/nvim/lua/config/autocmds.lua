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

-- Format on save using LSP as fallback when conform isn't available
vim.api.nvim_create_autocmd("BufWritePre", {
   callback = function()
      -- Only format if conform isn't handling this file type
      local conform = require("conform")
      local formatters = conform.get_formatters()
      local filetype = vim.bo.filetype
      
      if not formatters[filetype] or #formatters[filetype] == 0 then
         -- Use LSP formatting as fallback
         local clients = vim.lsp.get_active_clients({ bufnr = 0 })
         for _, client in ipairs(clients) do
            if client.supports_method("textDocument/formatting") then
               vim.lsp.buf.format({ async = false })
               break
            end
         end
      end
   end,
   desc = "Format on save with LSP fallback",
})

