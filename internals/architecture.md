# BREXX/370 architecture

How the interpreter is put together: the language pipeline, the core data
structures and the layer that talks to MVS. For the build, the toolchain and
the state of the migration see [cc370-migration.md](cc370-migration.md); for
open work see [TODO.md](../TODO.md).

BREXX/370 is the port of Vasilis N. Vlachoudis' BRexx (CERN) to MVS 3.8j,
maintained by Peter Jacob and Mike Großmann. Release 3.0.0 is for TK5 Update
6: fixes, SMP packaging and documentation, no new language functions (those
go to REKX/370).

## 1. Source tree

Counts are tracked files; lines are C, header and assembler source.

| Directory | Files | Lines | Contents | Built |
|-----------|------:|------:|----------|-------|
| `src/` | 38 | ~25,800 | interpreter core and MVS integration | yes |
| `lstring/` | 79 | ~6,000 | REXX string library, one function per file | yes |
| `inc/` | 38 | ~4,000 | headers | — |
| `asm/` | 26 | ~12,000 | S/370 assembler routines and standalone modules | yes |
| `rac/`, `dynit/`, `fss/`, `map/`, `regex/` | 21 | ~3,450 | RAKF checks, SVC 99, full-screen services, hash map/list, regular expressions (the SMF records in `smf/` were removed, #152) | yes |
| `cross/` | 3 | ~500 | JCC stubs for a host build | no (#150) |
| `maclib/` | 62 | ~5,000 | BREXX macros, minimal IF/ELSE/ENDIF/DO/ENDDO for as370, YREGS; the IBM macros come from maclib370 | — |
| `test/` | — | — | REXX test suite, run on MVS by `scripts/mvstest.py` (`mbt run mvstest`) | — |
| `scripts/` | — | — | the MVS test runner and its mvsMF client (`mvsmf.py`) | — |
| `test/tso/` | — | — | interactive tests on a 3270 (`mbt test --tso`), their execs | — |
| `mbt/` | — | — | `init.lua`: the `mbt run` commands for the MVS tools | — |
| `rxlib/`, `samples/` | — | — | REXX library execs and samples | — |
| `docs/` | — | — | user documentation: the manuals ML03-0001..0003 in `docs/books/` (Typst, bookmaster) | — |
| `internals/` | — | — | maintainer documentation: this file, the migration notes, the libc370 gap list | — |

What is compiled and linked is decided by `mbt.toml`, not by the
directory: BREXX is `src/*.c`, `lstring/*.c`, the support modules
and ten assembler routines (the JCC compatibility layer `compat/` is gone, #298); BRXVTOC, BRXVSMIO and BRXVSMTR
are standalone assembler modules.

## 2. Layers

```
┌──────────────────────────────────────────────────────────────┐
│                     REXX program (source)                    │
├──────────────────────────────────────────────────────────────┤
│  1. Language      nextsymb.c → compile.c / expr.c → bytecode │
├──────────────────────────────────────────────────────────────┤
│  2. Execution     interpre.c (VM loop), variable.c,          │
│                   bintree.c, builtin.c, rexxfunc.c,          │
│                   lstring/*, external.c                      │
├──────────────────────────────────────────────────────────────┤
│  3. MVS           rxexecio.c, rxtso.c, rxvsamio.c, rxnje.c,  │
│                   rxtcp.c, rxfiles.c, hostenv.c, address.c,  │
│                   dynit/, fss/, rac/                         │
├──────────────────────────────────────────────────────────────┤
│  4. System        asm/: rxsvc, rxestae, rxtsoa, rxvsam,      │
│                   rxcputim, …; src/tsoenv.c                  │
└──────────────────────────────────────────────────────────────┘
```

## 3. Interpreter pipeline

### 3.1 Scanner (`nextsymb.c`)

Turns source into symbols (`ident_sy`, `function_sy`, `literal_sy`,
operators, keywords — about 50 kinds). It is a stateful scanner with a global
state (`normal_st`, `in_do_st`, `in_if_st`, …) because several REXX keywords
are only keywords in context. Comments nest; line numbers are kept for error
messages and TRACE.

### 3.2 Compiler (`compile.c`, `expr.c`)

A recursive-descent parser that emits bytecode directly, without an AST.
Statements are parsed in `compile.c`; expressions in `expr.c` through the
precedence ladder `Exp0` (OR/XOR) to `Exp8` (literals, variables, function
calls). The code is appended to a growing `Lstr` buffer.

### 3.3 Virtual machine (`interpre.c`)

A stack machine with about 85 opcodes (`enum` in `inc/compile.h`): stack
(`OP_PUSH`, `OP_POP`, `OP_DUP`, `OP_COPY`), control (`OP_JMP`, `OP_JF`,
`OP_JT`, `OP_SIGNAL`), variables (`OP_LOAD`, `OP_CREATE`, `OP_DROP`,
`OP_ASSIGNSTEM`), arithmetic and logic, calls (`OP_CALL`, external calls) and
parsing (`OP_PARSE`, `OP_PVAR`, …).

`RxInterpret()` is a `while` loop over a `switch` on the current opcode;
`Rxcip` walks the bytecode. The operand stack is the global
`RxStck[STCK_SIZE]` (255 entries), with temporaries in `_tmpstr[]`.

## 4. Core data structures

### 4.1 `Lstr` — length-prefixed string (`inc/lstring.h`)

Every REXX value is an `Lstr`: data pointer, length, allocated size and a type
(`LSTRING_TY`, `LINTEGER_TY`, `LREAL_TY`). Numbers are converted lazily, only
when a string or number is actually needed, and `Lfx()` grows a buffer in
place instead of reallocating per operation. Access goes through `LSTR()`,
`LLEN()`, `LTYPE()`, `LMAXLEN()`.

### 4.2 `BinTree` — variable scopes (`inc/bintree.h`)

Variables and literals live in binary trees. A tree rebalances itself when it
grows past `balancedepth`; leaves can be threaded for iteration. Each
procedure level has its own scope tree.

### 4.3 `RxProc` — procedure frame

One per CALL / PROCEDURE level: instruction pointer, stack position, scope,
arguments, ADDRESS environment, NUMERIC DIGITS/FUZZ/FORM, SIGNAL conditions
and TRACE setting.

### 4.4 `HashMap` (`map/`)

Separate-chaining hash map, used next to the trees: NJE38 subtasks
(`rxnje.c`), variable pools (`variable.c`), RAKF profile cache (`rac/`).

### 4.5 `DQueue`

Double-ended queue behind the REXX data stack (PUSH, PULL, QUEUE) in
`stack.c`.

## 5. MVS integration

### 5.1 System calls

C calls MVS through a small set of assembler routines, each taking a C struct
as its parameter block:

```
src/*.c
  ├─ call_rxsvc()     → asm/rxsvc.asm     any SVC (RX_SVC_PARAMS: SVC, R0, R1, R15)
  ├─ call_rxtso()     → asm/rxtsoa.asm    TSO commands
  ├─ call_rxvsam()    → asm/rxvsam.asm    VSAM I/O
  └─ _setjmp_estae()  → asm/rxestae.asm   ESTAE recovery (RXSETJMP)
```

The TSO environment (foreground/background, prefix, user id, ISPF, a
running CLIST) is read in C by `tsoEnvInit()` in `src/tsoenv.c`; it was
the assembler module RXINIT until #357.

The `call_*` prototypes in `inc/rxmvsext.h` carry the MVS entry names as
`asm("...")` labels (#298).
The routines use the cc370/libc370 linkage.

### 5.2 Environment context (`inc/rxmvsext.h`)

`RX_ENVIRONMENT_CTX` holds the session state the assembler side and C share:
`SYSPREF`, `SYSUID`, `SYSENV`, `SYSISPF`, flag bytes, the literal and
variable trees, the procedure id, the CPPL when running under TSO and the
VSAM subtask table.

### 5.3 External functions (`external.c`)

An external function is a load module called with SVC 6 (LINK): the name is
cut or padded to 8 characters, an EFPL with the argument table (up to 32
arguments, an omitted one as length 0) and a 4096-byte EVALBLOCK for the
result is built, R0 is 0 (the callee finds the environment through ECTENVBK,
see 5.6), and
the result is taken from the EVALBLOCK. The same SVC 6 path serves ADDRESS
LINK, LINKMVS and LINKPGM (`addrlink.c`); LINK passes the TSO/E parameter
list, two words pointing to fullwords that hold the string's address and
its length.

### 5.4 Data sets

Data sets are opened through `src/dsio.c` on libc370: `rxOpenDsn()` for a
data set name (`'name'`), `rxOpenDd()` for a DD name (`DD:name`),
`rxWalkDir()` for a PDS directory (`__walkpd()`), `rxDsAttr()` for volume and
DSORG (catalog and format-1 DSCB). Each caller decides whether it has a DD
or a data set name; JCC's global `_style` is gone (#299). EXECIO (`rxexecio.c`) reads and writes sequential data sets and PDS members;
VSAM goes through `rxvsamio.c` and the BRXVSMIO/BRXVSMTR modules.

### 5.5 TSO

`ADDRESS TSO` commands and ISPEXEC. The CLIST variable pool
(`VALUE(…,'CLIST')` through IKJCT441) is gone (#366). GTTERM (SVC 94) supplies the terminal id and screen size for
`SYSVAR('SYSTERMID')`, `TERMINAL()` and FSS.

### 5.6 Variable routine and the ENVBLOCK words (`src/rxvarcom.c`)

While an exec runs under TSO, `RxXcPub()` (called from `RxRun`) makes
ECTENVBK (ECT+X'30') point to BREXX's ENVBLOCK, and `RxXcRst()` (end of the
run, and the shared cleanup in `brexx.c` after an abend) takes the block out
again. The ENVBLOCK leads to the IRXEXTE, whose `irxexcom` entry is the
variable routine (IRXEXCOM convention) on the variables of the running exec.
Without an LWA (batch) nothing is published.

The four reserved words at the end of the 320-byte ENVBLOCK belong to this
interface; BREXX uses X'130' and X'13C' (`XC_STKOFF` and `XC_PREVOFF` are the
only places that know the offsets), the IKJCT441 with the REXX path (the
current PTF ZP60038) owns X'134' and X'138'. `RxMvsInitialize()` zeroes the whole block, so all four start
as 0:

| Word | Meaning |
|---|---|
| X'130' (304) | The input stack element on top when the exec started (ECT -> ECTIOWA at +4 -> IOSRL, IOSTELM at +0). IKJCT441 uses it to tell that a REXX exec is meant. 0 means no exec runs; without an ECT it stays 0. |
| X'134' (308) | IKJCT441's anchor: the chain of chunks that hold the names and values of its last variable sequence (ISPF locate-all, TSVELOC). BREXX does not touch it. |
| X'138' (312) | IKJCT441's owner word: the TCB (PSATOLD) of the task that got the chunks at X'134'. BREXX does not touch it. |
| X'13C' (316) | The chain word: what ECTENVBK held before this exec published its block. 0 at the end of the chain. |

**The owner word.** The chunks at X'134' are subpool 1 of the task that
made them, so they go when that task ends, while the ENVBLOCK they hang from
lives as long as the copy of BREXX. Under ISPF the two can differ: a dialog
on another logical screen runs on its own task but finds this ENVBLOCK in
ECTENVBK. IKJCT441 writes X'138' when it gets a chunk (RXCPUT) and compares
it with PSATOLD before it touches the chain, both when it appends and when
it frees the last sequence (RXCFREE): its own chunks are reused or freed,
another task's are left alone and only the anchor is dropped, so they stay
until their task ends. The word is in the ENVBLOCK and not in the chunks
because a chunk of an ended task is gone, and reading it abends (S0C4-11,
measured with a test driver for that IKJCT441, step `TMPF`): the test must be
possible without touching the chunk. The ENVBLOCK is safe to read whenever
ECTENVBK points to it. A comparison with the ENVBLOCK of the time the chunks
were made is not needed: the anchor is in that ENVBLOCK, so the one reached
from ECTENVBK is always the one the chunks were made under. What stays open
in stage 1 is the reuse of a TCB address: a later task with the same address
as the ended owner passes the test. BREXX takes no part in any of this: it
keeps the two words zero until IKJCT441 uses them, and `RxMvsTerminate()`
frees the block with them. The chunks of this task, if any are still
anchored there, stay until the task ends; under ISPF that is the end of the
dialog (measured: twenty dialogs in a row, largest free block unchanged).

**The chain.** Several copies of BREXX can run under one ECT (two ISPF
screens, an exec started from an exec). `RxXcPub()` links the new block in
front: X'13C' = old ECTENVBK, ECTENVBK = own block. So ECTENVBK is the newest
block and X'13C' leads to the next older one. `RxXcRst()` unlinks the block
where it is: if ECTENVBK still holds it, the predecessor is put back; if
another block has been put on top meanwhile, the chain is walked from
ECTENVBK (256 blocks at most, each one checked for the eyecatcher `ENVBLOCK`
and the length 320) to the block whose X'13C' is ours, and that block's
X'13C' is patched to our predecessor. When no block points to ours, a
foreign value in ECTENVBK stays untouched. Afterwards X'130' and X'13C' of the
own block are 0, and `RxMvsTerminate()` overwrites the eyecatcher before it
frees the block. The unlink runs under `___try`, because it also runs in the
cleanup after an abend and must not abend itself on a damaged chain.
`RxXcRst()` is called before `RxMvsTerminate()` on both paths
(`src/brexx.c`).

**The dispatcher.** IKJCT441 reads ECTENVBK and calls the `irxexcom` entry
of that block, with R0 = the ENVBLOCK, R1 = the parameter list. With several
copies the newest one is called, but the request may be meant for an older
exec. So `BRXEXCOM` (`asm/rxexcom.asm`) decides before it enters C, because
@@CCALL takes the C environment of the task and C code of another copy must
never run on it:

1. R0 is our own ENVBLOCK (the external symbol of `env_block`) and its X'130'
   is the element on top of the input stack: ours, go to C (`RXXCOM`).
   Without an ECT there is no chain: the same.
2. Otherwise walk the chain from ECTENVBK (256 blocks, eyecatcher and length
   checked). The first block whose X'130' is the element on top and whose
   IRXEXTE has an `irxexcom` entry gets the request: a branch to that entry
   with R0 = that block and all other registers as the caller's. Its stub
   meets step 1.
3. No block: R15 = -1 (and -1 in the sixth parameter, if there is one). For
   IKJCT441 this is the CLIST path. 28 and 32 would have been RC 40 there.

`RXXCOM` returns the same -1 when it is entered without a running exec, and
checks parameter 5 (the ENVBLOCK) against the R0 the stub passes on.

### 5.7 Attention (`asm/rxstax.asm`, `src/rxattn.c`)

Under `__MVS__` libc370's `signal()` is a software table, so the
`SIGNAL(SIGINT, RxHaltTrap)` of `RxInitialize()` never fires on a TSO
attention (PA1). Without a STAX exit the TMP ends the command: BREXX's own
end does not run, `RxXcRst()` is never reached and ECTENVBK keeps pointing at
the ENVBLOCK of a copy that is gone (#610); the next CLIST dialog under ISPF
abends.

`RxRun()` calls `RxAttnOn()` right after `RxXcPub()`: a STAX with
`REPLACE=NO` (`RXSTAXON`). The exit (`ATTNEXIT`) is an IRB on the same TCB and
does one thing, `MVI RXSTAXFL,X'FF'`: no C runtime, no GETMAIN, no I/O. The
interpreter reads the flag at the clause boundary, in `OP_NEWCLAUSE` and
`OP_EXIT` (where `TrapPend` is checked), through `RxAttnPending()`, clears it
and calls `RxHaltTrap()` (`RxAttnRaise()`). So `SIGNAL ON HALT` catches it, a
`CALL ON HALT` runs at the next clause, and otherwise the exec ends with
`ERR_PROG_INTERRUPT` ("Program interrupted") through the normal end, where
`RxXcRst()` restores ECTENVBK.

The exit is cancelled (a bare STAX, `RXSTAXOF`, `RxAttnOff()`) before
`RxXcRst()` on both ends: at the end of `RxRun()` and in the shared cleanup of
`brexx.c` after an abend. `RxAttnOff()` can be called again harmlessly.
`REPLACE=NO` stacks the exits, so a BREXX started by another BREXX gets its own,
on top of the first, and the cancels run last in, first out. The flag and the
parameter list are in the CSECT; BREXX is linked NORENT. The host build
(`__CROSS__`) has no exit: `RxAttnPending()` is 0.

Every STAX return code is checked: a code other than 0 on the way in leaves
the exec running without the exit and prints `BRX0004W`, one on the way out
prints `BRX0005W`. STAX answered 0 in a batch TMP and in a TSO session (measured
on MVS/CE).

Not covered: an attention while the exec waits inside a host command (a TSO
command, an ISPF DISPLAY). The interpreter is not running then, so BREXX
does not handle the attention; what happens is up to the host command and
has not been measured. `test/tso/stax.lua` (`mbt test --tso --only STAX`) presses PA1 on a
looping exec in a real 3270 session and checks the three outcomes (handler,
HALT error, ECTENVBK restored through TSTXSENT SET/CHK).

## 6. Errors and recovery

REXX conditions (ERROR, HALT, NOVALUE, NOTREADY, SYNTAX) are implemented
with `setjmp`/`longjmp` (`_error_trap`, `_exit_trap`). `Lerror()` always
ends in a `longjmp`, so code after a call to it is not reached on the error
path. About 70 error codes are defined in `inc/lerror.h`.

ABENDs are caught by an ESTAE set up in `asm/rxestae.asm`, which passes the
SDWA back to C (`BRX0003E - ABEND CAUGHT IN BREXX/370`). The JCC STAE
variants `_setjmp_stae()` and `_setjmp_canc()` are gone (#157): `MTT()` and
`MTTX()` read a bounds-checked copy of the Master Trace Table (libc370
`cmtt_*()`), and the X'75' probe in `rxtcp.c` runs under libc370 `try()`.

## 7. Storage

`MALLOC` / `REALLOC` / `FREE` in `inc/bmem.h` never return NULL: a failed
allocation ends the exec with the REXX error `ERR_MALLOC_FAILED` (60) or
`ERR_REALLOC_FAILED` (61) (`malloc_or_die()`). With `__DEBUG__` each block carries a magic header and is tracked for
leak reports (`mem_first()`, `mem_last()`, `mem_count()`). Temporary strings
come from `_tmpstr[]` rather than the heap. BREXX is linked NORENT.

libc370's `malloc()` is one GETMAIN per block, with an 8 byte header,
rounded up to 64 bytes. A stem entry is four small blocks (variable, name,
value, tree leaf), so it took 256 bytes of the region and PRIMES 30000
ran out of an 8192K region (#504). `BmemInit()` (called from `main()`)
therefore sets up a pool for blocks up to 128 bytes: 8 KB chunks from
`malloc()`, size classes of 8 bytes, 8 byte header (`POOL_MAGIC`, class),
free lists per class; an entry takes about 150 bytes. The pool belongs to the
task that called `BmemInit()`; the NJE subtask and `PRIVILEGE('ON')` (key 0
maps subpool 0 to 252, #191) use `malloc()`. `BmemTerm()` returns the chunks.

`BmemInit()` also holds a 16 KB reserve. When an allocation fails,
`memoryExhausted()` leaves `PRIVILEGE('ON')` (`RxNoPriv()`), gives the reserve back and `RxMemoryError()` reports the error once and leaves
`RxRun()` through `_exit_trap` (with `SIGNAL ON SYNTAX` active, error 60 runs
the handler in the exhausted state instead; the next failure ends the exec);
a second failure while
reporting prints a plain message and leaves as well. The error path used to
allocate again, fail again and recurse until S0C4 (~1200 times).
`test/oomstem.rexx` exhausts the private area (`MVSTEST RC=60`, in a job of
its own: `MVSTEST OWNJOB`); `test/oompriv.rexx` does the same under
`PRIVILEGE('ON')`, where a block is a GETMAIN of its own in key 0 and nothing
stopped the exec before the last page of a `REGION=0K` job: the step ended
S40D and the initiator was drained (#566). `privAlloc()` in `bmem.c` refuses a
privileged block while less than 64 KB is free (a probe GETMAIN after every
32 KB taken), so the exec ends with error 60 as it does unprivileged (the 64 KB and
32 KB were measured on MVS/CE, not derived); `test/oompstr.rexx` does it with
one large block, a string that doubles (RC 61, as unprivileged);
`test/stem45k.rexx` checks that 45000 stem entries fit. The `REGION=` of an
EXEC statement in the test job does not limit the step: the JOB statement
has `REGION=0K`, which wins, so the limit is the private area of the address
space.

## 8. Build

Host build with mbt 3 and cc370 (`mbt build --all`, `mbt deploy`; mbt v2
until #420); see [cc370-migration.md](cc370-migration.md). The JCC build —
jcc.exe under Wine, then assembly and NCAL link on MVS — lives on in the
branch `v2.5-jcc` and no longer works with the current tree.
