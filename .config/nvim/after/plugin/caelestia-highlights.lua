-- ┌──────────────────────────────────────────────────────────┐
-- │     Caelestia Extended Highlights                        │
-- │     Material Design 3 Semantic Token Mapping             │
-- │     Runs after caelestia-nvim loads & on theme reload    │
-- └──────────────────────────────────────────────────────────┘

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local set_hl = vim.api.nvim_set_hl

local function get_scheme_path()
  local xdg_state = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
  return xdg_state .. "/caelestia/scheme.json"
end

local function read_scheme()
  local path = get_scheme_path()
  local file = io.open(path, "r")
  if not file then
    return nil, nil
  end

  local content = file:read("*all")
  file:close()

  local ok, scheme = pcall(vim.json.decode, content)
  if not ok or not scheme or not scheme.colours then
    return nil, nil
  end

  local colors = {}
  for name, value in pairs(scheme.colours) do
    colors[name] = "#" .. value
  end

  return colors, scheme.mode
end

local function apply_extended_highlights()
  if vim.g.colors_name ~= "caelestia" then
    return
  end

  local c, mode = read_scheme()
  if not c then
    return
  end

  if mode == "light" or mode == "dark" then
    vim.o.background = mode
  end

  -- Semantic M3 Aliases for clear UI hierarchy
  local bg                = c.background or c.surface or "#141312"
  local fg                = c.onBackground or c.onSurface or "#e6e1df"
  local primary           = c.primary or "#d2c5b4"
  local on_primary        = c.onPrimary or "#372f23"
  local primary_container = c.primaryContainer or "#51483b"
  local secondary         = c.secondary or "#cdc5bd"
  local tertiary          = c.tertiary or "#c5c6cf"
  local tertiary_container= c.tertiaryContainer or "#474951"
  local outline           = c.outline or "#978f86"
  local outline_variant   = c.outlineVariant or "#4c463e"
  local surface_low       = c.surfaceContainerLow or "#1d1b1a"
  local surface_mid       = c.surfaceContainer or "#211f1e"
  local surface_high      = c.surfaceContainerHigh or "#2b2a28"
  local surface_highest   = c.surfaceContainerHighest or "#363433"
  local error_color       = c.error or "#ffb4ab"
  local success_color     = c.success or "#b5ccba"

  -- ══════════════════════════════════════════════════════════
  -- ║ EDITOR CORE                                            ║
  -- ══════════════════════════════════════════════════════════

  set_hl(0, "Normal",          { fg = fg, bg = bg })
  set_hl(0, "NormalFloat",     { fg = fg, bg = surface_mid })
  set_hl(0, "LineNr",          { fg = outline_variant })
  set_hl(0, "CursorLineNr",   { fg = primary, bold = true })
  set_hl(0, "SignColumn",      { fg = outline_variant, bg = "NONE" })
  set_hl(0, "VertSplit",       { fg = outline_variant })
  set_hl(0, "WinSeparator",    { fg = outline_variant })
  set_hl(0, "Folded",          { fg = outline, bg = surface_low })
  set_hl(0, "FoldColumn",      { fg = outline_variant })
  set_hl(0, "MatchParen",      { fg = primary, bg = surface_highest, bold = true })
  set_hl(0, "Search",          { fg = on_primary, bg = primary })
  set_hl(0, "IncSearch",       { fg = on_primary, bg = secondary })
  set_hl(0, "CurSearch",       { fg = on_primary, bg = primary, bold = true })
  set_hl(0, "Substitute",      { fg = bg, bg = error_color })
  set_hl(0, "NonText",         { fg = outline_variant })
  set_hl(0, "SpecialKey",      { fg = outline_variant })
  set_hl(0, "EndOfBuffer",     { fg = bg })
  set_hl(0, "ColorColumn",     { bg = surface_low })
  set_hl(0, "Conceal",         { fg = outline })
  set_hl(0, "Directory",       { fg = primary, bold = true })
  set_hl(0, "Title",           { fg = primary, bold = true })
  set_hl(0, "Question",        { fg = success_color })
  set_hl(0, "MoreMsg",         { fg = success_color })
  set_hl(0, "WarningMsg",      { fg = secondary })
  set_hl(0, "ErrorMsg",        { fg = error_color, bold = true })
  set_hl(0, "ModeMsg",         { fg = fg, bold = true })
  set_hl(0, "WildMenu",        { fg = on_primary, bg = primary })
  set_hl(0, "SpellBad",        { sp = error_color, undercurl = true })
  set_hl(0, "SpellCap",        { sp = secondary, undercurl = true })
  set_hl(0, "SpellLocal",      { sp = tertiary, undercurl = true })
  set_hl(0, "SpellRare",       { sp = success_color, undercurl = true })
  set_hl(0, "FloatBorder",     { fg = primary, bg = surface_mid })
  set_hl(0, "FloatTitle",      { fg = primary, bg = surface_mid, bold = true })
  set_hl(0, "WinBar",          { fg = secondary, bg = "NONE" })
  set_hl(0, "WinBarNC",        { fg = outline, bg = "NONE" })

  set_hl(0, "TabLine",         { fg = outline, bg = surface_low })
  set_hl(0, "TabLineFill",     { bg = bg })
  set_hl(0, "TabLineSel",      { fg = fg, bg = surface_mid, bold = true })

  -- ══════════════════════════════════════════════════════════
  -- ║ TERMINAL COLORS                                        ║
  -- ══════════════════════════════════════════════════════════

  -- Synced with caelestia-shell's term0–term15 for parity with external terminal
  vim.g.terminal_color_0  = c.term0  or "#353433"  -- black
  vim.g.terminal_color_1  = c.term1  or "#cc8000"  -- red
  vim.g.terminal_color_2  = c.term2  or "#fac442"  -- green
  vim.g.terminal_color_3  = c.term3  or "#ffe2b7"  -- yellow
  vim.g.terminal_color_4  = c.term4  or "#b6ac67"  -- blue
  vim.g.terminal_color_5  = c.term5  or "#e59a50"  -- magenta
  vim.g.terminal_color_6  = c.term6  or "#e4c76d"  -- cyan
  vim.g.terminal_color_7  = c.term7  or "#e7d6bf"  -- white
  vim.g.terminal_color_8  = c.term8  or "#aea18f"  -- bright black
  vim.g.terminal_color_9  = c.term9  or "#ec9500"  -- bright red
  vim.g.terminal_color_10 = c.term10 or "#ffd887"  -- bright green
  vim.g.terminal_color_11 = c.term11 or "#fff2e3"  -- bright yellow
  vim.g.terminal_color_12 = c.term12 or "#cdc193"  -- bright blue
  vim.g.terminal_color_13 = c.term13 or "#f3b270"  -- bright magenta
  vim.g.terminal_color_14 = c.term14 or "#fbd873"  -- bright cyan
  vim.g.terminal_color_15 = c.term15 or "#ffffff"  -- bright white

  -- ══════════════════════════════════════════════════════════
  -- ║ SYNTAX                                                 ║
  -- ══════════════════════════════════════════════════════════

  set_hl(0, "Comment",         { fg = outline, italic = true })
  set_hl(0, "Constant",        { fg = secondary })
  set_hl(0, "String",          { fg = c.term2 or success_color })
  set_hl(0, "Character",       { fg = c.term2 or success_color })
  set_hl(0, "Number",          { fg = secondary })
  set_hl(0, "Boolean",         { fg = secondary, bold = true })
  set_hl(0, "Float",           { fg = secondary })

  set_hl(0, "Identifier",      { fg = fg })
  set_hl(0, "Function",        { fg = primary, bold = true })
  set_hl(0, "Statement",       { fg = tertiary, bold = true })
  set_hl(0, "Conditional",     { fg = tertiary })
  set_hl(0, "Repeat",          { fg = tertiary })
  set_hl(0, "Label",           { fg = tertiary })
  set_hl(0, "Operator",        { fg = outline })
  set_hl(0, "Keyword",         { fg = tertiary, bold = true })
  set_hl(0, "Exception",       { fg = error_color })

  set_hl(0, "PreProc",         { fg = secondary })
  set_hl(0, "Include",         { fg = secondary })
  set_hl(0, "Define",          { fg = secondary })
  set_hl(0, "Macro",           { fg = secondary })
  set_hl(0, "PreCondit",       { fg = secondary })

  set_hl(0, "Type",            { fg = primary })
  set_hl(0, "StorageClass",    { fg = primary })
  set_hl(0, "Structure",       { fg = primary })
  set_hl(0, "Typedef",         { fg = primary })

  set_hl(0, "Special",         { fg = secondary })
  set_hl(0, "SpecialChar",     { fg = secondary })
  set_hl(0, "Tag",             { fg = primary })
  set_hl(0, "Delimiter",       { fg = outline })
  set_hl(0, "SpecialComment",  { fg = outline, italic = true })
  set_hl(0, "Debug",           { fg = error_color })
  set_hl(0, "Todo",            { fg = on_primary, bg = primary, bold = true })

  -- ══════════════════════════════════════════════════════════
  -- ║ DIAGNOSTICS                                            ║
  -- ══════════════════════════════════════════════════════════

  set_hl(0, "DiagnosticError",              { fg = error_color })
  set_hl(0, "DiagnosticWarn",               { fg = secondary })
  set_hl(0, "DiagnosticInfo",               { fg = tertiary })
  set_hl(0, "DiagnosticHint",               { fg = success_color })
  set_hl(0, "DiagnosticOk",                 { fg = success_color })
  set_hl(0, "DiagnosticUnderlineError",     { sp = error_color, undercurl = true })
  set_hl(0, "DiagnosticUnderlineWarn",      { sp = secondary, undercurl = true })
  set_hl(0, "DiagnosticUnderlineInfo",      { sp = tertiary, undercurl = true })
  set_hl(0, "DiagnosticUnderlineHint",      { sp = success_color, undercurl = true })

  -- ══════════════════════════════════════════════════════════
  -- ║ GIT / DIFF                                             ║
  -- ══════════════════════════════════════════════════════════

  set_hl(0, "DiffAdd",         { bg = surface_low, fg = success_color })
  set_hl(0, "DiffChange",      { bg = surface_low, fg = secondary })
  set_hl(0, "DiffDelete",      { bg = surface_low, fg = error_color })
  set_hl(0, "DiffText",        { bg = surface_high, fg = primary, bold = true })

  set_hl(0, "GitSignsAdd",              { fg = success_color })
  set_hl(0, "GitSignsChange",           { fg = secondary })
  set_hl(0, "GitSignsDelete",           { fg = error_color })

  -- ══════════════════════════════════════════════════════════
  -- ║ TREESITTER                                             ║
  -- ══════════════════════════════════════════════════════════

  set_hl(0, "@variable",             { fg = fg })
  set_hl(0, "@variable.builtin",     { fg = secondary, italic = true })
  set_hl(0, "@variable.parameter",   { fg = fg })
  set_hl(0, "@variable.member",      { fg = secondary })

  set_hl(0, "@constant",             { fg = secondary })
  set_hl(0, "@constant.builtin",     { fg = secondary, bold = true })
  set_hl(0, "@module",               { fg = primary, italic = true })
  set_hl(0, "@label",                { fg = tertiary })

  set_hl(0, "@string",              { fg = c.term2 or success_color })
  set_hl(0, "@string.escape",       { fg = secondary })
  set_hl(0, "@string.special",      { fg = secondary })

  set_hl(0, "@function",            { fg = primary, bold = true })
  set_hl(0, "@function.builtin",    { fg = primary })
  set_hl(0, "@function.method",     { fg = primary })
  set_hl(0, "@constructor",         { fg = primary })

  set_hl(0, "@keyword",             { fg = tertiary, bold = true })
  set_hl(0, "@keyword.import",      { fg = tertiary })
  set_hl(0, "@keyword.return",      { fg = tertiary })

  set_hl(0, "@type",                { fg = primary })
  set_hl(0, "@type.builtin",        { fg = primary, italic = true })
  set_hl(0, "@property",            { fg = secondary })
  set_hl(0, "@operator",            { fg = outline })
  set_hl(0, "@punctuation.bracket",   { fg = outline })
  set_hl(0, "@punctuation.delimiter", { fg = outline })

  -- ══════════════════════════════════════════════════════════
  -- ║ TELESCOPE                                              ║
  -- ══════════════════════════════════════════════════════════

  set_hl(0, "TelescopeNormal",          { fg = fg, bg = surface_mid })
  set_hl(0, "TelescopeBorder",          { fg = primary, bg = surface_mid })
  set_hl(0, "TelescopeTitle",           { fg = primary, bold = true })

  set_hl(0, "TelescopePromptNormal",    { fg = fg, bg = surface_high })
  set_hl(0, "TelescopePromptBorder",    { fg = primary, bg = surface_high })
  set_hl(0, "TelescopePromptTitle",     { fg = on_primary, bg = primary, bold = true })
  set_hl(0, "TelescopePromptPrefix",    { fg = primary, bg = surface_high })

  set_hl(0, "TelescopeResultsNormal",   { fg = fg, bg = surface_mid })
  set_hl(0, "TelescopeResultsBorder",   { fg = outline_variant, bg = surface_mid })
  set_hl(0, "TelescopeResultsTitle",    { fg = on_primary, bg = secondary, bold = true })

  set_hl(0, "TelescopePreviewNormal",   { fg = fg, bg = bg })
  set_hl(0, "TelescopePreviewBorder",   { fg = outline_variant, bg = bg })
  set_hl(0, "TelescopePreviewTitle",    { fg = on_primary, bg = tertiary, bold = true })

  set_hl(0, "TelescopeSelection",       { fg = fg, bg = surface_highest, bold = true })
  set_hl(0, "TelescopeSelectionCaret",  { fg = primary, bg = surface_highest })
  set_hl(0, "TelescopeMatching",        { fg = primary, bold = true })

  -- ══════════════════════════════════════════════════════════
  -- ║ NEO-TREE                                               ║
  -- ══════════════════════════════════════════════════════════

  set_hl(0, "NeoTreeNormal",           { fg = fg, bg = surface_low })
  set_hl(0, "NeoTreeNormalNC",         { fg = fg, bg = surface_low })
  set_hl(0, "NeoTreeWinSeparator",     { fg = bg, bg = bg })
  set_hl(0, "NeoTreeEndOfBuffer",      { fg = surface_low, bg = surface_low })
  set_hl(0, "NeoTreeFileName",         { fg = fg })
  set_hl(0, "NeoTreeDirectoryIcon",    { fg = primary })
  set_hl(0, "NeoTreeDirectoryName",    { fg = primary, bold = true })
  set_hl(0, "NeoTreeRootName",         { fg = primary, bold = true, italic = true })
  set_hl(0, "NeoTreeFileIcon",         { fg = primary })
  set_hl(0, "NeoTreeIndentMarker",     { fg = outline_variant })
  set_hl(0, "NeoTreeExpander",         { fg = outline })
  set_hl(0, "NeoTreeCursorLine",       { bg = surface_high })
  set_hl(0, "NeoTreeTitleBar",         { fg = on_primary, bg = primary, bold = true })

  set_hl(0, "NeoTreeGitAdded",         { fg = success_color })
  set_hl(0, "NeoTreeGitModified",      { fg = secondary })
  set_hl(0, "NeoTreeGitDeleted",       { fg = error_color })

  -- ══════════════════════════════════════════════════════════
  -- ║ NOICE / NOTIFY / DASHBOARD                             ║
  -- ══════════════════════════════════════════════════════════

  set_hl(0, "NoiceCmdline",              { fg = fg })
  set_hl(0, "NoiceCmdlinePopup",         { fg = fg, bg = surface_mid })
  set_hl(0, "NoiceCmdlinePopupBorder",   { fg = primary, bg = surface_mid })
  set_hl(0, "NoiceCmdlineIcon",          { fg = primary })

  set_hl(0, "DashboardHeader",    { fg = primary, bold = true })
  set_hl(0, "DashboardCenter",    { fg = fg })
  set_hl(0, "DashboardIcon",      { fg = primary })
  set_hl(0, "DashboardKey",       { fg = secondary })
  set_hl(0, "DashboardDesc",      { fg = fg })
  set_hl(0, "DashboardShortCut",  { fg = secondary })
  set_hl(0, "DashboardFooter",    { fg = outline, italic = true })

  set_hl(0, "WhichKey",          { fg = primary })
  set_hl(0, "WhichKeyGroup",     { fg = tertiary })
  set_hl(0, "WhichKeyDesc",      { fg = fg })
  set_hl(0, "WhichKeySeparator", { fg = outline })
  set_hl(0, "WhichKeyFloat",     { bg = surface_mid })
  set_hl(0, "WhichKeyBorder",    { fg = primary, bg = surface_mid })
end

augroup("CaelestiaExtendedHighlights", { clear = true })
autocmd("ColorScheme", {
  group = "CaelestiaExtendedHighlights",
  pattern = "caelestia",
  callback = function()
    vim.schedule(apply_extended_highlights)
  end,
})

if vim.g.colors_name == "caelestia" then
  apply_extended_highlights()
end
