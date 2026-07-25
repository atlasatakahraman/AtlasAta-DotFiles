-- ┌──────────────────────────────────────────┐
-- │            Vim Options                   │
-- │   General editor behavior & appearance   │
-- └──────────────────────────────────────────┘

local opt = vim.opt

-- ── Encoding ──────────────────────────────────────────────────
opt.fileencoding = "utf-8"          -- File encoding (encoding is always utf-8 in Neovim)

-- ── Indentation ───────────────────────────────────────────────
opt.expandtab = true                -- Use spaces instead of tabs
opt.shiftwidth = 4                  -- Indent size
opt.tabstop = 4                     -- Tab character width
opt.softtabstop = 4                 -- Tab key inserts 4 spaces
opt.smartindent = true              -- Smart auto-indentation
opt.autoindent = true               -- Copy indent from current line

-- ── Line Numbers ──────────────────────────────────────────────
opt.number = true                   -- Show absolute line numbers
opt.relativenumber = false          -- No relative numbers (beginner-friendly)
opt.numberwidth = 4                 -- Gutter width for line numbers
opt.signcolumn = "yes"              -- Always show sign column (prevents layout shift)

-- ── Display ───────────────────────────────────────────────────
opt.wrap = false                    -- No line wrapping
opt.showmode = false                -- Don't show mode (lualine shows it)
opt.cursorline = true               -- Highlight current line
opt.termguicolors = true            -- True color support
opt.pumheight = 12                  -- Max completion popup height
opt.cmdheight = 1                   -- Command line height
opt.laststatus = 3                  -- Global statusline
opt.conceallevel = 0                -- Show all text (no concealing)
opt.showtabline = 2                 -- Always show tabline

-- ── Search ────────────────────────────────────────────────────
opt.hlsearch = true                 -- Highlight search results
opt.incsearch = true                -- Incremental search
opt.ignorecase = true               -- Case-insensitive search
opt.smartcase = true                -- Case-sensitive if uppercase used

-- ── Files & Backup ────────────────────────────────────────────
opt.backup = false                  -- No backup files
opt.writebackup = false             -- No write backup
opt.swapfile = false                -- No swap files
opt.undofile = true                 -- Persistent undo history
opt.undolevels = 10000              -- Many undo levels

-- ── Clipboard ─────────────────────────────────────────────
-- Deferred: clipboard provider detection is synchronous and can add 50-150ms
-- to startup (especially on Windows). Schedule it to run after init completes.
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- ── Mouse ─────────────────────────────────────────────────────
opt.mouse = "a"                     -- Full mouse support

-- ── Scrolling ─────────────────────────────────────────────────
opt.scrolloff = 8                   -- Lines above/below cursor
opt.sidescrolloff = 8               -- Columns left/right of cursor

-- ── Splits ────────────────────────────────────────────────────
opt.splitbelow = true               -- Horizontal splits open below
opt.splitright = true               -- Vertical splits open right

-- ── Performance ───────────────────────────────────────────────
opt.updatetime = 250                -- Faster CursorHold events
opt.timeoutlen = 300                -- Time for key sequence (fast for dd escape)
opt.redrawtime = 1500               -- Time for redrawing screen

-- ── Completion ────────────────────────────────────────────────
opt.completeopt = { "menuone", "noselect" }

-- ── Miscellaneous ─────────────────────────────────────────────
opt.shortmess:append("c")           -- Don't show completion messages
opt.shortmess:append("I")           -- Don't show intro message
opt.iskeyword:append("-")           -- Treat hyphenated words as one word
opt.formatoptions:remove({ "c", "r", "o" }) -- Don't auto-insert comment leaders
opt.whichwrap:append("<,>,[,],h,l") -- Allow cursor to wrap lines

-- ── Filetype-Specific Indentation ─────────────────────────────
local filetype_group = vim.api.nvim_create_augroup("FileTypeIndent", { clear = true })

-- 2-space indentation for web and config files
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "html", "css", "scss", "less",
    "javascript", "javascriptreact", "typescript", "typescriptreact",
    "json", "jsonc", "yaml", "yml",
    "lua", "xml", "graphql", "svelte", "vue",
  },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
  group = filetype_group,
})

-- Wrap + spell check for text files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
  group = filetype_group,
})
