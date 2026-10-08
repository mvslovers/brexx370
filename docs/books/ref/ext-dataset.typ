#import "../bookmaster/bookmaster.typ": *

= Data Set Functions <ext-dataset>

#idx("data set")
The functions of this chapter create, delete, rename, allocate and list
data sets and members, and the host command #cmd("EXECIO") reads and
writes them record by record. They are part of the interpreter and work
in TSO and in a batch step without TSO. To open a data set as a stream,
use #cmd("OPEN") and the other stream functions (@lang-builtin-open);
the TSO functions #cmd("SYSDSN"), #cmd("LISTDSI") and their relatives
are described in @ext-tso.

#idx("data set prefix")
*Data set names.* A name in quotes, such as #cmd("\"'HERC01.TEST.DATA'\""),
is used as it is. A name without quotes gets the data set prefix in front
of it, #var("prefix")#cmd(".")#var("name"), when there is one; without a
prefix it stands as it is. The prefix is the one in the TSO profile of the
user: it is set under TSO, in the foreground and in a batch TMP, and empty
in a batch step without TSO and for a user with #cmd("NOPREFIX"). A name
with a quote at one end only is not valid. The functions translate names
to uppercase. Where a member is allowed, it follows the data set name in
parentheses: #cmd("'HERC01.TEST.PDS(MEMBER)'").

== Data Set Management <ext-dataset-manage>

=== CREATE <ext-dataset-create>

#idx("CREATE")
```
CREATE(dsname, allocation)
```
Creates and catalogs the data set #var("dsname"); it does not open it.
#var("allocation") is a list of #var("keyword")#cmd("=")#var("value")
items separated by commas; case does not matter, and blanks around an
item are ignored. All keywords are optional:

