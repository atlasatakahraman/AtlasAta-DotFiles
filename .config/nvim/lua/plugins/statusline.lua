-- ┌──────────────────────────────────────────┐
-- │          Lualine Status Line             │
-- │   Bottom bar: mode, branch, file, etc.   │
-- │   Catppuccin integrated                  │
-- └──────────────────────────────────────────┘

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  opts = {
    options = {
      theme = "auto", -- 'auto' perfectly mirrors whatever colorscheme is loaded
      globalstatus = true,           -- Single statusline for all windows
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = {
        statusline = { "dashboard", "alpha" },
      },
    },

    sections = {
      -- Left side
      lualine_a = {
        {
          "mode",
          fmt = function(str)
            -- Show full mode name for learning
            local mode_map = {
              ["NORMAL"]   = " NORMAL",
              ["INSERT"]   = " INSERT",
              ["VISUAL"]   = "󰈈 VISUAL",
              ["V-LINE"]   = "󰈈 V-LINE",
              ["V-BLOCK"]  = "󰈈 V-BLOCK",
              ["COMMAND"]  = " COMMAND",
              ["REPLACE"]  = " REPLACE",
              ["TERMINAL"] = " TERMINAL",
            }
            return mode_map[str] or str
          end,
        },
      },
      lualine_b = {
        { "branch", icon = "" },
        {
          "diff",
          symbols = { added = " ", modified = " ", removed = " " },
        },
      },
      lualine_c = {
        {
          "filename",
          path = 1,                  -- Show relative path
          symbols = {
            modified = " ●",
            readonly = " 󰌾",
            unnamed = " [No Name]",
            newfile = " [New]",
          },
        },
      },

      -- Right side
      lualine_x = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = {
            error = " ",
            warn = " ",
            info = "󰋽 ",
            hint = "󰌵 ",
          },
        },
        { "filetype", icon_only = false },
      },
      lualine_y = {
        { "encoding" },
        { "fileformat", symbols = { unix = "LF", dos = "CRLF", mac = "CR" } },
      },
      lualine_z = {
        { "progress" },
        { "location" },
      },
    },

    -- Inactive windows (when using non-global statusline)
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { { "filename", path = 1 } },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },

    extensions = { "neo-tree", "lazy", "toggleterm", "trouble" },
  },
}
