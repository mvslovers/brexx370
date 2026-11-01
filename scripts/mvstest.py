#!/usr/bin/env python3
"""Run BREXX on MVS: a smoke test plus the REXX test suite in test/.

Runs as an mbt command (mbt/init.lua), against the target mbt deploys to
and over mbt's mvsMF session (scripts/mvsmf.py):

  mbt run mvstest                            # smoke test + all test/*.rexx
  mbt run mvstest -- --only abbrev           # smoke test + one test
  mbt run mvstest -- --smoke-only
  mbt run mvstest --target NAME -- ...       # another system

Steps:
  1. (re)create {HLQ}.BREXX370.TESTS and {HLQ}.BREXX370.RXLIB (FB 80)
  2. upload the smoke exec, test/*.rexx and test/rxtest.rxlib (as RTEST)
  3. submit one job, one BREXX step per exec (PGM=BREXX,PARM='RXRUN',
     STEPLIB = the deployed LINKLIB + the TESTLIB of "mbt test --mvs";
     run that first, the script stops when a test module is missing)
  4. report RC / ABEND per step; the full spool goes to build/mvstest.spool

A test whose source says "MVSTEST PARM=DSN" is started by its data set
name instead (PARM='{testlib}(member)', no RXRUN DD), as RX 'DSN(MEMBER)'
does in TSO. One that says "MVSTEST FULLDD" gets a DD FULLDD: a new,
temporary FB 80 data set of one track and no secondary space, which a
write fills up (CREATE() cannot make one: compat drops pri/sec).
One that says "MVSTEST TSO" runs under a batch TMP instead (PGM=IKJEFT01,
SYSTSIN "BREXX '{testlib}(member)'"): BREXX is then a TSO command
processor with a CPPL, as ADDRESS COMMAND and ISPEXEC need. The step's
RC is BREXX's, the last command's. Each "MVSTEST SYSTSIN text" line of
such a test adds a SYSTSIN line after the BREXX command: data that PULL
reads through GETLINE, as under TSO/E. "MVSTEST RXLIB name ..." uploads
those members of rxlib/ into {HLQ}.BREXX370.RXLIBX, concatenated behind
the step's RXLIB (which keeps RTEST alone), for a test of them.
One that says "MVSTEST VSAM" gets a KSDS of its own: an IDCAMS step before
it defines {HLQ}.BREXX370.VSAMTST on the target's volume (key of 8 bytes
at offset 0, RECORDSIZE 100 200, one record loaded: an empty KSDS cannot
be processed), the step gets it as DD VSAMTST (and as VSAMTS, for the traced IRXVSMTR:
its DD name prefix leaves six characters), and an IDCAMS step after it
deletes the cluster again. One that says "MVSTEST OWNJOB" runs in a second
job (BRXTESTO, spool in build/mvstest-own.spool) after the first: a test
that takes the whole private area leaves the system none in a long job.

Exit status: 0 when every step ended with RC 0 (or the RC a test names
with "MVSTEST RC=n" in its source), 1 otherwise.
"""
import argparse
import os
import re
import sys
import tomllib
from pathlib import Path

from mvsmf import Client, MvsMFError, Target, to_vrm

ROOT = Path(__file__).resolve().parent.parent

SMOKE = """/* REXX - BREXX cc370 smoke test */
say 'BREXX SMOKE TEST'
parse version v
say 'VERSION:' v
say 'SOURCE :' sourceline()
rc = 0
if 1 + 2 * 3 \\= 7        then rc = rc + 1
if 10 / 4 \\= 2.5         then rc = rc + 1
if 2 ** 10 \\= 1024       then rc = rc + 1
if substr('ABCDEF', 2, 3) \\= 'BCD' then rc = rc + 1
if translate('abc') \\= 'ABC'       then rc = rc + 1
if words('a b  c') \\= 3            then rc = rc + 1
if c2x('A') \\= 'C1'                then rc = rc + 1
if d2x(255) \\= 'FF'                then rc = rc + 1
s. = 0
do i = 1 to 100
  s.i = i * i
end
if s.100 \\= 10000 then rc = rc + 1
say 'DATE   :' date() time()
say 'USERID :' userid()
say 'RESULT : rc='rc
exit rc
"""


def _log(msg):
    print(f"[mvstest] {msg}", flush=True)


