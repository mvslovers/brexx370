# Migration to mbt v2 / cc370

This document tracks the migration of BREXX/370 from the JCC compiler and the
MVS-side build engine to the [mbt](https://github.com/mvslovers/mbt) v2 host
build with the [cc370](https://github.com/mvslovers/cc370) toolchain and the
[libc370](https://github.com/mvslovers/libc370) C runtime.

**Status: builds, not yet verified on MVS.** Every C source compiles, every
assembler module except IRXNJE38 assembles, and BREXX plus five standalone
modules link without unresolved references. Nothing has been run on MVS yet.
Until that has happened, the JCC build in `legacy/` stays the reference build.

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
The TK4-/TK5/MVS-CE workflows (`test.yml`, `release.yml`) use `legacy/`,
`build.yml` runs the cc370 host build on every PR.

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
| `asm/mvsdump.asm` | work-around for an as370 bug (see upstream issues) |
| `src/address.c` | fd based command redirection compiled out for cc370 |
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

The assembler entry points that JCC renamed via `legacy/rxmvsext.nam`
(`RXINIT` -> `call_rxinit`, `RXSETJMP` -> `_setjmp_estae`, ...) are mapped the
other way round in `compat/jccompat.h`.

## JCC runtime compatibility layer

What libc370 would have to provide to retire this layer is collected in
[libc370-jcc-gaps.md](libc370-jcc-gaps.md).

| JCC API | cc370 implementation | Status |
|---------|----------------------|--------|
| `_style` + `fopen()` (`//DDN:`, `//DSN:`) | `jcc_fopen()`: `DD:name` resp. `'name'` for libc370 | done |
| `fopen()` mode extensions (`,recfm=u,lrecl=..,force`, `,vtoc`, `volser=`, `dirblks=` ...) | dropped, only `record`/`bsam`/`rlse` are passed on | **gap**: `PDSdet()` (directory read), dataset creation with DCB attributes |
| `//MEM:` memory files, `//HFS:`, `//NULLFILE` | `fopen()` fails with `EINVAL` | **gap** |
| `fileno()`, `isatty()` | handle = `FILE *` | done |
| `__get_ddndsnmemb()` | from the libc370 `FILE` | partial: no volser, DSORG derived from member |
| `_open/_close/dup/dup2/fdopen` | not available | **gap**: `ADDRESS ... (STACK/FIFO/LIFO` redirection returns -3, `reopen()` is JCC only |
| `_setjmp_estae/_setjmp_ecanc` | BREXX's own `RXSETJMP`/`RXECANC` (asm/rxestae.asm) | done (layout fits libc370's `jmp_buf`) |
| `_setjmp_stae/_setjmp_canc` | stubs, no recovery established | **gap** (used by `rxtcp.c` X'75' check) |
| `_testauth()`, `_modeset()` | `__isauth()`, `__super()`/`__prob()` | to verify on MVS |
| `_write2op()` | `wto()` | done |
| `systemTSO()` | `tsocmd(name, operands)`, -1 without CPPL (as JCC) | partial: no CLIST/implicit EXEC |
| `getlogin()` | ACEE user id | done |
| `Sleep()` | `ecb_timed_wait()` | done |
| `gettimeofday()` | `uclock64()` | done |
| `beginthread/syncthread/endthread` | libc370 cthreads (BREXX uses `startup = "crt1"`) | to verify on MVS |
| `inet_addr()` | `inet_aton()` | done |
| `_msize()` | recognises BREXX's auxiliary memory header only | done for `bmem.c` |
| `entry_R13` (`[6]` = CPPL) | static save area image, word 6 from `__ppaget()->ppacppl` | done for word 6 |
| `__libc_heap_*`, `__libc_stack_*`, `__libc_arch`, `__libc_tso_status` | storage only, never updated | **gap** (statistics, TSO status) |
| `_getline()` (terminal input in `Lread`) | JCC only, falls back to `fgetc()` | to verify |

## Modules

| Module | Built | Notes |
|--------|-------|-------|
| BREXX | yes | AC=1, NORENT, crt1. **Aliases REXX and RX are missing**: ld370/mbt have no ALIAS support |
| IRXVTOC | yes | vtocprnt: as370 reports cards consumed as continuation (RC 4), identical to IFOX00 behaviour |
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
  it). Work-around in `asm/mvsdump.asm`.
* **libc370** `<stdint.h>`: no `(u)intptr_t` for i370 (defined in the compat
  header).
* **libc370**: no `__muldi3/__udivdi3/__umoddi3/__divdi3/__moddi3`, so any
  `long long` multiply/divide fails to link (provided in `compat/libgcc64.c`).
* **ld370/mbt**: no ALIAS support (BREXX needs REXX and RX); duplicate
  definitions are dropped silently.
* **libc370** `fopen()`: no way to pass DCB attributes (RECFM/LRECL/BLKSIZE)
  for new datasets or to force RECFM=U for a directory read.

## Next steps

1. Deploy to a test system (`make deploy`) and run the REXX test suite from
   `test/` (`make -C legacy test` shows how it is driven today).
2. Replace the stubs marked `TODO(cc370)` in `compat/`, starting with STAE
   recovery, the fopen DCB attributes and command redirection.
3. Aliases REXX/RX (mbt/ld370 feature or a post-link step in deploy).
4. IRXEXCOM and IRXNJE38.
5. Package the non-load-module parts of a release with mbt.
6. Drop `legacy/` once the cc370 build is the verified reference.
