# JCC features missing in libc370

BREXX/370 was written against the JCC runtime. For the cc370 build,
`compat/jccompat.h` / `compat/jccompat.c` / `compat/libgcc64.c` rebuild the
parts of that runtime BREXX uses on top of libc370. This document lists
what libc370 would need to provide so that the compatibility layer can
shrink again, ideally to nothing.

Each entry names the JCC API, where BREXX uses it, what the compat layer
does today, and what a libc370 feature would look like. Priorities:

* **P1**: missing today, BREXX functionality is lost or unsafe
* **P2**: emulated in compat, but belongs in libc370 (other ports need it too)
* **P3**: cosmetic / statistics

See [cc370-migration.md](cc370-migration.md) for the overall migration state.

## Summary

| # | JCC feature | Used in | compat today | Prio |
|---|-------------|---------|--------------|------|
| 1 | `__muldi3`, `__udivdi3`, `__umoddi3`, `__divdi3`, `__moddi3` | any `long long` `*` `/` `%` | `compat/libgcc64.c` | P2 |
| 2 | `(u)intptr_t` in `<stdint.h>` | everywhere | typedef in compat | P2 |
| 3 | `fopen()` DCB attributes (`recfm=`, `lrecl=`, `blksize=`, `klen=`, `force`) | `rxmvs.c` `PDSdet()`, dataset creation | dropped | **P1** |
| 4 | `fopen()` new dataset allocation (`volser=`, `unit=`, `pri=`, `sec=`, `dirblks=`, `notcat`, `dontcat`) | `preload.c`, `util.c` | dropped | **P1** |
| 5 | `fopen(..., ",vtoc")` | VTOC access | dropped | P1 |
| 6 | memory files `//MEM:` | `address.c`, `rxfiles.c` | `fopen()` fails | **P1** |
| 7 | fd layer `open/_open/close/_close/dup/dup2/fdopen` | `address.c` (ADDRESS redirection), `rxmvs.c` `reopen()` | compiled out | **P1** |
| 8 | STAE based `_setjmp_stae()` / `_setjmp_canc()` | `rxtcp.c`, `rxmvs.c` | stubs, no recovery | **P1** |
| 9 | `_style` (default name style for `fopen`) | `rexx.c`, `rxfiles.c`, `rxexecio.c`, `rxmvs.c` | `jcc_fopen()` wrapper | P2 |
| 10 | `fileno()`, `isatty()` | `rexx.c`, `rxmvs.c`, `lstring/*.c` | handle = `FILE *` | P2 |
| 11 | `__get_ddndsnmemb()` (DD, DSN, member, volser, JFCB extract) | `rexx.c`, `rxmvs.c` `parseDCB()` | from `FILE`, no volser/DSORG | P2 |
| 12 | `_getline()` (TGET line read for terminals) | `lstring/read.c` | JCC only, falls back to `fgetc()` | P2 |
| 13 | `entry_R13` (entry save area, `[6]` = CPPL) | `brexx.c`, `hostenv.c`, `rxmvs.c` | built from `ppa->ppacppl` | P2 |
| 14 | `systemTSO()` (run a TSO command line) | `address.c`, `rxnje.c` | `tsocmd(name, operands)` | P2 |
| 15 | `beginthread()` / `syncthread()` / `endthread()` | `rxnje.c` | cthreads | P2 |
| 16 | `Sleep(ms)` | `rxmvs.c`, `rxnje.c`, `fss.c` | `ecb_timed_wait()` | P2 |
| 17 | `gettimeofday()` + `struct timezone` | `lstring/time.c` | `uclock64()` | P2 |
| 18 | `inet_addr()` | `rxtcp.c` | `inet_aton()` | P2 |
| 19 | `getlogin()` | `brexx.c`, `rxmvs.c`, `rxnje.c`, `smf.c` | ACEE user id | P2 |
| 20 | `_testauth()`, `_modeset()` | `rxmvs.c` | `__isauth()`, `__super()`/`__prob()` | P2 |
| 21 | `_write2op()` | `rxtso.c`, `rxmvs.c`, `fss.c` | `wto()` | P2 |
| 22 | `strupr()` | `rxfss.c` | compat | P3 |
| 23 | `_msize()` | `bmem.c` | size from libc370's getmain prefix (`ptr[-1]`) | P2 |
| 24 | `__libc_heap_used/max`, `__libc_stack_used/max` | `rxmvs.c` (STORAGE info), `bmem.c` | storage only, always 0 | P3 |
| 25 | `__libc_tso_status`, `__libc_arch` | `brexx.c`, `rxmvs.c` | storage only, always 0 | P3 |
| 26 | winsock names (`SOCKET`, `SOCKET_ERROR`, `WSAE*`, `LPSOCKADDR`, ...) | `rxtcp.c` | macros | P3 |
| 27 | `O_*` open flags, `STDIN_FILENO` ... | `address.c`, `rxmvs.c` | macros | P3 |
| 28 | `strcasecmp()`, `strncasecmp()` | `rxfss.c`, `rxvsamio.c` | `jcc_strcasecmp()` | done in libc370 `main` (libc370#183), not yet released |

## Pinned release

`project.toml` pins `[toolchain] libc370 = "1.0.6"`, the current release and
the one mvsmf builds against. #28 is already in libc370 `main` but not in
1.0.6, so compat bridges it under its own names (`JCCSCASE`, `JCCSNCAS`);
that way a build against `main` (CI `build.yml`) does not collide with
libc370's `STRCASEC`/`STRNCASE`. Both builds were checked: 1.0.6 and `main`
(1.0.7-dev) link without unresolved references and without duplicate or
shadowed symbols. Drop the bridge when the pin moves to the release that
carries libc370#183.

## Not gaps: provided by BREXX itself

Some names look like JCC runtime functions, but BREXX implements them in its
own assembler modules. The JCC build renamed their entry points with
`objscan` (`legacy/rxmvsext.nam`); the cc370 build maps the C names to the
real MVS entry points in `compat/jccompat.h` instead of stubbing them:

| C name | Entry point | Source |
|--------|-------------|--------|
| `_setjmp_estae` | `RXSETJMP` | `asm/rxestae.asm` |
| `_setjmp_ecanc` | `RXECANC` | `asm/rxestae.asm` |
| `cputime` | `RXCPUTIM` | `asm/rxcputim.asm` |
| `systemCP` | `RXCPCMD` | `asm/rxcpcmd.asm` |
| `call_rxinit`, `call_rxterm`, `call_rxtso`, `call_rxsvc`, `call_rxvsam`, `call_rxikj441`, `call_rxabend` | `RXINIT`, `RXTERM`, `RXTSO`, `RXSVC`, `RXVSAM`, `RXIKJ441`, `RXABEND` | `asm/rx*.asm` |

`jmp_buf` layout check for `RXSETJMP`: it stores R1-R14 (`STM R1,R14,0(R15)`,
14 words = 56 bytes) into the caller's `jmp_buf` and reloads them from there.
JCC's `jmp_buf` is `long[14]` (56 bytes); libc370's is
`struct { int regs[15]; int retval; }[1]` (64 bytes). The libc370 buffer is
larger, so `RXSETJMP` fits. The buffer is only used by `RXSETJMP`/its retry
routine, never by libc370's `setjmp()`/`longjmp()`, so the different field
layout does not matter. The SDWA copy on an abend is 512 bytes, which matches
the `sdwa512` buffers BREXX passes (`brexx.c`).

Still to verify on MVS: these routines were written for JCC's linkage; they
use standard OS linkage (R13 save area, R14 return, R1 parameter list of
values), which cc370's `PDPPRLG` code also uses.

## Details

### 1. 64-bit integer helpers (P2, mvslovers/libc370#187)

GCC emits calls to `__muldi3`, `__divdi3`, `__udivdi3`, `__moddi3`,
`__umoddi3` (MVS `@@MULDI3`, `@@DIVDI3`, `@@UDIVDI`, `@@MODDI3`, `@@UMODDI`)
for `long long` multiply, divide and remainder. libc370 is cc370's libgcc but
ships only its own `__64` routines (`@@64MUL`, `@@64DIV`, ...), so plain C
code using `long long` does not link. `compat/libgcc64.c` implements the five
routines on 32-bit halves (host-tested against native arithmetic on 2 million
random operand pairs). **Proposal:** move them into libc370 unchanged, and
check whether GCC can also emit calls to other `__*di3` helpers
(`__ashldi3`, `__lshrdi3`, `__ashrdi3`, `__cmpdi2`, ...) with the i370 backend.

### 2. `(u)intptr_t` (P2, mvslovers/libc370#187)

libc370's `<stdint.h>` only defines `(u)intptr_t` for a list of host CPUs
(`__i386__`, `__x86_64__`, ...); i370 is not among them. **Proposal:**
`typedef unsigned int uintptr_t; typedef int intptr_t;` plus the limits for
`__MVS__`.

### 3.-5. `fopen()` dataset attributes, allocation and VTOC (P1)

JCC's `fopen()` mode string takes
`,recfm=u|f[b]|v[b],blksize=x,lrecl=y,klen=z` as defaults for datasets whose
attributes the system does not return, `,force` to put them into the DCB
before OPEN, `volser=,unit=,pri=,sec=,rlse,dirblks=,notcat,dontcat` to
allocate new datasets and PDSs, and `,vtoc` to read a VTOC. libc370 knows
only `record`, `bsam` and `rlse`. BREXX uses this to

* read a PDS directory as RECFM=U 256 byte blocks (`PDSdet()`, `rxmvs.c`
  `fopen(name, "rb,klen=0,lrecl=256,blksize=256,recfm=u,force")`),
* create datasets from REXX (`preload.c`: `...,pri=30,sec=30,dirblks=50`),
* build DCB strings in `util.c`.

**Proposal:** parse these keywords in `@@fpmode.c` and pass them to the
existing allocation (`__dsalc()`) / DCB setup. `,vtoc` could build on
libc370's existing DSCB/`clibdscb.h` support.

### 6. Memory files `//MEM:` (P1)

Used for `ADDRESS` command output redirection (`address.c`, `//MEM:OUT`) and
in `rxfiles.c`. **Proposal:** a memory-backed `FILE` in libc370 (open by
name, readable after close within the same program).

### 7. File descriptor layer (P1)

`address.c` redirects stdin/stdout of a host command with
`dup/open/dup2/close/fdopen` (`ADDRESS ... (STACK`, `(FIFO`, `(LIFO`),
`rxmvs.c` `reopen()` re-opens stdin/stdout/stderr on DDs. libc370 has no fd
layer. In the cc370 build the redirection returns -3. **Proposal:** either a
minimal fd table over `FILE *` (0/1/2 plus `dup/dup2/fdopen`), or a libc370
API to swap `stdin`/`stdout`/`stderr` (e.g. `freopen()` on DD names plus a way
to restore the previous stream), after which BREXX would use that API instead.

### 8. STAE based setjmp (P1)

JCC's `_setjmp_stae(jmp_buf, char *sdwa104)` establishes a STAE exit and
returns like `setjmp()`: 0 when established, non-zero after an abend was
intercepted (the SDWA is copied into the 104 byte buffer); `_setjmp_canc()`
cancels it. `rxtcp.c` uses it to probe for the X'75' TCP/IP SVC, `rxmvs.c`
for protected storage access. The compat layer returns 0 and establishes
nothing, so an abend in these paths is not intercepted. **Proposal:** build it
on libc370's `__estae()` / `try()`; alternatively BREXX could reuse its own
`RXSETJMP` (ESTAE) with a 512 byte SDWA buffer.

### 9. `_style` (P2)

JCC resolves a plain `fopen()` name through `_style` (`"//DDN:"` by default,
`"//DSN:"` for a fully qualified dataset name, `"//MEM:"`, `"//HFS:"`), and a
name may carry the style as a prefix. libc370 uses `DD:name` and treats a
plain name as a dataset name (with the TSO prefix unless quoted).
`jcc_fopen()` (every `fopen()` call is redirected to it) translates.
**Proposal:** nothing for libc370 if the compat wrapper is acceptable;
otherwise a libc370 hook for a default name style.

### 10.-11. `fileno()`, `isatty()`, `__get_ddndsnmemb()` (P2)

BREXX only needs a handle to ask for the dataset information of an open
stream and whether it is a terminal. The compat layer uses the `FILE *` as
handle. `__get_ddndsnmemb()` returns DD, DSN, member, volser and an 11 byte
JFCB extract (TSDM, IND1/2, KEYLEN, DSORG, RECFM, BLKSIZE, LRECL) that
`parseDCB()` turns into `SYSDSORG`, `SYSRECFM`, `SYSBLKSIZE`, `SYSLRECL`,
`SYSVOLUME`. libc370's `FILE` has DD, DSN, member, RECFM, LRECL and BLKSIZE,
but no volser and no DSORG. **Proposal:** keep volser and DSORG (from the
JFCB/DSCB at OPEN) in the `FILE`, and provide `fileno()`/`isatty()`.

### 12. `_getline()` (P2)

JCC reads a terminal line with TGET (`lstring/read.c`, only when
`isatty()`). The cc370 build reads with `fgetc()` on the terminal `FILE`.
**Proposal:** verify libc370's terminal input behaves the same (line mode,
prompt), otherwise a `getline`-style TGET helper.

