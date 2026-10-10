#import "../bookmaster/bookmaster.typ": *

= The Sample Library <lib-samples>

#idx("sample library")#idx("SAMPLES")
BREXX/370 comes with a library of sample execs. The jobs of the JCL
library name it #cmd("BREXX.CURRENT.SAMPLES"); the examples below use
#cmd("BREXX.SAMPLES"), as release 3.0 drops the version from its data set
names. Change #cmd("SLIB=") in a job to the name on your system.
They show the functions of BREXX/370 at work, test an installation, and
include some classic REXX programs. Some members are not execs but input
data for other samples. This chapter lists them and shows how to run
them.

== Running a Sample <lib-samples-run>

#idx("sample library", "running a sample")
*At a TSO terminal*, run a sample with #cmd("RX") and its name in
quotes, or by its name alone when the sample library is allocated to
#cmd("SYSEXEC") or #cmd("SYSUEXEC") (_BREXX/370 User's Guide_, "Running
REXX Programs"):

```
RX 'BREXX.SAMPLES($VERSION)'
RX $DATE
```

*In a batch job*, run it with one of the procedures of the BREXX/370
PROCLIB, naming the sample in #cmd("EXEC=") and the library in
#cmd("SLIB="); #cmd("LIB=") names RXLIB:

#deflist(width: 1.2in,
  [#cmd("RXTSO")], [Runs the exec under TSO in batch (#cmd("IKJEFT01")).
    Output goes to #cmd("SYSTSPRT"). Use it for samples that issue TSO
    commands or allocate data sets.],
  [#cmd("RXBATCH")], [Runs the exec without TSO (#cmd("PGM=BREXX")).
    Output goes to #cmd("STDOUT").],
)

```
//WTOTEST  JOB (BREXX370),CLASS=A,MSGCLASS=H,REGION=8192K
//REXX     EXEC RXTSO,EXEC='$WTO',SLIB='BREXX.SAMPLES',
//         LIB='BREXX.RXLIB'
```

#note[*To be confirmed:* the data set names of release 3.0 (the
installation by hand unpacks the library as #cmd("SAMPLE")) and the
#cmd("LIB=") defaults of the procedures; the procedures in the source tree
still name #cmd("BREXX.CURRENT.RXLIB") and #cmd("BREXX.V2R5M3.RXLIB")
(@lib-intro-alloc).]

#idx("JCL library", "sample jobs")
The JCL library of BREXX/370 holds ready jobs for some samples:
#cmd("DATE#B") runs #cmd("DATE#T") with RXBATCH; #cmd("DUMP#T"),
#cmd("ETIME#T"), #cmd("PDSDIR#T"), #cmd("RXMSG#T"), #cmd("SORT#T"),
#cmd("STEM#T"), #cmd("VERSIO#T"), #cmd("WAIT#T") and #cmd("WTO#T") run
samples with RXTSO. #cmd("STUDENTC") defines and loads the VSAM cluster
#cmd("BREXX.VSAM.STUDENTM") for the #cmd("@") samples; its
#cmd("VOLUMES(PUB013)") must be changed to a volume of your system.
#cmd("STUDENTI"), #cmd("STUDENTK") and #cmd("STUDENTN") run the
#cmd("@") samples in batch.

#idx("REXXDSN")
*Samples that read members of their own library.* Many samples open a
data member of the sample library, such as #cmd("LLDATA") or
#cmd("HOUSING"), as #cmd("MVSVAR('REXXDSN')")#cmd("'(LLDATA)'"), the
library the exec was read from. They must be run from the sample library
itself, not from a copy elsewhere without the data members. The table
marks them "own library".

*Names.* A sample may have the name of a function. #cmd("RX JESQUEUE")
runs the sample JESQUEUE, a JES2 menu; #cmd("JESQUEUE()") called from an
exec runs the RXLIB function JESQUEUE (@lib-rxlib-jesqueue). The same holds
for #cmd("LISTALC") and, against the functions built into the
interpreter, for #cmd("FIFO"), #cmd("LIFO"), #cmd("IPLDATE") and the
string-array and linked-list samples.

