#!/bin/bash
# Starts UZDoom with the second screen. Usage: uzdoom-start.sh [path to a .doom file from Doom Engines]
# Used by "UZDoom Two Screens.sh" and by the Doom Engines launcher when UZDoom is chosen there.

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
controlfolder="/roms/ports/PortMaster"
[ -d "$XDG_DATA_HOME/PortMaster/" ] && controlfolder="$XDG_DATA_HOME/PortMaster"

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

FILE="$1"
GAMEDIR="/$directory/ports/UZDoom"
DE="/$directory/ports/doomengines"
cd "$GAMEDIR"
chmod +x ./uzdoom 2>/dev/null

export LD_LIBRARY_PATH="$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export HOME="$GAMEDIR"
export XDG_DATA_HOME="$GAMEDIR/config"
export XDG_CONFIG_HOME="$GAMEDIR/config"

export BANANA_SECOND=1
export BANANA_BOTTOM_HZ=20   # how often the lower screen is redrawn per second

# run-port switched the bottom panel's backlight off for a one-panel port: this one uses both
. /usr/libexec/banana/one-panel
one_panel_dark top
one_panel_restore

IWAD=""; MODS=""; EXTRA=""
# find a file by its path relative to doomengines, whatever the capitalisation
resolve() {
    r="$DE/$1"
    [ -f "$r" ] && { echo "$r"; return; }
    d=$(dirname "$DE/$1"); b=$(basename "$1")
    f=$(find "$d" -maxdepth 1 -iname "$b" 2>/dev/null | head -n 1)
    [ -n "$f" ] && echo "$f"
}
if [ -n "$FILE" ]; then
    [ -f "$FILE" ] || FILE="$DE/$FILE"
    if [ -f "$FILE" ]; then
        while IFS== read -r key value; do
            value=$(echo "$value" | tr -d '\r')
            case "$key" in
                IWAD) IWAD=$(resolve "$value") ;;
                MOD)  m=$(resolve "$value"); [ -n "$m" ] && MODS="$MODS \"$m\"" ;;
                DIFF) EXTRA="$EXTRA +set skill $value" ;;
                MAP)  EXTRA="$EXTRA +map $value" ;;
            esac
        done < "$FILE"
    fi
fi

# nothing chosen (no launcher, or it did not give an IWAD): first IWAD found, your own Doom 2 / Doom before Freedoom
if [ -z "$IWAD" ]; then
    for d in "$GAMEDIR/iwads" "$DE/iwads"; do
        for f in doom2.wad DOOM2.WAD doom.wad DOOM.WAD freedoom2.wad FREEDOOM2.WAD freedoom1.wad FREEDOOM1.WAD DOOM19S.WAD; do
            [ -z "$IWAD" ] && [ -f "$d/$f" ] && IWAD="$d/$f"
        done
    done
fi

> "$GAMEDIR/log.txt"
$GPTOKEYB "uzdoom" -c "$GAMEDIR/uzdoom.gptk" &
# keep SDL's own game-controller handling out of the way (gptokeyb does the input); the small library for that comes with Doom Engines
if [ -f "$DE/libs/hacksdl.so" ]; then
    export LD_PRELOAD="$DE/libs/hacksdl.so"
    export HACKSDL_NO_GAMECONTROLLER=1
    export HACKSDL_VERBOSE=0
fi
# uzdoom.cfg gives the buttons their first meaning; after that the controls are yours: change them in the game menu
# (Options > Customize Controls), they are kept in config/uzdoom/uzdoom.ini and not overwritten here
EXEC=""
[ -f "$GAMEDIR/config/uzdoom/uzdoom.ini" ] || EXEC="-exec $GAMEDIR/uzdoom.cfg"
eval ./uzdoom -iwad \"\$IWAD\" ${MODS:+-file $MODS} $EXTRA $EXEC +gl_es 1 +vid_preferbackend 3 +cl_capfps 0 +vid_fps 0 +vid_scalefactor 0.85 +gl_texture_filter_anisotropic 2 >> "$GAMEDIR/log.txt" 2>&1
unset LD_PRELOAD
kill -9 $(pidof gptokeyb) 2>/dev/null
sync
printf "\033c" >> /dev/tty1
