#!/usr/bin/env python3
"""Run BREXX on MVS: a smoke test plus the REXX test suite in test/.

Uses mbt's mvsMF client and configuration (.env / MBT_* variables), so it
talks to the same system 'make deploy' wrote the LINKLIB to.

  python3 scripts/mvstest.py                 # smoke test + all test/*.rexx
  python3 scripts/mvstest.py --only abbrev   # smoke test + one test
  python3 scripts/mvstest.py --smoke-only

Steps:
  1. (re)create {HLQ}.BREXX370.TESTS and {HLQ}.BREXX370.RXLIB (FB 80)
  2. upload the smoke exec, test/*.rexx and test/rxtest.rxlib (as RTEST)
  3. submit one job, one BREXX step per exec (PGM=BREXX,PARM='RXRUN',
     STEPLIB = the deployed LINKLIB)
  4. report RC / ABEND per step; the full spool goes to build/mvstest.spool

Exit status: 0 when every step ended with RC 0, 1 otherwise.
"""
import argparse
import re
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "mbt" / "scripts"))

from mbt.config import MbtConfig          # noqa: E402
from mbt.mvsmf import MvsMFClient, MvsMFError   # noqa: E402
from mbt.version import to_vrm            # noqa: E402

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


def _default_linklib(config, project):
    name = project["project"]["name"].upper()
    vrm = to_vrm(project["project"]["version"])
    target = project.get("deploy", {}).get("target")
    return target or f"{config.hlq}.{name}.{vrm}.LINKLIB"


def _recreate_pds(client, dsn):
    if client.dataset_exists(dsn):
        client.delete_dataset(dsn)
    client.create_dataset(dsn, "PO", "FB", 80, 3120, ["TRK", 60, 30, 40])


def _prepare(text):
    """Make a test exec uploadable: the legacy build did the same edits."""
    text = text.replace('"||VER||"', "BUILD")
    text = text.replace("¬", "\\")   # NOT sign -> backslash (also NOT)
    return text if text.endswith("\n") else text + "\n"


def _job(jobname, steps, linklib, testlib, rxlib, jobclass, msgclass,
         dump=False):
    out = [f"//{jobname:<8} JOB (BREXX),'BREXX TESTS',CLASS={jobclass},"
           f"MSGCLASS={msgclass},",
           "//         MSGLEVEL=(1,1),REGION=0K"]
    for member in steps:
        out += [
            f"//{member:<8} EXEC PGM=BREXX,PARM='RXRUN',REGION=8192K",
            f"//STEPLIB  DD DISP=SHR,DSN={linklib}",
            f"//RXRUN    DD DISP=SHR,DSN={testlib}({member})",
            f"//RXLIB    DD DISP=SHR,DSN={rxlib}",
            "//STDIN    DD DUMMY",
            "//STDOUT   DD SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)",
            "//STDERR   DD SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)",
        ]
        if dump:
            out.append("//SYSUDUMP DD SYSOUT=*")
    return "\n".join(out) + "\n"


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


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--project", default=str(ROOT / "project.toml"))
    ap.add_argument("--linklib", help="LINKLIB with BREXX (default: deploy target)")
    ap.add_argument("--only", action="append", default=[], metavar="TEST")
    ap.add_argument("--smoke-only", action="store_true")
    ap.add_argument("--timeout", type=int, default=900)
    ap.add_argument("--dump", action="store_true",
                    help="add a SYSUDUMP DD to every step")
    ap.add_argument("--print-spool", action="store_true",
                    help="also print the job spool to stdout")
    args = ap.parse_args()

    with open(args.project, "rb") as f:
        project = tomllib.load(f)
    config = MbtConfig(project_path=args.project)
    client = MvsMFClient(config.mvs_host, config.mvs_port,
                         config.mvs_user, config.mvs_pass)

    linklib = args.linklib or _default_linklib(config, project)
    testlib = f"{config.hlq}.BREXX370.TESTS"
    rxlib = f"{config.hlq}.BREXX370.RXLIB"
    jobname = "BRXTEST"

    if not client.dataset_exists(linklib):
        _log(f"ERROR: {linklib} does not exist -- run 'make deploy' first")
        return 1

    tests = []
    if not args.smoke_only:
        files = sorted((ROOT / "test").glob("*.rexx"))
        if args.only:
            wanted = {o.lower() for o in args.only}
            files = [f for f in files if f.stem.lower() in wanted]
        tests = [f for f in files if len(f.stem) <= 8]

    _log(f"LINKLIB {linklib}")
    _log(f"creating {testlib} and {rxlib}")
    _recreate_pds(client, testlib)
    _recreate_pds(client, rxlib)

    client.write_member(testlib, "SMOKE", SMOKE)
    client.write_member(rxlib, "RTEST",
                        _prepare((ROOT / "test" / "rxtest.rxlib").read_text()))
    steps = ["SMOKE"]
    for f in tests:
        member = f.stem.upper()
        client.write_member(testlib, member, _prepare(f.read_text()))
        steps.append(member)
    _log(f"uploaded {len(steps)} exec(s)")

    jcl = _job(jobname, steps, linklib, testlib, rxlib,
               config.jes_jobclass, config.jes_msgclass, dump=args.dump)
    _log(f"submitting {jobname} ({len(steps)} step(s))")
    try:
        result = client.submit_jcl(jcl, timeout=args.timeout)
    except MvsMFError as e:
        _log(f"ERROR: {e}")
        return 1

    spool_file = ROOT / "build" / "mvstest.spool"
    spool_file.parent.mkdir(exist_ok=True)
    spool_file.write_text(result.spool)
    _log(f"job {result.jobid} ended: {result.status} rc={result.rc} "
         f"(spool in {spool_file.relative_to(ROOT)})")

    if args.print_spool:
        print("----- spool -----")
        print(result.spool)
        print("----- end of spool -----")

    failed = 0
    for step in steps:
        rc = _step_rc(result.spool, result.jobname, step)
        ok = rc == "RC 0"
        failed += not ok
        print(f"  {step:<8} {rc:<14} {'PASS' if ok else 'FAIL'}")
    _log(f"{len(steps) - failed}/{len(steps)} step(s) passed")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
