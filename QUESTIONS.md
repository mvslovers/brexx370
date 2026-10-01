# Open questions

Questions that need an answer from outside this repo (the maintainer, a
former developer, a caller) before the work can go on. The decisions
themselves are listed in [TODO.md](TODO.md) under "Open decisions"; this file
holds the background for the ones that are waiting on someone.

## Q1 — Load-time macro rewrite (#284, D10)

**Who:** Peter Jacob (author). **Asked:** 2026-10-01, the maintainer talks
to him.

`RxFileLoad()` (`src/rexx.c:343-372`) rewrites an exec's source before it is
compiled: `:code xyz` → `CALL MACROGENERATE xyz`, `:exec xyz` and
`:call xyz` → `CALL xyz`, `x = ARGIN#(…)` → `CALL ARGIN(…)` plus
`interpret RESULT`. Added by Peter in `4250bb8` (2023-03-27, VLIST target
variable), `c99ebab` (2024-07-29, "MACROs in REXX") and `62523cf`
(2024-09-26). None of it is documented or tested, `MACROGENERATE` is not in
the repo, and no shipped exec uses it.

Questions:

1. What is it for, and is it in use (by Peter, by users)?
2. Where does `MACROGENERATE` come from?
3. Should it stay in BREXX/370 (then: document and test it), or go?

Until the answer, the code stays as it is; the `strstr` cleanup at
`src/rexx.c:272-360` (#133) waits for it.
