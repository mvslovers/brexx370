#!/usr/bin/env python3
"""Drive a TSO session on the MVS of .env through s3270, for what needs a
3270: the FSS routines (FSSMENU, FMTLIST, ...) and anything else full
screen. Batch and a batch TMP cannot run them: FSS needs a terminal.

  python3 scripts/tsodrive.py "ALLOC F(RXLIB) DA('...') SHR REUSE" \\
      "BREXX 'IBMUSER.BREXX370.TESTS(MEMBER)'" "@Enter()" "@String(1)" \\
      "@Enter()" "@PF(3)"

Each argument is a TSO command, typed on a cleared screen and entered,
or, with a leading '@', an s3270 action sent as it is (Enter(), PF(3),
String(text), Clear(), ...). After each one the screen is printed.

Host, user and password come from .env (MBT_MVS_HOST, MBT_MVS_USER,
MBT_MVS_PASS), the port from MBT_MVS_TN3270_PORT (default 3270). The
session is always logged off at the end, also after an error: a session
left behind keeps the userid "IN USE" until it is cancelled (C U=user).
Needs s3270 (x3270 suite) on the PATH.
"""
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def load_env():
    env = dict(os.environ)
    dotenv = ROOT / ".env"
    if dotenv.exists():
        for line in dotenv.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, value = line.split("=", 1)
                env.setdefault(key, value)
    return env


ENV = load_env()
P = subprocess.Popen(["s3270"], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                     text=True, bufsize=1)


def cmd(action, report=False):
    """Run one s3270 action; return (data lines, ok)."""
    P.stdin.write(action + "\n")
    P.stdin.flush()
    data = []
    while True:
        line = P.stdout.readline().rstrip("\n")
        if line in ("ok", "error") or not line:
            if line == "error" and report:
                print("  !! error on", action, data)
            return data, line == "ok"
        if line.startswith("data: "):
            data.append(line[6:])


def screen():
    return cmd("Ascii()")[0]


def show(title):
    print("=====", title)
    for line in screen():
        if line.strip() and "HASP165" not in line:
            print("  ", line.rstrip())


def settle(seconds=3):
    cmd("Wait(20,Output)")
    cmd("Wait(%d,Seconds)" % seconds)


def ready():
    return any(line.strip() == "READY" for line in screen())


def to_ready(tries=15):
    """Page through '***' until READY."""
    for _ in range(tries):
        if ready():
            return True
        if any("***" in line for line in screen()):
            cmd("Enter()")
            settle(2)
            continue
        cmd("Wait(2,Seconds)")
    return ready()


def type_enter(text):
    cmd("Wait(10,InputField)")
    if not cmd('String("%s")' % text.replace("\\", "\\\\").replace('"', '\\"'))[1]:
        print("  !! String failed")
    cmd("Enter()")


def main(steps):
    host = ENV.get("MBT_MVS_HOST")
    port = ENV.get("MBT_MVS_TN3270_PORT", "3270")
    cmd("Connect(%s:%s)" % (host, port))
    cmd("Wait(10,Output)")
    # the logon: the prompt comes a moment after CLEAR, and a string typed
    # before it is lost, so wait for the output and then some more
    cmd("Clear()")
    cmd("Wait(10,Output)")
    cmd("Wait(2,Seconds)")
    cmd('String("%s/%s")' % (ENV["MBT_MVS_USER"], ENV["MBT_MVS_PASS"]))
    cmd("Enter()")
    cmd("Wait(20,Output)")
    cmd("Wait(5,Seconds)")
    logged_on = to_ready()
    rc = 0 if logged_on else 8
    try:
        show("logon, READY=%s" % logged_on)
        if logged_on:
            for step in steps:
                if step.startswith("@"):
                    cmd(step[1:], report=True)
                    settle(3)
                    show(step[1:])
                else:
                    cmd("Clear()")
                    settle(1)
                    type_enter(step)
                    settle(4)
                    show(step)
    finally:
        if logged_on:
            for _ in range(4):
                if to_ready(3):
                    break
                cmd("PF(3)")
                settle(2)
            cmd("Clear()")
            settle(1)
            type_enter("LOGOFF")
            settle(3)
            show("LOGOFF")
        cmd("Disconnect()")
        P.stdin.close()
        P.wait(10)
    return rc


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
