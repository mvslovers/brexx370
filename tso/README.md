# tso/ — usermod ZMG0001, BREXX/370 in TSO EXEC

ZMG0001 makes the TSO `EXEC` command and the implicit invocation
(`%name`, `name`) run REXX execs through BREXX, by the TSO/E rules. It is
an SMP4 usermod on FMID EBB1102 and changes one load module,
`SYS1.CMDLIB(EXEC)`. The user's guide is the section "The TSO
Integration: ZMG0001" of `docs/books/guide/ug-install.typ`. Tracking
issue: #353.

The design follows REXX/370's ZMG0002 (mvslovers/rexx370 `tso/`), and
the hook in EXEC is the same. ZMG0001, ZMG0002 and ZMG0003 (both REXX
side by side, in rexx370) change the same elements and exclude each
other.

**This is not an mbt target.** mbt builds BREXX. These are IBM sources
and our decks, assembled against the MVS/CE macro libraries of the
`mvs38src` project.

| File | What it is |
|---|---|
| `IKJCT430.ASM` | EXEC, patched to ask `IKJCT437` first (implicit and explicit hooks, the `EXEC` keyword, `.EXEC` suffix, IKJ56479I). Taken over from rexx370 main f574e90; since #364 `RXVLPTR`/`RXVLLNG` stand after `EXPAROUT` (IFOX00 gives a forward symbol in an EQU IFO231 and the value 0), the deck is unchanged |
| `IKJCT437.ASM` | Ours: finds the member (SYSUEXEC, SYSUPROC, SYSEXEC, SYSPROC, BREXX's order; BPAM), decides by line 1, LINKs `BREXX` with a CPPL of its own. IKJCT43N/IKJCT43M: IKJ56479I |
| `RXDRV.ASM` | Test driver: calls `IKJCT437` as `IKJCT430` does, from a small load module (from rexx370) |
| `build.sh` | `exec`: decks `IKJCT430.o`, `IKJCT437.o` and the unpatched `IKJCT430.orig.o`; `rxdrv`: `RXDRV.xmit` |
| `lmod_link.py` | Links EXEC on MVS against the INSTALLED module, the way SMP does: `reference` proves the IBM source reproduces it, `testlib` puts the patched EXEC into `{HLQ}.BREXX370.TSO.LOADLIB` |
| `rxdrv_test.py` | `install` RXDRV into the test library, `run` the four classifier cases |
| `lab/exec_test.py` | The EXEC rules as a 29-case table in a batch TMP: `testlib` or `installed` |
| `lab/zmg_install.py` | `check`, `backup`, `receive`, `applycheck`, `apply` (extents before/after), `verify`, `restore` |
| `jcl/ZMG01*.jcl` | The jobs shipped with a release: `CK` check, `BK` back up EXEC, `RC` RECEIVE + APPLY CHECK, `AP` APPLY, `RS` RESTORE + copy the backup back |
| `usermod/ZMG0001.mcs`, `usermod.py` | The usermod: MCS with cover letter, JCLIN and two `++MOD` decks, built into `build/tso/ZMG0001.smp` |
| `usermod/IKJCT430.o`, `usermod/IKJCT437.o` | The decks the stream is built from, committed: the release workflow builds and attaches the stream without as370 or the macro libraries (#364) |

Everything except `IKJCT437.ASM` and `usermod/ZMG0001.mcs` is taken over
from rexx370 `tso/` (main f574e90), cut down to EXEC: ZMG0001 patches no
TMP.

## Build

```sh
tso/build.sh exec && python3 tso/usermod.py    # build/tso/ZMG0001.smp
tso/build.sh rxdrv                             # build/tso/RXDRV.xmit
```

`usermod.py` takes its decks from `tso/usermod/`, not from `build/tso`.
`build.sh exec` fails when a rebuilt `IKJCT430.o` or `IKJCT437.o` differs
from the committed one; after a change to the source, `build.sh decks`
takes the rebuild over, and the new decks are committed with it. The
assembly is deterministic (`ASMDATE`/`ASMTIME` are fixed), so a deck
changes only with its source or with the assembler.

The release workflow (`release.yml`, job `zmg0001`) runs `usermod.py`
and attaches `ZMG0001.smp` and `ZMG0001-jobs.zip` (`tso/jcl`) to the
release. It does not assemble: the macro libraries live in mvs38src, and
its pinned as370 is an arm64 macOS binary. cc370's as370 1.4.0 builds the
same three decks byte for byte.

Needs `../mvs38src` (or `MVS38SRC=…`) for the pinned as370 and the macro
libraries. `build.sh` fails on any as370 diagnostic, not only on the exit
status: as370 can write an object and exit 0 at severity 8.

## Test, then install (on the `.env` stand)

```sh
python3 tso/rxdrv_test.py install && python3 tso/rxdrv_test.py run
python3 tso/lmod_link.py reference exec     # must be byte-identical
python3 tso/lmod_link.py testlib exec
python3 tso/lab/exec_test.py testlib        # 29/29
python3 tso/lab/zmg_install.py check        # ZMG0001-3 free, UY16532 there
python3 tso/lab/zmg_install.py backup       # SYS1.CMDLIB(EXEC,EX)
python3 tso/lab/zmg_install.py receive
python3 tso/lab/zmg_install.py applycheck
python3 tso/lab/zmg_install.py apply        # WRITES SYS1.CMDLIB
python3 tso/lab/zmg_install.py verify       # SMP-built EXEC == tested EXEC
python3 tso/lab/exec_test.py installed      # 29/29
```

`verify` is the proof, not the condition codes: SMP can report success
and copy nothing (`NOT SEL`, root `CLAUDE.md`). The installed BREXX must
be at #358 or later, or the argument case fails.

The measurements of the first install (mvsdev, 2026-10-05) are in #353;
`internals/tso-integration.md` has the design notes.
