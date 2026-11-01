#!/usr/bin/env python3
"""Install, check and remove the SMP package on a throwaway MVS system.

  mbt package                                  # dist/brexx370-*-dist.zip
  mbt run smpinstall -- install [--volume V] [--tgtvol V --dlbvol V]
                                               # upload, allocate, install
                                               # (TK5: --tgtvol TK5RES --dlbvol TK5DLB)
  mbt run smpinstall -- check                  # the inventory
  mbt run smpinstall -- remove                 # UCLIN DEL, both zones
  mbt run smpinstall -- removed                # the inventory afterwards

Run it against a container of your own (mvsce-target up), never a stand: it
allocates BREXX.* data sets and writes the SMP data bases.

A return code says the job ran, not that the work happened. "check" reads the
result back instead: the member list of every target and distribution
library, the records of RXLIB and SAMPLIB against the files, and the LIST
stanzas of the CDS and the ACDS (FMID, status, the owner of every element).
Each job's number and return code are printed, and its spool is written to
build/smp/.
"""
import argparse
import glob
import os
import re
import sys
import tomllib
import zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mvsmf  # noqa: E402
import libverify  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "build", "smp")


def read_fmid():
    """[smp] fmid when mbt.toml sets one (a throwaway id for a -dev build), else the release's."""
    with open(os.path.join(ROOT, "mbt.toml"), "rb") as f:
        return tomllib.load(f).get("smp", {}).get("fmid", "TBRX300")


FMID = read_fmid()
LOAD = ["BREXX", "REXX", "RX", "IRXVTOC", "IRXVSMIO", "IRXVSMTR"]
MODS = ["BREXX", "IRXVTOC", "IRXVSMIO", "IRXVSMTR"]
LMODS = ["BREXX", "IRXVTOC", "IRXVSMIO", "IRXVSMTR"]
XMITS = ["LOAD", "RXLIB", "RXSAMP", "CMDLIB", "JCL", "PROCLIB"]
# the receive targets of the install job, in the order of its steps
STAGE = {"LOAD": "BRXLOAD", "RXLIB": "TRXLIB", "RXSAMP": "TSAMPLIB",
         "CMDLIB": "CMDLIB", "JCL": "JCL", "PROCLIB": "PROCLIB"}
PLAIN = {"CMDLIB": "cmdlib", "JCL": "jcl", "PROCLIB": "proclib"}
# The SMP libraries as (data set, DD name) of the target and of the distribution
# library (#535): LINKLIB and SAMPLIB are DDs of the SMP procedures, so the
# target libraries of those two have DD names of their own.
SMPLIBS = {"load": (("BREXX.LINKLIB", "RXLINK"), ("BREXX.ARXLINK", "ARXLINK")),
           "rxlib": (("BREXX.RXLIB", "RXLIB"), ("BREXX.ARXLIB", "ARXLIB")),
           "samples": (("BREXX.SAMPLIB", "RXSAMP"), ("BREXX.ARXSAMP", "ARXSAMP"))}


def jobs_dir():
    os.makedirs(OUT, exist_ok=True)
    return OUT


def run(client, name, jcl, timeout=900):
    r = client.submit_jcl(jcl, timeout=timeout)
    path = os.path.join(jobs_dir(), f"{name}.{r.jobid}.txt")
    with open(path, "w") as f:
        f.write(r.spool or "")
    print(f"{name}: {r.jobid} {r.status} rc={r.rc}  spool: {os.path.relpath(path, ROOT)}")
    if r.spool_errors:
        print(f"  spool read errors: {r.spool_errors}")
    return r


def package():
    zips = sorted(glob.glob(os.path.join(ROOT, "dist", "brexx370-*-dist.zip")))
    if not zips:
        raise SystemExit("no dist/brexx370-*-dist.zip -- run 'mbt package' first")
    return zips[-1]


