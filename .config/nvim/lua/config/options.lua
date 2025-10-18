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

