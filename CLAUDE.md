# brexx370 — project context

Extends the root `CLAUDE.md` of the mvslovers workspace; nothing here
overrides it. Open work and decisions: [TODO.md](TODO.md); questions
waiting on someone outside the repo: [QUESTIONS.md](QUESTIONS.md). Build and
migration background: [internals/cc370-migration.md](internals/cc370-migration.md),
[internals/architecture.md](internals/architecture.md).

Documentation: the manuals are the books in `docs/books` (Typst, the
bookmaster submodule): ML03-0001 User's Guide, ML03-0002 Reference,
ML03-0003 Library and Samples (#396); Read the Docs builds its site from
them. A change to documented behaviour goes into the book in the same PR.
The old Sphinx manual is gone (`docs/source`, `docs/markdown`); its last
state is in the history before the removal.

## Scope

**BREXX/370 3.0.0 is for TK5 Update 6: fixes, packaging (SMP), documentation.
No new language functions**; new REXX function belongs in REKX/370 (rekx370).
The GitHub milestones are the plan:

- **3.0.0**: defects, the SMP installation (FMID `TBRX300`, umbrella #273),
  the manuals (ML03), the TSO integration (`ZMG0001`), tests for VSAMIO and
  IRXVTOC, the toolchain pin.
- **3.1.0**: cleanup (#134, #133, #316, #315), and what 3.0.0 defers
  (#264, #284, #447, #150).

The decisions for 3.0.0 are in TODO.md ("Decisions (maintainer)") and in the
issues they name (#273, #264, #448). SMP FMID prefix is `TBRX` (TODO.md §5).

## Read when relevant

| Before you … | read |
|---|---|
| debug a red `mvs-test.yml` run | [internals/testing.md](internals/testing.md) (CI history) |
| write or change a test in `test/*.rexx` (`MVSTEST` directives) | [internals/testing.md](internals/testing.md) |
| run tests on mvsdev or TK5 beyond the commands below, or rely on APF/RAKF/SVC behaviour | [internals/testing.md](internals/testing.md) |
| touch the TSO integration | `tso/README.md`, [internals/tso-integration.md](internals/tso-integration.md) |

## Branches and pull requests

- **Work goes to `master`**, which carries the cc370 build since the
  migration branch was merged (2026-09-29). Feature branches
  (`fix/<issue>-<topic>`) are cut from it, and PRs target it; `Fixes #n`
  closes the issue. Keep the tracking issue #134 current.
- The JCC build (2.5.3) lives on in the branch `v2.5-jcc`, for a fix to
  that line only; `legacy/` and its `test.yml` left `master` with the move
  to mbt 3 (#420).
- No `Claude-Session:` or `Co-Authored-By:` trailers. The branch history
  was rewritten once to remove them. Commits carry the maintainer's identity.

## TSO integration (`tso/`)

The usermod `ZMG0001` (BREXX in TSO `EXEC`) lives in `tso/`, built by
`tso/build.sh` with the as370 and macro libraries of `../mvs38src`, not
by mbt. `tso/README.md` has the build, test and install steps,
`internals/tso-integration.md` the design. ZMG0001 is installed on
mvsdev; `IBMUSER.ZMG0001.BACKUP` holds the EXEC/EX from before it. It
excludes rexx370's ZMG0002/ZMG0003. Anything that writes SYS1 needs the
maintainer's OK per task.

## CI

| Workflow | Runs on | What |
|---|---|---|
| `build.yml` | every PR, push to master | host build (mbt's reusable `build3.yml`, cc370 and libc370 `main`) and the manuals |
| `mvs-test.yml` | push to `master`, `workflow_dispatch` | build against the `[toolchain] libc370` ref (`mbt ci-info`, now the release tag `v2.8.1`, with maclib370 installed first; cc370 is `main`, its compiler helpers come from `libcc370rt.a`), `mbt deploy` into an MVS/CE container (target from `MBT_TARGET_*`), smoke test + REXX suite (`mbt run mvstest`, which deploys the TESTLIB) |
| SonarCloud | every PR (org-wide GitHub App, Automatic Analysis) | quality gate |
| `release.yml` | tag `v*` | mbt's reusable `release3.yml`: pinned toolchain, tag checked against `[project] version`, `mbt package`, `dist/*` as a GitHub Release (a tag with `-` is a prerelease). A second job attaches `ZMG0001.smp` (from the committed decks in `tso/usermod/`) and `ZMG0001-jobs.zip` after it (#364). The JCC release workflow lives on in the branch `v2.5-jcc` only |

- A PR branch gets no MVS/CE run by itself. Start one with
  `gh workflow run mvs-test.yml --ref <branch>`.
- The expected state of `mvs-test.yml` is "190/190 passed"; when it turns
  red, read the step list. Known infrastructure failures (spool read errors,
  the IPL wait) are in [internals/testing.md](internals/testing.md).
- `mvstest.py` judges a step by its RC only, so a test that a failure
  could end early with RC 0 declares another RC (`MVSTEST RC=n`).
- SonarCloud reads `.sonarcloud.properties` **from `master` only**. It sets a
  32-bit big-endian target (`powerpc`) and `__MVS__`. Without it, every
  pointer/`int` cast is reported as a 64-bit truncation. It also sets the
  Python version (3.12), declares `test/` and `scripts/mvstest.py`
  as tests, and excludes `progs/banner.r`: it is Latin-1 on purpose and
  must not be converted to UTF-8. The IBM system macros come from
  maclib370 in the sysroot (`sysmac/` went with #429); `maclib/` holds
  BREXX's own and YREGS, which maclib370 does not have.

## Testing on mvsdev

The mbt 3 target `dev1` (`~/.mbt/targets.toml`, the default) is mvsdev
(mvsMF on port 8080, IBMUSER). Anything that writes to MVS (deploy, test
jobs) needs the maintainer's OK per task; an approval does not carry over
to the next task. Build with `mbt build --all`.

- `mbt deploy` writes `BREXX370.DEV.LINKLIB` (no APF entry, on purpose:
  the suite measures BREXX running unauthorized).
- `mbt run mvstest [-- --only NAME ...]` runs the smoke test plus
  `test/*.rexx` as batch steps; it needs the TESTLIB of `mbt test --mvs`,
  so run that first, and again after changing a test module.
- `mbt test --mvs --only NAME` runs a test module as a batch step and
  as a TSO step.
- `mbt test --tso [--only NAME]` runs `test/tso/*.lua` in a real 3270
  session (needed for FSS).
- TK5 is the target `m38b`; `mbt run` takes it from `MBT_TARGET=m38b`, it
  has no `--target` flag.
- **Reproduce before fixing:** run the new test against the deployed old
  build, record the job number, deploy the fix and run it again. Then run
  the whole suite. Cite stand and job number for every result; never give a
  job range you did not see.

## Build notes

- The build runs with `-Wall -Wextra -Werror` (mbt 3 sets them, #167):
  a new warning fails it. Mark an intentionally unused parameter
  `__unused` (e.g. `R_xxx(__unused int func)`) instead of dropping the
  flag.
- The JCC compatibility layer `compat/` is gone (#298). cc370 defines
  `__MVS__`; the host build (`__CROSS__`) does not, so keep the `#else`
  side of an `#ifdef __MVS__`. `inc/mvsnames.h` is force-included into
  every translation unit: the 8-character renames (`lmvs.h`, `rxmvs.h`)
  and `__unused`. Everything else a file needs it includes itself. The
  JCC conditionals are gone (#133); the last ones went with the IRXEXCOM
  sources (`irx/`, `metal/`, `printf/`, #355).
- BREXX publishes no environment: it leaves ECTENVBK (ECT+X'30') alone and
  LINKs called programs with R0 = 0, and it has no IRXEXCOM (#353, #355).
  ECTENVBK belongs to rexx370 when both run side by side (`ZMG0003`).
- A built-in must not change `ARGn` in place: a literal or a variable
  reaches it as a pointer to the caller's string, and equal literals are
  shared across the exec (#305). Change `ARG_OWN(n)` instead
  (`Lupper(ARG_OWN(1))`): it copies the argument into its stack slot
  first.
- BREXX is linked NORENT. Writable CSECT storage in its assembler routines is
  legal, but a write into a string literal changes every use of it.
- `char` is unsigned and the code is EBCDIC. Positive packed decimals are
  signed `F` (`D2P`).
