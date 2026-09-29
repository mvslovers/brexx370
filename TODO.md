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

Current state: smoke test and all 80 REXX tests pass on MVS/CE in CI
(`mvs-test.yml`), no abends; batch only. The stream I/O tests pass since
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
   edges. Follow-up: **#180** (a literal outside the HFP range abends at
   compile time, S0CC).
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
7. **#133** — dead code and unbuilt sources (D3 decided). Postponed
   2026-09-28: cleanup only, nothing broken. Also holds the unreachable
   PUTENV branch in `rxstr.c` (`Lstrcpy` where `Lcat` was meant).
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
- **D7** **#173** a `SIGNAL ON SYNTAX` trap stays on after it fires; an
  error inside a called function then loops endlessly (reproduced, mvsdev
  JOB00694/JOB00695). An interpreter defect: fix it in maintenance mode?
- **D8** SonarCloud rule c:S1172 (§6): disable it in `.sonarcloud.properties`
  on `master`?

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
- [ ] Memory files `//MEM:` and the fd layer (`dup/dup2/fdopen`) —
      `ADDRESS ... (STACK/FIFO/LIFO` redirection returns -3 today.
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
| mvslovers/libc370#189 (update modes, read on output stream) — direction check (PR #203) and slice 1 (PR #207: `r+`/`w+`/`a+`, write only at the end) in `edge`; slice 2 (overwrite in the middle, PS only) open. Contract: #140 comment | read/`fseek` guards in compat, removable once BREXX builds on the direction check |
| mvslovers/libc370#198 (`"a"` truncates like `"w"`) — fixed (PR #205), in `edge`: appends on PS; on an existing PDS member `fopen` fails (EOPNOTSUPP) instead of overwriting (appending to a member: libc370#204, not planned) | none — `EXECIO DISKA` (`hostcmd.c:709`, `rxexecio.c:269`) and `STREAM … APPEND` now append on PS and fail on an existing member |
| mvslovers/libc370#199 (an empty line writes no record, FB and VB) — fixed (PR #201), in `edge` | none — **every BREXX program writing empty lines loses them today** |
| mvslovers/libc370#200 (`ftell` on a write stream wrong, `fseek` re-emits the write buffer) — fixed (PR #202), in `edge`: `ftell` counts from the start; `fseek` on a write-only stream fails with `ESPIPE` unless it stays in place | none — `Lcharout`/`Llineout` ignore the `fseek` result, so a positioned write on an `OPEN 'W'` handle should now land at the current position (from the code, not measured; #140) |
| mvslovers/libc370#182 (`fclose` lost the last short block and returned 0) — fixed (PR #227), in `edge` at 14edfa7: `EOF` + `ENOSPC`/`EIO` | none — `CLOSE()` passes the result through (`rxfiles.c:614`); EXECIO ignores it (#178) |
| mvslovers/libc370#225 (`%f`/`%e` scaling inexact on HFP: `%e` of 1e-30 is `9.99…E-31`) — open, no pressure from BREXX | none — seen through REXX at the range edges (JOB00726, JOB00734: `trunc(1e40*1)`); literals and variables are exact in TRUNC since #177; reals print through `Lreal2str` since #181 (`1e-70*1` → `9.99999999999999E-71`) |
| mvslovers/libc370#197 (`racf_auth()` MODESETs, S047 without APF) | `rac/` issues SVC 130 itself; switch to `racf_auth()` once decided |
| mvslovers/libc370#210 (`ppacppl` never set) — fixed (PR #217), in `edge` at 832d794: `__start()` stores the CPPL of a TSO command processor (NULL under TSO CALL and in batch); measured on mvsdev by libc370 (JOB00683/00686/00689, 3270 foreground as MVSCE01) | none — `jcc_entry_r13()` removed, `jcc_cppl()` reads `ppacppl` (needs a sysroot >= 832d794; an older one leaves `ADDRESS TSO` without a CPPL). Side finding libc370#218: the CPPL grtptrs loop records 10 words, only 0-3 are meaningful |

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
- [ ] **#189** tests from RossPatterson/CMS-370-BREXX: blocks 1+2
      (EBCDIC cases, missing BIF cases) in #196; FORMAT cases in #198;
      block 3 (PARSE, CONDITION, CALL, SIGNAL, INTERPRET, …) open, goes
      together with the upstream fixes from #188.
- [ ] **#188** fixes from vlachoudis/brexx: ~~#199 `0**-1` S0CF~~,
      ~~#200 `2=2=2` error 21~~, ~~#201 RETURN under INTERPRET S30A~~ (#202).
      Upstream PR 22 (unset stem entry) does not reproduce here (JOB00815).
      ~~PR 24/26 function call mid-expression~~: own fix, #203 (#204).
      Open: 9c994903 (`'.'` as a literal), PR 12 (PARSE word targets,
      invasive). ~~CMS-370-BREXX #119 arguments by name~~ (#205). — each with
      the matching test from #189 block 3.
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
      reset after they are freed; harmless under NOREUS (#184).
- [ ] **#180** a number literal outside the S/370 float range (`1e-79`,
      `'1e76'`, even quoted) abends BREXX with S0CC while the program is
      compiled (JOB00757). Likely `_Lisnum()` computing `pow(10, 79)`.
- [ ] **#178** EXECIO DISKW/DISKA ignore `fputs`/`fclose` errors and return
      RC 0. Since libc370#182, `fclose` reports a lost last block. There are
      two `RxEXECIO` definitions (`rxexecio.c`, `hostcmd.c`); settle which one
      runs.
- [x] ~~**#43** FORMAT returned wrong numbers (`format(1/3)` → `0.8`)~~:
      rewritten on the decimal digits after the TSO/E REXX Reference
      (#198); `MPRINT`, `RXDIFF`, `REXXCPS` adapted.
- [ ] **#192** X2D ignores length 0 and wraps beyond 32 bits; **#193**
      prefix `+` is a no-op (`+1E+2` stays a string); **#194**
      `DATATYPE(,'W')` ignores NUMERIC DIGITS. Test cases are in
      `test/x2d.rexx`/`datatyp.rexx`, commented out (#196).
- [x] ~~**#195** `rtest` passed a failed `\==` as `*WARN*` when the
      numbers were close~~ (#197; `test/rtestchk.rexx`).
- [ ] Remove `compat/` pieces as libc370 catches up (goal: nothing left).
- [ ] Remove `legacy/` once the cc370 build is the reference.
