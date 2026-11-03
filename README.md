# UZDoom for bananaOS, with the status bar and automap on the second screen

[UZDoom](https://github.com/UZDoom/UZDoom) (the GZDoom-based Doom engine) for **bananaOS** on the dual-screen **Anbernic RG DS** handhelds.
The game fills the top screen. The **real** UZDoom status bar and automap, drawn by the engine itself, are on the bottom screen.
Unzip it on the card, start it from the ports list, pick a game. **Doom Engines (the PortMaster port) is included**, so nothing else is needed.

- **Top screen**: the game, full screen, without the status bar.
- **Bottom screen**: the engine's own status bar and the automap (not a re-drawing of it: mods with their own HUD work).
- **Game picker**: the [Doom Engines](https://portmaster.games/detail.html?name=doomengines) port is in the zip, and UZDoom becomes a
  third engine in its menu, next to Crispy Doom and GZ Doom, with `.doom` lists (IWAD, mods, skill, map).
- Music (ZMusic: soundfonts, FM, MIDI), sound and the OpenGL ES renderer work.

## Install

1. Download `UZDoom-bananaos-v1.1.1.zip` from the [latest release](../../releases/latest) (about 100 MB).
2. Unzip it at the **root of the data partition** (the card that holds `roms/`), so that `roms/ports/UZDoom Two Screens.sh`,
   `roms/ports/Doom Engines.sh` and the folders `roms/ports/UZDoom/` and `roms/ports/doomengines/` end up next to your other ports.
   **If you already have Doom Engines**, back up `roms/ports/doomengines/` and `Doom Engines.sh` first: the zip replaces the files
   that have the same names (your own WADs, mods and `.doom` files with other names are left alone).
3. The zip has the Doom shareware WAD and Freedoom, so you can play at once. For the full games, put your own IWADs
   (`doom2.wad`, `doom.wad`, ...) in `roms/ports/doomengines/iwads/`, or in `roms/ports/UZDoom/iwads/`. **No commercial game files are included.**
4. Start **UZDoom Two Screens** from the ports list. The first start adds UZDoom to the Doom Engines menu (see below). Pick a game and play.
   **Doom Engines** itself (Crispy Doom, GZ Doom) is also started from its own entry in the ports list.

Nothing else has to be installed: the zip carries the libraries bananaOS lacks, see [THIRD_PARTY.md](THIRD_PARTY.md). Without the Doom Engines
menu (if you delete it, or create `UZDoom/no-doomengines-patch`), UZDoom starts straight into the first IWAD it finds
(Doom II, Doom, then Freedoom).

**Tested on:** bananaOS 0.5.0.1, Anbernic RG DS Plus. Other versions or devices: not tested.

## Controls

The buttons are set in `roms/ports/UZDoom/uzdoom.gptk` (a [gptokeyb](https://portmaster.games/) file). The in-game controls
(Options > Customize Controls) are yours to change: they are kept in `roms/ports/UZDoom/config/uzdoom/uzdoom.ini` and not overwritten.

| Button | Does |
|---|---|
| Left stick, D-pad | walk forward / back, turn |
| **L1 / R1** | strafe left / right |
| **X** | fire |
| **L2** | next weapon |
| **R2** | automap (the one on the main screen) |
| **A** or **Y** | use / open, confirm in menus |
| **B** (hold) | run |
| **L3** (press the stick) | always run on/off |
| **Start** | menu |
| **Select** | back in menus |
| **L + R** | quit (bananaOS' own combination) |

## Doom Engines

Doom Engines is the PortMaster port by Slayer366, DDRSoul, Jeod and Speedrun ([the project](https://portmaster.games/detail.html?name=doomengines),
[source](https://github.com/PortsMaster/PortMaster-New/tree/main/ports/doomengines)); it is included unchanged, and the first time you start
**UZDoom Two Screens**, `roms/ports/UZDoom/integrate-doomengines.sh` adds UZDoom to it:

- a third engine in its menu (L / R step through Crispy Doom, GZ Doom, UZDoom),
- the hand-over to UZDoom in `Doom Engines.sh`,
- the one-stick button map (`doomengines/configs/1.gptk`): the stick and the D-pad both turn and walk, **L1 / R1** strafe
  (they used to pick weapons 6 and 7), **B** runs, **X** fires, **R2** is the automap, **Start** the menu. (They turn with the keys `j` and `l`, not the
  arrow keys: with arrows gptokeyb makes the stick press left and right at once. Crispy Doom and GZDoom are set to use those keys.)

It only changes files it recognises, runs again without doing anything twice, and keeps a copy of each file as `<name>.bak-uzdoom`.
To undo it, copy those back. To stop it from touching Doom Engines, create an empty file `roms/ports/UZDoom/no-doomengines-patch`.
The files of Doom Engines are in the release zip only, not in this repository.

## Performance

UZDoom is a big engine for this hardware. Expect somewhere around 45-60 frames per second in the original maps and less in big modern
maps. These choices keep it up:

- The top picture is drawn at **85 %** of the screen and scaled up (`+vid_scalefactor 0.85` in `roms/ports/UZDoom/uzdoom-start.sh`; 1 is
  full resolution and sharper but slower).
- The bottom screen is drawn in half resolution (a bit soft) and at most 20 times a second. The GPU draws straight into the panel's
  buffer; there is no read-back. Settings through environment variables in `uzdoom-start.sh`:
  `BANANA_BOTTOM_HZ` (default 20), `BANANA_BOTTOM_SCALE` (default 2; 1 is full resolution).
- Anisotropic filtering is 2.

How it works, and what was measured: [docs/HOW-IT-WORKS.md](docs/HOW-IT-WORKS.md).

## Building it yourself

See [build/](build/): a Debian 13 chroot with an aarch64 cross compiler, two scripts, and `package.py` for the zip.

```sh
sudo build/setup-chroot.sh /opt/trixie
sudo cp patches/uzdoom-bananaos.patch build/build-uzdoom.sh /opt/trixie/root/
sudo chroot /opt/trixie sh /root/build-uzdoom.sh      # -> /opt/trixie/out-uz
python3 build/package.py /opt/trixie/out-uz UZDoom-bananaos.zip
```

For the full release zip, add the Doom Engines port as a third argument: check out
`ports/doomengines` of [PortMaster-New](https://github.com/PortsMaster/PortMaster-New) at the commit in [THIRD_PARTY.md](THIRD_PARTY.md) with
`git config core.autocrlf false` (the scripts must keep LF), put the compatibility libraries in `doomengines/libs/crispy/`, and run
`python3 build/package.py /opt/trixie/out-uz UZDoom-bananaos.zip <that ports/doomengines folder>`.

The script fetches the UZDoom fork and ZMusic at fixed commits and applies [patches/uzdoom-bananaos.patch](patches/uzdoom-bananaos.patch).

## Known limits

- The "swap screens" function of the Android version (game on the bottom screen) is not supported.
- Vulkan is not built; the renderer is OpenGL ES.
- The bottom screen is not touch-controlled.
- The bottom picture is soft (half resolution) on purpose, to save frame rate.
- Only the one-stick button map of Doom Engines is changed (the RG DS has one stick).
- The controls in Crispy Doom and GZDoom (through Doom Engines) are rough: stick, D-pad and some buttons may not behave as in the table.
  Fix them in `roms/ports/doomengines/configs/1.gptk` (buttons) and the engines' own menus. UZDoom's controls are the ones that were tuned.
- Crispy Doom needs a few compatibility libraries on bananaOS (`doomengines/libs/crispy/`); jack, pulse and pipewire in it are empty
  placeholders so that it starts. Crispy Doom's music was not tested for this release.

## Credits

See [CREDITS.md](CREDITS.md). In short: the second-screen code in UZDoom is [andreyvelsk](https://github.com/andreyvelsk)'s, in his
[Android port](https://github.com/andreyvelsk/com.mobilerpgpack.phone) built on [sandstranger](https://github.com/sandstranger)'s
[port collection](https://github.com/sandstranger/com.mobilerpgpack.phone); UZDoom is by the [UZDoom team](https://github.com/UZDoom/UZDoom).
This repository replaces the Android surface with a direct drive of bananaOS' second panel.

## Licence

GPL-3.0-or-later for the code in this repository ([LICENSE](LICENSE)). UZDoom is GPL-3.0 with its own asset licences
([its LICENSE](https://github.com/andreyvelsk/UZDoom/blob/9b79117526a427cccdbfaa8e6d449f53376ef114/LICENSE)); the bundled libraries have their own
([THIRD_PARTY.md](THIRD_PARTY.md)). The complete corresponding source: the pinned commits named in [THIRD_PARTY.md](THIRD_PARTY.md)
plus this repository.
