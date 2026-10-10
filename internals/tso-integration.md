# TSO integration (usermod ZMG0001)

Design notes for `tso/`. The user's view is in `docs/books/guide/ug-install.typ`
("The TSO Integration: ZMG0001"), the build and test steps in `tso/README.md`, and the
measurements of the first install in #353.

## Decisions (maintainer, 2026-10-05)

- `ZMG0001` is BREXX/370 only, `ZMG0002` REXX/370 only (rexx370 `tso/`),
  and `ZMG0003` both side by side (rexx370). The three exclude each other.
- `ZMG0003` sends a member whose line 1 begins with `/* BREXX` to BREXX
  and everything else to REXX/370 by ZMG0002's rules.
- IKJ56479I is always shown under ZMG0001: there is no environment to
  check, and with ZMG0001 installed BREXX is there.
- The argument of an explicit EXEC loses its leading and trailing blanks,
  because BREXX trims the command buffer (#358). This is a known
  deviation from z/OS, accepted.
- ZMG0001 searches the user libraries too, in BREXX's order for `RX`:
  SYSUEXEC, SYSUPROC, SYSEXEC, SYSPROC (maintainer, 2026-10-06). TSO/E
  searches SYSUEXEC/SYSUPROC only after ALTLIB, which MVS 3.8 lacks.
- SYSEXEC before SYSPROC, also when the SYSPROC member is a CLIST:
  measured on z/OS (maintainer, 2026-10-07, batch IKJEFT01 with both
  DDs). The REXX `ORDA` in SYSEXEC beat the CLIST `ORDA` in SYSPROC, as
  `%ORDA` and as `ORDA`. The REXX `ORDB` in SYSEXEC beat the REXX `ORDB`
  in SYSPROC. After `EXECUTIL SEARCHDD(NO)` both came from SYSPROC, ORDB
  as REXX; `SEARCHDD(YES)` restored SYSEXEC. ZMG0001 follows the default
  and has no SEARCHDD. Kept although it changes a name that is in both
  libraries on an existing system: on MVS/CE, `SHUTDOWN` (the CLIST in
  SYS1.CMDPROC that starts an STC, the exec in SYS2.EXEC) now runs the
  exec in the user's session (#368). The installation guide says so; the
  rename is MVS/CE's (maintainer, 2026-10-07).
- ZMG0001 is installed on mvsdev.
- The release ships jobs (`tso/jcl`) and says how to remove the usermod.

## Shape

`IKJCT430` (EXEC) is rexx370's patch, unchanged. At its hooks it calls
`IKJCT437` with R0 → CPPL and R1 → RXPLIST:

| Offset | Field |
|---|---|
| +0 | CL8 member |
| +8 | CL8 DD (explicit: the DD DAIR allocated) |
| +16 | A(argument) |
| +20 | F length (0 = no argument) |

The argument is final, as z/OS gives it (rexx370#331).

BREXX's `IKJCT437` differs from rexx370's in two ways:

- **No environment.** rexx370 loads the exec through IRXLDTSO and
  decides by `instblk_ddname`. Here the module finds the member itself:
  - a TIOT scan first, because OPEN of a missing DD says IEC130I;
  - then BPAM OPEN and FIND in SYSEXEC, then SYSPROC;
  - then READ of the first block, with line 1 taken by RECFM (F: LRECL;
    V: after BDW and RDW; U: the whole block).
- **It runs BREXX, not IRXEXEC.**
  - BLDL `BREXX` first, since a LINK to a missing module abends S806 in
    EXEC.
  - Then LINK `BREXX` with a CPPL made of the caller's UPT, PSCB and ECT
    and a command buffer `BREXX <dd>(<member>) <argument>`, offset 6.
  - libc370's startup accepts it as a CPPL because the PSCB matches.
    BREXX opens `DD:<dd>(<member>)` first and takes its argument from
    the buffer unchanged (#358).

The EXEC load module is AC=0, RENT and REUS. IKJCT437 calls nothing
authorized and stores nothing into itself; the work area, DCB, DECB and
READ buffer are GETMAINed.

## Traps met or inherited

- **as370 exits 0 at severity 8.** `build.sh` therefore greps the
  listing for diagnostics.
- **IHBINNRA.** `FIND …,D` loads R1 from the DCB operand before R0 from
  the name, so neither register can carry an operand (KB MVS-BLDL-0001).
- **Concatenations.** A concatenation takes BLKSIZE from its first data
  set. A later library with larger blocks fails the READ into SYNAD, and
  the member counts as not REXX.
- **SYSTSIN.** Columns 73–80 of SYSTSIN are a sequence field. A test
  command longer than 72 columns is cut off silently.
- **BREXX output in a batch TMP.** In a batch TMP, BREXX's SAY goes to a
  SYSOUT of its own per run (libc370 `*SYSPRINT`), not to SYSTSPRT. So
  `lab/exec_test.py` gives every REXX case a tag as its argument and
  looks for the tag in the whole spool. TSO/E writes SAY to SYSTSPRT
  (TODO.md).
- **RESTORE and service.** RESTORE relinks from SYS1.AOST4, which holds
  no service that was applied but never accepted; the IEBCOPY backup of
  EXEC/EX is the level to copy back afterwards (job `ZMG01RS`).
- **RESTORE needs UY16532 accepted.** On mvsdev UY16532 was applied
  only, and `RESTORE SELECT(ZMG0001)` stopped with HMA3022 "UY16532 PRE"
  (JOB01519). After `ACCEPT SELECT(UY16532)` (JOB01522, AOST4 members
  backed up first, JOB01521) the RESTORE ran (JOB01525) and took ZMG0001
  off SMPPTS too (the REJECT after it found nothing, JOB01527). The
  reinstall that followed: RECEIVE JOB01528, APPLY JOB01530, verify
  byte-identical JOB01531, 29/29 installed JOB01532.
- **SYS1.CMDLIB extents.** The library is in the link list, so a new
  extent stays invisible until IPL (`IEA703I 106-F`). `zmg_install.py
  apply` compares the extents before and after.
