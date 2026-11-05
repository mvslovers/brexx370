#!/usr/bin/env python3
"""REXXCPS speed comparison of BREXX builds on MVS (#611).

Runs samples/REXXCPS.rexx under IKJEFT01 (`RX`) once per build and round,
with the builds in turn so a drifting host hits every build alike, and
reports clauses per second per build, the median over the rounds and the
ratio to a baseline build.  Runs as an mbt command (mbt/init.lua), against
a throwaway system:

  eval "$(~/repos/mvs/mvs-docker/mvsce/mvsce-target up --dist tk5)"
  mbt run rexxcps --target env -- \\
      --load V2=BREXX.V2R5M3.LEVEL02.LLIB.zip \\
      --load V3=brexx370-3.0.0-load.xmit \\
      --rounds 3 --baseline V2 --min-ratio 0.80 --candidate V3

A build is `--load NAME=FILE` (an XMIT of the load library, or a ZIP
holding one: it is uploaded and RECEIVEd into {HLQ}.RXCPS.NAME) or
`--lib NAME=DSN` (a library already on the system, for example the one
`mbt deploy --linklib DSN` wrote).  The first `--load`/`--lib` is the
baseline unless `--baseline` names another.

Every step must end with CC 0, and the PARSE VERSION line of each run is
kept in the report.  With `--candidate NAME` and `--min-ratio R` the exit
status is 1 when the median ratio candidate/baseline is below R; this is
the hurdle for a release.  The report also goes to build/rexxcps.json.

The default is 100 x 100 iterations of the 1000-clause loop (REXXCPS's own
defaults); `--count`/`--averaging` shorten a trial run.
"""
import argparse
import io
import json
import os
import re
import statistics
import sys
import zipfile
from pathlib import Path

from mvsmf import Client, MvsMFError, Target, jobcard

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "samples" / "REXXCPS.rexx"
OUT = ROOT / "build" / "rexxcps.json"

CPS = re.compile(r"Performance:\s+(\d+)\s+REXX clauses per second")
VERSION = re.compile(r"REXX version is:\s*(.*)")
INSTR = re.compile(r"Instructions\s+(\d+)\s*$", re.M)


def parse_builds(a):
    builds = []
    for kind, items in (("load", a.load), ("lib", a.lib)):
        for item in items:
            name, sep, value = item.partition("=")
            if not sep or not re.fullmatch(r"[A-Z][A-Z0-9]{0,7}", name):
                sys.exit(f"--{kind} {item}: want NAME=VALUE, NAME 1-8 upper-case "
                         f"letters or digits")
            builds.append((name, kind, value))
    if len(builds) < 1:
        sys.exit("no build: give --load NAME=FILE or --lib NAME=DSN")
    names = [b[0] for b in builds]
    if len(set(names)) != len(names):
        sys.exit("a build name is used twice")
    return builds


def xmit_bytes(path):
    data = Path(path).read_bytes()
    if zipfile.is_zipfile(io.BytesIO(data)):
        with zipfile.ZipFile(io.BytesIO(data)) as z:
            xs = [n for n in z.namelist()
                  if n.lower().endswith(".xmit") and "apf" not in n.lower()]
            if len(xs) != 1:
                sys.exit(f"{path}: want exactly one non-APF .xmit, found {xs}")
            return z.read(xs[0])
    return data


def member_records(text, no_not_sign=False):
    """The exec as CP037 records of 80 bytes: mvsMF's text translation turns
    the NOT sign of REXXCPS into a character BREXX rejects (error 13)."""
    if no_not_sign:
        text = re.sub(r"\u00ac(\w+\([^)]*\))", r"\1=0", text)
    recs = []
    for line in text.splitlines():
        if len(line) > 80:
            sys.exit(f"{SOURCE.name}: a line longer than 80 characters")
        recs.append(line.ljust(80).encode("cp037"))
    return b"".join(recs)


