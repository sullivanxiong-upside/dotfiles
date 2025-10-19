-- Neovim options configuration
-- This file contains all vim options and settings

-- Leader key configuration
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- General options
vim.o.autoread = true
vim.o.splitright = true
vim.o.number = true
vim.o.relativenumber = true

-- Performance optimizations
vim.o.updatetime = 300 -- Faster completion
vim.o.timeoutlen = 500 -- Faster key sequence timeout
vim.o.lazyredraw = true -- Don't redraw during macros
vim.o.ttyfast = true -- Faster terminal connection
vim.o.synmaxcol = 200 -- Don't syntax highlight long lines
vim.o.hidden = true -- Allow hidden buffers
vim.o.backup = false -- Disable backup files
vim.o.writebackup = false -- Disable write backup
vim.o.swapfile = false -- Disable swap files
vim.o.undofile = false -- Disable persistent undo
vim.o.completeopt = "menu,menuone,noselect" -- Better completion
vim.o.shortmess = "c" -- Don't show completion messages
vim.o.cmdheight = 1 -- Command line height
vim.o.laststatus = 2 -- Always show status line
vim.o.showmode = false -- Don't show mode in status line
vim.o.ruler = false -- Don't show cursor position
vim.o.showcmd = false -- Don't show command
vim.o.incsearch = true -- Incremental search
vim.o.hlsearch = false -- Don't highlight search results by default
vim.o.ignorecase = true -- Case insensitive search
vim.o.smartcase = true -- Case sensitive when uppercase
vim.o.wrap = false -- Don't wrap lines
vim.o.scrolloff = 8 -- Keep 8 lines above/below cursor
vim.o.sidescrolloff = 8 -- Keep 8 columns left/right of cursor
vim.o.guifont = "monospace:h12" -- Set font
vim.o.mouse = "a" -- Enable mouse
vim.o.clipboard = "unnamedplus" -- Use system clipboard
vim.o.termguicolors = true -- Enable true colors
vim.o.background = "dark" -- Dark background
vim.o.cursorline = true -- Highlight current line
vim.o.cursorcolumn = false -- Don't highlight current column
vim.o.signcolumn = "yes" -- Always show sign column
vim.o.foldenable = false -- Disable folding
vim.o.foldmethod = "manual" -- Manual folding
vim.o.foldlevel = 99 -- Open all folds
vim.o.foldlevelstart = 99 -- Open all folds on start
vim.o.foldcolumn = "0" -- Don't show fold column
vim.o.foldtext = "" -- Don't show fold text
vim.o.fillchars = "fold: " -- Fill characters for folds
vim.o.foldnestmax = 3 -- Maximum fold nesting
vim.o.foldminlines = 1 -- Minimum lines to fold
vim.o.foldignore = "" -- Don't ignore any characters
vim.o.foldopen = "block,hor,insert,jump,mark,percent,quickfix,search,tag,undo" -- Open folds on these commands
vim.o.foldclose = "all" -- Close folds on these commands
vim.o.foldenable = false -- Disable folding
vim.o.foldmethod = "manual" -- Manual folding
vim.o.foldlevel = 99 -- Open all folds
vim.o.foldlevelstart = 99 -- Open all folds on start
vim.o.foldcolumn = "0" -- Don't show fold column
vim.o.foldtext = "" -- Don't show fold text
vim.o.fillchars = "fold: " -- Fill characters for folds
vim.o.foldnestmax = 3 -- Maximum fold nesting
vim.o.foldminlines = 1 -- Minimum lines to fold
vim.o.foldignore = "" -- Don't ignore any characters
vim.o.foldopen = "block,hor,insert,jump,mark,percent,quickfix,search,tag,undo" -- Open folds on these commands
vim.o.foldclose = "all" -- Close folds on these commands

-- Tab configuration
-- Use tabs by default, displayed as 3 spaces
vim.opt.expandtab = false
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3
vim.opt.softtabstop = 3

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

