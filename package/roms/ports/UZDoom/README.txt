UZDoom with the status bar and the automap on the bottom screen. Start "UZDoom Two Screens" from the ports list.

Doom Engines (the PortMaster port) is included, with the Doom shareware WAD and Freedoom. Commercial IWADs (doom2.wad, doom.wad, ...) are not: put them in roms/ports/doomengines/iwads/ or in this folder's iwads/.

Buttons: roms/ports/UZDoom/uzdoom.gptk. Game controls: in the game's own menu (kept in config/uzdoom/uzdoom.ini).
Doom Engines integration: integrate-doomengines.sh (copies of changed files: *.bak-uzdoom; stop it with an empty file "no-doomengines-patch" here).
Settings: uzdoom-start.sh (resolution scale, how often the bottom screen is redrawn).
More: https://github.com/GASQBDUV/uzdoom-bananaos
