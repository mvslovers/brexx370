**BREXX/370 3.0.0 is the release that comes with TK5 Update 6.** It is the BREXX/370 REXX interpreter of V2R5M3, rebuilt with the cc370 compiler and the libc370 C library instead of JCC, and cleaned up. It is installed with SMP as the function `TBRX300`, which deletes nothing: release 3.0 sits beside V2R5M3 and does not replace it. It has new manuals, and an optional usermod lets TSO's `EXEC` command run REXX. There are no new language functions; this release is fixes, packaging and documentation. Most execs written for V2R5M3 run unchanged. Read the next section first: where you install it matters, input and output under TSO changed, three RXLIB routines and eight samples have new names, and the functions that need privileges now ask RAKF.

## Read this first

- **Installing.** TK5 Update 6 comes with BREXX/370 3.0.0 installed. On another system, install the SMP function `TBRX300`. The job that allocates the libraries has the parameters `TGTVOL` and `DLBVOL`; the defaults are the MVS/CE volumes `MVSRES` and `SMP000`. On TK5 set `TGTVOL=TK5RES` and `DLBVOL=TK5DLB`. The job allocates three target libraries, `BREXX.LINKLIB`, `BREXX.RXLIB` and `BREXX.SAMPLIB`, and the three distribution libraries behind them, `BREXX.ARXLINK`, `BREXX.ARXLIB` and `BREXX.ARXSAMP`. The load library `BREXX.LINKLIB` is not APF-authorized, and BREXX/370 runs unauthorized. Check the result by listing the target libraries (`BREXX`, `REXX` and `RX` must be in `BREXX.LINKLIB`) and `LIST SYSMOD(TBRX300)`, not by return codes: SMP can end every step with condition code 0 and still leave the libraries empty. Then log on again and run `PARSE VERSION v; SAY v`; it must show `BREXX/370 V3R0M0` and the build date of this release. The data set names carry no version.
- **Going over from V2R5M3 on your own.** Release 3.0 is installed beside V2R5M3 and does not replace it. The first library in the link list that holds a module name wins, and V2R5M3 left copies of `BREXX`, `REXX`, `RX`, `IRXVTOC`, `IRXVSMIO` and `IRXVSMTR` in `SYS2.LINKLIB`; without a change a session still runs V2R5M3. Enter `BREXX.LINKLIB` in `SYS1.PARMLIB(LNKLST00)` before `SYS2.LINKLIB`, **with its volume serial**: `BREXX.LINKLIB(TK5RES)` on TK5, `BREXX.LINKLIB(MVSRES)` on MVS/CE (the volume you gave as `TGTVOL`). The alias `BREXX` is in a user catalog; without the volume serial the system answers `IEA327I` and does not load the library. The volume must be online at IPL, or the IPL stops with `IEA317A`. An IPL follows. Then remove the old modules from `SYS2.LINKLIB`, so that no second copy is left. To try release 3.0 first, use a `STEPLIB`. Replace the procedures `RXTSO` and `RXBATCH` in `SYS2.PROCLIB` by those of `BREXX.PROCLIB`, which already have `LIB='BREXX.RXLIB'`; a copy that stays keeps the old default. Change the data set name of the RXLIB allocation in your logon procedure and in your own JCL to `BREXX.RXLIB`. The User's Guide, appendix "Migrating from V2R5M3", has the complete steps.
- **Renamed members.** RXLIB and SAMPLIB are installed with SMP, and SMP must not replace IBM elements of the same name. Three RXLIB routines therefore have a new name, without an alias: `LISTCAT` is now `LISTCATX`, `LISTALC` is `LISTALCX` and `PRINT` is `PRINTX`. An exec of your own that calls `LISTCAT()`, `LISTALC()` or `CALL PRINT` must be changed. It does not end with a clean error: the old names are also names of IBM load modules, which BREXX/370 finds and calls as a last resort, and they abend with S0C4. BREXX/370 catches the abend and ends the exec with message `BRX0003E`; `SIGNAL ON SYNTAX` does not trap it. The TSO commands of the same names are not affected. Eight samples are installed under a new name: `LOCATE` as `LOCDSN`, `LISTALC` as `LISTALCS`, `CONSOLE` as `CONSOLET`, `CODE` as `CODEFILE`, `JES2` as `JES2SPL`, `$WAIT` as `WAITDEMO`, `$WTO` as `WTODEMO` and `JESQUEUE` as `JESQMENU`. The member `BUILD` is not installed. **On TK5, the logon exec `SYS2.EXEC($CONCAT)` calls `ListAlc("NOPRINT")`**; change it to `ListAlcX` at the same time as the RXLIB name, or a session starts without the user data sets in `SYSEXEC`, `ISPPLIB` and the other concatenations.
- **Privileged functions need a RAKF profile.** `PRIVILEGE`, `CONSOLE`, `MTT`, `MTTX` and `ADDRESS CONSOLE` exist only for a user with READ access to the FACILITY profile `SVC244`; `ADDRESS COMMAND` only for a user with READ access to `DIAG8CMD`. A call of `PRIVILEGE` without the profile is error 43, and `ADDRESS COMMAND` answers return code -3. V2R5M3 let every user call them. TK5 defines both profiles; refresh the profiles with `S RAKFPROF` after you change them. The profile must be defined: BREXX/370 takes a profile that RAKF does not know as no access. A system without RAKF needs no profiles.
- **Input and output under TSO follow TSO/E REXX.** When BREXX runs under the TSO terminal monitor program (`PGM=IKJEFT01` in batch, or a TSO session), `SAY`, `TRACE` output and error messages go into `SYSTSPRT` in batch and to the terminal in a session. `PULL` with an empty stack reads the next line of `SYSTSIN` in batch. The `STDOUT`, `STDERR` and `STDIN` DDs are no longer used there. **Remove them from your `RXTSO` procedure**; if a job fed `PULL` from a `STDIN` DD under `IKJEFT01`, put those lines into `SYSTSIN` after the command instead. A step with `PGM=BREXX` (the procedure `RXBATCH`) writes to its DDs as before.
- **Write to the standard streams as `<STDOUT>` and `<STDERR>`.** `LINEOUT('STDOUT', ...)` names a DD called STDOUT. The standard output already holds that DD, so the open fails with error 57. The documented names `<STDOUT>`, `<STDERR>` and `<STDIN>`, or the handles 0 to 2, work.
- **`OUTTRAP` traps what commands write, and only that.** The exec's own `SAY`, `TRACE` and error messages are not trapped; the output of another exec run as a command is.
- **Removed:** `PUTSMF` and the SMF type 242 records, `OPEN(..., 'VIO')`, the undocumented CLIST variable pool, `IRXEXCOM` (BREXX/370 publishes no environment block any more), and the routines `IRXISTAT` and `MVSDUMP`, which no exec could call. The RXLIB member `NJE38DIR` is not supported: it needed `IRXEXCOM`.
- **Changed behaviour an exec can notice:** a comparison ignores trailing blanks; `FORMAT`, `C2D`, `X2D`, `ROUND`, `QUOTE`, `DATE('GERMAN')`; `SELECT` without a true `WHEN` and without `OTHERWISE` is error 7; `ADDRESS` to an environment that does not exist answers return code -3; `SYSDSN` returns the messages of TSO/E; a member found in `SYSUPROC` or `SYSPROC` counts as REXX only when line 1 is a comment containing `REXX`; outside a TSO session a password-protected data set is refused instead of asking the operator; an exec that runs out of memory ends with RC 60 or 61. The Reference, chapter "Changes in Release 3.0", lists every change with the result under V2R5M3 and under 3.0.
- **BREXX/370 no longer runs authorized.** The load module is linked with authorization code 0, so it is unauthorized even in an APF-authorized library; `$INSTAPF` and the changes to `IKJEFTE2` and `IKJEFTE8` are not needed and no longer have an effect. The functions that need authorization (the NJE38 functions, `CONSOLE` and `ADDRESS CONSOLE`, `CP` commands, `SYSVAR('SYSCP')`, `SYSVAR('SYSCPLVL')`, `SYSVAR('SYSNODE')`) take it from SVC 244 for the length of one call, which needs READ access to the RAKF profile `SVC244` in the class `FACILITY` (`CP` commands also need `DIAG8CMD`); without it each ends with a return code or an error and nothing abends. `PRIVILEGE('ON')` gives an exec the same authorization for as long as it wants it. A job step that is authorized already is left as it is, and `SYSVAR('SYSAUTH')` shows 1. A program that checks for authorization itself, such as IEBCOPY, fails as it does under any unauthorized program.
- **The manuals** ML03-0001 User's Guide, ML03-0002 Reference and ML03-0003 Library and Samples are the First Edition with this release. They are attached as PDF files and are on [Read the Docs](https://mvslovers.readthedocs.io/projects/brexx370/).

