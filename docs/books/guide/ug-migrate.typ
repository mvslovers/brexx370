#import "../bookmaster/bookmaster.typ": *

= Migrating from V2R5M3 <ug-migrate>

#idx("migration", "from V2R5M3")
Release 3.0 runs most execs written for V2R5M3 unchanged. This appendix
lists what changes for an exec, a procedure or a user, and what to do about
it.

== Input and Output under TSO <ug-migrate-io>

Under the TSO terminal monitor program -- a TSO session, or
#cmd("PGM=IKJEFT01") in batch -- BREXX/370 now reads and writes through TSO,
as TSO/E REXX does (@ug-run-tsobatch):

- #cmd("SAY"), #cmd("TRACE") output and error messages go into
  #cmd("SYSTSPRT") in batch, in order with the messages of TSO, and to the
  terminal in a session.
- #cmd("PULL") and #cmd("PARSE PULL") with an empty stack read the next line
  of #cmd("SYSTSIN") in batch; TSO does not then run that line as a command,
  and at the end of #cmd("SYSTSIN") they return the null string. In a
  session they read the terminal.
- The DD statements #cmd("STDOUT"), #cmd("STDERR") and #cmd("STDIN") are no
  longer used there. *Remove them from your #cmd("RXTSO") procedure.* A job
  that fed #cmd("PULL") from #cmd("STDIN") under #cmd("IKJEFT01") puts those
  lines into #cmd("SYSTSIN") after the command instead.

In a batch step without TSO -- #cmd("PGM=BREXX"), the procedure
#cmd("RXBATCH") -- #cmd("SAY") writes to #cmd("STDOUT"), messages go to
#cmd("STDERR") and #cmd("PULL") reads #cmd("STDIN"), as with V2R5M3. A step
without #cmd("STDOUT") uses #cmd("SYSTSPRT") and #cmd("SYSTSIN") as IRXJCL
does.

#idx("OUTTRAP", "changed")
#cmd("OUTTRAP") now traps what commands write, and only that. The exec's own
#cmd("SAY"), #cmd("TRACE") output and error messages are not trapped; the
output of another exec run as a command is. The options #var("max"),
#cmd("CONCAT")/#cmd("NOCONCAT") and #var("skip") apply to the one
#cmd("OUTTRAP") call that names them.

#idx("standard streams", "names")
*Write to the standard streams as #cmd("<STDOUT>") and #cmd("<STDERR>").*
#cmd("LINEOUT('STDOUT', ...)") names a DD called #cmd("STDOUT"), which the
standard output already holds, so the open fails with error 57. The names
#cmd("<STDOUT>"), #cmd("<STDERR>") and #cmd("<STDIN>"), or the handles 0 to
2, work.

== Removed <ug-migrate-removed>

- #cmd("PUTSMF") and the SMF type 242 records;
- the assembler routines #cmd("IRXISTAT") and #cmd("MVSDUMP") of the
  V2R5M3 sources, which no exec could call. The V2R5M3 installation of TK5
  and MVS/CE never installed them;
- #cmd("OPEN(..., 'VIO')");
- the undocumented CLIST variable pool;
- the #cmd("IRXEXCOM") interface: BREXX/370 publishes no environment block
  any more (@ug-restrict-irxexcom).

== Renamed <ug-migrate-renamed>

#idx("renamed members")
Three RXLIB routines have a new name, because their old names are names of
IBM elements that SMP must not replace: #cmd("LISTCAT") is now
#cmd("LISTCATX"), #cmd("LISTALC") is #cmd("LISTALCX") and #cmd("PRINT") is
#cmd("PRINTX"). There is no alias. An exec of your own that calls
#cmd("LISTCAT()"), #cmd("LISTALC()") or #cmd("CALL PRINT") must be changed
to the new name. It does not end with error 43: the old names are also the
names of IBM load modules, which BREXX/370 finds and calls as a last resort
(_BREXX/370 Reference_, “Calling a Load Module”), and they abend with
S0C4. BREXX/370 catches the abend and ends the exec with message
#cmd("BRX0003E")\; #cmd("SIGNAL ON SYNTAX") does not trap it. Eight samples are
installed under a new name too, for instance #cmd("LOCATE") as
#cmd("LOCDSN"), and #cmd("BUILD") is not installed. The _BREXX/370
Reference_, chapter “Changes in Release 3.0”, has the complete tables.

