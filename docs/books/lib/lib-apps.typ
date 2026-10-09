#import "../bookmaster/bookmaster.typ": *

= Applications <lib-apps>

#idx("applications")
This chapter describes some larger programs written with BREXX/370: a
compare of two data sets, a copy service, a JES2 spool viewer and a data
exchange between MVS systems. They show what can be built with the library;
they are not all complete or tested in every situation. The functions are
RXLIB members and can be called from any exec; the programs that are
started directly are members of the SAMPLES library.

== RXDIFF: Comparing Two Data Sets <lib-apps-rxdiff>

#idx("RXDIFF")
```
RXDIFF(new-dsn, old-dsn [, [mode] [, DETAILS]])
```
Compares the data set #var("new-dsn") with #var("old-dsn"), from which it
is taken to have evolved, and returns the number of a string array that
holds the result. Both names are fully qualified, without quotes, and may
name members; they are translated to uppercase. If a data set does not
exist, RXDIFF ends with a message.

#deflist(width: 1.2in,
  [#var("mode")], [#cmd("ALL"): list every line, changed or not. Any other
    value, or none: list only the inserted and deleted lines.],
  [#cmd("DETAILS")], [Also write the steps of the compare, with time
    stamps, into the result.],
)

Each line of the result begins with the line numbers in the new and the old
data set. #cmd("**ins") marks a line that exists only in the new data set,
#cmd("**del") one that exists only in the old one. The result ends with the
number of deleted, inserted and moved lines. Display it with
#cmd("FMTLIST") (@lib-fssmenu-fmtlist) and free it afterwards with
#cmd("SFREE"):

```
file1 = 'USER.EXEC(DBDOC1)'
file2 = 'USER.EXEC(DBDOC2)'
rarray = RXDIFF(file1, file2)
buffer.0 = 'ARRAY' rarray
CALL FMTLIST ,, 'New    Old     'file1'<-'file2, 'Lino   Lino    Lines'
CALL SFREE rarray
```
```
New    Old     USER.EXEC(DBDOC1)<-USER.EXEC(DBDOC2)
Lino   Lino    Lines
Differences of USER.EXEC(DBDOC1)(new) with USER.EXEC(DBDOC2)(old)
**del  00012   call dblist('ONLY',"Wa")
**del  00013   call dblist('CONTAINS',"265")
**del  00014   say "CLOSE "DBCLOSE()
00012  **ins   say "CLOSE "DBCLOSE()
deleted  lines 3
inserted lines 1
moved    lines 0
```

The sample #cmd("DIFFT") compares two members of its own library with
#cmd("ALL") and #cmd("DETAILS") and writes the result with #cmd("SAY").

== RXCOPY: Copying a Data Set <lib-apps-rxcopy>

#idx("RXCOPY")
```
RXCOPY(source-dsn, target-dsn [, [volume] [, REPLACE]])
```
Copies the data set #var("source-dsn") to #var("target-dsn") with the MVS
utilities: a sequential data set with the TSO command #cmd("REPRO"), a
partitioned one with #cmd("IEBCOPY"). Both names are fully qualified,
without quotes. RXCOPY creates the target with the organization, record
format, record length and block size of the source, about one and a half
times the space the source uses, and the directory blocks scaled the same
way.

#deflist(width: 1.2in,
  [#var("volume")], [The volume of the target. Without it, MVS chooses
    one.],
  [#cmd("REPLACE")], [Delete an existing target first. Without it, an
    existing target ends RXCOPY with return code 8. The first three
    letters are enough.],
)

RXCOPY reports what it does with #cmd("SAY"), and for a partitioned data
set also the #cmd("IEBCOPY") listing, which it keeps meanwhile in the data
set #var("userid")#cmd(".TEMP.RXCOPY.SYSPRINT"). It returns #cmd("8") when
an argument is missing, the source does not exist or is neither sequential
nor partitioned, or the target cannot be created.

