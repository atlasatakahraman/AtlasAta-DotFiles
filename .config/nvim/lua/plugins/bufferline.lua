-- ┌──────────────────────────────────────────┐
-- │         Bufferline (Tab Bar)             │
-- │   Top bar showing open buffers as tabs   │
-- │   Alt+A/D to switch, Alt+1-5 for jump   │
-- └──────────────────────────────────────────┘

return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  opts = {
    options = {
      -- Use built-in LSP for diagnostics indicator
      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(count, level)
        local icon = level:match("error") and " " or " "
        return " " .. icon .. count
      end,

      -- Offset for Neo-tree sidebar
      offsets = {
        {
          filetype = "neo-tree",
          text = " File Explorer",
          text_align = "center",
          separator = true,
          highlight = "Directory",
        },
      },

      -- Visual settings
      separator_style = "thin",        -- Options: "slant", "thick", "thin", "padded_slant"
      show_buffer_close_icons = true,
      show_close_icon = false,
      show_tab_indicators = true,
      always_show_bufferline = true,
      color_icons = true,

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
