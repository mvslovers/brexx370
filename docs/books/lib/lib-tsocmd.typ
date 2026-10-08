#import "../bookmaster/bookmaster.typ": *

= TSO Commands Written in REXX <lib-tsocmd>

#idx("CMDLIB")#idx("TSO command", "written in REXX")
An exec becomes a TSO command when a CLIST of the command's name starts
it. BREXX/370 comes with a library of such CLISTs, CMDLIB. Each of them
holds a single TSO command, #cmd("RX") or #cmd("REXX"), that either runs
an exec or runs one or more REXX instructions written in the CLIST
itself. This chapter shows how they are built and describes the ones
that come with BREXX/370.

== Making a TSO Command <lib-tsocmd-make>

#idx("CLIST", "starting an exec")
A CLIST runs when its name is entered as a TSO command and the CLIST is a
member of a library in the #cmd("SYSPROC") concatenation of the session.
Add CMDLIB --
#cmd("BREXX.")#var("version")#cmd(".CMDLIB") after an installation by
hand; with release 3.0 the names carry no version -- to that
concatenation in the logon CLIST (_BREXX/370 User's Guide_, "Setting Up
TSO"), or copy the members you want into a library that is already
there, such as #cmd("SYS2.CMDPROC").

#note[*To be confirmed:* the data set name of CMDLIB in release 3.0,
presumably #cmd("BREXX.CMDLIB").]

The CLIST uses one of two forms:

#deflist(width: 1.5in,
  [#cmd("RX ")#var("exec")], [Runs the exec #var("exec"), found in the
    libraries allocated to #cmd("SYSUEXEC"), #cmd("SYSUPROC"),
    #cmd("SYSEXEC") and #cmd("SYSPROC"). Most commands of CMDLIB run an
    exec of the sample library, which must then be allocated to
    #cmd("SYSEXEC") or #cmd("SYSUEXEC"). #cmd("NOSTAE") as the last word
    runs the exec without the recovery that BREXX/370 otherwise sets up.],
  [#cmd("REXX - ")#var("instructions")], [Runs the REXX instructions that
    follow the minus sign. More than one instruction is separated by
    #cmd(";"). Written over several lines, the command continues with the
    CLIST continuation character #cmd("+") at the end of each line but the
    last; the instructions are still one line to REXX.],
)

#cmd("RX") and #cmd("REXX") are the same program; the _BREXX/370 User's
Guide_ describes their options ("Running REXX Programs").

```
REXX -              +
  CALL LISTALC('PRINT')
```

