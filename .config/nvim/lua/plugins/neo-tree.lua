-- ┌──────────────────────────────────────────┐
-- │            Neo-tree File Explorer        │
-- │   Modern file tree with git integration  │
-- │   Toggle: Ctrl+B or Leader+e            │
-- └──────────────────────────────────────────┘

-- NOTE: netrw is disabled in init.lua (before plugins load)
-- Do NOT set vim.g.loaded_netrw here — it was duplicated before.

--- Open the given node in the first non-neo-tree editor window.
--- Extracted from the duplicated <cr>/l/w handlers to avoid code repetition
--- and reduce the chance of bugs in one copy but not another.
local function open_in_editor(state)
  local node = state.tree:get_node()
  if node.type == "directory" then
    state.commands.toggle_node(state)
  else
    -- Find the editor window explicitly, then open
    local editor_win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "neo-tree" then
        editor_win = win
        break
      end
    end

    -- If no editor window exists, split vertically to create one
    if not editor_win then
      vim.cmd("vsplit")
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "neo-tree" then
          editor_win = win
          break
        end
      end
    end

    if editor_win then
      vim.api.nvim_set_current_win(editor_win)
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
    -- NOTE: <C-b> and <leader>e are defined to handle toggle window and focus toggle respectively.
    -- We removed <C-h> from here to prevent overriding the smart window transition map in navigation.lua.
    { "<C-b>",      "<cmd>Neotree toggle<cr>",            desc = "Toggle file explorer" },
    { "<leader>e",  function()
      if vim.bo.filetype == "neo-tree" then
        vim.cmd("wincmd p")
      else
        vim.cmd("Neotree focus")
      end
    end,                                                  desc = "Toggle focus file explorer" },
    { "<leader>ge", "<cmd>Neotree git_status toggle<cr>", desc = "Git explorer" },
    { "<leader>be", "<cmd>Neotree buffers toggle<cr>",    desc = "Buffer explorer" },
  },

  opts = {
    close_if_last_window = true,
    popup_border_style = "rounded",
    enable_diagnostics = true,
    enable_git_status = true,
    hijack_netrw_behavior = "disabled",

    source_selector = {
      winbar = true,
      content_layout = "center",
      sources = {
        { source = "filesystem", display_name = " 󰉓 Files " },
        { source = "buffers",    display_name = " 󰈚 Buffers " },
        { source = "git_status", display_name = " 󰊢 Git " },
      },
    },

    default_component_configs = {
      indent = {
        indent_size = 2,
        padding = 1,
        with_markers = true,
        indent_marker = "│",
        last_indent_marker = "└",
        with_expanders = true,
        expander_collapsed = "",
        expander_expanded = "",
      },
    },

    filesystem = {
      filtered_items = {
        visible = false,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = { "node_modules", "__pycache__", ".git", ".DS_Store", "thumbs.db" },
        never_show = { ".DS_Store", "thumbs.db" },
      },
      follow_current_file = {
        enabled = true,
        leave_dirs_open = true,
      },
      use_libuv_file_watcher = vim.fn.has("win32") == 0,
    },

    window = {
      position = "left",
      width = 35,
      mappings = {
        -- Disable space (don't shadow leader)
        ["<space>"] = "none",
        ["<leader>e"] = "none",
        ["<space>e"] = "none",

        ["<cr>"] = open_in_editor,
        ["l"]    = open_in_editor,
        ["w"]    = open_in_editor,

        -- ── h: collapse ─────────────────────────────────────────────
        ["h"] = "close_node",

        -- ── Arrow keys: Right = open/expand, Left = collapse ────────
        -- Use built-in STRING commands — these are guaranteed to work.
        ["<Right>"] = "open",
        ["<Left>"]  = "close_node",

        -- ── Splits ──────────────────────────────────────────────────
        ["<C-v>"] = "open_vsplit",
        ["<C-x>"] = "open_split",

        -- ── Preview ─────────────────────────────────────────────────
        ["P"] = { "toggle_preview", config = { use_float = true } },

        -- Disable s (used by surround plugin globally)
        ["s"] = "none",
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