def run_job(client, jcl, what, timeout):
    res = client.submit_jcl(jcl, timeout=timeout)
    if res.status != "CC" or res.rc != 0:
        sys.stderr.write(res.spool[-6000:] + "\n")
        sys.exit(f"{what}: {res.jobname} {res.jobid} ended {res.status} "
                 f"RC {res.rc}")
    return res


def receive(client, tg, name, path):
    """Upload the XMIT and RECEIVE it into {HLQ}.RXCPS.{name}; returns the DSN."""
    lib = f"{tg.hlq}.RXCPS.{name}"
    xmit = f"{tg.hlq}.RXCPS.{name}.XMIT"
    for dsn in (lib, xmit):
        if client.dataset_exists(dsn):
            client.delete_dataset(dsn)
    client.create_dataset(xmit, "PS", "FB", 80, 3120, ["CYL", 5, 5])
    data = xmit_bytes(path)
    client.upload_binary(xmit, data)
    jcl = (jobcard(f"RXC{name}"[:8], tg.jobclass, tg.msgclass, "RXCPS RECEIVE")
           + "\n//RECV370  EXEC PGM=RECV370,REGION=8192K\n"
             "//RECVLOG  DD SYSOUT=*\n"
             f"//XMITIN   DD DSN={xmit},DISP=SHR\n"
             "//SYSPRINT DD SYSOUT=*\n"
             "//SYSUT1   DD DSN=&&XMIT2,UNIT=SYSDA,SPACE=(TRK,(300,60)),\n"
             "//            DISP=(NEW,DELETE,DELETE)\n"
             f"//SYSUT2   DD DSN={lib},UNIT=SYSDA,\n"
             "//            SPACE=(TRK,(300,60,20)),DISP=(NEW,CATLG,CATLG)\n"
             "//SYSIN    DD DUMMY\n")
    res = run_job(client, jcl, f"RECEIVE {name}", 300)
    members = client.list_members(lib)
    if "BREXX" not in members:
        sys.exit(f"{lib} has no member BREXX after RECEIVE ({res.jobid}); "
                 f"members: {members[:20]}")
    client.delete_dataset(xmit)
    print(f"{name}: {path} -> {lib} ({len(members)} members, {res.jobid})")
    return lib


def step_jcl(tg, jobname, lib, execlib, count, averaging):
    arg = f"{count} {averaging}"
    return (jobcard(jobname, tg.jobclass, tg.msgclass, "REXXCPS")
            + "\n//TSO      EXEC PGM=IKJEFT01,REGION=8192K,DYNAMNBR=50\n"
              f"//STEPLIB  DD DSN={lib},DISP=SHR\n"
              "//SYSPRINT DD SYSOUT=*\n"
              "//SYSTSPRT DD SYSOUT=*\n"
              "//STDOUT   DD SYSOUT=*\n"
              "//STDERR   DD SYSOUT=*\n"
              "//SYSTSIN  DD *\n"
              f" RX '{execlib}(REXXCPS)' {arg}\n"
              "/*\n")


def one_run(client, tg, name, lib, execlib, count, averaging, timeout):
    res = client.submit_jcl(
        step_jcl(tg, "RXCPS", lib, execlib, count, averaging), timeout=timeout)
    cps = CPS.search(res.spool)
    ver = VERSION.search(res.spool)
    ins = INSTR.search(res.spool)
    if res.status != "CC" or res.rc != 0 or not cps:
        sys.stderr.write(res.spool[-4000:] + "\n")
        why = "" if cps else ", no Performance line"
        sys.exit(f"{name}: {res.jobname} {res.jobid} ended {res.status} "
                 f"RC {res.rc}{why}")
    return {"job": res.jobid, "cps": int(cps[1]), "hostload": os.getloadavg()[0],
            "version": ver[1].strip() if ver else "",
            "instructions": int(ins[1]) if ins else None}