## What was fixed

| | before (V2R5M3 or earlier 3.0.0-dev builds) | now |
|---|---|---|
| SAY in a batch TMP | the `STDOUT` DD | `SYSTSPRT`, between the TSO messages |
| PULL in a batch TMP | the `STDIN` DD; `SYSTSIN` lines after the command ran as commands | the next `SYSTSIN` line, which TSO skips |
| SAY inside OUTTRAP | trapped together with the command output | shown; only command output is trapped |
| Comparison `'abc  ' = 'abc'` | 0 | 1 |
| `DECRYPT(ENCRYPT(x))` | did not give `x` back | gives `x` back |
| `SOUNDEX` | wrong codes on EBCDIC letters | correct codes |
| Stream I/O | one position for reading and writing; an implicit open could truncate | separate read and write positions, an implicit open never truncates (REXX standard) |
| A number beyond the float range written in the source, for example `1e76` or `030E80` | abend S0CC while the exec was compiled | a string: `DATATYPE(x,'N')` is 0, arithmetic gives error 41 |
| A result beyond about 7.2E+75 of `+ - * / % // **`, `POW(2,252)`, and the matrix functions `MSCALAR`, `MMULTIPLY`, `MINVERT`, `MADD`, `MSUBTRACT`, `MPROD`, `MSQR` | abend S0CC | error 42, which `SIGNAL ON SYNTAX` catches |
| Comparison of numbers above 7.2E+73 | abend S0CC | a result |
| Integer arithmetic beyond 32 bits | wrapped around | continues as a real number |
| `MAX()` / `MIN()` of whole numbers beyond 32 bits (`max(3E10,2E10)`) | error 26 | the number |
| `ARG(n)` with n above 99 | error 40 | `''`, as in TSO/E |
| A string array index out of range | abend S0C4 | error 40 |
| `ADDRESS` to an environment that does not exist | RC -42 and "please report this" | RC -3, as TSO/E |
| `ADDRESS COMMAND 'CP ...'` where RAKF denies it | abend S047 | RC -5 |
| `CREATE()` of a sequential data set | the first track kept what an earlier data set left there: `LISTDSI` counted records nobody wrote, and a RECFM=V reader could abend U1234 | the end-of-file mark is written |
| VSAMIO `DELETE KEY k2` after `READ KEY k1 UPDATE` | erased k1, reported RC 0 | erases k2 |
| VSAMIO `DELETE KEY` on a missing key | erased the next higher record, RC 0 | RC 8 |
| VSAMIO `CLOSE ALL`, a failed `OPEN`, a record longer than the maximum | `CLOSE ALL` was run as `CLOSE`; a failed `OPEN` left the subtask attached and the exec ended with abend A03; the long record overwrote storage | each handled |
| NJE38 functions in an unauthorized BREXX (the `IKJEFTE2`/`IKJEFTE8` change or an APF library was needed) | the functions ended in S102, S047 or SA03; an exec that ended without `__NJEDEREGISTER` ended in system abend A03 | authorization from SVC 244 for the length of a call; without READ on `SVC244`, `__NJEREGISTER` and `__NJESEND` return -5 with message `BRX0010E`, the user is not registered, so `__NJERECEIVE` ends with error 68 (`#ERROR` with `_RC` -5 only if the access is lost after the registration); no abend; an exec that ends without `__NJEDEREGISTER` ends the subtask and gives the authorization back |
| `SYSVAR('SYSNODE')` of a user registered by `__NJERECEIVE` | `-INACTIVE-` | the node of the registration |
| `__NJEREGISTER` with any user ID | registered it, so an exec could receive another user's NJE38 messages | only the logged-on user; any other ID is error 71 |
| `__NJEREGISTER` / `__NJEDEREGISTER` with a user ID of more than 8 characters | wrote past the end of two 9-byte buffers | error 40 |
| `__NJEDEREGISTER` without a prior `__NJERECEIVE`; a lowercase user ID | abend S102; error 28 | RC 0; the ID is upper-cased |
| `__NJERECEIVE` when the subtask cannot be attached | waited for the whole timeout and returned `#TIMEOUT`; error 68 showed the timeout as the user | returns `#ERROR` with `_RC` -1; error 68 names the user |
| `MVSVAR('REXX')` and `MVSVAR('REXXDSN')` when the exec is read through a DD (the procedures `RXTSO` and `RXBATCH`) | empty; samples that build a data set name from it, for example `STUDENTI`, failed | the member and the data set of the exec |
| The RXLIB routines that build FSS screens and some samples (`FMTMONAR`, `FSSCREEN`, `KEYVALUE`, `LSTNCAT`, `MTTLOG`, the `STARG*` family, `JES2SPL`, `MTT` and others) | a comma at the end of a line joined two arguments into one, and every later argument moved up | the call sites are fixed; the arguments arrive as written |
| `RX JESQMENU` on an 80-column screen | stopped with an FSS definition error | the menu fits |
| `RX JES2SPL`, line command `P` (purge) | ended the screen with `Field 'ZFOOTER' not defined`; purged output of class H only, which MVS/CE does not hold | purges held output of any class; no FSS error |
| `PRIVILEGE('ON')` followed by `SYSVAR('SYSNODE')`, `LISTVOLS`, `ADDRESS COMMAND 'CP ...'` or `SYSVAR('SYSCP')` | the exec lost the privilege (a later access to key 0 storage abended S0C4) | the privilege stays in effect |
| The samples `STUDENTI`, `STUDENTK`, `STUDENTN` in a batch step without TSO (`RXBATCH`) | the allocation of the cluster failed silently | they allocate with `ALLOCATE()`; a failed allocation ends the exec with RC 8 |
| `RX JESQUEUE`, line command `S` (a fault of the earlier 3.0.0-dev builds; V2R5M3 worked) | the spool list showed no rows; `S` showed nothing | the list shows its rows; `S` shows the output or says why there is none |
| Memory of a stem: `PRIMES 30000` (30000 stem entries), the virtual storage of the step, measured in an MVS/CE container whose private area is larger than an 8 MB region | 8596K; more than the 8192K of the region of the installation verification job `TESTRX` | 5560K |
| An exec that runs out of memory | the error path allocated again and failed again, and the console showed the message over and over until the step ended in S322 or S0C4 | one message `Memory allocation failed.` and the exec ends with RC 60 (`Memory reallocation failed.`, RC 61); measured in the main task, not under `PRIVILEGE('ON')` |
| Loading, `LINES`, `LINEOUT`, `SAY` (earlier 3.0.0-dev builds, measured on MVS) | IMPORT of a large exec 6.0 s, LINES of 2000 lines 18.5 s, LINEOUT 11.5 s, SAY 11.3 s | 0.34 s, 0.37 s, 1.0 s, 1.2 s |

