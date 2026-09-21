-- ┌──────────────────────────────────────────┐
-- │            Neo-tree File Explorer        │
-- │   Modern file tree with git integration  │
-- │   Toggle: Ctrl+B or Leader+e             │
-- └──────────────────────────────────────────┘

-- NOTE: netrw is disabled in init.lua (before plugins load)
-- Do NOT set vim.g.loaded_netrw here — it was duplicated before.

--- First window that is not the tree, or nil if the tree is all there is.
local function editor_win()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "neo-tree" then
			return win
		end
	end
end

--- Open the given node in the first non-neo-tree editor window.
--- Extracted from the duplicated <cr>/l/w handlers to avoid code repetition
--- and reduce the chance of bugs in one copy but not another.
local function open_in_editor(state)
	local node = state.tree:get_node()
	if node.type == "directory" then
		state.commands.toggle_node(state)
	else
		-- Find the editor window explicitly, splitting to create one if the
		-- tree is the only window left.
		local win = editor_win()
		if not win then
			vim.cmd("vsplit")
			win = editor_win()
		end
		if win then
			vim.api.nvim_set_current_win(win)
		end

		-- Use the buffer API to bypass Vim command-line parsing entirely.
		local path = node:get_id()
		local ok, err = pcall(function()
			local normalized = path:gsub("\\", "/")
			local bufnr = vim.fn.bufadd(normalized)
			vim.fn.bufload(bufnr)
			vim.bo[bufnr].buflisted = true
			vim.api.nvim_set_current_buf(bufnr)
		end)
		if not ok then
			vim.notify("Neo-tree: could not open " .. path .. "\n" .. tostring(err), vim.log.levels.ERROR)
		end
	end
end

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},

	keys = {
		-- These are the single source of truth for <C-b> and <leader>e: as lazy
		-- `keys` they also load the plugin on first press. keymaps/navigation.lua
		-- used to define both again, and the lazy stubs silently won.
		{ "<C-b>", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
		-- Toggles focus between the tree and the editor.
		-- NOT `Neotree show` + `Neotree focus`: show renders asynchronously and
		-- restores focus to the window you came from, undoing the focus that ran
		-- before it, so you were dropped straight back in the editor. `focus`
		-- alone opens *and* focuses.
		-- Leaving the tree uses editor_win() rather than `wincmd p`, which is a
		-- no-op when the tree was entered any way other than from the editor
		-- (mouse, <C-h>, or being the first window at startup).
		{
			"<leader>e",
			function()
				if vim.bo.filetype == "neo-tree" then
					local win = editor_win()
					if win then
						vim.api.nvim_set_current_win(win)
					end
				else
					vim.cmd("Neotree focus")
				end
			end,
			desc = "Toggle focus: editor / file explorer",
		},
		{ "<leader>ge", "<cmd>Neotree git_status toggle<cr>", desc = "Git explorer" },
		{ "<leader>be", "<cmd>Neotree buffers toggle<cr>", desc = "Buffer explorer" },
	},

	opts = {
		close_if_last_window = true,
		popup_border_style = "rounded",
		enable_diagnostics = true,
		enable_git_status = true,
		hijack_netrw_behavior = "disabled",

		-- Tabs across the top of the sidebar. Equal-width tabs and no edge
		-- separator stop them looking crammed at 34 columns.
		source_selector = {
			winbar = true,
			statusline = false,
			content_layout = "center",
			tabs_layout = "equal",
			show_separator_on_edge = false,
			padding = { left = 1, right = 1 },
			sources = {
				{ source = "filesystem", display_name = "  Files " },
				{ source = "buffers", display_name = "  Buffers " },
				{ source = "git_status", display_name = "  Git " },
			},
		},

		default_component_configs = {
			container = { enable_character_fade = true },

			-- Names carry git colour, so a modified file reads at a glance
			-- instead of you hunting for the status glyph at end of line.
			name = {
				trailing_slash = false,
				use_git_status_colors = true,
				highlight = "NeoTreeFileName",
			},

			modified = { symbol = "● ", highlight = "NeoTreeModified" },

			indent = {
				indent_size = 2,
				padding = 1,
				with_markers = true,
				indent_marker = "│",
				last_indent_marker = "└",
				with_expanders = true,
				expander_collapsed = "",
				expander_expanded = "",
			},

			-- Single-glyph git state, readable at a glance in a 35-col sidebar
			git_status = {
				symbols = {
					added = "",
					modified = "",
					deleted = "✖",
					renamed = "",
					untracked = "★",
					ignored = "",
					unstaged = "",
					staged = "",
					conflict = "",
				},
			},

			-- Diagnostics in the tree mirror the signs used in the gutter
			diagnostics = {
				symbols = {
					hint = "",
					info = "",
					warn = "",
					error = "",
				},
			},
		},

		filesystem = {
			filtered_items = {
				visible = false,
				hide_dotfiles = true,
				hide_gitignored = true,
				hide_hidden = true,
				-- Drop the "(7 hidden items)" trailer: noise on every folder,
				-- and "H" toggles hidden files anyway.
				show_hidden_count = false,
				hide_by_name = {
					"node_modules",
					"target",
				},
				never_show = {},
			},
			follow_current_file = {
				enabled = true,
				leave_dirs_open = true,
			},
			use_libuv_file_watcher = vim.fn.has("win32") == 0,
		},

		window = {
			position = "left",
			width = 34,
			mappings = {
				-- Disable space (don't shadow leader)
				["<space>"] = "none",
				["<leader>e"] = "none",
				["<space>e"] = "none",

				["<cr>"] = open_in_editor,
				["l"] = open_in_editor,
				["w"] = open_in_editor,

				-- ── h: collapse ─────────────────────────────────────────────
				["h"] = "close_node",

				-- ── Arrow keys: Right = open/expand, Left = collapse ────────
				-- Use built-in STRING commands — these are guaranteed to work.
				["<Right>"] = "open",
				["<Left>"] = "close_node",

				-- ── Splits ──────────────────────────────────────────────────
				["<C-v>"] = "open_vsplit",
				["<C-x>"] = "open_split",

				-- ── Preview ─────────────────────────────────────────────────
				["P"] = { "toggle_preview", config = { use_float = true } },

				-- ── Hidden / Ignored Files Toggle ─────────────────────────
				["H"] = "toggle_hidden",
				["I"] = "toggle_hidden",

				-- Disable s (used by surround plugin globally)
				["s"] = "none",
			},
		},

		-- Sidebar-local window options. The global listchars would otherwise
		-- sprinkle dots through the tree, and the cursorline IS the
		-- active-file indicator (themed in themes/kanagawa.lua).
		event_handlers = {
			{
				event = "neo_tree_buffer_enter",
				handler = function()
					vim.opt_local.cursorline = true
					vim.opt_local.cursorlineopt = "line"
					vim.opt_local.number = false
					vim.opt_local.relativenumber = false
					vim.opt_local.signcolumn = "no"
					vim.opt_local.list = false
					vim.opt_local.winhighlight =
						"Normal:NeoTreeNormal,NormalNC:NeoTreeNormalNC,CursorLine:NeoTreeCursorLine"
				end,
			},
		},

		buffers = {
			follow_current_file = {
				enabled = true,
				leave_dirs_open = true,
			},
		},
	},
}
