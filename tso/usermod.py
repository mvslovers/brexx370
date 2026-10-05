#!/usr/bin/env python3
"""tso/usermod.py - build the SMP4 usermod stream for the TSO integration.

Taken over from mvslovers/rexx370 tso/usermod.py (main f574e90).

    tso/build.sh exec
    python3 tso/usermod.py [ZMG0001]

Reads tso/usermod/<id>.mcs (the MCS text, cols 1-72) and replaces every
line "<<DECK name>>" with the object deck build/tso/<name>.o. It writes
build/tso/<id>.smp, an EBCDIC FB80 stream for //SMPPTFIN.

The decks go into the stream as they are. SMP link-edits them into the
INSTALLED load modules at APPLY (KB MVS-SMP-0004), so nothing else of
EXEC is shipped or rebuilt.

Checks, since a wrong stream fails on MVS only after a RECEIVE:
- every MCS line fits in 72 columns and encodes to cp037
- every deck is whole 80-byte cards and ends in an END card
- no deck card starts with '++' (SMP would read it as an MCS statement)
- every ++MOD is followed by the deck of the same name
- exactly one ++USERMOD and one ++VER (SMP refuses a second ++VER for the
  same SREL/FMID with HMA3482, and a text edit can duplicate the block)
"""
import re
import sys
from pathlib import Path

HERE = Path(__file__).parent
OUT = Path("build/tso")
END = "END".encode("cp037")
PLUSPLUS = "++".encode("cp037")


def card(text):
    if len(text) > 72:
        raise SystemExit(f"MCS line longer than 72 columns: {text!r}")
    return text.ljust(80).encode("cp037")


def deck(name):
    data = (OUT / f"{name}.o").read_bytes()
    if len(data) % 80:
        raise SystemExit(f"{name}.o: not whole 80-byte cards")
    cards = [data[i:i + 80] for i in range(0, len(data), 80)]
    if cards[-1][1:4] != END:
        raise SystemExit(f"{name}.o: last card is not END")
    for i, c in enumerate(cards):
        if c[:2] == PLUSPLUS:
            raise SystemExit(f"{name}.o card {i + 1} starts with ++")
    return data, len(cards)


def check_statements(lines):
    for stmt in ("++USERMOD", "++VER"):
        n = sum(1 for ln in lines if ln.startswith(stmt))
        if n != 1:
            raise SystemExit(f"{n} {stmt} statements, expected exactly 1")


def assemble(lines):
    """The stream: MCS cards, each <<DECK name>> replaced by its deck,
    which must follow its own ++MOD."""
    out = bytearray()
    pending = None
    for ln in lines:
        m = re.fullmatch(r"<<DECK (\w+)>>", ln.strip())
        if m:
            name = m.group(1)
            if pending != name:
                raise SystemExit(f"deck {name} does not follow ++MOD({name})")
            data, n = deck(name)
            out += data
            print(f"  ++MOD({name}): {n} cards")
            pending = None
            continue
        mm = re.match(r"\+\+MOD\((\w+)\)", ln)
        if mm and pending:
            raise SystemExit(f"++MOD({pending}) has no deck")
        if mm:
            pending = mm.group(1)
        out += card(ln)
    if pending:
        raise SystemExit(f"++MOD({pending}) has no deck")
    return out


def main():
    sysmod = sys.argv[1] if len(sys.argv) > 1 else "ZMG0001"
    if not re.fullmatch(r"ZMG\d{4}", sysmod):
        raise SystemExit(f"not a usermod id: {sysmod!r}")
    lines = (HERE / "usermod" / f"{sysmod}.mcs").read_text().splitlines()
    check_statements(lines)
    out = assemble(lines)
    target = OUT / f"{sysmod}.smp"
    target.write_bytes(out)
    print(f"wrote {target}: {len(out) // 80} cards")
    return 0


if __name__ == "__main__":
    sys.exit(main())