def cards(stmt, width=70):
    """One control statement as cards of at most `width` columns, broken after a comma."""
    out, cur = [], " "
    for tok in re.split(r"(?<=,)", stmt):
        if len(cur) + len(tok) > width and cur.strip():
            out.append(cur)
            cur = "   "
        cur += tok
    out.append(cur)
    return out


def smp_job(client, name, steps, timeout=900):
    """steps: [(stepname, [control statements])] in one job."""
    jcl = mvsmf.jobcard(name, client.cfg.jobclass, client.cfg.msgclass, "BREXX SMP") + "\n"
    for step, stmts in steps:
        jcl += f"//{step:<8} EXEC SMPAPP\n//SMPCNTL  DD  *\n"
        jcl += "".join(c + "\n" for s in stmts for c in cards(s)) + "/*\n"
    return run(client, name, jcl, timeout)


def cmd_install(client, cfg, a):
    zname = package()
    z = zipfile.ZipFile(zname)
    names = {os.path.basename(n): n for n in z.namelist()}

    def pick(suffix):
        hits = [b for b in names if b.endswith(suffix)]
        if len(hits) != 1:
            raise SystemExit(f"{zname}: {len(hits)} members end in {suffix}")
        return names[hits[0]]

    hlq = f"{cfg.hlq}.BRXINST"
    for x in XMITS:
        dsn = f"{hlq}.{x}"
        if client.dataset_exists(dsn):
            client.delete_dataset(dsn)
        client.create_dataset(dsn, "PS", "FB", 80, 3120, ["CYL", 5, 5],
                              volume=a.volume or None)
        data = z.read(pick(f"-{x.lower()}.xmit"))
        client.upload_binary(dsn, data)
        print(f"uploaded {dsn} ({len(data)} bytes)")
    alloc = z.read(pick("-alloc.jcl")).decode("utf-8")
    inst = z.read(pick("-inst.jcl")).decode("utf-8")
    for x in XMITS:
        inst = inst.replace(f"CHANGE.ME.{STAGE[x]}", f"{hlq}.{x}")
    if a.volume:
        inst = inst.replace("/* VOLUME('CHANGE.ME') */", f"VOLUME('{a.volume}')")
        alloc = alloc.replace("UNIT=SYSDA", f"UNIT=SYSDA,VOL=SER={a.volume}")
    else:
        inst = inst.replace("/* VOLUME('CHANGE.ME') */", "")
    if a.tgtvol or a.dlbvol:
        ovr = "".join(f",{k}={v}" for k, v in (("TGTVOL", a.tgtvol), ("DLBVOL", a.dlbvol)) if v)
        if "//ALLOC   EXEC SMPALLOC\n" not in alloc:
            raise SystemExit("alloc job: no 'EXEC SMPALLOC' statement to give the volumes to")
        alloc = alloc.replace("//ALLOC   EXEC SMPALLOC\n", f"//ALLOC   EXEC SMPALLOC{ovr}\n")
    cards = [l for l in inst.splitlines() if not l.startswith("//*")]
    left = sorted(set(re.findall(r"CHANGE\.ME\S*", "\n".join(cards))))
    if left:
        raise SystemExit(f"unreplaced placeholders: {left}")
    r1 = run(client, "BRXALLOC", alloc)
    r2 = run(client, "BRXINST", inst)
    if r1.rc != 0 or r2.rc != 0:
        print("install: a job ended above 0 -- read the spool; the verdict is 'check'")
        return 1
    return 0


def element_names():
    """Library -> member names, from the manifest stagelibs.py wrote."""
    rows = libverify_rows()
    out = {"rxlib": [], "samples": []}
    for lib, name, _src, _n in rows:
        out[lib].append(name)
    return out


def libverify_rows():
    rows = []
    with open(os.path.join(libverify.STAGE, "MANIFEST.tsv")) as f:
        for line in f:
            lib, name, src, n = line.rstrip("\n").split("\t")
            rows.append((lib, name, src, int(n)))
    return rows


def plain_members(d):
    """Members of a plain library: the base name of each file, upper case."""
    names = {}
    for f in os.listdir(os.path.join(ROOT, d)):
        names[os.path.splitext(f)[0].upper()] = f
    return names


