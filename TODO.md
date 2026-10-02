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

Current state: built against the libc370 release 2.0.0 (#274); the smoke
test and all 115 REXX tests pass on MVS/CE in CI (`mvs-test.yml`, 116/116
steps), no abends; batch only. The stream I/O tests pass since
#140 (they had never passed, not even under BREXX 2.5.3, JOB00491).

How the work is done here (branches, PRs, testing on mvsdev, conventions):
see [CLAUDE.md](CLAUDE.md).

## 0. Next up (in this order)

Decided 2026-09-28: finish the migration first (everything that worked
under JCC works again), the cleanup (#133) waits. For every gap, first look
for a BREXX-side change on top of what libc370 already offers; a libc370
issue only when there is none.

1. ~~**TSO in the foreground**~~ (#158): SAY, PULL and `ADDRESS TSO` work
   on a 3270 (mvsdev, `s3270`). Still open in §1: the rest of the TSO list.
2. ~~**STAE stubs**~~ (#157, #166): `MTT()`/`MTTX()` on libc370 `cmtt_*()`,
   the X'75' probe on `try()`, the stubs are gone. 78/78 on mvsdev
   (JOB00647) and MVS/CE (JOB00061). Not reproduced: the case without
   SVC 244 / without the X'75' SVC.
3. ~~**Real numbers under the default `NUMERIC DIGITS 30`**~~ (#156, #181):
   a real prints with at most 15 digits, placed by the REXX rules
   (`lstring/numfmt.c`); decimal literals stay strings. A mitigation, not
   conformance (SC28-1883 ch. 6). libc370#225 still shows at the range
   edges. Follow-up ~~#180~~ (#266: a literal outside the HFP range no
   longer abends at compile time); at run time it still does, **#267**.
4. **`fopen()` DCB options** (§2, #144 `DIR()`): look for a BREXX-side route
   first, libc370 issue only if there is none.
5. ~~`-Wall`, then `-Werror`~~ (#167, #168): the build runs with
   `-Wall -Wextra -Werror`, 616 warnings fixed. Real defects found on the way
   are fixed there (LLSEARCH, ISEARCH, `fssSetCurPos`, …). ~~#171~~ array
   bounds (integer/bit/fixed-string arrays) fixed in #174. Follow-ups: 6.
   below, D6/D7.
6. **Memory defects found in 5.** (read from the code, not reproduced):
   - [ ] **#172** string arrays (`SCREATE`, `SGET`, …): array number and
         index unchecked, off-by-one in `R_screate`, `R_screate(0)` reads
         the caller's argument — the same fix as #174.
   - [ ] **#170** `SYSDSN()`: a DSN with member overflows `sDSName[45]`.
   - [x] **#283** `getDatasetName()`: `DIR()` passed `sDSN[45]` (the
         function clears 55 bytes); no length check (`EXISTS` of a
         300-character name abended S0C1); a lone quote; an unquoted name
         without a prefix (batch) became empty and now stands as it is,
         as in TSO/E and EXECIO. Test `dsnname`. Same empty-prefix pattern
         still in `LISTDSI` and `SYSDSN` (`rxmvs.c` ~1354, ~1513).
7. **#133** — dead code and unbuilt sources (D3 decided). Worked through
   item by item 2026-10-01: IRXEXCOM sources moved to #151, `cross/` to
   #150; `__BORLANDC__` branches and `rxconio.h`/`systemx.h` in #279;
   unused macros, `LSTRALLOC` and every `JCC`/`GCC` conditional in #280
   (`CAT_INC`/`CODE_INC` stay at the cc370 values); duplicate preload
   branches, `strcat` no-ops, `Lreradix` in #281; `strstr` against NULL
   in `SSEARCH`/`SSELECT` and the DSN check, with tests (`ssearch`,
   `dsnmain`, the first step started by DSN). Left: the six calls of the
   macro rewrite (#284). Split out:
   PUTENV (#282: the unreachable branch removed),
   `getDatasetName()` (#283, under 6.). The other platforms (WCE, WIN,
   MSDOS, `__CMS__`, …) removed in #278.
8. **TSO integration** (`ZMG0001`, §4) — the actual goal after the migration;
   nothing planned yet. Model: rexx370's `tso/usermod/` (`ZMG0002`).

## Open decisions (maintainer)

All postponed on 2026-09-27.

- ~~**D1**~~ decided 2026-09-29: the in-memory exec entry (`0X…`,
  c2c3d8b) is not used any more and is removed (#167, closes #129).
- **D2** `RACCHECK()` on a resource with **no profile**: SVC 130 with
  LOG=NONE answers 4, BREXX reports "not authorized" (only 0 counts).
  libc370's contract is rc <= 4 = may proceed. Keep or follow libc370?
  Decide before `rac/` moves to `racf_auth()` (libc370#197).
- ~~**D3**~~ decided 2026-09-27 (#133 comment): IRXEXCOM (`irx/irxexcom.c`,
  `metal/`, `printf/`, `asm/svc.asm`, `asm/getsa.asm`) into the build (#151);
  remove `irx/irxinit.c`, `irx/irxsay.c`, `CMakeLists.txt`; `cross/` waits
  for #150 (host build for local debugging).
- ~~**D4**~~ decided 2026-09-29: the migration branch went to `master` under
  a neutral name (`mbt-cc370`); `mvs-test.yml` runs on pushes to `master`.
  The JCC line is kept in the branch `v2.5-jcc`.
- **D5** Version scheme and FMID (§5): `TBRX300` for 3.0.0?
- **D6** **#169** `SYSDSN()` reports only `OK` / `DATASET NOT FOUND`; the
  TSO messages (`MEMBER NOT FOUND`, …) never come. A compatibility gap, not
  a crash: fix in brexx370, or document it and leave TSO behaviour to
  rexx370?
- ~~**D7**~~ decided 2026-09-30: **#173** (a trap stays on after it fires)
  is fixed as an interpreter defect, PR #241.
- **D8** SonarCloud rule c:S1172 (§6): disable it in `.sonarcloud.properties`
  on `master`?
- **D9** **#264** an external exec without `PROCEDURE` shares its caller's
  variables (standard REXX gives it a fresh set). Fix it for 3.0.0, or
  document it as a BREXX limit? Existing execs may depend on the sharing.
- **D10** **#284** the load-time macro rewrite (`:code`/`:exec`/`:call`,
  `ARGIN#(…)`): keep, document and test it, or remove it? Waiting on a
  talk with Peter Jacob (QUESTIONS.md).

## 1. Verify on MVS what CI does not cover

- [ ] **TSO**: run BREXX from TSO (CPPL via `jcc_cppl()`, #175; `systemTSO()`,
      `USERID()`, SYSPREF handling in `open_file()`, terminal input
      `_getline()` fallback). CI runs batch only. Done in #158 (mvsdev,
      3270 via `s3270`, the build copied to `SYS2.LINKLIB(BRXDEV)`): SAY,
      PULL from the terminal, `ADDRESS TSO` in the foreground and under
      IKJEFT01; TSO `CALL` (no CPPL) gives `ADDRESS TSO` rc -3 instead of
      S0C4. Also the same as 2.5.3 in the foreground (2026-09-28): OUTTRAP
      of `LISTALC`, `ALLOC`/`FREE`, `EXEC` of a CLIST (queued, runs after
      BREXX ends, rc 0), unknown command rc -3; under ISPF (Wally ISPF
      V2.2) `SYSVAR('SYSISPF')` ACTIVE, `CONTROL ERRORS RETURN` rc 0,
      `VPUT`/`VGET` rc 8 in both builds, as expected: this ISPF supports
      CLIST variables only, no REXX. The cc370 build allocates two more
      TERMFILE DDs during a run (`SYS000nn`, presumably libc370's terminal
      streams), freed at the end. `systemTSO()` was not reachable in the
      cc370 build (callers: the ADDRESS redirection path, NJE38) and is
      replaced by `tsoCommand()` (#162).
      Open: SC28-1883-0 p. 24 lets `ADDRESS TSO` run CLISTs and execs;
      `__TSO()` only finds load modules. Measured under IKJEFT01 with
      SYSPROC (2.5.3 JOB00621, 3.0.0-dev JOB00622/JOB00624): `'%CLTEST'`
      and `'CLTEST'` give -3 in both builds - a deviation from the spec,
      not a regression. `EXEC '…(CLTEST)'` gives rc 0 and the CLIST runs
      after BREXX ends (the step ends with the CLIST's `EXIT CODE(4)`).
      Open: `lineout 'STDERR'` fails with error 57 although RXINIT has
      allocated DD STDERR to the terminal (cause not investigated; 2.5.3
      hangs there until PA1). Trace lines showed `d *-*` instead of the
      line number (§2, `%zd`, fixed in #160).
- [ ] **Authorization**: `_testauth()` / `_modeset()` via `__isauth()` /
      `__super()` / `__prob()`; JCC's `_modeset()` only switched the key.
- [ ] **Sockets** (`rxtcp.c`, X'75' SVC) and **threads** (`rxnje.c`, cthreads,
      crt1) — untested.
- [ ] **VSAM** (`rxvsamio.c`, IRXVSMIO/IRXVSMTR), **IRXVTOC**, **IRXISTAT**,
      **MVSDUMP** — built and deployed, never called.
- [x] `ADDRESS` host commands without redirection (`address.c`): the
      redirection had no caller; removed in #278.
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
      O(n) per call).
- [x] STAE recovery for `_setjmp_stae()` / `_setjmp_canc()` (#157, #166):
      `MTT()`/`MTTX()` read the `cmtt_new()` copy of the table (oldest
      entry dropped, SVC 244 via `__autask()`), `testX75()` runs under
      `try()`. Open: `cmtt_new()` copies the whole table on every call,
      also when nothing is new (about 300 entries on mvsdev, not measured
      in bytes).
- [x] **`%zd`/`%zu` print a literal `d`/`u`** (#160, libc370#211): libc370's `vsnprintf()`
      knows `h`, `l`, `ll`, `L`, but not C99's `z`/`j`/`t`. JCC did. Seen
      in every trace line (`src/trace.c:132`, `"%6zd *-* "`: `d *-* say`
      instead of `15 *-* say`); also `bmem.c` (out-of-memory messages),
      `rexx.c:660`, `interpre.c` debug output. Fixed on the BREXX side:
      cast to `long` and `%ld` (JOB00615 before, JOB00617 after).
- [x] `CAT_INC`/`CODE_INC` (`inc/rexx.h`, `lstring/lstring.c`): JCC only, so
      cc370 grows a concatenation to the exact length. Measured 2026-09-28 on
      mvsdev, 5000–40000 single-byte appends (`s=s||'x'` and `s=s'x'`):
      3.0.0-dev 0.07/0.13/0.30/0.66 s (JOB00601), 2.5.3 0.06/0.17/0.26/0.74 s
      (JOB00607), step CPU 2.22 s vs 2.44 s. No regression, no change.
- [ ] **Real to string** (`L2str()`, `lstring/lstring.c`): `snprintf("%.*g",
      lNumericDigits)` with BREXX's default `NUMERIC DIGITS 30`. libc370
      prints 30 digits, wrong from the 16th on, even for exact values:
      `1/4` -> `0.250000000000004996003610813204`, `2**0` ->
      `1.000000000000004884981308350688` (JOB00606). 2.5.3 (JCC) printed ~17
      digits, also noisy: `0.25000000000000002`, `1.0000000000000003`, and
      under `NUMERIC DIGITS 9` `0.1+0.2` -> `0.299999` where cc370 gives `0.3`
      (JOB00605). BREXX-side fix: cap the precision at the digits a double
      holds (15). libc370's digits beyond 15 may still deserve an issue.
- [ ] `fopen()` DCB attributes (`recfm=`, `lrecl=`, `blksize=`, `force`),
      dataset allocation keywords, `,vtoc` — `PDSdet()`, dataset creation.
      First look for a BREXX-side route (docs/libc370-jcc-gaps.md #3–#5);
      a libc370 issue only if there is none.
- [ ] Memory files `//MEM:` and the fd layer (`dup/dup2/fdopen`): needed
      by `rxfiles.c` and `reopen()` only. The `ADDRESS ... (STACK/FIFO/LIFO`
      redirection was never reachable: `RxRedirectCmd()` (`address.c`) had no caller since 2019 (`3f79908`, #25), in 2.5.3 too, and was removed in #278;
      bringing it back would be a new feature (model: `v2.5-jcc`).
- [ ] `__get_ddndsnmemb()`: volser and DSORG (SYSVOLUME/SYSDSORG).
- [x] `systemTSO()` removed from compat (#162): its callers use `tsoCommand()`,
      the `ADDRESS TSO` path.
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
| mvslovers/libc370#189 (update modes, read on output stream) — closed 2026-09-27, complete in `edge`: direction check (PR #203), slice 1 (PR #207: `r+`/`w+`/`a+`) and slice 2 (PR #208: overwrite in place, PS only). Contract: #140 comment | none — the read/`fseek` guards in compat are gone (#275); `rdout`, `updvb`, `updmem` test what they covered |
| mvslovers/libc370#198 (`"a"` truncates like `"w"`) — fixed (PR #205), in `edge`: appends on PS; on an existing PDS member `fopen` fails (EOPNOTSUPP) instead of overwriting (appending to a member: libc370#204, not planned) | none — `EXECIO DISKA` (`hostcmd.c:709`, `rxexecio.c:269`) and `STREAM … APPEND` now append on PS and fail on an existing member |
| mvslovers/libc370#199 (an empty line writes no record, FB and VB) — fixed (PR #201), in `edge` | none — **every BREXX program writing empty lines loses them today** |
| mvslovers/libc370#200 (`ftell` on a write stream wrong, `fseek` re-emits the write buffer) — fixed (PR #202), in `edge`: `ftell` counts from the start; `fseek` on a write-only stream fails with `ESPIPE` unless it stays in place | none — `Lcharout`/`Llineout` ignore the `fseek` result, so a positioned write on an `OPEN 'W'` handle should now land at the current position (from the code, not measured; #140) |
| mvslovers/libc370#182 (`fclose` lost the last short block and returned 0) — fixed (PR #227), in `edge` at 14edfa7: `EOF` + `ENOSPC`/`EIO` | none — `CLOSE()` passes the result through (`rxfiles.c:614`); EXECIO ignores it (#178) |
| mvslovers/libc370#225 (`%f`/`%e` scaling inexact on HFP: `%e` of 1e-30 is `9.99…E-31`) — open, no pressure from BREXX | none — seen through REXX at the range edges (JOB00726, JOB00734: `trunc(1e40*1)`); literals and variables are exact in TRUNC since #177; reals print through `Lreal2str` since #181 (`1e-70*1` → `9.99999999999999E-71`) |
| mvslovers/libc370#197 (`racf_auth()` MODESETs, S047 without APF) | `rac/` issues SVC 130 itself; switch to `racf_auth()` once decided |
| mvslovers/libc370#210 (`ppacppl` never set) — fixed (PR #217), in `edge` at 832d794: `__start()` stores the CPPL of a TSO command processor (NULL under TSO CALL and in batch); measured on mvsdev by libc370 (JOB00683/00686/00689, 3270 foreground as MVSCE01) | none — `jcc_entry_r13()` removed, `jcc_cppl()` reads `ppacppl` (needs a sysroot >= 832d794; an older one leaves `ADDRESS TSO` without a CPPL). Side finding libc370#218: the CPPL grtptrs loop records 10 words, only 0-3 are meaningful |

- [x] `[toolchain] libc370` is pinned to the release `2.0.0` (#274);
      `build.yml` follows libc370 `main` (the 2.0 line) again. The fixes
      BREXX waited for in `edge` (#183/#187/#188, #198, #199, #200, #189)
      are in 2.0.0. Still to remove: the work-arounds for them (§2).

## 4. Modules

- [ ] **TSO integration** as a `++USERMOD` (`ZMG0001`, reserved), shipped as
      object decks with `++VER … FMID(<owning IBM FMID>)` — see the root
      `CLAUDE.md` on usermods and rexx370's `tso/usermod/` (`ZMG0002`).
- [x] **Aliases REXX and RX** for BREXX (`aliases` in project.toml, mbt
      4c3d8e8). `LISTDS … MEMBERS` shows `BREXX ALIAS(REXX,RX)`; batch and TSO
      run through all three names (mvsdev JOB00531). SMP ships them with
      `TALIAS` (mbt#114). Never drop a released alias without reading
      mbt#115.
- [ ] **IRXEXCOM** (#151): build it with cc370 — 2.5.3 ships it. A TSO
      command processor called from an exec reads and sets the exec's
      variables through it (`ADDRESS TSO` LINKs with R0 = ENVBLOCK,
      `__TSO()`). ISPF never used it: it has CLIST support only. It reads
      JCC malloc headers of storage BREXX allocated; `printf/printf.c` does
      not compile with cc370 yet.
- [ ] **IRXNJE38**: needs the NJE38 macro library (`NSIO`, ...).
- [x] `asm/vtocprnt.asm`: the 11 cards as370 reported as consumed continuations
      belong to commented-out statements; nothing was lost (#165). The real
      find: as370 counts columns in **bytes** and translates UTF-8 byte by
      byte, so the `¬` in `vtocchek.asm` `OPERS2` became two bytes and
      shifted the operator table: `LIM(EXT < 2)`, `>=` etc. gave OPERERR and
      fell back to EQ (mvsdev JOB00635; 2.5.3 JOB00634; fixed JOB00637).

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
  `SREAD()` too, so `RXDIFF` of an FB data set against a VB one (or one
  with another LRECL) reports every line as changed.
- A normal comparison (`=`, `<`, `>`) ignores trailing blanks (#148):
  `'abc  ' = 'abc'` is 1.
- `PUTSMF` is gone (a call is error 51, as for any unknown function) and no
  SMF type 242 records are written (#152).
- `SOUNDEX` works on EBCDIC (#145); `LOCATE` with 4 arguments is error 40
  (#141).
- Load-module aliases `REXX` and `RX` (#143).
- `FORMAT` follows the TSO/E REXX Reference (#43): it rounds to NUMERIC
  DIGITS (`format(1/3)` gave `0.8`, `format(12.34)` gave `12`), `expp`/`expt`
  have their standard meaning (1/2 no longer select the C G/E formats; the
  old `format(x,2,n,2)` is `format(x,2,n,2,0)`), and a `before` too small is
  error 40 instead of a wider result.
- `WITH` is a keyword of `PARSE VALUE` only, as in TSO/E (#213): in
  `PARSE VAR`, `PULL`, `EXTERNAL` etc. it is a template target now.
  `parse var x with y` used to skip it; write `parse var x y`.
- Words are separated by blanks only, as in TSO/E (#212): TAB `'05'x`,
  NL `'15'x` and the other `isspace()` characters are ordinary characters
  in PARSE, WORD/WORDS/SUBWORD/…, SPACE, the `=` comparison and around
  numbers. Data with tabs no longer splits at the tab.
- Arguments are passed by value (#205); a term keeps its value across a
  later function call in the clause (#203); RETURN under INTERPRET returns
  from the routine (#201); `2=2=2`, `'.'` as a term, repeated prefix
  operators and prefix `+` work (#200, #207, #208, #193); `0**-1` is error
  42 (#199); PARSE word targets stop at the next trigger (#211).
- Numeric comparisons follow NUMERIC DIGITS (#223): values are compared
  rounded to DIGITS (at most 15 digits), so 100.5-50.6 = 49.9 is 1 and
  1E-20 = 0 is 0. NUMERIC FUZZ 0 is accepted (#219), NUMERIC set in an
  INTERPRET stays (#221), ARG(n) beyond the arguments is '' (#222).
- Integer results beyond 32 bits go on as reals instead of wrapping (#110);
  more precision than a double's ~15 digits is not available, whatever
  NUMERIC DIGITS says. NUMERIC FORM [VALUE] expression is accepted (#220;
  the first letter, E or S, decides).

SMP installation as a whole: umbrella issue #273 (incl. the open question
whether RXLIB travels as `++MAC` under SMP).

- [ ] SMP FMID: prefix **`TBRX`** (BREXX/370), digits = release version,
      so `TBRX300` for 3.0.0. Check it free on two stands (MVS/CE and TK5,
      with job numbers) before the first release; copy ufsd's
      `[distribution]` block.
- [ ] Package the non-load-module parts with mbt (`[distribution]`): RXLIB,
      SAMPLIB, PROCLIB, JCL, installation JCL, documentation — today only
      `legacy/` (`make -C legacy release`) knows how. RXLIB and SAMPLES:
      #272 (xmit370 refuses both today: SAMPLES lines up to 96 columns,
      UTF-8 characters in both; needs VB in mvslovers/cc370#601 and
      per-library `recfm`/`lrecl` in mvslovers/mbt#132). Replaces #127;
      #113 and #128 closed as obsolete with the SMP install.
- [ ] cc370 based release workflow (`release.yml` is legacy and manual only).
- [ ] Decide the version scheme shown by `PARSE VERSION` (now `3.0.0-dev`
      from `project.toml`; JCC builds showed `V2R5M3`).

## 6. Tests and CI

- [x] The six I/O tests were rewritten with #140 (standard semantics, FB80
      byte view, `'15'x`); in-place tests on a sequential data set
      (`lnoutps`, `updps`). No test uses `!=` any more; the rewrite in
      `scripts/mvstest.py` can go.
- [x] libc370 2.0 (#274): includes per libc370's migration maps, `rxtcp.c`
      on libc370's `inet_addr()`/`inet_ntop()`, pinned to the release
      2.0.0. MVS/CE run 36871820955 113/113.
- [x] libc370#189 tested from BREXX (#275, #276): `rdout`, `updvb`,
      `updmem`; the compat read guards are gone. MVS/CE run 36872581503
      116/116; results in libc370#189.
- [ ] **#277** `mvs-test.yml`: mvsMF never comes up in about half the runs
      (ready after ~1 s or not within 600 s; 6 of 11 attempts on
      2026-10-01). A rerun passes; read "Wait for MVS IPL" before the code.
      Fixed in the image (mvs-docker#8, #9; `:latest` = `67b06bc5`, 24/24
      IPLs); #286 waits 300 s, stops when the container ends and keeps one
      log artifact per attempt. Close after a few green runs (mvs-docker
      proposes it with a pointer to hyperion#889).
- [ ] Run the 8-character name collision / duplicate symbol check in the
      build (ld370 drops duplicate definitions silently; the check used for
      the migration lives outside the repo).
- [ ] `mvs-test.yml` runs on pushes to `master` and by hand
      (`gh workflow run mvs-test.yml --ref <branch>`); decide whether PRs
      trigger it too (it needs an MVS/CE container, ~5 min).
- Decided 2026-09-27: `mvs-test.yml` stays red until #140 fixes the six
  stream I/O tests; no list of expected failures. Resolved by #140 (75/75).
- [x] Compiler warnings: none left under `-Wall -Wextra -Werror` (#168).
- [ ] SonarCloud rule c:S1172 (unused parameter) does not accept
      `__unused`/`__attribute__((unused))` and duplicates `-Wextra`; it is
      most of the maintainability debt SonarCloud reports on a PR. Decide:
      disable it in `.sonarcloud.properties` (read from `master` only).
- [x] `-std=gnu99` in `[build] cflags`, as in the other projects: the build
      was gnu89 (cc370's default), so C99 loop declarations failed (#177,
      SonarCloud c:S5955). 127 translation units build clean with it.
- [ ] Host build for local debugging (#150); `CMakeLists.txt` goes with #133
      (D3).
- [x] **#189** tests from RossPatterson/CMS-370-BREXX: blocks 1+2
      (EBCDIC cases, missing BIF cases) in #196; FORMAT cases in #198;
      block 3: PARSE (#214), expr_ (#207, #208), interpr_ (#201) and
      Ross's CALL-by-value case (#205) done. Group A (arithtst, maths,
      numeric, expose, queued, options, arg2) in #224; abbrev1-3 left out
      (Ross does not run them; stray clause, exit check always 0). Found and
      fixed: ~~#219 NUMERIC FUZZ 0 rejected~~ (#226), ~~#221 NUMERIC under
      INTERPRET lost~~ (#228), ~~#222 ARG(n) beyond the arguments~~ (#227),
      ~~#223 numeric comparison ignored DIGITS~~ (#229). Merged master:
      mvsdev JOB00899 101/101. Then ~~#110 32-bit integer overflow~~ (#230;
      more than ~15 digits stays a BREXX limit), ~~#220 NUMERIC FORM VALUE~~
      (#231), ~~#225 S0C4 after compile errors in INTERPRET~~ (#232).
      Merged master: mvsdev JOB00924 103/103.
      Step 2 (#240): signal, conditi, call. Found: #233 CONDITION('I'/'S')
      not '' before a trap, #234 CONDITION('D') for ERROR, #173 (trap stays
      on): ~~fixed~~ (#241). #235 SIGL as a CALL argument, #236 missing
      routine error 51 not 43, #237 PARSE SOURCE changes in internal
      routines: ~~fixed~~ (#242). Merged master: MVS/CE run 36705823563
      JOB00014 106/106. Follow-ups: ~~#243 SIGL as an argument to a
      load-module function~~ (#263), mvslovers/mvsmf#376 spool read error
      for some DDs (fixed in mvsMF, not deployed yet), mvslovers/libc370#273
      floor/ceil/modf/fmod through a 32-bit int. Decided 2026-09-30, both to be implemented
      (plans in the issues): ~~#238 FAILURE condition~~ (#244, also raises
      ERROR under TRACE OFF; MVS/CE 106/106), ~~#239 CALL ON with real
      CALL semantics~~ (#245; callon.rexx, callend.rexx; mvsdev JOB00953,
      MVS/CE 108/108).
      Step 3 (#250): address_, trace_, add_test (addtest), t_mult (tmult).
      Found: ~~#246 ADDRESS without an operand~~, ~~#247 TRACE F~~, ~~#248
      positive exponent off by one ULP~~ (all #252; also INTERPRET "ADDRESS"
      in a routine changed the caller's environment), #249 no rounding to
      NUMERIC DIGITS: decided, a documented limit (#253, closed not
      planned). Merged master: MVS/CE 110/110.
      date_ as date.rexx (#257), with the comparison of the built-in DATE
      with Ross's REXX version. Found: ~~#254 `%` rounded, `//` overflowed
      beyond 32 bits~~ (#256; libc370 floor/ceil/modf go through a 32-bit
      int, BREXX no longer uses them there), ~~#255 a quoted function name
      called the internal label~~ and ~~#258 DATE('B') offset by 2×1721426~~
      (#261), ~~#260 DATE N leading zero, 4-digit year windowed~~ (#262).
      Left out with the reason in date.rexx: TIME(out,time,in) (ANSI, not
      TSO/E) and O (BREXX's yyyy/mm/dd on purpose). Merged master: MVS/CE
      110/110. All of Ross's non-CMS tests are adopted; abbrev1-3 stay out.
- [x] ~~**#259** PARSE SOURCE named the first exec of a call chain~~
      (#265, user report from TK5/2.5.3; also INTERPRET in a called exec).
      test/psname.rexx; mvsdev JOB01039/JOB01040 red, JOB01044 111/111;
      MVS/CE run 36770529005 JOB00014 111/111. Found on the way: #264, D9.
- [x] **#188** fixes from vlachoudis/brexx and RossPatterson/CMS-370-BREXX:
      ~~#199 `0**-1` S0CF~~, ~~#200 `2=2=2` error 21~~, ~~#201 RETURN under
      INTERPRET S30A~~ (#202); ~~#203 function call mid-expression~~ (#204,
      own fix, not PR 24/26); ~~#205 arguments by name~~ (#206, Ross #119);
      ~~#207 `'.'` as a term~~ (9c994903). Upstream PR 22 (unset stem entry)
      does not reproduce here (JOB00815).
      ~~#208 repeated prefix operators, #193 prefix +~~ (#210).
      PARSE: Ross's parse_ is test/parse.rexx (#214), red blocks skipped
      with their issue. ~~#211 word targets between triggers~~ (#215,
      upstream PR 12). ~~#212 words split at isspace()~~ (#217);
      ~~#213 WITH as a keyword outside PARSE VALUE~~ (#216; KEYVALUE.rexx
      adapted). Merged master: mvsdev JOB00869 93/93.
- [x] ~~mvslovers/mvsmf#374: the MVS/CE image's files listing abended
      with 88+ steps~~: fixed in image `sha256:8ac89b97…`; CI green again
      (runs 36674728837 93/93, 36674731286 master 92/92). The test job was
      never split.
- [ ] mvslovers/mvsmf#373: empty SYSOUT DDs answer HTTP 500, so
      `mvstest.py` shows 75 "FAILED TO RETRIEVE" per run (return codes are
      unaffected).

## 7. Cleanup when done

- [ ] **Cleanup pass** — defects from the 2026-02 code review, re-checked on
      this branch: #134 (tracking), #133 dead code and unbuilt sources.
      Done: ~~compiler warnings, `-Wall -Wextra -Werror`~~ (#168),
      ~~#129 uninitialised pointers~~ (#135; the `brexx.c` in-memory exec
      entry removed in #168),
      ~~#130/#131 buffer overflows~~ (#137, #136), ~~#132 logic errors~~
      (#141), ~~#40 SOUNDEX~~ (#145), ~~#147 `=` and trailing blanks~~
      (#148), ~~#140 stream I/O to the REXX standard~~ (#149), ~~#152 SMF removed~~
      (#153, supersedes #139), ~~#146 consumers of padded FB records~~ (#154),
      ~~#72 TRUNC rounded up, ignored NUMERIC DIGITS, changed its argument~~
      (#177), ~~#156 reals printed 30 digits of noise~~ (#181),
      ~~#183 S0C9 on the next RX after an abend: BREXX was linked REUS~~
      (#184, now NOREUS as 2.5.3 was), ~~#182 RX ran a CLIST from SYSPROC
      and called itself until SA06~~ (#186: SYSPROC/SYSUPROC members need
      a `/* REXX */` first line, as in TSO/E).
- [ ] **#191** ending with `PRIVILEGE('ON')` still set abends at cleanup
      (S30A; S378 in the samples LISTALL/LISTNCAT); 2.5.3 ends cleanly.
      Reset privilege in `RxMvsTerminate()` and the abend path.
- [ ] **#187** the EBCDIC not sign and the codepage the build and tools
      assume (research). X'5F' is NOT again since #190; the rest is open.
- [ ] **#185** `rac_check`'s profile cache and `globalVariables` are never
      reset after they are freed; harmless under NOREUS (#184). Also
      still open from #93: a DYNREXX definition rejected with RC 8 keeps
      its code string, and `rxDynrexxCtx` is never freed.
- [x] ~~**#114** SGENTRY ended in error 40 when `userid.EXEC(SGTCPLST)`
      was missing~~ (#271): STARGFSS called `sdrop` before checking
      `sread`. It now ends with RC 8 and names the member; the docs say
      to copy the SAMPLE member there. mvsdev JOB01085 (batch + TSO,
      old RC 40, new RC 8); the 3270 screen itself not run.
- [x] ~~**#93** SETG and DYNREXX kept the value they replaced~~ (#268):
      a loop setting one global ran out of storage (error 61). The 2021
      `FREE() … unknown pointer` messages are not reproducible, most likely
      the old heap tracer. test/setgleak.rexx; mvsdev JOB01050/JOB01054
      red, JOB01052 green, JOB01056 113/113;
      MVS/CE run 36831499312 JOB00014 113/113 (a rerun, see CLAUDE.md CI).
- [x] ~~**#102** ADDRESS LINKMVS/LINKPGM did not write the parameters
      back~~ (#269), and LINKMVS gave no room past the value: a program
      lengthening it overwrote the heap (ABEND SB0A). LINKMVS now gives
      500 bytes and honours the halfword (< 0 keep, 0 null); LINKPGM writes
      back at the old length. ATTCHMVS/ATTCHPGM not added (rexx370).
      Test module TSTLINK in the TESTLIB (test/tstlink.asm); mvsdev
      JOB01070 red, JOB01072 113/113; MVS/CE run 36836696046 113/113.
      Since #270 mvstest.py deploys the TESTLIB itself when it or a
      [[test]] module is missing (mvsdev JOB01078/JOB01079/JOB01080,
      MVS/CE run 36838254979 113/113).
- [x] ~~**#180** a number literal outside the S/370 float range abended
      with S0CC while the program was compiled~~ (#266; also **#87**,
      `'030E80'` from CMS-370-BREXX #63). `_Lisnum()` checks the magnitude
      first: from 1E75 on a string, below 1E-78 zero. test/hfprange.rexx;
      mvsdev JOB01045 red, JOB01047 green, JOB01048 112/112;
      MVS/CE run 36825396873 JOB00014 112/112 (a rerun: the first try
      timed out waiting for mvsMF).
- [ ] **#267** arithmetic beyond the float range abends with S0CC at run
      time (`1E50*1E50`, `10**80`, `+ - / %`) instead of error 42
      (mvsdev JOB01049, each operator mapped to its function). Check per
      operator or one SPIE for X'0C': not decided.
- [ ] **#178** EXECIO DISKW/DISKA ignore `fputs`/`fclose` errors and return
      RC 0. Since libc370#182, `fclose` reports a lost last block. There are
      two `RxEXECIO` definitions (`rxexecio.c`, `hostcmd.c`); settle which one
      runs.
- [x] ~~**#43** FORMAT returned wrong numbers (`format(1/3)` → `0.8`)~~:
      rewritten on the decimal digits after the TSO/E REXX Reference
      (#198); `MPRINT`, `RXDIFF`, `REXXCPS` adapted.
- [ ] **#192** X2D ignores length 0 and wraps beyond 32 bits;
      ~~#193 prefix `+` was a no-op~~ (#210); **#194**
      `DATATYPE(,'W')` ignores NUMERIC DIGITS. Test cases are in
      `test/x2d.rexx`/`datatyp.rexx`, commented out (#196).
- [x] ~~**#195** `rtest` passed a failed `\==` as `*WARN*` when the
      numbers were close~~ (#197; `test/rtestchk.rexx`).
- [ ] Remove `compat/` pieces as libc370 catches up (goal: nothing left).
- [ ] Remove `legacy/` once the cc370 build is the reference.
