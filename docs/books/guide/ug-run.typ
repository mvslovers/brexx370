#import "../bookmaster/bookmaster.typ": *

= Running REXX Programs <ug-run>

#idx("exec", "running")
An exec runs in one of three environments: in a TSO session at a terminal,
under TSO in a batch job, and in a batch job without TSO. The language is
the same in all three; what differs is where #cmd("SAY") writes, where
#cmd("PULL") reads, and whether TSO commands can be used. This chapter shows
how to start an exec in each, and where its input and output go.

== At a TSO Terminal <ug-run-tso>

#idx("RX command")#idx("REXX command")
In a TSO session an exec is started with the command #cmd("RX") or
#cmd("REXX") -- both are names of the BREXX/370 load module -- followed by
the name of the exec and its argument:

```
RX MYEXEC first second
REXX 'MY.EXEC(MYEXEC)' first second
RX 'MY.SEQ.REXX'
```

A name without quotes is a member, which BREXX/370 looks for in the
libraries allocated to #cmd("SYSUEXEC"), #cmd("SYSUPROC"), #cmd("SYSEXEC")
and #cmd("SYSPROC") (@ug-calling). A name in quotes is a data set: a member
of a partitioned data set, or a sequential data set that holds the exec.

With the usermod ZMG0001 installed (@ug-install-zmg), an exec also runs
when it is called like a TSO command, by its name or with #cmd("%")
#var("name"), and with the TSO command #cmd("EXEC").

#idx("argument", "of an exec")
*The argument.* Called as a TSO command, the exec gets the rest of the
command line after its name as one argument, as TSO/E gives it to an exec
called by name: without leading and trailing blanks, otherwise unchanged.
Runs of blanks and quotes are kept: #cmd("RX 'MY.EXEC(MYEXEC)'  a   b  \"c\"")
gives #cmd("ARG(1)") the value #cmd("a   b  \"c\"").

#idx("SAY", "at a terminal")#idx("PULL", "at a terminal")
*Input and output.* #cmd("SAY"), the output of #cmd("TRACE") and the error
messages appear on the terminal. #cmd("PULL") and #cmd("PARSE PULL") with
an empty stack read a line from the terminal.

A user library of execs is the place to keep your own: by convention
#var("userid")#cmd(".EXEC"), with #cmd("RECFM=VB") and #cmd("LRECL=255"),
allocated to #cmd("SYSUEXEC") by the logon procedure (@ug-install-tso).

== Under TSO in a Batch Job <ug-run-tsobatch>

#idx("IKJEFT01")#idx("RXTSO procedure")
A batch job runs TSO with the terminal monitor program #cmd("IKJEFT01"),
reads TSO commands from #cmd("SYSTSIN") and writes the output of TSO to
#cmd("SYSTSPRT"). An exec started there with the TSO command #cmd("RX"),
#cmd("REXX") or #cmd("BREXX") runs as at a terminal: it may use TSO
commands through #cmd("ADDRESS TSO"). Started with the TSO command
#cmd("CALL") instead, it runs as a plain program: TSO passes it no command
parameter list, and #cmd("ADDRESS TSO"), #cmd("ADDRESS COMMAND") and
#cmd("ADDRESS ISPEXEC") are not available (see below).

The procedure #cmd("RXTSO") does this for one exec:

```
//DATETEST JOB CLASS=A,MSGCLASS=H,REGION=8192K,NOTIFY=&SYSUID
//REXX     EXEC RXTSO,EXEC='DATE#T',SLIB='BREXX.V2R5M3.SAMPLES'
```

