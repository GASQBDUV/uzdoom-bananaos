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

# 3. buttons for the one-stick map (the RG DS has one stick): L1/R1 strafe, X fires, R2 automap (turning: see 6 and 8)
if [ -f "$GP" ] && grep -q '^l1 = 6$' "$GP" && grep -q '^x = tab$' "$GP"; then
    bak "$GP"
    sed -i -e 's/^l1 = 6$/l1 = a/' -e 's/^r1 = 7$/r1 = d/' \
           -e 's/^x = tab$/x = ctrl/' -e 's/^r2 = ctrl$/r2 = tab/' "$GP"
    echo "1.gptk: buttons changed"
fi

# 4. B runs (Shift) instead of picking weapon 1 / crouching, in the one-stick map and in GZDoom (where Shift was a second fire button)
if [ -f "$GP" ] && grep -q '^b = 1$' "$GP"; then
    bak "$GP"
    sed -i 's/^b = 1$/b = leftshift/' "$GP"
    echo "1.gptk: B runs"
fi
for ini in "$DE"/configs/gzdoom/*.ini; do
    if [ -f "$ini" ] && grep -q '^Shift=+altattack$' "$ini"; then
        bak "$ini"
        sed -i 's/^Shift=+altattack$/Shift=+speed/' "$ini"
        echo "$(basename "$ini"): Shift runs"
    fi
done

# 5. Crispy Doom needs a few libraries bananaOS does not have (shipped in doomengines/libs/crispy)
if [ -f "$SH" ] && ! grep -q 'libs/crispy' "$SH" && grep -q '^# Run the game' "$SH"; then
    bak "$SH"
    awk '/^# Run the game/ { print "# Crispy Doom needs extra libs not provided by bananaOS"; print "case \"$ENGINE_BASE\" in crispy*) export LD_LIBRARY_PATH=\"$GAMEDIR/libs/crispy:$LD_LIBRARY_PATH\" ;; esac"; print "" } { print }' "$SH" > "$SH.tmp" && cat "$SH.tmp" > "$SH" && rm -f "$SH.tmp"
    echo "Doom Engines.sh: Crispy libraries added"
fi

# 6. D-pad left/right turn with the same keys as the stick (j and l, see 8). They must not be arrow keys: with arrows gptokeyb makes the
#    stick press left and right at once, and on bananaOS the stick's sideways movement comes through the D-pad's keys.
if [ -f "$GP" ] && grep -q -E '^(left = (left|a)|right = (right|d))$' "$GP"; then
    bak "$GP"
    sed -i -e 's/^left = \(left\|a\)$/left = j/' -e 's/^right = \(right\|d\)$/right = l/' "$GP"
    echo "1.gptk: D-pad turns with j and l"
fi
# 6b. Start opens the menu, Select is "y" (confirms the quit question; Esc also steps back in the menus)
if [ -f "$GP" ] && grep -q '^start = y$' "$GP" && grep -q '^back = esc$' "$GP"; then
    bak "$GP"
    sed -i -e 's/^start = y$/start = esc/' -e 's/^back = esc$/back = y/' "$GP"
    echo "1.gptk: Start is the menu"
fi

# 7. the stick walks with w / s (as in the Doom Engines map): GZDoom had no keys bound for them
for ini in "$DE"/configs/gzdoom/*.ini; do
    if [ -f "$ini" ] && grep -q '^UpArrow=+forward$' "$ini" && ! grep -q '^W=+forward$' "$ini"; then
        bak "$ini"
        sed -i -e '/^UpArrow=+forward$/a W=+forward' -e '/^DownArrow=+back$/a S=+back' "$ini"
        echo "$(basename "$ini"): stick walks (W, S)"
    fi
done

# 8. the stick gets its own turn keys, j and l (as in UZDoom). On the arrow keys gptokeyb makes the stick press left AND right at once.
if [ -f "$GP" ] && grep -q '^left_analog_left = left$' "$GP"; then
    bak "$GP"
    sed -i -e 's/^left_analog_left = left$/left_analog_left = j/' -e 's/^left_analog_right = right$/left_analog_right = l/' "$GP"
    echo "1.gptk: stick turns with j and l"
fi
for ini in "$DE"/configs/gzdoom/*.ini; do
    if [ -f "$ini" ] && grep -q '^LeftArrow=+left$' "$ini" && ! grep -q '^J=+left$' "$ini"; then
        bak "$ini"
        sed -i -e '/^LeftArrow=+left$/a J=+left' -e '/^RightArrow=+right$/a L=+right' "$ini"
        echo "$(basename "$ini"): stick turns (J, L)"
    fi
done
# Crispy Doom: scancode 36 is j, 38 is l (the arrow keys, 75 and 77, stay for nothing else: the D-pad strafes)
for cfg in "$DE"/configs/crispy-doom/*.cfg; do
    if [ -f "$cfg" ] && grep -q '^key_left  *75$' "$cfg" && grep -q '^key_right  *77$' "$cfg"; then
        bak "$cfg"
        sed -i -e 's/^key_left\( *\)75$/key_left\1 36/' -e 's/^key_right\( *\)77$/key_right\1 38/' "$cfg"
        echo "$(basename "$cfg"): turn keys j and l"
    fi
done
exit 0
