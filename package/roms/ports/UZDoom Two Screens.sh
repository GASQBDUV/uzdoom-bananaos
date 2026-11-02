#!/bin/bash
# PORTMASTER: uzdoom.zip, UZDoom Two Screens.sh
# UZDoom with the status bar and the automap on the bottom panel (the real engine HUD, drawn by UZDoom itself).

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
controlfolder="/roms/ports/PortMaster"
[ -d "$XDG_DATA_HOME/PortMaster/" ] && controlfolder="$XDG_DATA_HOME/PortMaster"

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/UZDoom"
cd "$GAMEDIR"
chmod +x ./uzdoom 2>/dev/null

GAMEDIR="/$directory/ports/UZDoom"
DE="/$directory/ports/doomengines"
FILE=""
# add UZDoom as a third engine to Doom Engines (copies of what it changes are kept as *.bak-uzdoom)
[ -f "$GAMEDIR/integrate-doomengines.sh" ] && bash "$GAMEDIR/integrate-doomengines.sh" "$DE" > "$GAMEDIR/integrate.log" 2>&1
# the Doom Engines launcher (a Love2D menu) lists the .doom files with IWAD, mods, skill and map
if [ -f "$DE/love" ]; then
    (
        cd "$DE" || exit 0
        rm -f selected_game.txt
        export LD_LIBRARY_PATH="$DE/libs/lovelibs:$LD_LIBRARY_PATH"
        export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
        chmod +x ./love
        $GPTOKEYB "love" &
        ./love . > /dev/null 2>&1
        kill -9 $(pidof gptokeyb) 2>/dev/null
    )
    if [ -f "$DE/selected_game.txt" ]; then
        FILE=$(head -n 1 "$DE/selected_game.txt")
        rm -f "$DE/selected_game.txt"
        [ "$FILE" = "Exit" ] && exit 0
    fi
fi
exec "$GAMEDIR/uzdoom-start.sh" "$FILE"
