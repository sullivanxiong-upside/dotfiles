-- Autocmds configuration
-- This file contains all autocmd definitions

-- Auto-reload configuration when config files change
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.lua" },
	callback = function()
		-- Only reload if it's a config file
		local file = vim.fn.expand("%")
		if string.find(file, "config/") or string.find(file, "plugins/") then
			vim.cmd("source %")
			vim.notify("Configuration reloaded!", vim.log.levels.INFO)
		end
	end,
	desc = "Reload config on save",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	desc = "Highlight on yank",
})

-- Auto-save on focus lost
vim.api.nvim_create_autocmd("FocusLost", {
	callback = function()
		if vim.bo.modified and not vim.bo.readonly then
			vim.cmd("silent! write")
		end
	end,
	desc = "Auto-save on focus lost",
})

-- Format on save: use Conform if present; otherwise fall back to LSP
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function(args)
		local ok, conform = pcall(require, "conform")
		if ok then
			conform.format({
				bufnr = args.buf,
				async = false,
				lsp_fallback = true, -- uses LSP only if no conform formatter applies
			})
		else
			-- Conform not installed/loaded; try plain LSP format
			if vim.lsp.buf.format then
				vim.lsp.buf.format({ async = false })
			end
		end
	end,
	desc = "Format on save with Conform + LSP fallback",
})

-- Auto-reload files when changed externally
-- Check for external changes on these events
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	callback = function()
		if vim.fn.mode() ~= "c" then -- Don't check in command-line mode
			vim.cmd("checktime")
		end
	end,
	desc = "Check for external file changes",
})

-- Additional triggers for tmux environments
-- WinEnter triggers when switching windows/panes in tmux
vim.api.nvim_create_autocmd({ "WinEnter", "TabEnter" }, {
	callback = function()
		vim.cmd("checktime")
	end,
	desc = "Check for changes when entering window/tab",
})

-- Notify when file is reloaded from disk
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	callback = function()
		vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
	end,
	desc = "Notify on external file reload",
})