== Changed Behaviour <ug-migrate-changed>

- #cmd("ADDRESS") to an environment that does not exist answers return code
  -3, as TSO/E REXX does.
- A member found in #cmd("SYSUPROC") or #cmd("SYSPROC") counts as REXX only
  when its first line is a comment containing #cmd("REXX")\; any other
  member is taken for a CLIST and the search goes on (@ug-calling-main).
- Outside a TSO session a password-protected data set is refused; V2R5M3
  asked the operator for the password.
- #cmd("ADDRESS COMMAND") exists only for a user with READ access to the
  profile #cmd("DIAG8CMD"); for any other user it is an environment that
  does not exist, return code -3. A user with #cmd("DIAG8CMD") but without
  #cmd("SVC244") gets return code -5 from #cmd("ADDRESS COMMAND 'CP ...'"),
  where V2R5M3 ended the task with abend S047 (@ug-install-facility).
- #cmd("PRIVILEGE"), #cmd("CONSOLE"), #cmd("MTT"), #cmd("MTTX") and
  #cmd("ADDRESS CONSOLE") exist only for a user with READ access to
  #cmd("SVC244"); a call of #cmd("PRIVILEGE") without it is error 43.
- #cmd("SYSDSN") returns the messages of TSO/E, not only #cmd("OK") and
  #cmd("DATASET NOT FOUND").
- A comparison that is not strict ignores trailing blanks, as the REXX
  definition says.
- A real number is shown with at most 15 significant digits.
- A function or subroutine takes up to 32 arguments; the documentation of
  V2R5M3 gave 15. A 33rd ends with error 40 when the exec is compiled.

This list is the part that concerns installation and operation. The
_BREXX/370 Reference_, chapter “Changes in Release 3.0”, lists every change
an exec can notice, with the same expression run under V2R5M3 and under
release 3.0.

== Fixed <ug-migrate-fixed>

