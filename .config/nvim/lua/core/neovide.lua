-- ┌──────────────────────────────────────────┐
-- │         Neovide-Specific Settings        │
-- │   GUI features, animations, & visuals    │
-- │   Only applied when running in Neovide   │
-- └──────────────────────────────────────────┘

if not vim.g.neovide then
	return -- Skip all settings if not running in Neovide
end

-- Neovide guifont: use a fallback chain so it doesn't crash if the primary
-- font isn't installed. Neovide uses commas to separate fallback fonts.
-- Common Nerd Font names (try the one you have installed):
--   "JetBrainsMono Nerd Font"   (standard nerd-fonts name)
--   "JetBrainsMono NF"          (alternative short name)
--   "JetBrainsMono_NF"          (older Neovide underscore convention)
vim.o.guifont = "JetBrainsMono NF:h14"

-- ── Cursor Animations ─────────────────────────────────────────
-- Smooth cursor movement (Neovide's signature feature)
vim.g.neovide_cursor_animation_length = 0.09 -- Duration of cursor move animation
vim.g.neovide_cursor_trail_size = 0.9 -- Length of cursor trail/smear

-- Cursor particle effects — choose your style:
-- Options: "railgun", "torpedo", "pixiedust", "sonicboom", "ripple", "wireframe"
vim.g.neovide_cursor_vfx_mode = ""
vim.g.neovide_cursor_vfx_particle_lifetime = 1.2
vim.g.neovide_cursor_vfx_particle_density = 7.0
vim.g.neovide_cursor_vfx_particle_speed = 10.0

-- ── Smooth Scrolling ──────────────────────────────────────────
vim.g.neovide_scroll_animation_length = 0.3 -- Scroll animation duration
vim.g.neovide_far_scroll_lines = 9999 -- Renamed from neovide_scroll_animation_far_lines; large value = no animation for long jumps

-- ── Window Padding ────────────────────────────────────────────
-- Adds breathing room around the edges (in pixels)
vim.g.neovide_padding_top = 10
vim.g.neovide_padding_bottom = 10
vim.g.neovide_padding_left = 10
vim.g.neovide_padding_right = 10

-- ── Transparency ──────────────────────────────────────────────
-- 1.0 = fully opaque, 0.0 = fully transparent
vim.g.neovide_opacity = 1.0

-- ── Floating Window Effects ───────────────────────────────────
vim.g.neovide_floating_shadow = true
vim.g.neovide_floating_z_height = 10
vim.g.neovide_light_angle_degrees = 45
vim.g.neovide_light_radius = 5

-- ── Text Rendering ───────────────────────────────────────────
vim.g.neovide_text_gamma = 0.0
vim.g.neovide_text_contrast = 0.5

-- ── Scaling ───────────────────────────────────────────────────
vim.g.neovide_scale_factor = 1.0

-- Corner

vim.g.neovide_corner_preference = "round"

-- Mouse

vim.g.neovide_hide_mouse_when_typing = true
vim.g.neovide_message_area_drag_selection = true

-- Monitor

vim.g.neovide_refresh_rate = 180
vim.g.neovide_no_idle = true
vim.g.neovide_cursor_antialiasing = false

-- Helper function for Ctrl+= / Ctrl+- zoom
local function change_scale_factor(delta)
	vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
end

-- Zoom in/out with Ctrl+= and Ctrl+-
vim.keymap.set("n", "<C-=>", function()
	change_scale_factor(1.1)
end, { desc = "Neovide: Zoom in" })
vim.keymap.set("n", "<C-->", function()
	change_scale_factor(1 / 1.1)
end, { desc = "Neovide: Zoom out" })
vim.keymap.set("n", "<C-0>", function()
	vim.g.neovide_scale_factor = 1.0
end, { desc = "Neovide: Reset zoom" })

-- ── Fullscreen Toggle ─────────────────────────────────────────
vim.keymap.set("n", "<F11>", function()
	vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
end, { desc = "Neovide: Toggle fullscreen" })

-- ── System Clipboard Keybinds for Neovide ─────────────────────
-- These ensure Ctrl+V paste works properly in all Neovide modes
vim.keymap.set("n", "<C-S-v>", '"+P', { desc = "Paste from clipboard" })
vim.keymap.set("v", "<C-S-v>", '"+P', { desc = "Paste from clipboard" })
vim.keymap.set("c", "<C-S-v>", "<C-R>+", { desc = "Paste from clipboard" })
vim.keymap.set("i", "<C-S-v>", '<ESC>"+PA', { desc = "Paste from clipboard" })
vim.keymap.set("t", "<C-S-v>", '<C-\\><C-n>"+PA', { desc = "Paste from clipboard" })
