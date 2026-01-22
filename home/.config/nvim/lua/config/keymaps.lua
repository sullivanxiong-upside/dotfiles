-- https://linear.app/upsidelabs/issue/DEV-1062/setup-data-pipelines-configs-for-assembled-- Simple keymap helper for consistent key notation
local function keymap(mode, lhs, rhs, opts)
	vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", opts or {}, { noremap = true, silent = true }))
end

-- vim.keymap.set({modes}, {lhs}, {rhs}, {opts})
-- modes:
-- A string or table of strings specifying the modes in which the keymap is active (e.g., "n" for normal mode, "i" for insert mode, {"n", "v"} for normal and visual modes).
-- lhs:
-- The left-hand side of the keymap (the key combination you press, e.g., "<leader>ff").
--	rhs:
-- The right-hand side of the keymap (what happens when the keymap is triggered, e.g., a command string like "<cmd>Telescope find_files<cr>" or a Lua function).
--	opts:
-- An optional table for additional options, such as desc for a description (used by which-key), noremap, silent, expr, etc.
-- vim.keymap.set("n", "<C-BS>", ":tabclose<CR>", { desc = "Close current tab" })
--						normal, Ctrl + Backspace, :tabclose<CarriageReturn>, { description }

-- Movement
keymap("n", "<A-j>", "ddp", { desc = "Move line down" })
keymap("n", "<A-k>", "dd2kp", { desc = "Move line up" })
vim.keymap.set("n", "<C-u>", "<C-r>", { desc = "Redo" })
vim.keymap.set("n", "<C-j>", "<PageDown>", { desc = "Page down" })
vim.keymap.set("n", "<C-k>", "<PageUp>", { desc = "Page up" })

-- Enhanced Tab Navigation (optimized for tab-based workflow)
-- Tab cycling (most common operations)
keymap("n", "<A-Right>", ":tabnext<CR>", { desc = "Next Tab" })
keymap("n", "<A-Left>", ":tabprev<CR>", { desc = "Previous Tab" })
keymap("n", "<A-l>", ":tabnext<CR>", { desc = "Next Tab" })
keymap("n", "<A-h>", ":tabprev<CR>", { desc = "Previous Tab" })

-- Quick tab jumping (1-9)
keymap("n", "<A-1>", "1gt", { desc = "Go to tab 1" })
keymap("n", "<A-2>", "2gt", { desc = "Go to tab 2" })
keymap("n", "<A-3>", "3gt", { desc = "Go to tab 3" })
keymap("n", "<A-4>", "4gt", { desc = "Go to tab 4" })
keymap("n", "<A-5>", "5gt", { desc = "Go to tab 5" })
keymap("n", "<A-6>", "6gt", { desc = "Go to tab 6" })
keymap("n", "<A-7>", "7gt", { desc = "Go to tab 7" })
keymap("n", "<A-8>", "8gt", { desc = "Go to tab 8" })
keymap("n", "<A-9>", "9gt", { desc = "Go to tab 9" })

-- Tab management
keymap("n", "<A-n>", ":tabnew<CR>", { desc = "New Tab" })
keymap("n", "<A-w>", ":tabclose<CR>", { desc = "Close Tab" })
keymap("n", "<A-s>", ":w<CR>", { desc = "Save" })

-- Tab cycling with Ctrl (alternative)
keymap("n", "<C-Tab>", ":tabnext<CR>", { desc = "Next Tab (Ctrl+Tab)" })
keymap("n", "<C-S-Tab>", ":tabprev<CR>", { desc = "Previous Tab (Ctrl+Shift+Tab)" })

-- Copy-Paste
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy selection to Clipboard" })
vim.keymap.set("n", "<C-c>", function()
	local count = vim.v.count == 0 and 1 or vim.v.count
	vim.cmd("normal! m`0v" .. count .. 'jk$"+y``')
end, { desc = "Copy line(s) to Clipboard" })
vim.keymap.set({ "n", "i" }, "<C-v>", "\"+p", { desc = "Paste from clipboard" })

-- Diagnostics
vim.keymap.set("n", "<C-e>", "<C-u>", { desc = "Page up (scroll up)" })

-- nvim-surround will handle all text wrapping functionality
-- Much simpler and more powerful than custom functions

-- nvim-surround handles all text wrapping automatically
-- No need for complex filetype-specific setup


-- Commenting
vim.keymap.set("n", "<C-/>", function()
	require("Comment.api").toggle.linewise.current()
end, { desc = "Toggle comment for current line" })
vim.keymap.set("v", "<C-/>", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
	{ desc = "Toggle comment for selection" })

-- Comment.nvim provides gcc/gc by default, so no need to redefine

-- Copy file path
vim.keymap.set("n", "yY", function()
	local file_path = vim.fn.expand("%:p")
	vim.fn.setreg("+", file_path)
	vim.notify("Copied file path: " .. file_path, vim.log.levels.INFO)
end, { desc = "Copy entire file path to clipboard" })

-- LSP keymaps
keymap("n", "<A-CR>", function()
	vim.lsp.buf.definition()
end, { desc = "Go to definition (like VSCode F12)" })

-- LSP keymaps (VSCode-style, compatible with Cursor)
-- Note: <D-> notation doesn't work reliably in Neovim, using alternative keybinds
-- These conflict with LazyVim defaults, so using Alt+Enter instead
vim.keymap.set("n", "<A-CR>", function() vim.lsp.buf.definition() end,
	{ desc = "Go to definition (Alt+Enter)", noremap = true, silent = true })
vim.keymap.set("n", "<A-S-CR>", function() vim.lsp.buf.declaration() end,
	{ desc = "Go to declaration (Alt+Shift+Enter)", noremap = true, silent = true })
vim.keymap.set("n", "<leader><CR>", function() vim.lsp.buf.definition() end,
	{ desc = "Go to definition (Leader+Enter)", noremap = true, silent = true })

-- Reload configuration with Lazy
vim.keymap.set("n", "<leader>r", function()
	vim.cmd("Lazy sync")
end, { desc = "Reload with Lazy (leader+r)", noremap = true, silent = true })
