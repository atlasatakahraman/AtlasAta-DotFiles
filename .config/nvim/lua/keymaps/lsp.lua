-- ┌──────────────────────────────────────────┐
-- │          LSP Keybinds                    │
-- │   Loaded via LspAttach autocmd           │
-- │   Only active when a language server     │
-- │   is attached to the current buffer      │
-- └──────────────────────────────────────────┘

local M = {}

--- Setup LSP keymaps for the given buffer
--- Called from plugins/lsp.lua when an LSP server attaches
---@param buf number Buffer number
function M.setup(buf)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = "LSP: " .. desc })
  end

  -- ── Go-To Commands ────────────────────────────────────────
  map("n", "gd", vim.lsp.buf.definition,                   "Go to definition")
  map("n", "gD", vim.lsp.buf.declaration,                  "Go to declaration")
  map("n", "gr", vim.lsp.buf.references,                   "Find references")
  map("n", "gi", vim.lsp.buf.implementation,               "Go to implementation")
  map("n", "go", vim.lsp.buf.type_definition,              "Go to type definition")

  -- ── Documentation ─────────────────────────────────────────
  map("n", "K",          vim.lsp.buf.hover,                "Hover documentation")
  map("n", "gs",         vim.lsp.buf.signature_help,       "Signature help")
  map("i", "<C-k>",      vim.lsp.buf.signature_help,       "Signature help (insert)")

  -- ── Diagnostics ───────────────────────────────────────────
  map("n", "<leader>k",  vim.diagnostic.open_float,        "Show diagnostics")
  map("n", "[d",         function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
  map("n", "]d",         function() vim.diagnostic.jump({ count = 1, float = true }) end,  "Next diagnostic")
  map("n", "<leader>dl", vim.diagnostic.setloclist,        "Diagnostics to location list")

  -- ── Code Actions ──────────────────────────────────────────
  map("n", "<leader>ca", vim.lsp.buf.code_action,          "Code actions")
  map("v", "<leader>ca", vim.lsp.buf.code_action,          "Code actions (selection)")
  map("n", "<F4>",       vim.lsp.buf.code_action,          "Code actions (F4)")

  -- ── Rename ────────────────────────────────────────────────
  map("n", "<leader>rn", vim.lsp.buf.rename,               "Rename symbol")
  map("n", "<F2>",       vim.lsp.buf.rename,               "Rename symbol (F2)")

  -- ── Workspace ─────────────────────────────────────────────
  map("n", "<leader>Wa", vim.lsp.buf.add_workspace_folder,    "Add workspace folder")
  map("n", "<leader>Wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
  map("n", "<leader>Wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "List workspace folders")
end

return M
