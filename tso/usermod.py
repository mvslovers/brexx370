#!/usr/bin/env python3
"""tso/usermod.py - build the RECEIVE job of the TSO integration usermod.

Taken over from mvslovers/rekx370 tso/usermod.py (main f574e90, then named
rekx370), changed to ship source instead of object decks.

    python3 tso/usermod.py [ZMG0001]      # build/tso/jcl/ZMG01RC.jcl

The usermod is delivered in source form, the way RAKF delivers $RAK0001:
one job writes the MCS (IEBGENER), assembles each module with IFOX00 on the
target system against SYS1.MACLIB and SYS1.AMODGEN, and appends the object
deck to the MCS (SYSGO with DISP=MOD); SMP then RECEIVEs the result and
runs the APPLY CHECK. Nothing is uploaded, and no object deck is shipped.

Reads tso/usermod/<id>.mcs (the MCS text, cols 1-72). A line
"<<ASM name>>" stands for the deck of tso/<name>.ASM: the job assembles it
there, and the line must follow the ++MOD(name) statement of the same name.
tso/build.sh exec proves that the committed reference decks in tso/usermod/
are what the sources assemble to; the assembly on MVS is checked by
'zmginstall verify' (SMP-built EXEC == tested EXEC).

Checks, since a wrong job fails on MVS only after a RECEIVE:
- every MCS line fits in 72 columns and is plain ASCII
- every source card is at most 80 columns, plain ASCII, and does not start
  with '//' or '/*' (JES would end the SYSIN data there) or '++'
- the MCS has no card starting with 'ZZ' (the end of its in-stream data)
- every ++MOD is followed by the <<ASM>> line of the same name
- exactly one ++USERMOD and one ++VER (SMP refuses a second ++VER for the
  same SREL/FMID with HMA3482, and a text edit can duplicate the block)
- the JCL cards of the job itself end before column 72
"""
import re
import sys
from pathlib import Path

HERE = Path(__file__).parent
OUT = Path("build/tso/jcl")
DELIM = "ZZ"
PARM = "OBJECT,NODECK,NOTERM,XREF(SHORT),RENT"

HEAD = """\
//ZMG01RC  JOB (BREXX),'ZMG0001',CLASS=A,
//         MSGCLASS=H,MSGLEVEL=(1,1)
//*
//* ZMG0001 (BREXX/370 TSO INTEGRATION) - ASSEMBLE, RECEIVE, CHECK
//*
//* THE USERMOD COMES AS SOURCE.  THE STEPS WRITE ITS MCS, ASSEMBLE
//* IKJCT430 AND IKJCT437 WITH IFOX00 AGAINST SYS1.MACLIB AND
//* SYS1.AMODGEN, APPEND THE OBJECT DECKS TO THE MCS, AND LET SMP
//* RECEIVE IT.  NO DATA SET HAS TO BE UPLOADED OR RENAMED.
//* EACH ASSEMBLY MUST END WITH RC 0 ("NO STATEMENTS FLAGGED").  A
//* STEP THAT FAILS STOPS THE JOB BEFORE SMP.
//* THE APPLY CHECK CHANGES NOTHING.  ITS LISTING MUST SHOW IKJCT430
//* AND IKJCT437 AS "APPLIED" - NOT "NOT SEL" - BEFORE YOU RUN ZMG01AP.
//* ZMG0001 ALREADY RECEIVED (HMA3862, RC 8): REJECT IT FIRST.
//* A RESTORED ONE CAN BE RECEIVED AGAIN AS IT IS.
//*
"""

MCS_HEAD = """\
//{step:<8} EXEC PGM=IEBGENER{cond}
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//SYSUT1   DD DATA,DLM={delim}
"""

MCS_TAIL = """\
//SYSUT2   DD DSN=&&SMPMCS,DISP={disp},UNIT=SYSALLDA,
//            SPACE=(CYL,3),
//            DCB=(DSORG=PS,RECFM=FB,LRECL=80,BLKSIZE=4080)
"""

ASM_HEAD = """\
//{step:<8} EXEC PGM=IFOX00,COND=(0,LT),
//            PARM='{parm}'
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD UNIT=SYSALLDA,SPACE=(CYL,10)
//SYSUT2   DD UNIT=SYSALLDA,SPACE=(CYL,10)
//SYSUT3   DD UNIT=SYSALLDA,SPACE=(CYL,10)
//SYSLIB   DD DSN=SYS1.MACLIB,DISP=SHR
//         DD DSN=SYS1.AMODGEN,DISP=SHR
//SYSGO    DD DSN=&&SMPMCS,DISP=(MOD,PASS)
//SYSIN    DD *
"""