#deflist(width: 1.1in,
  [#cmd("EXEC=")], [the member that holds the exec.],
  [#cmd("SLIB=")], [the library that holds that member.],
  [#cmd("P=")], [the argument of the exec, if it takes one.],
  [#cmd("LIB=")], [the RXLIB library. The procedure allocates it to
    #cmd("RXLIB").],
)

The procedure allocates the exec to the DD statement #cmd("EXEC") and runs
#cmd("BREXX EXEC") under #cmd("IKJEFT01"). Its #cmd("SYSTSIN") is a
#cmd("DUMMY") data set, so #cmd("PULL") there gets the null string at once.
A step of your own can run several execs and TSO commands from one
#cmd("SYSTSIN"), and give them input lines.

#idx("SYSTSPRT")#idx("SYSTSIN")
*Input and output.* Under the terminal monitor program BREXX/370 reads and
writes through TSO, as TSO/E REXX does:

- #cmd("SAY"), the output of #cmd("TRACE") and the error messages go into
  #cmd("SYSTSPRT"), in order with the messages of TSO.
- #cmd("PULL") and #cmd("PARSE PULL") with an empty stack read the next line
  of #cmd("SYSTSIN"). TSO does not then run that line as a command. At the
  end of #cmd("SYSTSIN") they return the null string.
- The DD statements #cmd("STDOUT"), #cmd("STDERR") and #cmd("STDIN") are not
  used. A procedure written for V2R5M3 that has them can drop them.

This holds whether the step runs the command #cmd("BREXX") or calls the
program with the TSO command #cmd("CALL").

== In a Batch Job without TSO <ug-run-batch>

#idx("RXBATCH procedure")#idx("PGM=BREXX")
An exec that needs no TSO runs as an ordinary program,
#cmd("EXEC PGM=BREXX").

#idx("ADDRESS TSO", "without TSO")#idx("return code", "-3")
TSO commands are not available there. #cmd("ADDRESS TSO"),
#cmd("ADDRESS COMMAND") and #cmd("ADDRESS ISPEXEC") need the command
parameter list that only a TSO command receives: without it a command to
them ends with return code -3, which raises the condition #cmd("FAILURE")
if the exec traps it and is otherwise only the value of #cmd("RC"). The
same holds for an exec started with the TSO command #cmd("CALL").
#cmd("EXECIO") works without TSO, under #cmd("ADDRESS TSO") and
#cmd("ADDRESS MVS") alike.

The procedure #cmd("RXBATCH") runs one exec this way:

```
//ETIMETST JOB CLASS=A,MSGCLASS=H,REGION=8192K,NOTIFY=&SYSUID
//REXX     EXEC RXBATCH,EXEC='ETIME#T',SLIB='BREXX.V2R5M3.SAMPLES'
```

It takes the same parameters as #cmd("RXTSO"). It allocates the exec to
the DD statement #cmd("RXRUN") and passes #cmd("RXRUN") and the argument
as the #cmd("PARM") of the step.

#idx("STDOUT")#idx("STDERR")#idx("STDIN")
*Input and output.* Without TSO, BREXX/370 uses DD statements:

- #cmd("SAY") writes to #cmd("STDOUT").
- The output of #cmd("TRACE") and the error messages go to #cmd("STDERR").
- #cmd("PULL") reads #cmd("STDIN").
- A step without #cmd("STDOUT") writes to #cmd("SYSTSPRT"), as an IRXJCL
  step of TSO/E does, and without #cmd("STDERR") the messages go there too.
  Without #cmd("STDIN") it reads #cmd("SYSTSIN"). JCL written for IRXJCL
  therefore runs BREXX/370 with its DD statements unchanged.
- An output DD statement that is missing altogether becomes a SYSOUT data
  set that BREXX/370 allocates itself.

#idx("argument", "in batch")
*The argument.* In batch, from the #cmd("PARM") of the step, and with the
TSO command #cmd("CALL"), the words of the argument are separated by single
blanks, and #cmd("\"") quotes are removed.

#idx("BREXX command", "options")
*Options.* The first word may set the trace instead of naming the exec:
#cmd("-")#var("x"), #cmd("?")#var("x") or #cmd("!")#var("x") traces as
#cmd("TRACE") #var("x") would, so #cmd("-R HELLO") runs #cmd("HELLO") with
#cmd("TRACE R"). The option must not be in quotes: a quoted word is taken
for the name of the exec. #cmd("-") alone as the first word makes the rest
of the line the program -- #cmd("BREXX - SAY 'INLINE' 1+2") shows
#cmd("INLINE 3") -- and with nothing after it the program is read from
#cmd("STDIN"). #cmd("NOSTAE") as the last word runs the exec without the
recovery that BREXX/370 otherwise sets up.

== Which Environment to Use <ug-run-choose>

#tab(caption: [Where an exec runs])[
  #table(columns: (1.3in, 1fr, 1fr),
    [Environment], [Output and input], [Can use],
    [TSO terminal], [the terminal], [#cmd("ADDRESS TSO"),
      #cmd("COMMAND") (CP commands), #cmd("ISPEXEC") where ISPF runs,
      full-screen functions],
    [TSO in batch (#cmd("RXTSO"))], [#cmd("SYSTSPRT"), #cmd("SYSTSIN")],
      [#cmd("ADDRESS TSO") and #cmd("COMMAND")],
    [batch (#cmd("RXBATCH")), or TSO #cmd("CALL")], [#cmd("STDOUT"),
      #cmd("STDERR"), #cmd("STDIN")\; under #cmd("CALL") the TSO
      streams], [none of #cmd("TSO"), #cmd("COMMAND"), #cmd("ISPEXEC")\;
      #cmd("EXECIO") and #cmd("ADDRESS MVS") work],
  )
] <ug-run-tab>

An exec that allocates data sets or calls TSO commands needs one of the
TSO environments. An exec that only reads and writes data sets runs in any
of the three.