```
CALL RXCOPY 'USER.TEMP80', 'USER1.TEMP80', , 'REPLACE'
```
```
------------------------------------------------------------------------
RXCOPY USER.TEMP80 INTO USER1.TEMP80 REPLACE
------------------------------------------------------------------------
DSN USER.TEMP80 is partitioned, invoke IEBCOPY
Target Dataset 'USER1.TEMP80' has been removed, due to remove option
Create 'USER1.TEMP80' with DSORG=PO,RECFM=FB,UNIT=SYSDA,LRECL=80,...
'USER1.TEMP80' successfully created
Prepare IEBCOPY
IEBCOPY completed, RC=0 0
...
```

#note[*A defect* (brexx370 issue 386): for a partitioned data set the
value returned is that of deleting the temporary listing, not the return
code of #cmd("IEBCOPY")\; read the listing. *To be confirmed:* the old documentation also says that
#cmd("IEBCOPY") must run authorized, which it is under plain TSO but must
be made under ISPF.]

== The JES2 Spool Viewer <lib-apps-jes2>

#idx("JES2 spool viewer")#idx("JESQUEUE")
The spool viewer is a menu that lists the jobs of the JES2 queues and acts
on them. Start it from TSO with

```
RX 'hlq.SAMPLES(JESQUEUE)'
```

