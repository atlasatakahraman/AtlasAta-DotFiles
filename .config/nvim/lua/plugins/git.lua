-- ┌──────────────────────────────────────────┐
-- │          Gitsigns                        │
-- │   Git change indicators in the gutter    │
-- │   Inline blame, hunk preview/stage       │
-- └──────────────────────────────────────────┘

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufNewFile" },

  opts = {
    signs = {
      add          = { text = "▎" },
      change       = { text = "▎" },
      delete       = { text = "▁" },
      topdelete    = { text = "▔" },
      changedelete = { text = "▎" },
      untracked    = { text = "▎" },
    },

    signs_staged = {
      add          = { text = "▎" },
      change       = { text = "▎" },
      delete       = { text = "▁" },
      topdelete    = { text = "▔" },
      changedelete = { text = "▎" },
    },

    -- Current line blame (toggle with Leader+gb)
    current_line_blame = false,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 500,
    },

    -- Preview settings
    preview_config = {
      border = "rounded",
      style = "minimal",
    },

    -- Keymaps
    on_attach = function(bufnr)
      -- Safely require gitsigns instead of package.loaded (which can be nil
      -- if the module registered under a different key)
      local ok, gs = pcall(require, "gitsigns")
      if not ok then return end

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = "Git: " .. desc })
      end

      -- Navigation between hunks
      map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
      map("n", "[h", function() gs.nav_hunk("prev") end, "Previous hunk")

      -- Actions
      map("n", "<leader>gs", gs.stage_hunk,                "Stage hunk")
      map("n", "<leader>gr", gs.reset_hunk,                "Reset hunk")
      map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
      map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
      map("n", "<leader>gS", gs.stage_buffer,              "Stage buffer")
      map("n", "<leader>gR", gs.reset_buffer,              "Reset buffer")
      map("n", "<leader>gu", gs.stage_hunk,              "Undo/toggle stage hunk (v2: stage_hunk handles unstage)")
      map("n", "<leader>gp", gs.preview_hunk,              "Preview hunk")
      map("n", "<leader>gb", gs.toggle_current_line_blame, "Toggle line blame")
      map("n", "<leader>gd", gs.diffthis,                  "Diff this")
    end,
  },
}
