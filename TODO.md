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

Current state: smoke test and all 76 REXX tests pass on MVS/CE in CI
(`mvs-test.yml`), no abends; batch only. The stream I/O tests pass since
#140 (they had never passed, not even under BREXX 2.5.3, JOB00491).

How the work is done here (branches, PRs, testing on mvsdev, conventions):
see [CLAUDE.md](CLAUDE.md).

## 0. Next up (in this order)

1. **#152** — remove the SMF feature (type 242 records, `PUTSMF`); #139
   (move it onto libc370) is superseded.
2. **#146** — review consumers of LINEIN/EXECIO/READ for trailing blanks
   on FB records; release notes.
3. **#133** — dead code and unbuilt sources (D3 decided).
4. `-Wall`, then `-Werror` (583 warnings today), after 1–3.
5. **TSO integration** (`ZMG0001`, §4) — the actual goal after the cleanup;
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
- ~~**D3**~~ decided 2026-09-27 (#133 comment): IRXEXCOM (`irx/irxexcom.c`,
  `metal/`, `printf/`, `asm/svc.asm`, `asm/getsa.asm`) into the build (#151);
  remove `irx/irxinit.c`, `irx/irxsay.c`, `CMakeLists.txt`; `cross/` waits
  for #150 (host build for local debugging).
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
- [ ] **#144 `DIR()` is wrong in the cc370 build**: 0 entries for a load
      library, 1233 for a PDS with about 75 members (mvsdev JOB00531). It
      opens the directory with JCC `fopen` options that compat drops (§2).

## 2. Replace compat stubs (see docs/cc370-migration.md, compat table)

- [x] Stream update modes `r+`/`w+`/`a+`, read after write — libc370#189
      (complete in `edge`) and BREXX's own read/write positions (#140).
- [ ] Stream follow-ups not in #140: the STREAM command vocabulary (TRL2
      leaves it to the implementation; `WRITE` still truncates), READ/WRITE/
      SEEK/EOF keep one file pointer, `LINES()` returning 0/1 (ANSI) instead
      of a count, O(1) backward seeks (libc370#206; `LINES()`/`CHARS()` are
      O(n) per call), removing the read guards in `compat/` once a libc370
      release carries #189.
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
| mvslovers/cc370#467 (`long long / const`) | `lstring/mult.c` digit count via `sprintf` |
| mvslovers/libc370#183 (`strcasecmp`) — closed, not in a release yet | `jcc_strcasecmp()` in compat |
| mvslovers/libc370#187 (64-bit helpers, `uintptr_t`) — closed, not in a release yet | `compat/libgcc64.c`, typedefs in `compat/jccompat.h` |
| mvslovers/libc370#188 (`INT32_MIN` positive) — closed, not in a release yet | own `INT32_MIN/MAX` in `inc/lstring.h` |
| mvslovers/libc370#189 (update modes, read on output stream) — direction check (PR #203) and slice 1 (PR #207: `r+`/`w+`/`a+`, write only at the end) in `edge`; slice 2 (overwrite in the middle, PS only) open. Contract: #140 comment | read/`fseek` guards in compat, removable once BREXX builds on the direction check |
| mvslovers/libc370#198 (`"a"` truncates like `"w"`) — fixed (PR #205), in `edge`: appends on PS; on an existing PDS member `fopen` fails (EOPNOTSUPP) instead of overwriting (appending to a member: libc370#204, not planned) | none — `EXECIO DISKA` (`hostcmd.c:709`, `rxexecio.c:269`) and `STREAM … APPEND` now append on PS and fail on an existing member |
| mvslovers/libc370#199 (an empty line writes no record, FB and VB) — fixed (PR #201), in `edge` | none — **every BREXX program writing empty lines loses them today** |
| mvslovers/libc370#200 (`ftell` on a write stream wrong, `fseek` re-emits the write buffer) — fixed (PR #202), in `edge`: `ftell` counts from the start; `fseek` on a write-only stream fails with `ESPIPE` unless it stays in place | none — `Lcharout`/`Llineout` ignore the `fseek` result, so a positioned write on an `OPEN 'W'` handle should now land at the current position (from the code, not measured; #140) |
| mvslovers/libc370#197 (`racf_auth()` MODESETs, S047 without APF) | `rac/` issues SVC 130 itself; switch to `racf_auth()` once decided |