def compare_members(problems, client, dsn, want):
    if not client.dataset_exists(dsn):
        problems.append(f"{dsn}: data set not found")
        print(f"{dsn}: not found")
        return
    have = set(client.list_members(dsn))
    want = set(want)
    for m in sorted(want - have):
        problems.append(f"{dsn}({m}): missing")
    for m in sorted(have - want):
        problems.append(f"{dsn}({m}): not expected")
    print(f"{dsn}: {len(have)} members on MVS, {len(want)} expected")


def lib_records(spool):
    """{(zone, entry kind): {name: libraries}} from the LIST output of SMP.

    "LIBRARIES = DISTLIB=ARXLIB    SYSLIB=RXLIB" reads "DISTLIB=ARXLIB SYSLIB=RXLIB",
    "SYSTEM LIBRARY = RXLINK" (a load module) reads "SYSTEM LIBRARY=RXLINK".
    """
    out, key, name = {}, None, None
    for line in spool.splitlines():
        m = re.match(r"(SMPCDS|SMPACDS)\s+(.+?)\s+ENTRIES\s*$", line)
        if m:
            key, name = (m.group(1)[3:], m.group(2)), None
            out.setdefault(key, {})
            continue
        m = re.match(r"(\S+)\s+LASTUPD\s+=", line)
        if m and key:
            name = m.group(1)
            continue
        m = re.match(r"\s+(LIBRARIES|SYSTEM LIBRARY)\s+=\s*(.*\S)", line)
        if m and key and name:
            val = " ".join(m.group(2).split())
            out[key][name] = val if m.group(1) == "LIBRARIES" else "SYSTEM LIBRARY=" + val
            name = None
    return out


def check_dd_names(problems, spool, wanted):
    """wanted: [(zone, kind, names, libraries)]; an entry under other libraries is a problem."""
    have = lib_records(spool)
    for zone, kind, names, libs in wanted:
        got = have.get((zone, kind), {})
        bad = sorted(n for n in names if got.get(n) != libs)
        print(f"LIST {zone} {kind}: {len(names) - len(bad)} of {len(names)} under {libs}")
        if bad:
            problems.append(f"LIST {zone} {kind}: {len(bad)} not under '{libs}' "
                            f"(e.g. {bad[0]}: '{got.get(bad[0], 'not listed')}')")


def list_statements(zone):
    """LIST of the function, its modules and (CDS only) its load modules."""
    st = [f"LIST {zone} SYSMOD({FMID}) .", f"LIST {zone} MOD({','.join(MODS)}) ."]
    if zone == "CDS":
        st.append(f"LIST {zone} LMOD({','.join(LMODS)}) .")
    return st


