#import "../bookmaster/bookmaster.typ": *

= Working with TSO and MVS <ug-tso>

#idx("host command environment")
An exec does most of its work in REXX itself, and hands the rest to the
system: TSO commands, programs, data sets. This chapter shows the ways it
does so. The _BREXX/370 Reference_ describes each of them in full.

== Host Command Environments <ug-tso-address>

#idx("ADDRESS")
A clause that is an expression and nothing else -- a quoted string, most
often -- is a command. REXX evaluates it and passes the result to the
current host command environment, which the instruction #cmd("ADDRESS")
selects:

```
ADDRESS TSO 'LISTCAT LEVEL(BREXX)'   /* one command to TSO         */
ADDRESS MVS                          /* MVS from here on           */
'EXECIO * DISKR INDD (STEM LINE. FINIS'
```

After every command, the special variable #cmd("RC") holds its return code.

#tab(caption: [The host command environments])[
  #table(columns: (1.15in, 1fr, 1.3in),
    [Environment], [Passes the command to], [Needs],
    [#cmd("TSO")], [a TSO command processor, which is loaded and called
      with a command parameter list], [a TSO command (@ug-run)],
    [#cmd("MVS")], [#cmd("EXECIO") and the VSAM commands, which BREXX/370
      carries out itself; any other word is run as a program of that
      name, with return code -3 if there is none], [nothing],
    [#cmd("COMMAND")], [the control program under which MVS runs, with
      #cmd("CP")#var(" command")], [a TSO command; RAKF
      #cmd("FACILITY SVC244") READ, or APF],
    [#cmd("CONSOLE")], [an operator command], [a TSO command; RAKF
      #cmd("FACILITY SVC244") READ, or APF],
    [#cmd("ISPEXEC")], [the ISPF of Wally McLaughlin], [a TSO command,
      ISPF running],
    [#cmd("FSS")], [the formatted-screen services], [a TSO terminal],
    [#cmd("LINK"), #cmd("LINKMVS"), #cmd("LINKPGM")], [a program, called
      with the linkage of the TSO/E environments of these names],
      [nothing],
  )
] <ug-tso-env-tab>

The table shows the environments an exec uses most; the _BREXX/370
Reference_ lists them all, among them #cmd("DYNREXX").

#idx("ADDRESS TSO", "command not found")
*TSO commands.* #cmd("ADDRESS TSO") loads the command processor of the
command's name and calls it, as TSO does. Without a command parameter list -- in a batch step
without TSO, or under the TSO command #cmd("CALL") -- every command to
#cmd("TSO"), #cmd("COMMAND") and #cmd("ISPEXEC") ends with return code -3
(@ug-run-batch).

== Capturing the Output of a Command <ug-tso-outtrap>

#idx("OUTTRAP")
#cmd("OUTTRAP") collects what commands write into a stem variable instead
of the terminal or #cmd("SYSTSPRT"):

```
CALL OUTTRAP 'LCAT.'
ADDRESS TSO 'LISTCAT LEVEL(BREXX)'
CALL OUTTRAP 'OFF'
DO i = 1 TO lcat.0
  SAY lcat.i
END
```

As in TSO/E REXX, #cmd("OUTTRAP") traps what commands write that run with
#cmd("ADDRESS TSO") or #cmd("ADDRESS COMMAND"), including the output of
another exec run as a command, and not the exec's own #cmd("SAY"),
#cmd("TRACE") output or error messages. The stem is filled after each
command, and #var("stem")#cmd(".0") holds the number of lines so far.
Output that a command writes in full-screen mode cannot be trapped.

#cmd("ARRAYGEN") works the same way, but collects the lines in a string
array of BREXX/370 instead of a stem.

== Reading and Writing Data Sets <ug-tso-data>

#idx("data set", "reading and writing")#idx("EXECIO")
An exec reads and writes data sets in three ways:

- *#cmd("EXECIO")*, the command of TSO/E REXX, under #cmd("ADDRESS MVS")
  or #cmd("ADDRESS TSO"): records into a stem or onto the stack, and back.
  It works in every environment, also in a batch step without TSO.
- *The stream functions of REXX*: #cmd("LINEIN"), #cmd("LINEOUT"),
  #cmd("CHARIN"), #cmd("CHAROUT"), #cmd("LINES") and #cmd("STREAM"). A
  stream name without quotes is a DD name; under TSO with a prefix it is
  first tried as the data set #var("prefix")#cmd(".")#var("name"), then as
  a DD name. A name in quotes is a data set name as it stands. The standard
  streams are #cmd("<STDIN>"), #cmd("<STDOUT>") and #cmd("<STDERR>").
- *The data set functions of BREXX/370*, which allocate, list, create and
  delete data sets and read the catalog and the VTOC.

```
/* REXX - copy a data set, line by line */
DO WHILE LINES('INDD') > 0
  CALL LINEOUT 'OUTDD', LINEIN('INDD')
END
CALL LINEOUT 'OUTDD'
```

== Calling Programs <ug-tso-link>

#idx("ADDRESS LINKMVS")
#cmd("ADDRESS LINKMVS"), #cmd("LINKPGM") and #cmd("LINK") call a load
module, with the parameter conventions of the TSO/E environments of the
same names. This calls IEBGENER with its input and output under other DD
names:

```
prog   = 'IEBGENER'
parm   = ''
ddlist = COPIES('00'X, 32) ||,   /* SYSLIN ... SYSLIB: unchanged   */
         LEFT('CTL', 8) ||,      /* SYSIN                          */
         LEFT('REP', 8) ||,      /* SYSPRINT                       */
         COPIES('00'X, 8) ||,    /* SYSPUNCH                       */
         LEFT('INP', 8) ||,      /* SYSUT1                         */
         LEFT('OUT', 8)          /* SYSUT2                         */
ADDRESS LINKMVS prog 'parm ddlist'
```

A program that must run authorized needs BREXX/370 to run authorized
(@ug-install-apf).

== Commands to Hercules <ug-tso-cp>

#idx("ADDRESS COMMAND", "CP")
#cmd("ADDRESS COMMAND 'CP ")#var("command")#cmd("'") passes a command to
Hercules, or to VM when MVS runs under VM, and shows its answer; trap it
with #cmd("OUTTRAP") to process it:

```
CALL OUTTRAP 'DEV.'
ADDRESS COMMAND 'CP DEVLIST'
CALL OUTTRAP 'OFF'
```

Only commands that begin with #cmd("CP") are accepted. BREXX/370 takes the
authorization the command needs itself, as #cmd("PRIVILEGE('ON')") does,
which requires READ access to the RAKF profile #cmd("SVC244") in the class
#cmd("FACILITY"), or BREXX/370 running authorized; without it the command
ends with return code -5 and is not sent. @ug-install-cp describes what
Hercules needs.
