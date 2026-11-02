# Credits

- **The [UZDoom team](https://github.com/UZDoom/UZDoom)** and everyone behind GZDoom, ZDoom and Doom: the engine. GPL-3.0, plus the asset
  licences listed in UZDoom's LICENSE. The games (IWADs) belong to their owners; none are included here.
- **[andreyvelsk](https://github.com/andreyvelsk)**: the second-screen support for UZDoom (the status bar and the automap drawn by the engine
  for a second display, the melt and damage effects on it), in
  [andreyvelsk/UZDoom](https://github.com/andreyvelsk/UZDoom) (branch `android-mods`) and
  [andreyvelsk/com.mobilerpgpack.phone](https://github.com/andreyvelsk/com.mobilerpgpack.phone) (GPL-3.0, Android port of UZDoom with second
  screen support). The engine side of that work is used here as it is; what this repository changes is in [patches/uzdoom-bananaos.patch](patches/uzdoom-bananaos.patch): the part that hands the picture to a screen is replaced, and the lower picture is only built a few times a second.
- **[sandstranger](https://github.com/sandstranger)**: [com.mobilerpgpack.phone](https://github.com/sandstranger/com.mobilerpgpack.phone), the Android
  port collection the above is built on, and the Android build of UZDoom.
- **[ZDoom/ZMusic](https://github.com/ZDoom/ZMusic)**: UZDoom's music library, built from source and shipped as a shared library.
- **Doom Engines for PortMaster**: many thanks to **Slayer366, DDRSoul, Jeod and Speedrun**, whose Love2D game picker, with Crispy Doom and
  GZDoom, makes this easy to use. Project: <https://portmaster.games/detail.html?name=doomengines>, source:
  <https://github.com/PortsMaster/PortMaster-New/tree/main/ports/doomengines>. It is included in the release zip, unchanged;
  `integrate-doomengines.sh` adds UZDoom to the user's copy. Its own thanks apply too: Andrew Hushult (launcher music), Cyril Deletre
  (HackSDL, the gamepad work), the PortMaster Discord testers, and the Crispy Doom and GZDoom teams. Nothing of it is in this repository.
- **bananaOS**: the operating system this is made for, and its two-panel display set-up.
- **[PortMaster](https://portmaster.games/)**: `gptokeyb`, which turns the gamepad into keyboard and mouse, and the launcher conventions used here.
- The bottom-panel drawing through DRM is the technique first used in the Lighthouse companion screen for bananaOS, and in the
  [ScummVM two-screen port](https://github.com/GASQBDUV/scummvm-bananaos) by the same author as this repository.
