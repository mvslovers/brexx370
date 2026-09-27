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

- **All work goes to `claude/mbt-cc370-migration-5et9yt`, not `master`.**
  Feature branches (`fix/<issue>-<topic>`) are cut from it, and PRs target it.
  `master` still carries the JCC build.
- A PR into that branch does not auto-close its issue (`Fixes #n` only works
  on the default branch). Close the issue and tick its boxes by hand after
  the merge, and keep the tracking issue #134 current.
- **No `Claude-Session:` or `Co-Authored-By:` trailers and no AI identity**
  in commits, PRs or issues (root CLAUDE.md). The branch history was rewritten
  once to remove them. Commits carry the maintainer's identity.
- After every merge: update TODO.md (the root CLAUDE.md rule).

## CI

| Workflow | Runs on | What |
|---|---|---|
| `build.yml` | every PR, push to master | host build (mbt's reusable workflow, cc370 `main`) |
| `mvs-test.yml` | push to `claude/mbt-cc370-*`, `workflow_dispatch` | build, deploy into an MVS/CE container, smoke test + REXX suite |
| SonarCloud | every PR (org-wide GitHub App, Automatic Analysis) | quality gate |

- A PR branch gets no MVS/CE run by itself. Start one with
  `gh workflow run mvs-test.yml --ref <branch>`.
- `mvs-test.yml` is red as long as the six stream I/O tests fail
  (#140, libc370#189). **Read the step list, not the conclusion.** The expected
  state is "65/71 passed, 0 ABEND".
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

- `make CC="cc370 -Wall"` gives the warning list without changing the
  project. `CFLAGS=` on the command line would drop the project's include
  flags. The default build has no `-Wall` (TODO.md §0 step 5).
- In the cc370 build `JCC` is not defined and `BREXX_CC370` is (from
  `compat/jccompat.h`, which is force-included). `#ifdef JCC` code is dead
  unless it also names `BREXX_CC370`.
- BREXX is linked NORENT. Writable CSECT storage in its assembler routines is
  legal, but a write into a string literal changes every use of it.
- `char` is unsigned and the code is EBCDIC. Positive packed decimals are
  signed `F` (`D2P`).
