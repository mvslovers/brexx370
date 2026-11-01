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
| `lab/zmg_install.py` | `upload` (the XMIT, RECEIVE into `USERMOD.ZMG0001`), `check`, `backup`, `acceptptf` (UY16532, which MVS/CE has applied only), `receive` (member `$INSTALL`), `apply` (member `ZMG01AP`, extents before/after), `job MEMBER`, `verify`, `restore` |
| `jcl/ZMG01*.jcl` | Sources of three members of the library: `CK` check, `BK` back up EXEC, `RS` RESTORE + copy the backup back |
| `usermod/ZMG0001.mcs`, `usermod.py` | The usermod: MCS with cover letter and JCLIN; each `++MOD` carries `TXLIB(name)`. `usermod.py` builds the library `USERMOD.ZMG0001` from them, the two sources and the jobs: the members as files in `build/tso/pds/`, `build/tso/ZMG0001.zip`, and with `--xmit` `build/tso/ZMG0001.xmit` |
| `usermod/IKJCT430.o`, `usermod/IKJCT437.o` | Reference decks (as370), committed. Not shipped; `build.sh exec` proves that the sources still assemble to them, and `lmod_link.py testlib` links the tested EXEC from them |

Everything except `IKJCT437.ASM` and `usermod/ZMG0001.mcs` is taken over
from rekx370 `tso/` (main f574e90), cut down to EXEC: ZMG0001 patches no
TMP.

## Shipped as source

The usermod comes as one PDS, `USERMOD.ZMG0001`, the way RAKF 2.0.0 ships
`USERMOD.TRKF200` in `TK5INST.zip`. The release carries it twice:
`ZMG0001.xmit` (a TSO TRANSMIT file; `RECEIVE INDSN(...)
DATASET('USERMOD.ZMG0001')` unpacks it) and `ZMG0001.zip` with the same
members as text files. The members, in the order they are run:

| Member | What |
|---|---|
| `@CVRLET` | Cover letter and the MCS; each `++MOD` names its source by `TXLIB(IKJCT430)` / `TXLIB(IKJCT437)`. The cover letter lists the run order |
| `IKJCT430`, `IKJCT437` | The sources (`tso/IKJCT430.ASM`, `tso/IKJCT437.ASM`) |
| `ZMG01CK` | Job: check the prerequisites |
| `ZMG01BK` | Job: back up `SYS1.CMDLIB(EXEC,EX)` |
| `$INSTALL` | Job `ZMG01IN`: assemble, REJECT, RECEIVE, APPLY CHECK |
| `ZMG01AP` | Job: assemble again, APPLY |
| `ZMG01RS` | Job: RESTORE, and copy the backup back |

The jobs read the sources and the MCS from the library (`DSN=USERMOD.ZMG0001(member)`);
nothing is inline. `$INSTALL` (one `IFOX00` step and one `IEBGENER` step
per `++MOD`):

1. `IFOX00` assembles `IKJCT430` from the library against `SYS1.MACLIB` and
   `SYS1.AMODGEN` (`PARM='OBJECT,NODECK,NOTERM,XREF(SHORT),RENT'`),
2. `IEBGENER` writes the object plus the card
   `IDENTIFY IKJCT430('ZMG0001')` as member `IKJCT430` of the temporary
   PDS `&&TXLIB`. The first of these steps creates the PDS once
   (`DSORG=PO`, a directory), the second adds its member with
   `DISP=(MOD,PASS)`. Steps 1 and 2 run for `IKJCT437` as well,
3. `REJ` (SMP) rejects `ZMG0001`, so that the job can be run again. Its
   return code is 12 (HMA2462) when `ZMG0001` was not received, which is
   the case on the first run; SMP stops a command after an earlier code of
   12 or more in the same step, so `REJ` is a step of its own,
4. `SMP` RECEIVEs the MCS (`@CVRLET`) and runs `APPLY CHECK`; its `TXLIB`
   DDs `IKJCT430` and `IKJCT437` both point into `&&TXLIB` (the first DD
   takes the passed data set, the second refers back to the first).

The `IDENTIFY` card puts the sysmod id into the IDR record of the CSECT, so
`idrdump370` shows `ZMG0001` for `IKJCT430` and `IKJCT437` in the linked
`EXEC`. SMP adds no id of its own.

`ZMG01AP` assembles both modules again and APPLYs. SMP takes the text of a
`++MOD` from its `TXLIB` DD at APPLY time, not at RECEIVE, and the
temporary PDS is gone when `$INSTALL` ends: an APPLY without it fails with
HMA2832 ("DDCARD MISSING"). So the order matters: `$INSTALL` (receive and
check), then `ZMG01AP` (the real APPLY). The assembly is deterministic, so
the second one yields the same objects.

No data set is renamed; a failing assembly stops
the job before SMP (`COND=(0,LT)`). The object decks IFOX00 writes equal
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
python3 tso/usermod.py [--xmit]                # build/tso/pds/, ZMG0001.zip, ZMG0001.xmit
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

`--xmit` needs `xmit370` (cc370 toolchain; `make xmit370/xmit370` in
mvslovers/cc370 builds the one tool). The release workflow (`release.yml`,
job `zmg0001`) builds it from the cc370 tag pinned in `mbt.toml`, runs
`usermod.py --xmit` and attaches `ZMG0001.xmit` and `ZMG0001.zip` to the
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
python3 tso/usermod.py --xmit             # the library as XMIT
mbt run zmginstall -- upload              # RECEIVE it as USERMOD.ZMG0001
mbt run zmginstall -- check               # ZMG0001-3 free, UY16532 there (the member ZMG01CK is
                                          #   run by `job ZMG01CK`)
mbt run zmginstall -- backup              # SYS1.CMDLIB(EXEC,EX)
mbt run zmginstall -- receive             # member $INSTALL: assemble, REJECT, RECEIVE, APPLY CHECK
mbt run zmginstall -- apply               # member ZMG01AP: assemble again, APPLY; WRITES SYS1.CMDLIB
mbt run zmginstall -- verify              # SMP-built EXEC == tested EXEC
mbt run exectest -- installed             # 29/29
```

`verify` is the proof, not the condition codes: SMP can report success
and copy nothing (`NOT SEL`, root `CLAUDE.md`). The installed BREXX must
be at #358 or later, or the argument case fails.

The measurements of the first install (mvsdev, 2026-10-05) are in #353;
`internals/tso-integration.md` has the design notes.
