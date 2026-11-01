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
and ten assembler routines (the JCC compatibility layer `compat/` is gone, #298); IRXVTOC, IRXVSMIO and IRXVSMTR
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
result is built, R0 is 0 (BREXX publishes no environment block, #353), and
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
VSAM goes through `rxvsamio.c` and the IRXVSMIO/IRXVSMTR modules.

### 5.5 TSO

`ADDRESS TSO` commands and ISPEXEC. The CLIST variable pool
(`VALUE(…,'CLIST')` through IKJCT441) is gone (#366). GTTERM (SVC 94) supplies the terminal id and screen size for
`SYSVAR('SYSTERMID')`, `TERMINAL()` and FSS.

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
free lists per class; an entry takes about 120 bytes. The pool belongs to the
task that called `BmemInit()`; the NJE subtask and `PRIVILEGE('ON')` (key 0
maps subpool 0 to 252, #191) use `malloc()`. `BmemTerm()` returns the chunks.

`BmemInit()` also holds a 16 KB reserve. When an allocation fails,
`memoryExhausted()` leaves `PRIVILEGE('ON')` (`RxNoPriv()`), gives the
reserve back and `RxMemoryError()` reports the error once and leaves
`RxRun()` through `_exit_trap` (with `SIGNAL ON SYNTAX` active, error 60 runs
the handler in the exhausted state instead; the next failure ends the exec);
a second failure while
reporting prints a plain message and leaves as well. The error path used to
allocate again, fail again and recurse until S0C4 (~1200 times).
`test/oomstem.rexx` exhausts the private area (`MVSTEST RC=60`, in a job of
its own: `MVSTEST OWNJOB`);
`test/stem45k.rexx` checks that 45000 stem entries fit. The `REGION=` of an
EXEC statement in the test job does not limit the step: the JOB statement
has `REGION=0K`, which wins, so the limit is the private area of the address
space.

## 8. Build

Host build with mbt 3 and cc370 (`mbt build --all`, `mbt deploy`; mbt v2
until #420); see [cc370-migration.md](cc370-migration.md). The JCC build —
jcc.exe under Wine, then assembly and NCAL link on MVS — lives on in the
branch `v2.5-jcc` and no longer works with the current tree.
