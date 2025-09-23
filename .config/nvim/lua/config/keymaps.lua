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
vim.keymap.set("n", "<A-j>", "ddp", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "dd2kp", { desc = "Move line up" })
vim.keymap.set("n", "<C-u>", "<C-r>", { desc = "Redo"})
vim.keymap.set("n", "<C-j>", "<PageDown>", { desc = "Page down"})
vim.keymap.set("n", "<C-k>", "<PageUp>", { desc = "Page up"})

-- Tab control
vim.keymap.set("n", "<A-Right>", ":tabnext<CR>", { desc = "Next Tab" })
vim.keymap.set("n", "<A-l>", ":tabnext<CR>", { desc = "Next Tab" })
vim.keymap.set("n", "<A-Left>", ":tabprev<CR>", { desc = "Previous Tab" })
vim.keymap.set("n", "<A-h>", ":tabprev<CR>", { desc = "Previous Tab" })
vim.keymap.set("n", "<A-1>", "1gt", { desc = "Go to first tab" })
vim.keymap.set("n", "<A-2>", "2gt", { desc = "Go to second tab" })
vim.keymap.set("n", "<A-3>", "3gt", { desc = "Go to ... tab" })
vim.keymap.set("n", "<A-4>", "4gt", { desc = "Go to ... tab" })
vim.keymap.set("n", "<A-5>", "5gt", { desc = "Go to ... tab" })
vim.keymap.set("n", "<A-6>", "6gt", { desc = "Go to ... tab" })
vim.keymap.set("n", "<A-7>", "7gt", { desc = "Go to ... tab" })
vim.keymap.set("n", "<A-8>", "8gt", { desc = "Go to ... tab" })
vim.keymap.set("n", "<A-9>", "9gt", { desc = "Go to ... tab" })
vim.keymap.set("n", "<C-h>", ":w<CR>:tabclose<CR>", { desc = "Close current tab" })
vim.keymap.set("n", "<C-n>", ":tabnew ./<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save current tab" })
vim.keymap.set("n", "<C-r>", ":source ~/.config/nvim/lua/config/lazy.lua<CR>:source ~/.config/nvim/lua/config/keymaps.lua<CR>", { desc = "Reload NeoVim environment" })

-- Copy-Paste
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy selection to Clipboard" })
vim.keymap.set("n", "<C-c>", function()
	local count = vim.v.count == 0 and 1 or vim.v.count
	vim.cmd("normal! m`0v" .. count .. 'jk$"+y``')
end, { desc = "Copy line(s) to Clipboard" })
vim.keymap.set({"n", "i"}, "<C-v>", "\"+p", { desc = "Paste from clipboard" })

-- Diagnostics
vim.keymap.set("n", "<C-e>", ":lua vim.diagnostic.open_float()<CR>", { desc = "Show current line Error" })

-- Wrappers
vim.keymap.set("n", "\"", "lbi\"<esc>ea\"", { desc = "Wrap in quotes" })
vim.keymap.set("v", "\"", "<esc>`>a\"<esc>`<i\"", { desc = "Wrap in quotes" })
vim.keymap.set("i", "\"", "\"\"<esc>i", { desc = "Wrap in quotes" })

vim.keymap.set("n", "'", "lbi'<esc>ea'", { desc = "Wrap in single quotes" })
vim.keymap.set("v", "'", "<esc>`>a'<esc>`<i'", { desc = "Wrap in single quotes" })
vim.keymap.set("i", "'", "''<esc>i", { desc = "Wrap in single quotes" })

vim.keymap.set("n", "{", "lbi{<esc>ea}", { desc = "Wrap in curly braces" })
vim.keymap.set("v", "{", "<esc>`>a}<esc>`<i{", { desc = "Wrap in curly braces" })
vim.keymap.set("i", "{", "{}<esc>i", { desc = "Wrap in curly braces" })

vim.keymap.set("n", "[", "lbi[<esc>ea]", { desc = "Wrap in square brackets" })
vim.keymap.set("v", "[", "<esc>`>a]<esc>`<i[", { desc = "Wrap in square brackets" })
vim.keymap.set("i", "[", "[]<esc>i", { desc = "Wrap in square brackets" })

vim.keymap.set("n", "(", "lbi(<esc>ea)", { desc = "Wrap in paranthesis" })
vim.keymap.set("v", "(", "<esc>`>a)<esc>`<i(", { desc = "Wrap in paranthesis" })
vim.keymap.set("i", "(", "()<esc>i", { desc = "Wrap in paranthesis" })

vim.keymap.set("n", "<C-_>", "gcc", { remap = false, desc = "Comment this" })
vim.keymap.set("i", "<C-_>", "<esc>gcc", { remap = false, desc = "Comment this" })
vim.keymap.set("v", "<C-_>", "gc", { remap = false, desc = "Comment this" })

vim.keymap.set("n", "<C-[>", "<<", { remap = false, desc = "Un-indent" })
vim.keymap.set("v", "<C-[>", "<", { remap = false, desc = "Un-indent" })

vim.keymap.set("n", "<C-]>", ">>", { remap = false, desc = "Indent" })
vim.keymap.set("v", "<C-]>", ">", { remap = false, desc = "Indent" })
