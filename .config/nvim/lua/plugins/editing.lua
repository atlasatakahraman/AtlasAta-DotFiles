-- ┌──────────────────────────────────────────┐
-- │         Editing Enhancements             │
-- │   autopairs, surround, Comment           │
-- └──────────────────────────────────────────┘

return {
  -- ═══════════════════════════════════════════
  -- ║ nvim-autopairs — Auto-close brackets    ║
  -- ═══════════════════════════════════════════
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",

    opts = {
      check_ts = true,                 -- Use treesitter for smart pairing
      ts_config = {
        lua = { "string", "source" },  -- Don't add pairs in lua string treesitter nodes
        javascript = { "string", "template_string" },
        typescript = { "string", "template_string" },
      },
      disable_filetype = { "TelescopePrompt" },
      fast_wrap = {
        map = "<M-e>",                 -- Alt+E to wrap with bracket
        chars = { "{", "[", "(", '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = "$",
        before_key = "h",
        after_key = "l",
        cursor_pos_before = true,
        keys = "qwertyuiopasdfghjklzxcvbnm",
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },
    },
  },

  -- ═══════════════════════════════════════════
  -- ║ nvim-surround — Add/change/delete       ║
  -- ║ surrounding characters                   ║
  -- ═══════════════════════════════════════════
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",

    -- Default keymaps:
    --   ys{motion}{char}  → Add surround (e.g., ysiw" surrounds word with quotes)
    --   ds{char}          → Delete surround (e.g., ds" deletes surrounding quotes)
    --   cs{old}{new}      → Change surround (e.g., cs"' changes " to ')
    --   S{char}           → Surround selection in Visual mode
    opts = {},
  },

  -- ═══════════════════════════════════════════
  -- ║ Comment.nvim — Toggle comments           ║
  -- ║ Ctrl+/ for VSCode-style commenting       ║
  -- ═══════════════════════════════════════════
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },

    config = function()
      require("Comment").setup({
        -- Standard keymaps:
        --   gcc → Toggle comment (line)
        --   gc  → Toggle comment (visual selection)
        --   gbc → Toggle block comment
        toggler = {
          line = "gcc",
          block = "gbc",
        },
        opleader = {
          line = "gc",
          block = "gb",
        },
      })

      -- VSCode-style Ctrl+/ (and Ctrl+_) to toggle comment (normal, visual, insert)
      local map = vim.keymap.set
      map("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment" })
      map("v", "<C-/>", "gc",  { remap = true, desc = "Toggle comment" })
      map("i", "<C-/>", "<Esc>gccgi", { remap = true, desc = "Toggle comment" })

      map("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment" })
      map("v", "<C-_>", "gc",  { remap = true, desc = "Toggle comment" })
      map("i", "<C-_>", "<Esc>gccgi", { remap = true, desc = "Toggle comment" })
    end,
  },
}
