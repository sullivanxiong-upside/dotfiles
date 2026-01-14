-- LSP configuration
return {
   -- LSP setup
   {
      "neovim/nvim-lspconfig",
      config = function()
         require("mason").setup({
            ui = {
               border = "none",
               icons = {
                  package_installed = "✓",
                  package_pending = "➜",
                  package_uninstalled = "✗"
               }
            }
         })
         require("mason-lspconfig").setup({
            -- Remove ensure_installed to prevent auto-installation on startup
            -- Install LSP servers manually with :Mason when needed
            automatic_installation = false,
            handlers = {
               function(server_name)
                  require("lspconfig")[server_name].setup({
                     on_attach = function(client, bufnr)
                        -- Basic LSP keybindings without auto-formatting
                        local opts = { noremap = true, silent = true, buffer = bufnr }
                        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                        vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
                        vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
                        vim.keymap.set('n', '<leader>wl', function()
                           print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                        end, opts)
                        vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
                        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
                        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                        vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts)
                        vim.keymap.set('n', '<leader>F', function() vim.lsp.buf.format { async = false } end, opts)
                     end,
                  })
               end,
            },
         })
      end,
   },

   -- Completion setup (lazy loaded)
   {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
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

