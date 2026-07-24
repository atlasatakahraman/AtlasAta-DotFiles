-- ┌──────────────────────────────────────────┐
-- │          Telescope Fuzzy Finder          │
-- │   File finder, grep, buffers, commands   │
-- │   Ctrl+Space = find files (normal mode)  │
-- └──────────────────────────────────────────┘

return {
  "nvim-telescope/telescope.nvim",
  -- Upgraded from "0.1.x" → master to fix the ft_to_lang nil crash:
  -- Telescope 0.1.x calls the deprecated vim.treesitter.language.ft_to_lang()
  -- which returns nil on Nvim 0.11+/0.12+ for filetypes without a parser,
  -- causing: "attempt to call field 'ft_to_lang' (a nil value)" in previewer.
  branch = "master",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- Native FZF sorter for much faster performance
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      -- Windows: use cmake (make is not available). Linux/Mac: prefers make, fallback to cmake.
      build = vim.fn.has("win32") == 1
        and "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
        or  "make",
      cond = function()
        return vim.fn.executable("cmake") == 1 or vim.fn.executable("make") == 1
      end,
    },
    "nvim-tree/nvim-web-devicons",
  },

  keys = {
    -- ── File Finding ──────────────────────────────────────────────
    -- <C-Space> in NORMAL mode: no conflict with blink.cmp which uses it in INSERT mode.
    { "<C-Space>",      "<cmd>Telescope find_files<cr>",   desc = "Find files",          mode = "n" },
    { "<leader>ff",     "<cmd>Telescope find_files<cr>",   desc = "Find files" },
    { "<leader>fh",     "<cmd>Telescope find_files hidden=true<cr>", desc = "Find files (hidden)" },
    { "<leader>fg",     "<cmd>Telescope git_files<cr>",    desc = "Find git files" },

    -- ── Search / Grep ─────────────────────────────────────────
    { "<leader>fr",      "<cmd>Telescope live_grep<cr>",    desc = "Live grep (all files)" },
    { "<leader>fw",      "<cmd>Telescope grep_string<cr>",  desc = "Grep word under cursor" },

    -- ── Buffers & Recent ──────────────────────────────────────
    { "<leader>fb",      "<cmd>Telescope buffers<cr>",      desc = "Find buffers" },
    { "<leader>fo",      "<cmd>Telescope oldfiles<cr>",     desc = "Recent files" },

    -- ── Command Palette ───────────────────────────────────────
    -- Map Ctrl+Shift+Space to Telescope Command Palette
    { "<C-S-Space>",     "<cmd>Telescope commands<cr>",     desc = "Command palette" },
    { "<leader>fc",      "<cmd>Telescope commands<cr>",     desc = "Commands" },

    -- ── LSP Integration ───────────────────────────────────────
    { "<leader>fs",      "<cmd>Telescope lsp_document_symbols<cr>",    desc = "Document symbols" },
    { "<leader>fS",      "<cmd>Telescope lsp_workspace_symbols<cr>",   desc = "Workspace symbols" },
    { "<leader>fd",      "<cmd>Telescope diagnostics<cr>",             desc = "Diagnostics" },

    -- ── Miscellaneous ─────────────────────────────────────────
    { "<leader>fk",      "<cmd>Telescope keymaps<cr>",      desc = "Keymaps" },
    { "<leader>f?",      "<cmd>Telescope help_tags<cr>",    desc = "Help tags" },
    { "<leader>ft",      "<cmd>Telescope colorscheme<cr>",  desc = "Color schemes" },
  },

  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    -- ── Custom File Opener to bypass Windows path escaping bugs ──
    local custom_open = function(prompt_bufnr, open_cmd)
      local action_state = require("telescope.actions.state")
      local selection = action_state.get_selected_entry()

      -- If no selection or it's not a file-based entry, delegate to default actions
      if not selection or (not selection.path and not selection.filename) then
        if open_cmd == "vsplit" then
          actions.select_vertical(prompt_bufnr)
        elseif open_cmd == "split" then
          actions.select_horizontal(prompt_bufnr)
        else
          actions.select_default(prompt_bufnr)
        end
        return
      end

      -- Close prompt before switching buffers
      actions.close(prompt_bufnr)

      local path = selection.path or selection.filename or selection[1]
      if not path then return end

      -- Get absolute path and normalize separators
      path = vim.fn.fnamemodify(path, ":p")
      local normalized = path:gsub("\\", "/")

      -- Split if requested
      if open_cmd == "vsplit" then
        vim.cmd("vsplit")
      elseif open_cmd == "split" then
        vim.cmd("split")
      end

      -- Load buffer directly to bypass Vim's ex-command command-line parsing
      local ok, err = pcall(function()
        local bufnr = vim.fn.bufadd(normalized)
        vim.fn.bufload(bufnr)
        vim.bo[bufnr].buflisted = true
        vim.api.nvim_set_current_buf(bufnr)
      end)

      if not ok then
        vim.notify("Telescope: could not open " .. path .. "\n" .. tostring(err), vim.log.levels.ERROR)
        return
      end

      -- Jump to line and column if available (e.g. from live_grep)
      local lnum = selection.lnum
      local col = selection.col or 1
      if lnum then
        pcall(vim.api.nvim_win_set_cursor, 0, { lnum, math.max(0, col - 1) })
        vim.cmd("normal! zz")
      end
    end

    telescope.setup({
      defaults = {
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",

        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },

        -- Ignore patterns
        file_ignore_patterns = {
          "%.git/",
          "node_modules/",
          "target/",
          "dist/",
          "build/",
          "%.o$",
          "%.a$",
          "%.out$",
          "%.class$",
          "%.pdf$",
          "%.mkv$",
          "%.mp4$",
          "%.zip$",
        },

        -- Key mappings inside Telescope
        mappings = {
          i = {
            ["<C-j>"]   = actions.move_selection_next,
            ["<C-k>"]   = actions.move_selection_previous,
            ["<C-n>"]   = actions.move_selection_next,
            ["<C-p>"]   = actions.move_selection_previous,
            ["<C-c>"]   = actions.close,
            ["<Esc>"]   = actions.close,
            ["<CR>"]    = function(prompt_bufnr) custom_open(prompt_bufnr, "edit") end,
            ["<C-v>"]   = function(prompt_bufnr) custom_open(prompt_bufnr, "vsplit") end,
            ["<C-x>"]   = function(prompt_bufnr) custom_open(prompt_bufnr, "split") end,
            ["<C-u>"]   = actions.preview_scrolling_up,
            ["<C-d>"]   = actions.preview_scrolling_down,
            ["<Tab>"]   = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
          },
          n = {
            ["q"]       = actions.close,
            ["<Esc>"]   = actions.close,
            ["j"]       = actions.move_selection_next,
            ["k"]       = actions.move_selection_previous,
            ["<CR>"]    = function(prompt_bufnr) custom_open(prompt_bufnr, "edit") end,
            ["<C-v>"]   = function(prompt_bufnr) custom_open(prompt_bufnr, "vsplit") end,
            ["<C-x>"]   = function(prompt_bufnr) custom_open(prompt_bufnr, "split") end,
          },
        },
      },

      pickers = {
        find_files = {
          hidden = false,
          previewer = false,
          layout_config = {
            width = 0.6,
            height = 0.5,
          },
        },
        buffers = {
          previewer = false,
          layout_config = {
            width = 0.6,
            height = 0.5,
          },
        },
      },
    })

    -- Load FZF native extension if available
    pcall(telescope.load_extension, "fzf")
  end,
}