def cmd_check(client, cfg, a):
    problems = []
    rows = libverify_rows()
    names = element_names()
    compare_members(problems, client, SMPLIBS["load"][0][0], LOAD)
    compare_members(problems, client, SMPLIBS["load"][1][0], LOAD)
    for lib in ("rxlib", "samples"):
        problems += libverify.verify(client, SMPLIBS[lib][0][0], lib, rows)
        compare_members(problems, client, SMPLIBS[lib][1][0], names[lib])
    for x, d in PLAIN.items():
        want = plain_members(d)
        compare_members(problems, client, f"BREXX.{x}", want)
    # nothing of ours may have landed in an IBM library
    ours = set(LOAD) | set(names["rxlib"]) | set(names["samples"])
    for dsn in ("SYS1.LINKLIB", "SYS1.SAMPLIB", "SYS1.ASAMPLIB"):
        if client.dataset_exists(dsn):
            have = set(client.list_members(dsn))
            hit = sorted(ours & have)
            print(f"{dsn}: {len(have)} members, {len(hit)} of our names")
            if hit:
                problems.append(f"{dsn}: holds {len(hit)} of our names ({', '.join(hit[:5])} ...)")
    # the LIST stanzas
    mac = names["rxlib"] + names["samples"]
    chunks = [mac[i:i + 20] for i in range(0, len(mac), 20)]
    stmts = []
    for z in ("CDS", "ACDS"):
        stmts += list_statements(z)
    r = smp_job(client, "BRXLIST", [("LIST", stmts)])
    sp = r.spool or ""
    (_, ddl), (_, ddd) = SMPLIBS["load"]
    wanted = [(z, "MODULE", MODS, f"DISTLIB={ddd}") for z in ("CDS", "ACDS")]
    wanted.append(("CDS", "LOAD MODULE", LMODS, f"SYSTEM LIBRARY={ddl}"))
    check_dd_names(problems, sp, wanted)
    for z in ("CDS", "ACDS"):
        sec = sp.split(f"LIST {z} SYSMOD({FMID}) .", 1)[-1]
        m = re.search(rf"{FMID}\s+TYPE\s+= FUNCTION\s+STATUS\s+=([^\n]*)", sec[:800])
        status = m.group(1).split() if m else []
        print(f"LIST {z} SYSMOD({FMID}): {'FUNCTION' if m else 'not found'} status {' '.join(status)}")
        if not m or not {"REC", "APP", "ACC"} <= set(status):
            problems.append(f"LIST {z} SYSMOD({FMID}): not a FUNCTION with REC APP ACC")
    for z in ("CDS", "ACDS"):
        stmts = [f"LIST {z} MAC({','.join(c)}) ." for c in chunks]
        rr = smp_job(client, f"BRXMAC{z[0]}{z[-1]}", [("LIST", stmts)])
        s = rr.spool or ""
        owned = len(re.findall(rf"FMID\s+= {FMID}", s))
        nf = "NOT FOUND" in s
        wanted = []
        for lib in ("rxlib", "samples"):
            (_, ddt), (_, ddd) = SMPLIBS[lib]
            wanted.append((z, "MACRO", names[lib],
                           f"DISTLIB={ddd}" + (f" SYSLIB={ddt}" if z == "CDS" else "")))
        check_dd_names(problems, s, wanted)
        print(f"LIST {z} MAC: {owned} entries with FMID {FMID}, {len(mac)} expected")
        if owned != len(mac) or nf:
            problems.append(f"LIST {z} MAC: {owned} owned by {FMID} of {len(mac)}"
                            + (", some not found" if nf else ""))
    for p in problems:
        print("PROBLEM:", p, file=sys.stderr)
    print(f"check: {len(problems)} problem(s)")
    return 1 if problems else 0


def removal_blocks(zone, names):
    """UCLIN blocks that take the function out of one zone.

    A statement that names a missing entry makes its block RC 08 and the
    statements behind it are ignored, so each block ends in ENDUCL and a
    RESETRC, and the entries come in the order SMP can follow: the SYSMOD's
    references to its modules, the modules, the load modules (CDS only), the
    macros, the SYSMOD itself.
    """
    mods = [f"DEL SYSMOD({FMID}) MOD({m}) ." for m in MODS]
    mods += [f"DEL MOD({m}) ." for m in MODS]
    if zone == "CDS":
        mods += [f"DEL LMOD({m}) ." for m in LMODS]
    return [mods, [f"DEL MAC({n}) ." for n in names], [f"DEL SYSMOD({FMID}) ."]]


def cmd_remove(client, cfg, a):
    names = element_names()
    mac = names["rxlib"] + names["samples"]
    steps = []
    for z in ("CDS", "ACDS"):
        stmts = []
        for blk in removal_blocks(z, mac):
            stmts += [f"UCLIN {z} ."] + blk + ["ENDUCL .", "RESETRC ."]
        steps.append((f"UCL{z}", stmts))
    r = smp_job(client, "BRXUCL", steps, timeout=3600)
    sp = r.spool or ""
    bad = [l for l in sp.splitlines() if l.startswith("HMA") and " ** " in l]
    print(f"remove: {len(bad)} message(s) with **")
    for l in bad[:10]:
        print("  ", l[:110])
    return 0 if r.rc <= 4 and not bad else 1


