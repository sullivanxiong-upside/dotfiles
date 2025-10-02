-- OS Detection for adaptive keybinds
local function is_mac()
    return vim.fn.has("mac") == 1
end

-- Helper function to adapt Alt keybinds for macOS
local function alt_key(key)
    if is_mac() then
        return key:gsub("<A%-", "<D-")
    else
        return key
    end
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
vim.keymap.set("n", alt_key("<A-j>"), "ddp", { desc = "Move line down" })
vim.keymap.set("n", alt_key("<A-k>"), "dd2kp", { desc = "Move line up" })
vim.keymap.set("n", "<C-u>", "<C-r>", { desc = "Redo"})
vim.keymap.set("n", "<C-j>", "<PageDown>", { desc = "Page down" })
vim.keymap.set("n", "<C-k>", "<PageUp>", { desc = "Page up"})

-- Tab control
vim.keymap.set("n", alt_key("<A-Right>"), ":tabnext<CR>", { desc = "Next Tab" })
vim.keymap.set("n", alt_key("<A-l>"), ":tabnext<CR>", { desc = "Next Tab" })
vim.keymap.set("n", alt_key("<A-Left>"), ":tabprev<CR>", { desc = "Previous Tab" })
vim.keymap.set("n", alt_key("<A-h>"), ":tabprev<CR>", { desc = "Previous Tab" })
vim.keymap.set("n", alt_key("<A-1>"), "1gt", { desc = "Go to first tab" })
vim.keymap.set("n", alt_key("<A-2>"), "2gt", { desc = "Go to second tab" })
vim.keymap.set("n", alt_key("<A-3>"), "3gt", { desc = "Go to ... tab" })
vim.keymap.set("n", alt_key("<A-4>"), "4gt", { desc = "Go to ... tab" })
vim.keymap.set("n", alt_key("<A-5>"), "5gt", { desc = "Go to ... tab" })
vim.keymap.set("n", alt_key("<A-6>"), "6gt", { desc = "Go to ... tab" })
vim.keymap.set("n", alt_key("<A-7>"), "7gt", { desc = "Go to ... tab" })
vim.keymap.set("n", alt_key("<A-8>"), "8gt", { desc = "Go to ... tab" })
vim.keymap.set("n", alt_key("<A-9>"), "9gt", { desc = "Go to ... tab" })
vim.keymap.set("n", "<C-BS>", ":w<CR>:tabclose<CR>", { desc = "Close current tab" })
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
vim.keymap.set("n", "<C-f>", ":lua vim.diagnostic.open_float()<CR>", { desc = "Show current line Error" })
vim.keymap.set("n", "<C-e>", "<C-u>", { desc = "Page up (scroll up)" })

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


-- Commenting
vim.keymap.set("n", "<C-/>", function()
    require("Comment.api").toggle.linewise.current()
end, { desc = "Toggle comment for current line" })
vim.keymap.set("v", "<C-/>", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", { desc = "Toggle comment for selection" })

-- Alternative commenting keymaps (in case Ctrl+/ doesn't work)
vim.keymap.set("n", "gcc", function()
    require("Comment.api").toggle.linewise.current()
end, { desc = "Toggle comment for current line" })
vim.keymap.set("v", "gc", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", { desc = "Toggle comment for selection" })

-- Debug: Test what key is actually being received
vim.keymap.set("n", "<C-_>", function()
    print("Ctrl+_ received!")
    require("Comment.api").toggle.linewise.current()
end, { desc = "Toggle comment for current line (Ctrl+_)" })
vim.keymap.set("v", "<C-_>", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", { desc = "Toggle comment for selection (Ctrl+_)" })

-- Copy file path
vim.keymap.set("n", "yY", function()
    local file_path = vim.fn.expand("%:p")
    vim.fn.setreg("+", file_path)
    vim.notify("Copied file path: " .. file_path, vim.log.levels.INFO)
end, { desc = "Copy entire file path to clipboard" })

-- LSP keymaps
vim.keymap.set("n", alt_key("<A-CR>"), function()
    vim.lsp.buf.definition()
end, { desc = "Go to definition (like VSCode F12)" })
