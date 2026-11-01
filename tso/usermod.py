#!/usr/bin/env python3
"""tso/usermod.py - build the library USERMOD.ZMG0001 of the TSO integration usermod.

Taken over from mvslovers/rekx370 tso/usermod.py (main f574e90, then named
rekx370), changed to ship source instead of object decks.

    python3 tso/usermod.py [ZMG0001] [--xmit]
        build/tso/pds/        the members, as host files
        build/tso/ZMG0001.zip the same members, for upload
        build/tso/ZMG0001.xmit  with --xmit: the library as a TSO TRANSMIT
                              file (xmit370 from the cc370 toolchain)

The usermod is delivered as one source library, USERMOD.ZMG0001, the way
RAKF delivers USERMOD.TRKF200 (TK5 convention):

    @CVRLET   cover letter and MCS (tso/usermod/<id>.mcs); the elements
              are named by TXLIB(...)
    IKJCT430  the sources (tso/<name>.ASM)
    IKJCT437
    $INSTALL  job: assemble both modules with IFOX00 against SYS1.MACLIB
              and SYS1.AMODGEN, store each object plus the card IDENTIFY
              name('ZMG0001') as a member of a temporary PDS (&&TXLIB,
              created once, DSORG=PO), REJECT, RECEIVE, APPLY CHECK
    ZMG01CK   job: check the prerequisites (tso/jcl)
    ZMG01BK   job: back up EXEC (tso/jcl)
    ZMG01AP   job: assemble again and APPLY (SMP takes the TXLIB text at
              APPLY time, and the temporary PDS is gone when $INSTALL ends)
    ZMG01RS   job: RESTORE, and copy the backup back (tso/jcl)

The jobs read the sources and the MCS from the library; nothing is inline.
No object deck is shipped.

Reads tso/usermod/<id>.mcs (the MCS text, cols 1-72). Every ++MOD(name)
statement must carry TXLIB(name); the jobs assemble tso/<name>.ASM into
that member. tso/build.sh exec proves that the committed reference decks
in tso/usermod/ are what the sources assemble to; the assembly on MVS is
checked by 'zmginstall verify' (SMP-built EXEC == tested EXEC).

Checks, since a wrong job fails on MVS only after a RECEIVE:
- every MCS line fits in 72 columns and is plain ASCII
- every source card is at most 80 columns, plain ASCII, and does not start
  with '//' or '/*' or '++' (the sources are read from a library, but a
  copy pasted into a job would end there)
- every ++MOD names its source in TXLIB(), and tso/<name>.ASM exists
- exactly one ++USERMOD and one ++VER (SMP refuses a second ++VER for the
  same SREL/FMID with HMA3482, and a text edit can duplicate the block)
- the JCL cards of every job end before column 72
"""
import re
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

HERE = Path(__file__).parent
BUILD = Path("build/tso")
PDS = "USERMOD.ZMG0001"
PARM = "OBJECT,NODECK,NOTERM,XREF(SHORT),RENT"
JOB_CARD = "//{name:<8} JOB (BREXX),'ZMG0001',CLASS=A,\n" \
           "//         MSGCLASS=H,MSGLEVEL=(1,1)\n"

