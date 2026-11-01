#!/usr/bin/env python3
"""tso/usermod.py - build the RECEIVE and APPLY jobs of the TSO integration usermod.

Taken over from mvslovers/rekx370 tso/usermod.py (main f574e90, then named
rekx370), changed to ship source instead of object decks.

    python3 tso/usermod.py [ZMG0001]      # build/tso/jcl/ZMG01RC.jcl, ZMG01AP.jcl

The usermod is delivered in source form, the way RAKF delivers $RAK0001.
Job ZMG01RC writes the MCS (IEBGENER), assembles each module with IFOX00 on
the target against SYS1.MACLIB and SYS1.AMODGEN, and lets IEBGENER write the
object plus the card IDENTIFY name('ZMG0001') as a member of a temporary
PDS (&&TXLIB, created once, DSORG=PO). Step REJ rejects ZMG0001 (RC 12 on
the first run), so the job can be repeated; step SMP RECEIVEs the MCS, takes
the text of each ++MOD from the TXLIB DD of the same name, and runs the
APPLY CHECK. Job ZMG01AP assembles again, because SMP takes the TXLIB text
at APPLY time and the temporary PDS is gone when ZMG01RC ends, and then
APPLYs. Nothing is uploaded, and no object deck is shipped.

Reads tso/usermod/<id>.mcs (the MCS text, cols 1-72). Every ++MOD(name)
statement must carry TXLIB(name); the jobs assemble tso/<name>.ASM into
that member. tso/build.sh exec proves that the committed reference decks
in tso/usermod/ are what the sources assemble to; the assembly on MVS is
checked by 'zmginstall verify' (SMP-built EXEC == tested EXEC).

Checks, since a wrong job fails on MVS only after a RECEIVE:
- every MCS line fits in 72 columns and is plain ASCII
- every source card is at most 80 columns, plain ASCII, and does not start
  with '//' or '/*' (JES would end the SYSIN data there) or '++'
- the MCS has no card starting with 'ZZ' (the end of its in-stream data)
- every ++MOD names its source in TXLIB(), and tso/<name>.ASM exists
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
//* SYS1.AMODGEN, STORE EACH OBJECT WITH AN IDENTIFY CARD AS A MEMBER
//* OF THE TEMPORARY LIBRARY &&TXLIB, AND LET SMP RECEIVE THE MCS AND
//* THE TXLIB MEMBERS.  NO DATA SET HAS TO BE UPLOADED OR RENAMED.
//* EACH ASSEMBLY MUST END WITH RC 0 ("NO STATEMENTS FLAGGED").  A
//* STEP THAT FAILS STOPS THE JOB BEFORE SMP.
//* STEP REJ REJECTS ZMG0001 FIRST, SO THE JOB CAN BE RUN AGAIN.  ITS
//* RC IS 12 (HMA2462) WHEN ZMG0001 WAS NOT RECEIVED - EXPECTED ON THE
//* FIRST RUN.  STEP SMP ENDS WITH THE RC OF RECEIVE AND APPLY CHECK.
//* THE APPLY CHECK CHANGES NOTHING.  ITS LISTING MUST SHOW IKJCT430
//* AND IKJCT437 AS "APPLIED" - NOT "NOT SEL" - BEFORE YOU RUN ZMG01AP.
//*
"""

HEAD_AP = """\
//ZMG01AP  JOB (BREXX),'ZMG0001',CLASS=A,
//         MSGCLASS=H,MSGLEVEL=(1,1)
//*
//* ZMG0001 (BREXX/370 TSO INTEGRATION) - ASSEMBLE AND APPLY
//*
//* RUN ZMG01BK AND ZMG01RC FIRST.  SMP TAKES THE TEXT OF A ++MOD FROM
//* ITS TXLIB DD AT APPLY TIME, AND THE TEMPORARY LIBRARY OF ZMG01RC
//* IS GONE WHEN THAT JOB ENDS.  SO THIS JOB ASSEMBLES IKJCT430 AND
//* IKJCT437 AGAIN, FROM THE SAME SOURCE, AND THEN APPLIES.  A FAILING
//* ASSEMBLY STOPS THE JOB BEFORE SMP.
//* NOTE THE EXTENTS OF SYS1.CMDLIB BEFORE AND COMPARE THEM AFTER: A
//* NEW EXTENT MEANS EXEC CANNOT BE LOADED (IEA703I 106-F) UNTIL THE
//* NEXT IPL.  OTHERWISE NO IPL IS NEEDED.
//* THE LISTING MUST SHOW "HMA2390 LINK SUCCESSFUL" FOR IKJCT430 AND
//* IKJCT437.  DO NOT ACCEPT ZMG0001.
//*
"""

MCS_STEP = """\
//MCS      EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//SYSUT1   DD DATA,DLM={delim}
{mcs}{delim}
//SYSUT2   DD DSN=&&SMPMCS,DISP=(NEW,PASS),UNIT=SYSALLDA,
//            SPACE=(CYL,3),
//            DCB=(DSORG=PS,RECFM=FB,LRECL=80,BLKSIZE=4080)
"""

