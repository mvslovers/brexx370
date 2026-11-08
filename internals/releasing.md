# Releasing BREXX/370

The ecosystem-wide rules (id format, burned ids, `DELETE`, the
element-ownership wall, `LIST`) and the brexx370 FMID row with its install
record are in `~/repos/mvs/.workspace/context/smp.md`; `.github/workflows/release.yml` (mbt's `release3.yml`) publishes a tag as a
release. This file holds the release rules that are particular to brexx370. Read it, and `smp.md`, before cutting a release.

## Release acceptance: the package the CI builds

Board decision of 2026-11-08, after mvsMF 1.4.1 and FTPD 1.3.4 were
published with guides that described a different install job than the one
in the package.

**The release is accepted on the package the CI builds, never on one built
locally.** `release.yml` runs mbt's reusable `release3.yml`, which installs
the newest mbt 3 release at the time of the run and packages with it. The
pin `[toolchain] mbt = "3.0"` is satisfied by any 3.0.x, so an older local
mbt does not switch and builds a package of its own. That is how it went
wrong twice: the candidates were packaged locally by an mbt whose install
job still ran the `ACCEPT`; the published packages (mbt 3.0.1,
mvslovers/mbt#328) have an install job that ends after the `APPLY` and a
separate accept job, `brexx370-<version>-accept.jcl` (job `BREXXACC`: `GUARD`,
`ACCEPT`, `CLEANUP`), and nobody had compared the guides with them.

- What is measured for the release (first install, upgrade, removal, the
  guides, the release page) is the artefact of the release run
  (`gh release download vX.Y.Z -R mvslovers/brexx370`, checksums against the
  assets) or a CI build of the same commit. A local `mbt package` is a
  development aid; its output is no evidence for a release, whichever mbt
  built it.
- The CI builds the package only in the release run today (`build3.yml`
  runs the build and the tests; mvslovers/mbt#369 asks for a package
  artifact). Until then the acceptance of the package happens after the
  tag, on the published assets, before the approved page text goes on the
  release page. Record on the release issue the mbt version from the log
  of the release run and the checksums of the files that were tested.
- Before anything is run, compare the package with the guides: the file
  list of the archive against the file tables of `README.md` and the Guide chapters `ug-install.typ` and `ug-migrate.typ`, and the steps of
  each job (the comment header of every `.jcl` lists them) against the step
  tables and the upgrade and removal instructions. A difference is a stop:
  the release goes back to the board, and the page is not published as it
  is.
- A text that describes a job it was not measured with says so and names
  the package it was measured with.