#tab(caption: [The commands of CMDLIB])[
  #table(columns: (0.9in, 1.5in, 1fr),
    [Command], [Runs], [Does],
    [#cmd("EOT")], [sample #cmd("EOT")], [interactive REXX, mixed case],
    [#cmd("LA")], [RXLIB #cmd("LISTALC")], [lists the allocations],
    [#cmd("NJE38DIR")], [RXLIB #cmd("NJE38DIR")], [browses the NJE38 spool],
    [#cmd("REPL")], [sample #cmd("REPL")], [interactive REXX, upper case],
    [#cmd("REXXTRY")], [sample #cmd("REXXTRY")], [interactive REXX, the
      classic REXXTRY],
    [#cmd("TODAY")], [instructions], [shows the date and time],
    [#cmd("TT")], [sample #cmd("MTT")], [shows the master trace table],
    [#cmd("USERS")], [sample #cmd("WHO")], [lists the TSO users],
    [#cmd("WHO")], [sample #cmd("WHO")], [lists the TSO users],
    [#cmd("WHOAMI")], [instructions], [shows the user ID],
  )
] <lib-tsocmd-tab>

== The Commands <lib-tsocmd-cmds>

=== EOT <lib-tsocmd-eot>

#idx("EOT command")
```
 RX EOT NOSTAE
```
Interactive REXX. The exec EOT of the sample library shows the version,
then reads one line at a time from the terminal and runs it with
#cmd("INTERPRET"), as typed, without translation to upper case. A command
error or a syntax error is reported and the next line is read.
#cmd("EXIT") ends it.

=== LA <lib-tsocmd-la>

#idx("LA command")
```
REXX -              +
CALL LISTALC('PRINT')
```
Lists the DD names of the TSO session and the data sets allocated to
them, one line each, with the RXLIB function LISTALC
(@lib-rxlib-listalc).

```
LA
/* STDOUT    *terminal
   RXLIB     BREXX.RXLIB
   SYSPROC   SYS1.CMDPROC     ... */
```

=== NJE38DIR <lib-tsocmd-nje38dir>

#idx("NJE38DIR command")#idx("NJE38", "spool browser")
```
REXX -              +
       CALL NJE38DIR
```
Browses the spool of NJE38, the network job entry of MVS 3.8j, on a
formatted list (FMTLIST, @lib-fssmenu). It runs the RXLIB member NJE38DIR,
which allocates the NJE38 spool data set (@lib-rxlib-nje38dsn) and reads
its directory with the TSO command #cmd("IRXNJE38"). NJE38DIR needs a TSO
terminal and the privileged mode: when #cmd("SYSVAR('SYSAUTH')") is
#cmd("0") it ends with a message.

Each line of the list is a file in the spool. By default the list shows
the files for the user's own ID.

#deflist(width: 1.2in,
  [#cmd("B")], [Line command: browse the content of the file. It is
    received into a temporary data set first; for a partitioned data set,
    its directory is shown.],
  [#cmd("S")], [Line command: show the details of the file. #cmd("I") does
    the same.],
  [#cmd("R")], [Line command: receive the file into a data set, whose name
    is asked for.],
  [#cmd("P")], [Line command: purge the file from the spool.],
  [#cmd("M")], [Line command: send a message to the sender of the file.],
  [#cmd("STATUS *")], [Primary command: show all files of the spool;
    #cmd("STATUS ")#var("userid") those of one user.],
  [#cmd("REFRESH")], [Primary command: read the directory again.],
  [#cmd("RESET")], [Primary command: reset the colours.],
  [#cmd("HELP")], [Primary command: list these commands.],
)

=== REPL <lib-tsocmd-repl>

#idx("REPL command")
```
 RX REPL NOSTAE
```
Interactive REXX, like EOT, with two differences: each line is
translated to upper case before it runs, so a string typed in quotes
comes out in upper case, and the prompt is #cmd("BREXX"). #cmd("EXIT")
ends it. (The member is the file #cmd("REPL.cllst") in the source
tree, where the others end in #cmd(".clist")\; a defect, brexx370 issue
386.)

=== REXXTRY <lib-tsocmd-rexxtry>

#idx("REXXTRY command")
```
 RX REXXTRY NOSTAE
```
The classic REXXTRY. It reads instructions with #cmd("PARSE PULL") after
the prompt #cmd("Rexxtry;") and runs them; an error, a syntax error and
an attention interrupt (#cmd("HALT")) are reported and it starts again.
#cmd("EXIT") ends it. Given an instruction as argument, the exec REXXTRY
runs only that and ends; the CLIST passes none.

=== TODAY <lib-tsocmd-today>

#idx("TODAY command")
```
 REXX - SAY DATE(); SAY TIME()
```
Shows today's date and the time.

```
TODAY
/* 8 Oct 2026
   14:05:31 */
```

=== TT <lib-tsocmd-tt>

#idx("TT command")#idx("master trace table", "display")
```
RX MTT
```
Shows the master trace table, the recent console messages of the system,
on a formatted screen that refreshes itself. It runs the exec MTT of the
sample library, which is the same application as the RXLIB member MTTLOG
(@lib-rxlib-mttlog) with a refresh of 3 seconds: a command typed on the
screen is issued as an operator command, and #cmd("@")#var("text") is
sent as a #cmd("WTO"). It needs a TSO terminal and the authority for
console commands.

=== USERS and WHO <lib-tsocmd-who>

#idx("USERS command")#idx("WHO command")
```
 RX WHO
```
Both CLISTs run the exec WHO of the sample library, which lists the TSO
users logged on. It scans the address space vector table and writes, for
each TSO address space, a sequence number, a value from the ASCB (at
offset 200) and the user ID.

```
WHO
/* Currently active users:
   -----------------------
   01 ...  IBMUSER */
```

=== WHOAMI <lib-tsocmd-whoami>

#idx("WHOAMI command")
```
REXX -              +
    SAY USERID()
```
Shows the user ID of the session.