def _default_testmods(target, project):
    """The TESTLIB 'mbt test --mvs' deploys the test modules to (mbt's rule,
    internal/mvstest/run.go; mbt does not pass it to Lua yet). The REXX
    tests LINK helper programs from it (TSTLINK, #102)."""
    name = project["project"]["name"].upper()
    vrm = to_vrm(project["project"]["version"])
    lib = project.get("test_deploy", {}).get("target")
    return lib or f"{target.hlq}.{name}.{vrm}.TESTLIB"


def _recreate_pds(client, dsn):
    if client.dataset_exists(dsn):
        client.delete_dataset(dsn)
    client.create_dataset(dsn, "PO", "FB", 80, 3120, ["TRK", 60, 30, 40])


def _recreate_ps(client, dsn, recfm="FB", lrecl=80, blksize=3120):
    if client.dataset_exists(dsn):
        client.delete_dataset(dsn)
    client.create_dataset(dsn, "PS", recfm, lrecl, blksize, ["TRK", 5, 5])


def _prepare(text, testlib, testseq, linklib=None, rxlib=None, vrm=None,
             cluster=None):
    """Make a test exec uploadable.

    The I/O tests write members into 'BREXX."||VER||".TESTS' (the legacy
    build ran them against BREXX.BUILD.TESTS); point them at our test PDS.
    Tests that overwrite in place need a sequential data set (a PDS member
    cannot be updated): 'BREXX."||VER||".TESTSEQ' (FB80) and
    'BREXX."||VER||".TESTSEQV' (VB84). 'BREXX.LINKLIB' and 'BREXX.RXLIB'
    name the libraries of the step: the deployed LINKLIB and the RXLIB.
    '@VRM@' becomes the version of mbt.toml in mbt's VRM form (V3R0M0).
    '@CLUSTER@' becomes the KSDS of "MVSTEST VSAM", for a test that
    allocates it by name.
    """
    if vrm:
        text = text.replace("@VRM@", vrm)
    if cluster:
        text = text.replace("@CLUSTER@", cluster)
    if linklib:
        text = text.replace("'BREXX.LINKLIB'", f"'{linklib}'")
    if rxlib:
        text = text.replace("'BREXX.RXLIB'", f"'{rxlib}'")
    text = text.replace("'BREXX.\"||VER||\".TESTSEQV'", f"'{testseq}V'")
    text = text.replace("'BREXX.\"||VER||\".TESTSEQ'", f"'{testseq}'")
    text = text.replace("'BREXX.\"||VER||\".TESTS", f"'{testlib}")
    text = text.replace('"||VER||"', "BUILD")
    text = text.replace("¬", "\\")   # NOT sign -> backslash (also NOT)
    # '!' is a symbol character in BREXX, not NOT: "x!=5" means x||'!' = 5,
    # which is never true, so these checks could not fail. Use "\=".
    text = text.replace("!=", "\\=")
    return text if text.endswith("\n") else text + "\n"


def _vsam_define(member, cluster, volume):
    """The IDCAMS step before a test with "MVSTEST VSAM": a fresh KSDS"""
    return [
        f"//D{member[:7]:<7} EXEC PGM=IDCAMS,REGION=1024K,COND=EVEN",
        "//SYSPRINT DD SYSOUT=*",
        "//FIRSTREC DD *",
        "00000000first record",
        "/*",
        "//SYSIN    DD *",
        f"  DELETE {cluster} CLUSTER PURGE",
        "  SET MAXCC=0",
        f"  DEFINE CLUSTER (NAME({cluster}) INDEXED -",
        "    RECORDSIZE(100 200) KEYS(8 0) TRACKS(2 2) -",
        f"    VOLUMES({volume}) SHAREOPTIONS(2 3) UNIQUE) -",
        f"    DATA (NAME({cluster}.DATA)) -",
        f"    INDEX (NAME({cluster}.INDEX))",
        "  IF LASTCC = 0 THEN -",
        f"    REPRO INFILE(FIRSTREC) ODS({cluster})",
        "/*",
    ]


def _vsam_delete(member, cluster):
    return [
        f"//X{member[:7]:<7} EXEC PGM=IDCAMS,REGION=1024K,COND=EVEN",
        "//SYSPRINT DD SYSOUT=*",
        "//SYSIN    DD *",
        f"  DELETE {cluster} CLUSTER PURGE",
        "/*",
    ]


