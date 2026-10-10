# TODO — migration to mbt v2 / cc370

**brexx370 is in maintenance mode.** The scope is: the move to mbt v2 /
cc370 + libc370, one cleanup pass, and the TSO integration. No new features —
new REXX function belongs in rexx370.

Next work items for the cc370/libc370 build. Background, current state and
the reasoning behind each item:

* [internals/cc370-migration.md](internals/cc370-migration.md) — what changed, how the
  build and CI work, status of every JCC API and module, upstream issues
* [internals/libc370-jcc-gaps.md](internals/libc370-jcc-gaps.md) — JCC features libc370
  lacks, with a proposal per item (the input for retiring `compat/`)

Code locations are marked `TODO(cc370)` (`git grep -n "TODO(cc370)"`).

Current state (2026-10-07): the CI builds against the libc370 release
`2.6.3` (`[toolchain]` pin, #389) and passes 165/165 steps on MVS/CE (smoke test
plus the REXX suite, batch, and `addrcmd` under a batch TMP). Locally the sysroot is libc370 2.6.3
(`make doctor`). TSO is tested on mvsdev in the background (batch
TMP) and in the foreground (s3270). The JCC layer `compat/` is gone
(#298), `rxmvs.c` is split (#302), and the TSO integration ZMG0001 is
merged (#359) and installed on mvsdev; BREXX in SYS2.LINKLIB there is the
master build of 2026-10-07 (3aff1a1, with #368; JOB01563, the members
before it in `IBMUSER.BREXX370.SYS2BK.D261007`). `%SHUTFAST` from TSO
runs clean with it and shuts the system down (maintainer, 2026-10-07).

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
4. **`fopen()` DCB options** (§2): the directory part is done (#144:
   `__walkpd()`); creating with DCB/space is left, now part of #299.
5. ~~`-Wall`, then `-Werror`~~ (#167, #168): the build runs with
   `-Wall -Wextra -Werror`, 616 warnings fixed. Real defects found on the way
   are fixed there (LLSEARCH, ISEARCH, `fssSetCurPos`, …). ~~#171~~ array
   bounds (integer/bit/fixed-string arrays) fixed in #174. Follow-ups: 6.
   below, D6/D7.
6. **Memory defects found in 5.** (read from the code, not reproduced):
   - [x] **#172** string arrays (`SCREATE`, `SGET`, …): the array number
         and SCREATE's slot past the table were fixed with the move in
         #338; the element index, offsets, empty arrays, the gap SSET
         left, `R_screate(0)` (now `sarray_new()`/`sarray_room()`), SREAD
         and LL2S in PR #382. Test `sarrbnd`: JOB01653 old build 16 FAIL,
         JOB01655 PASS, suite 157/157 JOB01687; MVS/CE master 157/157
         (run 37651600426). The grown module exposed libc370#473 in
         `lineread` (#380, libc370 2.6.2, PR #381).
   - [x] **#384** a call with 33 to 63 arguments overwrote the first
         literal of its clause (64 on: Error 5): the bitmask of present
         arguments has 32 bits, MAXARGS was 99. MAXARGS is 32 now, a 33rd
         argument is Error 40 at compile time (PR #385). Test `args32`:
         JOB01696 red, JOB01698 green, suite 158/158 JOB01699; MVS/CE
         master 158/158 (run 37748552303). Found cross-reading the
         manuals. Open from it: `MAX()`/`MIN()` with every argument
         omitted copy a NULL argument (`builtin.c:514/553`).
   - [x] **#170** `SYSDSN()`: a DSN with member overflowed `sDSName[45]`
         (into the message: "BER01)DATASET NOT FOUND"). `SYSDSN` and
         `LISTDSI` use `getDatasetName()` now; also `LISTDSI('dd FILE')`
         and `parseArgs()` bounds. Tests `sysdsn`, `listdsi`.
   - [x] **#283** `getDatasetName()`: `DIR()` passed `sDSN[45]` (the
         function clears 55 bytes); no length check (`EXISTS` of a
         300-character name abended S0C1); a lone quote; an unquoted name
         without a prefix (batch) became empty and now stands as it is,
         as in TSO/E and EXECIO. Test `dsnname`. `LISTDSI` and `SYSDSN`
         followed in #170.
   - [x] **#169** `SYSDSN()` gives the TSO/E messages: catalog and volume
         (`rxDsAttr()` says why in errno), `MEMBER SPECIFIED, BUT DATASET IS
         NOT PARTITIONED`, `MEMBER NOT FOUND`, `UNAVAILABLE DATASET`
         (`rxDsHeld()`, SVC 99 reason 0210; `dynalloc()` fills `__errcode`
         now), `INVALID` for a name over 44 or a member over 8. Test
         `sysdsn` on mvsdev: JOB01643 old build 5 FAIL, JOB01645 PASS, suite
         156/156 JOB01646. Not in the suite: `VOLUME NOT ON SYSTEM`
         (JOB01647, a catalog entry on a missing volume) and `UNAVAILABLE
         DATASET` (JOB01651 while JOB01650 held it DISP=OLD). PR #379;
         MVS/CE 156/156 (run 37628178878).
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
8. **#298** — remove the JCC compatibility layer (`compat/`), part by part.
   File handling (**#299**) is done: every open goes through `src/dsio.c`,
   `CREATE()` and `OPEN` apply their allocation information, `OPEN` and
   `EXECIO` take names from `getDatasetName()` (#322, TSO prefix measured,
   JOB01345), `fileno()`/`__get_ddndsnmemb()` are gone (#319); #294 (#317).
   `libgcc64.c` done (#300), authorisation (#323), small libc gaps (#324),
   TSO and runtime (#325), assembler entry names (#326), sockets and
   threads (#327; `compat/jccompat.c` is gone, the NJE subtask needs a
   stand with NJE38: #328), and `compat/` with `BREXX_CC370` is gone: the
   force-include is `inc/mvsnames.h` (renames, `__unused`). Done.
9. **#302** — split `src/rxmvs.c` into one `rx*.c` per function family, one
   PR each, pure moves (ESD compared, `git diff --color-moved`); faults
   the move exposes are fixed in separate commits of the same PR. Done:
   linked lists → `src/rxll.c` (#332; it also fixed unchecked list numbers,
   LLCREATE's `llist[32]`, name overflows, LLFREE's dangling pointer);
   matrices → `src/rxmatrix.c`, shared tables in `inc/rxarray.h` (#336;
   fixed unchecked matrix numbers, rows and columns, `matrix[128]`, the
   int size overflow in MCREATE); integer/bit/SF arrays →
   `src/rxiarray.c` (#337; S2IARRAY/S2HASH check the string array);
   string arrays → `src/rxsarray.c` (#338; array numbers checked,
   SCREATE's `sarray[128]`, SARRAY(128)); data sets → `src/rxdsn.c`
   (#339; DIR line and fields bounded, __SWRITE's buffer, SUBMIT's
   sources checked); helpers → `src/vars.c` (#340), `src/loadmod.c`
   (#341), `src/privilege.c` (#342); rxmvs.c's old SonarCloud findings
   and code smells cleared (#343, #345: OUTTRAP/RXLIST/SPLIT buffers,
   MEMORY's `memory[128]`, DATTIMBASE's `parmi[10]`, LCS, RXLIST 'R').
   ENCRYPT/DECRYPT/ROTATE/RHASH → `src/rxcrypt.c` (#347); DECRYPT
   reverses ENCRYPT now (#348: it ran 1 round of 7 and stepped its
   round value below 0, since 2.5.3); string functions → `src/rxstr.c`
   (#349; test `strfunc.rexx`). Done: `rxmvs.c` keeps the
   MVS/TSO functions, the environment block and the registration.
   QUOTE's debug print `is quited` is gone (#351).
10. ~~**TSO integration**~~ (`ZMG0001`, §4, #353, merged in #359) — the
   actual goal after the migration. Shape agreed 2026-10-05 (maintainer, rexx370 session): EXEC
   patch copied from rexx370's `ZMG0002`, an IKJCT437 that reads line 1 by
   BPAM and LINKs BREXX, no TMP patch. `ZMG0003` (both REXX side by side,
   `/* BREXX` in line 1 → BREXX) lives in rexx370 (rexx370#330). Done on the
   BREXX side: ECTENVBK left alone, R0 = 0, IRXEXCOM gone (#355); RXINIT
   and RXTERM replaced by `src/tsoenv.c`, no terminal allocations, SYSUID
   in the background (#357); IRXISTAT removed (#356); the argument string
   comes unchanged from the CBUF (#358). The ZMG0001 usermod is in `tso/`
   (IKJCT430 from rexx370 f574e90, IKJCT437 our own) and installed on
   mvsdev: APPLY JOB01472, verify byte-identical JOB01473, case table
   24/24 installed JOB01478, foreground via s3270 green (#353).
   Under ISPF, PULL behaves as with 2.5.3 (§4, "PULL under ISPF").
11. ~~**Slow file I/O**~~ (#362, 2026-10-06): libc370's fgetc()/fputc()
   take an ENQ and a DEQ per byte (libc370#453). BREXX loads execs with
   fread(), reads lines with fgets(), skips/counts lines with
   Lskipline(), writes with fwrite(): IMPORT FSSAPI 6.0 -> 0.34 s, LINES
   of 2000 lines 18.5 -> 0.37 s, LINEOUT 11.5 -> 1.0 s, SAY 11.3 -> 1.2 s,
   `SYS2.EXEC(MVP) LIST` 9.0 -> 0.8 s CPU (mvsdev). Found on the way: a
   text-mode read cuts a record at its first X'00' (libc370#454; 2.5.3
   read it whole, JOB01508/01509/01511); EXECIO cut there already in 2.5.3.
12. **Next, open** (2026-10-05):
   - Prerelease **v3.0.0-dev** renewed 2026-10-07 at d2e76f9 (run
     37618693623) with the terminal/DD I/O (#375 STDOUT/STDERR/STDIN and
     SYSTSPRT/SYSTSIN, #377 PUTLINE and OUTTRAP, #378 GETLINE; libc370
     2.6.0); `ZMG0001.smp` unchanged (`339fba40…e9097`). Release page
     reworked for users (title "BREXX/370 3.0.0-dev (preview)"); its
     source is internals/release-page-3.0.0-dev.md. **A renewal deletes
     and recreates the release with generated notes**: afterwards run
     `gh release edit v3.0.0-dev --title ... --notes-file` with that
     source plus the generated list again. Before that
     renewed at 7013363 (run 37581857778) with #366 (CLIST pool removed), #368 (ADDRESS COMMAND
     privilege), #369 (search order documented) and #371 (unknown
     environment RC -3); `ZMG0001.smp` unchanged (`339fba40…e9097`).
     Published 2026-10-05, renewed 2026-10-06
     with #362 (file I/O) and #363 (ZMG0001 searches SYSUEXEC/SYSUPROC,
     jobs `tso/jcl`): the LINKLIB XMIT from the release workflow, and
     `ZMG0001.smp` plus `ZMG0001-jobs.zip`, attached by the release
     workflow itself since #365 (renewed 2026-10-06, run 37490673086; the
     stream's sha256 `339fba40…e9097` is the one installed on mvsdev). On mvsdev UY16532
     is accepted now (2026-10-06, needed for RESTORE of ZMG0001).
     The mbt 3 route is a USERMOD distribution kind (mbt#168, §4).
   - ~~SAY in a batch TMP goes to a SYSOUT of its own, not SYSTSPRT~~
     (§4), done in #377. Terminal/DD I/O: internals/dd-io.md (2026-10-07).
     Step 1 is done (#251): STDOUT/STDERR/STDIN, else SYSTSPRT/SYSTSIN
     outside TSO, set in `__premain()` (libc370 2.4.x). Next: PUTLINE
     under a TMP, winning over STDOUT/STDERR (RXTSO loses them), through
     a libc370 PUTLINE stream (libc370#463, released in 2.5.0; pin
     2.5.0). Built and measured on mvsdev (JOB01610), RXTSO without
     STDOUT/STDERR; foreground measured (s3270, no output DD in the
     TIOT). OUTTRAP now STACKs its DD per command, so it no longer
     catches the exec's own SAY/TRACE (as TSO/E; `test/outtrap.rexx`).
     Step 3 built (libc370 2.6.0
     `*GETLINE`): PULL reads SYSTSIN / the terminal under a TMP, RXTSO
     without STDIN, no stdin DD in the foreground (JOB01629, s3270).
   - IRXNJE38 without IRXEXCOM, and the NJE38 subtask test (#328), both
     need a stand with NJE38 (§4).
   - #267 (§7), #192 (§7).
   - Decisions D2, D5, D8, D9, D10 below; D10 waits on Peter (#284).
   - rexx370's side: ZMG0003 (rexx370#330) can reuse our IKJCT437's
     SYSEXEC/SYSPROC search.

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
- ~~**D6**~~ decided 2026-10-07: **#169** (`SYSDSN()` reported only `OK` /
  `DATASET NOT FOUND`) is fixed in brexx370, PR #379.
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

- [ ] **TSO**: run BREXX from TSO (CPPL via `tsoCppl()`, #175; `systemTSO()`,
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
- [x] **Authorization**: `_testauth()`, `_modeset()` and `_write2op()`
      left compat (#298): `__isauth()`, rxmvs.c `keyZero()` (key 0 in
      problem state, #191) and `wto()` directly; test `authwto`.
      `PRIVILEGE('OFF')` answers 8 even when it worked (not changed).
- [ ] **Sockets** (`rxtcp.c`, X'75' SVC; `tcp132` in CI) and **threads**
      (`rxnje.c` via `src/subtask.c`, cthreads) — the NJE subtask is
      untested, #328. Since libc370 2.3.x the CRT IDENTIFYs `CTHREAD` itself
      (BREXX links the thread driver); under crt1 nothing did.
- [ ] **VSAM** (`rxvsamio.c`, IRXVSMIO/IRXVSMTR), **IRXVTOC** — built and
      deployed, never called. MVSDUMP (a storage dump helper for the
      assembler modules, `DUMPIT` macro) was removed: no caller, and the
      2.5.3 release did not ship it.
- [x] `ADDRESS` host commands without redirection (`address.c`): the
      redirection had no caller; removed in #278.
- [x] **#144 `DIR()` was wrong in the cc370 build**: `DIR`, `LOCATE` and
      `PDSdet()` read the directory with libc370's `__walkpd()` now (dsio
      `rxWalkDir()`); test `dirlist`. `SYSDIRBLK` is `n/a` (not available
      that way).

## 2. Replace compat stubs (see internals/cc370-migration.md, compat table)

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
      First look for a BREXX-side route (internals/libc370-jcc-gaps.md #3–#5);
      a libc370 issue only if there is none.
- [ ] The fd layer (`dup/dup2/fdopen`): no user left. `reopen()` became
      `bindStdin()` (#353), and #251 replaced that with `__premain()`
      (`src/stdstrm.c`).
      Memory files `//MEM:` have no user left: `OPEN(…,'VIO')` is removed
      (#299). The `ADDRESS ... (STACK/FIFO/LIFO`
      redirection was never reachable: `RxRedirectCmd()` (`address.c`) had no caller since 2019 (`3f79908`, #25), in 2.5.3 too, and was removed in #278;
      bringing it back would be a new feature (model: `v2.5-jcc`).
- [x] `__get_ddndsnmemb()`: volser and DSORG (SYSVOLUME/SYSDSORG) — from
      `__locate()` + `__dscbdv()` (dsio `rxDsAttr()`); `LISTDSI` of a PDS
      reports PO and its members now. The function itself, `fileno()`,
      `isatty()`, `O_*` and `STD*_FILENO` are gone from compat; dsio
      `rxFileInfo()` reads the open stream (#299).
- [x] **#305** built-ins that changed their argument in place (`Lupper(ARGn)`,
      53 sites) changed the caller's literal, every equal one, and a passed
      variable (#330): `ARG_OWN(n)` copies first; test `argkeep`.
- [x] **#334** the follow-up: numbers were converted in place (`ABS`,
      `SIGN`, the math functions, `POW`, `ROUND`, `D2P`, and the `*`
      operator turned a caller's `'1.50'` into `1.5`), `ARGIN`/`ARRAYGEN`
      overwrote their argument (#335): `Lrdnum()` reads without
      converting; test `argnum`.
- [x] `systemTSO()` removed from compat (#162): its callers use `tsoCommand()`,
      the `ADDRESS TSO` path.
- [x] Heap/stack statistics (`__libc_heap_*`, `__libc_stack_*`) and
      `__libc_tso_status`: gone (#298). `SYSVAR('SYSHEAP')`/`'SYSSTACK'`
      answer 0, documented; no exec used them (FMTMON's dead `oldsize`
      removed).
- [ ] `_msize()` from a libc370 `malloc_usable_size()` instead of the
      `getmain()` prefix layout (now `heapSize()` in `bmem.c`, #298).

## 3. Upstream issues — drop the BREXX work-arounds once fixed

| Issue | Work-around in BREXX |
|-------|----------------------|
| mvslovers/cc370#467 (`long long / const`) | `lstring/mult.c` digit count via `sprintf` |
| mvslovers/libc370#188 (`INT32_MIN` positive) — closed, not in a release yet | own `INT32_MIN/MAX` in `inc/lstring.h` |
| mvslovers/libc370#189 (update modes, read on output stream) — closed 2026-09-27, complete in `edge`: direction check (PR #203), slice 1 (PR #207: `r+`/`w+`/`a+`) and slice 2 (PR #208: overwrite in place, PS only). Contract: #140 comment | none — the read/`fseek` guards in compat are gone (#275); `rdout`, `updvb`, `updmem` test what they covered |
| mvslovers/libc370#198 (`"a"` truncates like `"w"`) — fixed (PR #205), in `edge`: appends on PS; on an existing PDS member `fopen` fails (EOPNOTSUPP) instead of overwriting (appending to a member: libc370#204, not planned) | none — `EXECIO DISKA` (`hostcmd.c:709`, `rxexecio.c:269`) and `STREAM … APPEND` now append on PS and fail on an existing member |
| mvslovers/libc370#199 (an empty line writes no record, FB and VB) — fixed (PR #201), in `edge` | none — **every BREXX program writing empty lines loses them today** |
| mvslovers/libc370#200 (`ftell` on a write stream wrong, `fseek` re-emits the write buffer) — fixed (PR #202), in `edge`: `ftell` counts from the start; `fseek` on a write-only stream fails with `ESPIPE` unless it stays in place | none — `Lcharout`/`Llineout` ignore the `fseek` result, so a positioned write on an `OPEN 'W'` handle should now land at the current position (from the code, not measured; #140) |
| mvslovers/libc370#182 (`fclose` lost the last short block and returned 0) — fixed (PR #227), in `edge` at 14edfa7: `EOF` + `ENOSPC`/`EIO` | none — `CLOSE()` passes the result through (`rxfiles.c:614`); EXECIO RC 20 since #178 |
| mvslovers/libc370#225 (`%f`/`%e` scaling inexact on HFP: `%e` of 1e-30 is `9.99…E-31`) — open, no pressure from BREXX | none — seen through REXX at the range edges (JOB00726, JOB00734: `trunc(1e40*1)`); literals and variables are exact in TRUNC since #177; reals print through `Lreal2str` since #181 (`1e-70*1` → `9.99999999999999E-71`) |
| mvslovers/libc370#197 (`racf_auth()` MODESETs, S047 without APF) | `rac/` issues SVC 130 itself; switch to `racf_auth()` once decided |
| mvslovers/libc370#210 (`ppacppl` never set) — fixed (PR #217), in `edge` at 832d794: `__start()` stores the CPPL of a TSO command processor (NULL under TSO CALL and in batch); measured on mvsdev by libc370 (JOB00683/00686/00689, 3270 foreground as MVSCE01) | none — `jcc_entry_r13()` removed, `tsoCppl()` reads `ppacppl` (needs a sysroot >= 832d794; an older one leaves `ADDRESS TSO` without a CPPL). Side finding libc370#218: the CPPL grtptrs loop records 10 words, only 0-3 are meaningful |

- [x] `[toolchain] libc370` is pinned to the release `2.0.0` (#274);
      `build.yml` follows libc370 `main` (the 2.0 line) again. The fixes
      BREXX waited for in `edge` (#183/#187/#188, #198, #199, #200, #189)
      are in 2.0.0. Still to remove: the work-arounds for them (§2).

## 4. Modules

- [x] **TSO integration** as a `++USERMOD` (`ZMG0001`, #353), shipped as
      object decks with `++VER … FMID(EBB1102)`. `ZMG0001` (BREXX only),
      `ZMG0002` (REXX/370 only) and `ZMG0003` (both; rexx370) are mutually
      exclusive. BREXX prerequisites: LINKable from IKJCT437 with member,
      DD and arguments (#358, done); ECTENVBK untouched (#355, done).
- [x] **Aliases REXX and RX** for BREXX (`aliases` in project.toml, mbt
      4c3d8e8). `LISTDS … MEMBERS` shows `BREXX ALIAS(REXX,RX)`; batch and TSO
      run through all three names (mvsdev JOB00531). SMP ships them with
      `TALIAS` (mbt#114). Never drop a released alias without reading
      mbt#115.
- [x] **Link attributes** declared per module (mbt v2.1.2, #318):
      IRXVTOC RENT REUS REFR; IRXVSMIO, IRXVSMTR NORENT REUS;
      BREXX neither. The assembler modules had been
      RENT+REUS only by ld370's default. mbt's 122 writable-data warnings
      for BREXX stay (NORENT, as 2.5.3 ran from its APF library).
- [x] **IRXEXCOM** dropped (maintainer, 2026-10-05; #355 closes #151):
      with BREXX/370 and REXX/370 side by side ECTENVBK and the IRX names
      belong to REXX/370. BREXX leaves ECTENVBK alone and LINKs with R0 = 0;
      `irx/`, `metal/`, `printf/`, `asm/svc.asm`, `asm/getsa.asm` are gone.
- [x] **SAY in a batch TMP** went to a SYSOUT of its own per BREXX run,
      not to SYSTSPRT as under TSO/E (#353). Since #377 SAY, TRACE and
      messages go through PUTLINE under a TMP, and since #378 PULL reads
      through GETLINE (internals/dd-io.md).
- [x] **ZMG0001 in the release package** (#364, #365): the decks are committed
      in `tso/usermod/` (`build.sh exec` checks a rebuild against them),
      and `release.yml`'s job `zmg0001` attaches `ZMG0001.smp` and
      `ZMG0001-jobs.zip` after mbt's release job. Interim, agreed with mbt
      2026-10-06: mbt 3 plans project tasks (design §9), a USERMOD
      distribution kind is proposed for §6.4 (mbt#168, with
      `ZMG0001.smp` as the golden file); `usermod.py` stays the reference until mbt reproduces
      it byte for byte. Found on the way: `IKJCT430.ASM` named
      `EXPAROUT` in an EQU before defining it; IFOX00 answers IFO231 and
      the value 0 (cc370#89), as370 1.4.0 IFO231. Moved, deck unchanged;
      rexx370's copy (ZMG0002) has the same lines (fixed there locally,
      not yet committed). Verified on the release: run 37490673086,
      asset sha256 `339fba40…e9097`, jobs identical to `tso/jcl`.
- [ ] **PULL under ISPF** (known, before and after #357): from an ISPF
      panel (`tso rx …`) line-mode output is held back until the next
      terminal read, so input is typed after the first line; in option 6
      PULL gets no input (`GOT=<>`). TSO READY is correct. Measured by the
      maintainer 2026-10-05 (#357 comment). Not planned.
- [ ] **IRXNJE38**: needs the NJE38 macro library (`NSIO`, ...), and a
      new way to hand its results to `rxlib/NJE38DIR.rexx`: it reads and
      sets REXX variables through IRXEXCOM (RXGET/RXPUT), which BREXX no
      longer has (#355). Later (maintainer, 2026-10-05).
- [x] **IRXISTAT** (ISPF statistics of a PDS member through IRXEXCOM)
      removed with `asm/rxpdstat.asm`, `asm/rxpdstax.asm` and
      `maclib/RPFCOMM.mac`: no caller in 3.0 or 2.5.3, and no IRXEXCOM.
- [x] `asm/vtocprnt.asm`: the 11 cards as370 reported as consumed continuations
      belong to commented-out statements; nothing was lost (#165). The real
      find: as370 counts columns in **bytes** and translates UTF-8 byte by
      byte, so the `¬` in `vtocchek.asm` `OPERS2` became two bytes and
      shifted the operator table: `LIM(EXT < 2)`, `>=` etc. gave OPERERR and
      fell back to EQ (mvsdev JOB00635; 2.5.3 JOB00634; fixed JOB00637).

## 5. Release and packaging

**Release notes 3.0 — user-visible changes so far** (collect here, write
them up for the release):

- The manuals are new: ML03-0001..0003, as PDF and on Read the Docs
  (#396). Attach the PDFs to the release with their `SHA256SUMS` lines,
  and add a books step to the release checklist (root CLAUDE.md).
- From #386 (the defects found writing them), what a caller notices:
  a `CALL` of a routine that returns no value drops `RESULT`; a `SELECT`
  with no true `WHEN` and no `OTHERWISE` is error 7.3; `QUOTE` takes a
  `qtype`; `DATE('GERMAN')` is `dd.mm.yy`; `ROUND` rounds once (3.141 to
  3.14); `C2D` of more than four significant bytes is error 40;
  `PRIVILEGE('OFF')` returns 0; `ISORT`, `SQSORT`/`SHSORT` 'D' and
  `SREVERSE` return the count; `LL2STEM` returns the count; `TCPWAIT`
  reports one event per call and times out under 2 s; `EXECIO ... SKIP n`
  with the stack skips the first n; `STREAM()` reports NOTREADY after a
  failed operation; `MATCH [a-z]` takes letters only; RXLIB routines
  that ended the caller with `EXIT` (STDATE, FMTBANNR) return.

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
- The undocumented CLIST variable pool is gone (#366): `VALUE(name,,'CLIST')`
  is error 40 as for any unknown pool (it was already without a calling
  CLIST). `ADDRESS ISPEXEC` stays; ISPF dialog
  variables shared with REXX are rexx370's (#124).
- `ADDRESS` to an environment BREXX does not have gives RC -3, as in
  TSO/E, without the message `ERROR> please report this.` (#371; it was
  RC -42).
- `ADDRESS COMMAND 'CP …'` no longer abends S047 in an unauthorised task
  (#368): it takes the privilege for the call, as `CONSOLE()` did. Where
  RAKF denies FACILITY SVC244, `ADDRESS COMMAND` gives RC -5 (it exists
  only with FACILITY DIAG8CMD; without it the environment is unknown, RC
  -3 since #371). `CONSOLE()` returns 0 (it returned nothing before); like
  `PRIVILEGE`, `MTT`, `MTTX` and `ADDRESS CONSOLE` it exists only with
  FACILITY SVC244, as in 2.5.3 (error 43 for others). Measured as MVSCE02
  on mvsdev, 2026-10-07: error 43.1 without SVC244, RC -42 (now -3)
  without DIAG8CMD, RC -5 with DIAG8CMD and without SVC244. A `PRIVILEGE('ON')` of the exec now stays in effect after
  `CONSOLE()`, `ADDRESS CONSOLE` and `SYSVAR('SYSCP')`, which used to
  switch it off.
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
- [x] cc370 based release workflow: `release.yml` uses mbt's (tag `v*`);
      the JCC one lives on in the branch `v2.5-jcc` only.
- [ ] Decide the version scheme shown by `PARSE VERSION` (now `3.0.0-dev`
      from `project.toml`; JCC builds showed `V2R5M3`).

## 6. Tests and CI

- [x] **Books in CI**: `build.yml` job `books` builds ML03-0001..0003 as
      PDF and as the web form on every PR, Typst 0.15.1 pinned by sha256 as
      in `.readthedocs.yaml`; the PDFs are the artifact `books`.

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
- [x] **#277** (closed 2026-10-02, 14/14 IPLs on `67b06bc5`) `mvs-test.yml`: mvsMF never came up in about half the runs
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

- [ ] **Remove the Sphinx manual** (decision: maintainer). Since #396 Read
      the Docs builds the books; `docs/source/`, `docs/markdown/`,
      `docs/Makefile`, `docs/make.bat`, `docs/requirements.txt` and
      `docs/README.md` are built by nothing. One PR, with every reference
      rewritten (`git grep -n 'docs/source\|docs/markdown'`). Until then a
      behaviour change goes into the book and into rst and md.

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
- [x] **#191** `PRIVILEGE('ON')`: compat's `_modeset(0)` went to supervisor
      state + key 0 where JCC stayed in problem state; MVS then maps
      subpool 0 to 252 and libc370's heap broke (S30A, S378). Key 0 in
      problem state again; `RxNoPriv()` at the end (#291). Tests
      `privend`, `privfree`; LISTALL RC 0 on mvsdev (JOB01153).
- [x] **#294** LISTNCAT on mvsdev: `fopen()` of
      `PUB001.NJE38.NETSPOOL.DATA` abended S913-0C. Not RAKF (RACHECK
      READ answers RC 0, JOB01325) but its password: outside the TSO
      foreground dsio refuses a password protected data set (EACCES,
      SYSDSN `PROTECTED DATASET`) (#317; JOB01327/01328, suite 134/134).
- [x] **#187** the code page is the one set in the user's emulator:
      CP037, x3270 "bracket" and IBM-1047 are accepted (NOT since #190,
      MATCH's `[ ] ^` since #350; docs: restrictions, "Code pages").
- [x] **#185** `rac_check`'s profile cache and `globalVariables` are freed
      and set to NULL (`hashMapFree()`, `rac_done()`).
- [ ] Still open from #93: a DYNREXX definition rejected with RC 8 keeps
      its code string, and `rxDynrexxCtx` is never freed. From #185's
      sweep: `rxnje.c`'s `subtasks` map is never freed (needs the NJE
      subtasks stopped first).
- [ ] **#386** defects found writing the ML03 manuals, one collecting
      issue: storage overruns (external functions, VSAMIO names, EXECIO
      FIFOW, MINVERT, JOIN, ROTATE, VLIST, ADDRESS LINK), two TCPWAIT
      hangs, some 20 wrong results (DYNREXX, ROUND, DATE GERMAN, RANDOM
      range, C2D, PRIVILEGE OFF, …), the TSO/E differences RESULT and
      SELECT, and RXLIB/sample faults. Work the storage overruns first.
      Done: EXECIO FIFOW/LIFOW (#387), VSAMIO KEY/VAR (#388), external
      functions (#390), libc370 2.6.3 for RANDOM's spread (#389), VLIST
      (#391), JOIN (#392), ROTATE (#393), MINVERT (#394); section 1 is
      done (ADDRESS LINK was not a defect: it matches TSO/E). TCPWAIT
      (section 2) in #395. The rest of the storage defects (section 7):
      CONSOLE (#397), linked lists (#398), array bounds (#399), SETG,
      FPOS and EVLEN (#400). The wrong results, in five groups: the
      preload REXX (#401), array and list counts (#402), numbers (#403),
      I/O (#404, with a TCPWAIT defect found on the way) and the rest
      (#405). Sections 1, 2, 3 and 7 are done; sections 5 and 8 (RXLIB,
      KEYVALUE, FSS routines, samples) in #407, #408, #409, with a TCPWAIT
      defect (timeout under 2 s) and RXCOPY's SYSDIRBLK found on the way.
      KEYVALUE and the FSS routines are fixed from the code, not measured
      (no VSAM space on mvsdev). Decided and done: RESULT and SELECT as in
      TSO/E (#411, consumers adapted), QUOTE built-in with qtype (#412).
      FSSMENU measured on a 3270 with s3270 (`scripts/tsodrive.py`): no
      option could be selected without MenuOption (#413). Open: #264
      (external exec without PROCEDURE shares variables), waiting on the
      maintainer's talk with Peter.
- [ ] cc370 folds `strstr(s, "x")` / `strpbrk(s, "x")` with a
      one-character literal into `strchr(s, c)` with the ASCII value.
      DYNREXX works around it with `strchr(s, '}')` (#405); the cc370
      fix is on a branch there, not merged (2026-10-09). Once a cc370
      release has it, the workaround can stay; nothing else uses the
      pattern.
- [ ] `LLCOPY` exists twice: the C built-in `R_llcopy` (`src/rxll.c:637`)
      and a REXX version in `src/preload.c`. Registered built-ins are
      found before the external search, so the preload one is most likely
      dead (read from the lookup order, not measured). Check with a test,
      then remove it; the manuals document the C behaviour (Book session,
      2026-10-07).
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
- [x] **#178** EXECIO DISKW/DISKA: a failed `fputs`/`fputc`/`fclose` gives
      RC 20 (test `execfull` on a one-track `FULLDD`, `MVSTEST FULLDD`).
      `hostcmd.c` (the other `RxEXECIO`) was one comment since 2019, removed.
- [x] ~~**#43** FORMAT returned wrong numbers (`format(1/3)` → `0.8`)~~:
      rewritten on the decimal digits after the TSO/E REXX Reference
      (#198); `MPRINT`, `RXDIFF`, `REXXCPS` adapted.
- [ ] **#192** X2D ignores length 0 and wraps beyond 32 bits;
      ~~#193 prefix `+` was a no-op~~ (#210); **#194**
      `DATATYPE(,'W')` ignores NUMERIC DIGITS. Test cases are in
      `test/x2d.rexx`/`datatyp.rexx`, commented out (#196).
- [x] ~~**#195** `rtest` passed a failed `\==` as `*WARN*` when the
      numbers were close~~ (#197; `test/rtestchk.rexx`).
- [x] Remove `compat/` pieces as libc370 catches up (goal: nothing left): done, #298.
- [ ] Remove `legacy/` once the cc370 build is the reference.
