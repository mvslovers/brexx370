# TSO integration (usermod ZMG0001)

Design notes for `tso/`. The user's view is in `docs/source/installation.rst`
("TSO integration"), the build and test steps in `tso/README.md`, and the
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
- ZMG0001 is installed on mvsdev.

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
- **RESTORE and service.** UY16532 is applied but not accepted on
  mvsdev, so SYS1.AOST4 holds the IKJCT430 from before it. A RESTORE
  would relink that level; the IEBCOPY backup of EXEC/EX is the way
  back.
- **SYS1.CMDLIB extents.** The library is in the link list, so a new
  extent stays invisible until IPL (`IEA703I 106-F`). `zmg_install.py
  apply` compares the extents before and after.
