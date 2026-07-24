-- ┌──────────────────────────────────────────┐
-- │          Editing Keybinds                │
-- │   Mode switching, text manipulation      │
-- │   Double-tap 'd' to exit Insert mode     │
-- └──────────────────────────────────────────┘

local map = vim.keymap.set

-- ══════════════════════════════════════════════════════════════
-- ║  MODE SWITCHING — The "dd" Escape Sequence                ║
-- ║                                                            ║
-- ║  In INSERT mode, quickly tap 'd' twice to go to NORMAL.   ║
-- ║  Single 'd' still types normally (after timeoutlen delay). ║
-- ║  This works because timeoutlen = 300ms in options.lua.     ║
-- ║                                                            ║
-- ║  Your left index finger rests on 'D' in the W-A-D         ║
-- ║  position, making this extremely natural.                  ║
-- ══════════════════════════════════════════════════════════════

-- NOTE: "dd" in insert mode causes a 300ms lag on every 'd' keystroke because
-- Neovim waits to see if a second 'd' follows (ambiguous key sequence).
-- This is an intentional tradeoff in the config design.
-- If the lag bothers you, use <C-[> or jk instead and remove this mapping.
map("i", "dd", "<Esc>", { desc = "Exit Insert mode (double-tap d)", nowait = false })

-- Also keep Ctrl+[ as an alternative (standard vim Escape equivalent)
-- This is already built into vim, but documenting it here for clarity.

-- Also map Escape in terminal mode to go back to Normal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ── Visual Mode Text Operations ───────────────────────────────
-- Stay in indent mode after indenting
map("v", "<", "<gv",                                        { desc = "Indent left (stay selected)" })
map("v", ">", ">gv",                                        { desc = "Indent right (stay selected)" })
-- NOTE: <Tab> in visual for indent conflicts with treesitter node_incremental (<Tab> only in normal)
-- In VISUAL mode, tab indents (safe: treesitter uses Tab in normal mode only)
map("v", "<Tab>", ">gv",                                    { desc = "Indent right" })
map("v", "<S-Tab>", "<gv",                                  { desc = "Indent left" })

-- Move text up and down in Visual mode (WASD: W=up, S=down)
map("v", "<A-w>", ":m '<-2<cr>gv=gv",                      { desc = "Move selection up" })
map("v", "<A-s>", ":m '>+1<cr>gv=gv",                      { desc = "Move selection down" })

-- Visual Block mode (Ctrl+Shift+V might conflict with paste, so use leader)
map("n", "<leader>v", "<C-v>",                              { desc = "Visual Block mode" })

-- ── Paste Without Overwriting Register ────────────────────────
-- When you paste over selected text, don't yank the deleted text
map("v", "p", '"_dP',                                       { desc = "Paste without yanking" })
map("x", "p", '"_dP',                                       { desc = "Paste without yanking" })

-- ── Delete Without Yanking ────────────────────────────────────
-- Use leader+d to delete without putting text in register
map({ "n", "v" }, "<leader>d", '"_d',                       { desc = "Delete (no yank)" })

-- ── Better Join Lines ─────────────────────────────────────────
-- Join lines without moving cursor
map("n", "J", "mzJ`z",                                     { desc = "Join lines (cursor stays)" })

-- ── Quick Word Selection ──────────────────────────────────────
-- Double-click behavior: select word with leader+w in normal mode
map("n", "<leader>sw", "viw",                               { desc = "Select word under cursor" })

-- ── Add Empty Lines ───────────────────────────────────────────
map("n", "<leader>o", "o<Esc>",                             { desc = "Add empty line below" })
map("n", "<leader>O", "O<Esc>",                             { desc = "Add empty line above" })

-- ── Quick Semicolon/Comma at End of Line ──────────────────────
map("n", "<leader>;", "A;<Esc>",                            { desc = "Add ; at end of line" })
map("n", "<leader>,", "A,<Esc>",                            { desc = "Add , at end of line" })

-- ── Better Insert Mode Navigation ─────────────────────────────
-- Allow cursor movement in insert mode without leaving it
map("i", "<C-h>", "<Left>",                                 { desc = "Move cursor left" })
map("i", "<C-l>", "<Right>",                                { desc = "Move cursor right" })

-- ── Cut Operations (Ctrl+X and Ctrl+Shift+X) ────────────────
-- Ctrl+X: Cut line in Normal/Insert mode, cut selection in Visual mode
map("n", "<C-x>", '"+dd',                                   { desc = "Cut line to clipboard" })
map("v", "<C-x>", '"+x',                                    { desc = "Cut selection to clipboard" })
map("i", "<C-x>", '<Esc>"+ddi',                             { desc = "Cut line and stay in insert mode" })

