# TODO — migration to mbt v2 / cc370

**brexx370 is in maintenance mode.** The scope is: the move to mbt v2 /
cc370 + libc370, one cleanup pass, and the TSO integration. No new features —
new REXX function belongs in rexx370.

Next work items for the cc370/libc370 build. Background, current state and
the reasoning behind each item:

* [docs/cc370-migration.md](docs/cc370-migration.md) — what changed, how the
  build and CI work, status of every JCC API and module, upstream issues
* [docs/libc370-jcc-gaps.md](docs/libc370-jcc-gaps.md) — JCC features libc370
  lacks, with a proposal per item (the input for retiring `compat/`)

Code locations are marked `TODO(cc370)` (`git grep -n "TODO(cc370)"`).

Current state: smoke test and 59 of 65 REXX tests pass on MVS/CE in CI
(`mvs-test.yml`), no abends; batch only.

## 1. Verify on MVS what CI does not cover

- [ ] **TSO**: run BREXX from TSO (CPPL via `entry_R13`, `systemTSO()`,
      `USERID()`, SYSPREF handling in `open_file()`, terminal input
      `_getline()` fallback). CI runs batch only.
- [ ] **Authorization**: `_testauth()` / `_modeset()` via `__isauth()` /
      `__super()` / `__prob()`; JCC's `_modeset()` only switched the key.
- [ ] **Sockets** (`rxtcp.c`, X'75' SVC) and **threads** (`rxnje.c`, cthreads,
      crt1) — untested.
- [ ] **VSAM** (`rxvsamio.c`, IRXVSMIO/IRXVSMTR), **IRXVTOC**, **IRXISTAT**,
      **MVSDUMP** — built and deployed, never called.
- [ ] `ADDRESS` host commands without redirection (`address.c`).

## 2. Replace compat stubs (see docs/cc370-migration.md, compat table)

- [ ] Stream update modes `r+`/`w+`/`a+`, read after write —
      **libc370#189**. Fixes the 6 failing I/O tests (CHARIN, CHAROUT, CHARS,
      LINEIN, LINEOUT, LINES) and `STREAM(...'UPDATE'/'CREATE')`, `CHAROUT`/
      `LINEOUT` on a file not yet open.
- [ ] STAE recovery for `_setjmp_stae()` / `_setjmp_canc()` (libc370
      `__estae()`/`try()` or BREXX's own `RXSETJMP`).
- [ ] `fopen()` DCB attributes (`recfm=`, `lrecl=`, `blksize=`, `force`),
      dataset allocation keywords, `,vtoc` — `PDSdet()`, dataset creation.
      **No libc370 issue filed yet** (docs/libc370-jcc-gaps.md #3–#5).
- [ ] Memory files `//MEM:` and the fd layer (`dup/dup2/fdopen`) —
      `ADDRESS ... (STACK/FIFO/LIFO` redirection returns -3 today.
- [ ] `__get_ddndsnmemb()`: volser and DSORG (SYSVOLUME/SYSDSORG).
- [ ] `systemTSO()`: CLIST / implicit EXEC.
- [ ] Heap/stack statistics (`__libc_heap_*`, `__libc_stack_*`) and
      `__libc_tso_status`.
- [ ] `_msize()` from a libc370 `malloc_usable_size()` instead of the
      `getmain()` prefix layout.

## 3. Upstream issues — drop the BREXX work-arounds once fixed

| Issue | Work-around in BREXX |
|-------|----------------------|
| mvslovers/cc370#465 (as370 `L'` + literal) | `asm/mvsdump.asm` offset spelled out |
| mvslovers/cc370#466 (ld370 ALIAS) | none — REXX/RX aliases missing |
| mvslovers/cc370#467 (`long long / const`) | `lstring/mult.c` digit count via `sprintf` |
| mvslovers/libc370#183 (`strcasecmp`, in `main`, unreleased) | `jcc_strcasecmp()` in compat |
| mvslovers/libc370#187 (64-bit helpers, `uintptr_t`) | `compat/libgcc64.c`, typedefs in `compat/jccompat.h` |
| mvslovers/libc370#188 (`INT32_MIN` positive) | own `INT32_MIN/MAX` in `inc/lstring.h` |
| mvslovers/libc370#189 (update modes, read on output stream) | read/`fseek` guards in compat |

- [ ] Move the `[toolchain] libc370` pin forward when a release carries the
      fixes, then remove the matching work-arounds.

## 4. Modules

- [ ] **TSO integration** as a `++USERMOD` (`ZMG0001`, reserved), shipped as
      object decks with `++VER … FMID(<owning IBM FMID>)` — see the root
      `CLAUDE.md` on usermods and rexx370's `tso/usermod/` (`ZMG0002`).
- [ ] **Aliases REXX and RX** for BREXX (cc370#466 in ld370, then an
      `aliases` key in mbt).
- [ ] **IRXEXCOM**: redesign — it reads JCC malloc headers of storage BREXX
      allocated; `printf/printf.c` does not compile with cc370 yet.
- [ ] **IRXNJE38**: needs the NJE38 macro library (`NSIO`, ...).
- [ ] `asm/vtocprnt.asm`: as370 reports cards consumed as continuation
      (RC 4, same as IFOX00) — check whether statements are really lost.

## 5. Release and packaging

- [ ] SMP FMID: prefix **`TBRX`** (BREXX/370), digits = release version,
      so `TBRX300` for 3.0.0. Check it free on two stands (MVS/CE and TK5,
      with job numbers) before the first release; copy ufsd's
      `[distribution]` block.
- [ ] Package the non-load-module parts with mbt (`[distribution]`): RXLIB,
      SAMPLIB, PROCLIB, JCL, installation JCL, documentation — today only
      `legacy/` (`make -C legacy release`) knows how.
- [ ] cc370 based release workflow (`release.yml` is legacy and manual only).
- [ ] Decide the version scheme shown by `PARSE VERSION` (now `3.0.0-dev`
      from `project.toml`; JCC builds showed `V2R5M3`).

## 6. Tests and CI

- [ ] Fix the test sources: the six I/O tests compare with `!=`, but `!` is a
      symbol character in BREXX, so those checks never fail;
      `scripts/mvstest.py` rewrites them to `\=` at upload time.
- [ ] Run the 8-character name collision / duplicate symbol check in the
      build (ld370 drops duplicate definitions silently; the check used for
      the migration lives outside the repo).
- [ ] `mvs-test.yml` only runs on `claude/mbt-cc370-*` branches — decide the
      trigger for master/PRs (it needs an MVS/CE container, ~5 min).
- [ ] Remaining compiler warnings (pointer/int casts in `bintree.c`,
      `rxmvs.c`, `hostenv.c`, `rxtcp.c`).
- [ ] Host build (`CMakeLists.txt`, `__CROSS__`) is broken (`uintptr_t` in
      `address.c`, `external.c`) — pre-existing.

## 7. Cleanup when done

- [ ] **Cleanup pass** — defects from the 2026-02 code review, re-checked on
      this branch: #134 (tracking), #129 uninitialised pointers, #130/#131
      buffer overflows, #132 logic errors, #40 SOUNDEX, #133 dead code and
      unbuilt sources. Includes turning on `-Wall`, then `-Werror`.
- [ ] Remove `compat/` pieces as libc370 catches up (goal: nothing left).
- [ ] Remove `legacy/` once the cc370 build is the reference.
