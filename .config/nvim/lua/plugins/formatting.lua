-- ┌──────────────────────────────────────────┐
-- │        conform.nvim Formatting           │
-- │   Format-on-save with fallback to LSP    │
-- │   Ctrl+Shift+F for manual format         │
-- └──────────────────────────────────────────┘

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },

  opts = {
    -- Formatters by filetype
    formatters_by_ft = {
      -- Web: Prettier via prettierd (faster daemon)
      javascript      = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescript      = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      html            = { "prettierd", "prettier", stop_after_first = true },
      css             = { "prettierd", "prettier", stop_after_first = true },
      scss            = { "prettierd", "prettier", stop_after_first = true },
      json            = { "prettierd", "prettier", stop_after_first = true },
      jsonc           = { "prettierd", "prettier", stop_after_first = true },
      yaml            = { "prettierd", "prettier", stop_after_first = true },
      markdown        = { "prettierd", "prettier", stop_after_first = true },
      graphql         = { "prettierd", "prettier", stop_after_first = true },

      -- Rust
      rust = { "rustfmt" },

      -- Lua
      lua = { "stylua" },

      -- Python
      python = { "ruff_format", "black", stop_after_first = true },

      -- C/C++
      c   = { "clang_format" },
      cpp = { "clang_format" },

      -- Shell
      sh   = { "shfmt" },
      bash = { "shfmt" },

      -- TOML
      toml = { "taplo" },

      -- Fallback: use LSP formatting for any other filetype
      ["_"] = { "trim_whitespace" },
    },

    -- Format on save
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",  -- Use LSP if no formatter is configured
    },
  },
}
