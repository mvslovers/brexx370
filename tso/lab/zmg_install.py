#!/usr/bin/env python3
"""tso/lab/zmg_install.py - install ZMG0001 on mbt's target, step by step.

Taken over from mvslovers/rekx370 tso/lab/zmg_install.py (main f574e90),
cut down to EXEC (ZMG0001 patches no TMP), without its rejectcheck (no
REJECT ... CHECK in SMP4: HMA2033), plus a check step.

    python3 tso/usermod.py --xmit    # build/tso/ZMG0001.xmit (needs xmit370)
    mbt run zmginstall -- upload      # upload the XMIT, RECEIVE USERMOD.ZMG0001
    mbt run zmginstall -- check       # ZMG0001-3, UY16532 in CDS
    mbt run zmginstall -- backup [SUFFIX]  # EXEC/EX
    mbt run zmginstall -- acceptptf   # back up AOST4, ACCEPT UY16532
    mbt run zmginstall -- restorecheck | restore | reject
    mbt run zmginstall -- receive     # member $INSTALL: assemble, REJECT,
                                      #   RECEIVE, APPLY CHECK
    mbt run zmginstall -- apply       # member ZMG01AP: assemble, APPLY
    mbt run zmginstall -- job MEMBER  # any job member of the library
    mbt run zmginstall -- verify

The jobs are submitted from the members of USERMOD.ZMG0001 on the target,
as the XMIT delivered them, with the job card of the target. YOUR. in a
job (the backup library of ZMG01BK and ZMG01RS) becomes the target's HLQ.

APPLY only, never ACCEPT (see the cover letter in tso/usermod/ZMG0001.mcs).
verify is the real test: a condition code says the job ran, not that the
right bytes landed. It compares the EXEC SMP built in SYS1.CMDLIB byte for
byte with the one tso/lmod_link.py testlib put into the test library,
which is the module tso/lab/exec_test.py testlib ran. Same decks and same
link-edit order, so the two must be identical.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, "scripts")
sys.path.insert(0, "tso")
from mvsmf import jobcard  # noqa: E402
import lmod_link as L  # noqa: E402

SYSMOD = "ZMG0001"
XMIT = Path("build/tso/ZMG0001.xmit")
PDS = "USERMOD.ZMG0001"
OUT = Path("build/tso/lab")


def submit(c, cfg, name, body, out, widths=True):
    jcl = jobcard(name, cfg.jobclass, cfg.msgclass,
                  f"{SYSMOD} INSTALL") + body
    long = [l for l in jcl.splitlines() if l.startswith("//") and len(l) > 71]
    if long and widths:
        raise SystemExit("long cards: %r" % long)
    r = c.submit_jcl(jcl, timeout=900)
    sp = r.spool or ""
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / out).write_text(sp)
    print(f"{r.jobid} {r.status} rc={r.rc}  spool: {OUT / out}")
    return sp


def smp(c, cfg, name, stmt, out, ptfin=None):
    extra = f"//HMASMP.SMPPTFIN DD DSN={ptfin},DISP=SHR\n" if ptfin else ""
    body = f"""
//SMP     EXEC SMPAPP
//HMASMP.CMDLIB  DD DSN=SYS1.CMDLIB,DISP=SHR
//HMASMP.AOST4   DD DSN=SYS1.AOST4,DISP=SHR
{extra}//HMASMP.SMPCNTL DD *
 {stmt}
