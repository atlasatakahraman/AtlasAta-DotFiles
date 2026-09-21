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

-- ── Theme Toggle (light / dark) ───────────────────────────────
-- Follows whatever colorscheme family is active instead of hard-coding one.
-- (It used to force catppuccin even though tokyonight is the active theme.)
map("n", "<leader>th", function()
  local dark = vim.o.background == "dark"
  local name = vim.g.colors_name or ""

  if name:find("kanagawa") then
    vim.cmd.colorscheme(dark and "kanagawa-lotus" or "kanagawa-dragon")
  elseif name:find("tokyonight") then
    vim.cmd.colorscheme(dark and "tokyonight-day" or "tokyonight-night")
  elseif name:find("catppuccin") then
    vim.cmd.colorscheme(dark and "catppuccin-latte" or "catppuccin-macchiato")
  else
    vim.o.background = dark and "light" or "dark"
  end
end, { desc = "Toggle theme (dark/light)" })

-- ── UI Toggles ────────────────────────────────────────────────
map("n", "<leader>ur", function()
  vim.wo.relativenumber = not vim.wo.relativenumber
end, { desc = "Toggle relative line numbers" })

map("n", "<leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle line wrap" })

map("n", "<leader>ul", function()
  vim.wo.list = not vim.wo.list
end, { desc = "Toggle whitespace markers" })

map("n", "<leader>ud", function()
  local on = vim.diagnostic.config().virtual_text ~= false
  vim.diagnostic.config({ virtual_text = not on and { prefix = "●", spacing = 4 } or false })
end, { desc = "Toggle inline diagnostics" })

map("n", "<leader>uz", function()
  local zen = not vim.g.atlas_zen
  vim.g.atlas_zen = zen
  vim.o.laststatus = zen and 0 or 3
  vim.o.showtabline = zen and 0 or 2
  vim.o.number = not zen
  vim.o.signcolumn = zen and "no" or "yes"
end, { desc = "Toggle zen mode (bars off)" })

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
