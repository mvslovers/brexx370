#import "../bookmaster/bookmaster.typ": *

= TSO Functions <ext-tso>

#idx("TSO function")
These functions answer questions about data sets, allocations, volumes
and the environment, in the way the TSO/E REXX functions of the same
names do. Despite the chapter title, most of them work in batch as well
as in TSO:

- #cmd("SYSDSN"), #cmd("LISTDSI"), #cmd("SYSALC"), #cmd("SYSVAR") and
  #cmd("MVSVAR") work everywhere; some #cmd("SYSVAR") values need TSO.
- #cmd("LISTDSIX"), #cmd("LISTVOL") and #cmd("VTOC") read the VTOC
  through the TSO command #cmd("IRXVTOC"), so they need TSO, in the
  foreground or in batch under #cmd("IKJEFT01").
- #cmd("LISTVOLS") needs the #cmd("SVC244") privilege and Hercules.
- #cmd("OUTTRAP") and #cmd("ARRAYGEN") need TSO; outside it they end
  in error 40.

A data set name is given as in TSO: in apostrophes when it is fully
qualified, else the TSO prefix is put in front of it. Because the
apostrophes must reach the function, enclose the whole name in double
quotes: #cmd("\"'IBMUSER.TEST.DATA'\"").

The quick variants #cmd("LISTDSIQ") and #cmd("TSTCAT") are described with
the data set functions (@ext-dataset-listdsiq, @ext-dataset-tstcat).

== Data Sets <ext-tso-datasets>

=== SYSDSN <ext-tso-sysdsn>

#idx("SYSDSN")
```
SYSDSN(dsname)
```
Tells whether a data set, or a member of one, exists and can be used.
The answer is one of the messages TSO/E REXX gives:

