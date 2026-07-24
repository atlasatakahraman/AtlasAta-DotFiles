-- ┌──────────────────────────────────────────┐
-- │     LSP Configuration (Mason + Native)   │
-- │   Uses Neovim 0.11+ native LSP API       │
-- │   Mason auto-installs LSP servers        │
-- └──────────────────────────────────────────┘

return {
  {
    -- Mason: LSP/DAP/Linter/Formatter installer
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  {
    -- Mason-lspconfig: Bridge between Mason and lspconfig
    -- v2.0+ uses vim.lsp.config() / vim.lsp.enable() API
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    event = { "BufReadPre", "BufNewFile" },

    config = function()
      -- ── Mason-lspconfig Setup ─────────────────────────────
      require("mason-lspconfig").setup({
        -- Auto-install these LSP servers
        ensure_installed = {
          "ts_ls",          -- TypeScript/JavaScript
          "rust_analyzer",  -- Rust
          "html",           -- HTML
          "cssls",          -- CSS
          "tailwindcss",    -- TailwindCSS
          "jsonls",         -- JSON
          "lua_ls",         -- Lua (for Neovim config editing)
          "pyright",        -- Python
          "clangd",         -- C/C++
          "marksman",       -- Markdown
          "taplo",          -- TOML
          "yamlls",         -- YAML
          "bashls",         -- Bash/Shell
        },
        -- Automatically enable installed servers
        automatic_enable = true,
      })

      -- ── Server-Specific Configurations ────────────────────
      -- Using Neovim 0.11+ native vim.lsp.config() API

      -- Lua LSP: Configure for Neovim Lua development
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = {
              globals = { "vim" }, -- Recognize 'vim' global
            },
            workspace = {
              -- PERF: Use ${3rd} library detection instead of eagerly scanning
              -- ALL runtime files. nvim_get_runtime_file("", true) at parse time
              -- adds ~200-400ms to startup. This lazy approach lets lua_ls
              -- discover libraries on-demand.
              library = { vim.env.VIMRUNTIME },
              checkThirdParty = false,
            },
            telemetry = { enable = false },
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      })

      -- TypeScript/JavaScript
      vim.lsp.config("ts_ls", {
        settings = {
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
          javascript = {
            updateImportsOnFileMove = { enabled = "always" },
          },
        },
      })

      -- JSON LSP: Schema support
      vim.lsp.config("jsonls", {
        settings = {
          json = {
            validate = { enable = true },
          },
        },
      })

      -- YAML LSP
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            keyOrdering = false, -- Don't enforce key ordering
          },
        },
      })

      -- Rust Analyzer
      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy", -- Use clippy for better lints
            },
            cargo = {
              allFeatures = true,
            },
          },
        },
      })

      -- NOTE: Do NOT call vim.lsp.enable() here — mason-lspconfig's
      -- automatic_enable = true already enables all installed servers.
      -- Calling both causes duplicate LSP client attachments.

      -- ── LspAttach: Set keymaps when LSP connects ──────────
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(event)
          -- Load LSP keymaps from keymaps/lsp.lua
          require("keymaps.lsp").setup(event.buf)
        end,
      })

      -- ── Diagnostic Configuration ──────────────────────────
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          spacing = 4,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = "󰌵 ",
            [vim.diagnostic.severity.INFO]  = "󰋽 ",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = true,
        },
      })


    end,
  },
}
