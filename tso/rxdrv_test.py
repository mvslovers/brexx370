#!/usr/bin/env python3
"""tso/rxdrv_test.py - run ZMG0001's IKJCT437 through RXDRV on MVS.

Run from the repository root (mbt's mvsMF client and .env):

    tso/build.sh rxdrv
    python3 tso/rxdrv_test.py install   # RXDRV -> {HLQ}.BREXX370.TSO.LOADLIB
    python3 tso/rxdrv_test.py run       # batch TMP job, prints SYSTSPRT

RXDRV calls IKJCT437 the way IKJCT430 does, from a small load module, so
the classifier and the LINK to BREXX are tested before EXEC is relinked.
It must run as a TSO COMMAND: TSO CALL passes a PARM list, not a CPPL.

install RECEIVEs RXDRV into a test library of its own, outside the link
list. It needs no APF authorization: ZMG0001 patches no TMP, and an
unauthorized batch TMP runs EXEC and BREXX the same way. The STEPLIB of
run is that library, then the dev LINKLIB, where IKJCT437 finds BREXX.

run sets up {HLQ}.BREXX370.RXT.EXEC and .PROC and drives:
    RXA   in SYSEXEC, no comment   -> REXX
    RXB   in SYSPROC, /* REXX */   -> REXX
    RXC   in SYSPROC, CLIST        -> not REXX
    RXZZ  nowhere                  -> not REXX
The verdicts are WTOs in the job log, an exec's SAY is in SYSTSPRT.

Taken over from mvslovers/rexx370 tso/rxdrv_test.py (main f574e90).
"""
import sys
from pathlib import Path

sys.path.insert(0, "mbt/scripts")
from mbt.config import MbtConfig  # noqa: E402
from mbt.jcl import jobcard  # noqa: E402
from mbt.mvsmf import MvsMFClient  # noqa: E402

XMIT = Path("build/tso/RXDRV.xmit")

MEMBERS = {
    "EXEC": {
        "RXA": "say 'RXA FROM SYSEXEC, NO COMMENT, ARG=<'arg(1)'>'\nexit 0\n",
    },
    "PROC": {
        "RXB": "/* REXX */\nsay 'RXB FROM SYSPROC WITH REXX COMMENT'\nexit 0\n",
        "RXC": "PROC 0\nWRITE RXC IS A CLIST\n",
    },
}


def client():
    cfg = MbtConfig("project.toml")
    return cfg, MvsMFClient(host=cfg.mvs_host, port=cfg.mvs_port,
                            user=cfg.mvs_user, password=cfg.mvs_pass)


def show(r, keys):
    print(f"job {r.jobname} {r.jobid}: {r.status} rc={r.rc}")
    for line in (r.spool or "").splitlines():
        if any(k in line for k in keys):
            print("  ", line.rstrip()[:110])


def install():
    cfg, c = client()
    stage = f"{cfg.hlq}.BREXX370.TSO.XMIT"
    lib = f"{cfg.hlq}.BREXX370.TSO.LOADLIB"
    for dsn in (stage, lib):
        if c.dataset_exists(dsn):
            c.delete_dataset(dsn)
    c.create_dataset(stage, "PS", "FB", 80, 3120, ["TRK", 10, 5], "SYSDA")
    c.upload_binary(stage, XMIT.read_bytes())
    jcl = jobcard("BRXDRVIN", cfg.jes_jobclass, cfg.jes_msgclass,
                  "RXDRV INSTALL") + f"""
//RECV     EXEC PGM=IKJEFT01,REGION=4096K
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
 RECEIVE INDSN('{stage}') -
   DATASET('{lib}')
/*
//
"""
    r = c.submit_jcl(jcl, timeout=300)
    show(r, ("IEF142I", "RECEIVE", "Receive", "IKJ"))
    print("members:", c.list_members(lib))
    return 0 if r.rc == 0 else 1


def setup(cfg, c):
    for kind, members in MEMBERS.items():
        dsn = f"{cfg.hlq}.BREXX370.RXT.{kind}"
        if not c.dataset_exists(dsn):
            c.create_dataset(dsn, "PO", "FB", 80, 3120, ["TRK", 5, 5, 5],
                             "SYSDA")
        for name, text in members.items():
            c.write_member(dsn, name, text)


def run():
    cfg, c = client()
    setup(cfg, c)
    h = cfg.hlq
    jcl = jobcard("BRXCT437", cfg.jes_jobclass, cfg.jes_msgclass,
                  "IKJCT437 RXDRV") + f"""
//TMP      EXEC PGM=IKJEFT01,REGION=8192K
//STEPLIB  DD  DSN={h}.BREXX370.TSO.LOADLIB,DISP=SHR
//         DD  DSN={h}.BREXX370.V3R0M0D.LINKLIB,DISP=SHR
//SYSEXEC  DD  DSN={h}.BREXX370.RXT.EXEC,DISP=SHR
//SYSPROC  DD  DSN={h}.BREXX370.RXT.PROC,DISP=SHR
//SYSTSPRT DD  SYSOUT=*
//SYSUDUMP DD  SYSOUT=*
//SYSTSIN  DD  *
 RXDRV RXA
 RXDRV RXB
 RXDRV RXC
 RXDRV RXZZ
/*
//
"""
    r = c.submit_jcl(jcl, timeout=300)
    show(r, ("RXDRV", "RXA", "RXB", "RXC", "IKJ", "IEC", "ABEND",
             "BRX", "Error"))
    return 0 if r.rc == 0 else 1


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "install":
        sys.exit(install())
    if cmd == "run":
        sys.exit(run())
    print(__doc__)
    sys.exit(2)