- [ ] `[toolchain] libc370` is the rolling tag `edge` (libc370 main with the
      fixes BREXX waits for; the runtime reports 1.0.7-dev). **Pin a real
      release before a BREXX release**, then remove the matching
      work-arounds. Latest release is v1.0.6 (2026-09-13); #183/#187/#188
      were closed after it; #198, #199, #200 and the #189 direction check
      are in `edge`.

## 4. Modules

- [ ] **TSO integration** as a `++USERMOD` (`ZMG0001`, reserved), shipped as
      object decks with `++VER … FMID(<owning IBM FMID>)` — see the root
      `CLAUDE.md` on usermods and rexx370's `tso/usermod/` (`ZMG0002`).
- [x] **Aliases REXX and RX** for BREXX (`aliases` in project.toml, mbt
      4c3d8e8). `LISTDS … MEMBERS` shows `BREXX ALIAS(REXX,RX)`; batch and TSO
      run through all three names (mvsdev JOB00531). SMP ships them with
      `TALIAS` (mbt#114). Never drop a released alias without reading
      mbt#115.
- [ ] **IRXEXCOM** (#151): build it with cc370 — 2.5.3 ships it, ISPF uses it
      for BREXX variables. It reads JCC malloc headers of storage BREXX
      allocated; `printf/printf.c` does not compile with cc370 yet.
- [ ] **IRXNJE38**: needs the NJE38 macro library (`NSIO`, ...).
- [ ] `asm/vtocprnt.asm`: as370 reports cards consumed as continuation
      (RC 4, same as IFOX00) — check whether statements are really lost.

## 5. Release and packaging

**Release notes 3.0 — user-visible changes so far** (collect here, write
them up for the release):

- Stream I/O follows the REXX standard (#149): separate read and write
  positions, `LINEOUT(name)` writes nothing, `CHAROUT` positions are 1-based,
  implicit opens never truncate, `OPEN(name,'W')` can be read back.
- `CHAROUT`/`LINEOUT` return the count **not** written (0 on success);
  `CHAROUT` returned `LENGTH(string)` before.
- FB records keep their trailing blanks in `LINEIN`, `EXECIO DISKR` and
  `READ()`, as TSO/E does (#146); `STRIP(x,'T')` restores the old form.
- A normal comparison (`=`, `<`, `>`) ignores trailing blanks (#148):
  `'abc  ' = 'abc'` is 1.
- `PUTSMF` is gone (a call is error 51, as for any unknown function) and no
  SMF type 242 records are written (#152).
- `SOUNDEX` works on EBCDIC (#145); `LOCATE` with 4 arguments is error 40
  (#141).
- Load-module aliases `REXX` and `RX` (#143).

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

- [x] The six I/O tests were rewritten with #140 (standard semantics, FB80
      byte view, `'15'x`); in-place tests on a sequential data set
      (`lnoutps`, `updps`). No test uses `!=` any more; the rewrite in
      `scripts/mvstest.py` can go.
- [ ] Run the 8-character name collision / duplicate symbol check in the
      build (ld370 drops duplicate definitions silently; the check used for
      the migration lives outside the repo).
- [ ] `mvs-test.yml` only runs on `claude/mbt-cc370-*` branches — decide the
      trigger for master/PRs (it needs an MVS/CE container, ~5 min).
- Decided 2026-09-27: `mvs-test.yml` stays red until #140 fixes the six
  stream I/O tests; no list of expected failures. Resolved by #140 (75/75).
- [ ] Remaining compiler warnings (pointer/int casts in `bintree.c`,
      `rxmvs.c`, `hostenv.c`, `rxtcp.c`).
- [ ] Host build for local debugging (#150); `CMakeLists.txt` goes with #133
      (D3).

## 7. Cleanup when done

- [ ] **Cleanup pass** — defects from the 2026-02 code review, re-checked on
      this branch: #134 (tracking), #133 dead code and unbuilt sources,
      #152 remove SMF, #146 consumers of padded FB records.
      Includes turning on `-Wall`, then `-Werror`.
      Done: ~~#129 uninitialised pointers~~ (#135, except `brexx.c:151`:
      in-memory exec address, `atoi` or hex needs the caller's contract),
      ~~#130/#131 buffer overflows~~ (#137, #136), ~~#132 logic errors~~
      (#141), ~~#40 SOUNDEX~~ (#145), ~~#147 `=` and trailing blanks~~
      (#148), ~~#140 stream I/O to the REXX standard~~ (#149).
- [ ] Remove `compat/` pieces as libc370 catches up (goal: nothing left).
- [ ] Remove `legacy/` once the cc370 build is the reference.