### 13. `entry_R13` (P2)

JCC exposes the caller's save area at program entry; BREXX reads word 6 (R1
at entry = the CPPL under TSO) in eight places. The compat layer returns a
static save area image with word 6 taken from `__ppaget()->ppacppl`, NULL
without a PPA. **Proposal:** a documented libc370 accessor for the CPPL /
entry R1 (e.g. `__cppl()`), and BREXX uses it directly.

### 14. `systemTSO()` (P2)

JCC takes a complete command line, runs it with a CPPL and returns -1 when
the program was not invoked with a CPPL. libc370's `tsocmd(pgm, operands)`
takes the command name separately and does not handle CLISTs/implicit EXEC.
The compat layer splits the command name off. **Proposal:** a libc370
`system()`-like TSO entry taking a command line.

### 15. Threads (P2)

`rxnje.c` runs the NJE38 receiver in a subtask with JCC's
`beginthread/syncthread/endthread`. The compat layer maps them to libc370
cthreads (`cthread_create[_ex]`, wait on `termecb` + `cthread_detach`,
`cthread_exit`), which needs the `crt1` startup. **Proposal:** thin JCC-style
wrappers in libc370 are optional; the mapping is small.

### 16.-21. Small functions (P2)

* `Sleep(ms)`: libc370 only has `sleep(seconds)`; compat uses
  `ecb_timed_wait()` in 1/100 s. Proposal: `usleep()`/`msleep()`.
