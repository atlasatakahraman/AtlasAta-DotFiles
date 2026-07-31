-- ┌──────────────────────────────────────────┐
-- │       Caelestia Color Scheme             │
-- │   Dynamic Material Design 3 theme        │
-- │   Syncs with caelestia-shell in realtime │
-- └──────────────────────────────────────────┘

return {
  "atdma/caelestia-nvim",
  priority = 1000,    -- Load before other plugins
  lazy = false,       -- Must load on startup

  config = function()
    require("caelestia").setup()
    vim.cmd.colorscheme("caelestia")
  end,
}