#deflist(width: 1.2in,
  [#cmd("DSORG")], [#cmd("PS") or #cmd("PO"). Default: #cmd("PO") if
    #cmd("DIRBLKS") is given, else #cmd("PS").],
  [#cmd("RECFM")], [#cmd("F"), #cmd("V") or #cmd("U"), followed by any
    of #cmd("B"), #cmd("S"), #cmd("A"), #cmd("M"), for example
    #cmd("FB") or #cmd("VBA").],
  [#cmd("LRECL")], [Record length.],
  [#cmd("BLKSIZE")], [Block size.],
  [#cmd("PRI")], [Primary space in tracks. Default 1.],
  [#cmd("SEC")], [Secondary space in tracks. Default 1.],
  [#cmd("DIRBLKS")], [Directory blocks. Default 5 for a #cmd("PO")
    data set.],
  [#cmd("UNIT")], [Unit name, up to 8 characters. Default
    #cmd("SYSDA").],
)

The return value is:

#deflist(width: 1.2in,
  [#cmd("0")], [The data set was created.],
  [#cmd("-1")], [It could not be created: the name or the allocation is
    not valid (an unknown keyword, a bad value), or the allocation
    failed, for example for lack of space or authority.],
  [#cmd("-2")], [A data set of that name is already cataloged.],
)

```
rc = create("'HERC01.TEST.PDS'",'recfm=fb,lrecl=80,blksize=3120,pri=5,dirblks=5')
SAY rc                   /* 0 */
```

=== REMOVE <ext-dataset-remove>

#idx("REMOVE")
```
REMOVE(dsname)
```
Deletes #var("dsname"). A data set is deleted and uncataloged with the
IDCAMS command #cmd("DELETE"). A member,
#var("dsname")#cmd("(")#var("member")#cmd(")"), is removed from the
directory alone, as ISPF does it, so the data set need not be held
exclusively. Returns #cmd("0") if it was deleted, #cmd("-1") for a name
that is not valid, and otherwise the return code of IDCAMS or of the
directory update.

```
SAY remove("'HERC01.TEST.PDS(OLDMEM)'")    /* 0 */
SAY remove("'HERC01.TEST.SEQ'")            /* 0 */
```

=== RENAME <ext-dataset-rename>

#idx("RENAME")
```
RENAME(oldname, newname)
```
Renames a data set, or a member within one partitioned data set. Either
both names carry a member or neither does; a data set and its member
cannot be renamed in one call. A data set is renamed with the IDCAMS
command #cmd("ALTER ... NEWNAME"); a member by a directory update, which
keeps its data and statistics. The return value is:

#deflist(width: 1.2in,
  [#cmd("0")], [Renamed.],
  [#cmd("-2")], [One of the names is not valid.],
  [#cmd("-3")], [Only one of the names has a member.],
  [#cmd("-4")], [The two names are the same.],
  [#cmd("-5")], [Both names have a member but name different data
    sets.],
  [other], [The return code of IDCAMS or of the directory update.],
)

```
SAY rename("'HERC01.TEST.PDS(OLD)'","'HERC01.TEST.PDS(NEW)'")  /* 0 */
```

=== EXISTS <ext-dataset-exists>

#idx("EXISTS")
```
EXISTS(dsname)
```
Returns #cmd("1") if the data set, or the member of a partitioned data
set, exists and can be opened for reading, otherwise #cmd("0"); for a
name that is not valid, #cmd("-1"). Outside the TSO foreground no one
can be asked for a password, so a password-protected data set counts as
not there, and #cmd("EXISTS") returns #cmd("0") for it.

```
IF exists("'HERC01.TEST.PDS(MEMBER)'") THEN SAY 'there'
```

=== LISTDSIQ <ext-dataset-listdsiq>

#idx("LISTDSIQ")
```
LISTDSIQ(dsname [, option])
```
A quick form of #cmd("LISTDSI") (@ext-tso) with fewer attributes.
#var("dsname") is a fully qualified data set name without quotes,
optionally with a member, 44 characters at most in all; neither the
prefix nor a DD name is used. The data set is opened for reading, and
these variables are set:

#deflist(width: 1.2in,
  [#cmd("SYSDSNAME")], [Data set name.],
  [#cmd("SYSDDNAME")], [DD name of the allocation.],
  [#cmd("SYSMEMBER")], [Member name, if one was given.],
  [#cmd("SYSVOLUME")], [Volume serial.],
  [#cmd("SYSDSORG")], [#cmd("PS"), #cmd("PO") or #cmd("???").],
  [#cmd("SYSRECFM")], [#cmd("F"), #cmd("FB"), #cmd("FBM"), #cmd("V"),
    #cmd("VB"), #cmd("VBA"), #cmd("VBM") or #cmd("U"); any other
    format, #cmd("FBA") among them, shows as #cmd("??????").],
  [#cmd("SYSLRECL")], [Record length.],
  [#cmd("SYSBLKSIZE")], [Block size.],
)

With #var("option") #cmd("R") (in uppercase) the records are also counted, into
#cmd("SYSRECORDS"); this reads the whole data set. Returns #cmd("0"),
#cmd("16") if the data set cannot be opened, and #cmd("3") if the name
is longer than 44 characters.

```
IF listdsiq('SYS1.MACLIB(SAVE)','R') = 0 THEN
   SAY sysvolume sysrecfm syslrecl sysrecords
```

=== TSTCAT <ext-dataset-tstcat>

#idx("TSTCAT")
```
TSTCAT(dsname, volume)
```
Written in REXX and carried in the load module. Tests whether
#var("dsname") is cataloged on #var("volume"). #var("dsname") is fully
qualified and without quotes, as for #cmd("LISTDSIQ"), which
#cmd("TSTCAT") calls. Returns #cmd("0") if the data set is found on
#var("volume"), #cmd("8") if it is found on another volume, and
#cmd("16") if it cannot be opened. It sets the variables of
#cmd("LISTDSIQ") in the caller.

```
SAY tstcat('SYS1.MACLIB','MVSRES')    /* 0 if it is on MVSRES */
```

== Allocation <ext-dataset-alloc>

=== ALLOCATE <ext-dataset-allocate>

#idx("ALLOCATE")
```
ALLOCATE(ddname, dsname [, MOD])
```
Allocates #var("dsname") to the DD name #var("ddname") by dynamic
allocation, so that it can be used where a DD name is needed, for
example by #cmd("EXECIO"). An allocation that #var("ddname") already has
is freed first. #var("dsname") can be:

#deflist(width: 1.2in,
  [a data set], [An existing data set or member, allocated
    #cmd("DISP=SHR"), or #cmd("DISP=MOD") with the third argument
    #cmd("MOD").],
  [#cmd("DUMMY")], [A dummy data set.],
  [#cmd("INTRDR")], [The internal reader, #cmd("SYSOUT=(A,INTRDR)")
    with #cmd("RECFM=F") and #cmd("LRECL=80"): records written to it
    are submitted as a job.],
  [#cmd("&&")#var("var")], [A new temporary data set on unit
    #cmd("VIO"), #cmd("RECFM=FB"), #cmd("LRECL=80"); its
    system-generated name is stored in the variable #var("var").],
  [#cmd("##")#var("var")], [The same with #cmd("LRECL=255").],
)

Returns #cmd("0") if the allocation succeeded, #cmd("-1") for a name
that is not valid, and otherwise the return code of dynamic allocation
(SVC 99), which also writes a message with its error and information
codes.

```
CALL allocate 'INDD',"'HERC01.TEST.PDS(MEMBER)'"
CALL allocate 'TMP','&&TMPDSN'
SAY tmpdsn               /* the generated name */
```

=== FREE <ext-dataset-free>

#idx("FREE")
```
FREE(ddname)
```
Frees the allocation of #var("ddname"). Returns #cmd("0"), or the
return code of dynamic allocation (SVC 99), for example if
#var("ddname") is not allocated.

```
CALL free 'INDD'
```

== Directories <ext-dataset-dirs>

=== DIR <ext-dataset-dir>

#idx("DIR")
```
DIR(dsname [, option])
```
Reads the directory of the partitioned data set #var("dsname") into the
stem #cmd("DIRENTRY."). #cmd("DIRENTRY.0") holds the number of entries,
at most 3000; further members are not listed. Returns #cmd("0"), or
#cmd("8") if the directory cannot be read. #var("option") selects how
much is set for each entry #var("n"):

#deflist(width: 1.2in,
  [#cmd("D")], [Details (the default): #cmd("NAME"), #cmd("TTR"),
    #cmd("LINE") and, for a member with ISPF statistics,
    #cmd("CDATE"), #cmd("UDATE"), #cmd("UTIME"), #cmd("INIT"),
    #cmd("SIZE"), #cmd("MOD") and #cmd("UID").],
  [#cmd("M")], [Member names only: #cmd("NAME").],
  [any other], [#cmd("NAME") and #cmd("LINE").],
)

The variables of entry #var("n") are:

#deflist(width: 1.2in,
  [#cmd("DIRENTRY.")#var("n")#cmd(".NAME")], [Member name.],
  [#cmd("DIRENTRY.")#var("n")#cmd(".TTR")], [TTR of the member, six
    hexadecimal digits.],
  [#cmd("DIRENTRY.")#var("n")#cmd(".CDATE")], [Creation date,
    #var("yy")#cmd("-")#var("mm")#cmd("-")#var("dd").],
  [#cmd("DIRENTRY.")#var("n")#cmd(".UDATE")], [Date of the last change,
    #var("yy")#cmd("-")#var("mm")#cmd("-")#var("dd").],
  [#cmd("DIRENTRY.")#var("n")#cmd(".UTIME")], [Time of the last change,
    #var("hh")#cmd(":")#var("mm")#cmd(":")#var("ss").],
  [#cmd("DIRENTRY.")#var("n")#cmd(".INIT")], [Initial number of
    lines.],
  [#cmd("DIRENTRY.")#var("n")#cmd(".SIZE")], [Current number of
    lines.],
  [#cmd("DIRENTRY.")#var("n")#cmd(".MOD")], [Number of modified
    lines.],
  [#cmd("DIRENTRY.")#var("n")#cmd(".UID")], [User id of the last
    change.],
  [#cmd("DIRENTRY.")#var("n")#cmd(".LINE")], [All of it in one line:
    name, TTR, version, creation date, change date and time, initial,
    current and modified lines, user id. For a load module: name, TTR,
    the module size in hexadecimal and, if the entry is an alias, the
    name of the main member.],
)

```
IF dir("'SYS2.EXEC'") = 0 THEN
   DO i = 1 TO direntry.0
      SAY direntry.i.name direntry.i.udate direntry.i.uid
   END
```

=== LOCATE <ext-dataset-locate>

#idx("LOCATE")
```
LOCATE(dsname, member [, FILE])
```
Tests whether the partitioned data set #var("dsname") has the member
#var("member"). #var("dsname") is fully qualified, with or without
quotes; with the third argument #cmd("FILE"), it is a DD name instead.
The member name is compared exactly, without patterns. Returns
#cmd("0") if the member is there, #cmd("8") if it is not, and
#cmd("12") if the directory cannot be read.

```
SAY locate('SYS1.MACLIB','SAVE')        /* 0 */
SAY locate('SYSPROC','NOSUCH','FILE')   /* 8 */
```

== The EXECIO Command <ext-dataset-execio-sect>

=== EXECIO <ext-dataset-execio>

#idx("EXECIO")
```
"EXECIO lines|* operation file [(options]"
```
#cmd("EXECIO") is a host command, so it is written as a string.
BREXX/370 carries it out itself, under #cmd("ADDRESS MVS") and under
#cmd("ADDRESS TSO"), also without TSO (@ext-address); under any other
environment the return code is #cmd("-3"). It reads and writes text
records between a data set and a stem or the data stack, or moves
records between a stem and the stack.

#var("lines") is the number of records to process; #cmd("*") processes
all of them. #var("file") is a DD name or a data set name. A name of up
to eight characters without quotes is tried as a DD name first; if no
such DD is allocated, it is taken as a data set name as described at the
beginning of this chapter. A name in quotes is always a data set name
and may carry a member.

#note[*To be confirmed:* #cmd("EXECIO") passes the name as written,
without translating it to uppercase; whether a name in lowercase is
found depends on the C library.]

#var("operation") is one of:

#deflist(width: 1.2in,
  [#cmd("DISKR")], [Read records from #var("file").],
  [#cmd("DISKW")], [Write records to #var("file"), replacing its
    content.],
  [#cmd("DISKA")], [Append records to #var("file").],
  [#cmd("FIFOR")], [Pull records from the data stack into a stem.
    #cmd("LIFOR") is the same: the records come in the order of the
    stack.],
  [#cmd("FIFOW"), #cmd("LIFOW")], [Write the records of a stem to the
    data stack, queued (#cmd("FIFOW")) or pushed (#cmd("LIFOW")).],
)

The options follow a left parenthesis; a closing one is not needed:

#deflist(width: 1.2in,
  [#cmd("STEM") #var("name")], [Read into, or write from, the stem
    #var("name"). The name is used as given, so write the period:
    #cmd("STEM LINE.") gives #cmd("LINE.1"), #cmd("LINE.2"), and so on,
    and #cmd("LINE.0") holds the number of records. Without
    #cmd("STEM"), #cmd("DISKR") puts the records on the data stack and
    #cmd("DISKW") and #cmd("DISKA") take them from it.],
  [#cmd("FIFO"), #cmd("LIFO")], [For #cmd("DISKR") without
    #cmd("STEM"): queue (the default) or push the records.],
  [#cmd("SKIP") #var("n")], [Skip the first #var("n") records;
    #var("n") must be positive.],
  [#cmd("START") #var("n")], [#cmd("DISKR") into a stem: store the first
    record at #var("stem")#var("n") instead of #var("stem")#cmd("1");
    #var("stem")#cmd("0") is then the highest index set.],
  [#cmd("KEEP") #var("string")], [Process only records that contain
    #var("string").],
  [#cmd("DROP") #var("string")], [Process only records that do not
    contain #var("string").],
  [#cmd("SUBSTR(")#var("offset")#cmd(",")#var("length")#cmd(")")],
    [Process only this part of each record.],
)

The command is split into words at blanks, parentheses and commas, so a
#cmd("KEEP") or #cmd("DROP") string cannot contain any of them; the
comparison is exact, case included. A record is read up to 4096
characters, and its line end is removed. #cmd("DISKW") from a stem
writes #var("stem")#cmd("1") to #var("stem")#var("n"), where #var("n")
is the value of #var("stem")#cmd("0").

The return code is:

#deflist(width: 1.2in,
  [#cmd("0")], [Done.],
  [#cmd("8")], [The command is not valid, a value is not numeric, the
    file cannot be opened, or #cmd("DISKW") found the stack empty. A
    message says which.],
  [#cmd("20")], [A record could not be written; a message gives the
    number of records written.],
)

Differences from TSO/E: the return codes 1, 2 and 4 of TSO/E do not
occur. #var("lines") must be #cmd("*") or a positive number. Every
#cmd("EXECIO") opens and closes the file itself; there are no
#cmd("OPEN") and #cmd("FINIS") options, so the TSO/E idiom
#cmd("EXECIO 0 DISKW") #var("dd") #cmd("(FINIS") is not valid, and a
second #cmd("DISKR") starts again at the first record. #cmd("DISKRU")
is not supported. #cmd("DISKA"), #cmd("FIFOR"), #cmd("LIFOR"),
#cmd("FIFOW"), #cmd("LIFOW"), #cmd("START"), #cmd("KEEP"),
#cmd("DROP") and #cmd("SUBSTR") are BREXX/370 additions.

```
"EXECIO * DISKR INDD (STEM IN."
SAY in.0 'records read'
"EXECIO * DISKW 'HERC01.TEST.PDS(COPY)' (STEM IN."
"EXECIO * DISKR INDD (KEEP ERROR SKIP 2"
DO QUEUED()
   PARSE PULL line
   SAY line
END
```
