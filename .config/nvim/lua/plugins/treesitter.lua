-- ┌──────────────────────────────────────────┐
-- │        Treesitter Syntax Highlighting    │
-- │   Parser-based highlighting & indent     │
-- │   Auto-installs parsers for all langs    │
-- └──────────────────────────────────────────┘

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,  -- plugin docs explicitly warn: does NOT support lazy-loading

  config = function()
    -- Main-branch nvim-treesitter uses require("nvim-treesitter").setup()
    -- which only accepts `ensure_installed`, `sync_install`, `auto_install`,
    -- and `ignore_install`. Highlight/indent/incremental_selection are
    -- configured separately via vim.treesitter APIs.
    require("nvim-treesitter").setup({
      -- All the languages you'll work with
      ensure_installed = {
        -- Web development
        "typescript", "tsx", "javascript",
        "html", "css", "scss",
        "json", "jsonc",

        -- Systems programming
        "rust", "c", "cpp",

        -- Scripting
        "python", "lua", "bash",

        -- Config files
        "yaml", "toml", "xml",
        "dockerfile", "gitignore", "gitcommit",

        -- Documentation
        "markdown", "markdown_inline",

        -- Vim/Neovim
        "vim", "vimdoc", "query", "luadoc",

        -- Other useful ones
        "regex", "sql", "graphql",
        "diff", "ini", "properties",
      },

      -- Don't block startup with parser install
      sync_install = false,

      -- Auto-install parsers for any filetype you open
      auto_install = true,
    })

    -- ── Treesitter Highlight ──────────────────────────────────
    -- Use an autocmd to enable treesitter highlighting for every buffer,
    -- with a guard for large files and non-code filetypes.
    local ts_disabled_ft = {
      "dashboard", "neo-tree", "lazy", "mason", "notify", "toggleterm",
      "help", "man", "qf", "lspinfo", "checkhealth", "startuptime",
      "TelescopePrompt", "trouble", "alpha", "",
    }

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true }),
      callback = function(event)
        local buf = event.buf
        local ft = event.match

        -- Skip UI/special filetypes that have no treesitter parser
        if vim.tbl_contains(ts_disabled_ft, ft) then
          return
        end

        -- Disable for very large files (performance)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return  -- Skip treesitter for oversized files
        end

        -- Only start if a parser exists for this filetype.
        -- Wrap in pcall as a final safety net — vim.treesitter.start() can
        -- assert if the parser binary doesn't exist even though add() succeeded.
        local lang = vim.treesitter.language.get_lang(ft)
        if lang and pcall(vim.treesitter.language.add, lang) then
          pcall(vim.treesitter.start, buf, lang)
        end
      end,
    })

    -- ── Incremental Selection ────────────────────────────────
    -- Note: Main-branch treesitter doesn't support incremental_selection
    -- via opts. Using textobjects or manual visual selection instead.
    -- The keymaps <leader>vs / <Tab> / <BS> are handled below:
    vim.keymap.set("n", "<leader>vs", function()
      -- Start treesitter incremental selection
      require("nvim-treesitter.incremental_selection").init_selection()
    end, { desc = "Start treesitter selection" })

    vim.keymap.set("x", "<Tab>", function()
      require("nvim-treesitter.incremental_selection").node_incremental()
    end, { desc = "Expand selection (treesitter)" })

    vim.keymap.set("x", "<BS>", function()
      require("nvim-treesitter.incremental_selection").node_decremental()
    end, { desc = "Shrink selection (treesitter)" })
  end,
}
