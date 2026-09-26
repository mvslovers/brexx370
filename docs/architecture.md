# BREXX/370 architecture

How the interpreter is put together: the language pipeline, the core data
structures and the layer that talks to MVS. For the build, the toolchain and
the state of the migration see [cc370-migration.md](cc370-migration.md); for
open work see [TODO.md](../TODO.md).

BREXX/370 is the port of Vasilis N. Vlachoudis' BRexx (CERN) to MVS 3.8j,
maintained by Peter Jacob and Mike Großmann. It is in maintenance mode: the
move to mbt v2 / cc370 + libc370, one cleanup pass and the TSO integration,
no new features.

## 1. Source tree

Counts are tracked files; lines are C, header and assembler source.

| Directory | Files | Lines | Contents | Built |
|-----------|------:|------:|----------|-------|
| `src/` | 38 | ~25,800 | interpreter core and MVS integration | yes |
| `lstring/` | 79 | ~6,000 | REXX string library, one function per file | yes |
| `inc/` | 38 | ~4,000 | headers | — |
| `asm/` | 28 | ~12,100 | S/370 assembler routines and standalone modules | all but `svc.asm` |
| `compat/` | 3 | ~870 | JCC runtime API mapped onto libc370, 64-bit helpers | yes |
| `rac/`, `dynit/`, `fss/`, `map/`, `smf/`, `regex/` | 23 | ~3,700 | RAKF checks, SVC 99, full-screen services, hash map/list, SMF records, regular expressions | yes |
| `irx/` | 3 | ~790 | IRXEXCOM and friends | no (TODO.md §4) |
| `metal/`, `printf/`, `cross/` | 8 | ~1,900 | Metal-C page allocator, Marco Paland's printf, JCC stubs for a host build | no |
| `maclib/` | 66 | ~5,000 | BREXX macros, minimal IF/ELSE/ENDIF/DO/ENDDO for as370 | — |
| `sysmac/` | 33 | ~6,800 | IBM SYS1.MACLIB/AMODGEN members libc370 does not ship | — |
| `test/` | — | — | REXX test suite, run on MVS by `scripts/mvstest.py` | — |
| `rxlib/`, `samples/` | — | — | REXX library execs and samples | — |
| `doc/` | — | — | user documentation (Markdown, Sphinx) | — |
| `legacy/` | — | — | the JCC build, reference only | — |

What is compiled and linked is decided by `project.toml`, not by the
directory: BREXX is `src/*.c`, `lstring/*.c`, the support modules, `compat/`
and ten assembler routines; IRXVTOC, IRXVSMIO, IRXVSMTR, IRXISTAT and MVSDUMP
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
│                   dynit/, fss/, rac/, smf/                   │
├──────────────────────────────────────────────────────────────┤
│  4. System        asm/: rxsvc, rxestae, rxinit, rxterm,      │
│                   rxtsoa, rxvsam, rxikj441, rxcputim, …      │
│                   compat/: JCC API → libc370                 │
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
  ├─ call_rxikj441()  → asm/rxikj441.asm  CLIST variable pool (IKJCT441)
  ├─ call_rxinit/term → asm/rxinit.asm, rxterm.asm   environment block
  └─ _setjmp_estae()  → asm/rxestae.asm   ESTAE recovery (RXSETJMP)
```

The `call_*` names are mapped to the 8-character external names in
`compat/jccompat.h`, which is force-included into every translation unit.
The routines use the cc370/libc370 linkage.

### 5.2 Environment context (`inc/rxmvsext.h`)

`RX_ENVIRONMENT_CTX` holds the session state the assembler side and C share:
`SYSPREF`, `SYSUID`, `SYSENV`, `SYSISPF`, flag bytes, the literal and
variable trees, the procedure id, the CPPL when running under TSO and the
VSAM subtask table.

### 5.3 External functions (`external.c`)

An external function is a load module called with SVC 6 (LINK): the name is
padded to 8 characters, an EFPL with the argument table and an EVALBLOCK for
the result is built, R0 points to the environment block, and the result is
taken from the EVALBLOCK. The same SVC 6 path serves ADDRESS LINK, LINKMVS
and LINKPGM (`addrlink.c`).

### 5.4 Data sets

A plain file name is resolved as JCC did it, according to `_style`: a DD
name by default (`//DDN:`), a data set name with `//DSN:`. `compat/`
translates both into libc370's `DD:name` or data set name. EXECIO (`rxexecio.c`) reads and writes sequential data sets and PDS members;
VSAM goes through `rxvsamio.c` and the IRXVSMIO/IRXVSMTR modules.

### 5.5 TSO

`ADDRESS TSO` commands, ISPEXEC, and the CLIST variable pool through
IKJCT441. GTTERM (SVC 94) supplies the terminal id and screen size for
`SYSVAR('SYSTERMID')`, `TERMINAL()` and FSS.

## 6. Errors and recovery

REXX conditions (ERROR, HALT, NOVALUE, NOTREADY, SYNTAX) are implemented
with `setjmp`/`longjmp` (`_error_trap`, `_exit_trap`). `Lerror()` always
ends in a `longjmp`, so code after a call to it is not reached on the error
path. About 70 error codes are defined in `inc/lerror.h`.

ABENDs are caught by an ESTAE set up in `asm/rxestae.asm`, which passes the
SDWA back to C (`BRX0003E - ABEND CAUGHT IN BREXX/370`). The JCC STAE
variants `_setjmp_stae()` and `_setjmp_canc()` are stubs in the cc370 build
(TODO.md §2).

## 7. Storage

`MALLOC` / `REALLOC` / `FREE` in `inc/bmem.h` never return NULL: a failed
allocation raises the REXX error `ERR_MALLOC_FAILED` (`malloc_or_die()`). With `__DEBUG__` each block carries a magic header and is tracked for
leak reports (`mem_first()`, `mem_last()`, `mem_count()`). Temporary strings
come from `_tmpstr[]` rather than the heap. BREXX is linked NORENT.

## 8. Build

Host build with mbt v2 and cc370 (`make`, `make deploy`); see
[cc370-migration.md](cc370-migration.md). The JCC build under `legacy/` —
jcc.exe under Wine, then assembly and NCAL link on MVS — is kept for
reference and no longer works with the current tree.
