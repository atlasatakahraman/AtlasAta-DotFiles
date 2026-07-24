-- ┌──────────────────────────────────────────┐
-- │         Extra Plugins                    │
-- │   todo-comments, colorizer, trouble      │
-- └──────────────────────────────────────────┘

return {
  -- ═══════════════════════════════════════════
  -- ║ todo-comments — Highlight TODO/FIXME    ║
  -- ═══════════════════════════════════════════
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },

    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Previous TODO" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>",                      desc = "TODO list (Trouble)" },
      { "<leader>ft", "<cmd>TodoTelescope<cr>",                            desc = "Find TODOs" },
    },

    opts = {
      signs = true,
      -- Keywords and their colors
      keywords = {
        FIX  = { icon = " ", color = "error",   alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = "󰅒 ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = "󰍨 ", color = "hint",    alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test",    alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
  },

  -- ═══════════════════════════════════════════
  -- ║ nvim-colorizer — CSS color previews     ║
  -- ═══════════════════════════════════════════
  {
    -- NvChad/nvim-colorizer.lua is unmaintained; catgoose is the active fork
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },

    opts = {
      filetypes = {
        "*",           -- Enable for all filetypes
        css = { css = true },
        scss = { css = true },
        html = { css = true },
        javascript = { css = true },
        typescript = { css = true },
      },
      user_default_options = {
        RGB = true,          -- #RGB hex codes
        RRGGBB = true,       -- #RRGGBB hex codes
        names = false,        -- Don't colorize "Blue", "Red" etc.
        RRGGBBAA = true,     -- #RRGGBBAA hex codes
        rgb_fn = true,       -- CSS rgb() and rgba()
        hsl_fn = true,       -- CSS hsl() and hsla()
        css = false,          -- Enable all CSS features
        css_fn = true,       -- CSS functions like rgb()
        mode = "background",  -- Set the display mode: "background" | "foreground" | "virtualtext"
        tailwind = true,     -- Enable tailwind colors
        virtualtext = "■",
        always_update = false,
      },
    },
  },

  -- ═══════════════════════════════════════════
  -- ║ trouble.nvim — Diagnostics panel        ║
  -- ═══════════════════════════════════════════
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (all)" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location list" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix list" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",      desc = "Symbols" },
    },

    opts = {
      auto_close = false,
      auto_open = false,
      auto_preview = true,
      auto_refresh = true,
      focus = false,
      restore = true,
      use_diagnostic_signs = true,
    },
  },
}