/*
//
"""
    sp = submit(c, cfg, name, body, out)
    for line in sp.splitlines():
        if re.search(r"HMA\d{4}|^ZMG\d{4} |^MOD |IEW\d{3}[1-9]|IEF142I", line):
            print("  ", line.rstrip()[:120])
    return sp


LINKLIST = ("SYS1.CMDLIB",)


def extents(c):
    """Extent count of SYS1.CMDLIB, which is in the link list: a new
    extent stays invisible until the next IPL (ZMG0002 reinstall on
    MVSCE-LAB, JOB01330/01332)."""
    out = {}
    for ds in LINKLIST:
        r = [x for x in c.list_datasets(ds) if x.get("dsname") == ds][0]
        out[ds] = int(r["extx"])
        print(f"  {ds}: {r['extx']} extent(s), {r.get('used')}% used")
    return out


def backup(c, cfg, suffix="BACKUP"):
    bk = f"{cfg.hlq}.{SYSMOD}.{suffix}"
    if c.dataset_exists(bk):
        raise SystemExit(f"{bk} exists - refusing to overwrite a backup")
    body = f"""
//CMD      EXEC PGM=IEBCOPY,REGION=4096K
//SYSPRINT DD SYSOUT=*
//SYSUT3   DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSUT4   DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//CMD      DD DSN=SYS1.CMDLIB,DISP=SHR
//OUT      DD DSN={bk},DISP=(NEW,CATLG,DELETE),
//            UNIT=SYSDA,SPACE=(TRK,(10,5,5)),
//            DCB=(RECFM=U,BLKSIZE=19069,DSORG=PO)
//SYSIN    DD *
  COPY INDD=CMD,OUTDD=OUT
  SELECT MEMBER=(EXEC,EX)
/*
//
"""
    sp = submit(c, cfg, "ZMGBKUP", body, "zmg_backup.spool")
    for line in sp.splitlines():
        if "IEB154I" in line or "IEB147I" in line:
            print("  ", line.strip())


def member_cards(c, member):
    """The cards of a member of USERMOD.ZMG0001 as they are on the target."""
    raw = c.read_member_binary(PDS, member)
    if len(raw) % 80:
        raise SystemExit(f"{PDS}({member}): {len(raw)} bytes, not cards")
    text = raw.decode("cp037")
    return [text[i:i + 80].rstrip() + "\n" for i in range(0, len(text), 80)]


def member_job(c, cfg, member, name, out):
    """Submit a job member of USERMOD.ZMG0001. Its JCL cards are checked
    by tso/usermod.py; the target's job card replaces the one in the
    member."""
    cards = member_cards(c, member)
    if not cards[0].startswith("//ZMG01") or not cards[1].startswith("//  "):
        raise SystemExit(f"unexpected JOB card in {PDS}({member}): "
                         f"{cards[:2]!r}")
    body = "\n" + "".join(cards[2:]).replace("YOUR.", cfg.hlq + ".")
    sp = submit(c, cfg, name, body, out, widths=False)
    for line in sp.splitlines():
        if re.search(r"HMA\d{4}|^ZMG\d{4} |^MOD |IEF142I|IEW\d{3}[1-9]|"
                     r"NO STATEMENTS FLAGGED|HIGHEST SEVERITY", line):
            print("  ", line.rstrip()[:120])
    return sp


def upload(c, cfg):
    """Upload the XMIT and RECEIVE it as USERMOD.ZMG0001 (a lab: an old
    library of that name is replaced)."""
    if not XMIT.exists():
        raise SystemExit(f"{XMIT} missing: run python3 tso/usermod.py --xmit")
    stage = f"{cfg.hlq}.ZMG0001.XMIT"
    for dsn in (stage, PDS):
        if c.dataset_exists(dsn):
            c.delete_dataset(dsn)
    c.create_dataset(stage, "PS", "FB", 80, 3120, ["TRK", 10, 5], "SYSDA")
    c.upload_binary(stage, XMIT.read_bytes())
    body = f"""
//RECV     EXEC PGM=IKJEFT01,REGION=4096K
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
 RECEIVE INDSN('{stage}') -
   DATASET('{PDS}')
/*
//
"""
    sp = submit(c, cfg, "ZMGUPLD", body, "zmg_upload.spool")
    for line in sp.splitlines():
        if re.search(r"IEF142I|IKJ|RECEIVE|Receive|restored", line):
            print("  ", line.rstrip()[:110])
    print("  members:", c.list_members(PDS))


def check(c, cfg):
    """Before anything is received: is ZMG0001 free, is another of the
    three installed (they exclude each other), and is UY16532 there?
    RC 04 with no stanza means not found; a stanza is a hit."""
    body = """
//SMPL    EXEC SMPAPP
//SMPCNTL  DD  *
 LIST CDS SYSMOD(ZMG0001,ZMG0002,ZMG0003,UY16532) .
 LIST ACDS SYSMOD(ZMG0001,ZMG0002,ZMG0003) .
/*
//
"""
    sp = submit(c, cfg, "ZMGCHECK", body, "zmg_check.spool")
    for line in sp.splitlines():
        if re.search(r"^\s*(ZMG\d{4}|UY16532)|STATUS|DELBY|FMID|HMA\d{4}|"
                     r"IEF142I", line):
            print("  ", line.rstrip()[:110])


def verify(c, cfg):
    testlib = f"{cfg.hlq}.BREXX370.TSO.LOADLIB"
    body = f"""
//SMPL    EXEC SMPAPP
//SMPCNTL  DD  *
 LIST CDS SYSMOD({SYSMOD}) .
 LIST CDS MOD(IKJCT430,IKJCT437) .
 LIST CDS LMOD(EXEC) .
/*
//CMD      EXEC PGM=AMBLIST
//SYSPRINT DD SYSOUT=*
//SYSLIB   DD DSN=SYS1.CMDLIB,DISP=SHR
//SYSIN    DD *
 LISTLOAD OUTPUT=MODLIST,MEMBER=EXEC
/*
//TST      EXEC PGM=AMBLIST
//SYSPRINT DD SYSOUT=*
//SYSLIB   DD DSN={testlib},DISP=SHR
//SYSIN    DD *
 LISTLOAD OUTPUT=MODLIST,MEMBER=EXEC
/*
//
"""
    sp = submit(c, cfg, "ZMGVRFY", body, "zmg_verify.spool")
    for line in sp.splitlines():
        if re.search(r"^ZMG\d{4}|STATUS|RMID|LKED CONTROL|^\s+(ORDER|ALIAS|"
                     r"ENTRY|SETCODE|INCLUDE)|SYSTEM LIBRARY", line):
            print("  ", line.rstrip()[:110])
    mods = {}
    for p in sp.split("MEMBER NAME")[1:]:
        mods.setdefault(p.split()[0], []).append(p)
    bad = 0
    for name in ("EXEC",):
        if len(mods.get(name, [])) != 2:
            print(f"  {name}: {len(mods.get(name, []))} AMBLIST listing(s),"
                  " need the SMP-built and the tested one: is the test"
                  " library there (mbt run lmodlink -- testlib exec)?")
            bad += 1
            continue
        smp_built, tested = mods[name]
        a, b = L.text_image(smp_built), L.text_image(tested)
        diff = [o for o in set(a) | set(b) if a.get(o) != b.get(o)]
        print(f"  {name}: SMP-built {L.cesd(smp_built)}")
        print(f"  {name}: tested    {L.cesd(tested)}")
        print(f"  {name}: {len(a)} vs {len(b)} bytes, {len(diff)} differ")
        bad += bool(diff) or not a
    print("VERIFY", "FAILED" if bad else "OK")
    return 1 if bad else 0


def do_check(c, cfg):
    check(c, cfg)
    extents(c)
    return 0


def do_backup(c, cfg):
    backup(c, cfg, *(sys.argv[2:3] or ["BACKUP"]))
    return 0


def take_back(cmd):
    """Taking a level back out (to reinstall a rebuilt usermod under the
    same id on a test system): RESTORE relinks the affected load modules
    from the DLIB, REJECT then drops the SYSMOD so a new one of the same
    name can be received."""
    def run(c, cfg):
        verb = cmd.replace("check", "").upper()
        chk = " CHECK" if cmd.endswith("check") else ""
        smp(c, cfg, f"ZMG{verb[:3]}{'C' if chk else ''}",
            f"{verb} SELECT({SYSMOD}){chk} .", f"zmg_{cmd}.spool")
        return 0
    return run


def do_acceptptf(c, cfg):
    """RESTORE of ZMG0001 needs UY16532 accepted, and MVS/CE ships it
    applied only. ACCEPT rewrites SYS1.AOST4(IKJCT430,IKJCT431), so those
    two are copied first."""
    bk = f"{cfg.hlq}.AOST4.BACKUP"
    if c.dataset_exists(bk):
        raise SystemExit(f"{bk} exists - refusing to overwrite a backup")
    body = f"""
//CMD      EXEC PGM=IEBCOPY,REGION=4096K
//SYSPRINT DD SYSOUT=*
//SYSUT3   DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSUT4   DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//IN       DD DSN=SYS1.AOST4,DISP=SHR
//OUT      DD DSN={bk},DISP=(NEW,CATLG,DELETE),
//            UNIT=SYSDA,SPACE=(TRK,(10,5,5)),
//            DCB=(RECFM=U,BLKSIZE=19069,DSORG=PO)
//SYSIN    DD *
  COPY INDD=IN,OUTDD=OUT
  SELECT MEMBER=(IKJCT430,IKJCT431)
/*
//
"""
    sp = submit(c, cfg, "ZMGAOBK", body, "zmg_aostbackup.spool")
    for line in sp.splitlines():
        if "IEB154I" in line or "IEB147I" in line:
            print("  ", line.strip())
    smp(c, cfg, "ZMGACC", "ACCEPT SELECT(UY16532) .", "zmg_accept.spool")
    return 0


def do_upload(c, cfg):
    upload(c, cfg)
    return 0


def do_receive(c, cfg):
    member_job(c, cfg, "$INSTALL", "ZMGRECV", "zmg_receive.spool")
    members = [m if isinstance(m, str) else m.get("member")
               for m in c.list_members("SYS1.SMPPTS")]
    print(f"  SMPPTS({SYSMOD}) present: {SYSMOD in members}")
    return 0


def do_job(c, cfg):
    if len(sys.argv) < 3:
        raise SystemExit("job MEMBER (one of ZMG01CK, ZMG01BK, ZMG01RS, ...)")
    member = sys.argv[2]
    member_job(c, cfg, member, f"ZMGJ{member[-4:]}", f"zmg_{member}.spool")
    return 0


def do_apply(c, cfg):
    before = extents(c)
    member_job(c, cfg, "ZMG01AP", "ZMGAPPLY", "zmg_apply.spool")
    after = extents(c)
    grew = [ds for ds in LINKLIST if after[ds] != before[ds]]
    for ds in LINKLIST:
        print(f"  {ds}: {before[ds]} -> {after[ds]} extent(s)")
    for ds in grew:
        print(f"!!! {ds} grew a new extent. Link-list extents are fixed at "
              "IPL: a module written there fails LOAD with IEA703I 106-F "
              "until the next IPL.")
    return 1 if grew else 0


STEPS = {
    "upload": do_upload,
    "job": do_job,
    "check": do_check,
    "backup": do_backup,
    "acceptptf": do_acceptptf,
    "restorecheck": take_back("restorecheck"),
    "restore": take_back("restore"),
    "reject": take_back("reject"),
    "receive": do_receive,
    "apply": do_apply,
    "verify": verify,
}


def main():
    step = STEPS.get(sys.argv[1] if len(sys.argv) > 1 else "")
    if step is None:
        print(__doc__)
        return 2
    cfg, c = L.client("zmginstall")
    return step(c, cfg)


if __name__ == "__main__":
    sys.exit(main())
