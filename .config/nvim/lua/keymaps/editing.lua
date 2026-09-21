-- ┌──────────────────────────────────────────┐
-- │          Editing Keybinds                │
-- │   Mode switching, text manipulation      │
-- └──────────────────────────────────────────┘

local map = vim.keymap.set

-- ══════════════════════════════════════════════════════════════
-- ║  MODE SWITCHING                                            ║
-- ║                                                            ║
-- ║  Use standard <Esc> or <C-[> to exit INSERT mode to NORMAL.║
-- ══════════════════════════════════════════════════════════════

-- `dd` leaves INSERT. `timeoutlen` decides how long the first d waits for
-- the second, so a real word with a double-d in it (add, odd, address)
-- only types through if you are not slower than that gap.
map("i", "dd", "<Esc>", { desc = "Exit insert mode" })

-- Also map Escape in terminal mode to go back to Normal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ── Visual Mode Text Operations ───────────────────────────────
-- Stay in indent mode after indenting
map("v", "<", "<gv", { desc = "Indent left (stay selected)" })
map("v", ">", ">gv", { desc = "Indent right (stay selected)" })
-- In VISUAL mode, Tab / Shift-Tab indent and keep the selection
map("v", "<Tab>", ">gv", { desc = "Indent right" })
map("v", "<S-Tab>", "<gv", { desc = "Indent left" })

-- Move text up and down in Visual mode (WASD: W=up, S=down)
map("v", "<A-w>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
map("v", "<A-s>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })

-- Visual Block mode (Ctrl+Shift+V might conflict with paste, so use leader)
map("n", "<leader>v", "<C-v>", { desc = "Visual Block mode" })

-- ── Paste Without Overwriting Register ────────────────────────
-- When you paste over selected text, don't yank the deleted text
-- "v" already covers visual + select; the extra "x" map was a duplicate.
map("v", "p", '"_dP', { desc = "Paste without yanking" })

-- ── Delete Without Yanking ────────────────────────────────────
-- Use leader+d to delete without putting text in register
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete (no yank)" })

-- ── Better Join Lines ─────────────────────────────────────────
-- Join lines without moving cursor
map("n", "J", "mzJ`z", { desc = "Join lines (cursor stays)" })

-- ── Quick Word Selection ──────────────────────────────────────
-- Double-click behavior: select word with leader+w in normal mode
map("n", "<leader>sw", "viw", { desc = "Select word under cursor" })

-- ── Add Empty Lines ───────────────────────────────────────────
map("n", "<leader>o", "o<Esc>", { desc = "Add empty line below" })
map("n", "<leader>O", "O<Esc>", { desc = "Add empty line above" })

-- ── Quick Semicolon/Comma at End of Line ──────────────────────
map("n", "<leader>;", "A;<Esc>", { desc = "Add ; at end of line" })
map("n", "<leader>,", "A,<Esc>", { desc = "Add , at end of line" })

-- ── Better Insert Mode Navigation ─────────────────────────────
-- Allow cursor movement in insert mode without leaving it
map("i", "<C-h>", "<Left>", { desc = "Move cursor left" })
map("i", "<C-l>", "<Right>", { desc = "Move cursor right" })

-- ── Cut Operations (Ctrl+X and Ctrl+Shift+X) ────────────────
-- Ctrl+X: Cut line in Normal/Insert mode, cut selection in Visual mode
map("n", "<C-x>", '"+dd', { desc = "Cut line to clipboard" })
map("v", "<C-x>", '"+x', { desc = "Cut selection to clipboard" })
map("i", "<C-x>", '<Esc>"+ddi', { desc = "Cut line and stay in insert mode" })
