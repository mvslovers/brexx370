# tso/ — usermod ZMG0001, BREXX/370 in TSO EXEC

ZMG0001 makes the TSO `EXEC` command and the implicit invocation
(`%name`, `name`) run REXX execs through BREXX, by the TSO/E rules. It is
an SMP4 usermod on FMID EBB1102 and changes one load module,
`SYS1.CMDLIB(EXEC)`. The user's guide is the section "The TSO
Integration: ZMG0001" of `docs/books/guide/ug-install.typ`. Tracking
issue: #353.

The design follows REKX/370's ZMG0002 (mvslovers/rekx370 `tso/`), and
the hook in EXEC is the same. ZMG0001, ZMG0002 and ZMG0003 (both REXX
side by side, in rekx370) change the same elements and exclude each
other.

**This is not an mbt target.** mbt builds BREXX. These are IBM sources
and our own, which the usermod ships as source and the target assembles
(see "Shipped as source" below); the reference decks are assembled with
as370 against the macro libraries of the `mvs38src` project.

| File | What it is |
|---|---|
| `IKJCT430.ASM` | EXEC, patched to ask `IKJCT437` first (implicit and explicit hooks, the `EXEC` keyword, `.EXEC` suffix, IKJ56479I). Taken over from rekx370 main f574e90; since #364 `RXVLPTR`/`RXVLLNG` stand after `EXPAROUT` (IFOX00 gives a forward symbol in an EQU IFO231 and the value 0), the deck is unchanged |
| `IKJCT437.ASM` | Ours: finds the member (SYSUEXEC, SYSUPROC, SYSEXEC, SYSPROC, BREXX's order; BPAM), decides by line 1, LINKs `BREXX` with a CPPL of its own. IKJCT43N/IKJCT43M: IKJ56479I |
| `RXDRV.ASM` | Test driver: calls `IKJCT437` as `IKJCT430` does, from a small load module (from rekx370) |
| `build.sh` | `exec`: decks `IKJCT430.o`, `IKJCT437.o` and the unpatched `IKJCT430.orig.o`; `rxdrv`: `RXDRV.xmit` |
| `lmod_link.py` | Links EXEC on MVS against the INSTALLED module, the way SMP does: `reference` proves the IBM source reproduces it, `testlib` puts the patched EXEC into `{HLQ}.BREXX370.TSO.LOADLIB` |
| `rxdrv_test.py` | `install` RXDRV into the test library, `run` the four classifier cases |
| `lab/exec_test.py` | The EXEC rules as a 29-case table in a batch TMP: `testlib` or `installed` |
| `lab/zmg_install.py` | `check`, `backup`, `acceptptf` (UY16532, which MVS/CE has applied only), `receive`, `applycheck`, `apply` (extents before/after), `verify`, `restore` |
| `jcl/ZMG01*.jcl` | The jobs shipped with a release: `CK` check, `BK` back up EXEC, `AP` APPLY, `RS` RESTORE + copy the backup back. `RC` is not in the directory: `usermod.py` builds it |
| `usermod/ZMG0001.mcs`, `usermod.py` | The usermod: MCS with cover letter and JCLIN, and a line `<<ASM name>>` after each `++MOD`. `usermod.py` builds the job `ZMG01RC` from them and the two sources: `build/tso/jcl/ZMG01RC.jcl` |
| `usermod/IKJCT430.o`, `usermod/IKJCT437.o` | Reference decks (as370), committed. Not shipped; `build.sh exec` proves that the sources still assemble to them, and `lmod_link.py testlib` links the tested EXEC from them |

Everything except `IKJCT437.ASM` and `usermod/ZMG0001.mcs` is taken over
from rekx370 `tso/` (main f574e90), cut down to EXEC: ZMG0001 patches no
TMP.

## Shipped as source

The usermod comes as source, the way RAKF ships `$RAK0001`. The job
`ZMG01RC` (built by `usermod.py`, one `IFOX00` step per `++MOD`):

1. `IEBGENER` writes the MCS to `&&SMPMCS`,
2. `IFOX00` assembles `IKJCT430` against `SYS1.MACLIB` and
   `SYS1.AMODGEN` (`PARM='OBJECT,NODECK,NOTERM,XREF(SHORT),RENT'`) and
   appends the object with `SYSGO DISP=(MOD,PASS)`; the same for
   `IKJCT437`,
3. `SMP` RECEIVEs `&&SMPMCS` and runs `APPLY CHECK`.

Nothing is uploaded and no data set is renamed; a failing assembly stops
the job before SMP (`COND=(4,LT)`). The object decks IFOX00 writes equal
the as370 decks in `usermod/` in text, ESD and RLD; only the IDR on the
END card (translator, version, date) differs: `15741SC103 0201` with the
assembly date from IFOX00, `ASM370 0100 26278` from as370. Measured on TK5
and MVS/CE, 2026-11-01: IFOX00 RC 0 for both modules on both.

`zmginstall verify` stays mandatory, because the objects are the ones the
target made: it compares the EXEC that SMP linked from the IFOX00 objects
with the EXEC tested from the as370 decks, byte by byte. 26840 bytes, 0
differ, on both systems. It fails, and says so, when the test library or
one of the two AMBLIST listings is missing.

## Build

```sh
python3 tso/usermod.py                         # build/tso/jcl/ZMG01RC.jcl
tso/build.sh exec                              # reference decks, == usermod/
tso/build.sh rxdrv                             # build/tso/RXDRV.xmit
```

`usermod.py` checks the job before it writes it: every MCS line fits 72
columns, every source card 80 and is plain ASCII, no source card starts
with `//`, `/*` or `++` (JES would end the in-stream data there), and
every JCL card of the job itself ends before column 72.
`build.sh exec` fails when a rebuilt `IKJCT430.o` or `IKJCT437.o` differs
from the committed one; after a change to the source, `build.sh decks`
takes the rebuild over, and the new decks are committed with it. The
assembly is deterministic (`ASMDATE`/`ASMTIME` are fixed), so a deck
changes only with its source or with the assembler.

The release workflow (`release.yml`, job `zmg0001`) runs `usermod.py`
and attaches `ZMG0001-jobs.zip` (`tso/jcl` plus `ZMG01RC`) to the
release. It needs neither as370 nor the macro libraries: the target
assembles.

Needs `../mvs38src` (or `MVS38SRC=…`) for `build.sh`, for the pinned
as370 and the macro libraries. `build.sh` fails on any as370 diagnostic,
not only on the exit status: as370 can write an object and exit 0 at
severity 8.

## Test, then install (on mbt's target)

The tools run as mbt commands (`mbt/init.lua`), which hand them the target
and mbt's mvsMF session; `--target NAME` before `--` picks another system.

```sh
mbt run rxdrv -- install && mbt run rxdrv -- run
mbt run lmodlink -- reference exec        # must be byte-identical
mbt run lmodlink -- testlib exec
mbt run exectest -- testlib               # 29/29
mbt run zmginstall -- check               # ZMG0001-3 free, UY16532 there
mbt run zmginstall -- backup              # SYS1.CMDLIB(EXEC,EX)
mbt run zmginstall -- receive             # assemble, RECEIVE, APPLY CHECK
mbt run zmginstall -- applycheck
mbt run zmginstall -- apply               # WRITES SYS1.CMDLIB
mbt run zmginstall -- verify              # SMP-built EXEC == tested EXEC
mbt run exectest -- installed             # 29/29
```

`verify` is the proof, not the condition codes: SMP can report success
and copy nothing (`NOT SEL`, root `CLAUDE.md`). The installed BREXX must
be at #358 or later, or the argument case fails.

The measurements of the first install (mvsdev, 2026-10-05) are in #353;
`internals/tso-integration.md` has the design notes.
