-- ┌──────────────────────────────────────────┐
-- │         General Keybinds                 │
-- │   VSCode-familiar shortcuts for a        │
-- │   smooth transition from GUI editors     │
-- └──────────────────────────────────────────┘

local map = vim.keymap.set

-- ── Save / Quit ───────────────────────────────────────────────
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>",        { desc = "Save file" })
map("n", "<leader>q",           "<cmd>q<cr>",              { desc = "Quit" })
map("n", "<leader>Q",           "<cmd>qa!<cr>",            { desc = "Quit all (force)" })
map("n", "<C-q>",               "<cmd>q<cr>",              { desc = "Quit" })

-- ── Undo / Redo (VSCode-style) ────────────────────────────────
map("n", "<C-z>", "u",                                     { desc = "Undo" })
map("i", "<C-z>", "<C-o>u",                                { desc = "Undo" })
map("n", "<C-S-z>", "<C-r>",                               { desc = "Redo" })
map("i", "<C-S-z>", "<C-o><C-r>",                          { desc = "Redo" })
map("n", "<C-y>", "<C-r>",                                 { desc = "Redo" })

-- ── Copy / Cut / Paste (VSCode-style) ─────────────────────────
-- These work alongside vim's default yank/put system
map("v", "<C-c>", '"+y',                                   { desc = "Copy to clipboard" })
map("v", "<C-x>", '"+d',                                   { desc = "Cut to clipboard" })
map("n", "<C-v>", '"+p',                                   { desc = "Paste from clipboard" })
map("v", "<C-v>", '"+p',                                   { desc = "Paste from clipboard" })
map("i", "<C-v>", '<C-r>+',                                { desc = "Paste from clipboard" })
map("c", "<C-v>", "<C-r>+",                                { desc = "Paste from clipboard" })

-- ── Select All ────────────────────────────────────────────────
map("n", "<C-a>", "ggVG",                                  { desc = "Select all" })
map("i", "<C-a>", "<Esc>ggVG",                             { desc = "Select all" })

-- ── Find (uses Telescope — see plugins keymaps) ───────────────
-- Ctrl+F and Ctrl+H are mapped in keymaps/plugins.lua after Telescope loads

-- ── Disable Q (ex mode — confusing for beginners) ─────────────
map("n", "Q", "<nop>",                                     { desc = "Disabled" })

-- ── Better Escape ─────────────────────────────────────────────
-- Press Escape in any mode to clear search highlighting too
map("n", "<Esc>", "<cmd>nohlsearch<cr>",                   { desc = "Clear search highlight" })

-- ── Move Lines Up/Down (VSCode-style Alt+Up/Down) ─────────────
map("n", "<A-Up>",    "<cmd>m .-2<cr>==",                  { desc = "Move line up" })
map("n", "<A-Down>",  "<cmd>m .+1<cr>==",                  { desc = "Move line down" })
map("i", "<A-Up>",    "<esc><cmd>m .-2<cr>==gi",           { desc = "Move line up" })
map("i", "<A-Down>",  "<esc><cmd>m .+1<cr>==gi",           { desc = "Move line down" })
map("v", "<A-Up>",    ":m '<-2<cr>gv=gv",                  { desc = "Move selection up" })
map("v", "<A-Down>",  ":m '>+1<cr>gv=gv",                  { desc = "Move selection down" })

-- ── Duplicate Lines (VSCode-style) ────────────────────────────
map("n", "<C-S-d>", "<cmd>t .<cr>",                        { desc = "Duplicate line down" })
map("v", "<C-S-d>", ":'<,'>t '><cr>gv",                    { desc = "Duplicate selection" })

-- ── Delete Line (VSCode-style Ctrl+Shift+K) ───────────────────
map("n", "<C-S-k>", "dd",                                  { desc = "Delete line" })
map("i", "<C-S-k>", "<esc>ddi",                            { desc = "Delete line" })

-- ── Delete Word Backward (Ctrl+Backspace) ─────────────────────
map("i", "<C-BS>", "<C-w>",                                { desc = "Delete word backward" })
map("c", "<C-BS>", "<C-w>",                                { desc = "Delete word backward" })

-- ── Better Line Beginning/End ─────────────────────────────────
-- Home key goes to first non-blank character
map({ "n", "v" }, "<Home>", "^",                           { desc = "Go to first non-blank" })
map("i", "<Home>", "<C-o>^",                               { desc = "Go to first non-blank" })
