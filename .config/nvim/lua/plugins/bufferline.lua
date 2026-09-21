-- ┌──────────────────────────────────────────┐
-- │         Bufferline (Tab Bar)             │
-- │   Top bar showing open buffers as tabs   │
-- │   Alt+A/D to switch, Alt+1-5 for jump    │
-- └──────────────────────────────────────────┘

return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  keys = {
    { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin/unpin buffer" },
    { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
    { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Close buffers to the left" },
    { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Close buffers to the right" },
    { "<A-S-a>", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer left" },
    { "<A-S-d>", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer right" },
    -- Alt+1..5 jump to the buffer whose ordinal is shown on the tab.
    -- These used to be "1gt" etc., which switches TAB PAGES -- a bar you never
    -- use -- so the numbers on screen pointed at nothing.
    { "<A-1>", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "Go to buffer 1" },
    { "<A-2>", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "Go to buffer 2" },
    { "<A-3>", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "Go to buffer 3" },
    { "<A-4>", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "Go to buffer 4" },
    { "<A-5>", "<cmd>BufferLineGoToBuffer 5<cr>", desc = "Go to buffer 5" },
  },

  opts = {
    options = {
      -- Use built-in LSP for diagnostics indicator
      diagnostics = "nvim_lsp",

      -- Offset for Neo-tree sidebar
      offsets = {
        {
          filetype = "neo-tree",
          text = "  EXPLORER",
          text_align = "left",
          separator = true,
          highlight = "Directory",
        },
      },

      -- ── Shape (Image 2 style: clean text, no numbers/icons/close buttons) ──
      separator_style = "none",
      indicator = { style = "none" },
      modified_icon = "",
      buffer_close_icon = "",
      close_icon = "",
      left_trunc_marker = "",
      right_trunc_marker = "",

      -- ── Density & Style ──────────────────────────────────────
      max_name_length = 24,
      truncate_names = true,
      tab_size = 0,
      show_buffer_icons = false,
      show_buffer_close_icons = false,
      show_close_icon = false,
      show_tab_indicators = false,
      always_show_bufferline = true,
      numbers = "none",

      -- Match Image 2 "+ filename" when modified
      name_formatter = function(buf)
        local is_modified = vim.api.nvim_get_option_value("modified", { buf = buf.bufnr })
        if is_modified then
          return "+ " .. buf.name
        end
        return buf.name
      end,

      -- Sort so tab order matches what you see, not internal buffer ids
      sort_by = "insert_after_current",

      -- Don't show certain buffer types
      custom_filter = function(buf_number)
        local buf_ft = vim.bo[buf_number].filetype
        if buf_ft == "qf" then return false end
        if buf_ft == "" and vim.fn.bufname(buf_number) == "" then return false end
        return true
      end,
    },
  },
}
