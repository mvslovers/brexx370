#import "../bookmaster/bookmaster.typ": *

= Host Command Environments <ext-address>

#idx("host command environment")
A command is passed to the current host command environment, which the
instruction #cmd("ADDRESS") selects (@lang-instr-address). This chapter
describes the environments of BREXX/370. After every command, #cmd("RC")
holds its return code. A negative return code raises the condition
#cmd("FAILURE"), or #cmd("ERROR") if #cmd("FAILURE") is not trapped; a
positive one raises #cmd("ERROR").

#tab(caption: [Return codes common to all environments])[
  #table(columns: (0.9in, 1fr),
    [Code], [Meaning],
    [#cmd("-3")], [The environment does not exist, is not available here,
      or does not know the command. #cmd("TSO"), #cmd("COMMAND"),
      #cmd("CONSOLE") and #cmd("ISPEXEC") answer -3 to every command when
      the exec was not started as a TSO command: in a batch step without
      TSO, and under the TSO command #cmd("CALL").],
    [#cmd("-5")], [The command needs an authorization that BREXX/370 could
      not obtain (#cmd("COMMAND"), #cmd("CONSOLE")).],
  )
] <ext-address-rc-tab>

== TSO <ext-address-tso>

#idx("ADDRESS TSO")
Passes the command to TSO: the command processor of that name is loaded
and called with a command parameter list, as TSO calls it. The return code
is that of the command processor; -3 if no load module of that name
exists. Commands that TSO handles itself and those found as load modules
both work under the terminal monitor program; the output of a command can
be trapped with #cmd("OUTTRAP").

#cmd("EXECIO") and #cmd("VSAMIO") are carried out by BREXX/370 itself, under
#cmd("ADDRESS TSO") as under #cmd("ADDRESS MVS"), also without TSO.

== MVS <ext-address-mvs>

#idx("ADDRESS MVS")
The environment of a batch step; it needs no TSO. It takes:

- #cmd("EXECIO"), to read and write data sets record by record
  (@ext-dataset);
- #cmd("VSAMIO"), the VSAM commands (@ext-vsam);
- any other word, which is run as a program of that name, with the rest of
  the command as its parameter. If no such load module exists, the command
  ends with return code -3 and the message
  #cmd("Error: Command ")#var("name")#cmd(" not found").

== COMMAND <ext-address-command>

#idx("ADDRESS COMMAND")#idx("CP command")
Passes a command to the control program under which MVS runs: Hercules,
or VM. Only commands that begin with #cmd("CP") are accepted; any other
gets return code -3.

```
ADDRESS COMMAND 'CP DEVLIST'
```

Under Hercules the command is a Hercules command, and Hercules must accept
commands from the guest (#cmd("DIAG8CMD ENABLE")). BREXX/370 takes the
authorization the command needs itself, as #cmd("PRIVILEGE('ON')") does,
and gives it back afterwards: it needs READ access to the RAKF profile
#cmd("SVC244") in the class #cmd("FACILITY"), or BREXX/370 running
authorized. Without it the command ends with return code -5 and is not
sent. The answer can be trapped with #cmd("OUTTRAP").

== CONSOLE <ext-address-console>

#idx("ADDRESS CONSOLE")#idx("operator command")
Issues the command as an operator command (SVC 34). It needs the same
authorization as #cmd("COMMAND") and ends with return code -5 without it;
a command too long for the operator command buffer is refused.

#note[*To be confirmed:* how an exec sees the response to the operator
command.]

== ISPEXEC <ext-address-ispexec>

#idx("ADDRESS ISPEXEC")
Passes the command to the ISPF of Wally McLaughlin, as a dialog service
request. What it supports is what that ISPF implements:

```
ADDRESS ISPEXEC
'CONTROL ERRORS RETURN'
'DISPLAY PANEL(PANEL1)'
```

== FSS <ext-address-fss>

#idx("ADDRESS FSS")
The formatted screen services: a 3270 screen made of fields, built and
shown by commands (@ext-fss).

== DYNREXX <ext-address-dynrexx>

#idx("ADDRESS DYNREXX")
Collects REXX clauses, command by command, into a routine that is kept for
the rest of the run. The first command begins with #cmd("{"), the last ends
with #cmd("}") followed by #cmd("AS") #var("name"), where #var("name")
begins with two underscores:

```
ADDRESS DYNREXX
"{ PARSE ARG a, b"
"RETURN a + b } AS __ADD"
```

A malformed definition is reported with a message beginning
#cmd("DYNREXX") and return code 8; the routine is then not stored.

#note[*To be confirmed:* how the stored routine is called.]

== LINK, LINKMVS and LINKPGM <ext-address-link>

#idx("ADDRESS LINKMVS")#idx("ADDRESS LINKPGM")#idx("ADDRESS LINK")
Call a load module, with the parameter conventions of the TSO/E
environments of the same names. The command is the name of the program
followed by its parameters. Register 0 is zero: BREXX/370 provides no
environment block (_BREXX/370 User's Guide_, “Restrictions”). The return
code is the program's.

#deflist(width: 1.1in,
  [#cmd("LINK")], [The rest of the command is passed as one character
    string, with its length.],
  [#cmd("LINKMVS")], [Each parameter names a variable. The program gets,
    for each, a halfword length followed by the value, with room for at
    least 500 bytes. What it leaves there is stored back: the value at the
    length it set; a length of 0 makes the variable null, a negative one
    leaves it as it was.],
  [#cmd("LINKPGM")], [Each parameter names a variable. The program gets
    the value alone, at its own length, and what it leaves there is stored
    back at the same length.],
)

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

#note[*To be confirmed:* the exact parameter list of #cmd("LINK"); the
source builds it in a way that may differ from TSO/E.]
