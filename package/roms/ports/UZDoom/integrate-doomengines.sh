#!/bin/bash
# Makes Doom Engines (the PortMaster port with the Love2D menu) offer UZDoom as a third engine, and gives its one-stick
# button map the same layout as UZDoom. Safe to run again: it only changes files it recognises, and keeps a copy of each
# as <file>.bak-uzdoom. Create the file  UZDoom/no-doomengines-patch  to stop it from touching Doom Engines at all.
#   usage: integrate-doomengines.sh /roms/ports/doomengines
DE="${1%/}"
HERE="$(cd "$(dirname "$0")" && pwd)"
[ -d "$DE" ] || { echo "no Doom Engines at $DE, nothing to do"; exit 0; }
[ -f "$HERE/no-doomengines-patch" ] && { echo "disabled by no-doomengines-patch"; exit 0; }

LUA="$DE/main.lua"
SH="$DE/../Doom Engines.sh"
GP="$DE/configs/1.gptk"
bak() { [ -f "$1.bak-uzdoom" ] || cp "$1" "$1.bak-uzdoom"; }

# 1. the menu (main.lua): a third engine, and L/R step through the three
if [ -f "$LUA" ] && grep -q 'local radioOptions = { "crispydoom", "gzdoom" }' "$LUA"; then
    bak "$LUA"
    sed -i \
        -e 's/(radioContent == "2" and 2) or 1$/(radioContent == "2" and 2) or (radioContent == "3" and 3) or 1/' \
        -e 's/selectedRadioOption = 1  -- "Crispy Doom" selected/selectedRadioOption = math.max(1, selectedRadioOption - 1)/' \
        -e 's/selectedRadioOption = 2  -- "GZ Doom" selected/selectedRadioOption = math.min(3, selectedRadioOption + 1)/' \
        -e 's/{"Crispy Doom", "GZ Doom"}/{"Crispy Doom", "GZ Doom", "UZDoom"}/g' \
        -e 's/local radioOptions = { "crispydoom", "gzdoom" }/local radioOptions = { "crispydoom", "gzdoom", "uzdoom" }/' \
        -e 's/^local radioButtonXPercentage = 0\.60 /local radioButtonXPercentage = 0.42 /' \
        "$LUA"
    echo "main.lua: UZDoom added"
fi

# 2. the start script: hand over to UZDoom when it is chosen
if [ -f "$SH" ] && ! grep -q 'uzdoom-start.sh' "$SH" && grep -q '^# If Exit chosen from launcher, quit' "$SH"; then
    bak "$SH"
    sed -i '/^# If Exit chosen from launcher, quit/,/^fi$/{
/^fi$/a\
\
# UZDoom (second screen on the bottom panel) is started by its own script\
if [ "$ENGINE" = "uzdoom" ]; then\
    exec "/$directory/ports/UZDoom/uzdoom-start.sh" "$FILE"\
fi
}' "$SH"
    echo "Doom Engines.sh: UZDoom start added"
fi

# 3. buttons for the one-stick map (the RG DS has one stick): the D-pad does what the stick does, L1/R1 strafe, X fires, R2 automap
if [ -f "$GP" ] && grep -q '^l1 = 6$' "$GP" && grep -q '^x = tab$' "$GP"; then
    bak "$GP"
    sed -i -e 's/^left = a$/left = left/' -e 's/^right = d$/right = right/' -e 's/^l1 = 6$/l1 = a/' -e 's/^r1 = 7$/r1 = d/' \
           -e 's/^x = tab$/x = ctrl/' -e 's/^r2 = ctrl$/r2 = tab/' "$GP"
    echo "1.gptk: buttons changed"
fi
exit 0
