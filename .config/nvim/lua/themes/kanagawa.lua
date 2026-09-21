-- ┌──────────────────────────────────────────┐
-- │         Kanagawa Color Scheme            │
-- │   Default: dragon (warm, low-contrast)   │
-- │   Flavors: wave (blue), lotus (light)    │
-- └──────────────────────────────────────────┘

return {
  "rebelot/kanagawa.nvim",
  lazy = false,    -- main colorscheme: must load at startup
  priority = 1000, -- before every other start plugin

  opts = {
    -- compile = false on purpose: the cache does not invalidate when the
    -- overrides below change, so editing this file would silently do nothing
    -- until you remembered :KanagawaCompile. Costs a few ms at startup.
    compile = false,
    undercurl = true,
    commentStyle = { italic = true },
    keywordStyle = { italic = true },
    functionStyle = {},
    statementStyle = { bold = true },
    typeStyle = {},

    transparent = false,
    dimInactive = true,    -- dim windows that aren't focused
    terminalColors = true,

    background = {
      dark = "dragon",     -- warm ink-on-paper
      light = "lotus",
    },

    -- ── Palette overrides ───────────────────────────────────────
    overrides = function(colors)
      local theme = colors.theme
      local palette = colors.palette

      return {
        -- Floats read as one surface: no seam between body and border
        NormalFloat = { bg = theme.ui.bg_m3 },
        FloatBorder = { bg = theme.ui.bg_m3, fg = theme.ui.bg_m3 },
        FloatTitle = { bg = theme.ui.bg_m3, fg = theme.ui.special, bold = true },

        -- ── Neo-tree ────────────────────────────────────────────────
        -- The sidebar sits one surface BELOW the editor, so the split reads as
        -- depth rather than as a line.
        NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
        NeoTreeNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
        NeoTreeNormalNC = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
        NeoTreeWinSeparator = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },
        NeoTreeEndOfBuffer = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },

        -- THE ACTIVE FILE. A solid accent bar, not the default washed-out grey:
        -- filled background, warm gold text, bold. Impossible to lose.
        NeoTreeCursorLine = { bg = theme.ui.bg_p2, bold = true },
        NeoTreeFileNameOpened = { fg = palette.dragonYellow, bold = true },
        NeoTreeTitleBar = { fg = theme.ui.bg_m3, bg = palette.dragonBlue2, bold = true },

        -- Root and structure
        NeoTreeRootName = { fg = palette.dragonYellow, bold = true },
        NeoTreeDirectoryName = { fg = palette.dragonBlue2 },
        NeoTreeDirectoryIcon = { fg = palette.dragonBlue2 },
        NeoTreeFileName = { fg = theme.ui.fg_dim },
        NeoTreeIndentMarker = { fg = theme.ui.bg_p1 },
        NeoTreeExpander = { fg = theme.ui.bg_p2 },
        NeoTreeDotfile = { fg = theme.ui.nontext },
        NeoTreeModified = { fg = palette.dragonOrange },

        -- Git state in the sidebar, same language as the gutter
        NeoTreeGitAdded = { fg = palette.dragonGreen },
        NeoTreeGitModified = { fg = palette.dragonYellow },
        NeoTreeGitDeleted = { fg = palette.dragonRed },
        NeoTreeGitUntracked = { fg = palette.dragonPink },
        NeoTreeGitIgnored = { fg = theme.ui.nontext },
        NeoTreeGitConflict = { fg = palette.dragonRed, bold = true },

        -- Source-selector tabs across the top of the sidebar
        NeoTreeTabActive = { fg = palette.dragonYellow, bg = theme.ui.bg_p1, bold = true },
        NeoTreeTabInactive = { fg = theme.ui.nontext, bg = theme.ui.bg_m3 },
        NeoTreeTabSeparatorActive = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
        NeoTreeTabSeparatorInactive = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },

        -- ── Bufferline: the active buffer gets the same accent treatment ──
        BufferLineFill = { bg = theme.ui.bg_m3 },
        BufferLineBufferSelected = { fg = palette.dragonYellow, bg = theme.ui.bg, bold = true, italic = false },
        BufferLineNumbersSelected = { fg = palette.dragonYellow, bg = theme.ui.bg, bold = true, italic = false },
        BufferLineIndicatorSelected = { fg = palette.dragonYellow, bg = theme.ui.bg },
        BufferLineModifiedSelected = { fg = palette.dragonOrange, bg = theme.ui.bg },
        BufferLineBackground = { fg = theme.ui.nontext, bg = theme.ui.bg_m3 },
        BufferLineNumbers = { fg = theme.ui.nontext, bg = theme.ui.bg_m3 },
        BufferLineSeparator = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },
        BufferLineSeparatorSelected = { fg = theme.ui.bg_m3, bg = theme.ui.bg },
        BufferLineOffsetSeparator = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },

        TelescopeNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
        TelescopeBorder = { bg = theme.ui.bg_m3, fg = theme.ui.bg_m3 },
        TelescopeTitle = { fg = theme.ui.special, bold = true },
        TelescopePromptNormal = { bg = theme.ui.bg_p1 },
        TelescopePromptBorder = { bg = theme.ui.bg_p1, fg = theme.ui.bg_p1 },
        TelescopeResultsNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
        TelescopeResultsBorder = { bg = theme.ui.bg_m3, fg = theme.ui.bg_m3 },
        TelescopePreviewNormal = { bg = theme.ui.bg_dim },
        TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },

        -- Completion menu: selection is a block, not a colour shift
        Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
        PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
        PmenuSbar = { bg = theme.ui.bg_m1 },
        PmenuThumb = { bg = theme.ui.bg_p2 },

        -- Gutter shares the editor background so there is no seam beside the
        -- text; only the current line number is allowed to stand out.
        LineNr = { fg = theme.ui.bg_p2, bg = "NONE" },
        CursorLineNr = { fg = palette.dragonYellow, bg = "NONE", bold = true },
        SignColumn = { bg = "NONE" },
        FoldColumn = { bg = "NONE" },
        CursorLine = { bg = theme.ui.bg_p1 },

        -- Indent guides one step above the background, scope one above that
        IblIndent = { fg = theme.ui.bg_p1 },
        IblScope = { fg = theme.ui.bg_p2 },

        -- Winbar / tabline blend into the editor
        WinSeparator = { fg = theme.ui.bg_p1 },
      }
    end,
  },

  config = function(_, opts)
    require("kanagawa").setup(opts)
    vim.cmd.colorscheme("kanagawa-dragon")
  end,
}
