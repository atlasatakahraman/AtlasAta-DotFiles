-- ┌──────────────────────────────────────────┐
-- │         Catppuccin Color Scheme          │
-- │   Default: Macchiato (medium dark)       │
-- └──────────────────────────────────────────┘

return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,       
  priority = 1000,    

  opts = {
    flavour = "macchiato",   -- Default flavor: macchiato (medium dark, cool)
    transparent_background = false,
    term_colors = true,

    integrations = {
      bufferline = true,
      gitsigns = true,
      indent_blankline = {
        enabled = true,
        scope_color = "lavender",
        colored_indent_levels = false,
      },
      mason = true,
      noice = true,
      notify = true,
      neo_tree = true,
      telescope = { enabled = true },
      treesitter = true,
      which_key = true,
      native_lsp = {
        enabled = true,
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
      },
    },
  },

  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin-macchiato")
    vim.g.catppuccin_flavor = "macchiato"
  end,
}
