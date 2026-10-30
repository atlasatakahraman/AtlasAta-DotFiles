-- Caelestia Hyprland Variable Overrides
-- Migrated from legacy ~/.config/hypr/variables.conf & keybinds.conf
-- Reference: ~/.config/hypr/variables.lua

local scheme = require("scheme.current")

return {
    ------------------
    ---- HYPRLAND ----
    ------------------

    -- Apps
    terminal                   = "kitty",
    browser                    = "firefox-developer-edition",
    editor                     = "neovide",
    fileExplorer               = "thunar",
    audioSettings              = "pavucontrol",

    -- Shadow
    shadowRange                = 20,
    shadowRenderPower          = 3,
    shadowColour               = "rgba(" .. scheme.surface .. "d4)",

    -- Gaps (from legacy variables.conf)
    workspaceGaps              = 20,
    windowGapsIn               = 10,
    windowGapsOut              = 40,
    singleWindowGapsOut        = 20,

    -- Window styling
    windowOpacity              = 0.95,
    windowRounding             = 10,
    windowBorderSize           = 3,

    -- Misc
    volumeStep                 = 9,

    ------------------
    ---- KEYBINDS ----
    ------------------

    -- Workspace navigation (preserves legacy scroll-up = +1, scroll-down = -1)
    kbPrevWs                   = { "SUPER + mouse_down", "CTRL + SUPER + Left", "SUPER + Page_Up" },
    kbNextWs                   = { "SUPER + mouse_up", "CTRL + SUPER + Right", "SUPER + Page_Down" },
    kbPrevWsGroup              = "CTRL + SUPER + mouse_down",
    kbNextWsGroup              = "CTRL + SUPER + mouse_up",
    kbMoveWinToWsPrev          = { "SUPER + ALT + mouse_down", "SUPER + ALT + Page_Up", "CTRL + SUPER + SHIFT + Left" },
    kbMoveWinToWsNext          = { "SUPER + ALT + mouse_up", "SUPER + ALT + Page_Down", "CTRL + SUPER + SHIFT + Right" },

    -- Window actions
    kbMoveWindow               = "SUPER + Z",        -- Hold SUPER + Z (or SUPER + mouse:272) to drag windows
    kbResizeWindow             = "",                 -- Mouse resize remains on SUPER + mouse:273 (frees SUPER + X)
    kbCloseWindow              = "SUPER + X",
    kbToggleWindowFloating     = "SUPER + Space",
    kbWindowBorderedFullscreen = "SUPER + D",        -- Maximize (fullscreen mode 1)
    kbWindowFullscreen         = "SUPER + ALT + F",  -- Frees SUPER + F for special:file

    -- Special workspaces (additional custom toggles are bound in hypr-user.lua)
    kbSpecialWs                = "",                 -- Frees SUPER + S for special:music
    kbMusicWs                  = "SUPER + S",
    kbCommunicationWs          = "SUPER + H",        -- Opens/wakes Vesktop & toggles special:communication
    kbTodoWs                   = "",                 -- Bound directly in hypr-user.lua without spawning todoist

    -- Apps
    kbTerminal                 = "SUPER + T",
    kbBrowser                  = "SUPER + Q",        -- Primary browser (frees SUPER + W for special:terminal)
    kbEditor                   = "SUPER + B",        -- Editor (frees SUPER + C for special:ide)
    kbFileExplorer             = "SUPER + E",
    kbAudioSettings            = "SUPER + N",        -- Audio control (pavucontrol)

    -- Utilities & Misc
    kbShowSidebar              = "",                 -- Frees SUPER + N for pavucontrol
    kbScreenshot               = "",                 -- Print is bound to screenshotFreezeClip in hypr-user.lua
    kbScreenshotFreeze         = "SUPER + Print",
    kbColorPicker              = "SUPER + ALT + Print",
}