def _job(jobname, steps, linklib, testlib, rxlib, jobclass, msgclass,
         dump=False, testmods=None, by_dsn=(), full_dd=(), tso=(),
         vsam=(), cluster=None, volume=None):
    out = [f"//{jobname:<8} JOB (BREXX),'BREXX TESTS',CLASS={jobclass},"
           f"MSGCLASS={msgclass},",
           "//         MSGLEVEL=(1,1),REGION=0K"]
    for member in steps:
        if member in vsam:
            out += _vsam_define(member, cluster, volume)
        if member in tso:
            out += _tso_step(member, linklib, testlib, rxlib, testmods, dump,
                             tso[member], cluster if member in vsam else None)
            if member in vsam:
                out += _vsam_delete(member, cluster)
            continue
        parm = f"{testlib}({member})" if member in by_dsn else "RXRUN"
        out += [
            # COND=EVEN: an abend in one test must not flush the others;
            # PARM on a line of its own, a DSN does not fit in column 71
            f"//{member:<8} EXEC PGM=BREXX,REGION=8192K,COND=EVEN,",
            f"//         PARM='{parm}'",
            f"//STEPLIB  DD DISP=SHR,DSN={linklib}",
        ]
        if testmods:
            out.append(f"//         DD DISP=SHR,DSN={testmods}")
        if member not in by_dsn:
            out.append(f"//RXRUN    DD DISP=SHR,DSN={testlib}({member})")
        out += [
            f"//RXLIB    DD DISP=SHR,DSN={rxlib}",
            f"//         DD DISP=SHR,DSN={rxlib}X",
            "//STDIN    DD DUMMY",
            "//STDOUT   DD SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)",
            "//STDERR   DD SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)",
            # an output-only stream for test/rdout.rexx (libc370#203)
            "//OUTDD    DD SYSOUT=*,DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120)",
        ]
        if member in vsam:
            out.append(f"//VSAMTST  DD DISP=OLD,DSN={cluster}")
            out.append(f"//VSAMTS   DD DISP=OLD,DSN={cluster}")
        if member in full_dd:
            # one track, no secondary: a data set that fills up (#178)
            out += ["//FULLDD   DD UNIT=SYSDA,SPACE=(TRK,(1,0)),DISP=(NEW,DELETE),",
                    "//         DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)"]
        if dump:
            out.append("//SYSUDUMP DD SYSOUT=*")
        if member in vsam:
            out += _vsam_delete(member, cluster)
    return "\n".join(out) + "\n"


def _tso_step(member, linklib, testlib, rxlib, testmods, dump, systsin=(),
              cluster=None):
    """One test as a TSO command in a batch TMP: "MVSTEST TSO" """
    out = [
        f"//{member:<8} EXEC PGM=IKJEFT01,REGION=8192K,COND=EVEN",
        f"//STEPLIB  DD DISP=SHR,DSN={linklib}",
    ]
    if testmods:
        out.append(f"//         DD DISP=SHR,DSN={testmods}")
    out += [
        f"//RXLIB    DD DISP=SHR,DSN={rxlib}",
        f"//         DD DISP=SHR,DSN={rxlib}X",
        "//SYSTSPRT DD SYSOUT=*",
    ]
    if cluster:
        out.append(f"//VSAMTST  DD DISP=OLD,DSN={cluster}")
        out.append(f"//VSAMTS   DD DISP=OLD,DSN={cluster}")
    out += [
        "//SYSTSIN  DD *",
        f"  BREXX '{testlib}({member})'",
        *systsin,
        "/*",
    ]
    if dump:
        out.append("//SYSUDUMP DD SYSOUT=*")
    return out


def _step_rc(spool, jobname, step):
    ab = re.search(rf"IEF450I\s+{jobname}\s+{step}\s+-\s+ABEND\s+(\S+)", spool)
    if ab:
        return f"ABEND {ab.group(1)}"
    cc = re.search(rf"IEF142I\s+{jobname}\s+{step}\s+-\s+STEP WAS EXECUTED"
                   rf"\s+-\s+COND CODE\s+(\d+)", spool)
    if cc:
        return f"RC {int(cc.group(1))}"
    if re.search(rf"IEF272I\s+{jobname}\s+{step}\s+-\s+STEP WAS NOT EXECUTED",
                 spool):
        return "NOT EXECUTED"
    return "NO RC"


def _expected_rc(text):
    """A test that must end with another RC than 0 says so in its source,
    e.g. the abend test: /* MVSTEST RC=8 */"""
    m = re.search(r"MVSTEST\s+RC=(\d+)", text)
    return int(m.group(1)) if m else 0


def _full_dd(text):
    """A test that needs a data set which fills up: /* MVSTEST FULLDD */"""
    return re.search(r"MVSTEST\s+FULLDD\b", text) is not None


