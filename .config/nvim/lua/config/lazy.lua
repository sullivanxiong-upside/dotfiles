-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
   local lazyrepo = "https://github.com/folke/lazy.nvim.git"
   local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
   if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
         { "Failed to clone lazy.nvim:\n\n", "ErrorMsg" },
         { out, "WarningMsg" },
         { "\nPress any key to exit..." },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
   end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.o.autoread = true
vim.o.splitright = true

-- Setup lazy.nvim with plugins for LSP/IntelliSense and indentation
require("lazy").setup({
   {
      "olimorris/onedarkpro.nvim",
      priority = 1000,
      config = function()
         require("onedarkpro").setup({
            options = {
               styles = {
                  comments = "italic",
                  keywords = "bold",
                  functions = "italic,bold",
               },
            },
         })
         vim.cmd("colorscheme onedark") -- or "onedark_dark", "onedark_vivid"
      end,
   },
   -- LSP and completion plugins
   { "neovim/nvim-lspconfig" },  -- Core LSP config
   { "williamboman/mason.nvim" },  -- LSP server manager
   { "williamboman/mason-lspconfig.nvim" },  -- Bridge for mason and lspconfig
   {
      "hrsh7th/nvim-cmp",
      dependencies = {
         "hrsh7th/cmp-nvim-lsp",  -- LSP source for cmp
         "hrsh7th/cmp-buffer",    -- Buffer source
         "hrsh7th/cmp-path",      -- Path source
      },
   },
   -- Treesitter for syntax-aware indentation
   {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
         require("nvim-treesitter.configs").setup({
            ensure_installed = { "lua", "python", "vim" },  -- Add languages as needed
            indent = { enable = true },
         })
      end,
   },
   -- Comment plugin for commenting/uncommenting code
   {
      "numToStr/Comment.nvim",
      config = function()
         require("Comment").setup()
      end,
   },
})

-- Somewhere in your config:
vim.cmd("colorscheme onedark")
-- Use tabs by default, displayed as 3 spaces
vim.opt.expandtab = false
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3
vim.opt.softtabstop = 3
vim.opt.number = true
vim.opt.relativenumber = true

-- For Python files, use 4 spaces instead of tabs
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
	end,
})

-- LSP setup (e.g., for Lua and Python servers)
require("mason").setup()
require("mason-lspconfig").setup({
   ensure_installed = { 
      "lua_ls",          -- Lua
      "pyright",         -- Python
      "clangd",          -- C/C++
      "ts_ls",           -- JavaScript/TypeScript
      "rust_analyzer",   -- Rust
      "gopls",           -- Go
      "html",            -- HTML
      "cssls",           -- CSS
      "jsonls",          -- JSON
      "jdtls"            -- Java
   },
   handlers = {
      function(server_name)
         require("lspconfig")[server_name].setup({
            on_attach = function(client, bufnr)
               -- Enable LSP formatting/indentation capabilities
               if client.server_capabilities.documentFormattingProvider then
                  -- Debounced auto-indent on character change in insert mode
                  local debounce_timer = nil
                  local debounce_delay = 300  -- ms; adjust as needed

                  vim.api.nvim_buf_set_keymap(bufnr, "i", "", "", {
                     callback = function()
                        if debounce_timer then
                           vim.fn.timer_stop(debounce_timer)
                        end
                        debounce_timer = vim.fn.timer_start(debounce_delay, function()
                           vim.lsp.buf.format({ async = false })  -- Re-indent/format current line/block
                        end)
                     end,
                     expr = true,
                     noremap = true,
                     silent = true,
                  })
               end
            end,
         })
      end,
   },
})

-- Completion setup (nvim-cmp for IntelliSense popup)
local cmp = require("cmp")
cmp.setup({
   sources = {
      { name = "nvim_lsp" },  -- LSP source
      { name = "buffer" },    -- Buffer words
      { name = "path" },      -- File paths
   },
   mapping = cmp.mapping.preset.insert({
      ["<C-Space>"] = cmp.mapping.complete(),  -- Trigger completion
      ["<CR>"] = cmp.mapping.confirm({ select = true }),  -- Confirm selection
   }),
})