The column "Needs" of the tables names what a sample requires besides
BREXX/370: #cmd("TSO") (TSO commands, so RXTSO in batch), a TSO
#cmd("terminal") (formatted screens), #cmd("VSAM") (the cluster of
#cmd("STUDENTC")), #cmd("console") (the authority for operator commands),
#cmd("TCP/IP") (TCP/IP in Hercules), #cmd("SVC244") (the privilege
that #cmd("LISTVOLS") needs, _BREXX/370 Reference_), and #cmd("own
library").

== Basic Functions: the \$ Samples <lib-samples-dollar>

#idx("sample library", "$ samples")
The members whose names begin with #cmd("$") show single functions of
BREXX/370.

#tab(caption: [The \$ samples])[
  #table(columns: (1.0in, 1fr, 0.9in),
    [Member], [Purpose], [Needs],
    [#cmd("$ABEND")], [Ends the exec with #cmd("ABEND(42)").], [],
    [#cmd("$DATE")], [Calls #cmd("DATE") with many input and output
      formats.], [],
    [#cmd("$DATETIM")], [Converts a #cmd("DATETIME") time stamp and
      back.], [],
    [#cmd("$DSINFO")], [Reports #cmd("LISTDSI") information for data sets
      and DD names.], [],
    [#cmd("$DSORG")], [Shows the organisation of three data sets with
      #cmd("LISTDSI").], [],
    [#cmd("$ETIME")], [Shows #cmd("TIME") in several formats.], [],
    [#cmd("$PDSDIR")], [Lists the directory of #cmd("SYS2.PROCLIB") with
      #cmd("DIR").], [],
    [#cmd("$RXMSG")], [Writes messages with RXMSG at several
      #cmd("RXMSLV") levels.], [],
    [#cmd("$RXSORT")], [Times the four methods of RXSORT on 500 random
      entries.], [],
    [#cmd("$TCPSERV")], [A TCP server on port 3205 built with TCPSF.],
      [TCP/IP],
    [#cmd("$VERSION")], [Shows #cmd("VERSION()") and
      #cmd("VERSION('FULL')").], [],
    [#cmd("$WAIT")], [Waits the seconds given as argument, 42 without
      one.], [],
    [#cmd("$WTO")], [Writes a message to the console with #cmd("WTO").],
      [],
  )
] <lib-samples-dollar-tab>

== Formatted Screens: the \# Samples <lib-samples-hash>

#idx("sample library", "# samples")
The members whose names begin with #cmd("#") use the formatted-screen
functions (@lib-fssmenu) and need a TSO terminal; #cmd("#VSAMDAT") is the
exception.

#tab(caption: [The \# samples])[
  #table(columns: (1.0in, 1fr, 0.9in),
    [Member], [Purpose], [Needs],
    [#cmd("#BROWSE")], [Shows the allocations of the session (LISTALC) in
      FMTLIST.], [terminal],
    [#cmd("#FSS1COL")], [An input screen with nine fields in one column,
      built by FMTCOLUM.], [terminal],
    [#cmd("#FSS2COL")], [The same in two columns.], [terminal],
    [#cmd("#FSS3COL")], [The same in three columns.], [terminal],
    [#cmd("#FSS4COL")], [The same in four columns.], [terminal],
    [#cmd("#FSS4CLX")], [Four columns, with a call-back routine that
      checks the input.], [terminal],
    [#cmd("#LOGON")], [A logon-style screen with user ID, password and
      command fields, built with the FSS functions.], [terminal],
    [#cmd("#SELMEM")], [A screen that asks for a member name and a debug
      flag.], [terminal],
    [#cmd("#TSOAPPL")], [A menu application with terminal, system, user,
      date and time fields.], [terminal, TSO],
    [#cmd("#VSAMDAT")], [Not an exec: the student records that
      #cmd("@STUDENI") loads into the VSAM cluster.], [],
  )
] <lib-samples-hash-tab>

== VSAM: the \@ Samples <lib-samples-at>

#idx("sample library", "@ samples")#idx("VSAM", "samples")
The members whose names begin with #cmd("@") work on the VSAM cluster
#cmd("BREXX.VSAM.STUDENTM"), which the job #cmd("STUDENTC") defines.
They use #cmd("ADDRESS TSO") to allocate it and the #cmd("VSAMIO")
command to read and write it.

#tab(caption: [The \@ samples])[
  #table(columns: (1.0in, 1fr, 0.9in),
    [Member], [Purpose], [Needs],
    [#cmd("@STUDENI")], [Loads the records of #cmd("#VSAMDAT") into the
      cluster.], [VSAM, TSO, own library],
    [#cmd("@STUDENK")], [Reads students by key.], [VSAM, TSO],
    [#cmd("@STUDENL")], [A student information screen: search by name
      with FMTCOLUM, the hits in FMTLIST; uses DCL.], [VSAM, TSO,
      terminal],
    [#cmd("@STUDENN")], [Reads all students whose key begins with a
      prefix, with #cmd("LOCATE") and #cmd("READ NEXT").], [VSAM, TSO],
  )
] <lib-samples-at-tab>

== Other Samples <lib-samples-other>

#idx("sample library", "other samples")
The other members are grouped here by subject. Several come from the
original BREXX of Vasilis Vlachoudis and from the REXX community; their
authors are named in the members.

#tab(caption: [Arrays, lists and stems])[
  #table(columns: (1.0in, 1fr, 0.9in),
    [Member], [Purpose], [Needs],
    [#cmd("AFLOAT")], [Creates and lists a float array.], [],
    [#cmd("AINT")], [Creates and lists an integer array.], [],
    [#cmd("FIFO")], [A first-in first-out queue with #cmd("FIFO").], [],
    [#cmd("LIFO")], [A last-in first-out stack with #cmd("LIFO").], [],
    [#cmd("BUFFER")], [Pushes and queues lines in stack buffers and shows
      #cmd("QUEUED").], [],
    [#cmd("LLCOPY")], [Copies a linked list.], [],
    [#cmd("LLDEL")], [Deletes an entry of a linked list.], [own library],
    [#cmd("LLREAD")], [Reads a linked list from a data set and writes it
      back.], [own library],
    [#cmd("LLSETX")], [Steps through a linked list.], [own library],
    [#cmd("LLSORT")], [Sorts a linked list.], [own library],
    [#cmd("LLSORT2")], [Sorts a linked list on a column.], [own library],
    [#cmd("LL2STEM")], [Copies a linked list into a stem.], [],
    [#cmd("STEM2LL")], [Copies a stem into a linked list.], [],
    [#cmd("STEM2SX")], [Copies a stem into a string array and times
      it.], [],
    [#cmd("S2STEM")], [Copies a string array into a stem and times it.],
      [],
    [#cmd("S2HASH")], [Builds hashes from the lines of a string
      array.], [own library],
    [#cmd("SAPPEND")], [Appends part of a string array to itself.],
      [own library],
    [#cmd("SCHANGE")], [Changes strings in a string array.], [own library],
    [#cmd("SDROP")], [Drops the lines that contain given strings.],
      [own library],
    [#cmd("SKEEP")], [Keeps the lines that contain any of given
      strings.], [own library],
    [#cmd("SKEEPAND")], [Keeps the lines that contain all given
      strings.], [own library],
    [#cmd("SNUMBER")], [Numbers the lines of a string array.],
      [own library],
    [#cmd("SSEARCH")], [Searches a string array.], [own library],
    [#cmd("SSELECT")], [Selects lines into a new string array.],
      [own library],
    [#cmd("SSORT")], [Sorts a string array on a column.], [own library],
    [#cmd("SSUBSTR")], [Cuts the lines of a string array from a
      column.], [own library],
    [#cmd("LSELECT")], [Extracts data from a line of a string array.],
      [],
    [#cmd("GETCMT")], [Reads data held in a comment of the exec into a
      stem.], [],
  )
] <lib-samples-arrays-tab>

#tab(caption: [System, data sets and console])[
  #table(columns: (1.0in, 1fr, 0.9in),
    [Member], [Purpose], [Needs],
    [#cmd("CONSOLE")], [Shows the reply to #cmd("D A,L") with
      RXCONSOL.], [console],
    [#cmd("IPLDATE")], [Estimates the date of the last IPL from the MVS
      up time.], [],
    [#cmd("JES2")], [The JES2 spool queue and viewer (@lib-apps).],
      [terminal, TSO, console],
    [#cmd("JESQUEUE")], [A JES2 primary option menu on a formatted
      screen.], [terminal,
      console],
    [#cmd("JESVIEW")], [Writes the JES2 queue (JESQUEUE function).],
      [console],
    [#cmd("LISTALC")], [Lists the allocations with LISTALC.], [],
    [#cmd("LISTALL")], [Lists all data sets by their VTOCs (LSTALL).],
      [TSO, SVC244],
    [#cmd("LISTNCAT")], [Lists the data sets that are not catalogued
      (LSTNCAT).], [TSO, SVC244],
    [#cmd("LOCATE")], [Writes the data set #cmd("LOCATE.DATA"): every data
      set and member found through the VTOCs.], [TSO],
    [#cmd("LOCPAN")], [Queries #cmd("LOCATE.DATA") on a formatted
      screen.], [terminal, TSO],
    [#cmd("LOCRPT")], [A report from #cmd("LOCATE.DATA").], [TSO],
    [#cmd("LSTVOL")], [A volume list in FMTLIST, with the data sets of a
      volume and line commands such as EDIT.], [terminal, TSO, SVC244],
    [#cmd("LVOLMVS")], [Space statistics of all volumes.], [TSO, SVC244],
    [#cmd("LVOLUME")], [The details of one volume (#cmd("LISTVOL")).], [TSO],
    [#cmd("LVTOC")], [Lists the VTOC of a volume.], [TSO],
    [#cmd("MTT")], [The master trace table on a self-refreshing screen;
      the TSO command #cmd("TT").], [terminal, console],
    [#cmd("MTTSCANT")], [Watches the trace table for LOGON and LOGOFF with
      MTTSCAN.], [console],
    [#cmd("MTTSTOP")], [Stops MTTSCAN with the #cmd("WTO") #cmd("TTSCAN
      STOP").], [],
    [#cmd("NJECMD")], [Shows the files in the NJE38 spool with
      NJE38CMD.], [console],
    [#cmd("WHO")], [Lists the TSO users; the TSO commands #cmd("WHO") and
      #cmd("USERS").], [],
    [#cmd("WHOAMI")], [Shows the user ID.], [],
  )
] <lib-samples-system-tab>

#tab(caption: [Applications, servers and data])[
  #table(columns: (1.0in, 1fr, 0.9in),
    [Member], [Purpose], [Needs],
    [#cmd("CORELT")], [The correlation matrix of #cmd("HOUSING") (MATIN,
      MCOREL).], [own library],
    [#cmd("REGRESST")], [A linear regression with REGRESSN.], [],
    [#cmd("DIFFT")], [Compares #cmd("HOUSING") and #cmd("HOUSING2") with
      RXDIFF (@lib-apps).], [own library],
    [#cmd("DBWORLD")], [Loads the key/value sample database from
      #cmd("COUNTRY") and #cmd("CITIES") (@lib-kv).], [own library],
    [#cmd("KCOUNTRY")], [Browses the countries of the key/value database
      in FMTLIST.], [terminal, TSO],
    [#cmd("KVSAMP1")], [Writes and reads entries of the key/value
      database.], [],
    [#cmd("FMTOPBOT")], [FMTLIST with lines of your own above and below
      the list.], [terminal],
    [#cmd("FORMULA")], [A formula editor and calculator on a formatted
      screen.], [terminal],
    [#cmd("XMAS")], [Christmas and Chanukkah greetings on a formatted
      screen.], [terminal],
    [#cmd("HTTPD")], [A small HTTP server on port 8080.], [TCP/IP],
    [#cmd("FSVR")], [A file server on port 4711.], [TCP/IP],
    [#cmd("SGENTRY")], [Starts the Stargate client menu (@lib-apps).],
      [terminal, TCP/IP],
    [#cmd("SGSTART")], [Starts a Stargate server; put in your own
      address.], [TCP/IP],
    [#cmd("SGTCPLST")], [Not an exec: the list of Stargate servers, to
      tailor.], [],
    [#cmd("STARDATE")], [Calls STDATE with several formats.], [],
    [#cmd("COUNTRY")], [Not an exec: countries, capitals and continents,
      input of #cmd("DBWORLD").], [],
    [#cmd("CITIES")], [Not an exec: cities, countries and populations,
      input of #cmd("DBWORLD").], [],
    [#cmd("HOUSING")], [Not an exec: housing data, input of
      #cmd("CORELT") and #cmd("DIFFT").], [],
    [#cmd("HOUSING2")], [Not an exec: a changed copy of #cmd("HOUSING"),
      input of #cmd("DIFFT").], [],
    [#cmd("LLDATA")], [Not an exec: a list of songs, input of the list
      and string-array samples.], [],
    [#cmd("LLTEMP")], [Not an exec: a copy of #cmd("LLDATA").], [],
  )
] <lib-samples-apps-tab>

#tab(caption: [Interactive REXX, programs and games])[
  #table(columns: (1.0in, 1fr, 0.9in),
    [Member], [Purpose], [Needs],
    [#cmd("EOT")], [Interactive REXX, mixed case; the TSO command
      #cmd("EOT").], [],
    [#cmd("REPL")], [Interactive REXX, upper case; the TSO command
      #cmd("REPL").], [],
    [#cmd("REXXTRY")], [The classic REXXTRY; the TSO command
      #cmd("REXXTRY").], [],
    [#cmd("REXXCPS")], [Measures the REXX clauses per second.], [],
    [#cmd("ALLCHARS")], [Shows all characters of the BANNER font.], [],
    [#cmd("BANNER")], [Writes its argument in large letters.], [],
    [#cmd("TB")], [The time in large digits.], [],
    [#cmd("QT")], [The time in English words; #cmd("?") explains
      it.], [],
    [#cmd("BASE64")], [Encodes and decodes a string in base64.], [],
    [#cmd("CODE")], [Encodes and decodes a file with a key.], [],
    [#cmd("FACTRIAL")], [Factorials, computed recursively.], [],
    [#cmd("PRIMES")], [The sieve of Eratosthenes.], [],
    [#cmd("SUNDARAM")], [The sieve of Sundaram, with an integer
      array.], [],
    [#cmd("PLOT3D")], [Plots one of six functions in three
      dimensions.], [],
    [#cmd("SINPLOT")], [Plots a sine curve.], [],
    [#cmd("ANIMAL")], [The animal guessing game.], [],
    [#cmd("AWARI")], [The board game Awari.], [],
    [#cmd("BLOCK")], [A program that uses only REXX keywords as
      variable names.], [],
    [#cmd("BUZZWORD")], [Generates buzzword phrases.], [],
    [#cmd("POETRY")], [Generates random lines of poetry.], [],
    [#cmd("MONDAY")], [A word game written for VM/CMS. It brings its own
      #cmd("CP") and #cmd("VMFCLEAR") routines.], [terminal],
  )
] <lib-samples-progs-tab>

The directory of the samples also holds BUILD.REXX, a note on the last
synchronisation with the source repository, and README.md; neither is a
sample.
