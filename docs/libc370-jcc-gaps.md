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
The resulting work items are tracked in [TODO.md](../TODO.md).

## Summary

| # | JCC feature | Used in | compat today | Prio |
|---|-------------|---------|--------------|------|
| 1 | `__muldi3`, `__udivdi3`, `__umoddi3`, `__divdi3`, `__moddi3` | any `long long` `*` `/` `%` | removed: cc370 1.1 ships them in `libcc370rt.a` (#300) | done |
| 2 | `(u)intptr_t` in `<stdint.h>` | everywhere | typedef in compat | P2 |
| 3 | `fopen()` DCB attributes (`recfm=`, `lrecl=`, `blksize=`, `klen=`, `force`) | — | not needed: `PDSdet()` reads the directory with `__walkpd()` (#144), creation goes through dsio `rxCreateDsn()` (#299) | done |
| 4 | `fopen()` new dataset allocation (`volser=`, `unit=`, `pri=`, `sec=`, `dirblks=`, `notcat`, `dontcat`) | — | not needed: `CREATE()` and `OPEN(…, alloc)` allocate through dsio `rxCreateDsn()` (dynamic allocation, #299) | done |
| 5 | `fopen(..., ",vtoc")` | — | no user in BREXX; VTOC reads are `IRXVTOC`'s (assembler) | not needed |
| 6 | memory files `//MEM:` | — (`OPEN(…,'VIO')` removed, #299) | not needed | done |
| 7 | fd layer `open/_open/close/_close/dup/dup2/fdopen` | `rxmvs.c` `reopen()` | compiled out | **P1** |
| 8 | STAE based `_setjmp_stae()` / `_setjmp_canc()` | `rxtcp.c`, `rxmvs.c` (`MTT`, `MTTX`) | removed (#157) | done, BREXX-side: libc370 `cmtt_*()` and `try()` |
| 9 | `_style` (default name style for `fopen`) | — | removed with `jcc_fopen()`; BREXX opens through `src/dsio.c` (#299) | done |
| 10 | `fileno()`, `isatty()` | — (`lstring/*.c` in host code only) | removed (#299) | done |
| 11 | `__get_ddndsnmemb()` (DD, DSN, member, volser, JFCB extract) | `rexx.c`, `rxmvs.c` `parseDCB()` | removed: dsio `rxFileInfo()` + `rxDsAttr()` (#299) | done |
| 12 | `_getline()` (TGET line read for terminals) | `lstring/read.c` | JCC only, falls back to `fgetc()` | P2 |
| 13 | `entry_R13` (entry save area, `[6]` = CPPL) | `hostenv.c`, `rxmvs.c` | `jcc_cppl()` = `ppa->ppacppl` (libc370#210) | done |
| 14 | `systemTSO()` (run a TSO command line) | `address.c`, `rxnje.c` | removed: BREXX's own `tsoCommand()` (#162) | done |
| 15 | `beginthread()` / `syncthread()` / `endthread()` | `rxnje.c` | cthreads | P2 |
| 16 | `Sleep(ms)` | `rxmvs.c`, `rxnje.c`, `fss.c` | removed: BREXX's `sleepMs()` (#298) | done |
| 17 | `gettimeofday()` + `struct timezone` | `lstring/time.c` | removed: `lstring/time.c` reads `uclock64()` (#298) | done |
| 18 | `inet_addr()` | `rxtcp.c` | libc370 2.0 `inet_addr()` (libc370#51) | done |
| 19 | `getlogin()` | `brexx.c`, `rxmvs.c`, `rxnje.c` | removed: BREXX's `rac_user()` (#298) | done |
| 20 | `_testauth()`, `_modeset()` | `rxmvs.c` | removed: `__isauth()`, `keyZero()` on `__super()`/`__prob()` | done |
| 21 | `_write2op()` | `rxtso.c`, `rxmvs.c`, `fss.c` | removed: `wto()` | done |
| 22 | `strupr()` | `rxfss.c` | removed: a loop at its one caller (#298) | done |
| 23 | `_msize()` | `bmem.c` | moved into `bmem.c` as `heapSize()`, still from libc370's getmain prefix (`ptr[-1]`) (#298) | P3 |
| 24 | `__libc_heap_used/max`, `__libc_stack_used/max` | `rxmvs.c` (STORAGE info), `bmem.c` | storage only, always 0 | P3 |
| 25 | `__libc_tso_status`, `__libc_arch` | `brexx.c`, `rxmvs.c` | storage only, always 0 | P3 |
| 26 | winsock names (`SOCKET`, `SOCKET_ERROR`, `WSAE*`, `LPSOCKADDR`, ...) | `rxtcp.c` | macros | P3 |
| 27 | `O_*` open flags, `STDIN_FILENO` ... | — | removed, no caller (#299) | done |
| 29 | update modes `r+`/`w+`/`a+`, reading back a stream written with `w` | `rxfiles.c` (OPEN, STREAM, CHAROUT/LINEOUT), `lstring/lines.c`, `linein.c` | libc370#189 in `edge` + BREXX read/write positions (#140) | done, not in a libc370 release yet |
| 28 | `strcasecmp()`, `strncasecmp()` | 13 files | libc370's `<strings.h>` (libc370#183, in 2.1.0) | done |

## Update modes (libc370#189)

**Resolved (2026-09-28):** libc370#189 is complete in `edge` (r+/w+/a+,
overwriting in place on sequential data sets), and #140 gives BREXX its own
read and write positions; the suite passes 75/75. The rest of this section is
the state before.

With the checks fixed (see the note below) the suite passes 67 of 73 tests on
MVS/CE without any abend. The six failures (CHARIN, CHAROUT, CHARS, LINEIN,
LINEOUT, LINES) all open a PDS member with
`"w"`, write it and read it back with `LINES()`/`LINEIN()`, which JCC allowed.
libc370 has no update modes at all (`__fpmode()` rejects `+`) and issued the
READ against the output DCB: S400, then B14-10 at CLOSE. The compat layer now
returns `EOF`/`EBADF` for such reads (and fails `fseek(SEEK_END)`, which
libc370 implements by reading), so the tests fail cleanly instead of
abending, until libc370 supports update I/O.

Note on these six tests: they compare with `!=`, but `!` is a symbol
character in BREXX, so `lines(file)!=5` is `lines(file)||'!' = 5` and never
true -- the checks could not fail, under JCC either. `scripts/mvstest.py`
rewrites `!=` to `\=` so the results are real.

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

### 1. 64-bit integer helpers (done, #300)

GCC emits calls to `__muldi3`, `__divdi3`, `__udivdi3`, `__moddi3`,
`__umoddi3` for `long long` multiply, divide and remainder. BREXX carried
them in `compat/libgcc64.c` until cc370 1.1 shipped them in `libcc370rt.a`;
the file is gone (#292, #300).

### 2. `(u)intptr_t` (P2, mvslovers/libc370#187)

libc370's `<stdint.h>` only defines `(u)intptr_t` for a list of host CPUs
(`__i386__`, `__x86_64__`, ...); i370 is not among them. **Proposal:**
`typedef unsigned int uintptr_t; typedef int intptr_t;` plus the limits for
`__MVS__`.

### 3.-5. `fopen()` dataset attributes, allocation and VTOC (done BREXX-side)

JCC's `fopen()` mode string took DCB defaults (`recfm=`, `lrecl=`,
`blksize=`, `klen=`, `force`), allocation keywords (`volser=`, `unit=`,
`pri=`, `sec=`, `dirblks=`, `notcat`, `dontcat`) and `,vtoc`; libc370 knows
only `record`, `bsam` and `rlse`. BREXX no longer needs any of them:

* `PDSdet()` reads a PDS directory with libc370's `__walkpd()` (BPAM),
  through dsio `rxWalkDir()` (#144), instead of a forced RECFM=U open;
* `CREATE()` and `OPEN(name, mode, allocation-information)` allocate a new
  data set through dsio `rxCreateDsn()`, BREXX's dynamic allocation
  (`dynit`), with DSORG, RECFM, LRECL, BLKSIZE, PRI, SEC, DIRBLKS and UNIT
  (#299);
* nothing in the C code reads a VTOC through `fopen()`; that is the
  assembler module `IRXVTOC`.

### 6. Memory files `//MEM:` (not needed any more)

`rxfiles.c` used it for `OPEN(name, mode, 'VIO')`, which never worked in the
cc370 build, was documented nowhere and had no user; it is removed (#299,
`OPEN` ends with error 40 for `VIO`). `address.c` used `//MEM:OUT` for
`ADDRESS` output redirection, but that function had no caller since 2019 and
was removed in #278. Nothing in BREXX needs a memory-backed `FILE` now.

### 7. File descriptor layer (P1)

`rxmvs.c` `reopen()` re-opens stdin/stdout/stderr on DDs. libc370 has no fd
layer. (The `ADDRESS ... (STACK/FIFO/LIFO` redirection in `address.c` used it
too, but had no caller since 2019 and was removed in #278.) **Proposal:** either a
minimal fd table over `FILE *` (0/1/2 plus `dup/dup2/fdopen`), or a libc370
API to swap `stdin`/`stdout`/`stderr` (e.g. `freopen()` on DD names plus a way
to restore the previous stream), after which BREXX would use that API instead.

### 8. STAE based setjmp (done, #157)

JCC's `_setjmp_stae(jmp_buf, char *sdwa104)` establishes a STAE exit and
returns like `setjmp()`: 0 when established, non-zero after an abend was
intercepted (the SDWA is copied into the 104 byte buffer); `_setjmp_canc()`
cancels it. `rxtcp.c` uses it to probe for the X'75' TCP/IP SVC, `rxmvs.c`
for protected storage access. The compat layer returns 0 and establishes
nothing, so an abend in these paths is not intercepted.

**Resolved on the BREXX side** (#157), no libc370 change: `MTT()`/`MTTX()`
read the copy of the table that `cmtt_new()` makes (it authorises itself via
SVC 244 when the task is not APF authorised) and walk it with
`cmtt_get_array()`, which checks the bounds of every entry, so no recovery is
needed. The X'75' probe calls `closesocket(0)` under `try()`. The stubs are
gone.

### 9. `_style` (P2)

JCC resolves a plain `fopen()` name through `_style` (`"//DDN:"` by default,
`"//DSN:"` for a fully qualified dataset name, `"//MEM:"`, `"//HFS:"`), and a
name may carry the style as a prefix. libc370 uses `DD:name` and treats a
plain name as a dataset name (with the TSO prefix unless quoted).
`jcc_fopen()` (every `fopen()` call is redirected to it) translates.
**Done without libc370 (#299):** BREXX opens every data set through its own
`src/dsio.c` (`rxOpenDsn()` for `'name'`, `rxOpenDd()` for `DD:name`), and
`_style`, `jcc_fopen()` and the `fopen` mapping are gone from `compat/`.

### 10.-11. `fileno()`, `isatty()`, `__get_ddndsnmemb()` (done)

BREXX only needed a handle to ask for the dataset information of an open
stream. That is BREXX's own now (#299): dsio `rxFileInfo()` reads DD, DSN,
member, RECFM, LRECL and BLKSIZE from libc370's `FILE`, and `rxDsAttr()`
takes volser and DSORG from the catalog and the format-1 DSCB. Nothing in
the cc370 build calls `fileno()` or `isatty()` (`lstring/` does, in host
code only), so the compat layer no longer provides them.

### 12. `_getline()` (P2)

JCC reads a terminal line with TGET (`lstring/read.c`, only when
`isatty()`). The cc370 build reads with `fgetc()` on the terminal `FILE`.
**Proposal:** verify libc370's terminal input behaves the same (line mode,
prompt), otherwise a `getline`-style TGET helper.

### 13. `entry_R13` (done)

JCC exposes the caller's save area at program entry; BREXX only ever read
word 6 (R1 at entry = the CPPL under TSO). libc370's startup stores the CPPL
of a TSO command processor in `ppacppl` since libc370#210 (NULL in batch and
under TSO `CALL`), so `compat/jccompat.c` offers `jcc_cppl()`, which returns
that field, and the save area image with its CPPL copy from `grt->grtptrs`
is gone.

### 14. `systemTSO()` (P2)

JCC takes a complete command line, runs it with a CPPL and returns -1 when
the program was not invoked with a CPPL. **Resolved in BREXX (#162):** both
callers now use `tsoCommand()` (`src/hostenv.c`), the code behind
`ADDRESS TSO`: RC of the command, -3 when it is not found (SC28-1883-0
p. 23-24), LINK with R0 = ENVBLOCK. libc370's `tsocmd(pgm, operands)` was
not the right fit: no -3 for an unknown command, no ENVBLOCK in R0. No
libc370 change needed.

### 15. Threads (P2)

`rxnje.c` runs the NJE38 receiver in a subtask with JCC's
`beginthread/syncthread/endthread`. The compat layer maps them to libc370
cthreads (`cthread_create[_ex]`, wait on `termecb` + `cthread_detach`,
`cthread_exit`), which needs the `crt1` startup. **Proposal:** thin JCC-style
wrappers in libc370 are optional; the mapping is small.

### 16.-21. Small functions (P2)

* `Sleep(ms)`: BREXX's own `sleepMs()` (`src/util.c`), `ecb_timed_wait()` in
  1/100 s. libc370 2.1 has `usleep()` (`STIMER WAIT`), whose `unsigned`
  microseconds would overflow for a `WAIT()` over 71 minutes.
* `gettimeofday()`: `lstring/time.c` reads `uclock64()` itself; libc370 has
  `struct timeval` (in `<sys/select.h>`) but no `gettimeofday()`.
* `inet_addr()`: in libc370 2.0 (libc370#51); BREXX uses it, and
  `inet_ntop()` instead of its own `inet_ntoa()`.
* `getlogin()`: BREXX's `rac_user()` (`rac/rac.c`) reads the ACEE user id
  (`racf_get_acee()`).
* `_testauth()`, `_modeset()`: gone from compat. BREXX calls `__isauth()`,
  and `privilege()` switches with `keyZero()` in `rxmvs.c`: `__super(PSWKEY0)`
  then `__prob(PSWKEYNONE)`, so it ends in key 0 and problem state as JCC's
  `MODESET KEY=ZERO` did (supervisor state broke libc370's heap, #191). A
  key-only `MODESET` in libc370 would make it one call.
* `_write2op()`: gone, BREXX calls `wto()`.

### 22.-27. Cosmetic (P3)

* `strupr()` (non standard, trivial): a loop at its one caller.
* `_msize()`: JCC returns the size of a heap block; `bmem.c` uses it to tell
  `malloc()` blocks (non-zero) from IRXEXCOM's "auxiliary" blocks (0, with a
  `0xDEADBEAF` header 12 bytes in front). `bmem.c`'s `heapSize()` reads the caller's size from
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
* as370: `L'sym` followed by a literal was scanned as a string
  (mvslovers/cc370#465, fixed in cc370 039a968).
* ld370/mbt: ALIAS support is in mbt (mbt#113, cc370#466 closed); duplicate
  definitions are still dropped silently.
