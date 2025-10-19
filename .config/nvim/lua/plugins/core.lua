-- Core plugins configuration
return {
   -- Colorscheme
   {
      "navarasu/onedark.nvim",
      priority = 1000,
      config = function()
         require("onedark").setup({
            style = "dark", -- dark, darker, cool, deep, warm, warmer, light
            transparent = false,
            term_colors = true,
            ending_tildes = false,
            cmp_itemkind_reverse = false,
            toggle_style_key = nil,
            toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" },
            code_style = {
               comments = "italic",
               keywords = "bold",
               functions = "italic,bold",
               strings = "none",
               variables = "none",
            },
            lualine = {
               transparent = false,
            },
            colors = {},
            highlights = {},
            diagnostics = {
               darker = true,
               undercurl = true,
               background = true,
            },
         })
         vim.cmd("colorscheme onedark")
      end,
   },

   -- LSP and completion
   { "neovim/nvim-lspconfig" },
   { "williamboman/mason.nvim" },
   { "williamboman/mason-lspconfig.nvim" },
   {
      "hrsh7th/nvim-cmp",
      dependencies = {
         "hrsh7th/cmp-nvim-lsp",
         "hrsh7th/cmp-buffer",
         "hrsh7th/cmp-path",
      },
   },

   -- Treesitter
   {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
         require("nvim-treesitter.configs").setup({
            -- Only install essential parsers to reduce startup time
            ensure_installed = { "lua", "vim" },
            auto_install = false, -- Disable auto-install for better performance
            highlight = {
               enable = true,
               disable = {}, -- Don't disable any languages
            },
            indent = { enable = true },
            incremental_selection = {
               enable = true,
               keymaps = {
                  init_selection = "<C-space>",
                  node_incremental = "<C-space>",
                  scope_incremental = "<C-s>",
                  node_decremental = "<C-backspace>",
               },
            },
         })
      end,
   },

   -- Comment plugin (lazy loaded)
   {
      "numToStr/Comment.nvim",
      event = "VeryLazy", -- Load only when needed
      config = function()
         require("Comment").setup()
      end,
   },
}