ASM_STEP = """\
//{asm:<8} EXEC PGM=IFOX00,COND=(0,LT),
//            PARM='{parm}'
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD UNIT=SYSALLDA,SPACE=(CYL,10)
//SYSUT2   DD UNIT=SYSALLDA,SPACE=(CYL,10)
//SYSUT3   DD UNIT=SYSALLDA,SPACE=(CYL,10)
//SYSLIB   DD DSN=SYS1.MACLIB,DISP=SHR
//         DD DSN=SYS1.AMODGEN,DISP=SHR
//SYSGO    DD DSN=&&OBJ,UNIT=SYSALLDA,SPACE=(TRK,(15,15)),
//            DISP=(,PASS),
//            DCB=(DSORG=PS,RECFM=FB,LRECL=80,BLKSIZE=3200)
//SYSIN    DD *
{source}/*
"""

TXL_STEP = """\
//{txl:<8} EXEC PGM=IEBGENER,COND=(0,LT)
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&OBJ,DISP=(OLD,DELETE)
//         DD DDNAME=ADDREC
//SYSUT2   DD DSN=&&TXLIB({name}),{alloc}
//ADDREC   DD *
    IDENTIFY {name}('{sysmod}')
/*
"""

TXL_NEW = """UNIT=SYSALLDA,
//            SPACE=(TRK,(10,10,2)),DISP=(,PASS),
//            DCB=(DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=3200)"""
TXL_ADD = "DISP=(MOD,PASS)"

REJ = """\
//REJ      EXEC SMPAPP,COND=({cond})
//HMASMP.SMPCNTL  DD *
 REJECT S({sysmod}) .
/*
"""

SMP = """\
//SMP      EXEC SMPAPP,COND=({cond})
//HMASMP.CMDLIB   DD DSN=SYS1.CMDLIB,DISP=SHR
//HMASMP.AOST4    DD DSN=SYS1.AOST4,DISP=SHR
{txdd}{ptfin}//HMASMP.SMPCNTL  DD *
{cntl}/*
//
"""
SMP_RC = (" RECEIVE SELECT({sysmod}) .\n"
          " APPLY SELECT({sysmod}) CHECK .\n")
SMP_AP = " APPLY SELECT({sysmod}) .\n"
PTFIN = "//HMASMP.SMPPTFIN DD DSN=&&SMPMCS,DISP=(OLD,DELETE)\n"
TXDD_FIRST = "//HMASMP.{name:<8} DD DSN=&&TXLIB,DISP=(OLD,PASS)\n"
TXDD_NEXT = ("//HMASMP.{name:<8} DD DSN=*.{first},VOL=REF=*.{first},\n"
            "//            DISP=(OLD,PASS)\n")


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


def modules(lines):
    """The ++MOD names, in order; each must carry TXLIB(name)."""
    out = []
    for i, ln in enumerate(lines, 1):
        ascii_line(ln, f"MCS line {i}", 72)
        if ln[:2] == DELIM:
            raise SystemExit(f"MCS line {i} starts with {DELIM!r}, the end "
                             f"of its in-stream data: {ln!r}")
        m = re.match(r"\+\+MOD\((\w+)\)", ln)
        if m:
            name = m.group(1)
            if f"TXLIB({name})" not in ln:
                raise SystemExit(f"++MOD({name}) has no TXLIB({name}): {ln!r}")
            out.append(name)
    if not out:
        raise SystemExit("no ++MOD statement")
    return out


def build(sysmod, lines, kind):
    """Job text for kind "RC" (write MCS, assemble, REJECT, RECEIVE, APPLY
    CHECK) or "AP" (assemble, APPLY)."""
    check_statements(lines)
    mods = modules(lines)
    rc = kind == "RC"
    skeleton = [HEAD, MCS_STEP.format(delim=DELIM, mcs="")] if rc else [HEAD_AP]
    job = ([HEAD, MCS_STEP.format(
        delim=DELIM, mcs="".join(t + "\n" for t in lines))] if rc
        else [HEAD_AP])
    txdd = ""
    for n, name in enumerate(mods):
        cards = source(name)
        asm = ASM_STEP.format(asm=f"ASM{name[-3:]}", parm=PARM, source="")
        txl = TXL_STEP.format(txl=f"TXL{name[-3:]}", name=name, sysmod=sysmod,
                              alloc=TXL_ADD if n else TXL_NEW)
        skeleton += [asm, txl]
        job += [ASM_STEP.format(
                    asm=f"ASM{name[-3:]}", parm=PARM,
                    source="".join(c + "\n" for c in cards)), txl]
        txdd += (TXDD_NEXT.format(name=name, first=mods[0]) if n
                 else TXDD_FIRST.format(name=name))
        print(f"  {kind}: ++MOD({name}): {len(cards)} source cards")
    steps = (["MCS"] if rc else []) + [
        f"{p}{n[-3:]}" for n in mods for p in ("ASM", "TXL")]
    cond = ",\n//            ".join(f"(0,LT,{x})" for x in steps)
    tail = SMP.format(
        cond=cond, txdd=txdd, ptfin=PTFIN if rc else "",
        cntl=(SMP_RC if rc else SMP_AP).format(sysmod=sysmod))
    if rc:
        tail = REJ.format(sysmod=sysmod, cond=cond) + tail
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
    OUT.mkdir(parents=True, exist_ok=True)
    for kind in ("RC", "AP"):
        text = build(sysmod, lines, kind)
        target = OUT / f"ZMG01{kind}.jcl"
        target.write_text(text, encoding="ascii", newline="\n")
        print(f"wrote {target}: {len(text.splitlines())} cards")
    return 0


if __name__ == "__main__":
    sys.exit(main())
