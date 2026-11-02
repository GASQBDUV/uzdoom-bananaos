# Third-party software in the release zip

The zip contains the UZDoom program, its data files and seven shared libraries (and, since v1.1, Doom Engines, see below). Everything is built from, or taken unchanged from, the
sources below (Debian 13 "trixie" packages for aarch64). The only source that was modified is UZDoom, by
[patches/uzdoom-bananaos.patch](patches/uzdoom-bananaos.patch).

| Component | Version | Licence | Source |
|---|---|---|---|
| UZDoom (fork with second-screen support) | commit `9b79117526a427cccdbfaa8e6d449f53376ef114` + our patch | GPL-3.0 and asset licences (see its LICENSE) | <https://github.com/andreyvelsk/UZDoom/tree/9b79117526a427cccdbfaa8e6d449f53376ef114> |
| ZMusic (`libzmusic.so.1`) | commit `d3b730795784bff3f97571446101c57c1c6ac9bc` | GPL-3.0 / LGPL / BSD (see its `licenses/`) | <https://github.com/ZDoom/ZMusic/tree/d3b730795784bff3f97571446101c57c1c6ac9bc> |
| libvpx (`libvpx.so.9`) | 1.15.0-2.1+deb13u1 | BSD-3-Clause | <https://packages.debian.org/source/trixie/libvpx> |
| libsndfile (`libsndfile.so.1`) | 1.2.2-2+deb13u1 | LGPL-2.1-or-later | <https://packages.debian.org/source/trixie/libsndfile> |
| FLAC (`libFLAC.so.14`) | 1.5.0+ds-2 | BSD-3-Clause | <https://packages.debian.org/source/trixie/flac> |
| Opus (`libopus.so.0`) | 1.5.2-2 | BSD-3-Clause | <https://packages.debian.org/source/trixie/opus> |
| LAME (`libmp3lame.so.0`) | 3.100-6+b3 | LGPL-2.0-or-later | <https://packages.debian.org/source/trixie/lame> |
| libvorbisenc (`libvorbisenc.so.2`) | 1.3.7-3 | BSD-3-Clause | <https://packages.debian.org/source/trixie/libvorbis> |

The program data that is built into the `.pk3` files, `soundfonts/` and `fm_banks/` comes from the UZDoom source tree; their licences are in
`wadsrc_bm/static/license.md`, `wadsrc_extra/static/license.md`, `wadsrc_widepix/static/license.md` and `branding/` of that source.

`banana_bottom.cpp` and the patch are this repository's own code (GPL-3.0-or-later). UZDoom is GPL-3.0, so the zip as a whole is distributed
under the GPL. To get the exact sources: the commits above, the Debian source packages for the libraries (the version numbers are those of the build
chroot, see [build/setup-chroot.sh](build/setup-chroot.sh)), and this repository for the rest.

## Doom Engines (release zip v1.1 and later)

The zip also carries the PortMaster port **Doom Engines** as it is published: `Doom Engines.sh`, the Love2D launcher (`doomengines/love`,
`main.lua`, `launcher/`), `hacksdl.so` and its libraries, Crispy Doom 7.0.0, GZDoom 4.14.2 and 4.11.3, the `.doom` lists, the Doom shareware
WAD and Freedoom 1 and 2, with the licence files in `doomengines/license/` (Crispy Doom GPL-2.0, GZDoom GPL-3.0, Freedoom BSD-3-Clause).
Source: <https://github.com/PortsMaster/PortMaster-New/tree/efd7f977cf4fa9c442a08dd0d4d4ca0553de9a4e/ports/doomengines> (the commit the zip
was made from). The files are included unchanged; `integrate-doomengines.sh` changes three of them on the user's device, with backups.
The Love2D launcher, its scripts and `hacksdl.so` carry no licence text in the port itself; see the project page for who made them.

In addition the zip has `doomengines/libs/crispy/`, which is **not** part of the PortMaster port: compatibility libraries that Crispy Doom needs
on bananaOS 0.5.0.1 (`libfluidsynth.so.3`, `libSDL2_net-2.0.so.0`, `libsndfile.so.1`, `libFLAC.so.8`, taken from a working install, so the exact
package versions are not recorded here; fluidsynth and libsndfile are LGPL, SDL2_net zlib, FLAC BSD). `libjack.so.0`, `libpulse.so.0`,
`libpulse-simple.so.0` and `libpipewire-0.3.so.0` in that folder are copies of `libz.so.1` used as placeholders, so that the loader is satisfied;
Crispy Doom does not use them.

Also not part of the port: `doomengines/libs/lovelibs/libmodplug.so.1`, which the Love2D launcher needs on bananaOS 0.5.0.1 (libmodplug, public domain; taken from a working install).

The libraries the zip does **not** carry because bananaOS 0.5.0.1 already has them: SDL2, libdrm, OpenAL, ALSA, libstdc++, libgomp, libm,
zlib, bzip2, libpng/jpeg, Ogg and Vorbis, libEGL/GLESv2 (Mesa). UZDoom uses `hacksdl.so` from Doom Engines when it is there.

No commercial game data is included. The Doom shareware WAD and Freedoom come with Doom Engines; bring your own IWADs for the full games.