def cmd_removed(client, cfg, a):
    """After the removal every name must be reported "not found" and none listed."""
    problems = []
    names = element_names()
    mac = names["rxlib"] + names["samples"]
    stmts = []
    for z in ("CDS", "ACDS"):
        stmts += list_statements(z)
        stmts += [f"LIST {z} MAC({','.join(mac[i:i + 20])}) ." for i in range(0, len(mac), 20)]
    r = smp_job(client, "BRXGONE", [("RESETRC", ["RESETRC ."]), ("LIST", stmts)])
    sp = r.spool or ""
    want = {"SMPCDS": {"SYSMOD": {FMID}, "MODULE": set(MODS), "LMOD": set(LMODS), "MACRO": set(mac)},
            "SMPACDS": {"SYSMOD": {FMID}, "MODULE": set(MODS), "MACRO": set(mac)}}
    got = {z: {t: set() for t in w} for z, w in want.items()}
    zone = None
    for line in sp.splitlines():
        m = re.match(r"LIST\s+SELECT SUMMARY REPORT FOR (\w+)", line)
        if m:
            zone = m.group(1)
            continue
        m = re.match(r" (SYSMOD|MODULE|LMOD|MACRO)\s+(\S+)\s*$", line)
        if m and zone in got and m.group(1) in got[zone]:
            got[zone][m.group(1)].add(m.group(2))
    for z, w in want.items():
        for t, ns in w.items():
            print(f"{z} {t}: {len(got[z][t])} of {len(ns)} reported not found")
            if got[z][t] != ns:
                problems.append(f"{z} {t}: {len(ns - got[z][t])} still present or not listed")
    if re.search(r"LASTUPD|FMID\s+= " + FMID + r"|TYPE\s+= FUNCTION", sp):
        problems.append("a stanza of " + FMID + " is still listed")
    for p in problems:
        print("PROBLEM:", p, file=sys.stderr)
    print(f"removed: {len(problems)} problem(s)")
    return 1 if problems else 0


def cmd_dirs(client, cfg, a):
    """Directory occupancy of the BREXX libraries (IEHLIST LISTPDS)."""
    jcl = mvsmf.jobcard("BRXDIR", cfg.jobclass, cfg.msgclass, "BREXX DIR") + "\n"
    jcl += "//S EXEC PGM=IEHLIST\n//SYSPRINT DD SYSOUT=*\n"
    vol = a.volume or cfg.volume
    jcl += f"//D1 DD UNIT=SYSDA,VOL=SER={vol},DISP=OLD\n//SYSIN DD *\n"
    for d in ("ARXSAMP", "ARXLIB", "SAMPLIB", "RXLIB"):
        jcl += f" LISTPDS DSNAME=BREXX.{d},VOL=SYSDA={vol},FORMAT\n"
    jcl += "/*\n"
    run(client, "BRXDIR", jcl)
    return 0


