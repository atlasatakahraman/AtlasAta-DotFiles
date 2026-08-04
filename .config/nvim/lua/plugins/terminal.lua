-- ┌──────────────────────────────────────────┐
-- │          toggleterm.nvim                 │
-- │   Floating/horizontal terminal toggle    │
-- │   Ctrl+\ to toggle, multiple instances  │
-- └──────────────────────────────────────────┘

return {
	"akinsho/toggleterm.nvim",
	version = "*",

	keys = {
		{ "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
		{ "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
		{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
		{ "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Vertical terminal" },
		{ "<leader>ts", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal terminal" },
	},

	opts = {
		size = function(term)
			if term.direction == "horizontal" then
				return 15
			elseif term.direction == "vertical" then
				return vim.o.columns * 0.4
			end
		end,

		open_mapping = [[<C-\>]],
		direction = "float", -- Default: floating terminal
		close_on_exit = true,
		hide_numbers = true,
		shade_terminals = true,
		shading_factor = 2,

		-- Auto-detect shell based on OS
		shell = (function()
			if vim.fn.has("win32") == 1 then
				-- Use pwsh (PowerShell Core) if available — faster startup
				-- Add -NoLogo -NoProfile to skip banner and profile loading (~1-2s delay)
				if vim.fn.executable("pwsh") == 1 then
					return "pwsh -NoLogo"
				end
				return "pwsh -NoLogo"
			else
				if vim.fn.executable("fish") == 1 then
					return "fish"
				end
				return vim.o.shell
			end
		end)(),

		-- Float settings
		float_opts = {
			border = "rounded",
			width = function()
				return math.floor(vim.o.columns * 0.8)
			end,
			height = function()
				return math.floor(vim.o.lines * 0.8)
			end,
			winblend = 3,
		},

		-- Terminal keymaps
		on_open = function(term)

			-- Close Neo-tree if it is open (saves layout squashing on vertical open)
			local neotree_open = false
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
					neotree_open = true
					break
				end
			end
			vim.g.neotree_was_open = neotree_open
			if neotree_open then
				vim.cmd("Neotree close")
			end

			-- Ctrl+\ to close from terminal mode too
			vim.keymap.set("t", "<C-\\>", "<cmd>ToggleTerm<cr>", { buffer = term.bufnr })
			-- dd to enter normal mode from terminal insert mode (avoids Esc)
			vim.keymap.set("t", "dd", "<C-\\><C-n>", { buffer = term.bufnr })
			-- Space+W in normal mode inside terminal to focus back to editor
			vim.keymap.set("n", "<leader>w", function()
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
					if ft ~= "neo-tree" and ft ~= "toggleterm" then
						vim.api.nvim_set_current_win(win)
						return
					end
				end
			end, { buffer = term.bufnr })
		end,

		on_close = function(term)
			-- Restore Neo-tree if it was open before the terminal opened
			if vim.g.neotree_was_open then
				vim.cmd("Neotree show")
				vim.g.neotree_was_open = false
			end
		end,
	},
}