SMP = """\
//SMP      EXEC SMPAPP,COND=(0,LT)
//HMASMP.CMDLIB   DD DSN=SYS1.CMDLIB,DISP=SHR
//HMASMP.AOST4    DD DSN=SYS1.AOST4,DISP=SHR
//HMASMP.SMPPTFIN DD DSN=&&SMPMCS,DISP=(OLD,DELETE)
//HMASMP.SMPCNTL  DD *
 RECEIVE SELECT({sysmod}) .
 APPLY SELECT({sysmod}) CHECK .
/*
//
"""


def read_cards(path):
    """File text as cards; only a newline ends one (a form feed does not)."""
    cards = path.read_text(encoding="ascii").split("\n")
    if cards and cards[-1] == "":
        cards.pop()
    return cards


def ascii_line(text, what, limit):
    if len(text) > limit:
        raise SystemExit(f"{what}: longer than {limit} columns: {text!r}")
    if not text.isascii() or any(ord(ch) < 32 for ch in text):
        raise SystemExit(f"{what}: not plain ASCII: {text!r}")


def source(name):
    """The cards of tso/<name>.ASM, checked."""
    cards = read_cards(HERE / f"{name}.ASM")
    for i, c in enumerate(cards, 1):
        what = f"{name}.ASM card {i}"
        ascii_line(c, what, 80)
        if c[:2] in ("//", "/*", "++"):
            raise SystemExit(f"{what} starts with {c[:2]!r}: {c!r}")
    return cards


def check_statements(lines):
    for stmt in ("++USERMOD", "++VER"):
        n = sum(1 for ln in lines if ln.startswith(stmt))
        if n != 1:
            raise SystemExit(f"{n} {stmt} statements, expected exactly 1")


def segments(lines):
    """[(mcs_lines, asm_name or None)]: the MCS text up to each
    <<ASM name>> line, which must follow ++MOD(name), and the rest."""
    out, cur, pending = [], [], None
    for i, ln in enumerate(lines, 1):
        ascii_line(ln, f"MCS line {i}", 72)
        m = re.fullmatch(r"<<ASM (\w+)>>", ln.strip())
        if m:
            name = m.group(1)
            if pending != name:
                raise SystemExit(f"<<ASM {name}>> does not follow "
                                 f"++MOD({name})")
            out.append((cur, name))
            cur, pending = [], None
            continue
        mm = re.match(r"\+\+MOD\((\w+)\)", ln)
        if mm and pending:
            raise SystemExit(f"++MOD({pending}) has no <<ASM {pending}>>")
        if mm:
            pending = mm.group(1)
        if ln[:2] == DELIM:
            raise SystemExit(f"MCS line {i} starts with {DELIM!r}, the end "
                             f"of its in-stream data: {ln!r}")
        cur.append(ln)
    if pending:
        raise SystemExit(f"++MOD({pending}) has no <<ASM {pending}>>")
    if cur:
        out.append((cur, None))
    return out


def build(sysmod, lines):
    check_statements(lines)
    skeleton = [HEAD]
    job = [HEAD]
    for n, (text, name) in enumerate(segments(lines), 1):
        if text:
            head = MCS_HEAD.format(
                step=f"MCS{n}", cond="" if n == 1 else ",COND=(0,LT)",
                delim=DELIM)
            tail = MCS_TAIL.format(disp="(NEW,PASS)" if n == 1
                                   else "(MOD,PASS)")
            job += [head, "".join(t + "\n" for t in text), DELIM + "\n", tail]
            skeleton += [head, tail]
        if name:
            cards = source(name)
            head = ASM_HEAD.format(step=f"ASM{name[-3:]}", parm=PARM)
            job += [head, "".join(c + "\n" for c in cards), "/*\n"]
            skeleton.append(head)
            print(f"  ++MOD({name}): {len(cards)} source cards")
    tail = SMP.format(sysmod=sysmod)
    job.append(tail)
    skeleton.append(tail)
    long = [ln for ln in "".join(skeleton).splitlines()
            if ln.startswith("//") and len(ln) > 71]
    if long:
        raise SystemExit(f"JCL cards over column 71: {long!r}")
    return "".join(job)


def main():
    sysmod = sys.argv[1] if len(sys.argv) > 1 else "ZMG0001"
    if not re.fullmatch(r"ZMG\d{4}", sysmod):
        raise SystemExit(f"not a usermod id: {sysmod!r}")
    lines = read_cards(HERE / "usermod" / f"{sysmod}.mcs")
    text = build(sysmod, lines)
    OUT.mkdir(parents=True, exist_ok=True)
    target = OUT / "ZMG01RC.jcl"
    target.write_text(text, encoding="ascii", newline="\n")
    print(f"wrote {target}: {len(text.splitlines())} cards")
    return 0


if __name__ == "__main__":
    sys.exit(main())