#deflist(width: 2.6in,
  [#cmd("OK")], [The data set, or the member, is available.],
  [#cmd("DATASET NOT FOUND")], [The data set is not cataloged, or its
    volume has no such data set.],
  [#cmd("MEMBER NOT FOUND")], [The data set is partitioned and the member
    does not exist.],
  [#cmd("MEMBER SPECIFIED, BUT DATASET IS NOT PARTITIONED")], [A member
    was given for a data set that is not partitioned.],
  [#cmd("PROTECTED DATASET")], [The data set is password protected.],
  [#cmd("VOLUME NOT ON SYSTEM")], [The volume the catalog names is not
    mounted.],
  [#cmd("UNAVAILABLE DATASET")], [Another job holds the data set
    exclusively.],
  [#cmd("ERROR PROCESSING REQUESTED DATASET")], [The catalog or the
    VTOC could not be read, or the data set could not be opened for
    another reason.],
  [#cmd("INVALID DATASET NAME,") #var("dsname")], [The name is partially
    quoted or longer than 44 characters, or its member is not 1 to 8
    characters in parentheses.],
  [#cmd("MISSING DATASET NAME")], [The argument is null.],
)

The checks run in this order: catalog and volume, a member of a data set
that is not partitioned, then an open of the data set or member.

```
x = sysdsn("'IBMUSER.TEST.DATA'")
IF x = 'OK' THEN SAY 'found'
ELSE SAY x                 /* e.g. DATASET NOT FOUND */
```

=== LISTDSI <ext-tso-listdsi>

#idx("LISTDSI")
```
LISTDSI(dsname)
LISTDSI('ddname FILE')
```
Sets variables that describe a data set, named directly or by the DD
name it is allocated to. Returns #cmd("0") if the data set could be
opened, #cmd("16") if not: when it does not exist, the name is not valid,
or the DD name is longer than 8 characters. A second word other than
#cmd("FILE") ends in error 40.

#deflist(width: 1.2in,
  [#cmd("SYSDSNAME")], [Data set name.],
  [#cmd("SYSDDNAME")], [DD name it was opened through.],
  [#cmd("SYSMEMBER")], [Member name, if one was given.],
  [#cmd("SYSVOLUME")], [Volume serial.],
  [#cmd("SYSDSORG")], [#cmd("PS") or #cmd("PO"); #cmd("???") for
    anything else.],
  [#cmd("SYSRECFM")], [#cmd("F"), #cmd("FB"), #cmd("FBM"), #cmd("V"),
    #cmd("VB"), #cmd("VBA"), #cmd("VBM") or #cmd("U"); #cmd("??????")
    for any other format.],
  [#cmd("SYSLRECL")], [Record length.],
  [#cmd("SYSBLKSIZE")], [Block size.],
  [#cmd("SYSRECORDS")], [Number of records of a sequential data set or
    member; #cmd("n/a") for a partitioned data set.],
  [#cmd("SYSSIZE")], [Size in bytes: records × record length for
    #cmd("SYSRECFM") #cmd("F") or #cmd("FB"), else the bytes read (also
    for #cmd("FBM")). For a partitioned data set named without a member,
    the length of its directory.],
  [#cmd("SYSMEMBERS")], [Number of members of a partitioned data set;
    #cmd("n/a") for a sequential one.],
  [#cmd("SYSDIRBLK")], [Always #cmd("n/a").],
)

A partitioned data set named with a member is described as that member,
like a sequential data set.

Unlike TSO/E REXX, #cmd("LISTDSI") sets no space, date or extent
variables; #cmd("LISTDSIX") adds some of them.

```
IF listdsi("'SYS1.MACLIB'") = 0 THEN
  SAY sysdsorg sysrecfm syslrecl sysmembers   /* PO FB 80 ... */
SAY listdsi('RXLIB FILE')                     /* 0 */
```

=== LISTDSIX <ext-tso-listdsix>

#idx("LISTDSIX")
```
LISTDSIX(dsname)
LISTDSIX('ddname FILE')
```
Calls #cmd("LISTDSI") and then reads the data set's entry in the VTOC of
its volume, which sets these variables as well. Returns #cmd("0"),
#cmd("8") if #cmd("LISTDSI") failed, or #cmd("-16") if the VTOC could
not be read (for example outside TSO). A data set that the VTOC listing
does not show also returns #cmd("0"), with none of the variables below
set. Because of the VTOC read it is slower than #cmd("LISTDSI").

#deflist(width: 1.2in,
  [#cmd("SYSTRACKS")], [Allocated tracks.],
  [#cmd("SYSNTRACKS")], [Tracks; see the note below.],
  [#cmd("SYSEXTENTS")], [Number of extents.],
  [#cmd("SYSDSORGX")], [Data set organization, from the VTOC.],
  [#cmd("SYSRECFMX")], [Record format, from the VTOC.],
  [#cmd("SYSLRECLX")], [Record length, from the VTOC.],
  [#cmd("SYSBLKSIZEX")], [Block size, from the VTOC.],
  [#cmd("SYSCREATE")], [Creation date, Julian.],
  [#cmd("SYSREFDATE")], [Date last referenced, Julian.],
  [#cmd("SYSSEQALC")], [Secondary allocation, in #cmd("SYSUNITS").],
  [#cmd("SYSUNITS")], [#cmd("CYLINDERS"), #cmd("TRACKS") or
    #cmd("BLOCKS").],
)

If #cmd("SYSRECFM") from #cmd("LISTDSI") starts with #cmd("?"), it is
replaced by #cmd("SYSRECFMX").

Written in REXX and carried in the load module.

#note[*To be confirmed:* #cmd("SYSNTRACKS") is taken from the column of
the #cmd("IRXVTOC") listing next to the allocated tracks, most likely
the tracks used; the old documentation gave no meaning.]

```
IF listdsix("'IBMUSER.TEST.DATA'") = 0 THEN
  SAY systracks sysextents sysunits     /* e.g. 15 1 TRACKS */
```

=== SYSALC <ext-tso-sysalc>

#idx("SYSALC")
```
SYSALC('DSN', dsname)
SYSALC('DDN', ddname)
```
Reports allocations of the program's address space, read from its TIOT,
in the stem #cmd("_RESULT."), #cmd("_RESULT.0") holding the number of
entries. Call it with #cmd("CALL"); it returns no value.

#deflist(width: 1.2in,
  [#cmd("DSN")], [The DD names to which #var("dsname") is allocated.
    #var("dsname") is the full name, without apostrophes.],
  [#cmd("DDN")], [The data set names allocated to #var("ddname"); more
    than one means a concatenation.],
)

Written in REXX and carried in the load module.

```
CALL sysalc 'DDN', 'SYSUEXEC'
DO i = 1 TO _result.0
  SAY _result.i          /* e.g. IBMUSER.EXEC */
END
CALL sysalc 'DSN', 'BREXX.RXLIB'
SAY _result.0 _result.1  /* e.g. 1 RXLIB */
```

== Command Output <ext-tso-output>

=== OUTTRAP <ext-tso-outtrap>

#idx("OUTTRAP")
```
OUTTRAP(stem [, max [, concat [, skip]]])
OUTTRAP('OFF')
```
Traps the lines that commands write to the terminal into a stem, as
TSO/E REXX does. #cmd("OUTTRAP(")#var("stem")#cmd(")") turns trapping on;
from then on, the output of every command issued with
#cmd("ADDRESS TSO") or #cmd("ADDRESS COMMAND") goes into
#var("stem")#cmd("1"), #var("stem")#cmd("2"), and so on, instead of to
the terminal, and #var("stem")#cmd("0") holds the number of lines. The
stem is filled after each command, so the lines can be used before
trapping is turned off. #cmd("OUTTRAP('OFF')") turns trapping off.

Only what the commands write is trapped. The output of the exec itself,
#cmd("SAY"), #cmd("TRACE") and the interpreter's messages, still goes to
the terminal, as in TSO/E REXX. An exec that is itself run as a command
does have its output trapped.

#deflist(width: 1.2in,
  [#var("stem")], [The name the line numbers are appended to, used as
    given: #cmd("'LINE.'") gives #cmd("LINE.1"), #cmd("'LINE'") gives
    #cmd("LINE1").],
  [#var("max")], [The most lines to keep in all; further lines are
    discarded. #cmd("*") or a blank means no limit (the default).],
  [#var("concat")], [#cmd("CONCAT") (the default): the lines of each
    command are added after those of the commands before.
    #cmd("NOCONCAT"): each command's lines replace those of the one
    before, from #var("stem")#cmd("1").],
  [#var("skip")], [The number of lines to discard before keeping any
    (default 0).],
)

The options apply only to the call that names them: each
#cmd("OUTTRAP") starts again from the defaults and from line 1, and a
#cmd("NOCONCAT"), #var("max") or #var("skip") of an earlier call does not
carry over. A second #cmd("OUTTRAP") while trapping is on changes the
stem and options without turning trapping off.

Returns 0, or the return code of the allocation of the work file if it
failed. Trapping still on when the exec ends is turned off then.

#note[*To be confirmed:* the work file has records of 133 bytes, so a
longer output line is probably cut.]

```
CALL outtrap 'lst.'
ADDRESS TSO 'LISTCAT LEVEL(IBMUSER)'
CALL outtrap 'OFF'
DO i = 1 TO lst.0
  SAY lst.i
END
```

=== ARRAYGEN <ext-tso-arraygen>

#idx("ARRAYGEN")
```
ARRAYGEN('ON')
ARRAYGEN('OFF')
```
Collects terminal output into a string array (@ext-array) instead of a
stem. #cmd("ARRAYGEN") with any argument other than #cmd("OFF") turns
collecting on and returns 0 if it could be started.
#cmd("ARRAYGEN('OFF')") turns it off and returns the number of the
string array that holds the lines; free it with #cmd("SFREE").

Unlike #cmd("OUTTRAP"), #cmd("ARRAYGEN") redirects the output from the
#cmd("ON") call to the #cmd("OFF") call, not around single commands.

#note[*To be confirmed:* whether the exec's own #cmd("SAY") output
between #cmd("ON") and #cmd("OFF") is collected as well; #cmd("OUTTRAP")
had to be changed for that reason, #cmd("ARRAYGEN") was not.]

```
CALL arraygen 'ON'
ADDRESS TSO 'LISTALC STATUS'
s = arraygen('OFF')
CALL slist s
CALL sfree s
```

== Environment <ext-tso-env>

=== TERMINAL <ext-tso-terminal>

#idx("TERMINAL")
```
TERMINAL()
```
Returns the size of the TSO terminal as two words, rows and columns:
the alternate screen size, else the primary one. Without a terminal
(batch, or TSO in the background) the result is #cmd("0 0").

```
PARSE VALUE terminal() WITH rows cols
SAY rows cols            /* e.g. 43 80 */
```

=== PRIVILEGE <ext-tso-privilege>

#idx("PRIVILEGE")
```
PRIVILEGE('ON')
PRIVILEGE('OFF')
```
#cmd("PRIVILEGE('ON')") makes the program APF-authorised, through SVC
244 when it is not authorised already, and switches it to storage key 0.
#cmd("PRIVILEGE('OFF')") goes back to the problem key and, if
#cmd("ON") had to authorise it, removes the authorisation again.

#cmd("PRIVILEGE") exists only for users with #cmd("READ") access to the
RAKF profile #cmd("SVC244") in class #cmd("FACILITY"); for anyone else
a call ends in error 43. #cmd("ON") returns 0 when it succeeded.

Functions that need the privilege for a single service, such as
#cmd("CONSOLE") (@ext-kernel-console-fn), take it themselves and drop it
afterwards; a #cmd("PRIVILEGE('ON')") of the exec stays in effect
across them. A program running in key 0 can overwrite any storage, so
turn the privilege off as soon as it is no longer needed.

#note[*A defect* (brexx370 issue 386): #cmd("PRIVILEGE('OFF')") always
returns 8, even when it has dropped the privilege, and so does any
argument other than #cmd("ON") or #cmd("OFF"). Do not test the return
code of #cmd("OFF").]

```
CALL privilege 'ON'
/* work that needs authorisation */
CALL privilege 'OFF'
```

=== SYSVAR <ext-tso-sysvar>

#idx("SYSVAR")
```
SYSVAR(name)
```
Returns information about the user and the environment. An unknown
#var("name") gives #cmd("not yet implemented").

#deflist(width: 1.2in,
  [#cmd("SYSUID")], [User ID.],
  [#cmd("SYSPREF")], [TSO prefix, usually the user ID; null in batch
    without one.],
  [#cmd("SYSENV")], [#cmd("FORE") in the TSO foreground, #cmd("BACK")
    in TSO in batch, #cmd("BATCH") outside TSO.],
  [#cmd("SYSTSO")], [#cmd("1") under TSO, else #cmd("0").],
  [#cmd("SYSISPF")], [#cmd("ACTIVE") or #cmd("NOT ACTIVE").],
  [#cmd("SYSAUTH")], [#cmd("1") if the program runs APF-authorised,
    else #cmd("0").],
  [#cmd("SYSRAKF")], [#cmd("AVAILABLE") if RAKF is active, else
    #cmd("NOT AVAILABLE"). #cmd("SYSRACF") is the same.],
  [#cmd("SYSTERMID")], [Terminal ID in the TSO foreground; null
    otherwise.],
  [#cmd("SCRWIDTH")], [Screen width, from the full-screen services
    (@ext-fss).],
  [#cmd("SCRHEIGHT")], [Screen height, likewise.],
  [#cmd("SYSCP")], [The host MVS runs on: #cmd("Hercules"),
    #cmd("VM/370"), #cmd("VM/ESA"), #cmd("VM/SP"), #cmd("VM") or
    #cmd("UNKNOWN").],
  [#cmd("SYSCPLVL")], [The release of the host, for example the
    Hercules version line.],
  [#cmd("SYSNODE")], [The NJE38 node name, or #cmd("-INACTIVE-").],
  [#cmd("RXINSTRC")], [Number of REXX instructions run so far.],
  [#cmd("SYSHEAP")], [Always #cmd("0") since 3.0.],
  [#cmd("SYSSTACK")], [Always #cmd("0") since 3.0.],
)

#cmd("SYSCP"), #cmd("SYSCPLVL") and #cmd("SYSNODE") need #cmd("READ")
access to the RAKF profile #cmd("SVC244") in class #cmd("FACILITY"),
else they return #cmd("not authorized"); #cmd("SYSCP") and
#cmd("SYSCPLVL") also need TSO, else they return
#cmd("failed, TSO required").

The names partly differ from those of TSO/E REXX, which has no
#cmd("SYSAUTH"), #cmd("SYSRAKF"), #cmd("SYSCP"), #cmd("SYSNODE") or
#cmd("RXINSTRC").

Written in REXX and carried in the load module; the variables not
handled in REXX are passed to an internal C function.

```
SAY sysvar('SYSUID')       /* IBMUSER                    */
SAY sysvar('SYSENV')       /* FORE                       */
SAY sysvar('SYSISPF')      /* NOT ACTIVE                 */
SAY sysvar('SYSCP')        /* Hercules                   */
SAY sysvar('SYSCPLVL')     /* e.g. Hercules version 4.4.1... */
```

=== MVSVAR <ext-tso-mvsvar>

#idx("MVSVAR")
```
MVSVAR(name)
```
Returns information about the system and the running job. An unknown
#var("name") gives #cmd("not yet implemented").

#deflist(width: 1.2in,
  [#cmd("SYSNAME")], [System name (SMF ID).],
  [#cmd("SYSSMFID")], [The same.],
  [#cmd("SYSOPSYS")], [Operating system release, #cmd("MVS 03.8")
    followed by a blank.],
  [#cmd("CPU")], [CPU model, in hexadecimal.],
  [#cmd("CPUS")], [Number of CPUs.],
  [#cmd("MVSUP")], [Seconds since the IPL.],
  [#cmd("IPLDATE")], [Date and time of the IPL, the date in
    #cmd("XEUROPEAN") format.],
  [#cmd("JOBNAME")], [Job name, as #cmd("JOB.NAME") of #cmd("JOBINFO")
    (@ext-kernel-jobinfo).],
  [#cmd("JOBNUMBER")], [Job number.],
  [#cmd("STEPNAME")], [Step name.],
  [#cmd("PROGRAM")], [Program of the step.],
  [#cmd("REXX")], [Name of the main exec.],
  [#cmd("REXXDSN")], [Data set the main exec was loaded from, or null.],
  [#cmd("NJE")], [#cmd("1") if NJE38 is running, else #cmd("0").],
  [#cmd("NJEDSN")], [Data set name of the NJE38 spool, or null.],
  [#cmd("SYSNJVER")], [NJE38 version.],
)

TSO/E REXX has #cmd("MVSVAR") with other names; only #cmd("SYSNAME"),
#cmd("SYSSMFID") and #cmd("SYSOPSYS") are common to both.

Written in REXX and carried in the load module; the variables not
handled in REXX are passed to an internal C function. It has variables
of its own and changes none of the caller's.

```
SAY mvsvar('SYSNAME')                       /* e.g. MVSC     */
SAY mvsvar('SYSOPSYS')                      /* 'MVS 03.8 '   */
SAY mvsvar('NJE')                           /* 1             */
SAY sec2time(mvsvar('MVSUP'), 'DAYS')       /* e.g. 15 day(s) 12:03:52 */
```

== Volumes <ext-tso-volumes>

=== LISTVOL <ext-tso-listvol>

#idx("LISTVOL")
```
LISTVOL(volume)
```
Reads the VTOC of #var("volume") and sets variables that describe it.
Returns #cmd("0"), or another value if the volume could not be read:
#cmd("4") if the listing of #cmd("IRXVTOC") holds no summary of the
volume, #cmd("8") without #var("volume"), #cmd("12") if the volume is not
mounted (its device number is 0), #cmd("-16") outside TSO or when the work
file cannot be allocated.

#deflist(width: 1.2in,
  [#cmd("VOLVOLUME")], [Volume serial.],
  [#cmd("VOLTYPE")], [Device type, for example #cmd("3350").],
  [#cmd("VOLDEVICE")], [Device number.],
  [#cmd("VOLCYLS")], [Cylinders.],
  [#cmd("VOLTRKCYL")], [Tracks per cylinder.],
  [#cmd("VOLTRKS")], [Tracks of the volume, #cmd("VOLCYLS") ×
    #cmd("VOLTRKCYL").],
  [#cmd("VOLTRKLEN")], [Track length.],
  [#cmd("VOLTRKALC")], [Tracks allocated.],
  [#cmd("VOLTRKUSED")], [Tracks used.],
  [#cmd("VOLDSNS")], [Number of data sets on the volume.],
  [#cmd("VOLDSCBS")], [Number of DSCBs the VTOC can hold.],
  [#cmd("VOLDSCBTRK")], [DSCBs per track.],
  [#cmd("VOLDIRTRK")], [Directory blocks per track.],
  [#cmd("VOLALTTRK")], [Alternate tracks.],
)

The old documentation called two of them #cmd("VOLTRACKS") and
#cmd("VOLTRKSCYL"); in 3.0 they are #cmd("VOLTRKS") and
#cmd("VOLTRKCYL").

Written in REXX and carried in the load module.


```
IF listvol('PUB001') = 0 THEN
  SAY volvolume voltype volcyls voltrkused   /* e.g. PUB001 3350 555 ... */
```

=== LISTVOLS <ext-tso-listvols>

#idx("LISTVOLS")
```
LISTVOLS([option])
```
Lists the disk volumes attached to the system, asking Hercules with the
command #cmd("CP DEVLIST"). It needs the #cmd("PRIVILEGE") function, that
is #cmd("READ") access to the RAKF profile #cmd("SVC244") in class
#cmd("FACILITY"), and runs only under Hercules. Each line holds the
volume serial, the device type and the device number, as far as
#cmd("CP DEVLIST") shows them: the third column follows the layout of
the Hercules version, and some versions repeat the device type there.

#deflist(width: 1.2in,
  [#cmd("FMTLIST")], [Show the list on a full-screen #cmd("FMTLIST")
    panel (an #cmd("RXLIB") member).],
  [#cmd("LIST")], [Write the list to the terminal, followed by the
    number of volumes.],
  [(other)], [Put the lines into the stem #cmd("VOLUMES."), with
    #cmd("VOLUMES.0") holding their number (the default).],
)

#cmd("FMTLIST") and #cmd("LIST") are recognised by their first three
letters.

Written in REXX and carried in the load module.

```
CALL listvols
DO i = 1 TO volumes.0
  SAY volumes.i          /* e.g. PUB001  3350  0240 */
END
```

=== VTOC <ext-tso-vtoc>

#idx("VTOC")
```
VTOC(volume [, option])
```
Lists the data sets on #var("volume") from its VTOC, with these columns:
data set name, volume, tracks allocated and used, DSORG, RECFM,
percentage used, LRECL, BLKSIZE, last use and creation date.

#deflist(width: 1.2in,
  [#cmd("LIST")], [Write the list to the terminal, with a heading.],
  [#cmd("FMTLIST")], [Show the list on a full-screen #cmd("FMTLIST")
    panel.],
  [(none)], [Put the lines into the stem #cmd("VTOC."), with
    #cmd("VTOC.0") holding their number and #cmd("VTOC.HDR") the
    heading.],
)

#cmd("LIST") and #cmd("FMTLIST") are recognised by their first three
letters. If the VTOC cannot be read (outside TSO, for example), the
result is #cmd("-16").

Written in REXX and carried in the load module.

```
CALL vtoc 'PUB001'
SAY vtoc.hdr
DO i = 1 TO vtoc.0
  SAY vtoc.i
END
```
