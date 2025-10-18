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
            ensure_installed = { "lua", "python", "vim" },
            indent = { enable = true },
         })
      end,
   },

   -- Comment plugin
   {
      "numToStr/Comment.nvim",
      config = function()
         require("Comment").setup()
      end,
   },
}