def _tso(text):
    """A test that needs TSO (a CPPL) says so: /* MVSTEST TSO */"""
    return re.search(r"MVSTEST\s+TSO\b", text) is not None


def _vsam(text):
    """A test that needs a KSDS says so: /* MVSTEST VSAM */"""
    return re.search(r"MVSTEST\s+VSAM\b", text) is not None


def _rxlib_members(text):
    """rxlib/ members a test needs: /* MVSTEST RXLIB name ... */"""
    names = []
    for found in re.findall(r"MVSTEST\s+RXLIB\s+(.*?)\s*\*/", text):
        names += found.split()
    return names


def _systsin(text):
    """SYSTSIN lines after the command: /* MVSTEST SYSTSIN text */"""
    return re.findall(r"MVSTEST\s+SYSTSIN (.*?)\s*\*/", text)


def _own_job(text):
    """A test that must not share a job with the others says so:
    /* MVSTEST OWNJOB */. A long job leaves less private area for the
    system, which a test that fills the whole area cannot take (#504)"""
    return re.search(r"MVSTEST\s+OWNJOB\b", text) is not None


def _by_dsn(text):
    """A test started by its data set name says so: /* MVSTEST PARM=DSN */"""
    return re.search(r"MVSTEST\s+PARM=DSN\b", text) is not None


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--linklib", help="LINKLIB with BREXX (default: deploy target)")
    ap.add_argument("--only", action="append", default=[], metavar="TEST")
    ap.add_argument("--smoke-only", action="store_true")
    ap.add_argument("--timeout", type=int, default=900)
    ap.add_argument("--dump", action="store_true",
                    help="add a SYSUDUMP DD to every step")
    ap.add_argument("--print-spool", action="store_true",
                    help="also print the job spool to stdout")
    args = ap.parse_args()

    with open(ROOT / "mbt.toml", "rb") as f:
        project = tomllib.load(f)
    target = Target.from_env("mvstest")
    client = Client(target)

    # mbt passes its deploy target and the test modules it finds
    linklib = args.linklib or os.environ.get("MVSTEST_LINKLIB")
    if not linklib:
        _log("ERROR: no deploy target from mbt and no --linklib")
        return 1
    testlib = f"{target.hlq}.BREXX370.TESTS"
    rxlib = f"{target.hlq}.BREXX370.RXLIB"
    testseq = f"{target.hlq}.BREXX370.TESTSEQ"
    jobname = "BRXTEST"

    try:
        if not client.dataset_exists(linklib):
            _log(f"ERROR: {linklib} does not exist -- run 'mbt deploy' first")
            return 1
        return _run(args, project, target, client, linklib, testlib, rxlib,
                    testseq, jobname)
    except MvsMFError as e:
        _log(f"ERROR: {e}")
        return 1


