# Atlas Neovim Configuration Guide

> A comprehensive guide to your Neovim + Neovide setup.
> Optimized for Turkish-Q keyboard layout, Windows 10 & Arch Linux.

---

## Table of Contents

1. [Installation](#installation)
2. [Understanding Neovim Modes](#understanding-neovim-modes)
3. [Complete Keybind Reference](#complete-keybind-reference)
4. [Plugin Guide](#plugin-guide)
5. [Turkish-Q Keyboard Map](#turkish-q-keyboard-map)
6. [Customization Guide](#customization-guide)
7. [Troubleshooting](#troubleshooting)

---

## Installation

### Prerequisites

| Tool | Windows | Arch Linux | Why |
|------|---------|------------|-----|
| **Neovim 0.11+** | `winget install Neovim.Neovim` | `pacman -S neovim` | The editor itself |
| **Neovide** | [neovide.dev](https://neovide.dev) | `pacman -S neovide` | GUI frontend |
| **Git** | `winget install Git.Git` | `pacman -S git` | Plugin management |
| **Node.js** | `winget install OpenJS.NodeJS.LTS` | `pacman -S nodejs npm` | LSP servers (TypeScript, etc.) |
| **ripgrep** | `winget install BurntSushi.ripgrep.MSVC` | `pacman -S ripgrep` | Telescope grep |
| **fd** | `winget install sharkdp.fd` | `pacman -S fd` | Telescope file finder |
| **A Nerd Font** | [nerdfonts.com](https://nerdfonts.com) | `pacman -S ttf-jetbrains-mono-nerd` | Icons everywhere |
| **Rust** | [rustup.rs](https://rustup.rs) | `pacman -S rustup` | rust-analyzer, blink.cmp |
| **Python** | `winget install Python.Python.3` | `pacman -S python` | pyright LSP |
| **C/C++ compiler** | Visual Studio Build Tools | `pacman -S gcc` | clangd, telescope-fzf-native |

### Setup Steps

#### Windows 10

```powershell
# 1. Clone the config to the correct location
# Option A: Symlink (recommended — keeps config in your repo)
New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA\nvim" -Target "C:\atlasfirarda\#ANTIGRAVITY\nvim"

# Option B: Copy
Copy-Item -Recurse "C:\atlasfirarda\#ANTIGRAVITY\nvim" "$env:LOCALAPPDATA\nvim"

# 2. Launch Neovide — plugins will auto-install on first run
neovide
```

#### Arch Linux

```bash
# 1. Symlink to standard config location
ln -sf /path/to/nvim ~/.config/nvim

# 2. Launch Neovide
neovide
```

### First Launch

On first launch, **lazy.nvim** will automatically:
1. Install itself
2. Download and install all plugins
3. Install Treesitter parsers
4. Install LSP servers via Mason

This may take 1-2 minutes. Wait for all installations to complete, then restart Neovide.

---

## Understanding Neovim Modes

Neovim is a **modal editor** — it has different modes for different tasks. This is what makes it powerful (and initially confusing). Think of modes like tools in a toolbox: you pick the right tool for the job.

### Mode Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     NORMAL MODE                              │
│  Your "home base" — navigate, delete, copy, run commands    │
│  You spend most of your time here                           │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │  i / a   │  │    v     │  │    :     │                   │
│  │  Enter   │  │  Enter   │  │  Enter   │                   │
│  ▼          │  ▼          │  ▼          │                   │
│ INSERT     │  VISUAL     │  COMMAND   │                     │
│ Type text  │  Select     │  Run cmds  │                     │
│            │  text       │            │                      │
│  dd/Esc    │  Esc/dd     │  Enter/Esc │                     │
│  Back to   │  Back to    │  Back to   │                     │
│  NORMAL    │  NORMAL     │  NORMAL    │                     │
│  ──────────┘  ──────────┘  ──────────┘                      │
└─────────────────────────────────────────────────────────────┘
```

### Normal Mode (DEFAULT)

This is where you **start** and where you **return to**. In Normal mode, every key is a command:
- `h j k l` = Move cursor (left, down, up, right) — or just use arrow keys!
- `w` = Jump to next word
- `b` = Jump to previous word
- `0` = Go to start of line
- `$` = Go to end of line
- `gg` = Go to first line of file
- `G` = Go to last line of file
- `x` = Delete character under cursor
- `u` = Undo (or Ctrl+Z)
- `Ctrl+R` = Redo (or Ctrl+Shift+Z)

**Your statusline shows the current mode** — look at the bottom-left corner. It will say `NORMAL`, `INSERT`, `VISUAL`, etc.

### Insert Mode (TYPING)

This is where you **actually type text**, like a normal editor.

**How to enter:**
- `i` = Insert before cursor
- `a` = Insert after cursor
- `o` = Open new line below and insert
- `O` = Open new line above and insert
- `A` = Insert at end of line
- `I` = Insert at beginning of line

**How to exit (back to Normal):**
- **Double-tap `d`** (your custom escape — left index finger)
- `Escape` key (standard, but far from your hands)
- `Ctrl+[` (standard vim alternative)

### Visual Mode (SELECTING)

This is like clicking and dragging to select text.

**How to enter (from Normal):**
- `v` = Character-wise selection (select individual characters)
- `V` = Line-wise selection (select whole lines)
- `Leader+v` (or `Ctrl+V`) = Block selection (select a rectangle)

**While in Visual:**
- Move with arrow keys or `h j k l` to expand selection
- `y` = Copy (yank) selection
- `d` = Delete selection
- `>` / `<` = Indent/Outdent (stays selected!)
- `Tab` / `Shift+Tab` = Indent/Outdent

### Command Mode

- Press `:` to enter a command
- `:w` = Save
- `:q` = Quit
- `:wq` = Save and quit
- `:q!` = Quit without saving

---

## Complete Keybind Reference

### Legend
- `Leader` = Space bar
- `C-` = Ctrl
- `A-` = Alt
- `S-` = Shift

### General (VSCode-Familiar)

| Keybind | Action | Works In |
|---------|--------|----------|
| `Ctrl+S` | Save file | Normal, Insert, Visual |
| `Ctrl+Z` | Undo | Normal, Insert |
| `Ctrl+Shift+Z` / `Ctrl+Y` | Redo | Normal, Insert |
| `Ctrl+C` | Copy to clipboard | Visual |
| `Ctrl+X` | Cut to clipboard | Visual |
| `Ctrl+V` | Paste from clipboard | Normal, Insert, Visual |
| `Ctrl+A` | Select all | Normal, Insert |
| `Ctrl+/` | Toggle comment | Normal, Visual |
| `Ctrl+Shift+D` | Duplicate line | Normal, Visual |
| `Ctrl+Shift+K` | Delete line | Normal, Insert |
| `Ctrl+Backspace` | Delete word backward | Insert |
| `Alt+Up/Down` | Move line up/down | Normal, Insert, Visual |
| `Escape` | Clear search highlight | Normal |

### Mode Switching

| Keybind | From → To | Notes |
|---------|-----------|-------|
| `dd` (fast double-tap) | Insert → Normal | Your custom escape |
| `i` | Normal → Insert (before cursor) | Standard |
| `a` | Normal → Insert (after cursor) | Standard |
| `o` | Normal → Insert (new line below) | Standard |
| `v` | Normal → Visual | Standard |
| `V` | Normal → Visual Line | Standard |
| `Leader+v` | Normal → Visual Block | Custom |
| `Esc Esc` | Terminal → Normal | Double escape |

### Navigation

| Keybind | Action | Notes |
|---------|--------|-------|
| `Ctrl+H/J/K/L` | Focus window left/down/up/right | Standard vim |
| `Ctrl+Arrow keys` | Resize windows | ±2 per press |
| `Alt+A` / `Shift+H` | Previous buffer (tab) | Left hand reach |
| `Alt+D` / `Shift+L` | Next buffer (tab) | Left hand reach |
| `Alt+1-5` | Go to tab 1-5 | Direct jump |
| `Ctrl+D` | Scroll half-page down (centered) | |
| `Ctrl+U` | Scroll half-page up (centered) | |
| `Leader+sv` | Split vertical | |
| `Leader+sh` | Split horizontal | |
| `Leader+sc` | Close split | |
| `Ctrl+W` | Close buffer | |

### File Finding (Telescope)

| Keybind | Action |
|---------|--------|
| `Ctrl+Space` | Find files (Zed-style!) |
| `Ctrl+P` | Find files (VSCode-style) |
| `Ctrl+F` | Fuzzy find in current file |
| `Ctrl+Shift+Space` | Command palette |
| `Leader+ff` | Find files |
| `Leader+fg` | Find git files |
| `Leader+fr` | Live grep (search all files) |
| `Leader+fw` | Grep word under cursor |
| `Leader+fb` | Find buffers |
| `Leader+fo` | Recent files |
| `Leader+fk` | Search keymaps |
| `Leader+f?` | Search help tags |
| `Leader+fs` | Document symbols |
| `Leader+fd` | Diagnostics |

### LSP (Code Intelligence)

| Keybind | Action |
|---------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Find all references |
| `gi` | Go to implementation |
| `go` | Go to type definition |
| `K` | Hover documentation |
| `gs` | Signature help |
| `Leader+k` | Show diagnostics float |
| `[d` / `]d` | Previous/Next diagnostic |
| `Leader+ca` / `F4` | Code actions |
| `Leader+rn` / `F2` | Rename symbol |
| `Ctrl+Shift+F` | Format file |

### Completion (blink.cmp)

| Keybind | Action |
|---------|--------|
| `Tab` | Next completion item / snippet field |
| `Shift+Tab` | Previous completion item / snippet field |
| `Enter` | Accept completion |
| `Ctrl+Space` | Trigger completion manually |
| `Ctrl+E` | Dismiss completion |
| `Ctrl+J/K` | Navigate completion (alternative) |
| `Ctrl+D/U` | Scroll documentation |

### File Explorer (Neo-tree)

| Keybind | Action |
|---------|--------|
| `Ctrl+B` | Toggle file explorer (Zed-style!) |
| `Leader+e` | Toggle file explorer |
| `Leader+ge` | Git status explorer |
| `Leader+be` | Buffer explorer |
| Inside Neo-tree: `Enter/l` | Open file |
| Inside Neo-tree: `h` | Close folder |
| Inside Neo-tree: `P` | Preview file |

### Terminal (toggleterm)

| Keybind | Action |
|---------|--------|
| `Ctrl+\` | Toggle floating terminal |
| `Leader+tt` | Toggle terminal |
| `Leader+tf` | Float terminal |
| `Leader+tv` | Vertical terminal |
| `Leader+ts` | Horizontal terminal |

### Git (Gitsigns)

| Keybind | Action |
|---------|--------|
| `]h` / `[h` | Next/Previous git hunk |
| `Leader+gs` | Stage hunk |
| `Leader+gr` | Reset hunk |
| `Leader+gS` | Stage entire buffer |
| `Leader+gR` | Reset entire buffer |
| `Leader+gp` | Preview hunk |
| `Leader+gb` | Toggle line blame |
| `Leader+gd` | Diff this file |

### Trouble (Diagnostics Panel)

| Keybind | Action |
|---------|--------|
| `Leader+xx` | Toggle diagnostics (all files) |
| `Leader+xd` | Toggle diagnostics (current buffer) |
| `Leader+xl` | Location list |
| `Leader+xq` | Quickfix list |
| `Leader+xs` | Symbols |
| `Leader+xt` | TODO list |

### Neovide-Specific

| Keybind | Action |
|---------|--------|
| `F11` | Toggle fullscreen |
| `Ctrl+=` | Zoom in |
| `Ctrl+-` | Zoom out |
| `Ctrl+0` | Reset zoom |

### Utility

| Keybind | Action |
|---------|--------|
| `Leader+?` | Show buffer-local keymaps |
| `Leader+Leader` | Show ALL keymaps |
| `Leader+th` | Toggle theme (dark/light) |
| `Leader+lz` | Open Lazy plugin manager |
| `Leader+lm` | Open Mason LSP manager |
| `Leader+;` | Add semicolon at end of line |
| `Leader+,` | Add comma at end of line |
| `Leader+o` | Add empty line below |
| `Leader+O` | Add empty line above |

---

## Plugin Guide

### What Each Plugin Does

| Plugin | Purpose | Why Included |
|--------|---------|-------------|
| **lazy.nvim** | Plugin manager | Auto-installs and manages all plugins |
| **Catppuccin** | Color scheme | Beautiful, modern theme with light/dark variants |
| **Neo-tree** | File explorer | Sidebar file tree like VS Code |
| **Telescope** | Fuzzy finder | Find files, grep text, browse buffers, commands |
| **Treesitter** | Syntax highlighting | Parser-based accurate highlighting for all languages |
| **nvim-lspconfig** | LSP client | Connects to language servers for code intelligence |
| **Mason** | LSP installer | Auto-installs language servers, linters, formatters |
| **blink.cmp** | Autocompletion | Fast code completion with LSP, snippets, paths |
| **conform.nvim** | Code formatting | Format-on-save with Prettier, rustfmt, etc. |
| **Lualine** | Status bar | Bottom bar showing mode, branch, file, diagnostics |
| **Bufferline** | Tab bar | Top bar showing open files as clickable tabs |
| **Gitsigns** | Git indicators | Shows add/change/delete in the gutter |
| **toggleterm** | Terminal | Floating terminal with one-key toggle |
| **which-key** | Key helper | Popup showing available keybinds |
| **noice** | UI enhancement | Fancy floating command line and notifications |
| **indent-blankline** | Indent guides | Visual lines showing indentation levels |
| **dashboard** | Start screen | Quick actions when you open Neovim |
| **nvim-autopairs** | Auto brackets | Automatically closes brackets, quotes, etc. |
| **nvim-surround** | Surround editing | Add/change/delete surrounding characters |
| **Comment.nvim** | Comments | Toggle comments with Ctrl+/ or gcc |
| **todo-comments** | TODO highlighting | Highlights TODO/FIXME/HACK comments |
| **nvim-colorizer** | Color preview | Shows CSS color values inline |
| **trouble.nvim** | Diagnostics panel | Pretty list of all errors and warnings |

### How to Add a New Plugin

1. Create a new file in `lua/plugins/` (e.g., `lua/plugins/my-plugin.lua`)
2. Return the lazy.nvim spec:

```lua
return {
  "author/plugin-name",
  event = "VeryLazy",  -- When to load (see lazy.nvim docs)
  opts = {
    -- Plugin options go here
  },
}
```

3. Restart Neovim — lazy.nvim auto-discovers files in `lua/plugins/`

### How to Add a New LSP Server

1. Open Mason with `Leader+lm` or `:Mason`
2. Search for the server and press `i` to install
3. Or add it to `ensure_installed` in `lua/plugins/lsp.lua`
4. Add custom config if needed with `vim.lsp.config("server_name", { ... })`
5. Add it to the `vim.lsp.enable()` list

### How to Add a New Formatter

1. Edit `lua/plugins/formatting.lua`
2. Add the filetype and formatter:

```lua
my_language = { "my_formatter" },
```

3. Install the formatter via Mason or your system package manager

### How to Update Plugins

- Run `:Lazy update` or press `Leader+lz` then `U`
- Run `:MasonUpdate` to update LSP servers

---

## Turkish-Q Keyboard Map

Your hands rest on:
- **Left hand**: W-A-S-D area (gaming position)
- **Right hand**: Enter-Ü-Ş/I area

```
Key positions and their Neovim functions:

LEFT HAND (primary):
┌─────┬─────┬─────┬─────┬─────┬─────┐
│ Esc │  1  │  2  │  3  │  4  │  5  │
│     │     │     │     │     │     │
├─────┼─────┼─────┼─────┼─────┼─────┤
│ Tab │  Q  │  W  │  E  │  R  │  T  │
│Ind. │     │ ↑   │     │     │     │
├─────┼─────┼─────┼─────┼─────┼─────┤
│CapsL│  A  │  S  │  D  │  F  │  G  │
│     │ ←   │ ↓   │dd=Esc│    │     │
├─────┼─────┼─────┼─────┼─────┼─────┤
│Shift│  Z  │  X  │  C  │  V  │  B  │
│     │     │     │Copy │Paste│     │
└─────┴─────┴─────┴─────┴─────┴─────┘
         ┌─────────────────┐
         │    Space Bar     │
         │   (Leader Key)   │
         └─────────────────┘

RIGHT HAND:
┌─────┬─────┬─────┬─────┬─────┐
│  8  │  9  │  0  │  -  │  =  │
│     │     │Reset│Zoom-│Zoom+│
├─────┼─────┼─────┼─────┼─────┤
│  Ü  │  I  │  O  │  P  │  Ğ  │
│     │     │     │     │     │
├─────┼─────┼─────┼─────┼─────┤
│  Ş  │  İ  │  L  │Enter│     │
│     │     │     │Conf.│     │
├─────┼─────┼─────┼─────┼─────┤
│  Ö  │  Ç  │  .  │ R-  │     │
│     │     │     │Shift│     │
└─────┴─────┴─────┴─────┴─────┘
```

### Hand Position Philosophy

- **`dd` escape**: Your left index finger rests on `D` — double-tap it to exit Insert mode
- **`Space` leader**: Both thumbs reach it — prefix for all custom commands
- **`Alt+A/D`**: Left hand buffer switching (A=prev, D=next, like WASD)
- **`Ctrl+B`**: Left pinky — toggle file explorer
- **`Ctrl+Space`**: Both hands — file finder
- **`Enter`**: Right hand — confirm completion/selections

---

## Customization Guide

### Config File Structure

```
nvim/
├── init.lua                    ← Entry point (don't edit much)
├── lua/
│   ├── core/
│   │   ├── init.lua            ← Module loader
│   │   ├── options.lua         ← ★ Edit: tab size, line numbers, etc.
│   │   ├── neovide.lua         ← ★ Edit: font, animations, cursor effects
│   │   └── autocmds.lua        ← Auto-behaviors
│   ├── keymaps/
│   │   ├── init.lua            ← Module loader
│   │   ├── general.lua         ← ★ Edit: add general shortcuts
│   │   ├── navigation.lua      ← ★ Edit: window/buffer keybinds
│   │   ├── editing.lua         ← ★ Edit: text manipulation keybinds
│   │   ├── lsp.lua             ← LSP-specific keybinds
│   │   └── plugins.lua         ← Cross-plugin keybinds
│   └── plugins/
│       ├── init.lua            ← Lazy.nvim setup (rarely edit)
│       ├── colorscheme.lua     ← ★ Edit: change theme/colors
│       ├── neo-tree.lua        ← File explorer config
│       ├── telescope.lua       ← Fuzzy finder config
│       ├── treesitter.lua      ← ★ Edit: add language parsers
│       ├── lsp.lua             ← ★ Edit: add LSP servers
│       ├── completion.lua      ← Autocompletion config
│       ├── formatting.lua      ← ★ Edit: add formatters
│       ├── statusline.lua      ← Status bar config
│       ├── bufferline.lua      ← Tab bar config
│       ├── git.lua             ← Git integration config
│       ├── terminal.lua        ← Terminal config
│       ├── which-key.lua       ← Key helper config
│       ├── ui.lua              ← noice, indent guides, dashboard
│       ├── editing.lua         ← autopairs, surround, Comment
│       └── extras.lua          ← todo-comments, colorizer, trouble
└── docs/
    └── GUIDE.md                ← This file!
```

### Change Theme/Font

Edit `lua/core/neovide.lua`:
```lua
vim.o.guifont = "YourFont Nerd Font:h16"  -- Change font and size
```

Edit `lua/plugins/colorscheme.lua`:
```lua
flavour = "mocha",  -- Options: latte, frappe, macchiato, mocha
```

### Change Tab Size

Edit `lua/core/options.lua`:
```lua
opt.shiftwidth = 2   -- Change from 4 to 2
opt.tabstop = 2
```

### Add a New Keybind

Edit the appropriate file in `lua/keymaps/`:
```lua
vim.keymap.set("n", "<leader>my_key", function()
  -- Your action here
end, { desc = "Description shown in which-key" })
```

### Disable dd Escape (if annoying)

Edit `lua/keymaps/editing.lua`, remove or comment out:
```lua
-- map("i", "dd", "<Esc>", { desc = "Exit Insert mode (double-tap d)" })
```

And use `Escape`, `Ctrl+[`, or map a different sequence like `jk`:
```lua
map("i", "jk", "<Esc>", { desc = "Exit Insert mode" })
```

---

## Troubleshooting

### Common Issues

**Q: Plugins won't install**
- Check internet connection
- Run `:Lazy` to see error messages
- Try `:Lazy clean` then `:Lazy install`

**Q: LSP server not working**
- Run `:LspInfo` to see attached servers
- Run `:Mason` to check server installation
- Run `:checkhealth` for diagnostic info

**Q: Icons look like boxes/squares**
- Install a Nerd Font (JetBrainsMono Nerd Font recommended)
- Set it in Neovide: edit `neovide.lua` → `guifont`

**Q: dd escape has a delay when typing words with "dd"**
- This is expected — the 300ms `timeoutlen` waits to see if you're escaping
- To reduce delay: edit `options.lua` → `opt.timeoutlen = 200` (shorter = faster but harder to hit)
- To remove: comment out the `dd` mapping and use `jk` or `Escape` instead

**Q: Ctrl+Space doesn't work in Telescope**
- In Insert mode, Ctrl+Space triggers completion (blink.cmp)
- In Normal mode, Ctrl+Space opens file finder (Telescope)
- If conflict: use `Ctrl+P` or `Leader+ff` for file finding instead

**Q: Font size is too big/small in Neovide**
- Use `Ctrl+=` / `Ctrl+-` to zoom in/out
- Or edit `neovide.lua` → change `h14` to your preferred size

### Health Check

Run inside Neovim:
```
:checkhealth
```

This will verify all dependencies, LSP servers, and plugin configurations.

---

*Generated for Atlas Neovim Config — Last updated: July 2026*