def cmd_smoke(client, cfg, a):
    """Run BREXX from BREXX.LINKLIB (STEPLIB) with BREXX.RXLIB and BREXX.SAMPLIB."""
    jcl = mvsmf.jobcard("BRXSMK", cfg.jobclass, cfg.msgclass, "BREXX SMOKE") + "\n"
    for step, pgm in (("BREXX", "BREXX"), ("ALIASREX", "REXX"), ("ALIASRX", "RX")):
        jcl += (f"//{step:<8} EXEC PGM={pgm},REGION=8192K,PARM='RXRUN'\n"
                "//STEPLIB  DD DISP=SHR,DSN=BREXX.LINKLIB\n"
                "//RXLIB    DD DISP=SHR,DSN=BREXX.RXLIB\n"
                "//STDIN    DD DUMMY\n//STDOUT   DD SYSOUT=*\n//STDERR   DD SYSOUT=*\n"
                "//RXRUN    DD *\n"
                "say 'SMOKE' version()\n"
                "say 'DAYSBETW' daysbetw('01.01.2026','31.01.2026')\n"
                "/*\n")
    jcl += ("//SAMPLE   EXEC PGM=BREXX,REGION=8192K,PARM='RXRUN 50'\n"
            "//STEPLIB  DD DISP=SHR,DSN=BREXX.LINKLIB\n"
            "//RXLIB    DD DISP=SHR,DSN=BREXX.RXLIB\n"
            "//STDIN    DD DUMMY\n//STDOUT   DD SYSOUT=*\n//STDERR   DD SYSOUT=*\n"
            "//RXRUN    DD DISP=SHR,DSN=BREXX.SAMPLIB(PRIMES)\n")
    r = run(client, "BRXSMK", jcl)
    sp = r.spool or ""
    ok = len(re.findall(r"DAYSBETW 30", sp))
    sample = "47" in sp.split("SAMPLE", 1)[-1]
    print(f"smoke: {ok} of 3 steps printed DAYSBETW 30; SAMPLIB(PRIMES) "
          f"{'printed 47' if sample else 'printed nothing usable'}")
    return 0 if r.rc == 0 and ok == 3 and sample else 1


LIBRARIES = ["LINKLIB", "ARXLINK", "BRXLOAD", "RXLIB", "ARXLIB", "TRXLIB",
             "SAMPLIB", "ARXSAMP", "TSAMPLIB", "CMDLIB", "JCL", "PROCLIB"]


def cmd_scratch(client, cfg, a):
    """Delete the BREXX libraries and the uploaded XMITs (after 'remove')."""
    dsns = [f"BREXX.{x}" for x in LIBRARIES] + [f"{cfg.hlq}.BRXINST.{x}" for x in XMITS]
    for dsn in dsns:
        if client.dataset_exists(dsn):
            client.delete_dataset(dsn)
            print(f"deleted {dsn}")
    left = [d for d in dsns if client.dataset_exists(d)]
    print(f"scratch: {len(left)} left")
    return 1 if left else 0


def cmd_smp(client, cfg, a):
    """Run the given SMP control statements and print the messages with **."""
    r = smp_job(client, "BRXSMP", [("SMP", a.statements)])
    for l in (r.spool or "").splitlines():
        if l.startswith("HMA") or " ** " in l:
            print(l[:120])
    return 0 if r.rc == 0 else 1


def cmd_spool(client, cfg, a):
    """Fetch the spool of a job that finished without the client seeing it: spool JOBNAME JOBID."""
    jobname, jobid = a.statements
    text, errors = client._collect_spool(jobname, jobid)
    path = os.path.join(jobs_dir(), f"{jobname}.{jobid}.txt")
    with open(path, "w") as f:
        f.write(text)
    print(f"{jobname} {jobid}: {len(text.splitlines())} lines -> {path}")
    for e in errors:
        print("ERROR:", e, file=sys.stderr)
    return 1 if errors else 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("step", choices=["install", "check", "remove", "removed", "dirs", "smoke", "smp", "scratch", "spool"])
    ap.add_argument("statements", nargs="*", help="smp: control statements")
    ap.add_argument("--volume", default="", help="volume of the staging data sets and RECEIVE")
    ap.add_argument("--tgtvol", default="", help="TGTVOL of the allocation job (default MVSRES)")
    ap.add_argument("--dlbvol", default="", help="DLBVOL of the allocation job (default SMP000)")
    a = ap.parse_args()
    cfg = mvsmf.Target.from_env("smpinstall")
    client = mvsmf.Client(cfg)
    client.cfg = cfg
    return {"install": cmd_install, "check": cmd_check, "remove": cmd_remove,
            "removed": cmd_removed, "dirs": cmd_dirs, "smoke": cmd_smoke, "smp": cmd_smp, "scratch": cmd_scratch,
            "spool": cmd_spool}[a.step](client, cfg, a)


if __name__ == "__main__":
    sys.exit(main())
