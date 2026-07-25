-- ┌──────────────────────────────────────────┐
-- │           Auto-Commands                  │
-- │   Automatic behaviors & quality of life  │
-- └──────────────────────────────────────────┘

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ── Highlight on Yank (brief flash when copying) ──────────────
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    -- vim.hl.on_yank is Nvim 0.13+; older versions use vim.highlight.on_yank
    local hl_mod = vim.hl or vim.highlight
    hl_mod.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- ── Restore Cursor Position ───────────────────────────────────
-- When reopening a file, jump to the last known cursor position
augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
  group = "RestoreCursor",
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── Auto-Resize Splits ───────────────────────────────────────
-- When terminal window is resized, equalize split sizes
augroup("AutoResize", { clear = true })
autocmd("VimResized", {
  group = "AutoResize",
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- ── Close Special Buffers with 'q' ───────────────────────────
-- Close help, man, quickfix, etc. with just pressing 'q'
augroup("CloseWithQ", { clear = true })
autocmd("FileType", {
  group = "CloseWithQ",
  pattern = {
    "help", "man", "qf", "lspinfo",
    "notify", "checkhealth", "startuptime",
    "spectre_panel", "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", {
      buffer = event.buf,
      silent = true,
      desc = "Close buffer",
    })
  end,
})

-- ── Disable Auto Comment on New Line ──────────────────────────
augroup("NoAutoComment", { clear = true })
autocmd("BufEnter", {
  group = "NoAutoComment",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- ── Auto-Create Directories ──────────────────────────────────
-- When saving a file, auto-create parent directories if they don't exist
augroup("AutoCreateDir", { clear = true })
autocmd("BufWritePre", {
  group = "AutoCreateDir",
  callback = function(event)
    -- Skip remote files (e.g. scp://, oil://, etc.) — 2+ letter scheme + ://
    if event.match:match("^%a%a+://") then
      return
    end
    -- Expand to absolute path; for new files realpath returns nil, use match directly
    local path = vim.fn.expand(event.match)
    local dir = vim.fn.fnamemodify(path, ":p:h")
    -- Only mkdir if the directory doesn't exist
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- ── Check if File Changed Outside of Neovim ──────────────────
augroup("CheckFileChange", { clear = true })
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = "CheckFileChange",
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- ── Handle Directory Startup Cleanly ──────────────────────────
-- Intercepts directory buffers immediately on entry (BufEnter),
-- replaces them with a clean unnamed listed buffer, and wipes the directory buffer.
-- This bypasses Windows path-escaping/parentheses bugs globally.
augroup("DirStartup", { clear = true })
autocmd("BufEnter", {
  group = "DirStartup",
  callback = function(event)
    local bufname = vim.api.nvim_buf_get_name(event.buf)
    if vim.fn.isdirectory(bufname) == 1 then
      -- 1. Create a clean unnamed listed buffer
      local new_buf = vim.api.nvim_create_buf(true, false)
      -- 2. Switch the current window to the new buffer
      vim.api.nvim_win_set_buf(0, new_buf)
      -- 3. Delete the directory buffer (forcefully since it's unneeded)
      pcall(vim.api.nvim_buf_delete, event.buf, { force = true })

      -- 4. Schedule opening Neo-tree sidebar
      vim.schedule(function()
        if vim.fn.exists(":Neotree") ~= 2 then
          require("lazy").load({ plugins = { "neo-tree.nvim" } })
        end
        vim.cmd("Neotree show")
      end)
    end
  end,
})

-- ── Track Recent Folders ──────────────────────────────────────
-- Automatically record the startup directory and any subsequent directory changes
local function record_folder(path)
  if not path or path == "" then return end
  path = vim.fn.fnamemodify(path, ":p")
  
  -- Remove trailing slash/backslash (except for drive letters like C:\)
  if #path > 3 and (path:sub(-1) == "/" or path:sub(-1) == "\\") then
    path = path:sub(1, -2)
  end

  if vim.fn.isdirectory(path) == 1 then
    local history_file = vim.fn.stdpath("data") .. "/recent_folders.json"
    local folders = {}

    -- Load existing history
    local f = io.open(history_file, "r")
    if f then
      local content = f:read("*a")
      f:close()
      local ok, decoded = pcall(vim.json.decode, content)
      if ok and type(decoded) == "table" then
        folders = decoded
      end
    end

    -- Remove duplicate if it already exists
    for i, val in ipairs(folders) do
      if val == path then
        table.remove(folders, i)
        break
      end
    end
    table.insert(folders, 1, path)

    -- Keep only the top 20 folders
    while #folders > 20 do
      table.remove(folders)
    end

    -- Save back to file
    local wf = io.open(history_file, "w")
    if wf then
      wf:write(vim.json.encode(folders))
      wf:close()
    end
  end
end

-- Record current directory on startup
record_folder(vim.fn.getcwd())

-- Record directory changes
augroup("TrackRecentFolders", { clear = true })
autocmd("DirChanged", {
  group = "TrackRecentFolders",
  callback = function(event)
    local raw_path = event.file
    if not raw_path or raw_path == "" then
      raw_path = vim.v.event.cwd
    end
    record_folder(raw_path)
  end,
})
