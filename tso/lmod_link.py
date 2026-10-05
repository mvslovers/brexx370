#!/usr/bin/env python3
"""tso/lmod_link.py - relink the installed EXEC with ZMG0001's CSECTs.

Taken over from mvslovers/rexx370 tso/lmod_link.py (main f574e90), cut
down to EXEC: ZMG0001 patches no TMP. The test library is BREXX's own.
Run from the repository root after `tso/build.sh exec`:

    python3 tso/lmod_link.py reference exec [object]
    python3 tso/lmod_link.py testlib   exec

The patched TSO modules ship as an SMP usermod: object decks only, and SMP
link-edits them on MVS into the load module that is already installed.
Nothing else of that module is rebuilt from source, because the installed
one carries service a rebuild from the IBM sources would silently drop
(ZP60014 on IKJCT431, UY16532 on IKJCT430, UZ82014 on IKJEFTSC, ...).

reference performs that link-edit with the UNPATCHED deck -- assembled from
the mvs38src source -- into a TEST library, and compares the result with
the installed module byte for byte (AMBLIST text records). If they are
identical, the source is the installed level and a link with the patched
deck changes only what the patch changes. The optional object replaces the
default reference deck; linked with a patched deck the comparison MUST
show differences, or the reference run proved nothing.

Only the test library is written. The link control mirrors the LMOD entry
in the CDS (SMP LIST CDS LMOD(...), JOB01219 on MVSCE-LAB):

    exec      SYS1.CMDLIB(EXEC): ENTRY IKJCT430, ALIAS EX, RENT REUS

Run reference first on every stand: it proves that this control and the
mvs38src source reproduce that stand's installed EXEC.

testlib links the PATCHED decks (ours plus the new module) the same way
into {HLQ}.BREXX370.TSO.LOADLIB, a library outside the link list. A batch
TMP with that STEPLIB takes the EXEC command processor from there, ahead
of SYS1.CMDLIB, so the patch can be tested without touching SYS1 and
without affecting anyone else. (EXEC must keep its real name: the
IKJCT437 hook sits in IKJCT430's IMPLICIT path, which only a
TMP-dispatched EXEC reaches.)
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, "mbt/scripts")
from mbt.config import MbtConfig  # noqa: E402
from mbt.jcl import jobcard  # noqa: E402
from mbt.mvsmf import MvsMFClient  # noqa: E402

LMODS = {
    "exec": {
        "lib": "SYS1.CMDLIB",
        "base": "EXEC",
        "deck": "build/tso/IKJCT430.orig.o",
        "patched": ["build/tso/IKJCT430.o", "build/tso/IKJCT437.o"],
        "control": [
            "REPLACE IKJCT430,PARS",
            "INCLUDE SYSLIB({base})",
            "ORDER IKJCT431,IKJCT430,PARS,IKJCT432,IKJCT435",
            "ENTRY IKJCT430",
            "ALIAS EX",
            "NAME EXEC(R)",
        ],
        "member": "EXEC",
    },
}


def client():
    cfg = MbtConfig("project.toml")
    return cfg, MvsMFClient(host=cfg.mvs_host, port=cfg.mvs_port,
                            user=cfg.mvs_user, password=cfg.mvs_pass)


def upload_obj(c, dsn, path):
    data = Path(path).read_bytes()
    if len(data) % 80:
        raise SystemExit(f"{path}: not a deck of 80-byte cards")
    if c.dataset_exists(dsn):
        c.delete_dataset(dsn)
    c.create_dataset(dsn, "PS", "FB", 80, 3120, ["TRK", 5, 5], "SYSDA")
    c.upload_binary(dsn, data)


def text_image(listing):
    """Rebuild the module text from an AMBLIST LISTLOAD OUTPUT=MODLIST.
    Text lines are '  OOOOOO  xxxxxxxx xxxxxxxx ...' under a T E X T
    record; returns {offset: byte}."""
    img = {}
    in_text = False
    for line in listing.splitlines():
        if "T E X T" in line:
            in_text = True
            continue
        if "RECORD#" in line[:12]:
            in_text = False
            continue
        if not in_text:
            continue
        m = re.match(r"\s+([0-9A-F]{6})\s+((?:[0-9A-F]{2,8}\s*)+)", line)
        if not m:
            continue
        off = int(m.group(1), 16)
        data = bytes.fromhex("".join(m.group(2).split()))
        for i, b in enumerate(data):
            img[off + i] = b
    return img


def cesd(listing):
    return sorted(re.findall(
        r"^\s+\d+\s+(\S+)\s+[0-9A-F]{2}\(SD\)\s+([0-9A-F]{6})\s+\d+\s+\d+\s+([0-9A-F]+)",
        listing, re.M), key=lambda t: t[1])




def target(c, hlq, which, lm, testlib):
    """The library to link into, its SYSLMOD DD, and for testlib the
    patched deck to include."""
    if testlib:
        load = f"{hlq}.BREXX370.TSO.LOADLIB"
        objfile = Path("build/tso") / f"{which}-patched.o"
        objfile.write_bytes(b"".join(Path(p).read_bytes()
                                     for p in lm["patched"]))
        return load, f"//SYSLMOD  DD DSN={load},DISP=SHR", objfile
    load = f"{hlq}.BREXX370.LMOD.LOADREF"
    if c.dataset_exists(load):
        c.delete_dataset(load)
    return load, (f"//SYSLMOD  DD DSN={load},\n"
                  "//            DISP=(NEW,CATLG,DELETE),\n"
                  "//            UNIT=SYSDA,SPACE=(TRK,(10,5,5)),\n"
                  "//            DCB=(RECFM=U,BLKSIZE=19069,DSORG=PO)"), None


def compare(spool, which):
    """Save the spool, then compare the linked module's text with the
    installed one, byte by byte. 0 if identical."""
    Path("build/tso").mkdir(parents=True, exist_ok=True)
    Path(f"build/tso/{which}-reference.spool").write_text(spool)
    for line in spool.splitlines():
        if re.search(r"IEF142I|IEF272I|IEW\d{3}[1-9]", line):
            print("  ", line.strip()[:100])
    listings = [p for p in spool.split(" LISTLOAD OUTPUT=MODLIST")
                if "M O D U L E   S U M M A R Y" in p]
    if len(listings) < 2:
        print(f"could not find both AMBLIST listings; see "
              f"build/tso/{which}-reference.spool")
        return 1
    ours, theirs = listings[0], listings[1]
    print("CSECTs linked:   ", cesd(ours))
    print("CSECTs installed:", cesd(theirs))
    a, b = text_image(ours), text_image(theirs)
    diff = sorted(o for o in set(a) | set(b) if a.get(o) != b.get(o))
    print(f"text bytes: linked {len(a)}, installed {len(b)}, "
          f"differing {len(diff)}")
    if diff:
        print(f"differing range: +{diff[0]:06X}..+{diff[-1]:06X}")
    for o in diff[:40]:
        print(f"  +{o:06X}  linked {a.get(o, -1):02X}  "
              f"installed {b.get(o, -1):02X}")
    return 0 if not diff and a else 1


def reference(which, objfile=None, testlib=False):
    lm = LMODS[which]
    cfg, c = client()
    hlq = cfg.hlq
    obj = f"{hlq}.BREXX370.LMOD.OBJREF"
    load, lmoddd, patched = target(c, hlq, which, lm, testlib)
    objfile = patched or objfile
    upload_obj(c, obj, objfile or lm["deck"])
    control = "\n".join("  " + s.format(base=lm["base"])
                        for s in lm["control"])
    jcl = jobcard("BRXLMREF", cfg.jes_jobclass, cfg.jes_msgclass,
                  "LMOD REFERENCE") + f"""
