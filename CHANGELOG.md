# Changelog

All notable changes to BREXX/370 are listed here, newest first.

## 3.1.0 (unreleased)

### Fixed

- A number with digits after the decimal point is no longer slower to read
  than in BREXX/370 V2R5M3. Since 3.0.0 the interpreter formed the scale
  factor of such a number (`10**-n`) with the C library's `pow()`, which calls
  `log()` for a range check, and a loop that reads many numbers ran about
  20 % slower than in V2R5M3. The scale factor is now formed by repeated
  squaring, which gives the same bits `pow()` gave: no numeric literal
  changes its value. Numbers down to `1E-78` are still read as before.
