-- ┌──────────────────────────────────────────┐
-- │          Keymaps Module Loader           │
-- │   Loads all keymap files in order        │
-- └──────────────────────────────────────────┘

require("keymaps.general")
require("keymaps.navigation")
require("keymaps.editing")
require("keymaps.plugins")  -- Theme toggle, format, lazy, mason shortcuts
-- NOTE: keymaps.lsp is loaded via LspAttach autocmd (see plugins/lsp.lua)
