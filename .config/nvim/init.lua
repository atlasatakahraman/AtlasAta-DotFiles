-- ╔══════════════════════════════════════════════════════════════╗
-- ║                    Atlas Neovim Config                      ║
-- ║          Optimized for Neovide + Turkish-Q Keyboard         ║
-- ║         Windows 10 (primary) & Arch Linux compatible        ║
-- ╚══════════════════════════════════════════════════════════════╝

-- Set leader key BEFORE loading any plugins (required by lazy.nvim)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw BEFORE plugins load (neo-tree requires this to be set early)
-- Without this, netrw intercepts directory opens and conflicts with neo-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Load core modules (options, neovide, autocmds)
require("core")

-- Load keymaps (general, navigation, editing, lsp, plugins)
require("keymaps")

-- Load lazy.nvim bootstrap and all plugin specs
require("core.lazy")
