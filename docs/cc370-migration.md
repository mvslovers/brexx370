# Migration to mbt v2 / cc370

This document tracks the migration of BREXX/370 from the JCC compiler and the
MVS-side build engine to the [mbt](https://github.com/mvslovers/mbt) v2 host
build with the [cc370](https://github.com/mvslovers/cc370) toolchain and the
[libc370](https://github.com/mvslovers/libc370) C runtime.

**Status: runs on MVS/CE in CI (`mvs-test.yml`): smoke test and all 76
REXX tests pass (77/77 steps), no abends. The stream I/O tests pass since #140
(separate read/write positions on top of libc370#189).** Every C source
compiles, every assembler module except IRXNJE38 assembles, and BREXX plus
five standalone modules link without unresolved references. Batch, TSO in
the background (IKJEFT01) and, since #158, TSO in the foreground on a 3270
(SAY, PULL, `ADDRESS TSO`) have been exercised; sockets, NJE38 and VSAM are
untested.

The open work items are tracked in [TODO.md](../TODO.md).
The JCC build in `legacy/` is no longer maintained: the assembler routines
called from C use the cc370/libc370 (PDP) linkage now, so a JCC build of the
current tree would not work. It is kept only as a reference for the parts mbt
does not cover yet (release packaging, RXLIB/SAMPLIB/JCL, test driver).

## Building

Requirements: cc370 and libc370 installed (see their READMEs, default prefix
`~/.local`), Python 3.12+, GNU make.

```sh
git submodule update --init   # mbt
make                          # build/BREXX, IRXVTOC, IRXVSMIO, ... (+ .iebcopy)
make package                  # dist/brexx370-<version>-load.xmit (one LINKLIB)
make deploy                   # upload + RECEIVE on MVS (see mbt docs)
VERBOSE=1 make                # show the full cc370/as370/ld370 commands
```

The JCC build engine moved unchanged from `build/` to `legacy/`
(`make -C legacy SYSTEM=TK5 ...`); `build/` is now mbt's output directory.
CI:

| Workflow | Trigger | What |
|----------|---------|------|
| `build.yml` | PR, push to master | cc370 host build (mbt reusable workflow, toolchain from `main`) |
| `mvs-test.yml` | push to `master`, manual | build against the `[toolchain] libc370` ref (the release tag `v2.0.0`), deploy into an MVS/CE container, smoke test + REXX test suite (`scripts/mvstest.py`) |
| `test.yml`, `release.yml` | manual only | legacy JCC build on TK4-/TK5/MVS-CE, no longer maintained |

## What changed in the tree

| Change | Why |
|--------|-----|
| `project.toml`, 2-line `Makefile`, `mbt` submodule, `VERSION` | mbt v2 project layout |
| `build/` -> `legacy/` | `build/` is mbt's build directory |
| `asm/*.hlasm` -> `asm/*.asm`, `maclib/*.hlasm` -> `maclib/*.mac` | as370 only searches `.macro/.copy/.mac/.asm`; mbt's pattern rule is `%.asm` |
| `asm/rxtso.asm` -> `asm/rxtsoa.asm` | mbt puts all objects flat into `build/`; clashed with `src/rxtso.c` |
| `maclib/{IF,ELSEIF,ELSE,ENDIF,DO,ENDDO,#SPCND}.mac` | the legacy build took these structured macros from `SYS2.MACLIB`, which does not exist on the host. Minimal clean-room versions covering exactly the forms BREXX uses (rxinit, rxterm, rxtsoa) |
| `sysmac/` | the 33 IBM `SYS1.MACLIB`/`AMODGEN` members BREXX needs that libc370's sysroot does not ship (taken from MVS/CE 2.1.4) |
| `compat/jccompat.h`, `compat/jccompat.c` | JCC runtime API on top of libc370, force-included into every TU |
| `compat/libgcc64.c` | `__muldi3`, `__udivdi3`, `__umoddi3`, `__divdi3`, `__moddi3` (missing in libc370) |
| `inc/rxmvs.h` | more 8-character external name renames (see below) |
| `inc/rexx.h` | `VERSION` comes from `project.toml` (mbt `<buildstamp.h>`), e.g. `PARSE VERSION` -> `BREXX/370 3.0.0-dev (<date>)` |
| `maclib/MRXSTART.mac` | PDP linkage instead of the JCC stack prologue (see below) |
| `asm/mvsdump.asm` | work-around for an as370 bug (see upstream issues) |
| `src/address.c` | fd based command redirection (`RxRedirectCmd`) removed in #278: no caller since 2019 (`3f79908`) |
| `legacy/builder.py`, `legacy/Makefile` | follow the renames |

## External names (8 characters)

JCC keeps long external names (objscan/prelink). cc370 maps every external
name to 8 uppercase characters, so `RxVarFindName` and `RxVarFind` both
become `RXVARFIN`. `inc/rxmvs.h` already carried renames for an old GCC port;
it is now force-included through `compat/jccompat.h` so the renames apply in
*every* translation unit (before, only TUs including `rxdefs.h` saw them) and
was extended by 26 renames for the collisions still left.

`ld370` keeps the first definition of a duplicate symbol silently (IEWL
semantics), so collisions do not fail the link. They were checked with a
host build (`nm`, mapping each C name to its MVS name) and by listing the
ESDs of all objects (`file370 -v`) against the libc370 archive index; the
latter found `__ISPEXEC` shadowing libc370's `ispexec()` (`@@ISPEXE`). This
check should become part of the build (or of ld370, see cc370#8).

### Linkage of the assembler routines

The RXMVSEXT routines called from C (RXINIT, RXTERM, RXTSO, RXSVC, RXVSAM,
RXIKJ441, RXABEND, RXCPUTIM, RXCPCMD) enter through `MRXSTART`. For JCC it
took its frame from JCC's stack (`8(,R13)`, stack control block at
`0(,R13)`, extension routine called via `0(,RC)`); under libc370 that branched
into the stack (S0C1 on the first MVS run). `MRXSTART` now uses the PDP
linkage of cc370/libc370: the next available frame is the NAB at `76(,R13)`,
96 bytes of it become the routine's save area, the save areas are chained and
the NAB is advanced for the routine's own callees. `MRXEXIT` is unchanged (it
returns via the back chain). `RXSETJMP`/`RXECANC` are leaf routines and need
no frame.

The assembler entry points that JCC renamed via `legacy/rxmvsext.nam`
(`RXINIT` -> `call_rxinit`, `RXSETJMP` -> `_setjmp_estae`, ...) are mapped the
other way round in `compat/jccompat.h`.

## JCC runtime compatibility layer

What libc370 would have to provide to retire this layer is collected in
[libc370-jcc-gaps.md](libc370-jcc-gaps.md).

| JCC API | cc370 implementation | Status |
|---------|----------------------|--------|
| `_style` + `fopen()` (`//DDN:`, `//DSN:`) | removed: BREXX opens through `src/dsio.c` (`DD:name` / `'name'` on libc370), #299 | done |
| `fopen()` mode extensions (`,recfm=u,lrecl=..,force`, `,vtoc`, `volser=`, `dirblks=` ...) | dropped, only `record`/`bsam`/`rlse` are passed on | **gap**: `PDSdet()` (directory read), dataset creation with DCB attributes |
| `//MEM:` memory files, `//HFS:`, `//NULLFILE` | `fopen()` fails with `EINVAL` | no user left: `OPEN(…,'VIO')` (`//MEM:`) removed in #299 |
| `fileno()`, `isatty()`, `O_*`, `STD*_FILENO` | removed: no caller left in the cc370 build (`lstring/` uses `fileno()` in host code only) | done |
| `__get_ddndsnmemb()` | removed: dsio `rxFileInfo()` reads DD, DSN, member and the DCB from the libc370 `FILE`; volser and DSORG come from `rxDsAttr()` (catalog + format-1 DSCB), #299 | done |
| update modes `r+`/`w+`/`a+`, read after write | libc370#189 (in `edge`) plus BREXX's own read/write positions (#140) | done; the read guards in compat are gone, libc370#203 returns EOF on an output-only stream (#275) |
| `_open/_close/dup/dup2/fdopen` | not available | **gap** for `reopen()` (stdout/stderr, #251); the `ADDRESS` redirection had no caller and is gone (#278) |
| `_setjmp_estae/_setjmp_ecanc` | BREXX's own `RXSETJMP`/`RXECANC` (asm/rxestae.asm) | done (layout fits libc370's `jmp_buf`) |
| `_setjmp_stae/_setjmp_canc` | removed (#157): `MTT()`/`MTTX()` use libc370 `cmtt_new()`/`cmtt_get_array()` (bounds-checked copy of the table), the `rxtcp.c` X'75' probe uses `try()` (ESTAE-protected call) | done |
| `_testauth()`, `_modeset()` | `__isauth()`, `__super()`/`__prob()` | to verify on MVS |
| `_write2op()` | `wto()` | done |
| `systemTSO()` | removed; its callers use BREXX's `tsoCommand()`, the `ADDRESS TSO` path (#162) | done |
| `getlogin()` | ACEE user id | done |
| `Sleep()` | `ecb_timed_wait()` | done |
| `gettimeofday()` | `uclock64()` | done |
| `beginthread/syncthread/endthread` | libc370 cthreads (BREXX uses `startup = "crt1"`) | to verify on MVS |
| `inet_addr()`, `inet_ntoa()` | libc370 2.0 `inet_addr()` and `inet_ntop()` (libc370#51); BREXX's own copies are gone | done |
| `_msize()` | caller's size from the 8 byte prefix of libc370's `getmain()` (`ptr[-1] & 0xFFFFFF`) | done; depends on libc370 internals, IRXEXCOM's auxiliary blocks would be seen as malloc blocks |
| `entry_R13` (`[6]` = CPPL) | `jcc_cppl()` returns `__ppaget()->ppacppl`, which libc370 sets for a TSO command processor since libc370#210 (the copy from `grt->grtptrs`, #158, is gone). NULL without a CPPL (batch, TSO `CALL`): `ADDRESS TSO` then returns -3. Needs libc370 >= 832d794 | done |
| `__libc_heap_*`, `__libc_stack_*`, `__libc_arch`, `__libc_tso_status` | storage only, never updated | **gap** (statistics, TSO status) |
| `_getline()` (terminal input in `Lread`) | JCC only, falls back to `fgetc()`; on a 3270 `stdin` is DD STDIN (TERMFILE), which QSAM reads from the terminal (#158) | done |
| `strcasecmp()`, `strncasecmp()` | `jcc_strcasecmp()` (own names, no clash with libc370 `main`) | bridge until the pinned libc370 carries libc370#183 |

## JCC-only code paths

cc370 defines `BREXX_CC370`, not `JCC`. Code under `#ifdef JCC` without a
`BREXX_CC370` counterpart therefore fell to the branch written for other
platforms (PC/Unix). The JCC conditionals were removed from the built sources
in #133 (objects byte-identical before and after); the JCC branches live on
in the branch `v2.5-jcc`. Most were harmless (JCC-only includes, `__unused`, a
cast, the 8-character renames in `inc/rxmvs.h`, which are now unconditional).
These four changed behaviour, and the cc370 column is what remains:

| Place | JCC | cc370 today |
|-------|-----|-------------|
| `src/rxmvs.c` `reopen()` | re-binds `stdin`/`stdout`/`stderr` to the DDs STDIN/STDOUT/STDERR, which RXINIT allocates to the terminal in TSO foreground (`asm/rxinit.asm`, `DYNATERM`) | since #158: `stdin` is bound to DD STDIN whenever it is allocated (JCC's default); `stdout`/`stderr` stay with libc370, which already writes to the terminal |
| `lstring/read.c` | terminal input via `_getline()` (TGET) | `fgetc()` on DD STDIN, which reads the terminal (#158) |
| `inc/rexx.h` `CAT_INC`/`CODE_INC`, `lstring/lstring.c` `Lstrcat` | concatenation grows with 64 bytes spare, code buffer by 4096 | grows to the exact length (rounded to 32), code buffer by 256 — results are the same; run time measured equal 2026-09-28 (TODO.md), kept |
| `inc/config.h` `GREEK` | undefined | undefined (same) |

## Modules

| Module | Built | Notes |
|--------|-------|-------|
| BREXX | yes | AC=1, NORENT, crt1. Aliases REXX and RX (mbt#113; SMP ships them with `TALIAS`, mbt#114) |
| IRXVTOC | yes | assembles without messages since #165. `OPERS2` in vtocchek is written with `X'5F'`: as370 turned the UTF-8 `¬` into two bytes, which broke the `<`/`>=`/... operators |
| IRXVSMIO, IRXVSMTR, IRXISTAT, MVSDUMP | yes | |
| IRXNJE38 | no | needs the NJE38 macro library (`NSIO`, ...) |
| IRXEXCOM | no | "metal" module that inspects JCC malloc headers (`JCC_MEM_HEADER_LENGTH`) of storage allocated by BREXX; needs a redesign for libc370. `printf/printf.c` does not compile with cc370 yet |

Not covered by mbt yet: the RXLIB/SAMPLIB/PROCLIB/JCL datasets, the
installation JCL and the documentation that `make -C legacy release`
packages. mbt's `[distribution]` section is the candidate for this.

## Upstream issues found

* **as370** (mvslovers/cc370#465): `scan_undef_terms()` reads `L'sym` as a
  string prefix, so a following literal is scanned as code, e.g.
  `MVC F+1+L'G+3(5),=C'AB CD'` -> "Undefined symbol AB", RC=8 (IFOX00 accepts
  it). Fixed in cc370 039a968 (as370 now assembles it byte-identical to
  IFOX00); `asm/mvsdump.asm` is back to its original source. CI builds
  cc370 from `main`, so it has the fix.
* **libc370** `<stdint.h>` (mvslovers/libc370#187): no `(u)intptr_t` for i370 (defined in the compat
  header).
* **libc370** (mvslovers/libc370#187): no `__muldi3/__udivdi3/__umoddi3/__divdi3/__moddi3`, so any
  `long long` multiply/divide fails to link (provided in `compat/libgcc64.c`).
* **cc370** (mvslovers/cc370#467): signed `long long` `/` and `%` by a
  constant are inlined as a single `DR` -- wrong result, S0C9 for large
  dividends. Work-around in `lstring/mult.c`.
* **libc370** `<stdint.h>` (mvslovers/libc370#188): `INT32_MIN` is
  `0x80000000L`, a positive value; range checks against it are optimized
  away. BREXX keeps its own definitions in `inc/lstring.h`.
* **libc370** (mvslovers/libc370#189): no update modes; reading an output-only
  stream abended S400. Complete in `edge`, not in a release yet; BREXX
  relies on it without guards since #275.
* **ld370/mbt** (mvslovers/cc370#466, closed): ALIAS support now in mbt
  (mbt#113). Duplicate definitions are still dropped silently.
* **libc370** `fopen()`: no way to pass DCB attributes (RECFM/LRECL/BLKSIZE)
  for new datasets or to force RECFM=U for a directory read (no issue filed
  yet, see TODO.md).

## Next steps

See [TODO.md](../TODO.md).