HEAD_IN = """\
//*
//* ZMG0001 (BREXX/370 TSO INTEGRATION) - ASSEMBLE, RECEIVE, CHECK
//*
//* RUN ZMG01CK AND ZMG01BK FIRST.  THE USERMOD COMES AS SOURCE IN THE
//* LIBRARY {pds}.  THE STEPS ASSEMBLE IKJCT430 AND IKJCT437
//* WITH IFOX00 AGAINST SYS1.MACLIB AND SYS1.AMODGEN, STORE EACH
//* OBJECT WITH AN IDENTIFY CARD AS A MEMBER OF THE TEMPORARY LIBRARY
//* &&TXLIB, AND LET SMP RECEIVE THE MCS (MEMBER @CVRLET) AND THE
//* TXLIB MEMBERS.  NOTHING HAS TO BE RENAMED.
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
//*
//* ZMG0001 (BREXX/370 TSO INTEGRATION) - ASSEMBLE AND APPLY
//*
//* RUN ZMG01CK, ZMG01BK AND $INSTALL FIRST.  SMP TAKES THE TEXT OF A
//* ++MOD FROM ITS TXLIB DD AT APPLY TIME, AND THE TEMPORARY LIBRARY OF
//* $INSTALL IS GONE WHEN THAT JOB ENDS.  SO THIS JOB ASSEMBLES
//* IKJCT430 AND IKJCT437 AGAIN, FROM THE SAME SOURCE IN THE
//* LIBRARY {pds}, AND THEN APPLIES.  A FAILING
//* ASSEMBLY STOPS THE JOB BEFORE SMP.
//* NOTE THE EXTENTS OF SYS1.CMDLIB BEFORE AND COMPARE THEM AFTER: A
//* NEW EXTENT MEANS EXEC CANNOT BE LOADED (IEA703I 106-F) UNTIL THE
//* NEXT IPL.  OTHERWISE NO IPL IS NEEDED.
//* THE LISTING MUST SHOW "HMA2390 LINK SUCCESSFUL" FOR IKJCT430 AND
//* IKJCT437.  DO NOT ACCEPT ZMG0001.
//*
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
//SYSIN    DD DSN={pds}({name}),DISP=SHR
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
SMP_IN = (" RECEIVE SELECT({sysmod}) .\n"
          " APPLY SELECT({sysmod}) CHECK .\n")
SMP_AP = " APPLY SELECT({sysmod}) .\n"
PTFIN = "//HMASMP.SMPPTFIN DD DSN={pds}(@CVRLET),DISP=SHR\n"
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
        m = re.match(r"\+\+MOD\((\w+)\)", ln)
        if m:
            name = m.group(1)
            if f"TXLIB({name})" not in ln:
                raise SystemExit(f"++MOD({name}) has no TXLIB({name}): {ln!r}")
            out.append(name)
    if not out:
        raise SystemExit("no ++MOD statement")
    return out


def job(kind, sysmod, mods):
    """Job text for kind "IN" ($INSTALL: assemble, REJECT, RECEIVE, APPLY
    CHECK) or "AP" (ZMG01AP: assemble, APPLY)."""
    name = "ZMG01IN" if kind == "IN" else "ZMG01AP"
    text = [JOB_CARD.format(name=name),
            (HEAD_IN if kind == "IN" else HEAD_AP).format(pds=PDS)]
    txdd = ""
    for n, mod in enumerate(mods):
        text.append(ASM_STEP.format(asm=f"ASM{mod[-3:]}", parm=PARM,
                                    pds=PDS, name=mod))
        text.append(TXL_STEP.format(txl=f"TXL{mod[-3:]}", name=mod,
                                    sysmod=sysmod,
                                    alloc=TXL_ADD if n else TXL_NEW))
        txdd += (TXDD_NEXT.format(name=mod, first=mods[0]) if n
                 else TXDD_FIRST.format(name=mod))
    steps = [f"{p}{m[-3:]}" for m in mods for p in ("ASM", "TXL")]
    cond = ",\n//            ".join(f"(0,LT,{x})" for x in steps)
    if kind == "IN":
        text.append(REJ.format(sysmod=sysmod, cond=cond))
    text.append(SMP.format(
        cond=cond, txdd=txdd,
        ptfin=PTFIN.format(pds=PDS) if kind == "IN" else "",
        cntl=(SMP_IN if kind == "IN" else SMP_AP).format(sysmod=sysmod)))
    return "".join(text)


def check_job(member, text):
    for i, ln in enumerate(text.splitlines(), 1):
        ascii_line(ln, f"{member} line {i}", 80)
        if ln.startswith("//") and len(ln) > 71:
            raise SystemExit(f"{member} line {i}: JCL card over column 71: "
                             f"{ln!r}")


def members(sysmod, mcs):
    """[(member, host name, zip name, text)] in the order of the library."""
    mods = modules(mcs)
    check_statements(mcs)
    out = [("@CVRLET", "CVRLET", "@CVRLET.mcs",
            "".join(c + "\n" for c in mcs))]
    for mod in mods:
        cards = source(mod)
        out.append((mod, mod, f"{mod}.asm", "".join(c + "\n" for c in cards)))
        print(f"  {mod}: {len(cards)} source cards")
    out.append(("$INSTALL", "INSTALL", "$INSTALL.jcl",
                job("IN", sysmod, mods)))
    for m in ("ZMG01CK", "ZMG01BK"):
        out.append((m, m, f"{m}.jcl",
                    (HERE / "jcl" / f"{m}.jcl").read_text(encoding="ascii")))
    out.append(("ZMG01AP", "ZMG01AP", "ZMG01AP.jcl",
                job("AP", sysmod, mods)))
    out.append(("ZMG01RS", "ZMG01RS", "ZMG01RS.jcl",
                (HERE / "jcl" / "ZMG01RS.jcl").read_text(encoding="ascii")))
    for member, _, _, text in out:
        if member.startswith(("$", "ZMG")):
            check_job(member, text)
    return out


def write_zip(path, items):
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as z:
        for _, _, zname, text in items:
            z.writestr(zipfile.ZipInfo(zname, (2026, 1, 1, 0, 0, 0)), text,
                       zipfile.ZIP_DEFLATED)


def write_xmit(path, items, pds):
    exe = shutil.which("xmit370")
    if exe is None:
        raise SystemExit("xmit370 not on PATH (cc370 toolchain: "
                         "make xmit370/xmit370 in mvslovers/cc370)")
    cmd = [exe, "create", "-o", str(path), "--dsn", pds, "--lrecl", "80",
           "--blocksize", "3120", "--tabs", "0"]
    for member, host, _, _ in items:
        cmd += ["--member", f"{member}={BUILD / 'pds' / host}"]
    empty = BUILD / "nomembers"
    empty.mkdir(exist_ok=True)
    subprocess.run(cmd + [str(empty)], check=True)
    empty.rmdir()
    subprocess.run([exe, "list", str(path)], check=True)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    sysmod = args[0] if args else "ZMG0001"
    if not re.fullmatch(r"ZMG\d{4}", sysmod):
        raise SystemExit(f"not a usermod id: {sysmod!r}")
    mcs = read_cards(HERE / "usermod" / f"{sysmod}.mcs")
    items = members(sysmod, mcs)
    pds = BUILD / "pds"
    shutil.rmtree(pds, ignore_errors=True)
    pds.mkdir(parents=True)
    for _, host, _, text in items:
        (pds / host).write_text(text, encoding="ascii", newline="\n")
    write_zip(BUILD / f"{sysmod}.zip", items)
    print(f"wrote {pds}/ ({len(items)} members) and {BUILD}/{sysmod}.zip")
    if "--xmit" in sys.argv:
        write_xmit(BUILD / f"{sysmod}.xmit", items, PDS)
    return 0


if __name__ == "__main__":
    sys.exit(main())
