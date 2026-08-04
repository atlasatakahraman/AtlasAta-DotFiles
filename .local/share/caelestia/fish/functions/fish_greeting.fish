function _caelestia_read_color --description "Read a colour from caelestia scheme.json"
    set -l key $argv[1]
    set -l fallback $argv[2]
    set -l scheme "$HOME/.local/state/caelestia/scheme.json"
    if test -f "$scheme"
        set -l val (string match -r "\"$key\"\\s*:\\s*\"([0-9a-fA-F]{6})\"" < "$scheme")
        if test (count $val) -ge 2
            echo $val[2]
            return
        end
    end
    echo $fallback
end

function fish_greeting
    # ── ASCII art ──────────────────────────────────────────────
    if set -q NVIM
        # Neovim terminal: OSC 4 doesn't remap indices 16+, use 24-bit truecolor
        set -l primary (_caelestia_read_color primary d2c5b4)
        set -l r (printf '%d' 0x(string sub -s 1 -l 2 $primary))
        set -l g (printf '%d' 0x(string sub -s 3 -l 2 $primary))
        set -l b (printf '%d' 0x(string sub -s 5 -l 2 $primary))
        printf '\e[38;2;%d;%d;%dm' $r $g $b
    else
        # External terminal: caelestia-shell remaps index 16 → primary via OSC 4
        echo -ne '\x1b[38;5;16m'
    end
    echo '        ___   __  __           ___   __'
    echo '       /   | / /_/ /___ ______/   | / /_____ _'
    echo '      / /| |/ __/ / __ `/ ___/ /| |/ __/ __ `/'
    echo '     / ___ / /_/ / /_/ (__  ) ___ / /_/ /_/ / '
    echo '    /_/  |_\__/_/\__,_/____/_/  |_\__/\__,_/  '
    set_color normal

    # ── Fastfetch ──────────────────────────────────────────────
    if set -q NVIM
        # Neovim's libvterm ignores OSC 4 for indices 16+, so 256-color
        # indices 16/17/18 (primary/secondary/tertiary) render as black.
        # Generate a temp config with 24-bit truecolor escapes instead.
        set -l primary (_caelestia_read_color primary d2c5b4)
        set -l secondary (_caelestia_read_color secondary cdc5bd)
        set -l tertiary (_caelestia_read_color tertiary c5c6cf)
        set -l base_cfg "$HOME/.config/fastfetch/config.jsonc"
        if not test -f "$base_cfg"
            set base_cfg "$HOME/.config/fastfetch/config.json"
        end
        set -l tmp (mktemp /tmp/fastfetch-nvim-XXXXXX.json)

        # Python builds the truecolor escapes and writes valid JSON
        python3 -c '
import json, sys, os

def hex_to_sgr(h):
    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    return "\x1b[38;2;%d;%d;%dm" % (r, g, b)

base_path = sys.argv[1]
if os.path.exists(base_path):
    with open(base_path) as f:
        cfg = json.load(f)
    cfg["display"]["constants"] = [
        "\x1b[37m",
        hex_to_sgr(sys.argv[2]),
        hex_to_sgr(sys.argv[3]),
        hex_to_sgr(sys.argv[4])
    ]
    with open(sys.argv[5], "w") as f:
        json.dump(cfg, f)
' "$base_cfg" "$primary" "$secondary" "$tertiary" "$tmp"

        fastfetch --key-padding-left 5 --config "$tmp"
        rm -f "$tmp"
    else
        fastfetch --key-padding-left 5
    end
end
