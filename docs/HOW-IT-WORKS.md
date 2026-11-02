# How it works

## What the Android version does

[andreyvelsk's UZDoom branch](https://github.com/andreyvelsk/UZDoom/tree/android-mods) can move the status bar and the automap to a second
display. The engine builds a separate list of 2D drawing commands (a `F2DDrawer`) for the lower screen: the automap, the status bar and the
pain/pickup blend. On Android it draws that list into an EGL surface that belongs to the second display's `Surface`
(`ANativeWindow`). The top screen is then shown with `screenblocks 12` (full screen, no status bar).

bananaOS has no Android surfaces, but it does let a program take the second panel through DRM: the same way the ScummVM two-screen port
and the Lighthouse companion screen do it.

## What was replaced (patches/uzdoom-bananaos.patch)

- `src/common/platform/posix/sdl/banana_bottom.cpp` (new): finds the DRM device that SDL's KMSDRM driver already holds open
  (`/proc/self/fd`), finds the bottom panel (DSI connector 1) and a free CRTC, makes a dumb buffer and sets the CRTC on it.
  It can hand the buffer out as a dma-buf (`drmPrimeHandleToFD`).
- `gles_framebuffer.cpp`: `Render2DToSecondScreen` is implemented for non-Android builds. It draws the 2D list into an off-screen target,
  and then
  - **zero-copy (default):** imports the panel's dma-buf into OpenGL (`EGL_EXT_image_dma_buf_import`, an `EGLImage` bound to a texture) and
    blits into it, flipped (OpenGL's origin is at the bottom) and enlarged from half resolution. There is no read-back.
  - **fallback:** if that does not work on the device, `glReadPixels` into memory and a copy into the dumb buffer.
- `d_main.cpp`: a lower screen exists if `BANANA_SECOND` is set and the panel could be opened; the lower picture is built and drawn at most
  `BANANA_BOTTOM_HZ` times a second (building the status bar and the automap every frame cost about a quarter of the frame rate).
- `CMakeLists.txt` files: the new source file, libdrm, and a fix for newer CMake in ZWidget.

## What was measured (RG DS Plus, Mesa 25.0.7, OpenGL ES 3.1)

| | per update |
|---|---|
| read-back with `glReadPixels` (512 x 384) | about 14 ms, almost all of it waiting for the GPU |
| read-back through a pixel pack buffer (PBO) | about 105 ms (much worse on this driver; off by default, `BANANA_PBO=1`) |
| zero-copy draw and blit | about 3.5 ms, of which the engine builds the picture in about 1 ms |

On top of that the 3D renderer is the limit on this GPU: around 40-45 frames per second in a heavy scene at full resolution, better at 85 %
resolution. The CPU and GPU frequencies are already at their maximum on the device.

## The launcher

`UZDoom Two Screens.sh` first runs `integrate-doomengines.sh` (see the README), then starts the Doom Engines Love2D menu if it is installed,
and hands the chosen `.doom` file to `uzdoom-start.sh`. That script reads `IWAD`, `MOD`, `DIFF` and `MAP` from the file the same way
Doom Engines does, resolves the file names case-insensitively, and starts UZDoom with the OpenGL ES renderer (`+gl_es 1`).
Doom Engines itself calls `uzdoom-start.sh` when UZDoom is picked in its menu.

## Debugging

`BANANA_BOTTOM_DEBUG=1` prints timings every 100 updates to `roms/ports/UZDoom/log.txt`. `BANANA_NO_ZEROCOPY=1` forces the read-back path.
