#!/usr/bin/env python3
"""Stage RXLIB and SAMPLIB for the SMP package, and check what goes in.

  mbt run libcheck                 # check only
  python3 scripts/stagelibs.py     # check, then write build/stage/<lib>/

mbt reads an element library from one directory and takes every regular
file in it as a member, so the files that must not become members
(README.md, names that belong to IBM) are left out here. The rules are
those of "mbt package" and xmit370, applied to the source files so that a
fault is found before the package step:

  - a line is at most 80 columns (a tab goes to the next multiple of 8,
    trailing blanks do not count)
  - no control character, nothing outside Latin-1, so every character has
    a CP037 equivalent
  - a member name is 1-8 characters of A-Z 0-9 $ # @, not starting with a
    digit
  - a name on the IBM list of scripts/smplibs.toml is not delivered
  - a name is delivered once per SYSMOD, across both libraries

build/stage/MANIFEST.tsv lists library, member, source file and line count;
the install check compares the installed libraries with it.
"""
import os
import re
import shutil
import sys
import tomllib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NAME_RE = re.compile(r"^[A-Z$#@][A-Z0-9$#@]{0,7}$")
STAGE = os.path.join(ROOT, "build", "stage")


def read_text(path):
    raw = open(path, "rb").read()
    try:
        return raw.decode("utf-8")
    except UnicodeDecodeError:
        return raw.decode("latin-1")


def check_lines(path, text):
    """Problems of one file, as (line, column, text)."""
    probs = []
    lines = text.split("\n")
    if lines and lines[-1] == "":
        lines.pop()
    for n, line in enumerate(lines, 1):
        col = width = 0
        for c in line:
            o = ord(c)
            if c == "\t":
                col = (col // 8 + 1) * 8
                continue
            col += 1
            if o < 0x20 or o == 0x7F or 0x80 <= o < 0xA0:
                probs.append((n, col, "control character U+%04X" % o))
            elif o > 0xFF:
                probs.append((n, col, "%r (U+%04X) has no CP037 equivalent" % (c, o)))
            else:
                try:
                    c.encode("cp037")
                except UnicodeEncodeError:
                    probs.append((n, col, "%r has no CP037 equivalent" % c))
            if c != " ":
                width = col
        if width > 80:
            probs.append((n, width, "line is %d columns, the limit is 80" % width))
    return probs, len(lines)


def main():
    stage = "--check-only" not in sys.argv[1:]
    cfg = tomllib.load(open(os.path.join(ROOT, "scripts", "smplibs.toml"), "rb"))
    ibm = {n.upper() for n in cfg["ibm"]["names"]}
    errors = []
    owner = {}
    members = []

    for lib in ("rxlib", "samples"):
        c = cfg[lib]
        d = os.path.join(ROOT, c["dir"])
        exclude = c.get("exclude", {})
        rename = c.get("rename", {})
        for key in list(exclude) + list(rename):
            if not os.path.isfile(os.path.join(d, key)):
                errors.append("%s: smplibs.toml names %s, which is not a file" % (lib, key))
        for f in sorted(os.listdir(d)):
            path = os.path.join(d, f)
            if not os.path.isfile(path) or f in exclude:
                continue
            name = rename.get(f, os.path.splitext(f)[0]).upper()
            if not NAME_RE.match(name):
                errors.append("%s/%s: %r is not an SMP member name" % (c["dir"], f, name))
            if name in ibm:
                errors.append("%s/%s: member name %s is an IBM name; rename or exclude it" % (c["dir"], f, name))
            if name in owner:
                errors.append("%s/%s: member name %s is also %s" % (c["dir"], f, name, owner[name]))
            owner[name] = "%s/%s" % (c["dir"], f)
            probs, nlines = check_lines(path, read_text(path))
            for ln, col, msg in probs:
                errors.append("%s/%s:%d:%d: %s" % (c["dir"], f, ln, col, msg))
            members.append((lib, name, path, f, nlines))

    if errors:
        print("\n".join(errors), file=sys.stderr)
        print("stagelibs: %d problem(s)" % len(errors), file=sys.stderr)
        return 1

    per = {}
    for lib, *_ in members:
        per[lib] = per.get(lib, 0) + 1
    print("stagelibs: %s -- all lines <= 80 columns, all CP037, no IBM or duplicate names"
          % ", ".join("%s %d members" % (k, v) for k, v in per.items()))
    if not stage:
        return 0

    shutil.rmtree(STAGE, ignore_errors=True)
    rows = []
    for lib, name, path, f, nlines in members:
        out = os.path.join(STAGE, lib)
        os.makedirs(out, exist_ok=True)
        shutil.copyfile(path, os.path.join(out, name + ".rexx"))
        rows.append("%s\t%s\t%s\t%d" % (lib, name, f, nlines))
    with open(os.path.join(STAGE, "MANIFEST.tsv"), "w") as m:
        m.write("\n".join(rows) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