def _run(args, project, target, client, linklib, testlib, rxlib, testseq,
         jobname):

    # The REXX tests LINK test modules (TSTLINK, #102), from the TESTLIB
    # behind the LINKLIB, so a test module can never shadow BREXX. Filling
    # it is 'mbt test --mvs', run before this: an mbt started from here
    # would log off at its end, and mvsMF then refuses this command's
    # session token as well (HTTP 401, #421).
    testmods = _default_testmods(target, project)
    wanted = {t for t in os.environ.get("MVSTEST_TESTS", "").split(",") if t}
    have = set()
    if client.dataset_exists(testmods):
        have = {m.upper() for m in client.list_members(testmods)}
    if wanted - have:
        _log(f"ERROR: {testmods} lacks {', '.join(sorted(wanted - have))} "
             f"-- run 'mbt test --mvs' first")
        return 1
    if not wanted:
        testmods = None

    tests = []
    if not args.smoke_only:
        files = sorted((ROOT / "test").glob("*.rexx"))
        if args.only:
            wanted = {o.lower() for o in args.only}
            files = [f for f in files if f.stem.lower() in wanted]
        tests = [f for f in files if len(f.stem) <= 8]

    _log(f"LINKLIB {linklib}" + (f" + {testmods}" if testmods else ""))
    _log(f"creating {testlib} and {rxlib}")
    _recreate_pds(client, testlib)
    _recreate_pds(client, rxlib)
    _recreate_pds(client, rxlib + "X")   # rxlib/ members a test names
    _recreate_ps(client, testseq)
    _recreate_ps(client, testseq + "V", "VB", 84, 3120)

    client.write_member(testlib, "SMOKE", SMOKE)
    client.write_member(rxlib, "RTEST",
                        _prepare((ROOT / "test" / "rxtest.rxlib").read_text(), testlib,
                                 testseq))
    sources = {f.stem.upper(): f for f in (ROOT / "rxlib").glob("*.rexx")}
    uploaded = set()
    for f in tests:
        for name in _rxlib_members(f.read_text()):
            name = name.upper()
            if name in uploaded:
                continue
            if name not in sources:
                sys.exit(f"[mvstest] {f.name}: no rxlib/{name}.rexx")
            client.write_member(rxlib + "X", name, sources[name].read_text())
            uploaded.add(name)
    if uploaded:
        _log(f"uploaded {len(uploaded)} RXLIB member(s)")
    cluster = f"{target.hlq}.BREXX370.VSAMTST"
    steps = ["SMOKE"]
    expected = {}
    by_dsn = set()
    full_dd = set()
    own_job = []
    tso = {}
    vsam = set()
    for f in tests:
        member = f.stem.upper()
        text = f.read_text()
        client.write_member(testlib, member, _prepare(text, testlib, testseq, linklib, rxlib,
                                                      to_vrm(project["project"]["version"]),
                                                      cluster))
        if _own_job(text):
            own_job.append(member)
        else:
            steps.append(member)
        expected[member] = _expected_rc(text)
        if _by_dsn(text):
            by_dsn.add(member)
        if _full_dd(text):
            full_dd.add(member)
        if _tso(text):
            tso[member] = _systsin(text)
        if _vsam(text):
            vsam.add(member)
    _log(f"uploaded {len(steps)} exec(s)")

    if vsam and not target.volume:
        _log("ERROR: a VSAM test needs the target's volume (MBT_TARGET_VOLUME)")
        return 1
    failed = total = 0
    for name, job_steps, spool_name in (
            (jobname, steps, "mvstest.spool"),
            (jobname + "O", own_job, "mvstest-own.spool")):
        if not job_steps:
            continue
        f, t = _submit(args, target, client, name, job_steps, spool_name,
                       expected, vsam, cluster, linklib, testlib, rxlib,
                       testmods, by_dsn, full_dd, tso)
        failed += f
        total += t
    _log(f"{total - failed}/{total} step(s) passed")
    return 0 if failed == 0 else 1


def _submit(args, target, client, jobname, steps, spool_name, expected, vsam,
            cluster, linklib, testlib, rxlib, testmods, by_dsn, full_dd, tso):
    """Submit one job, print its steps; returns (failed, total)"""
    jcl = _job(jobname, steps, linklib, testlib, rxlib,
               target.jobclass, target.msgclass, dump=args.dump,
               testmods=testmods, by_dsn=by_dsn, full_dd=full_dd, tso=tso,
               vsam=vsam, cluster=cluster, volume=target.volume)
    _log(f"submitting {jobname} ({len(steps)} step(s))")
    result = client.submit_jcl(jcl, timeout=args.timeout)

    spool_file = ROOT / "build" / spool_name
    spool_file.parent.mkdir(exist_ok=True)
    spool_file.write_text(result.spool)
    _log(f"job {result.jobid} ended: {result.status} rc={result.rc} "
         f"(spool in {spool_file.relative_to(ROOT)})")
    # a failed readback is not an empty job: say which request failed
    for err in result.spool_errors[:5]:
        _log(f"spool read error: {err}")
    if len(result.spool_errors) > 5:
        _log(f"... {len(result.spool_errors) - 5} more spool read errors")

    if args.print_spool:
        print("----- spool -----")
        print(result.spool)
        print("----- end of spool -----")

    failed = 0
    total = len(steps)
    for step in steps:
        rc = _step_rc(result.spool, result.jobname, step)
        ok = rc == f"RC {expected.get(step, 0)}"
        failed += not ok
        print(f"  {step:<8} {rc:<14} {'PASS' if ok else 'FAIL'}")
    # the IDCAMS steps around a VSAM test: a cluster that could not be
    # defined or deleted fails the run, not only the test
    for member in sorted(vsam & set(steps)):
        for prefix in ("D", "X"):
            step = f"{prefix}{member[:7]}"
            rc = _step_rc(result.spool, result.jobname, step)
            ok = rc == "RC 0"
            total += 1
            failed += not ok
            print(f"  {step:<8} {rc:<14} {'PASS' if ok else 'FAIL'}")
    return failed, total


if __name__ == "__main__":
    sys.exit(main())
