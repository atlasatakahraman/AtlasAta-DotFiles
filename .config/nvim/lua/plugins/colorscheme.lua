-- ┌──────────────────────────────────────────┐
-- │           Theme Switcher                 │
-- │   Change the string below to switch      │
-- │   between themes in `lua/themes/`        │
-- └──────────────────────────────────────────┘

local active_theme = "tokyonight" -- options: "tokyonight", "catppuccin"

return require("themes." .. active_theme)
