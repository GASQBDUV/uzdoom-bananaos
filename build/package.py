#!/usr/bin/env python3
"""Builds the install zip: package/ (launchers, button map, scripts) + the build output of build-uzdoom.sh.

    python3 package.py <dir with uzdoom, *.pk3, soundfonts/, fm_banks/, lib/> <output.zip>

The zip is unpacked at the root of BananaOS' data partition (the one that holds roms/). Unix file modes are stored
explicitly, so the launchers and the binary stay executable after unzipping."""
import os
import sys
import zipfile

here = os.path.dirname(os.path.abspath(__file__))
package = os.path.join(here, "..", "package")
out_dir, target = sys.argv[1], sys.argv[2]
BINARY = (".so", ".zip", ".pk3", ".sf2", ".wopl", ".wopn")


def add(z, src, arcname, mode):
    info = zipfile.ZipInfo(arcname.replace(os.sep, "/"))
    info.create_system = 3  # Unix
    info.external_attr = (0o100000 | mode) << 16
    info.compress_type = zipfile.ZIP_DEFLATED
    data = open(src, "rb").read()
    if b"\r\n" in data and not (src.endswith(BINARY) or ".so." in src or src.endswith("uzdoom")):
        sys.exit("CRLF line endings in " + src)
    z.writestr(info, data)


with zipfile.ZipFile(target, "w") as z:
    for root, _dirs, files in os.walk(package):
        for name in sorted(files):
            src = os.path.join(root, name)
            rel = os.path.relpath(src, package)
            add(z, src, rel, 0o755 if name.endswith(".sh") else 0o644)
    base = "roms/ports/UZDoom/"
    add(z, os.path.join(out_dir, "uzdoom"), base + "uzdoom", 0o755)
    for name in sorted(os.listdir(out_dir)):
        path = os.path.join(out_dir, name)
        if name.endswith(".pk3"):
            add(z, path, base + name, 0o644)
        elif name in ("soundfonts", "fm_banks"):
            for f in sorted(os.listdir(path)):
                add(z, os.path.join(path, f), base + name + "/" + f, 0o644)
    lib = os.path.join(out_dir, "lib")
    for name in sorted(os.listdir(lib)):
        add(z, os.path.join(lib, name), base + "lib/" + name, 0o755)
print("wrote", target)