The cleanup pass also fixed uninitialised pointers, buffer overflows in the interpreter and its support modules (FSS, RAC, dynamic allocation, arrays, matrices, linked lists, `VLIST`, `JOIN`, `ROTATE`, `FPOS`, `TCPWAIT`, `CONSOLE`, `EXECIO`, `MINVERT`), and some 600 compiler warnings. The build runs with `-Wall -Wextra -Werror`. Test cases were adopted from CMS-370-BREXX for PARSE, SIGNAL, CALL ON, conditions, NUMERIC and DATE, and the interpreter follows them. The regression suite has 204 steps: the smoke test, one step per test exec, and two IDCAMS steps around the VSAM test; a test that needs TSO runs under a batch TMP instead of in the batch step. It runs on MVS/CE for every change to the main branch and passes; VSAMIO and IRXVTOC are covered by it now.

## Known issues

- **NJE38 functions: limits.** If `PRIVILEGE('ON')` is in effect when the first `__NJERECEIVE` starts its subtask, the subtask ends with S306 and `__NJERECEIVE` returns `#ERROR` with `_RC` -2; call `PRIVILEGE('OFF')` first. A step that ends with a user abend (`ABEND 100`) while a user is registered leaves a stale registration at NJE38: the next `__NJERECEIVE` of that user returns `#ERROR` with `_RC` 24 until the operator restarts NJE38 (`P NJE38`, `S NJE38`). `__NJESEND` works only under the TSO terminal monitor program and returns -3 in a step without it. The NJE38 tests of the regression suite skip where no NJE38 started task runs, which is the case on the MVS/CE system that runs the suite for every change ([#328](https://github.com/mvslovers/brexx370/issues/328)).
- Near the limit of the long float (about 7.2E+75) four cases are not right yet; they are planned for 3.0.1. `MNORMALISE` and `MPROPERTY` can still end in S0CC instead of error 42 ([#472](https://github.com/mvslovers/brexx370/issues/472)). `POW(2,251.99) / 1E75` gives error 41 ([#483](https://github.com/mvslovers/brexx370/issues/483)). `COSH(x)` and `SINH(x)` with |x| between 174.67 and 175.36 give error 42 although the result is representable, and `7.19E75 // 7` returns a wrong number ([#460](https://github.com/mvslovers/brexx370/issues/460)).

## Install

The package is `brexx370-3.0.0-dist.zip` (the same files as `brexx370-3.0.0-dist.tar.gz`; the file `brexx370-3.0.0-load.xmit` is also attached to the release on its own). The User's Guide, chapter "Installing BREXX/370", describes every step; this is the short form. Upload the six `xmit` files in binary to sequential data sets with RECFM FB and LRECL 80.

| File | What |
|---|---|
| `brexx370-3.0.0-alloc.jcl` | Allocates the SMP libraries once (job `BREXXALC`, procedure `SMPALLOC`, parameters `TGTVOL` and `DLBVOL`): the target libraries `BREXX.LINKLIB`, `BREXX.RXLIB` and `BREXX.SAMPLIB` on `TGTVOL`, the distribution libraries `BREXX.ARXLINK`, `BREXX.ARXLIB` and `BREXX.ARXSAMP` on `DLBVOL` |
| `brexx370-3.0.0-inst.jcl` | Unpacks the `xmit` files, receives, checks, applies and accepts `TBRX300` (job `BREXXINS`); replace every `CHANGE.ME.` name with the data set you uploaded to; on MVS/CE take the comment marks off the `VOLUME` line of each `RECEIVE` and name the volume (`PUB000` on a stock MVS/CE) |
| `brexx370-3.0.0-load.xmit` | The load modules `BREXX` (aliases `REXX`, `RX`), `IRXVTOC`, `IRXVSMIO`, `IRXVSMTR` |
| `brexx370-3.0.0-rxlib.xmit`, `brexx370-3.0.0-rxsamp.xmit` | The function library and the samples, installed by SMP as `BREXX.RXLIB` and `BREXX.SAMPLIB`; the installation job unpacks them into staging libraries and deletes those at the end |
| `brexx370-3.0.0-cmdlib.xmit`, `-jcl.xmit`, `-proclib.xmit` | The TSO commands, the sample jobs and the procedures, as the plain data sets `BREXX.CMDLIB`, `BREXX.JCL` and `BREXX.PROCLIB` |

1. Run `BREXXALC` once. On TK5 use `//ALLOC EXEC SMPALLOC,TGTVOL=TK5RES,DLBVOL=TK5DLB`. A volume that the system does not have holds the job with `IEF238D`; reply `R 00,CANCEL`, correct the volume and submit again.
2. Run `BREXXINS`. The jobs ask for `REGION=4096K`; a system that answers `REGION UNAVAILABLE, ERROR CODE=20` accepts 4 or 6 MB. The job deletes `BREXX.CMDLIB`, `BREXX.JCL` and `BREXX.PROCLIB` of an earlier installation and creates them again, so that it can run twice: copy what you changed in them first.
3. **Check the result by listing the target libraries**, not by the condition codes. `LIST CDS SYSMOD(TBRX300)` must show `REC APP ACC`, and the same stanza lists every member of `BREXX.RXLIB` and `BREXX.SAMPLIB` as a macro element. The job has no `DELETE` step for the six SMP libraries on purpose: do not scratch the distribution libraries after the accept, or SMP reports an accepted function with empty libraries behind it.
4. Put `BREXX.LINKLIB` into the link list before `SYS2.LINKLIB`, with its volume serial, or into the `STEPLIB` of the sessions and jobs that run BREXX/370 (see above). Copy the procedures `RXTSO` and `RXBATCH` from `BREXX.PROCLIB` into a procedure library of the system. Set up the TSO logon procedure as the User's Guide, "Setting Up TSO", describes it.
5. Give the users who need the privileged functions their FACILITY profiles `SVC244` and `DIAG8CMD`.

**TSO integration (optional)** (`ZMG0001.xmit`, `ZMG0001.zip`)

The usermod ZMG0001 makes TSO's `EXEC` command, and implicit invocation, run REXX through BREXX. It comes as source in one library, `USERMOD.ZMG0001`: the assembler source of its two modules and the usermod, and the jobs that assemble the modules on your system with `IFOX00`. `ZMG0001.xmit` is the library as a TSO TRANSMIT file (upload it in binary, RECFM FB, LRECL 80, BLKSIZE 3120, and `RECEIVE INDSN(...) DATASET('USERMOD.ZMG0001')`); `ZMG0001.zip` holds the same members as text files. No object deck and no SMP package file go with it.
- `%name` and `name` search `SYSUEXEC`, `SYSUPROC`, `SYSEXEC` and `SYSPROC`.
- A member is REXX when it comes from an EXEC library, or when line 1 is a REXX comment.
- A CLIST stays a CLIST.

TK5 Update 6 installs ZMG0001 together with BREXX/370 3.0.0, so there is nothing to do there. The library contains the jobs to check the prerequisites (ZMG01CK), back up EXEC (ZMG01BK), assemble, receive and check (`$INSTALL`), assemble again and apply (ZMG01AP) and remove the usermod again (ZMG01RS); the cover letter (`@CVRLET`) lists the order. The prerequisites are PTF UY16532 applied, BREXX in the link list, the macro libraries `SYS1.MACLIB` and `SYS1.AMODGEN` and the assembler `IFOX00`, and neither ZMG0002 (the TSO integration of REKX/370) nor ZMG0003 installed: the three change the same elements and exclude each other, so restore the one that is installed before you apply another. On MVS/CE that PTF is applied but not accepted: ZMG0001 applies anyway, but accept the PTF first if you want to remove the usermod again with `RESTORE`. Copying the saved `EXEC` back afterwards is optional: `RESTORE` alone returns `EXEC` to the level of the distribution library and it behaves as before. The apply and the removal each write `EXEC` behind the last member of `SYS1.CMDLIB`: make room first (on MVS/CE the library is one extent and 93 % full; the guide has the IEBCOPY job that compresses it), and if the apply takes a new extent, `EXEC` cannot be loaded until the next IPL. In `$INSTALL` the step `REJ` ends with condition code 12 the first time, which is expected; the code that counts is the one of the step `SMP`. Do not accept the usermod. One thing to check before you apply it: a member name that exists in both a `SYSEXEC` and a `SYSPROC` library now runs the exec. On MVS/CE this is `SHUTDOWN`.

**Manuals** (`ml03-0001-1.pdf`, `ml03-0002-1.pdf`, `ml03-0003-1.pdf`, and `SHA256SUMS` for every file of this release)

## Full list of changes

The pull requests merged since the preview 3.0.0-dev, by topic. The complete list, with the internal ones, is [v3.0.0-dev...v3.0.0](https://github.com/mvslovers/brexx370/compare/v3.0.0-dev...v3.0.0).

**Installation and packaging**
- Package RXLIB and SAMPLIB for SMP: 80-column sources, staging, build check (#480)
- The SMP libraries have DD names of their own (`RXLINK`, `ARXLINK`, `RXLIB`, `ARXLIB`, `RXSAMP`, `ARXSAMP`), because `LINKLIB` and `SAMPLIB` are DDs of the SMP procedures; the distribution libraries are `BREXX.ARXLINK`, `BREXX.ARXLIB` and `BREXX.ARXSAMP`, and the samples file is `rxsamp.xmit` (#535)
- SMP package: `[distribution]`/`[smp]` block for TBRX300 and an install/check/remove tool (#485)
- Delivered JCL, PROCLIB and CMDLIB: new data set names, no placeholders (#495)
- `PARSE VERSION` shows V3R0M0 (#450)
- RXLIB routines `PRINT`, `LISTCAT` and `LISTALC` renamed `PRINTX`, `LISTCATX`, `LISTALCX`; eight samples renamed (#480, #484)
- License: GPL-2.0 in `COPYING`, the obsolete freeware notice dropped (#383, #449)
- BREXX is linked with authorization code 0 and runs unauthorized, also from an APF-authorized library (#547, #549)
- The README names 3.0.0 as the release and describes the package (#548)
- Toolchain: cc370 1.6.3, libc370 2.28.0 and mbt 3.0.0-rc4 (#428, #457, #537)

**TSO, input and output**
- Standard streams from `STDOUT`/`STDERR`/`STDIN`, and under a TMP through PUTLINE and GETLINE, then `SYSTSPRT`/`SYSTSIN` (#375, #377, #378)
- `ADDRESS` to an unknown environment: RC -3 (#373)
- `ADDRESS COMMAND 'CP ...'` takes the privilege it needs (#370)
- `PRIVILEGE('ON')` stays in effect across `SYSVAR('SYSNODE')`, `LISTVOLS` and `CP` commands (#545)
- `MVSVAR('REXX')` and `MVSVAR('REXXDSN')` for an exec read through a DD, as `RXTSO` and `RXBATCH` do (#519)
- `SYSDSN()` reports the messages of TSO/E (#379)
- ZMG0001: `SYSEXEC` before `SYSPROC` measured on z/OS; the guide says when it is needed and follows the shipped jobs (#369, #452, #463); the usermod is shipped as source and assembled by `IFOX00` on the target (#520); one library `USERMOD.ZMG0001` as `ZMG0001.xmit` and `ZMG0001.zip`, a `REJECT` before the `RECEIVE`, the modules identified as ZMG0001 (#533); the level before the usermod is documented in the source of `IKJCT430`, and copying the saved `EXEC` back after `RESTORE` is optional (#541)

**Arithmetic and numbers**
- Arithmetic beyond the float range gives error 42, not S0CC (#453)
- `POW(2,252)` is error 42 (#470); matrix functions give error 42 instead of S0CC (#471)
- Numeric comparison beyond 7.2E+73 answers (#474)
- `MAX()`/`MIN()` return a real for whole numbers beyond 32 bits (#501)
- `X2D`: length 0 gives 0, a value beyond a long is error 40 (#419)
- `DATATYPE 'W'`: whole under `NUMERIC DIGITS` (#431)
- `ROUND`, `DATE('GERMAN')`, `C2D`, `RANDOM`, `PRIVILEGE('OFF')` (#403)

**Built-in functions and RXLIB**
- Small blocks come from a pool in the main task, so a stem entry takes about 120 bytes instead of 256 (under `PRIVILEGE('ON')` and in the NJE38 subtask it stays 256); running out of memory ends the exec once with RC 60 (61) and leaves `PRIVILEGE('ON')` first, and an NJE38 subtask that runs out of memory ends the subtask and reports the error to `__NJERECEIVE` (#532)
- Array, list and string functions stay inside their arrays: string arrays, `SDIFFERENCE`, `MDELROW`, `MDELCOL`, `ISEARCH`, `JOIN`, `ROTATE`, `MINVERT`, linked lists, `FPOS`, `ICREATE PRIME`, `ISORT`, `SHSORT`, `SREVERSE`, `FARRAY`, `LLCOPY`, `LL2S` (#382, #392, #393, #394, #398, #399, #400, #402)
- `DEFINED`, `DATETIME`, `SEC2TIME`, `WORDINS`, `MVSVAR`, `LL2STEM`, `LISTVOL`, `VLIST` (#391, #401)
- `EXECIO` `FIFOW`/`LIFOW`, `FIFOR`, `SKIP`; `TCPOPEN`, `TCPSEND`, `TCPWAIT`, `SUBMIT` (#387, #395, #404)
- `DYNREXX`, `MTT`/`MTTX`, option arguments, `MATCH`, `STREAM`, FSS (#405)
- `CONSOLE` refuses a command longer than its buffer (#397)
- More than 32 arguments: a 33rd is error 40; external functions take 32 arguments (#385, #390)
- `RESULT` and `SELECT` as in TSO/E (#411); `QUOTE` takes a second argument and the RXLIB `QUOTE` is gone (#412)
- RXLIB: `STDATE`, `READALL`, `WRITEALL`, `LISTALC`, `MATIN`, `MPRINT` and others (#407); KEYVALUE `DBGET`, `DBPRINT`, `DBNEXT`, `DBLOCATE`, `DBRCOUNT`, `DBWORKBENCH` (#408)
- FSS routines, `TCPSF`, samples (#409); FSSMENU: a selection without the option line works, a menu without a title gets a message field (#413, #425)
- `JESQUEUE`: the spool list shows its rows again, `S` reports failures (#517)
- `JESQMENU` fits an 80-column screen (#524); `JES2SPL`: `P` purges held output of any class, no FSS error (#526)
- Line-end commas that joined two arguments in the RXLIB routines and the samples (#530)
- The samples `STUDENTI`, `STUDENTK` and `STUDENTN` allocate with `ALLOCATE()` and stop on a failed allocation (#550)
- PL/I F samples link with `ENTRY IHESAPD` and work again (#432)

**Data sets, VSAM and NJE38**
- VSAMIO and IRXVTOC tests, and the defects they found (#464); `DELETE KEY` erases the named record (#503); the `KEY` and `VAR` words of VSAMIO are bounded and a missing one is refused (#388)
- `CREATE()` writes the end-of-file mark of a new sequential data set (#476)
- NJE38: `__NJEDEREGISTER` fix (#473); user ID over 8 characters, error 68, failed subtask start (#489); no `NJE_DEREGISTER` after a failed `NJE_REGISTER` (#496); the message copy is terminated and bounded (#497); `__NJEREGISTER` registers only the logged-on user (#502); the functions take their authorization from SVC 244 for the length of a call, an exec that ends without `__NJEDEREGISTER` ends the subtask, `SYSVAR('SYSNODE')` of a registered user (#527)

**Manuals**
- Manuals ML03-0001, ML03-0002 and ML03-0003, and the Read the Docs site; the Sphinx manual is gone (#396, #417)
- The functions that exist only with their RAKF profile (#372); authorization of the caller and the FACILITY profiles that must be defined (#560); the STUDENTI note removed from the Library and Samples book (#552)
- Installation, upgrade from V2R5M3, changes in 3.0 (#462); IEBCOPY job for the `SYS1.CMDLIB` compress (#455); the migration table names all seven matrix functions (#479); the chapter NJE38 messages (#475)
- The manuals are built on every pull request and attached to the release with `SHA256SUMS` (#416, #418)

**Build and tests**
- The build moved to mbt 3; `-Wall -Wextra -Werror`; the IBM macros come from maclib370 (#421, #427, #430)
- Interactive tests run with `mbt test --tso` (#423); further regression tests for `matovfl` (#482)
- Tests for the authorization of the job step after an abend and in tight `__NJERECEIVE` loops (#538), for `PRIVILEGE('ON')` followed by `OFF` (#543), for running out of memory and for 45000 stem entries (`oomstem` runs in a job of its own, #532), and the `%CLST` case of `exec_test` judged by whole line (#536)