It gets its information from operator commands (#cmd("$DA,ALL"),
#cmd("$DN"), #cmd("D A,L"), #cmd("D U,DASD,ONLINE")), whose replies it
reads back from the master trace table, and acts on jobs with the TSO
commands #cmd("OUTPUT") and #cmd("CANCEL"). The user must therefore be
allowed to issue console commands.

```
 --------------------------- JES2 Primary Option Menu --------------------------
 Option ===>

          Type an Option and press Enter"

          LOG        Display the System Log
          DA         Display Active Users of the System
          I          Display Jobs in the JES2 Input Queue
          A          Display Jobs Executing
          O          Display Jobs in the JES2 Output Queue
          H          Display Jobs in the JES2 Held Queue
          SYS        Display System Details
          DASD       Display Available Volumes
```

#deflist(width: 1.2in,
  [#cmd("LOG")], [The system log (master trace table), with the RXLIB
    member #cmd("MTTLOG").],
  [#cmd("DA")], [The TSO users logged on.],
  [#cmd("I")], [Jobs awaiting execution.],
  [#cmd("A")], [Executing batch jobs. The line command #cmd("S") shows the
    trace table entries of the job.],
  [#cmd("O"), #cmd("H")], [Both show the spool queue as a list, with the
    sample #cmd("JES2") (below).],
  [#cmd("SYS")], [User, system name, CPU, NJE38 version, the time MVS has
    been up, and the active jobs, started tasks and TSO users.],
  [#cmd("DASD")], [The online DASD units.],
  [#cmd("ISPF"), #cmd("SPF")], [Switch to ISPF.],
)

PF3 or PF4 ends the menu. The spool queue list is an #cmd("FMTLIST")
screen with these line commands:

#deflist(width: 1.2in,
  [#cmd("S")], [Copy the output of the job to
    #var("userid")#cmd(".JES2.TEMP.OUTLIST") and browse it with the TSO
    command #cmd("REVIEW").],
  [#cmd("SJ")], [Rebuild the JCL of the job from its output and edit it
    with the TSO command #cmd("REVED"). In-stream data cannot be recovered
    and is marked.],
  [#cmd("P")], [Purge the output; cancel the job if it is running.],
  [#cmd("O")], [Move the output to the class typed in the second line
    area.],
  [#cmd("XDC")], [Keep the output in the data set
    #var("userid")#cmd(".JES2.")#var("jobname")#cmd(".")#var("jobid")#cmd(".OUTLIST").],
)

The primary command #cmd("REFRESH") reads the queue again.

The list itself comes from the RXLIB function #cmd("JESQUEUE()"), which an
exec can call on its own: it returns a string array with one line per job
(name, job id, queue, status), sorted, or #cmd("-8") when it finds no spool
information.

The menu calls the sample #cmd("JES2") as an external routine. Started
with #cmd("RX") from the SAMPLES library, it finds #cmd("JES2") there,
in the library of the main exec (_BREXX/370 User's Guide_, "Calling an
External Routine"); it need not be copied. #cmd("REVIEW") and
#cmd("REVED") are TSO commands that do not come with BREXX/370.

== Stargate: Data Exchange Between MVS Systems <lib-apps-stargate>

#idx("Stargate")#idx("STARGATE")
Stargate exchanges data sets, jobs, messages and information between MVS
systems over TCP/IP. One system runs the Stargate server; on another, a TSO
user runs the Stargate client and works with menus. It uses the TCP/IP
functions of BREXX/370 (_BREXX/370 Reference_, "TCP/IP").

#idx("Stargate", "logon key")
*The logon key.* A client must log on to the server with a key that the
operator of the server chooses. Set it with #cmd("SETG") before the server
starts; without one, nobody can log on:

```
CALL SETG 'SG_LOGONPW', 'your-key'
```

The client sends the key from the same global variable,
#cmd("GETG('SG_LOGONPW')"), or, in the menus of #cmd("STARGFSS"), the key
the user types on the logon screen. A client that can log on can submit
jobs, run REXX execs and read and write data sets with the authority of the
user the server runs under: choose the key accordingly, and run a server
only where its port is reachable by the clients that should use it.

=== Starting the Server <lib-apps-sgserver>

```
rc = STARGATE('RECEIVE', , port)
SAY 'Stargate ended with RC='rc
```
The server listens on #var("port") (the sample #cmd("SGSTART") uses 3205)
until it is told to stop. The second argument is not used by the server.
Data sets that a client delivers are written under the user id of the
server.

The server ends after one request when the calling exec sets the
variable #cmd("stargate_keepAlive") to a value other than #cmd("1");
#cmd("STARGATE") sees the variables of its caller.

=== The Client <lib-apps-sgclient>

The client needs a list of the servers it may connect to. Copy the sample
#cmd("SGTCPLST") to #var("userid")#cmd(".EXEC(SGTCPLST)") and enter one
server per line; lines containing #cmd(";;") are comments:

```
;; IP-ADDRESS                  PORT   comment
   mvs1.example.org            3205   my system 1
   mvs2.example.org            3205   my system 2
```

Without that member the client ends with a message. Start the client with

```
CALL STARGFSS
```
as the sample #cmd("SGENTRY") does. The first screen shows the systems of
the list, each marked #cmd("ACTIVE") or #cmd("INACTIVE") after a trial
connection; select one, and after the logon the selection menu offers:

#deflist(width: 1.2in,
  [#cmd("1")], [Send a message to a TSO user on the server.],
  [#cmd("2")], [Deliver a data set to the server.],
  [#cmd("3")], [Select members of a local PDS and deliver them.],
  [#cmd("4")], [Receive a data set from the server.],
  [#cmd("5")], [Receive the member list of a PDS on the server and select
    members.],
  [#cmd("6")], [Compare the members of a PDS on the server and here by
    their hash.],
  [#cmd("7")], [Transfer a job and submit it on the server.],
  [#cmd("8")], [Retrieve the output queue of the server.],
  [#cmd("9")], [Retrieve a #cmd("LISTCAT") from the server.],
  [#cmd("10")], [Retrieve system information of the server.],
  [#cmd("HB")], [Check that the server is alive.],
)

The menu also accepts #cmd("16"), which connects the server to a third
system, and #cmd("XX"), which shuts the server down. PF3 or PF4 returns.

#idx("SHUTD")
A server can also be stopped from TSO with the command #cmd("SHUTD")
#var("host") \[#var("port")\], where #var("port") defaults to 3205.

=== Calling STARGATE from an Exec <lib-apps-sgcall>

```
STARGATE(mode, ip-address, port [, commands])
```
#var("mode") is #cmd("RECEIVE") (the server, above) or #cmd("SEND")\; the
first three letters are enough. With #cmd("SEND"), #var("commands") are
Stargate commands, separated by #cmd("\\"), or #cmd("$$$QUEUE")
#var("stem") to take them from #var("stem")#cmd("1") to
#var("stem")#cmd("0"). The first command must be the logon; the client
member #cmd("STARGFSS") shows how it and the other commands are built.

#note[*To be confirmed:* the Stargate commands (the words beginning with
#cmd("$$$") in the member #cmd("STARGATE")) were not documented by their
author.]
