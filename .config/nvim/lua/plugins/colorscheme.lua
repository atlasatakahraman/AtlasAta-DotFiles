-- ┌──────────────────────────────────────────┐
-- │           Theme Switcher                 │
-- │   Change the string below to switch      │
-- │   between themes in `lua/themes/`        │
-- └──────────────────────────────────────────┘

local active_theme = "caelestia" -- options: "caelestia", "tokyonight", "catppuccin"

return require("themes." .. active_theme)
