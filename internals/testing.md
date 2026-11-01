# Testing: CI history and the mvsdev details

Moved verbatim from `CLAUDE.md` on 2026-10-19 so that the file every session
loads stays short. `CLAUDE.md` keeps the commands; this file keeps the
history, the `mvstest.py` directives and the measured facts about the stands.

## CI: `mvs-test.yml` history

- `mvs-test.yml` is green since #140: the expected state is "191/191 passed"
  (183 steps on 2026-10-11, master after #421, the first run on mbt 3, run
  38139090496; `hfpovfl` and `version` made it 185; #444 added five more:
  `vsamio` with the two IDCAMS steps around it, `vtoc` and `vtocbat`;
  #459 added `matovfl`).
  It builds against the
  libc370 release `2.28.0` and cc370 `1.6.3` (#441; 2.4.0 or later for `__premain()`, #251; 2.5.0 for `*PUTLINE`, 2.6.0 for `*GETLINE`,
  2.6.2 for `fseek()` inside the buffer, libc370#473 / #380; 2.6.3 for `rand()`, libc370#387;
  2.8 takes the IBM macros from maclib370 and needs cc370 1.6.0, #426);
  when it turns red, read the step list. Since mvslovers/mvsmf#374
  (image `sha256:8ac89b97…`) the job lists its spool with 88+ steps; a
  "spool read error … /files" in the log means that listing failed again.
  A read error on single DDs ("first spool block belongs to another data
  set", `…/files/<id>/records`) is mvslovers/mvsmf#376 and does not affect
  the step results. It is fixed in mvsMF (closed 2026-09-30) but not yet
  deployed on mvsdev or in the MVS/CE image, so it still shows up.
- On 2026-10-01 the first run after a merge failed twice in "Wait for MVS
  IPL (mvsMF)" (`mvsMF not ready after 600s`, runs 36825396873 and
  36831499312), and `gh run rerun` passed both times. Read that step
  before suspecting the code. Tracked in #277 (6 of 11 attempts that day);
  fixed in the image `67b06bc5` (mvs-docker#8, #9). Since #286 the step
  gives up after 300 s or as soon as the container ends ("MVS container is
  exited"), and the logs are `mvs-test-logs-<attempt>`, one per rerun.

## `mvstest.py` and its `MVSTEST` directives

- `mvstest.py` judges a step by its RC only. It runs as `mbt run mvstest`
  (`mbt/init.lua`): mbt hands it the target and its mvsMF session token,
  `scripts/mvsmf.py` is its client. Without them it stops; it has no
  password and no fallback. A test that a failure could
  end early with RC 0 declares another RC (`MVSTEST RC=n` in the source,
  e.g. `callon.rexx`), so an early end reads as FAIL. `MVSTEST PARM=DSN`
  starts a step by its data set name (`PARM='<testlib>(member)'`, no
  RXRUN DD), as `RX 'DSN(MEMBER)'` does: `dsnmain.rexx`. `MVSTEST FULLDD`
  adds a DD FULLDD of one track without secondary space (`execfull.rexx`);
  `CREATE()` cannot make one, compat drops `pri`/`sec`. `MVSTEST TSO`
  runs the step under a batch TMP (`IKJEFT01`, SYSTSIN `BREXX
  '<testlib>(member)'`), for what needs a CPPL (`addrcmd.rexx`); each
  `MVSTEST SYSTSIN text` adds a SYSTSIN line after it, data that PULL
  reads through GETLINE (`pulltso.rexx`). `MVSTEST RXLIB name ...`
  uploads those `rxlib/` members into `…BREXX370.RXLIBX`, concatenated
  behind the step's RXLIB, which keeps RTEST alone (`rxlibfix.rexx`).
  An `EXIT` in an RXLIB routine ends the calling exec, so such a test
  declares another RC (`MVSTEST RC=3`). `MVSTEST VSAM` defines a KSDS for
  the step (an IDCAMS step before it, key 8, RECORDSIZE 100 200, one loaded
  record, on the target's volume, `MBT_TARGET_VOLUME`), gives it as DD
  VSAMTST and VSAMTS (six characters is all that is left of a DD name
  after the `#%` prefix of IRXVSMTR), and deletes it in an IDCAMS step
  after it; the two IDCAMS steps count in the summary (`vsamio.rexx`).
  `@CLUSTER@` in such a test becomes the cluster's name, for an
  `ALLOCATE()` of it instead of the DD (`vsamio.rexx`, #531).
  `vtoc.rexx` runs under TSO, `vtocbat.rexx` in batch: IRXVTOC needs
  TSO and answers -16 without it.

## Testing on mvsdev in detail

- `mbt deploy` writes `BREXX370.DEV.LINKLIB`, the mbt 3 default (until
  #420 mbt 2's `IBMUSER.BREXX370.V3R0M0D.LINKLIB`). It replaces the members
  with IEBCOPY and never deletes the library. On mvsdev mbt allocated it
  on WORK00 with the first deploy (2026-10-11, suite 183/183 JOB01978),
  deliberately **without** an APF entry: BREXX is no started task, and the
  suite measures BREXX running unauthorized (the maintainer's decision).
  mbt 2's `IBMUSER.BREXX370.V3R0M0D.LINKLIB` (PUB000) was deleted on
  2026-10-11; the `…V3R0M0D.TESTLIB` of `mbt test --mvs` stays.
- `mbt run mvstest [-- --only NAME ...]` runs the smoke test plus
  `test/*.rexx` as batch steps (`PGM=BREXX,PARM='RXRUN'`), spool in
  `build/mvstest.spool`; `-- --linklib DSN` names another library. The
  test PDS is `IBMUSER.BREXX370.TESTS`.
  Its STEPLIB is the LINKLIB plus, behind it, the `…V3R0M0D.TESTLIB` of
  `mbt test --mvs`: `test/addrlink.rexx` LINKs the test module `TSTLINK`
  from there (#102). When the TESTLIB or a test module is missing, the
  script stops: run `mbt test --mvs` first, and again after changing a
  test module. It does not start mbt itself: the inner mbt's logoff made
  mvsMF refuse the outer session's token (HTTP 401, #421).
- `mbt test --mvs --only NAME` runs a test module as a batch step and
  as a TSO step (`CALL` under IKJEFT01), from `…V3R0M0D.TESTLIB`.
- **TSO in the background:** an IKJEFT01 step with STEPLIB = the dev LINKLIB
  and `SYSTSIN` `BREXX 'IBMUSER.BREXX370.TESTS(member)'`. There,
  `SYSVAR('SYSENV')` is `BACK` and `SYSTSO` is 1.
- **A real 3270:** `mbt test --tso [--only NAME]` runs each
  `test/tso/*.lua` in a TSO session of its own, logged on as the target's
  `[tn3270]` user (IBMUSER on `dev1`; not while you are logged on with it
  yourself) and always logged off. `[tso.NAME] fixtures` in `mbt.toml`
  load the execs and RXLIB members a test needs into
  `IBMUSER.BREXX370.FIX.NAME.KEY` first (job MBTTSOFX); the test ALLOCs
  them through `t.fixtures`. FSS needs it (not batch, not a batch TMP):
  `test/tso/fssmenu.lua` (#422). Ad hoc 3270 work is a small Lua file of
  the same form (`scripts/tsodrive.py` went with #422). The `BREXX` TSO command
  runs the BREXX installed on the stand, not the dev LINKLIB (on mvsdev
  3.0.0-dev of 2026-10-07); an exec must `ADDRESS FSS` after
  `CALL IMPORT FSSAPI`. A session left logged on keeps the userid in use
  until `C U=IBMUSER`. FSSMENU was measured this way (#413).
- Long program arguments: `PARM=('part1','part2')` continuation, 100
  characters in total.

## Facts about mvsdev that the measurements rely on (2026-09-27)

- `BREXX370.DEV.LINKLIB` and the `TESTLIB` are **not** in `IEAAPF00`, so
  BREXX and test modules run unauthorized. WTOs show the `+` prefix. (The
  measurements below were made with `IBMUSER.BREXX370.V3R0M0D.LINKLIB`,
  which was not APF-authorized either.)
- RAKF is active, and the libc370 `tstracmx` fixture is installed
  (`LIBC370.TSTRACMX.ALLOW/DENY`, `LIBC370.RACTEST.*`, user MVSCE02).
  IBMUSER is ADMIN: `FACILITY SVC244` READ yes, UPDATE no, `BRXALLAUTH` no.
- SVC 130 answers from problem state without APF. `racf_auth()` and
  `smf_write()` abend S047 without APF and work after SVC 244
  (`privilege(1)`). SVC 83 needs APF but not supervisor state. Details and
  the probe source are in mvslovers/libc370#197 (JOB00486/JOB00488).
- TK5: the mbt 3 target `m38b` is MVSTK5-BLD (mvsMF on port 8085, HERC01,
  volume TSO001), which has the PL/I F compiler. Measured there once: the
  PL/I F samples `jcl/PL1PI.jcl`/`PL1CUT.jcl` with BREXX built from that branch
  (#432, JOB01296). The REXX suite has not run on TK5. Deploy with
  `mbt deploy --target m38b`; `mbt run` takes the target from
  `MBT_TARGET=m38b`, it has no `--target` flag.
