--------------------------------------------------------------------------------
-- Caelestia Hyprland User Configuration
-- Migrated from legacy ~/.config/hypr/hyprland.conf & ~/.config/hypr/hyprland/*.conf
-- Loaded automatically at the end of ~/.config/hypr/hyprland.lua
--------------------------------------------------------------------------------

local vars = require("variables")

------------------
---- MONITORS ----
------------------
-- Primary Monitor: DisplayPort (1440p @ 165Hz)
hl.monitor({
    output   = "DP-1",
    mode     = "2560x1440@165",
    position = "auto",
    scale    = 1,
})

-- Secondary Monitor: HDMI (1080p @ 60Hz)
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@60",
    position = "auto",
    scale    = 1,
})

-----------------------
---- INPUT & MISC  ----
-----------------------
-- Turkish Q keyboard, zero-delay CapsLock (unlockOnPress), & middle-click paste
hl.config({
    input = {
        kb_layout  = "tr",
        kb_variant = "",
        kb_file    = "/home/atlasata/.config/caelestia/keymap.xkb",
    },
    misc = {
        middle_click_paste = true,
    },
})

-----------------------------
---- ENV & AUTOSTART     ----
-----------------------------
-- From legacy env.conf & execs.conf
hl.env("XDG_MENU_PREFIX", "arch-")

hl.on("hyprland.start", function()
    hl.exec_cmd("easyeffects --gapplication-service")
    -- Re-sync SDDM dynamic theme if a caelestia-sddm package upgrade overwrote theme.conf / background.png
    hl.exec_cmd("sh -c '[ -e /usr/share/sddm/themes/caelestia/assets/background.png ] && sudo -n /usr/share/sddm/themes/caelestia/scripts/sync.sh --posthook'")
end)

----------------------------
---- CUSTOM KEYBINDINGS ----
----------------------------
local locked = { locked = true }

-- Toggle Microphone (from legacy keybinds.conf)
hl.bind("XF86Launch9", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), locked)

-- Lock session + turn off displays after 1s (from legacy keybinds.conf)
hl.bind("CTRL + SUPER + L", function()
    hl.exec_cmd("loginctl lock-session")
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms("off"))
    end, { timeout = 1000, type = "oneshot" })
end, locked)

-- Disable laptop brightness keys (commented out in legacy keybinds.conf)
hl.unbind("XF86MonBrightnessUp")
hl.unbind("XF86MonBrightnessDown")

-- Screenshot (Print -> freeze & copy region to clipboard, matching legacy keybinds.conf)
hl.bind("Print", hl.dsp.global("caelestia:screenshotFreezeClip"), locked)

-- Extra application launchers (from legacy variables.conf & keybinds.conf)
hl.bind("SUPER + ALT + Q", hl.dsp.exec_cmd("com.vivaldi.Vivaldi --no-sandbox"))
hl.bind("SUPER + ALT + G", hl.dsp.exec_cmd("obs"))

-- Custom Special Workspace Toggles (from legacy variables.conf & keybinds.conf)
hl.bind("SUPER + C", hl.dsp.workspace.toggle_special("ide"))
hl.bind("SUPER + R", hl.dsp.workspace.toggle_special("todo"))
hl.bind("SUPER + F", hl.dsp.workspace.toggle_special("file"))
hl.bind("SUPER + A", hl.dsp.workspace.toggle_special("game"))
hl.bind("SUPER + W", hl.dsp.workspace.toggle_special("terminal"))
hl.bind("SUPER + G", hl.dsp.workspace.toggle_special("stream"))
hl.bind("SUPER + Y", hl.dsp.workspace.toggle_special("design"))
hl.bind("SUPER + ALT + Y", hl.dsp.workspace.toggle_special("docs"))

-------------------------------------
---- CUSTOM WINDOW & LAYER RULES ----
-------------------------------------
-- Suppress client-initiated maximize requests so new windows always tile
-- instead of launching maximized/fullscreen (omitted in upstream Caelestia rules.lua)
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland empty drag-window focus issues (from Hyprland 0.57 defaults)
hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Opaque kitty terminal
hl.window_rule({ match = { class = "kitty" }, opaque = true })

-- Force tiled for games, Cursor, and Notion (from legacy rules.conf)
hl.window_rule({ match = { class = "steam", title = "^(?!Friends List$).*$" }, float = false })
hl.window_rule({ match = { class = "steam" }, rounding = 10 })
hl.window_rule({
    match = { class = "minecraft|javaw|java|Minecraft.*|org\\.vinegarhq\\.Sober|Froststrap" },
    float = false,
})
hl.window_rule({ match = { class = "cursor|Notion" }, float = false })

-- Float, resize (60% x 70%) and center kitty nmtui
hl.window_rule({
    match  = { class = "kitty", title = "nmtui" },
    float  = true,
    size   = "(monitor_w*0.6) (monitor_h*0.7)",
    center = true,
})

-- Special workspace routing rules (from legacy rules.conf)
hl.window_rule({
    match     = { class = "Vivaldi-flatpak|com\\.vivaldi\\.Vivaldi|firefox|Notion|firefox-developer-edition" },
    workspace = "special:todo",
})
hl.window_rule({
    match     = { class = "thunar|dolphin" },
    workspace = "special:file",
})
hl.window_rule({
    match     = { class = "org\\.prismlauncher\\.PrismLauncher|steam|org\\.multimc\\.MultiMC|minecraft|java|javaw|Minecraft.*|org\\.vinegarhq\\.Sober|Froststrap" },
    workspace = "special:game",
})
hl.window_rule({
    match     = { class = vars.terminal },
    workspace = "special:terminal",
})
hl.window_rule({
    match     = { class = "com\\.obsproject\\.Studio|obs" },
    workspace = "special:stream",
})
hl.window_rule({
    match     = { class = "Aseprite|aseprite|ai\\.storyteller\\.photocraft|photocraft|PhotoCraft|ai\\.storyteller\\.effectcraft|effectcraft|EffectCraft" },
    workspace = "special:design",
})
hl.window_rule({
    match     = { class = "dev\\.zed\\.Zed|antigravity|Antigravity|cursor|neovide|nvim|neovim|com\\.anthropic\\.Claude|Claude|claude-desktop" },
    workspace = "special:ide",
})
hl.window_rule({
    match     = { class = "obsidian|org\\.kde\\.gwenview|ai\\.storyteller\\.pdfcraft|pdfcraft|PdfCraft|ai\\.storyteller\\.wordcraft|wordcraft|WordCraft|ai\\.storyteller\\.gridcraft|gridcraft|GridCraft" },
    workspace = "special:docs",
})
hl.window_rule({
    match     = { class = "dev\\.vencord\\.Vesktop|vesktop|discord|Discord|equibop" },
    workspace = "special:communication",
})

-- Caelestia drawers blur (from legacy rules.conf)
hl.layer_rule({
    match        = { namespace = "caelestia-drawers" },
    blur         = true,
    ignore_alpha = 0.57,
})

------------------
---- PLUGINS  ----
------------------
-- Dynamic Cursors plugin configuration
local function is_plugin_loaded(target)
    if type(hl.get_loaded_plugins) ~= "function" then
        return false
    end
    for _, p in ipairs(hl.get_loaded_plugins()) do
        if p.name and (p.name == target or p.name:find(target, 1, true)) then
            return true
        end
    end
    return false
end

if is_plugin_loaded("dynamic-cursors") then
    pcall(function()
        hl.config({
            plugin = {
                ["dynamic-cursors"] = {
                    enabled   = true,
                    mode      = "stretch",
                    threshold = 2,
                    rotate = {
                        length = 20,
                        offset = 0.0,
                    },
                    tilt = {
                        limit        = 5000,
                        ["function"] = "negative_quadratic",
                        window       = 100,
                        full_tilt    = 60,
                    },
                    stretch = {
                        limit        = 5400,
                        ["function"] = "quadratic",
                        window       = 90,
                    },
                    shake = {
                        enabled   = false,
                        threshold = 6.0,
                        base      = 4.0,
                        speed     = 4.0,
                        timeout   = 2000,
                        nearest   = true,
                        effects   = false,
                    },
                },
            },
        })
    end)
end