//LKED     EXEC PGM=IEWL,REGION=4096K,
//            PARM='LIST,XREF,LET,RENT,REUS'
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSLIB   DD DSN={lm["lib"]},DISP=SHR
//OBJ      DD DSN={obj},DISP=SHR
{lmoddd}
//SYSLIN   DD *
  INCLUDE OBJ
{control}
/*
//OURS     EXEC PGM=AMBLIST,COND=(4,LT,LKED)
//SYSPRINT DD SYSOUT=*
//SYSLIB   DD DSN={load},DISP=SHR
//SYSIN    DD *
 LISTLOAD OUTPUT=MODLIST,MEMBER={lm["member"]}
/*
//THEIRS   EXEC PGM=AMBLIST
//SYSPRINT DD SYSOUT=*
//SYSLIB   DD DSN={lm["lib"]},DISP=SHR
//SYSIN    DD *
 LISTLOAD OUTPUT=MODLIST,MEMBER={lm["base"]}
/*
//
"""
    long = [l for l in jcl.splitlines() if l.startswith("//") and len(l) > 71]
    if long:
        print("JCL card(s) past column 71:", *long, sep="\n  ")
        return 1
    r = c.submit_jcl(jcl, timeout=300)
    print(f"job {r.jobname} {r.jobid}: {r.status} rc={r.rc}")
    return compare(r.spool or "", which)


if __name__ == "__main__":
    args = sys.argv[1:]
    if len(args) in (2, 3) and args[0] == "reference" and args[1] in LMODS:
        sys.exit(reference(*args[1:]))
    if len(args) == 2 and args[0] == "testlib" and args[1] in LMODS:
        reference(args[1], testlib=True)
        sys.exit(0)
    print(__doc__)
    sys.exit(2)
