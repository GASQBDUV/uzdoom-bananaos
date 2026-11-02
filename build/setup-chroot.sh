#!/bin/bash
# Creates a Debian 13 (trixie) build chroot with an aarch64 cross toolchain and the libraries UZDoom needs.
# Debian trixie has glibc 2.41, the same as BananaOS 0.5.0.1, so the binaries do not need anything newer than the device has.
# Run as root on a Debian/Ubuntu host (or in WSL):  sudo ./setup-chroot.sh [/opt/trixie]
set -e
CHROOT=${1:-/opt/trixie}
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y -qq debootstrap >/dev/null
[ -f "$CHROOT/etc/debian_version" ] || debootstrap --variant=minbase trixie "$CHROOT" http://deb.debian.org/debian
mount --bind /dev "$CHROOT/dev" 2>/dev/null || true
mount -t proc proc "$CHROOT/proc" 2>/dev/null || true

chroot "$CHROOT" sh -c '
export DEBIAN_FRONTEND=noninteractive
dpkg --add-architecture arm64
apt-get update -qq
# a failing post-install script of an arm64 package (it tries to run an arm64 binary) is harmless here
# native: cmake, ninja, a host compiler and libbz2 (UZDoom builds a few helper tools that run on the build machine)
# arm64: SDL2, libdrm, OpenAL, libvpx and the audio libraries
apt-get install -y -qq git make cmake ninja-build g++ libbz2-dev pkg-config file ca-certificates python3 crossbuild-essential-arm64 \
    libsdl2-dev:arm64 libdrm-dev:arm64 zlib1g-dev:arm64 libbz2-dev:arm64 libjpeg-dev:arm64 libglib2.0-dev:arm64 \
    libopenal-dev:arm64 libvpx-dev:arm64 libfluidsynth-dev:arm64 libmpg123-dev:arm64 libsndfile1-dev:arm64 \
    libwebp-dev:arm64 libgles-dev:arm64 libegl-dev:arm64 libgtk-3-dev:arm64 >/dev/null || true
ldd --version | head -1
aarch64-linux-gnu-gcc --version | head -1
cmake --version | head -1
'
mkdir -p "$CHROOT/work" "$CHROOT/out"
echo "chroot ready: $CHROOT"
