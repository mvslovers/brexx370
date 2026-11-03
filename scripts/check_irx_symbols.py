#!/usr/bin/env python3
"""Compare the IRX* names of two builds of BREXX (#602).

The IRX* namespace belongs to REKX/370. A change that gives BREXX a new
IRX* module, alias, entry point or external symbol would collide with it
on a system that has both, so none may appear.

  scripts/check_irx_symbols.py BASE_BUILD_DIR NEW_BUILD_DIR

For each build dir (mbt's build/), the script collects every IRX* name from
  - the CESD of each load module (named SD/LR/LD/ER entries),
  - the member and alias names in the IEBCOPY unloads (*.iebcopy),
  - the ESD of the object decks (*.o), defined and referenced names.
It prints both sets and the difference. Exit status 1 when the new build
has an IRX* name the base build does not, 0 otherwise. Names that only
the base build has are reported, but are not an error.

Needs file370 from the cc370 toolchain on the PATH.
"""
import json
import re
import subprocess
import sys
from pathlib import Path

IRX = re.compile(r"^IRX", re.I)
MEMBER = re.compile(r"^\s+member\s+(\S+)\s")
SKIP_OBJ = re.compile(r"^tst", re.I)  # test modules are not shipped


def run(args):
    p = subprocess.run(["file370", *args], capture_output=True, text=True)
    if p.returncode not in (0,):
        sys.exit(f"file370 {' '.join(args)} failed ({p.returncode}): {p.stderr}")
    return p.stdout


def esd_names(path):
    out = json.loads(run(["--json", str(path)]))
    if isinstance(out, list):
        out = out[0]
    return {c["name"] for c in out.get("csects", [])}


def collect(build):
    build = Path(build)
    if not build.is_dir():
        sys.exit(f"not a directory: {build}")
    found = {}  # name -> where
    loads = [p for p in sorted(build.iterdir())
             if p.is_file() and p.suffix == "" and p.with_name(p.name + ".iebcopy").exists()]
    if not loads:
        sys.exit(f"no load modules in {build}: run mbt build --all first")
    for p in loads:
        for n in esd_names(p):
            if IRX.match(n):
                found.setdefault(n, set()).add(f"CESD of {p.name}")
    for p in sorted(build.glob("*.iebcopy")):
        for line in run(["-v", str(p)]).splitlines():
            m = MEMBER.match(line)
            if m and IRX.match(m.group(1)):
                found.setdefault(m.group(1), set()).add(f"member of {p.name}")
    for p in sorted(build.glob("*.o")):
        if SKIP_OBJ.match(p.name):
            continue
        for n in esd_names(p):
            if IRX.match(n):
                found.setdefault(n, set()).add(f"ESD of {p.name}")
    return found, len(loads)


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    base, nb = collect(sys.argv[1])
    new, nn = collect(sys.argv[2])
    print(f"base {sys.argv[1]}: {nb} load modules, {len(base)} IRX* names")
    print(f"new  {sys.argv[2]}: {nn} load modules, {len(new)} IRX* names")
    for label, d in (("base", base), ("new", new)):
        for n in sorted(d):
            print(f"  {label:<4} {n:<9} {'; '.join(sorted(d[n]))}")
    added = sorted(set(new) - set(base))
    gone = sorted(set(base) - set(new))
    for n in gone:
        print(f"only in base: {n}")
    for n in added:
        print(f"NEW IRX* NAME: {n}  ({'; '.join(sorted(new[n]))})")
    if added:
        print("FAIL: the new build has IRX* names the base build lacks")
        return 1
    print("PASS: no IRX* name in the new build that the base build lacks")
    return 0


if __name__ == "__main__":
    sys.exit(main())
