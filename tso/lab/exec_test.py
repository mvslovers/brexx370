#!/usr/bin/env python3
"""tso/lab/exec_test.py - ZMG0001: the TSO EXEC language rules, case by case.

    python3 tso/lab/exec_test.py testlib     # patched EXEC from the test library
    python3 tso/lab/exec_test.py installed   # no STEPLIB: what SMP installed

testlib runs a batch TMP with STEPLIB={HLQ}.BREXX370.TSO.LOADLIB (the EXEC
that tso/lmod_link.py testlib linked) and the dev LINKLIB behind it, where
IKJCT437 finds BREXX. installed runs without a STEPLIB: EXEC from
SYS1.CMDLIB and BREXX from the link list.

The rules (measured on z/OS for ZMG0002, mvslovers/rexx370):

  implicit %name / name   SYSPROC member: REXX only with a comment
                          containing REXX in line 1; SYSEXEC: REXX, no check
  explicit EXEC 'ds(m)'   REXX only with that comment, whatever library
  explicit ... EXEC       REXX, forced; E, EX, EXE all abbreviate it
  EXEC name EXEC          unqualified name gets .EXEC, not .CLIST
  a CLIST line that is not a command: IKJ56479I, always under ZMG0001

BREXX's SAY does not reach SYSTSPRT in a batch TMP: libc370 writes stdout
to a SYSOUT of its own per run. So every case that must run as REXX passes
a tag of its own as the argument, the exec says 'ARG=<tag>', and that is
looked for in the whole spool. CLIST output and TMP messages are checked
in the command's own part of SYSTSPRT.

Taken over from mvslovers/rexx370 tso/lab/exec_test.py (main f574e90),
without its TMP modes: ZMG0001 patches no TMP.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, "mbt/scripts")
sys.path.insert(0, "tso")
from mbt.jcl import jobcard  # noqa: E402
import lmod_link as L  # noqa: E402

CFG, C = L.client()
H = CFG.hlq
LIB = f"{H}.BREXX370.TSO.LOADLIB"
DEVLIB = f"{H}.BREXX370.V3R0M0D.LINKLIB"
EXEC_DS = f"{H}.BREXX370.RXT.EXEC"
PROC_DS = f"{H}.BREXX370.RXT.PROC"

SAYARG = "say '{0} ARG=<' || arg(1) || '>'\nexit 0\n"
MEMBERS = {
    (EXEC_DS, "RXA"): SAYARG.format("RXA"),
    (EXEC_DS, "CLST"): "WRITE HELLO FROM CLIST CLST\n",
    (PROC_DS, "RXB"): "/* REXX */\n" + SAYARG.format("RXB"),
    (PROC_DS, "RXC"): "PROC 0\nWRITE HELLO FROM CLIST RXC\n",
    (PROC_DS, "RXD"): "/* A PLAIN CLIST, COMMENT IN LINE 1 */\n"
                      "WRITE HELLO FROM CLIST RXD\n",
    (PROC_DS, "NOCMT"): SAYARG.format("NOCMT"),
}

C_ = "HELLO FROM CLIST RXC"
D_ = "HELLO FROM CLIST RXD"
CLST = "HELLO FROM CLIST CLST"
SAYNF = "IKJ56479I COMMAND SAY NOT FOUND OR REXX IDENTIFIER IS MISSING"

# (command, expectation). 'ARG=<' in an expectation: look in the whole
# spool (BREXX output); otherwise in the command's part of SYSTSPRT. A
# leading '!' means it must NOT be there.
CASES = [
    # A batch TMP has no prefix; unqualified names need one.
    (f"PROFILE PREFIX({H})", ""),
    ("%RXA T01", "RXA ARG=<T01>"),
    ("RXB T02", "RXB ARG=<T02>"),
    ("%RXC", C_),
    ("%RXD", D_),
    ("%RXD", D_),
    ("%RXA T03", "RXA ARG=<T03>"),
    ("%CLST", "!" + CLST),                  # SYSEXEC: REXX, no check
    ("%NOCMT T04", SAYNF),                  # SYSPROC, no comment: CLIST
    ("%RXZZ", "IKJ56500I COMMAND RXZZ NOT FOUND"),
    (f"EXEC '{EXEC_DS}(RXA)' 'T05'", SAYNF),
    (f"EXEC '{EXEC_DS}(RXA)' 'T06' EX", "RXA ARG=<T06>"),
    (f"EXEC '{EXEC_DS}(RXA)' 'T07' E", "RXA ARG=<T07>"),
    (f"EXEC '{EXEC_DS}(RXA)' 'T08' EXEC", "RXA ARG=<T08>"),
    (f"EXEC '{PROC_DS}(RXB)' 'T09'", "RXB ARG=<T09>"),
    (f"EXEC '{EXEC_DS}(CLST)'", CLST),
    (f"EXEC '{PROC_DS}(NOCMT)' 'T10'", SAYNF),
    (f"EXEC '{PROC_DS}(NOCMT)' 'T11' EXEC", "NOCMT ARG=<T11>"),
    ("EXEC BREXX370.RXT(RXA) 'T12' EXEC", "RXA ARG=<T12>"),
    # without the keyword: .CLIST (3.8's message shows the name before
    # DAIR adds the prefix)
    ("EXEC BREXX370.RXT(RXC)", "BREXX370.RXT.CLIST NOT IN CATALOG"),
    (f"EXEC '{PROC_DS}(RXC)'", C_),
    # the argument as z/OS gives it: runs of blanks and quotes kept
    ("%RXA T13  a   b  'c'", "RXA ARG=<T13  a   b  'c'>"),
    ("TIME", "IKJ56650I"),
]

BODY = f"""
//TMP      EXEC PGM=IKJEFT01,REGION=8192K
<<STEPLIB>>//SYSEXEC  DD  DSN={EXEC_DS},DISP=SHR
//SYSPROC  DD  DSN={PROC_DS},DISP=SHR
//SYSTSPRT DD  SYSOUT=*
//SYSUDUMP DD  SYSOUT=*
//SYSTSIN  DD  *
""" + "".join(f" {cmd}\n" for cmd, _ in CASES) + "/*\n//\n"


def setup():
    for ds in (EXEC_DS, PROC_DS):
        if not C.dataset_exists(ds):
            C.create_dataset(ds, "PO", "FB", 80, 3120, ["TRK", 5, 5, 5],
                             "SYSDA")
    for (ds, mem), text in MEMBERS.items():
        C.write_member(ds, mem, text)


def split_output(tsprt):
    """Cut SYSTSPRT into the output of each command. The TMP echoes each
    input line; everything up to the next echo belongs to it."""
    lines = tsprt.splitlines()
    segs, pos = [], 0
    for i, (cmd, _) in enumerate(CASES):
        start = None
        for j in range(pos, len(lines)):
            if lines[j].strip() == cmd:
                start = j + 1
                break
        if start is None:
            segs.append(None)
            continue
        nxt = CASES[i + 1][0] if i + 1 < len(CASES) else None
        end = len(lines)
        for j in range(start, len(lines)):
            if nxt is not None and lines[j].strip() == nxt:
                end = j
                break
        segs.append("\n".join(lines[start:end]))
        pos = end
    return segs


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    if mode not in ("testlib", "installed"):
        print(__doc__)
        return 2
    setup()
    steplib = ("" if mode == "installed" else
               f"//STEPLIB  DD  DSN={LIB},DISP=SHR\n"
               f"//         DD  DSN={DEVLIB},DISP=SHR\n")
    jcl = jobcard("BRXEXECT", CFG.jes_jobclass, CFG.jes_msgclass,
                  "ZMG0001 EXEC TEST") + BODY.replace("<<STEPLIB>>", steplib)
    long = [l for l in jcl.splitlines() if l.startswith(" ") and len(l) > 72]
    if long:
        print("SYSTSIN line(s) past column 72:", *long, sep="\n  ")
        return 2
    r = C.submit_jcl(jcl, timeout=300)
    sp = r.spool or ""
    out = Path("build/tso/lab") / f"exec_test_{mode}.spool"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(sp)
    print(f"{r.jobid} {r.status} rc={r.rc}  spool: {out}")
    joblog = sp.split("--- JESYSMSG ---")[0]
    tsprt = sp.split("--- SYSTSPRT ---", 1)[1].split("\n--- ", 1)[0] \
        if "--- SYSTSPRT ---" in sp else ""
    # BREXX output: every data set after SYSTSPRT (not the echoed input)
    brexx = sp.split("--- SYSTSPRT ---", 1)[1] if tsprt else ""
    for line in joblog.splitlines():
        if re.search(r"IEA995I|IEF450I|ABEND|IEA703I", line):
            print("  joblog:", line.strip()[:100])

    bad = 0
    abend = (r.status == "ABEND" or "IEF450I" in joblog
             or "IKJ56641I" in tsprt)
    print(f"  {'FAIL' if abend else 'PASS'}  no abend "
          "(job log and TMP-caught IKJ56641I)")
    bad += abend
    for (cmd, want), seg in zip(CASES, split_output(tsprt)):
        neg = want.startswith("!")
        text = want[1:] if neg else want
        where = brexx if "ARG=<" in text else seg
        if where is None:
            ok, got = False, "(command not reached)"
        else:
            ok, got = (text not in where) if neg else (text in where), where
        print(f"  {'PASS' if ok else 'FAIL'}  {cmd:<44} "
              f"{'not ' + text if neg else text}")
        if not ok and "ARG=<" not in text:
            for g in got.splitlines()[:4]:
                print(f"          | {g.rstrip()[:90]}")
        bad += not ok
    print(f"{len(CASES) + 1 - bad}/{len(CASES) + 1} passed")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