def report(a, tg, names, baseline, runs):
    med = {n: statistics.median(x["cps"] for x in runs[n]) for n in names}
    print(f"\n{'build':8} {'median':>9} {'min':>9} {'max':>9} {'ratio':>7}  "
          f"(baseline {baseline}; {a.rounds} rounds, {a.count} x {a.averaging})")
    for n in names:
        cps = [x["cps"] for x in runs[n]]
        print(f"{n:8} {med[n]:>9.0f} {min(cps):>9} {max(cps):>9} "
              f"{med[n] / med[baseline]:>7.3f}")
    # the median of the per-round ratios is the one that survives a drift
    ratios = {n: statistics.median(
        x["cps"] / y["cps"] for x, y in zip(runs[n], runs[baseline]))
        for n in names}
    print("\nmedian of the per-round ratios: "
          + ", ".join(f"{n} {ratios[n]:.3f}" for n in names))

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(
        {"target": tg.url, "count": a.count, "averaging": a.averaging,
         "baseline": baseline, "median": med, "ratio_of_medians":
         {n: med[n] / med[baseline] for n in names},
         "median_of_ratios": ratios, "runs": runs}, indent=2) + "\n")

    if a.min_ratio is not None:
        got = ratios[a.candidate]
        ok = got >= a.min_ratio
        print(f"\nhurdle: {a.candidate}/{baseline} = {got:.3f}, "
              f"minimum {a.min_ratio:.3f}: {'passed' if ok else 'FAILED'}")
        sys.exit(0 if ok else 1)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--load", action="append", default=[], metavar="NAME=FILE")
    ap.add_argument("--lib", action="append", default=[], metavar="NAME=DSN")
    ap.add_argument("--rounds", type=int, default=3)
    ap.add_argument("--count", type=int, default=100)
    ap.add_argument("--averaging", type=int, default=100)
    ap.add_argument("--baseline", help="build the ratios are relative to")
    ap.add_argument("--candidate", help="build the hurdle is checked for")
    ap.add_argument("--min-ratio", type=float,
                    help="exit 1 when candidate/baseline (median) is lower")
    ap.add_argument("--no-not-sign", action="store_true",
                    help="write `if \u00acdatatype(x,'N')` as `datatype(x,'N')=0`, for a "
                         "build whose parser mistakes the NOT sign (the first cc370 states)")
    ap.add_argument("--timeout", type=int, default=1800,
                    help="seconds to wait for one run")
    a = ap.parse_args()
    builds = parse_builds(a)
    baseline = a.baseline or builds[0][0]
    if baseline not in [b[0] for b in builds]:
        sys.exit(f"--baseline {baseline} is not a build")
    if a.min_ratio is not None and not a.candidate:
        sys.exit("--min-ratio needs --candidate")
    if a.candidate and a.candidate not in [b[0] for b in builds]:
        sys.exit(f"--candidate {a.candidate} is not a build")

    tg = Target.from_env("rexxcps")
    client = Client(tg)
    try:
        execlib = f"{tg.hlq}.RXCPS.EXEC"
        if client.dataset_exists(execlib):
            client.delete_dataset(execlib)
        client.create_dataset(execlib, "PO", "FB", 80, 3120, ["TRK", 5, 5, 10])
        client._request("PUT", f"/restfiles/ds/{execlib}(REXXCPS)",
                        member_records(SOURCE.read_text(encoding="utf-8"),
                                       a.no_not_sign),
                        content_type="application/octet-stream", accept="*/*",
                        extra_headers={"X-IBM-Data-Type": "binary"})

        libs = {}
        for name, kind, value in builds:
            libs[name] = receive(client, tg, name, value) if kind == "load" else value
        names = [b[0] for b in builds]

        runs = {n: [] for n in names}
        for r in range(a.rounds):
            order = names if r % 2 == 0 else names[::-1]
            for n in order:
                run = one_run(client, tg, n, libs[n], execlib, a.count,
                              a.averaging, a.timeout)
                run["round"] = r + 1
                runs[n].append(run)
                print(f"round {r + 1} {n:8} {run['cps']:>9} clauses/s  "
                      f"{run['job']}  {run['version']}", flush=True)
    except MvsMFError as e:
        sys.exit(f"mvsMF: {e}")

    report(a, tg, names, baseline, runs)


if __name__ == "__main__":
    main()