#tab(caption: [Fixes that an exec may notice])[
  #table(columns: (1.8in, 1fr, 1fr),
    [Case], [V2R5M3], [3.0],
    [#cmd("DECRYPT(ENCRYPT(x))")], [did not give #cmd("x") back],
      [gives #cmd("x") back],
    [#cmd("SOUNDEX")], [wrong codes for EBCDIC letters], [correct codes],
    [stream I/O], [one position for reading and writing; an implicit open
      could truncate], [separate read and write positions; an implicit
      open never truncates],
    [a number of #cmd("1E75") or more in the source], [abend while the
      exec was compiled], [a string: #cmd("DATATYPE(x,'N')") is 0,
      arithmetic gives error 41],
    [#cmd("ARG(")#var("n")#cmd(")") with #var("n") above 99], [error 40],
      [#cmd("''"), as in TSO/E],
    [integer arithmetic beyond 32 bits], [wrapped around], [goes on as a
      real number],
    [a result beyond about #cmd("7.2E+75") of #cmd("+ - * / % // **") or
      of the matrix functions #cmd("MSCALAR"), #cmd("MMULTIPLY"),
      #cmd("MINVERT"), #cmd("MADD"), #cmd("MSUBTRACT"), #cmd("MPROD") and
      #cmd("MSQR")],
      [abend S0CC], [error 42, which #cmd("SIGNAL ON SYNTAX") catches],
    [a comparison of numbers above #cmd("7.2E+73"), or of opposite sign
      and above #cmd("3.6E+75")], [abend S0CC], [a result],
    [a string array index out of range], [abend S0C4], [error 40],
    [#cmd("TRUNC")], [wrong results in some cases], [correct],
    [a built-in function given a variable or literal], [could change it in
      place], [leaves it alone],
  )
] <ug-migrate-fixed-tab>

The cleanup also removed many faults in the interpreter and its support
modules -- uninitialized pointers and buffer overflows among them -- that
could abend an exec or give wrong results.

== Upgrading an Installation <ug-migrate-install>

#idx("upgrade", "from V2R5M3")
TK5 and MVS/CE come with V2R5M3 installed. Release 3.0 does not replace it
by copying over it; it is installed beside it, and the old copy stays until
you remove it. What V2R5M3 leaves on a system, and what to do about each
piece, is this.

#tab(caption: [What V2R5M3 installs])[
  #table(columns: (1.9in, 1fr),
    [Where], [What],
    [#cmd("BREXX.V2R5M3.LINKLIB"), #cmd("BREXX.V2R5M3.APFLLIB")],
      [The load modules #cmd("BREXX") with the aliases #cmd("REXX") and
      #cmd("RX"), #cmd("IRXVTOC"), #cmd("IRXVSMIO"), #cmd("IRXVSMTR"),
      #cmd("IRXEXCOM") and #cmd("IRXNJE38"). The same eight names are in
      both libraries; #cmd("APFLLIB") is the authorized copy.],
    [#cmd("BREXX.V2R5M3.RXLIB"), #cmd("SAMPLES"), #cmd("CMDLIB"), #cmd("JCL"),
      #cmd("PROCLIB")],
      [The function library, the samples, the TSO commands, the jobs and
      the procedures.],
    [#cmd("SYS2.LINKLIB")],
      [A copy of the eight load modules, made by #cmd("$INSTALL"). This is
      the copy that TSO and the link list find.],
    [#cmd("SYS2.PROCLIB")],
      [The procedures #cmd("RXBATCH"), #cmd("RXTSO") and #cmd("RX2ASM").
      #cmd("RXTSO") names #cmd("BREXX.V2R5M3.RXLIB") as its default
      #cmd("LIB"). Release 3.0 has no #cmd("RX2ASM").],
  )
] <ug-migrate-install-tab>

*The first library that holds a module name wins.* A session that finds
#cmd("BREXX") in #cmd("SYS2.LINKLIB") runs V2R5M3, whatever else is
installed. On TK5 the same exec, run in the same batch step, shows this:

```
/* REXX */
PARSE VERSION v
SAY v
```

With release 3.0 in a #cmd("STEPLIB") it names release 3.0 and the date of
its build; without one it says #cmd("BREXX/370 V2R5M3 L02 (May 01 2024)").
A #cmd("STEPLIB") is searched before the link list, so it is the way to try
release 3.0 beside V2R5M3 (@ug-install-smp).

TK5 Update 6 does this for you: it comes with release 3.0 installed, with
#cmd("BREXX.LINKLIB") in the link list before #cmd("SYS2.LINKLIB") and the
old modules removed. To go over to release 3.0 on your own:

+ Install release 3.0 (@ug-install-smp). Its libraries have different names
  from those of V2R5M3, so nothing is overwritten.
+ Try it with a #cmd("STEPLIB") first, and run your execs and jobs.
+ Make release 3.0 the one the link list finds: enter #cmd("BREXX.LINKLIB")
  in #cmd("SYS1.PARMLIB(LNKLST00)") *before* #cmd("SYS2.LINKLIB"), and
  *with its volume serial*, as #cmd("BREXX.LINKLIB(TK5RES)") on TK5 and as
  #cmd("BREXX.LINKLIB(MVSRES)") on MVS/CE (in both cases the volume you gave
  as #cmd("TGTVOL")). On MVS/CE the form needs the usermod #cmd("MS00100"),
  which release 3.0 names as a prerequisite and TK5 already has
  (@ug-install-smp); without it the IPL answers #cmd("IEA327I"). The volume
  must be online at IPL, or the IPL stops with #cmd("IEA317A"). The link list
  is read at IPL, so an IPL follows. Then take the V2R5M3 modules out of
  #cmd("SYS2.LINKLIB"), so that no second copy is left: #cmd("BREXX"),
  #cmd("REXX"), #cmd("RX"), #cmd("IRXVTOC"), #cmd("IRXVSMIO") and
  #cmd("IRXVSMTR").
+ Replace the procedures #cmd("RXTSO") and #cmd("RXBATCH") in
  #cmd("SYS2.PROCLIB") by those of #cmd("BREXX.PROCLIB") (release 3.0
  receives them only there). Copies that stay in #cmd("SYS2.PROCLIB") keep
  the old default #cmd("LIB"), a V2R5M3 library. #cmd("RX2ASM") has no
  counterpart in release 3.0 and nothing in it uses the procedure; leave the
  copy in #cmd("SYS2.PROCLIB") or delete it.
+ Change the data set name of the RXLIB allocation in the logon procedure
  (@ug-install-tso names the CLIST that your system runs) and in your own
  JCL to that of the new release. *Before you do, search your execs
  for the renamed routines* (@ug-migrate-renamed), also those the system
  provides. On TK5 the logon CLIST #cmd("ISPLOGON") runs the exec
  #cmd("SYS2.EXEC($CONCAT)"), which calls #cmd("ListAlc(\"NOPRINT\")").
  With the RXLIB of release 3.0 that call abends with S0C4 (it reaches the
  IBM module #cmd("IKJPARS")), and the CLIST, which runs without messages,
  leaves the session without the user data sets in #cmd("SYSEXEC"),
  #cmd("ISPPLIB") and the other concatenations. Change the call to
  #cmd("ListAlcX") in #cmd("SYS2.EXEC($CONCAT)") at the same time as the
  RXLIB name: V2R5M3 has no #cmd("LISTALCX"), so #cmd("$CONCAT") with the
  new name needs release 3.0's RXLIB. Remove the #cmd("STDOUT"),
  #cmd("STDERR") and #cmd("STDIN") statements of #cmd("RXTSO")
  (@ug-migrate-io).
+ Add the profiles #cmd("SVC244") and #cmd("DIAG8CMD") for the users who
  need #cmd("PRIVILEGE"), #cmd("CONSOLE") or #cmd("ADDRESS COMMAND")
  (@ug-install-facility). V2R5M3 let them all use the functions.
+ When all of that runs, delete the data sets #cmd("BREXX.V2R5M3.*").

*Modules that release 3.0 does not have.* #cmd("IRXEXCOM") and
#cmd("IRXNJE38") of V2R5M3 are not part of release 3.0, and nothing in 3.0
uses them. #cmd("IRXEXCOM") is gone for good (@ug-restrict-irxexcom).
#cmd("IRXNJE38") reads the NJE38 spool and hands the result to the RXLIB
member #cmd("NJE38DIR") through #cmd("IRXEXCOM"); release 3.0 has no way
to do that, so #cmd("NJE38DIR") is not supported with it. The modules in
#cmd("SYS2.LINKLIB") do no harm if you leave them. #cmd("IRXISTAT") and
#cmd("MVSDUMP"), which the V2R5M3 installation of TK5 and MVS/CE does not
install either, are not part of release 3.0.

*Authorized form.* If you ran V2R5M3 authorized, with #cmd("$INSTAPF") and
the changes to #cmd("IKJEFTE2") and #cmd("IKJEFTE8"), release 3.0 needs
none of it, and it cannot do it: the load module is linked with
authorization code 0 and runs unauthorized, also in a library that is
APF-authorized. See @ug-install-apf for how the functions that need
authorization get it.

== Earlier Releases <ug-migrate-older>

An installation older than V2R5M3 is best upgraded to release 3.0
directly. The notes of the releases V2R1M0 to V2R4M1 -- among them the move
of the libraries under a versioned name, the authorized version of V2R3M0
and the removal of the load module #cmd("BREXXSTD") -- are in the
documentation of those releases.