* `gettimeofday()`: libc370 has `struct timeval` (in `<socket.h>`) but no
  `gettimeofday()` and no `struct timezone`; compat uses `uclock64()`.
  Proposal: `gettimeofday()` in `<time.h>` (or `<sys/time.h>`).
* `inet_addr()`: libc370 has `inet_aton()` only.
* `getlogin()`: compat reads the ACEE user id (`racf_get_acee()`).
* `_testauth()`, `_modeset()`: compat uses `__isauth()` and
  `__super(PSWKEY0)`/`__prob()`. JCC's `_modeset()` is `MODESET KEY=ZERO/NZERO`;
  `__super()`/`__prob()` also switch the state, to be checked. Proposal: a
  key-only `MODESET` wrapper.
* `_write2op()`: `wto()`.

### 22.-27. Cosmetic (P3)

* `strupr()` (non standard, trivial).
* `_msize()`: JCC returns the size of a heap block; `bmem.c` uses it to tell
  `malloc()` blocks (non-zero) from IRXEXCOM's "auxiliary" blocks (0, with a
  `0xDEADBEAF` header 12 bytes in front). compat reads the caller's size from
  the 8 byte prefix libc370's `getmain()` puts in front of every block. An
  earlier version peeked 12 bytes before the block like `bmem.c` does and
  abended S0C4 when a block started at a page boundary. Proposal: a real
  `_msize()`/`malloc_usable_size()` in libc370, so BREXX does not depend on
  the prefix layout. Note that IRXEXCOM's auxiliary blocks would now be
  reported as malloc blocks; that only matters once IRXEXCOM is built again.
* `__libc_heap_used/max`, `__libc_stack_used/max`: heap and stack statistics
  shown by BREXX (`STORAGE` info, out-of-memory messages). Always 0 in the
  cc370 build. Proposal: a libc370 statistics API.
* `__libc_tso_status`, `__libc_arch`: always 0.
* winsock spellings and `O_*`/`STDIN_FILENO` constants: harmless macros, could
  stay in BREXX.

## Other libc370/toolchain findings from the migration

* `IRXEXCOM` ("metal" module, `metal/metal.c`) reads JCC malloc block headers
  (`JCC_MEM_HEADER_LENGTH`) of storage allocated by the main program. With
  libc370 this needs a documented heap block layout or a redesign in BREXX.
* libc370 `<stdint.h>`: `INT32_MIN` is positive (mvslovers/libc370#188).
* cc370: signed `long long` division by a constant is miscompiled
  (mvslovers/cc370#467).
* as370: `L'sym` followed by a literal is scanned as a string
  (mvslovers/cc370#465).
* ld370/mbt: no ALIAS support (mvslovers/cc370#466) (BREXX needs REXX and RX); duplicate
  definitions are dropped silently.
