-- ┌──────────────────────────────────────────┐
-- │          Lualine Status Line             │
-- │   Bottom bar: mode, branch, file, etc.   │
-- │   Follows the active colorscheme         │
-- └──────────────────────────────────────────┘

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  opts = function()
    -- Only render heavy right-hand components when the window is wide enough,
    -- so a vertical split or a narrow Neovide window stays readable.
    local function wide()
      return vim.o.columns > 100
    end

    return {
      options = {
        theme = "auto", -- mirrors whatever colorscheme is loaded
        globalstatus = true,
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = { "dashboard", "alpha", "neo-tree" },
          winbar = {},
        },
        refresh = { statusline = 200 },
      },

      sections = {
        -- Left side
        lualine_a = {
          {
            "mode",
            fmt = function(str)
              local mode_map = {
                ["NORMAL"]   = " NORMAL",
                ["INSERT"]   = " INSERT",
                ["VISUAL"]   = " VISUAL",
                ["V-LINE"]   = " V-LINE",
                ["V-BLOCK"]  = " V-BLOCK",
                ["COMMAND"]  = " COMMAND",
                ["REPLACE"]  = " REPLACE",
                ["TERMINAL"] = " TERMINAL",
              }
              return mode_map[str] or str
            end,
          },
        },
        lualine_b = {
          { "branch", icon = "", cond = wide },
          { "diff" },
        },
        lualine_c = {
          {
            "filename",
            path = 1, -- relative path
            symbols = {
              modified = " ●",
              readonly = " ",
              unnamed = " [No Name]",
              newfile = " [New]",
            },
          },
          -- Search progress: noice's search_count message is routed away, so
          -- without this you get no "3 of 12" feedback at all.
          {
            function()
              local sc = vim.fn.searchcount({ maxcount = 999 })
              if not sc.total or sc.total == 0 then
                return ""
              end
              return string.format(" %d/%d", sc.current, sc.total)
            end,
            cond = function()
              return vim.v.hlsearch == 1
            end,
          },
        },

        -- Right side
        lualine_x = {
          -- Which language servers are actually attached (silence == a real signal)
          {
            function()
              local names = {}
              for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                names[#names + 1] = client.name
              end
              return #names > 0 and table.concat(names, ", ") or ""
            end,
            cond = wide,
          },
          { "diagnostics", sources = { "nvim_diagnostic" } },
          { "filetype", icon_only = false, cond = wide },
        },
        lualine_y = {
          -- Only shout about non-default encodings/line endings
          {
            "encoding",
            cond = function()
              return wide() and vim.bo.fileencoding ~= "" and vim.bo.fileencoding ~= "utf-8"
            end,
          },
          {
            "fileformat",
            symbols = { unix = "LF", dos = "CRLF", mac = "CR" },
            cond = function()
              return wide() and vim.bo.fileformat ~= "unix"
            end,
          },
          { "progress" },
        },
        lualine_z = {
          { "location", padding = { left = 1, right = 1 } },
        },
      },

      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },

      extensions = { "neo-tree", "lazy", "mason", "toggleterm", "trouble" },
    }
  end,
}
