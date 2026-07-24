-- ┌──────────────────────────────────────────┐
-- │        Plugin-Specific Keybinds          │
-- │   Loaded after plugins initialize        │
-- │   Grouped by plugin for easy reference   │
-- └──────────────────────────────────────────┘

-- NOTE: Many plugin keybinds are defined inside their respective
-- plugin config files (e.g., telescope.lua, neo-tree.lua).
-- This file contains ADDITIONAL keybinds that reference plugins
-- or cross-plugin bindings that don't belong in a single plugin file.

local map = vim.keymap.set

-- ── Theme Toggle ──────────────────────────────────────────────
-- Switch between Catppuccin Macchiato (dark) and Latte (light)
map("n", "<leader>th", function()
  local current = vim.g.catppuccin_flavor or "macchiato"
  if current == "macchiato" then
    vim.g.catppuccin_flavor = "latte"
    vim.cmd("colorscheme catppuccin-latte")
  else
    vim.g.catppuccin_flavor = "macchiato"
    vim.cmd("colorscheme catppuccin-macchiato")
  end
end, { desc = "Toggle theme (dark/light)" })

-- ── Format File ───────────────────────────────────────────────
map({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format file/selection" })

map({ "n", "v" }, "<C-S-f>", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format file (Ctrl+Shift+F)" })

-- ── Lazy Plugin Manager ───────────────────────────────────────
map("n", "<leader>lz", "<cmd>Lazy<cr>",                    { desc = "Open Lazy plugin manager" })

-- ── Mason LSP Manager ─────────────────────────────────────────
map("n", "<leader>lm", "<cmd>Mason<cr>",                   { desc = "Open Mason LSP manager" })
