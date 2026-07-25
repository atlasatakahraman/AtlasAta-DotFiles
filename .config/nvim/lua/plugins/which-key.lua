-- ┌──────────────────────────────────────────┐
-- │          which-key.nvim v3               │
-- │   Shows keybind popup after prefix key   │
-- │   Essential for learning the config      │
-- └──────────────────────────────────────────┘

return {
  "folke/which-key.nvim",
  event = "VeryLazy",

  opts = {
    preset = "modern",    -- Modern floating style

    delay = function(ctx)
      return ctx.plugin and 0 or 300
    end,

    -- Register all leader key groups with labels
    spec = {
      { "<leader>b",  group = "Buffer",       icon = "󰈚" },
      { "<leader>c",  group = "Code",         icon = "" },
      { "<leader>d",  group = "Delete/Debug", icon = "" },
      { "<leader>f",  group = "Find",         icon = "" },
      { "<leader>g",  group = "Git",          icon = "󰊢" },
      { "<leader>l",  group = "LSP/Lazy",     icon = "" },
      { "<leader>o",  group = "Add line",     icon = "" },
      { "<leader>r",  group = "Rename",       icon = "󰑕" },
      { "<leader>s",  group = "Split/Select", icon = "" },
      { "<leader>t",  group = "Toggle/Tab",   icon = "" },
      { "<leader>w",  desc = "Focus terminal" },
      { "<leader>W",  group = "Workspace",    icon = "" },
      { "<leader>x",  group = "Trouble",      icon = "󰔫" },
    },

    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+ ",
      mappings = true,  -- Auto icons for keymaps
    },

    win = {
      border = "rounded",
      padding = { 1, 2 },
    },
  },

  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Buffer-local keymaps",
    },
    {
      "<leader><leader>",
      function() require("which-key").show({ global = true }) end,
      desc = "Show all keymaps",
    },
  },
}
