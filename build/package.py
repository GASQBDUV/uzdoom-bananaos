#!/usr/bin/env python3
"""Builds the install zip: package/ (launchers, button map, scripts) + the build output of build-uzdoom.sh.

    python3 package.py <dir with uzdoom, *.pk3, soundfonts/, fm_banks/, lib/> <output.zip> [<Doom Engines port dir>]

The optional third argument is the PortMaster port `ports/doomengines` (see THIRD_PARTY.md for the pinned commit): the folder
that holds `Doom Engines.sh` and `doomengines/`. It is added to the zip as it is; integrate-doomengines.sh adds UZDoom to it
the first time UZDoom Two Screens is started. Check it out with LF line endings (git config core.autocrlf false).

The zip is unpacked at the root of BananaOS' data partition (the one that holds roms/). Unix file modes are stored
explicitly, so the launchers and the binary stay executable after unzipping."""
import os
import sys
import zipfile

here = os.path.dirname(os.path.abspath(__file__))
package = os.path.join(here, "..", "package")
out_dir, target = sys.argv[1], sys.argv[2]
de_dir = sys.argv[3] if len(sys.argv) > 3 else None
EXEC_NAMES = ("love", "crispydoom", "crispyheretic", "crispyhexen", "crispystrife", "gzdoom")
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
    if de_dir:
        for root, _dirs, files in os.walk(de_dir):
            for name in sorted(files):
                src = os.path.join(root, name)
                rel = os.path.relpath(src, de_dir).replace(os.sep, "/")
                if rel.startswith(".git"):
                    continue
                if rel == "Doom Engines.sh":
                    arc = "roms/ports/Doom Engines.sh"
                elif rel == "README.md":
                    arc = "roms/ports/doomengines/doomengines.md"
                elif rel.startswith("doomengines/"):
                    arc = "roms/ports/" + rel
                else:  # cover.png, gameinfo.xml, port.json, screenshot.jpg: kept next to the port, as PortMaster installs them
                    arc = "roms/ports/doomengines/" + rel
                exe = name.endswith(".sh") or ".so" in name or name in EXEC_NAMES
                info = zipfile.ZipInfo(arc)
                info.create_system = 3
                info.external_attr = (0o100000 | (0o755 if exe else 0o644)) << 16
                info.compress_type = zipfile.ZIP_DEFLATED
                z.writestr(info, open(src, "rb").read())
print("wrote", target)
