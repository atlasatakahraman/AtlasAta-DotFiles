function fish_greeting
    echo -ne '\x1b[38;5;16m'  # Set colour to primary
    echo '        ___   __  __           ___   __'
    echo '       /   | / /_/ /___ ______/   | / /_____ _'
    echo '      / /| |/ __/ / __ `/ ___/ /| |/ __/ __ `/'
    echo '     / ___ / /_/ / /_/ (__  ) ___ / /_/ /_/ / '
    echo '    /_/  |_\__/_/\__,_/____/_/  |_\__/\__,_/  '
    set_color normal
    fastfetch --key-padding-left 5
end
