-- ┌──────────────────────────────────────────┐
-- │         Tokyonight Color Scheme          │
-- │   Default: tokyonight-night (dark)       │
-- └──────────────────────────────────────────┘

return {
  "folke/tokyonight.nvim",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  version = "*", -- Track the latest stable release (currently v4.15.0+)
  opts = {
    style = "night", -- Other options: storm, moon, day
    transparent = false,
    terminal_colors = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
      sidebars = "dark", -- style for sidebars
      floats = "dark", -- style for floating windows
    },
    
    -- ── Custom Theming ──────────────────────────────────────────
    -- Override specific colors (e.g., bg, fg, blue, green)
    on_colors = function(colors)
      -- colors.bg = "#1a1b26"
    end,

    -- Override specific highlight groups
    on_highlights = function(hl, c)
      -- hl.TelescopeBorder = { fg = c.blue, bg = c.bg_dark }
    end,
  },
  config = function(_, opts)
    require("tokyonight").setup(opts)
    -- load the colorscheme here
    vim.cmd([[colorscheme tokyonight-night]])
  end,
}
