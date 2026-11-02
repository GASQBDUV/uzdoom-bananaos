#!/bin/sh
# Builds UZDoom for BananaOS (aarch64). Runs INSIDE the chroot:
#   cp patches/uzdoom-bananaos.patch /opt/trixie/root/ && cp build/build-uzdoom.sh /opt/trixie/root/
#   chroot /opt/trixie sh /root/build-uzdoom.sh
# Result in $OUT (default /out-uz): uzdoom, the .pk3 files, soundfonts/, fm_banks/, lib/ (libzmusic and the audio libraries).
#
# What it builds: the UZDoom fork `andreyvelsk/UZDoom` (branch android-mods, the one with the second-screen code) at a fixed commit,
# plus ZMusic at a fixed commit, with patches/uzdoom-bananaos.patch on top (second screen through DRM instead of Android).
set -e
WORK=${WORK:-/work/uz}
OUT=${OUT:-/out-uz}
PATCH=${PATCH:-/root/uzdoom-bananaos.patch}
UZDOOM_COMMIT=9b79117526a427cccdbfaa8e6d449f53376ef114   # andreyvelsk/UZDoom, branch android-mods
ZMUSIC_COMMIT=d3b730795784bff3f97571446101c57c1c6ac9bc   # ZDoom/ZMusic
LIBDIR=/usr/lib/aarch64-linux-gnu
export PKG_CONFIG_LIBDIR=$LIBDIR/pkgconfig:/usr/share/pkgconfig

mkdir -p "$WORK" "$OUT/lib"
cd "$WORK"

fetch() {  # fetch <url> <dir> <commit>
    for i in 1 2 3 4; do
        rm -rf "$2"; mkdir "$2"; cd "$2"
        git init -q && git remote add origin "$1" && \
        git -c http.version=HTTP/1.1 fetch -q --depth 1 origin "$3" && git checkout -q FETCH_HEAD && { cd "$WORK"; return 0; }
        cd "$WORK"; sleep 3
    done
    echo "could not fetch $1"; exit 1
}
[ -f fork/.fetched ] || { fetch https://github.com/andreyvelsk/UZDoom.git fork "$UZDOOM_COMMIT"; touch fork/.fetched; }
[ -f zmusic/.fetched ] || { fetch https://github.com/ZDoom/ZMusic.git zmusic "$ZMUSIC_COMMIT"; touch zmusic/.fetched; }
[ -f fork/.patched ] || { (cd fork && git apply "$PATCH") && touch fork/.patched; }

cat > tc.cmake <<EOF
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)
set(CMAKE_FIND_ROOT_PATH /usr/aarch64-linux-gnu $WORK/sysroot)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
EOF

# 1. helper programs that run on the build machine (lemon, re2c, zipdir); UZDoom expects them as an "import" file
rm -rf tn; mkdir -p tn/src
cat > tn/src/CMakeLists.txt <<EOF
cmake_minimum_required(VERSION 3.16)
project(uztools C CXX)
set(F $WORK/fork)
macro(make_release_only)
endmacro()
macro(propagate_object_files)
endmacro()
find_package(BZip2 REQUIRED)
set(LZMA_INCLUDE_DIR \${F}/libraries/lzma/C)
set(BZIP2_LIBRARIES \${BZIP2_LIBRARY})
add_subdirectory(\${F}/libraries/miniz miniz)
add_subdirectory(\${F}/libraries/lzma lzma)
include_directories(SYSTEM \${BZIP2_INCLUDE_DIR} \${F}/libraries/lzma/C)
add_subdirectory(\${F}/tools/lemon lemon)
add_subdirectory(\${F}/tools/re2c re2c)
add_subdirectory(\${F}/tools/zipdir zipdir)
export(TARGETS lemon re2c zipdir FILE $WORK/tn/ImportExecutables.cmake)
EOF
cmake -S tn/src -B tn/b -G Ninja -DCMAKE_BUILD_TYPE=Release -DCROSS_EXPORTS= >/dev/null
ninja -C tn/b lemon re2c zipdir | tail -1

# 2. ZMusic (UZDoom's music library), as a shared library next to the program
cmake -S zmusic -B zmusic/b -G Ninja -DCMAKE_TOOLCHAIN_FILE="$WORK/tc.cmake" -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$WORK/sysroot" >/dev/null
ninja -C zmusic/b | tail -1
ninja -C zmusic/b install >/dev/null

# 3. UZDoom itself (OpenGL ES renderer, no Vulkan)
cmake -S fork -B ub -G Ninja -DCMAKE_TOOLCHAIN_FILE="$WORK/tc.cmake" -DCMAKE_BUILD_TYPE=Release \
    -DIMPORT_EXECUTABLES="$WORK/tn/ImportExecutables.cmake" -DHAVE_VULKAN=OFF -DHAVE_GLES2=ON -DNO_GTK=ON \
    -DZMusic_DIR="$WORK/sysroot/lib/cmake/ZMusic" -DCMAKE_PREFIX_PATH="$LIBDIR;$WORK/sysroot" \
    -DSDL2_INCLUDE_DIR=/usr/include/SDL2 -DSDL2_LIBRARY=$LIBDIR/libSDL2.so >/dev/null
ninja -C ub | tail -1

# 4. collect
cp ub/uzdoom "$OUT/uzdoom"
aarch64-linux-gnu-strip "$OUT/uzdoom"
cp ub/*.pk3 "$OUT/"
rm -rf "$OUT/soundfonts" "$OUT/fm_banks"
cp -r ub/soundfonts ub/fm_banks "$OUT/"
cp -L "$WORK/sysroot/lib/libzmusic.so.1" "$OUT/lib/"
for f in libvpx.so.9 libsndfile.so.1 libFLAC.so.14 libopus.so.0 libmp3lame.so.0 libvorbisenc.so.2; do cp -L "$LIBDIR/$f" "$OUT/lib/"; done
aarch64-linux-gnu-readelf -d "$OUT/uzdoom" | grep NEEDED
ls -la "$OUT" "$OUT/lib"
