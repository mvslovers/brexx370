# Terminal and DD I/O: where SAY and PULL go

Analysis of 2026-10-07, for #251 and the TSO integration. Step 1 is
built (#251, `src/stdstrm.c`); "Before #251" below describes the state it
replaced. Sources are tagged: **[M]** measured (stand, job), **[S]** read
in source (file:line), **[R]** reported by the rexx370 project (its own
tags kept), **[I]** inferred, not measured.

## Before #251

BREXX reads and writes through three C streams, chosen in `inc/os.h`:

| What | Stream | Where |
|---|---|---|
| SAY | `Lprint(STDOUT)` | `src/interpre.c:1616` |
| PULL / PARSE PULL, empty stack | `Lread(STDIN)` | `src/interpre.c:1825`, `:1835` |
| LINEIN / LINEOUT without a name | `<STDIN>` / `<STDOUT>` | `src/rxfiles.c:87`, `:92` |
| TRACE output | `STDERR` | `src/trace.c:129`, `:256` |
| error messages, ADDRESS RC, abend report | `STDERR` | `src/error.c`, `src/address.c`, `src/brexx.c` |

libc370's startup opens `stdout` as `*SYSPRINT`, `stderr` as `*SYSTERM`,
`stdin` as `dd:SYSIN`, else `'NULLFILE'` [S libc370 `src/mvs/crt/@@start.c`].
A `*` name opens the DD if it is allocated, and otherwise `__fpstar()`
allocates one [S libc370 `src/stdio/fopen.c`, `src/stdio/@@fpstar.c`]:

- TSO foreground: a terminal DD (`TERM=TS`, RECFM V, LRECL 4000) [S
  `@@fpstar.c:36`]. Written with a QSAM PUT, read with TGET when the DCB
  is a terminal [S `@@fgetc.c:57-59`]; PUTLINE/GETLINE are not used. These
  are the two `SYS000nn` TERMFILE DDs seen during a run (TODO.md, #158).
- everywhere else: a SYSOUT data set of its own.

BREXX rebound `stdin` only (`bindStdin()` in `src/rxmvs.c`, removed by
#251): DD STDIN when allocated, `*STDIN` in the foreground. `stdout` and
`stderr` stayed where libc370 put them.

Consequences:

- **Batch (`PGM=BREXX`).** The `STDOUT`/`STDERR` DDs of `proclib/RXBATCH.jcl`
  and of `scripts/mvstest.py` are allocated and never opened. SAY and
  errors go to dynamically allocated SYSOUT data sets instead, and 2.5.3
  wrote into the JCL's DDs [M mvsdev JOB00986, the spool contents, in
  #251]. The suite run JOB01570 (mvsdev, 2026-10-07) shows the same
  allocations and `SYS00001`/`SYS00002` freed before the step ends [M,
  allocation messages only; mvsMF lists the data sets as `UNKnnnn`]. The
  `IEC130I SYSPRINT DD STATEMENT MISSING` lines in that job log are not
  BREXX's: they come from the steps that LINK IEBGENER without a SYSPRINT
  on purpose (`test/callon.rexx` and others); the repro job JOB01573 has
  none.
- **Batch TMP (IKJEFT01).** SAY goes to a SYSOUT of its own, not to
  SYSTSPRT (internals/tso-integration.md). TSO/E writes it to SYSTSPRT.
  `proclib/RXTSO.jcl` (2.5.3) allocates `STDOUT`/`STDERR`/`STDIN` beside
  `SYSTSPRT`/`SYSTSIN`; they are ignored the same way [I, from the batch
  case].
- **TSO foreground.** SAY and PULL work on a 3270 [M mvsdev, s3270, #158],
  through the TERMFILE DDs [S, above]. Since that is not PUTLINE, OUTTRAP
  presumably cannot see SAY [I, not measured]. (`bindStdin()`'s comment
  said the terminal is read with GETLINE; the source says TGET.)

## What TSO/E does, and rexx370

From rexx370 (2026-10-07). Manual tags are SC28-1883-0 pages; rexx370
implements output only so far.

| | TSO FG | batch TMP | no TSO (IRXJCL) |
|---|---|---|---|
| SAY | terminal [M p.59]. rexx370: PUTLINE DATA,SINGLE [R measured, s3270] | rexx370: the same PUTLINE, which the TMP routes to its own SYSTSPRT: one DCB, ordered with the TMP's messages [R MVSCE-LAB JOB01189] | QSAM on OUTDD, default SYSTSPRT [M p.59, p.287] |
| PULL, empty stack | terminal [M p.55, p.97] | "terminal", i.e. GETLINE on the TMP's SYSTSIN [I] | INDD, default SYSTSIN; no data gives a null string [M p.55, p.97] |
| PARSE EXTERNAL | terminal [M p.50] | GETLINE [I] | INDD [M p.50] |
| TRACE | terminal | as SAY [I] | OUTDD [M p.287, p.319] |
| error messages | PUTLINE (rexx370) | PUTLINE → SYSTSPRT | OUTDD, plus a WTO; PARMBLOCK `NOMSGWTO`/`NOMSGIO` [R z/OS, rexx370#281] |

- OUTDD is ignored when TSOFL is on [M p.319].
- **TPUT is no option for SAY:** SVC 93 returns without doing anything
  when ASCBTSB is 0, as in a batch TMP, and the output is lost [R MVSCE-LAB
  JOB01185].
- **PUTLINE needs no CPPL.** rexx370 takes UPT and ECT from PSA+X'224' →
  ASCB+X'6C' → ASXB+X'14' → LWA (UPT via PSCB, ECT at LWA+32), so it also
  works for `TSO CALL` and for `PGM=` under a TMP. With no TMP the call
  answers rc 16 and the environment is non-TSO [R `src/irx#tsio.c:85-121`,
  `asm/putlin.asm`].
- Line format: LL halfword (including the 4-byte header), X'0000', text;
  rexx370 sends at most 256 bytes per PUTLINE and splits longer lines. TSO/E
  wraps at the terminal width [M p.59], rexx370 does not yet.

## The constraint

**Under a TMP, BREXX must not open SYSTSPRT itself.** The TMP holds it open;
a second QSAM DCB on the same DD writes with its own buffer and no ordering
against the TMP's messages. Output under a TMP goes through PUTLINE, or it
stays where it is today. This applies to the DD order proposed in #251: its
step 2 (SYSTSPRT/SYSTSIN) is for the case without a TMP only.

libc370 has a PUTLINE/GETLINE path (`@@aopen.asm` mode 80/81, `IOFTERM`),
but no C caller selects it [S: `IOFTERM` is set nowhere in
`src/stdio/*.c`], and it takes ECT/UPT from the CPPL in the
invocation R1 of the first save area [S `@@aopen.asm` TERMOPEN]. That is
wrong for `TSO CALL` and for a PARM-style call under a batch TMP, the two
cases where BREXX has no CPPL. Using it needs a libc370 change.

## Steps

1. **Done (#251).** Measured on mvsdev with the job of five steps in the
   PR, before JOB01573 and after JOB01578: SAY in STDOUT and TRACE in
   STDERR with the 2.5.3 DDs, also under IKJEFT01; SAY, TRACE and PULL on
   SYSTSPRT/SYSTSIN without them; SYSTSPRT of a TMP untouched; no
   dynamic SYSOUT where a DD exists. The suite (JOB01579, 153/153) writes
   152 STDOUT and 152 STDERR with the JCL's FB 140. Needs libc370 2.4.0.
   The design as built: a `__premain()` that sets
   `stdout`/`stderr` before libc370 opens them, by a TIOT lookup (OPEN of a
   missing DD says IEC130I, internals/tso-integration.md):
   - `STDOUT`/`STDERR`/`STDIN` always, with or without a TMP: they are
     BREXX's own DDs and nobody else holds them open (2.5.3 JCL,
     `RXBATCH.jcl` and `RXTSO.jcl`);
   - then `SYSTSPRT`/`SYSTSIN` (IRXJCL JCL), **only without a TMP**;
   - then libc370's default.

   The TMP test is libc370's PPA: `@@crt0` issues the EXTRACT and sets
   `PPAPSCB`/`PPATSOBG` before `__start()` calls the hook [S `@@crt0.asm:149-160`],
   so `__premain()` can read it. No change in the interpreter. Effort:
   small. Decided: stderr shares the SYSTSPRT stream when there is no
   STDERR (closed once), the dynamic SYSOUT stays as the last resort, and
   `bindStdin()` folded into the hook.
2. **PUTLINE under a TMP.** SAY, TRACE and error messages through PUTLINE
   when a TMP is present, in `Lwrite`/`Lprint` for the standard streams
   only. A stub of BREXX's own after rexx370's `putlin.asm` (LWA lookup,
   256-byte pieces), or libc370's terminal path once it finds ECT/UPT
   without a CPPL; the second avoids a second copy of the same code and
   needs a libc370 issue first. Effects: SAY lands in SYSTSPRT in a batch
   TMP, and OUTTRAP may see SAY. The foreground TERMFILE DDs go away only
   if the hook also keeps libc370 from opening `stdout`/`stderr` on the
   terminal; diverting in `Lwrite` alone leaves them allocated.
   Effort: medium. This closes the TODO.md item "SAY in a batch TMP goes to
   a SYSOUT of its own".
3. **GETLINE for PULL under a TMP.** Not decidable without measurements.
   rexx370 has no GETLINE either (its WP-33b), so the results go back to
   rexx370.
4. TPUT/TGET (`src/rxtso.c`) are full-screen functions, not the SAY path.
   Unchanged.

## To measure on z/OS (TSO/E REXX)

Needed before step 3, useful for step 2. Batch IKJEFT01 each:

- an exec doing `PULL x; SAY '>'x'<'` followed by a TSO command in
  SYSTSIN: does PULL consume the command line, and is the command still
  run?
- the same with SYSTSIN at EOF after the exec: what does PULL return, and
  what is RC?
- `CALL OUTTRAP 'L.'; SAY 'hello'; CALL OUTTRAP 'OFF'; SAY L.0`: does
  OUTTRAP catch SAY (that is, is SAY PUTLINE DATA)?
- PARSE EXTERNAL in the same setting as the first case.
