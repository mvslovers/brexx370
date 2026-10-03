# brexx370 — project context

Extends the root `CLAUDE.md` of the mvslovers workspace; nothing here
overrides it. Open work and decisions: [TODO.md](TODO.md); questions
waiting on someone outside the repo: [QUESTIONS.md](QUESTIONS.md). Build and
migration background: [docs/cc370-migration.md](docs/cc370-migration.md),
[docs/architecture.md](docs/architecture.md).

## Scope

BREXX/370 is in **maintenance mode**: the move to mbt v2 / cc370 + libc370,
one cleanup pass, and the TSO integration (`ZMG0001`). No new features. New
REXX function belongs in rexx370. SMP FMID prefix is `TBRX` (TODO.md §5).

## Branches and pull requests

- **Work goes to `master`**, which carries the cc370 build since the
  migration branch was merged (2026-09-29). Feature branches
  (`fix/<issue>-<topic>`) are cut from it, and PRs target it; `Fixes #n`
  closes the issue. Keep the tracking issue #134 current.
- The JCC build (2.5.3) lives on in the branch `v2.5-jcc`, for a fix to
  that line only.
- **No `Claude-Session:` or `Co-Authored-By:` trailers and no AI identity**
  in commits, PRs or issues (root CLAUDE.md). The branch history was rewritten
  once to remove them. Commits carry the maintainer's identity.
- After every merge: update TODO.md (the root CLAUDE.md rule).

## CI

| Workflow | Runs on | What |
|---|---|---|
| `build.yml` | every PR, push to master | host build (mbt's reusable workflow, cc370 `main`) |
| `mvs-test.yml` | push to `master`, `workflow_dispatch` | build against the `[toolchain] libc370` ref (now the release tag `v2.1.0`; cc370 is `main`, its compiler helpers come from `libcc370rt.a`), deploy into an MVS/CE container, smoke test + REXX suite (`mvstest.py` deploys the TESTLIB) |
| SonarCloud | every PR (org-wide GitHub App, Automatic Analysis) | quality gate |

- A PR branch gets no MVS/CE run by itself. Start one with
  `gh workflow run mvs-test.yml --ref <branch>`.
- `mvs-test.yml` is green since #140: the expected state is "129/129 passed"
  (2026-10-03, after #144). It builds against the libc370 release `v2.1.0`;
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
- `mvstest.py` judges a step by its RC only. A test that a failure could
  end early with RC 0 declares another RC (`MVSTEST RC=n` in the source,
  e.g. `callon.rexx`), so an early end reads as FAIL. `MVSTEST PARM=DSN`
  starts a step by its data set name (`PARM='<testlib>(member)'`, no
  RXRUN DD), as `RX 'DSN(MEMBER)'` does: `dsnmain.rexx`. `MVSTEST FULLDD`
  adds a DD FULLDD of one track without secondary space (`execfull.rexx`);
  `CREATE()` cannot make one, compat drops `pri`/`sec`.
- SonarCloud reads `.sonarcloud.properties` **from `master` only**. It sets a
  32-bit big-endian target (`powerpc`) and `__MVS__`. Without it, every
  pointer/`int` cast is reported as a 64-bit truncation.

## Testing on mvsdev

`.env` points at mvsdev (mvsMF on port 8080, IBMUSER). Anything that writes
to MVS (deploy, test jobs) needs the maintainer's OK per task; an approval
does not carry over to the next task.

- `make deploy` writes `IBMUSER.BREXX370.V3R0M0D.LINKLIB` and replaces it
  (DELETE + RECEIVE).
- `python3 scripts/mvstest.py [--only NAME ...]` runs the smoke test plus
  `test/*.rexx` as batch steps (`PGM=BREXX,PARM='RXRUN'`), spool in
  `build/mvstest.spool`. The test PDS is `IBMUSER.BREXX370.TESTS`.
  Its STEPLIB is the LINKLIB plus, behind it, the `…V3R0M0D.TESTLIB` of
  `make test-mvs`: `test/addrlink.rexx` LINKs the test module `TSTLINK`
  from there (#102). When the TESTLIB or a `[[test]]` module is missing,
  the script runs `make test-mvs` first; after changing a test module,
  run `make test-mvs` yourself (a present member is not replaced).
- `make test-mvs ARGS="--only NAME"` runs a C `[[test]]` as a batch step and
  as a TSO step (`CALL` under IKJEFT01), from `…V3R0M0D.TESTLIB`.
- **TSO in the background:** an IKJEFT01 step with STEPLIB = the dev LINKLIB
  and `SYSTSIN` `BREXX 'IBMUSER.BREXX370.TESTS(member)'`. There,
  `SYSVAR('SYSENV')` is `BACK` and `SYSTSO` is 1. A real 3270 has not been
  tested yet.
- Long program arguments: `PARM=('part1','part2')` continuation, 100
  characters in total.
- **Reproduce before fixing:** run the new test against the deployed old
  build, record the job number, deploy the fix and run it again. Then run
  the whole suite. Cite stand and job number for every result; never give a
  job range you did not see.

Facts about mvsdev that the measurements rely on (2026-09-27):

- `IBMUSER.BREXX370.V3R0M0D.LINKLIB` / `TESTLIB` are **not** in `IEAAPF00`,
  so BREXX and test modules run unauthorized. WTOs show the `+` prefix.
- RAKF is active, and the libc370 `tstracmx` fixture is installed
  (`LIBC370.TSTRACMX.ALLOW/DENY`, `LIBC370.RACTEST.*`, user MVSCE02).
  IBMUSER is ADMIN: `FACILITY SVC244` READ yes, UPDATE no, `BRXALLAUTH` no.
- SVC 130 answers from problem state without APF. `racf_auth()` and
  `smf_write()` abend S047 without APF and work after SVC 244
  (`privilege(1)`). SVC 83 needs APF but not supervisor state. Details and
  the probe source are in mvslovers/libc370#197 (JOB00486/JOB00488).
- TK5 has not been measured; `.env` has no second stand.

## Build notes

- The build runs with `-Wall -Wextra -Werror` (`[build] cflags`, #167):
  a new warning fails it. Mark an intentionally unused parameter
  `__unused` (e.g. `R_xxx(__unused int func)`) instead of dropping the
  flag. `CFLAGS=` on the command line would drop the project's include
  flags.
- In the cc370 build `JCC` is not defined and `BREXX_CC370` is (from
  `compat/jccompat.h`, which is force-included). The JCC conditionals are
  gone from the built sources (#133); only `printf/` (IRXEXCOM, #151) still
  tests `JCC`. The host build (`__CROSS__`) defines neither, so keep the
  `#else` side of an `#ifdef BREXX_CC370`.
- BREXX is linked NORENT. Writable CSECT storage in its assembler routines is
  legal, but a write into a string literal changes every use of it.
- `char` is unsigned and the code is EBCDIC. Positive packed decimals are
  signed `F` (`D2P`).
