-- ┌──────────────────────────────────────────┐
-- │        Navigation Keybinds               │
-- │   Window, buffer, and tab navigation     │
-- │   Optimized for Turkish-Q hand position  │
-- │   Left: W-A-D  |  Right: Enter-Ü-Ş      │
-- └──────────────────────────────────────────┘

local map = vim.keymap.set

-- ── Window Navigation (J/K/L/H smart toggle) ──────────────────
-- Smart Ctrl+H: Focus left window if there is one; otherwise toggle Neo-tree
local function focus_left_or_toggle_neotree()
  local current_win = vim.api.nvim_get_current_win()
  vim.cmd("wincmd h")
  if vim.api.nvim_get_current_win() == current_win then
    vim.cmd("Neotree toggle")
  end
end

map("n", "<C-j>", "<C-w>j",                                { desc = "Focus below window" })
map("n", "<C-k>", "<C-w>k",                                { desc = "Focus above window" })
map("n", "<C-l>", "<C-w>l",                                { desc = "Focus right window" })
map("n", "<C-h>", focus_left_or_toggle_neotree,            { desc = "Focus left window or toggle neo-tree" })

-- Ctrl+B: simple neo-tree open / close toggle (swapped with Space+e)
map("n", "<C-b>", "<cmd>Neotree toggle<cr>",               { desc = "Toggle neo-tree" })

-- <leader>e: toggle focus to/from neo-tree
--   • Neo-tree closed             → open and focus it
--   • Focus in neo-tree           → focus back to editor
--   • Focus in editor (tree open) → focus neo-tree
local function toggle_neotree_focus()
  if vim.bo.filetype == "neo-tree" then
    vim.cmd("wincmd p")
  else
    vim.cmd("Neotree focus")
  end
end
map("n", "<leader>e", toggle_neotree_focus, { desc = "Toggle focus file explorer" })

-- Protect neo-tree width when vertical splits (e.g. vertical terminal) open
vim.api.nvim_create_autocmd("FileType", {
  pattern = "neo-tree",
  callback = function()
    vim.wo.winfixwidth = true
  end,
})

-- <leader>w: toggle focus between editor and terminal
--   • Focus in editor    → jump to terminal window and enter insert mode
--   • Focus in terminal  → jump back to editor
--   • No terminal open   → open a floating terminal
local function focus_terminal()
  local term_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "toggleterm" then
      term_win = win
      break
    end
  end

  if term_win then
    if vim.api.nvim_get_current_win() == term_win then
      vim.cmd.stopinsert()
      -- Find the first non-neo-tree, non-toggleterm editor window
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
        if ft ~= "neo-tree" and ft ~= "toggleterm" then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
    else
      vim.api.nvim_set_current_win(term_win)
      vim.cmd.startinsert()
    end
  else
    if vim.fn.exists(":ToggleTerm") ~= 2 then
      require("lazy").load({ plugins = { "toggleterm.nvim" } })
    end
    vim.cmd("ToggleTerm direction=vertical")
  end
end
map("n", "<leader>w", focus_terminal, { desc = "Focus terminal" })

-- Terminal-mode equivalents (for window switching inside toggleterm)
map("t", "<C-j>", "<C-\\><C-n><C-w>j",                    { desc = "Focus below window" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k",                    { desc = "Focus above window" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l",                    { desc = "Focus right window" })
map("t", "<C-h>", function()
  vim.cmd.stopinsert()
  focus_left_or_toggle_neotree()
end, { desc = "Focus left window or toggle neo-tree" })

-- ── Window Resize ───────────────────────────────────────────────
-- Removed Ctrl+Arrow mappings to allow standard word-by-word text navigation

-- ── Window Splits ─────────────────────────────────────────────
map("n", "<leader>sv", "<cmd>vsplit<cr>",                   { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<cr>",                    { desc = "Split horizontal" })
map("n", "<leader>sc", "<cmd>close<cr>",                    { desc = "Close split" })
map("n", "<leader>se", "<C-w>=",                            { desc = "Equalize splits" })

-- ── Buffer Navigation (Alt+A/D — left hand reach) ─────────────
-- Alt+A = previous buffer, Alt+D = next buffer (WASD: A=left, D=right)
-- Add Meta key mapping (<M-a>, <M-d>) for Windows/Neovide compatibility
map("n", "<A-a>", "<cmd>bprevious<cr>",                    { desc = "Previous buffer" })
map("n", "<A-d>", "<cmd>bnext<cr>",                        { desc = "Next buffer" })
map("n", "<M-a>", "<cmd>bprevious<cr>",                    { desc = "Previous buffer" })
map("n", "<M-d>", "<cmd>bnext<cr>",                        { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>",                    { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>",                        { desc = "Next buffer" })

-- Close current buffer (without closing the window)
map("n", "<leader>bd", "<cmd>bdelete<cr>",                  { desc = "Close buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<cr>",                 { desc = "Force close buffer" })

-- Close the active split/window (Ctrl+W)
map({ "n", "v" }, "<C-w>", "<cmd>close<cr>",                { desc = "Close active window" })

-- ── Half-Page Scrolling (centered) ────────────────────────────
map("n", "<C-d>", "<C-d>zz",                               { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz",                               { desc = "Scroll up (centered)" })

-- ── Search Results Stay Centered ──────────────────────────────
map("n", "n", "nzzzv",                                     { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv",                                     { desc = "Previous search result (centered)" })

-- ── Tab Management ────────────────────────────────────────────
map("n", "<leader>tn", "<cmd>tabnew<cr>",                   { desc = "New tab" })
map("n", "<leader>tc", "<cmd>tabclose<cr>",                 { desc = "Close tab" })
map("n", "<A-1>", "1gt",                                   { desc = "Go to tab 1" })
map("n", "<A-2>", "2gt",                                   { desc = "Go to tab 2" })
map("n", "<A-3>", "3gt",                                   { desc = "Go to tab 3" })
map("n", "<A-4>", "4gt",                                   { desc = "Go to tab 4" })
map("n", "<A-5>", "5gt",                                   { desc = "Go to tab 5" })

-- ── Command Line Access ───────────────────────────────────────
-- Map RightShift+: to open the native command line
map({ "n", "v" }, "<R-S-:>", ":", { desc = "Enter command line" })

-- ── Keyword Search (Ctrl+F) ────────────────────────────────────
-- Triggers Neovim's native search which integrates with Noice.nvim floating UI
map({ "n", "v" }, "<C-f>", "/", { desc = "Search file" })
map("i", "<C-f>", "<Esc>/", { desc = "Search file" })

