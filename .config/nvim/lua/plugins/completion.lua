-- ┌──────────────────────────────────────────┐
-- │       blink.cmp Autocompletion           │
-- │   Blazingly fast Rust-based completion   │
-- │   Tab/↑↓/Enter to navigate & accept     │
-- └──────────────────────────────────────────┘

return {
  "saghen/blink.cmp",
  version = "1.*",       -- Pin to v1.x for stability
  event = "InsertEnter", -- Lazy load on insert

  dependencies = {
    "rafamadriz/friendly-snippets", -- Community snippet collection
  },

  opts = {
    -- ── Keymaps ─────────────────────────────────────────────
    keymap = {
      preset = "none", -- Custom keymap (not using presets)

      -- Tab / Shift+Tab to navigate completion list
      -- NOTE: snippet_forward removed — it calls vim.snippet.jump()
      -- which internally calls treesitter node:range() and errors when
      -- the buffer has no treesitter parser for the current filetype.
      ["<Tab>"]   = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },

      -- Arrow keys: navigate the completion menu (intuitive / discoverable)
      ["<Down>"] = { "select_next", "fallback" },
      ["<Up>"]   = { "select_prev", "fallback" },

      -- Enter to confirm selection
      ["<CR>"] = { "accept", "fallback" },

      -- Ctrl+Space to trigger completion manually
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },

      -- Ctrl+E to dismiss completion
      ["<C-e>"] = { "cancel", "fallback" },

      -- Ctrl+J / Ctrl+K to navigate (alternative to Tab/arrows)
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },

      -- Ctrl+D / Ctrl+U to scroll documentation panel
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      ["<C-u>"] = { "scroll_documentation_up", "fallback" },
    },

    -- ── Snippets ────────────────────────────────────────────
    -- Wrap vim.snippet.jump in pcall to suppress the treesitter nil-node
    -- error: "attempt to call method 'range' (a nil value)" — this happens
    -- when the buffer has no treesitter parser and blink tries to navigate
    -- snippet placeholders via vim.snippet which calls treesitter internally.
    snippets = {
      expand = function(snippet)
        vim.snippet.expand(snippet)
      end,
      active = function(filter)
        return vim.snippet.active(filter)
      end,
      jump = function(direction)
        -- Suppress treesitter errors on buffers without a parser
        local ok, err = pcall(vim.snippet.jump, direction)
        if not ok then
          local err_str = tostring(err or "")
          if not err_str:find("range") then
            vim.notify("Snippet jump error: " .. err_str, vim.log.levels.WARN)
          end
        end
      end,
    },

    -- ── Appearance ──────────────────────────────────────────
    appearance = {
      nerd_font_variant = "mono",
      kind_icons = {
        Text          = "",
        Method        = "󰆧",
        Function      = "󰊕",
        Constructor   = "",
        Field         = "󰇽",
        Variable      = "󰂡",
        Class         = "󰠱",
        Interface     = "",
        Module        = "",
        Property      = "󰜢",
        Unit          = "",
        Value         = "󰎠",
        Enum          = "",
        Keyword       = "󰌋",
        Snippet       = "",
        Color         = "󰏘",
        File          = "󰈙",
        Reference     = "",
        Folder        = "󰉋",
        EnumMember    = "",
        Constant      = "󰏿",
        Struct        = "",
        Event         = "",
        Operator      = "󰆕",
        TypeParameter = "󰅲",
      },
    },

    -- ── Sources ─────────────────────────────────────────────
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    -- ── Completion Behavior ─────────────────────────────────
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = { border = "rounded" },
      },
      ghost_text = {
        enabled = true,
      },
      menu = {
        border = "rounded",
        draw = {
          columns = {
            { "kind_icon" },
            { "label", "label_description", gap = 1 },
            { "source_name" },
          },
        },
      },
      list = {
        selection = {
          preselect = false,
          auto_insert = true,
        },
      },
    },

    -- ── Signature Help ──────────────────────────────────────
    signature = {
      enabled = true,
      window = { border = "rounded" },
    },
  },
}
