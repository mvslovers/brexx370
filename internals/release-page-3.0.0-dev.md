**BREXX/370 3.0.0-dev is a preview of the next BREXX/370 release, for testing.** It is the same REXX interpreter as V2R5M3, rebuilt from the ground up. It is compiled with the cc370 toolchain and the libc370 C library (2.6.0) instead of JCC. It went through one review and cleanup pass, and it brings a TSO integration: with an optional usermod, TSO's `EXEC` command runs REXX. It is not yet a complete package. This page carries the load modules and the usermod; the REXX library (RXLIB), the samples and the JCL procedures still come from a V2R5M3 installation. It replaces the load modules of such an installation. Most execs run unchanged, but read the next section first: input and output under TSO now behave as in TSO/E REXX, and a few undocumented or broken features are gone.

## Read this first

- **Input and output under TSO follow TSO/E REXX.** When BREXX runs under the TSO terminal monitor program (`PGM=IKJEFT01` in batch, or a TSO session), it reads and writes through TSO itself:
  - `SAY`, `TRACE` output and error messages go into `SYSTSPRT` in batch, in order with the TSO messages, and to the terminal in the foreground.
  - `PULL` and `PARSE PULL` with an empty stack read the next line of `SYSTSIN` in batch. TSO then does not run that line as a command, and at the end of `SYSTSIN` they return a null string. In the foreground they read the terminal.
  - The `STDOUT`, `STDERR` and `STDIN` DDs are no longer used there. **Remove them from your RXTSO procedure**; the [procedure in the source tree](https://github.com/mvslovers/brexx370/blob/master/proclib/RXTSO.jcl) no longer has them. If a job fed `PULL` from a `STDIN` DD under IKJEFT01, put those lines into `SYSTSIN` after the command instead.
- **Batch without TSO (`PGM=BREXX`, RXBATCH) writes into your DDs again.** SAY goes to `STDOUT`, TRACE and messages to `STDERR`, and PULL reads `STDIN`, as with V2R5M3. Earlier 3.0.0-dev builds ignored those DDs and wrote into unnamed SYSOUT data sets. A step without `STDOUT` uses `SYSTSPRT` and `SYSTSIN` the way IRXJCL does, so IRXJCL-style JCL works too.
- **OUTTRAP traps what commands write, and only that.** The exec's own `SAY`, `TRACE` and error messages are not trapped; the output of another exec run as a command is, as in TSO/E. The stem is filled after each command. `max`, `CONCAT`/`NOCONCAT` and `skip` apply to the one `OUTTRAP` call that names them; before, a `NOCONCAT` stayed in effect for every later call, and a `max` given as a string (`'5'`) was ignored.
- **Write to the standard streams as `<STDOUT>` and `<STDERR>`.** `LINEOUT('STDOUT', ...)` names a DD called STDOUT. The standard output already holds that DD, so the open fails with error 57. The documented names `<STDOUT>`, `<STDERR>` and `<STDIN>`, or the handles 0 to 2, work.
- **Removed:**
  - `PUTSMF` and the SMF type 242 records;
  - `MVSDUMP`;
  - `OPEN(..., 'VIO')`;
  - the undocumented CLIST variable pool;
  - the IRXEXCOM interface (BREXX publishes no environment block any more).
- **Changed behaviour:**
  - `ADDRESS` to an environment that does not exist answers RC -3, as TSO/E does.
  - When BREXX looks an exec up in SYSUPROC or SYSPROC, a member counts as REXX only when line 1 is a comment containing `REXX`. Any other member is taken for a CLIST, and the search goes on.
  - Outside the TSO foreground a password-protected data set is refused. Before, OPEN asked the operator for the password.
  - `ADDRESS COMMAND 'CP ...'` obtains the authorisation it needs itself. Where RAKF denies it, the command answers RC -5 instead of abending S047.

## What was fixed

| | before (V2R5M3 or earlier 3.0.0-dev builds) | now |
|---|---|---|
| SAY in a batch TMP | the `STDOUT` DD (V2R5M3), or a SYSOUT data set of its own (earlier 3.0.0-dev) | `SYSTSPRT`, between the TSO messages |
| PULL in a batch TMP | the `STDIN` DD; `SYSTSIN` lines after the command ran as commands | the next `SYSTSIN` line, which TSO skips |
| SAY, TRACE with `PGM=BREXX` (earlier 3.0.0-dev) | unnamed SYSOUT, the JCL's DCB ignored | `STDOUT` / `STDERR`, with the JCL's DCB |
| SAY inside OUTTRAP | trapped together with the command output | shown; only command output is trapped |
| `DECRYPT(ENCRYPT(x))` | did not give `x` back | gives `x` back |
| `SOUNDEX` | wrong codes on EBCDIC letters | correct codes |
| Stream I/O | one position for reading and writing; an implicit open could truncate | separate read and write positions, an implicit open never truncates (REXX standard) |
| Loading, `LINES`, `LINEOUT`, `SAY` (earlier 3.0.0-dev builds, measured on MVS) | IMPORT of a large exec 6.0 s, LINES of 2000 lines 18.5 s, LINEOUT 11.5 s, SAY 11.3 s | 0.34 s, 0.37 s, 1.0 s, 1.2 s |
| A number of 1E75 or more in the source | abend (exponent overflow) while the exec was compiled | a string: `DATATYPE(x,'N')` is 0, arithmetic gives error 41 |
| `ARG(n)` with n above 99 | error 40 | `''`, as in TSO/E |
| Integer arithmetic beyond 32 bits | wrapped around | continues as a real number |

The cleanup pass also fixed uninitialised pointers, buffer overflows in the interpreter and its support modules (FSS, RAC, dynamic allocation, arrays, matrices, linked lists), and some 600 compiler warnings. The build now runs with `-Wall -Wextra -Werror`. Test cases were adopted from CMS-370-BREXX for PARSE, SIGNAL, CALL ON, conditions, NUMERIC and DATE, and the interpreter now follows them. The regression suite, 156 test steps in batch and under a batch TMP, runs on MVS for every change to the main branch.

## Known issues

- Arithmetic whose result leaves the S/370 floating-point range at run time still abends with S0CC ([#267](https://github.com/mvslovers/brexx370/issues/267)). Only numbers written in the source are handled.
- `SYSDSN()` answers only `OK` or `DATASET NOT FOUND`. The other TSO messages are never returned ([#169](https://github.com/mvslovers/brexx370/issues/169)).
- RXLIB, the samples and the JCL procedures are not part of this preview yet ([#272](https://github.com/mvslovers/brexx370/issues/272)). Take them from V2R5M3.

## Installing

**Load modules** (`brexx370-3.0.0-dev-load.xmit`)

1. Upload the file in binary to a sequential data set with RECFM FB and LRECL 80, for example `your.BREXX.XMIT`, as in steps 1 and 2 of the [installation guide](https://github.com/mvslovers/brexx370/blob/master/docs/markdown/installation.md#step-1---upload-xmit-file). That guide also covers the REGION and STEPLIB needed for RECEIVE on some systems.
2. In TSO, run `RECEIVE INDSN('your.BREXX.XMIT')`. At the prompt, answer `DSNAME('your.BREXX.V3R0M0D.LINKLIB')`.
3. The library holds `BREXX` with its aliases `REXX` and `RX`, plus `IRXVTOC`, `IRXVSMIO` and `IRXVSMTR`.
4. Try it with a `STEPLIB` first. Then copy all members, the aliases included, over the V2R5M3 modules in your link list library: IEBCOPY with replace, `INDD=((IN,R))`. Keep a copy of the old modules.
5. Use an APF-authorised library if your V2R5M3 installation used one (`$INSTAPF`).

RXLIB, the samples and the JCL procedures stay as V2R5M3 installed them. Remove `STDOUT`, `STDERR` and `STDIN` from your RXTSO procedure (see above).

**TSO integration (optional)** (`ZMG0001.smp`, `ZMG0001-jobs.zip`)

The usermod ZMG0001 makes TSO's `EXEC` command, and implicit invocation, run REXX through BREXX:
- `%name` and `name` search SYSUEXEC, SYSUPROC, SYSEXEC and SYSPROC.
- A member is REXX when it comes from an EXEC library, or when line 1 is a REXX comment.
- A CLIST stays a CLIST.

`ZMG0001-jobs.zip` contains the jobs to check the prerequisites (ZMG01CK), back up EXEC (ZMG01BK), receive and check (ZMG01RC), apply (ZMG01AP) and remove the usermod again (ZMG01RS). The [installation guide, "TSO integration: EXEC runs REXX"](https://github.com/mvslovers/brexx370/blob/master/docs/markdown/installation.md#tso-integration-exec-runs-rexx-usermod-zmg0001-optional), lists the prerequisites (PTF UY16532 applied, BREXX in the link list), the restrictions, and the one thing to check before you apply it: a member name that exists in both a SYSEXEC and a SYSPROC library now runs the exec.

## Full list of changes

The generated list of pull requests; a renewal regenerates it.
