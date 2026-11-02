# Third-party software in the release zip

The zip contains the UZDoom program, its data files and seven shared libraries. Everything is built from, or taken unchanged from, the
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

The libraries the zip does **not** carry because bananaOS 0.5.0.1 already has them: SDL2, libdrm, OpenAL, ALSA, libstdc++, libgomp, libm,
zlib, bzip2, libpng/jpeg, Ogg and Vorbis, libEGL/GLESv2 (Mesa). `hacksdl.so`, which UZDoom uses when it is there, belongs to the Doom Engines
port and is not included.

No game data is included: bring your own IWAD (or Freedoom).
