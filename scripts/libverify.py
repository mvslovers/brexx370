#!/usr/bin/env python3
"""Compare the installed RXLIB and SAMPLIB with the files they came from.

  mbt run libverify                          # BREXX.RXLIB, BREXX.SAMPLIB
  mbt run libverify -- --rxlib DSN --samplib DSN

An SMP install ends at return code 0 also when it installed nothing (a MAC
known to the CDS is NOT SEL at RC 0). So the libraries are read back and
compared with build/stage/MANIFEST.tsv, which scripts/stagelibs.py wrote:

  - the member lists are the same, nothing missing, nothing extra
  - every member has as many records as the file has lines
  - every record is the CP037 form of its line, padded to 80 columns

The records are read in binary (EBCDIC), so a wrong code page mapping shows
here. Exit code 0 only when all of it holds.
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mvsmf  # noqa: E402
from stagelibs import read_text  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STAGE = os.path.join(ROOT, "build", "stage")


def expected_records(path):
    lines = read_text(path).split("\n")
    if lines and lines[-1] == "":
        lines.pop()
    return [l.expandtabs(8).rstrip(" ").ljust(80).encode("cp037") for l in lines]


def verify(client, dsn, lib, rows):
    problems = []
    want = {name: src for (l, name, src, _n) in rows if l == lib}
    have = set(client.list_members(dsn))
    for m in sorted(set(want) - have):
        problems.append(f"{dsn}({m}): missing")
    for m in sorted(have - set(want)):
        problems.append(f"{dsn}({m}): not in the package")
    records = 0
    for m in sorted(set(want) & have):
        exp = expected_records(os.path.join(ROOT, lib if lib == "rxlib" else "samples", want[m]))
        raw = client.read_member_binary(dsn, m)
        if len(raw) % 80:
            problems.append(f"{dsn}({m}): {len(raw)} bytes is not a whole number of 80-byte records")
            continue
        got = [raw[i:i + 80] for i in range(0, len(raw), 80)]
        records += len(got)
        if len(got) != len(exp):
            problems.append(f"{dsn}({m}): {len(got)} records, the file has {len(exp)} lines")
            continue
        for n, (g, e) in enumerate(zip(got, exp), 1):
            if g.rstrip(b"\x40") != e.rstrip(b"\x40"):
                problems.append(f"{dsn}({m}) line {n}: {g.decode('cp037').rstrip()!r} is not {e.decode('cp037').rstrip()!r}")
                break
    print(f"{dsn}: {len(have)} members on MVS, {len(want)} in the package, {records} records compared")
    return problems


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rxlib", default="BREXX.RXLIB")
    ap.add_argument("--samplib", default="BREXX.SAMPLIB")
    a = ap.parse_args()
    rows = []
    with open(os.path.join(STAGE, "MANIFEST.tsv")) as f:
        for line in f:
            lib, name, src, n = line.rstrip("\n").split("\t")
            rows.append((lib, name, src, int(n)))
    client = mvsmf.Client(mvsmf.Target.from_env("libverify"))
    problems = verify(client, a.rxlib, "rxlib", rows) + verify(client, a.samplib, "samples", rows)
    for p in problems:
        print(p, file=sys.stderr)
    if problems:
        print(f"libverify: {len(problems)} difference(s)", file=sys.stderr)
        return 1
    print("libverify: the installed libraries match the files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
