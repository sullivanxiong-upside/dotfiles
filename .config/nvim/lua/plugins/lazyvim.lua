-- LazyVim-style plugins
return {
   -- which-key.nvim for keymap help
   {
      "folke/which-key.nvim",
      event = "VeryLazy",
      init = function()
         vim.o.timeout = true
         vim.o.timeoutlen = 300
      end,
      opts = {
         -- your configuration comes here
         -- or leave it empty to use the default settings
         -- refer to the configuration section below
      }
   },

   -- nvim-surround for text wrapping (replaces your complex custom functions)
   {
      "kylechui/nvim-surround",
      version = "*", -- Use for stability; omit to use `main` for the latest in-development version
      event = "VeryLazy",
      config = function()
         require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
         })
      end
   },

   -- tabby.nvim for numbered tabs (enhances tab visibility)
   {
      "nanozuki/tabby.nvim",
      event = "VeryLazy",
      config = function()
         local theme = {
            fill = 'TabLineFill',
            -- Also you can do statusline and winbar. See tabby.nvim/lua/tabby/theme.lua
            head = 'TabLine',
            current_tab = 'TabLineSel',
            tab = 'TabLine',
            win = 'TabLine',
            tail = 'TabLine',
         }
         require('tabby.tabline').set(function(line)
            return {
               {
                  { '  ', hl = theme.head },
                  line.sep('', theme.head, theme.fill),
               },
               line.tabs().foreach(function(tab)
                  local hl = tab.is_current() and theme.current_tab or theme.tab
                  return {
                     line.sep('', hl, theme.fill),
                     tab.is_current() and ' ' or '',
                     tab.number(),
                     tab.name(),
                     tab.close_btn(''),
                     ' ',
                     hl = hl,
                     margin = ' ',
                  }
               end),
               line.spacer(),
               line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
                  return {
                     line.sep('', theme.win, theme.fill),
                     win.buf_name(),
                     hl = theme.win,
                  }
               end),
               {
                  line.sep('', theme.tail, theme.fill),
                  { '  ', hl = theme.tail },
               },
            }
         end)
      end,
   },

   -- conform.nvim for formatting
   {
      "stevearc/conform.nvim",
      event = { "BufWritePre" },
      cmd = { "ConformInfo" },
      keys = {
         {
            "<leader>cf",
            function()
               require("conform").format({ async = true, lsp_fallback = true })
            end,
            mode = "",
            desc = "Format buffer",
         },
         {
            "<leader>cF",
            function()
               require("conform").format({ async = false, lsp_fallback = true })
            end,
            mode = "",
            desc = "Format buffer (sync)",
         },
         {
            "<leader>ct",
            function()
               local conform = require("conform")
               local current_value = conform.formatters_by_ft[vim.bo.filetype]
               if current_value then
                  conform.formatters_by_ft[vim.bo.filetype] = nil
                  vim.notify("Format on save disabled for " .. vim.bo.filetype, vim.log.levels.INFO)
               else
                  -- Re-enable with default formatters
                  local default_formatters = {
                     lua = { "stylua" },
                     python = { "isort", "black" },
                     javascript = { "prettier" },
                     typescript = { "prettier" },
                     json = { "prettier" },
                     html = { "prettier" },
                     css = { "prettier" },
                     markdown = { "prettier" },
                  }
                  conform.formatters_by_ft[vim.bo.filetype] = default_formatters[vim.bo.filetype]
                  vim.notify("Format on save enabled for " .. vim.bo.filetype, vim.log.levels.INFO)
               end
            end,
            mode = "",
            desc = "Toggle format on save",
         },
      },
      opts = {
         formatters_by_ft = {
            lua = { "stylua" },
            python = { "isort", "black" },
            javascript = { "prettier" },
            typescript = { "prettier" },
            json = { "prettier" },
            html = { "prettier" },
            css = { "prettier" },
            markdown = { "prettier" },
            yaml = { "prettier" },
            yml = { "prettier" },
            xml = { "prettier" },
            sql = { "sqlfluff" },
            sh = { "shfmt" },
            bash = { "shfmt" },
            zsh = { "shfmt" },
            fish = { "fish_indent" },
            rust = { "rustfmt" },
            go = { "gofmt", "goimports" },
            c = { "clang_format" },
            cpp = { "clang_format" },
            java = { "google_java_format" },
         },
         format_on_save = {
            timeout_ms = 1000,
            lsp_fallback = true,
         },
      },
   },

   -- todo-comments.nvim
   {
      "folke/todo-comments.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {
         signs = true,
         sign_priority = 8,
         keywords = {
            FIX = {
               icon = " ",
               color = "error",
               alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
            },
            TODO = { icon = " ", color = "info" },
            HACK = { icon = " ", color = "warning" },
            WARN = {
               icon = " ",
               color = "warning",
               alt = { "WARNING", "XXX" },
            },
            PERF = {
               icon = " ",
               alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" },
            },
            NOTE = {
               icon = " ",
               color = "hint",
               alt = { "INFO" },
            },
            TEST = {
               icon = " ",
               color = "test",
               alt = { "TESTING", "PASSED", "FAILED" },
            },
         },
         gui_style = {
            fg = "NONE",
            bg = "BOLD",
         },
         merge_keywords = true,
         highlight = {
            multiline = true,
            multiline_pattern = "^.",
            multiline_context = 10,
            before = "",
            keyword = "wide",
            after = "fg",
            pattern = [[.*<(KEYWORDS)\s*:]],
            comments_only = true,
            max_line_len = 400,
            exclude = {},
         },
         colors = {
            error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
            warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
            info = { "DiagnosticInfo", "#2563EB" },
            hint = { "DiagnosticHint", "#10B981" },
            default = { "Identifier", "#7C3AED" },
            test = { "Identifier", "#FF006E" },
         },
         search = {
            command = "rg",
            args = {
               "--color=never",
               "--no-heading",
               "--with-filename",
               "--line-number",
               "--column",
               "--max-depth=10", -- Limit search depth for performance
               "--exclude-dir=.git",
               "--exclude-dir=node_modules",
               "--exclude-dir=.cache",
            },
            pattern = [[\b(KEYWORDS):]],
         },
      },
      keys = {
         {
            "]t",
            function()
               require("todo-comments").jump_next()
            end,
            desc = "Next todo comment",
         },
         {
            "[t",
            function()
               require("todo-comments").jump_prev()
            end,
            desc = "Previous todo comment",
         },
         { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
         { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
         { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
         { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
      },
   },

   -- telescope.nvim
   {
      "nvim-telescope/telescope.nvim",
      cmd = "Telescope",
      version = false, -- telescope did only one release, so use HEAD for now
      keys = {
         { "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Switch Buffer" },
         { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Grep (root dir)" },
         { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
         { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find Files (root dir)" },
         { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
         { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files (root dir)" },
         { "<leader>fF", "<cmd>Telescope find_files cwd=%:p:h find_command=rg,--ignore,--hidden,--files<cr>", desc = "Find Files (cwd)" },
         { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
         { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
         { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status" },
         { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
         { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
         { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
         { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
         { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
         { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
         { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Grep (root dir)" },
         { "<leader>sG", "<cmd>Telescope live_grep cwd=%:p:h<cr>", desc = "Grep (cwd)" },
         { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
         { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
         { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
         { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
         { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
         { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
         { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
         { "<leader>sw", "<cmd>Telescope grep_string<cr>", desc = "Word (root dir)" },
         { "<leader>sW", "<cmd>Telescope grep_string cwd=%:p:h<cr>", desc = "Word (cwd)" },
         { "<leader>uC", "<cmd>Telescope colorscheme<cr>", desc = "Colorscheme" },
         { "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Goto Symbol" },
         { "<leader>sS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Goto Symbol (Workspace)" },
      },
      opts = {
         defaults = {
            prompt_prefix = " ",
            selection_caret = " ",
            path_display = { "truncate" },
            file_ignore_patterns = { 
               ".git/", 
               "node_modules/", 
               ".cache/",
               ".vscode/",
               ".idea/",
               "build/",
               "dist/",
               "target/",
               "*.pyc",
               "*.pyo",
               "*.pyd",
               "__pycache__/",
               ".pytest_cache/",
               ".coverage",
               "*.so",
               "*.dylib",
               "*.dll",
               "*.exe",
               "*.o",
               "*.obj",
               "*.a",
               "*.lib",
               "*.dll",
               "*.so",
               "*.dylib",
               "*.exe",
               "*.o",
               "*.obj",
               "*.a",
               "*.lib",
            },
            vimgrep_arguments = {
               "rg",
               "--color=never",
               "--no-heading",
               "--with-filename",
               "--line-number",
               "--column",
               "--smart-case",
               "--hidden",
               "--glob=!.git/",
               "--glob=!node_modules/",
               "--glob=!.cache/",
               "--glob=!.vscode/",
               "--glob=!.idea/",
               "--glob=!build/",
               "--glob=!dist/",
               "--glob=!target/",
            },
         },
         pickers = {
            find_files = {
               find_command = { "rg", "--files", "--hidden", "--glob=!.git/", "--glob=!node_modules/" },
            },
         },
      },
   },

   -- Removed Harpoon - user prefers tab navigation workflow

   -- markdown-preview.nvim
   {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      ft = { "markdown" },
      build = function() vim.fn["mkdp#util#install"]() end,
      init = function()
         vim.g.mkdp_filetypes = { "markdown" }
      end,
      keys = {
         { "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
      },
   },

   -- toggleterm.nvim for terminal toggle
   {
      "akinsho/toggleterm.nvim",
      version = "*",
      opts = {
         open_mapping = [[<D-e>]],  -- Cmd+E on macOS
         direction = "horizontal",
         size = 15,
      },
      keys = {
         { "<D-e>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      },
   },
}
