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

Current state: smoke test and 65 of 71 REXX tests pass on MVS/CE in CI
(`mvs-test.yml`), no abends; batch only. The six failing I/O tests fail
under BREXX 2.5.3 (JCC) as well (mvsdev JOB00491); they never passed — see
#140.

How the work is done here (branches, PRs, testing on mvsdev, conventions):
see [CLAUDE.md](CLAUDE.md).

## 0. Next up (in this order)

1. **#40** SOUNDEX — EBCDIC (`c - 65` on `'A'` = 0xC1), well testable.
2. **#139** — `smf/` onto libc370 `smf_init`/`smf_active`/`smf_write`,
   inside `privilege()` (measured to work, see the issue).
3. **#140** — stream I/O to the REXX standard. The BREXX-only parts can
   start now (`CHAROUT` position off by one, `LINEOUT(name)` writing an empty
   line); the rest waits for libc370 #189/#198/#199/#200.
4. **Aliases REXX and RX** (§4) — mbt main has them (mbt#113, `make package`
   with `TALIAS` in mbt#114); bump the mbt submodule to 4c3d8e8, own PR.
5. **#133** — dead code and unbuilt sources; needs decision D3 first.
6. `-Wall`, then `-Werror` (583 warnings today), after 1–5.
7. **TSO integration** (`ZMG0001`, §4) — the actual goal after the cleanup;
   nothing planned yet. BREXX has only run under IKJEFT01 in the background,
   never on a 3270. Model: rexx370's `tso/usermod/` (`ZMG0002`).

## Open decisions (maintainer)

All postponed on 2026-09-27; D1 waits on the developer (QUESTIONS.md).

- **D1** `src/brexx.c:151` — the in-memory exec entry (`0X…`, c2c3d8b)
  parses the address with `atoi` (decimal) although the prefix says hex.
  The caller is outside this repo: which one does it pass? (#129 stays open
  for this.) Waiting on the developer — see [QUESTIONS.md](QUESTIONS.md) Q1.
- **D2** `RACCHECK()` on a resource with **no profile**: SVC 130 with
  LOG=NONE answers 4, BREXX reports "not authorized" (only 0 counts).
  libc370's contract is rc <= 4 = may proceed. Keep or follow libc370?
  Decide before `rac/` moves to `racf_auth()` (libc370#197).
- **D3** #133: remove `irx/`, `metal/`, `printf/`, `cross/*.c`,
  `asm/svc.asm`, or bring them into the build? `irx/` is tied to the
  IRXEXCOM redesign (§4).
- **D4** Rename the branch `claude/mbt-cc370-migration-5et9yt` before it goes
  to `master`? Its name is the `mvs-test.yml` trigger and is referenced in
  docs and issues #129–#134.
- **D5** Version scheme and FMID (§5): `TBRX300` for 3.0.0?

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
      **libc370#189**, the libc370 half of **#140**. libc370 alone does not
      fix the 6 failing I/O tests: BREXX has to keep separate read and write
      positions itself (#140).
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
| mvslovers/cc370#466 (ld370 ALIAS) — done; mbt `aliases` key in mbt#113 | none — REXX/RX aliases missing until the mbt submodule is bumped |
| mvslovers/cc370#467 (`long long / const`) | `lstring/mult.c` digit count via `sprintf` |
| mvslovers/libc370#183 (`strcasecmp`) — closed, not in a release yet | `jcc_strcasecmp()` in compat |
| mvslovers/libc370#187 (64-bit helpers, `uintptr_t`) — closed, not in a release yet | `compat/libgcc64.c`, typedefs in `compat/jccompat.h` |
| mvslovers/libc370#188 (`INT32_MIN` positive) — closed, not in a release yet | own `INT32_MIN/MAX` in `inc/lstring.h` |
| mvslovers/libc370#189 (update modes, read on output stream) | read/`fseek` guards in compat |
| mvslovers/libc370#198 (`"a"` truncates like `"w"`) | none — `EXECIO DISKA` (`hostcmd.c:709`, `rxexecio.c:269`) and `STREAM … APPEND` truncate today |
| mvslovers/libc370#199 (an empty line writes no record, FB and VB) — fix in libc370 PR #201 | none — **every BREXX program writing empty lines loses them today** |
| mvslovers/libc370#200 (`ftell` on a write stream wrong, `fseek` re-emits the write buffer) | none — `CHAROUT`/`LINEOUT` with a position write garbage (#140) |
| mvslovers/libc370#197 (`racf_auth()` MODESETs, S047 without APF) | `rac/` issues SVC 130 itself; switch to `racf_auth()` once decided |

- [ ] Move the `[toolchain] libc370` pin forward when a release carries the
      fixes, then remove the matching work-arounds. Latest release is v1.0.6
      (2026-09-13); #183/#187/#188 were closed after it.

## 4. Modules

- [ ] **TSO integration** as a `++USERMOD` (`ZMG0001`, reserved), shipped as
      object decks with `++VER … FMID(<owning IBM FMID>)` — see the root
      `CLAUDE.md` on usermods and rexx370's `tso/usermod/` (`ZMG0002`).
- [ ] **Aliases REXX and RX** for BREXX. ld370 has them (cc370#466), mbt
      main has the `aliases` key (mbt#113) and ships them through SMP with
      `TALIAS` (mbt#114). Neither name is an external symbol in BREXX, so both
      enter at the main entry. Never drop a released alias without reading
      mbt#115.
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
      `scripts/mvstest.py` rewrites them to `\=` at upload time. Their
      expected values are not measured and contradict each other (padded vs
      unpadded byte view, `'0D'x` as terminator); rewrite them with #140.
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
      this branch: #134 (tracking), #40 SOUNDEX, #133
      dead code and unbuilt sources, #139 `smf/` onto libc370, #140 stream
      I/O to the REXX standard. Includes
      turning on `-Wall`, then `-Werror`.
      Done: ~~#129 uninitialised pointers~~ (#135, except `brexx.c:151`:
      in-memory exec address, `atoi` or hex needs the caller's contract),
      ~~#130/#131 buffer overflows~~ (#137, #136), ~~#132 logic errors~~
      (#141).
- [ ] Remove `compat/` pieces as libc370 catches up (goal: nothing left).
- [ ] Remove `legacy/` once the cc370 build is the reference.
