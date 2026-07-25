-- ┌──────────────────────────────────────────┐
-- │           Core Module Loader             │
-- │   Loads options, neovide, and autocmds   │
-- └──────────────────────────────────────────┘

require("core.options")

-- Only load Neovide settings when running inside Neovide
if vim.g.neovide then
  require("core.neovide")
end

require("core.autocmds")
