# Open questions

Questions that need an answer from outside this repo (the maintainer, a
former developer, a caller) before the work can go on. The decisions
themselves are listed in [TODO.md](TODO.md) under "Open decisions"; this file
holds the background for the ones that are waiting on someone.

## Q1 (D1): in-memory exec entry, `0X…` address — decimal or hex?

**Where:** `src/brexx.c:149-157`, issue #129 (the last open item).

```c
if (Lbeg(&fileName, "0X") == 1) {
    char *pgm = (char *) (atoi((const char *)fileName.pstr + 2));
    int pgm_len = strlen(pgm);
```

If the exec name starts with `0X`, the rest is taken as the address of a
NUL-terminated REXX source in storage, and BREXX runs it from there.

**The problem:** the `0X` prefix says hex, `atoi` parses decimal. A hex
address such as `0X00A3B000` stops at the first `A` and yields 0 — BREXX then
runs `strlen()` on address 0.

**What is known:**

- Introduced by c2c3d8b "first implementation of in memory execs",
  2022-10-09. git shows Mike Großmann as author and committer, and the commit
  is on `master` as well, so this is not a result of the history rewrite on
  the migration branch. It may still have been written by Peter J. and
  committed by Mike — to be confirmed.
- No caller anywhere in the mvslovers workspace (`grep` for `0X` formats over
  all projects finds only this line). The caller is outside these repos.

**Questions for the developer:**

1. Who calls this entry, and is it still in use?
2. How does the caller format the address — decimal (`"0X%d"`, then the
   prefix is only a marker) or hex (`"0X%X"`)?

**What follows from each answer:**

| Answer | Change |
|---|---|
| Decimal | Keep decimal, but `strtoul(p, NULL, 10)` instead of `atoi`; comment that `0X` is a marker only |
| Hex | `strtoul(p, NULL, 16)` |
| Not used any more | Remove the entry (maintenance scope) |

In every case: reject an address of 0 instead of running `strlen()` on it.

** Answer **

`Not used any more`

