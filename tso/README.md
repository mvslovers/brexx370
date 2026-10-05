# tso/ — usermod ZMG0001, BREXX/370 in TSO EXEC

ZMG0001 makes the TSO `EXEC` command and the implicit invocation
(`%name`, `name`) run REXX execs through BREXX, by the TSO/E rules. It is
an SMP4 usermod on FMID EBB1102 and changes one load module,
`SYS1.CMDLIB(EXEC)`. The user's guide is `docs/source/installation.rst`,
section "TSO integration". Tracking issue: #353.

The design follows REXX/370's ZMG0002 (mvslovers/rexx370 `tso/`), and
the hook in EXEC is the same. ZMG0001, ZMG0002 and ZMG0003 (both REXX
side by side, in rexx370) change the same elements and exclude each
other.

**This is not an mbt target.** mbt builds BREXX. These are IBM sources
and our decks, assembled against the MVS/CE macro libraries of the
`mvs38src` project.

| File | What it is |
|---|---|
| `IKJCT430.ASM` | EXEC, patched to ask `IKJCT437` first (implicit and explicit hooks, the `EXEC` keyword, `.EXEC` suffix, IKJ56479I). Taken over unchanged from rexx370 main f574e90 |
| `IKJCT437.ASM` | Ours: finds the member (SYSEXEC, then SYSPROC; BPAM), decides by line 1, LINKs `BREXX` with a CPPL of its own. IKJCT43N/IKJCT43M: IKJ56479I |
| `RXDRV.ASM` | Test driver: calls `IKJCT437` as `IKJCT430` does, from a small load module (from rexx370) |
| `build.sh` | `exec`: decks `IKJCT430.o`, `IKJCT437.o` and the unpatched `IKJCT430.orig.o`; `rxdrv`: `RXDRV.xmit` |
| `lmod_link.py` | Links EXEC on MVS against the INSTALLED module, the way SMP does: `reference` proves the IBM source reproduces it, `testlib` puts the patched EXEC into `{HLQ}.BREXX370.TSO.LOADLIB` |
| `rxdrv_test.py` | `install` RXDRV into the test library, `run` the four classifier cases |
| `lab/exec_test.py` | The EXEC rules as a 24-case table in a batch TMP: `testlib` or `installed` |
| `lab/zmg_install.py` | `check`, `backup`, `receive`, `applycheck`, `apply` (extents before/after), `verify`, `restore` |
| `usermod/ZMG0001.mcs`, `usermod.py` | The usermod: MCS with cover letter, JCLIN and two `++MOD` decks, built into `build/tso/ZMG0001.smp` |

Everything except `IKJCT437.ASM` and `usermod/ZMG0001.mcs` is taken over
from rexx370 `tso/` (main f574e90), cut down to EXEC: ZMG0001 patches no
TMP.

## Build

```sh
tso/build.sh exec && python3 tso/usermod.py    # build/tso/ZMG0001.smp
tso/build.sh rxdrv                             # build/tso/RXDRV.xmit
```

Needs `../mvs38src` (or `MVS38SRC=…`) for the pinned as370 and the macro
libraries. `build.sh` fails on any as370 diagnostic, not only on the exit
status: as370 can write an object and exit 0 at severity 8.

## Test, then install (on the `.env` stand)

```sh
python3 tso/rxdrv_test.py install && python3 tso/rxdrv_test.py run
python3 tso/lmod_link.py reference exec     # must be byte-identical
python3 tso/lmod_link.py testlib exec
python3 tso/lab/exec_test.py testlib        # 24/24
python3 tso/lab/zmg_install.py check        # ZMG0001-3 free, UY16532 there
python3 tso/lab/zmg_install.py backup       # SYS1.CMDLIB(EXEC,EX)
python3 tso/lab/zmg_install.py receive
python3 tso/lab/zmg_install.py applycheck
python3 tso/lab/zmg_install.py apply        # WRITES SYS1.CMDLIB
python3 tso/lab/zmg_install.py verify       # SMP-built EXEC == tested EXEC
python3 tso/lab/exec_test.py installed      # 24/24
```

`verify` is the proof, not the condition codes: SMP can report success
and copy nothing (`NOT SEL`, root `CLAUDE.md`). The installed BREXX must
be at #358 or later, or the argument case fails.

The measurements of the first install (mvsdev, 2026-10-05) are in #353;
`internals/tso-integration.md` has the design notes.
