# Changelog

All notable changes to BREXX/370 are listed here, newest first.

## 3.1.0 (2026-11-05)

Release 3.1.0 follows release 3.0.0 directly. A release 3.0.1 was planned and
never published; its fixes are listed here.

### Added

- ISPF variable access from an exec through the usermod ZMG0003 (an
  IKJCT441 with a REXX path). An exec can hand variables to ISPF (`VPUT`) and
  read them back (`VGET`), and `DISPLAY` a panel that shows or fills
  variables. ZMG0003 is a separate usermod, not part of the package
  `TBRX310`, and it may be installed beside ZMG0001. It requires PTF ZP60038
  and changes a module in the link pack area, so it is active only after an
  IPL with CLPA: on MVS/CE, answer `IEA101A` with `r 00,clpa`, otherwise the
  old `IKJCT441` stays in use. Without it, release 3.1.0 behaves under ISPF as
  release 3.0.0 does: `VPUT` ends with return code 8 (#625, #632).
- BREXX/370 publishes its environment block in the TSO field `ECTENVBK`
  (ECT + X'30') while an exec runs and restores the previous value when the
  exec ends, also after an abend. A program that an exec calls reaches a
  variable routine through it, with the calling convention of IBM's variable
  access routine `IRXEXCOM`: it fetches, sets and drops variables of the
  running exec, direct and symbolic, and walks all variables with `N`
  (#602).
- The environment blocks of running execs form a chain. A request for an exec
  that is not the newest one (a nested exec has ended, or an abend happened
  inside it) is routed to the exec it is meant for. A request while no exec
  runs returns -1 (#609).

### Changed

- Under TSO, an attention (PA1) during a running exec now ends the exec as
  `HALT`: `SIGNAL ON HALT` catches it, otherwise the exec ends with "Program
  interrupted". `ECTENVBK` is restored. An attention while the exec waits
  inside a host command (a TSO command, an ISPF `DISPLAY`) is not handled by
  BREXX/370; that command decides (#610).
- Three load modules have new names, because the prefix `IRX` belongs to the
  IBM interface for REXX: `IRXVTOC` is now `BRXVTOC`, `IRXVSMIO` is
  `BRXVSMIO` and `IRXVSMTR` is `BRXVSMTR`. There is no alias. A job or a
  command of your own that names an old module must name the new one. The
  external symbol `IRXSTAM` of the program `BREXX` is now `BRXSTAM` (#608).
- Release 3.1.0 is the SMP function `TBRX310`. It replaces release 3.0.0 in
  one step and no longer names the usermod `MS00100` as a prerequisite, so
  it installs on a system without that usermod, for example MVS/CE. The User's
  Guide describes three ways to put `BREXX.LINKLIB` into the link list; the
  usermod is one of them (#586).
- `scripts/smpinstall.py install --tgtvol` and `--dlbvol` accept the
  allocation job that `mbt package` generates, including a `COND` operand on
  the `EXEC` statement (#598). `smpinstall.py restore` cuts the accept job at
  its last `SMPCNTL`, so that `RESTORE` runs in the step that has the data-set
  statements it needs (#616).
- `ZMG0001.xmit` is the same file on every build from the same sources: the
  XMIT statistics carry a fixed date (#580).
- The build follows the 3.0 series of the build tool (`mbt`) instead of a
  release candidate (#584).
- The manuals are published on Read the Docs. `latest`, `stable` (release
  3.0.0) and `v3.0.0` show the three books (#576).

### Documentation

- User's Guide: the source of the usermod `MS00100` for MVS/CE, and the form
  `BREXX.LINKLIB(******)` for the link list (#578).
- User's Guide: the upgrade from release 3.0.0 describes both cases, 3.0.0
  accepted and 3.0.0 applied and not accepted, with the catalog that holds
  `BREXX.LINKLIB` after the last `DEFINE` (#597).
- User's Guide: what a batch step that runs BREXX/370 needs: an explicit
  `REGION` (8192K recommended), the symptoms of the default region on TK5
  and MVS/CE (`U0801`, `S106`, and a `S322` without output from the build
  V2R5M3 that ships with TK5 before Update 6), and a complete example job (#636).
- Library and Samples: how a line command is entered in an `FMTLIST` list
  such as the one of `JESQMENU`: type it into the line number field and
  blank the rest of the field with Erase EOF (#579).

### Fixed

- A number with digits after the decimal point is no longer slower to read
  than in BREXX/370 V2R5M3. Since 3.0.0 the interpreter formed the scale
  factor of such a number (`10**-n`) with the C library's `pow()`, which calls
  `log()` for a range check, and a loop that reads many numbers ran about
  20 % slower than in V2R5M3. The scale factor is now formed by repeated
  squaring, which gives the same bits `pow()` gave: no numeric literal
  changes its value. Numbers down to `1E-78` are still read as before (#611).
- An exec that runs out of memory under `PRIVILEGE('ON')` ends with error 60
  and return code 60, as it does without privilege. Release 3.0.0 ended the
  step with abend S40D and no return code, and the initiator was drained. A
  privileged allocation is now refused while less than 64 KB of the private
  area is free (#566).
- A literal from `1E75` up to about `7.2E75` is a number. Release 3.0.0
  refused it, so `pow(2,251.99) / 1E75` ended in error 41; it gives
  7.18701592828511 now, and `DATATYPE('1E75','N')` is 1. A literal above the
  limit of the long float is still not a number (#483).
- `COSH(x)` and `SINH(x)` give a result for |x| up to 175.36. Between 174.67
  and 175.36 release 3.0.0 ended in error 42, although the result is
  representable. Above 175.36 the result is error 42. The `//` operator
  returned a wrong remainder for a large quotient: a quotient of `1E15` or
  more is error 42 now, and between `1E13` and `1E15` the remainder has the
  right sign (`1E15 // 7` was -1). A division that was exact at a quotient of
  `1E15` or more, such as `1E20 // 10`, is error 42 as well (#460).
- `MNORMALISE` and `MPROPERTY` end with error 42 instead of abend S0CC when
  the mean, the variance or a squared sum of elements near the limit of the
  long float overflows (#472).
