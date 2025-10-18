-- LSP configuration
return {
   -- LSP setup
   {
      "neovim/nvim-lspconfig",
      config = function()
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
      end,
   },

   -- Completion setup
   {
      "hrsh7th/nvim-cmp",
      config = function()
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
      end,
   },
}

