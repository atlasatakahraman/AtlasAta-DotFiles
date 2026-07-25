-- ┌──────────────────────────────────────────┐
-- │       Lazy.nvim Bootstrap & Setup        │
-- │   Auto-installs lazy.nvim on first run   │
-- │   Loads all plugin specs from plugins/   │
-- └──────────────────────────────────────────┘

-- Bootstrap lazy.nvim (auto-install if not present)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim with all plugin specs from lua/plugins/
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },

  -- Performance: don't auto-check for updates on startup
  checker = {
    enabled = false,    -- Manual updates with :Lazy update
  },

  -- Don't notify on config file changes
  change_detection = {
    notify = false,
  },

  -- Colorscheme used during plugin install
  install = {
    colorscheme = { "catppuccin", "habamax" },
  },

  -- Performance optimizations
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        -- Additional disabled plugins for faster startup
        "2html_plugin",
        "getscript",
        "getscriptPlugin",
        "logipat",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
      },
    },
  },

  -- UI settings for lazy.nvim window
  ui = {
    border = "rounded",
    icons = {
      cmd = " ",
      config = "",
      event = " ",
      ft = " ",
      init = " ",
      import = " ",
      keys = " ",
      lazy = "󰒲 ",
      loaded = "●",
      not_loaded = "○",
      plugin = " ",
      runtime = " ",
      require = "󰢱 ",
      source = " ",
      start = " ",
      task = "✔ ",
      list = {
        "●",
        "➜",
        "★",
        "‒",
      },
    },
  },
})
