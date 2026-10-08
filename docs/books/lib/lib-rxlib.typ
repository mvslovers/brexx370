#import "../bookmaster/bookmaster.typ": *

= RXLIB Functions <lib-rxlib>

#idx("RXLIB", "functions")
This chapter describes the members of RXLIB one by one, grouped by what
they do. How RXLIB is found, and what happens when a member has the name
of a built-in function, is described in @lib-intro. The members that make
up the formatted-screen tools, the key/value database and the larger
applications are described in their own chapters; @lib-rxlib-others lists
them.

Each entry gives the call as it is coded in the member. Argument values
in upper case, such as #cmd("'DSN'"), are coded as shown; a stem is
passed by name, with its trailing period, as #cmd("'MYSTEM.'"). Unless
the entry says otherwise, a data set name is passed fully qualified and
without quotes: the member adds the quotes itself.

== Dates and Times <lib-rxlib-dates>

=== RXDATE <lib-rxlib-rxdate>

#idx("RXDATE")
```
RXDATE([output-format] [, date [, input-format]])
```
Converts #var("date"), given in #var("input-format"), into
#var("output-format"). Both formats default to #cmd("EUROPEAN"); without
#var("date"), today's date is converted. The first letter of a format is
enough, except as the table says.
#idx("DATE", "supersedes RXDATE")
The member's own header says that it should no longer be used: the
built-in function #cmd("DATE") takes the same three arguments and the
same formats (_BREXX/370 Reference_, "DATE").

#tab(caption: [Date formats of RXDATE])[
  #table(columns: (1.1in, 1fr, 0.8in),
    [Format], [Meaning], [Input too?],
    [#cmd("BASE")], [days since 1 January 0001], [yes],
    [#cmd("JDN")], [Julian day number, days since 24 November 4714 BC;
      as input, at least #cmd("JDN")], [yes],
    [#cmd("UNIX")], [days since 1 January 1970; #cmd("U") means
      #cmd("UNIX"), so #cmd("USA") needs #cmd("US")], [yes],
    [#cmd("JULIAN")], [#cmd("yyyyddd"), for example #cmd("2026281")], [yes],
    [#cmd("DAYS")], [#cmd("ddd"), the day of the year], [no],
    [#cmd("WEEKDAY")], [the day of the week in English, #cmd("Monday")
      ...], [no],
    [#cmd("CENTURY")], [days since the start of the century], [no],
    [#cmd("EUROPEAN")], [#cmd("dd/mm/yyyy")], [yes],
    [#cmd("SHEUROPE")], [#cmd("dd/mm/yy")], [no],
    [#cmd("GERMAN")], [#cmd("dd.mm.yyyy")], [yes],
    [#cmd("SHGERMAN")], [#cmd("dd.mm.yy")], [no],
    [#cmd("USA")], [#cmd("mm/dd/yyyy")], [yes],
    [#cmd("SHUSA")], [#cmd("mm/dd/yy")], [no],
    [#cmd("STANDARD")], [#cmd("yyyymmdd")], [yes],
    [#cmd("ORDERED")], [#cmd("yyyy/mm/dd")], [yes],
    [#cmd("SHORT")], [#cmd("dd MON yyyy"), for example
      #cmd("24 DEC 2026")], [no],
    [#cmd("LONG")], [#cmd("dd MONTH yyyy"), for example
      #cmd("24 DECEMBER 2026")], [no],
  )
] <lib-rxlib-rxdate-tab>

An output format that is not in the table gives #cmd("dd.mm.yyyy"). An
input date that is not numeric once its blanks, periods and slashes are
removed is returned as #var("date")#cmd(" invalid date format").

```
SAY rxdate('STANDARD','24/12/2026')          /* 20261224 */
SAY rxdate('WEEKDAY','24/12/2026')           /* Thursday */
SAY rxdate('USA','20261224','STANDARD')      /* 12/24/2026 */
```

=== TODAY <lib-rxlib-today>

#idx("TODAY", "function")
```
TODAY([output-format] [, date [, input-format]])
```
Returns #cmd("RXDATE(")#var("output-format")#cmd(",")#var("date")#cmd(",")#var("input-format")#cmd(")"):
today's date in #var("output-format"), or another date converted.
Like RXDATE, it is superseded by the built-in #cmd("DATE"). The TSO
command #cmd("TODAY") (@lib-tsocmd-today) is a different thing.

```
SAY today('ORDERED')                    /* e.g. 2026/10/08 */
```

=== DAYSBETW <lib-rxlib-daysbetw>

#idx("DAYSBETW")
```
DAYSBETW([date1] [, [date2] [, [format1] [, format2]]])
```
Returns the number of days from #var("date1") to #var("date2"), negative
when #var("date2") is the earlier. #var("format1") defaults to
#cmd("EUROPEAN"), #var("format2") to #var("format1"); a date that is
omitted is today. The input formats are those of RXDATE
(@lib-rxlib-rxdate-tab), in upper case: DAYSBETW does not translate
them. An invalid date is returned as #var("date")#cmd(" invalid date format").

DAYSBETW does the conversion with #cmd("_DATEI"), a routine of the member
RXDATE. It is found only once RXDATE has been loaded in the run, by a call
of RXDATE or TODAY, or by #cmd("IMPORT").

#note[*A defect* (brexx370 issue 386): DAYSBETW calls #cmd("_DATEI"), an
internal label of RXDATE; the member contains no #cmd("_DATEI"), and no
member of that name exists. Load RXDATE first, as in the example.]

```
CALL import 'RXDATE'
SAY daysbetw('01/01/2026','24/12/2026')            /* 357 */
SAY daysbetw('20260101','20261231','STANDARD')     /* 364 */
```

=== STDATE <lib-rxlib-stdate>

#idx("STDATE")#idx("stardate")
```
STDATE([target] [, date [, input [, 'BASE2']]])
STDATE('SDNEW')
```
Converts between calendar dates and the "stardate" of Star Trek. The
calendar formats are #cmd("XU") (#cmd("mm/dd/yyyy")), #cmd("XE")
(#cmd("dd/mm/yyyy")) and #cmd("I") (#cmd("yyyy-mm-dd")); #cmd("SDW") is
the stardate. #var("target") defaults to #cmd("SDW"), #var("input") to
#cmd("DFLT"), today.

A stardate is #cmd("58000") for the start of 2005, plus 1000 a year, plus
the day of the year in thousandths of a year, rounded to two decimals;
from 2323 on it counts from 0. With #var("input") #cmd("SDW"), #var("date")
is a stardate and is converted into #var("target"); #cmd("BASE2") takes
it as counted from 2323. #cmd("STDATE('SDNEW')") returns another form,
#cmd("StarDate/Year: ")#var("dddd")#cmd(".")#var("t")#cmd("/")#var("yyyy"),
from the last four digits of today's Julian day number, the tenth of the
day and the year. Every year divisible by 4 counts as a leap year. An
invalid format is answered with a message text.

```
SAY stdate('SDW','12/31/2025','XU')      /* 78997.26 */
SAY stdate('XE',89898.41,'SDW')          /* a date in 2036 */
```

The sample STARDATE shows more calls (@lib-samples).

=== SECTIMEO <lib-rxlib-sectimeo>

#idx("SECTIMEO")#idx("SEC2TIME", "old RXLIB copy")
The old RXLIB copy of #cmd("SEC2TIME"), marked deprecated in the member.
#cmd("SEC2TIME") itself is built into the interpreter
(@lib-rxlib-moved); call it instead.

== Stems and Files <lib-rxlib-stems>

The members of this group work on stems that hold their number of
entries in #var("stem")#cmd(".0").

=== READALL <lib-rxlib-readall>

#idx("READALL")
```
READALL(file [, [stem] [, [type] [, [max] [, header]]]])
```
Reads #var("file") into the stem #cmd("READALL."), and, with
#var("stem"), copies it to #var("stem") as well. #var("type") is
#cmd("DSN") for a data set name or #cmd("DDN") for a DD name; without
it, a name that contains a period is a data set name and any other a DD
name. A data set name is put in quotes unless it already is.
#var("max") limits the lines read (default 99999). With #var("header"),
the first line must begin with #var("header"), which is translated to
upper case, or nothing is read.

Returns the number of lines read, #cmd("-4") if the header did not match
and #cmd("-8") if the file could not be opened; the open error is also
reported with RXMSG (@lib-rxlib-rxmsg) as message 300. An empty last line
is not counted.

```
n = readall('SYS1.PROCLIB(JES2)','jcl.','DSN')
SAY n jcl.0                  /* e.g. 42 42 */
```

=== WRITEALL <lib-rxlib-writeall>

#idx("WRITEALL")
```
WRITEALL(file, stem [, [type] [, [from] [, to]]])
```
Writes the entries #var("from") to #var("to") of #var("stem") (default:
all) to #var("file") as lines. #var("type") #cmd("DSN") means a data set
name, which WRITEALL puts in quotes; anything else, the default, a DD
name. Unlike READALL, WRITEALL does not look for a period in the name.

Returns the number of entries of the stem, #var("stem")#cmd(".0") --
also when only a range was written -- or #cmd("-8") if the file cannot
be opened, #var("stem")#cmd(".0") is not a number, or the range is
reversed or beyond the stem; the reason is reported with RXMSG (messages
300 to 322).

```
CALL writeall 'MY.DATA','jcl.','DSN'
```

=== STEMCLEN <lib-rxlib-stemclen>

#idx("STEMCLEN")
```
STEMCLEN(stem)
```
Removes the entries of #var("stem") that are unset or empty and closes
the gaps, so that the remaining entries are numbered from 1. Returns the
new number of entries, or #cmd("-8") (with RXMSG message 310) if
#var("stem")#cmd(".0") is not a number. #var("stem") must end in a
period. STEMCLEN does not set #var("stem")#cmd(".0"); assign the result
to it.

```
s.1='a'; s.2=''; s.3='c'; s.0=3
s.0 = stemclen('s.')
SAY s.0 s.1 s.2               /* 2 a c */
```

=== STEMINS <lib-rxlib-stemins>

#idx("STEMINS")
```
STEMINS(source, target [, index])
```
Inserts the entries of #var("source") into #var("target") in front of
entry #var("index") (default 1); the entries from there on move down.
#var("index") #cmd("-1") appends #var("source") at the end. A missing
trailing period is added. Sets #var("target")#cmd(".0") and returns the
new number of entries. If either #cmd(".0") is not a number, the exec is
stopped with a message.

```
a.1='x'; a.0=1
b.1='1'; b.2='2'; b.0=2
CALL stemins 'a.','b.',2
SAY b.0 b.1 b.2 b.3           /* 3 1 x 2 */
```

=== STEMREOR <lib-rxlib-stemreor>

#idx("STEMREOR")
```
STEMREOR(stem)
```
Reverses the order of the entries of #var("stem"): the first becomes the
last. Returns the number of entries; stops the exec with a message if
#var("stem")#cmd(".0") is not a number.

```
s.1='a'; s.2='b'; s.3='c'; s.0=3
CALL stemreor 's.'
SAY s.1 s.2 s.3               /* c b a */
```

=== STEMPUT and STEMGET <lib-rxlib-stemput>

#idx("STEMPUT")#idx("STEMGET")
```
STEMPUT(dsname, stem [, stem] ...)
STEMGET(dsname)
```
STEMPUT saves one or more stems, each named with its trailing period, in
the data set #var("dsname"). It writes comment lines that begin with
#cmd(";") and then, for each stem, the output of #cmd("VARDUMP") -- one
#var("NAME")#cmd("=\"")#var("value")#cmd("\"") line per variable. It
returns #cmd("0"), #cmd("-4") if nothing was written, or #cmd("-8") if
the data set cannot be opened (RXMSG message 500). A name without the
period is skipped with message 510.

STEMGET reads such a data set back and executes each line that does not
begin with #cmd(";") or a blank, which sets the variables again. It
returns the number of lines executed, or #cmd("-8") if the data set
cannot be opened.

```
CALL stemput 'MY.STEMS','jcl.','opts.'
...
SAY stemget('MY.STEMS')      /* number of variables restored */
```

=== RXSORT and SORTCOPY <lib-rxlib-rxsort>

#idx("RXSORT")#idx("SORTCOPY")
```
RXSORT([method] [, 'DESCENDING'])
SORTCOPY(stem)
```
RXSORT sorts the stem #cmd("SORTIN."). #var("method") is
#cmd("QUICKSORT") (the default and the fastest), #cmd("SHELLSORT"),
#cmd("HEAPSORT") or #cmd("BUBBLESORT"); the first letter is enough.
#cmd("DESCENDING"), at least #cmd("DES"), reverses the result. The
entries are compared strictly, character by character, in EBCDIC: lower
case sorts before upper case, letters before digits, and #cmd("10")
before #cmd("9"). RXSORT returns #cmd("0"), or #cmd("8") if
#cmd("SORTIN.0") is not a positive number, and sets #cmd("EXECTIME") to
the seconds it took.

Sorting in REXX is slow; the member's documentation recommends it for
up to about 1000 entries. The string arrays of the interpreter sort much
faster (_BREXX/370 Reference_, "SQSORT").

SORTCOPY copies #var("stem") to #cmd("SORTIN.") and returns the number
of entries.

```
names.1='Smith'; names.2='Adams'; names.3='Jones'; names.0=3
CALL sortcopy 'names.'
CALL rxsort 'QUICKSORT'
SAY sortin.1 sortin.2 sortin.3         /* Adams Jones Smith */
```

== Records <lib-rxlib-records>

=== DCL <lib-rxlib-dcl>

#idx("DCL")#idx("SPLITRECORD")#idx("SETRECORD")#idx("record", "structure")
```
DCL('$DEFINE', structure [, prefix])
DCL(field, [offset], length [, type])
CALL SPLITRECORD structure, record
record = SETRECORD(structure)
```
Describes the fields of a record, so that a record can be split into
variables and built from them. #cmd("$DEFINE") (or #cmd("$INIT")) starts
the structure #var("structure"); the fields defined after it belong to
it. #var("prefix") is put in front of every field name. It returns
#cmd("1").

Each further call defines a field: the variable #var("field") (in upper
case) takes #var("length") characters from #var("offset"). Without
#var("offset"), the field follows the one defined before; the first
starts at 1. #var("type") is #cmd("CHAR") (the default), #cmd("PACKED")
(the variable holds a number, the record a packed decimal) or
#cmd("BINARY") (the record holds a binary number #var("length") bytes
long); the first letter counts. DCL returns the offset after the field.

SPLITRECORD and SETRECORD are routines of the member DCL. They can be
called once DCL itself has been called, which loads the member.
SPLITRECORD sets the variables of #var("structure") from #var("record").
SETRECORD returns a record built from their values, without trailing
blanks.

```
n=DCL('$DEFINE','student')
n=DCL('Name',1,32)
n=DCL('FirstName',1,16)
n=DCL('LastName',,16)
n=DCL('Address',,32)
recin='Fred            Flintstone      Bedrock'
CALL splitrecord 'student',recin
SAY strip(firstname) strip(lastname) address   /* Fred Flintstone Bedrock */
firstname='Barney'; lastname='Rubble'
SAY setrecord('student')
                         /* Barney          Rubble          Bedrock */
```

The member DCLO is an older copy of DCL; use DCL.

== Strings and Messages <lib-rxlib-strings>

=== QUOTE <lib-rxlib-quote>

#idx("QUOTE", "RXLIB member")
#cmd("QUOTE") is a built-in function of the interpreter, and the built-in
wins (@lib-intro-search): #cmd("QUOTE(")#var("string")#cmd(")") returns
#var("string") in apostrophes, or in double quotes if it contains an
apostrophe (_BREXX/370 Reference_, "QUOTE"). The RXLIB member QUOTE, which
takes a second argument naming the delimiter -- #cmd("'"),
#cmd("\""), #cmd("("), #cmd("[") or #cmd("<") -- is never called (a
defect, brexx370 issue 386).

```
SAY quote('SYS1.MACLIB')       /* 'SYS1.MACLIB' */
```

=== UNQUOTE <lib-rxlib-unquote>

#idx("UNQUOTE")
```
UNQUOTE(string)
```
Removes the first and the last character of #var("string") if they are a
pair of quotes, double quotes, parentheses, square brackets or angle
brackets; otherwise returns #var("string") unchanged. Blanks are not
removed first.

```
SAY unquote("'SYS1.MACLIB'")     /* SYS1.MACLIB */
SAY unquote('(entry 2)')         /* entry 2 */
SAY unquote(" 'x' ")             /*  'x'   unchanged */
```

=== RXMSG <lib-rxlib-rxmsg>

#idx("RXMSG")#idx("MAXRC")#idx("RXMSLV")
```
RXMSG(number, level, text)
RXMSG('CUSTOMISE', [prefix] [, [number-length] [, [text-length] [, case]]])
```
Writes a message in a fixed layout and returns its return code. The
message is the prefix #cmd("RX"), #var("number") with four digits,
#var("level"), and #var("text"), in upper case.

#deflist(width: 1.2in,
  [#cmd("I")], [Information; return code 0.],
  [#cmd("W")], [Warning; return code 4.],
  [#cmd("E")], [Error; return code 8.],
  [#cmd("C")], [Critical; return code 12.],
)

RXMSG sets these variables of the caller:

#deflist(width: 1.2in,
  [#cmd("MAXRC")], [The highest return code of all RXMSG calls so far.
    #cmd("EXIT MAXRC") passes it to MVS as the step's return code. A
    procedure that calls RXMSG must expose #cmd("MAXRC") for its caller
    to see it.],
  [#cmd("MSRC")], [The return code as one hexadecimal digit:
    #cmd("0"), #cmd("4"), #cmd("8") or #cmd("C").],
  [#cmd("MSLV")], [The level.],
  [#cmd("MSTX")], [The text.],
  [#cmd("MSLN")], [The whole message line.],
)

The variable #cmd("RXMSLV") suppresses messages below a level:
#cmd("'E'") writes only #cmd("C") and #cmd("E") messages, #cmd("'W'")
also warnings, #cmd("'I'") all of them, and #cmd("'N'") none. The return
code and #cmd("MAXRC") are set either way.

#cmd("CUSTOMISE"), at least #cmd("CUS"), changes the layout for the rest
of the run: #var("prefix") replaces #cmd("RX"), #var("number-length")
the four digits, #var("text-length") cuts the text (#cmd("0"), the
default, for no limit), and #var("case") #cmd("1") keeps the text in
mixed case.

```
rc = rxmsg( 10,'I','Program started')    /* RX0010I    PROGRAM STARTED */
rc = rxmsg(200,'W','Value missing')      /* RX0200W    VALUE MISSING */
rc = rxmsg(999,'C','Divisor is zero')    /* RX0999C    DIVISOR IS ZERO */
SAY rc maxrc                             /* 12 12 */
```

The member RXMSGCUS was meant to set the same layout variables; its
second line holds an unterminated string, so it cannot run (a defect,
brexx370 issue 386). Use
#cmd("RXMSG('CUSTOMISE',...)").

=== DUMP <lib-rxlib-dump>

#idx("DUMP")
```
DUMP(string [, [title] [, address]])
```
Writes #var("string") in dump form with #cmd("SAY"), 32 bytes to a block
of three lines: the characters, the high half and the low half of each
byte in hexadecimal. Each line begins with the offset in decimal and,
in parentheses, in hexadecimal; with #var("address"), a decimal storage
address, the hexadecimal address of each line comes first. #var("title")
defaults to #cmd("Dump Output"). Returns #cmd("0").

```
CALL dump 'ABC','TEST'
/* TEST
   0000(0000)  ABC
   0000(0000)  CCC
   0000(0000)  123   */
```

== Data Sets and the System <lib-rxlib-system>

=== LISTALC <lib-rxlib-listalc>

#idx("LISTALC")
```
LISTALC(['PRINT' | 'NOPRINT' | 'BUFFER'])
```
Lists the DD names of the job step or TSO session and the data sets
allocated to them, read from the TIOT. A data set allocated with a member
shows as #var("dsname")#cmd("(")#var("member")#cmd(")"), the terminal as
#cmd("*terminal"), a SYSOUT data set as #cmd("*sysout"). The second and
later data sets of a concatenation have a blank DD name.

#cmd("PRINT"), the default, writes one line per data set with
#cmd("SAY"); #cmd("NOPRINT") writes nothing; #cmd("BUFFER") puts the lines
into the stem #cmd("BUFFER."), which FMTLIST displays (the sample
#cmd("#BROWSE")). Give the option in upper case. In every case the
results are in #cmd("LISTALCDDN.")#var("n") and #cmd("LISTALCDSN.")#var("n"),
and LISTALC returns their number.

```
n = listalc('NOPRINT')
DO i=1 TO n
  SAY left(listalcddn.i,9) listalcdsn.i     /* e.g. RXLIB    BREXX.RXLIB */
END
```

The TSO command #cmd("LA") calls LISTALC (@lib-tsocmd-la).

=== LISTCAT <lib-rxlib-listcat>

#idx("LISTCAT", "function")
```
LISTCAT([level] [, filter])
```
Runs the TSO command #cmd("LISTCAT LEVEL(")#var("level")#cmd(")") into a
temporary data set and returns the names it lists in the stem
#cmd("LISTCAT."). #var("level") defaults to the user ID. #var("filter")
selects the entry types: #cmd("NONVSAM") (the default), #cmd("DSN")
(#cmd("NONVSAM CLUSTER DATA INDEX")), or a list of type names.
#cmd("DETAILS") instead returns the output lines of LISTCAT as they are,
and #var("level") is then passed to LISTCAT unchanged. LISTCAT needs TSO.

#note[*A defect* (brexx370 issue 386): the member returns the variable #cmd("LRC"), which it
never sets, so the value is the string #cmd("LRC"); and with
#cmd("DETAILS") it does not set #cmd("LISTCAT.0").]

```
CALL listcat 'SYS2'
DO i=1 TO listcat.0
  SAY listcat.i                   /* e.g. SYS2.CMDPROC */
END
```

=== LSTALL and LSTNCAT <lib-rxlib-lstall>

#idx("LSTALL")#idx("LSTNCAT")#idx("VTOC", "scan all volumes")
```
LSTALL([string])
LSTNCAT([prefix])
```
Both read the VTOC of every volume (with #cmd("LISTVOLS") and
#cmd("VTOC"), _BREXX/370 Reference_) and report with #cmd("SAY").
LSTALL lists every data set whose name contains #var("string"), sorted,
with the VTOC details, and the number found. LSTNCAT lists the data sets
whose name begins with #var("prefix") and which are not catalogued, or
are catalogued on another volume. Neither returns a value.

#cmd("VTOC") needs TSO, and #cmd("LISTVOLS") the #cmd("SVC244")
privilege and Hercules (_BREXX/370 Reference_). The samples LISTALL and LISTNCAT call these
members.

```
CALL lstall 'BREXX'
CALL lstncat 'SYS2.'
```

=== PDSDIR <lib-rxlib-pdsdir>

#idx("PDSDIR")
```
PDSDIR(dsname [, 0 | 1 | 'DETAILS' | 'REPORT'])
```
Reads the directory of the partitioned data set #var("dsname") and returns
the number of members, or #cmd("-8"). The member names are in
#cmd("PDSLIST.MEMBERNAME.")#var("n"). With #cmd("1") or #cmd("DETAILS"),
also the ISPF statistics: #cmd("PDSLIST.CREATEDATE."),
#cmd("PDSLIST.CHANGEDATE.") (Julian, #cmd("yyyyddd")) and
#cmd("PDSLIST.USERID.") (#cmd("?") when a member has none).
#cmd("REPORT") writes a list with #cmd("SAY").

#note[*A defect* (brexx370 issue 386): PDSDIR allocates the data set
with #cmd("RXDYNALC"), which is neither a built-in function nor a
member of RXLIB. The built-in function #cmd("DIR") returns the same
information (_BREXX/370 Reference_, "DIR").]

=== PDSRESET <lib-rxlib-pdsreset>

#idx("PDSRESET")
```
PDSRESET(dsname)
```
Deletes every member of the partitioned data set #var("dsname"),
reporting each with RXMSG. It needs TSO, in the foreground or in batch.
Returns #cmd("0"), #cmd("4") if a member could not be deleted, or
#cmd("8") if the name is missing or TSO is not there. The space of the
data set is not reclaimed: the compress that the old documentation
promised is commented out in the member.

```
CALL pdsreset 'MY.TEST.PDS'
```

=== PDSHASH <lib-rxlib-pdshash>

#idx("PDSHASH")
```
PDSHASH(dsname, member)
```
Returns the #cmd("RHASH") value of the first 16000 characters of
#var("dsname")#cmd("(")#var("member")#cmd(")") read as text, or
#cmd("-1") if it cannot be opened. Useful to see whether a member has
changed.

=== PERFORM <lib-rxlib-perform>

#idx("PERFORM")
```
PERFORM(dsname, exec [, p1 [, p2 [, p3 [, p4]]]])
```
Calls the exec #var("exec") once for each member of the partitioned data
set #var("dsname"), with #var("dsname") and the member name as its first
two arguments. #var("p1") to #var("p4") follow as further arguments; they
are put into the #cmd("CALL") without quotes, so each is evaluated as an
expression. A last argument #cmd("EOL") follows them. Returns the number
of members, or #cmd("-8") if the directory cannot be read.

```
CALL perform 'MY.EXEC','SHOWMEM'
...
/* member SHOWMEM */
PARSE ARG pds, mem
SAY pds'('mem')'
```

=== MVSCBS <lib-rxlib-mvscbs>

#idx("MVSCBS")#idx("control block", "address")
```
CALL IMPORT 'MVSCBS'
CVT()   TCB()   ASCB()  TIOT()  JSCB()  CSCB()  TSB()   CIB()
RMCT()  ASXB()  ACEE()  ECVT()  SMCA()  DSAB()  CPU()
```
A set of functions that return the address of an MVS control block, in
decimal: the CVT, the current TCB and ASCB, and the blocks reached from
them. #cmd("CPU()") returns the two bytes that lie six bytes before the
CVT, the processor model, in hexadecimal. The functions are routines of
the member, so it must be loaded first, with #cmd("IMPORT") or by calling
#cmd("MVSCBS()"), which returns #cmd("0"). The layouts of the control
blocks are in the IBM manuals _MVS Data Areas_.

```
CALL import 'MVSCBS'
SAY d2x(cvt())              /* the CVT address in hexadecimal */
```

=== TSOUSERS <lib-rxlib-tsousers>

#idx("TSOUSERS")
```
TSOUSERS([stem])
```
Puts the user IDs of the TSO users logged on into #var("stem") (default
#cmd("TSOUSER."), with the period) and their number into entry
#cmd("0"); it scans the address space vector table. Returns #cmd("0").

```
CALL tsousers
DO i=1 TO tsouser.0; SAY tsouser.i; END
```

=== JESQUEUE <lib-rxlib-jesqueue>

#idx("JESQUEUE")#idx("JES2", "queue")
```
JESQUEUE()
```
Returns the jobs in the JES2 queues as a string array (_BREXX/370
Reference_, "SCREATE"), sorted, one line per job: job name, job number
(#cmd("JOB"), #cmd("STC") or #cmd("TSU") and five digits), queue and
hold status. It issues the JES2 commands #cmd("$DA,ALL") and
#cmd("$DN") with #cmd("CONSOLE") and reads the answer from the master
trace table, so it needs the authority for console commands. Returns
#cmd("-8"), after the message #cmd("No Spool available"), if no answer
was found. Free the array with #cmd("SFREE").

```
spool = jesqueue()
IF spool > 0 THEN CALL slist spool
/* e.g. 00001   BRXCLEAN   JOB04378  PRTPUN  ANY
        00002   INIT       STC01187  OUTPUT          */
```

The JES2 spool viewer is built on it (@lib-apps).

=== RXCONSOL <lib-rxlib-rxconsol>

#idx("RXCONSOL")#idx("operator command", "with output")
```
RXCONSOL(command [, [wait] [, 'STEM']])
```
Issues the operator command #var("command") with #cmd("CONSOLE"), waits
#var("wait") milliseconds (default 300) and collects the command and its
reply from the master trace table into the stem #cmd("CONSOLE."). Returns
#cmd("0"), or #cmd("8") if the command was not found in the trace table.
By default the trace table is read into a string array; #cmd("STEM")
reads it with #cmd("MTT") instead, which is slower.

```
IF rxconsol('D A,L') = 0 THEN
  DO i=1 TO console.0; SAY console.i; END
```

The sample CONSOLE does the same (@lib-samples).

=== NJE38CMD <lib-rxlib-nje38cmd>

#idx("NJE38CMD")#idx("NJE38")
```
NJE38CMD(command)
```
Sends #var("command") to the NJE38 started task as
#cmd("F NJE38,")#var("command") (a leading word #cmd("NJE38") is
dropped) and returns its reply lines in the stem #cmd("NJE38."). Returns
#cmd("0"), #cmd("8") if the command failed, or #cmd("12") if no NJE38
reply was found. It uses RXCONSOL.

```
IF nje38cmd('NJE38 D FILES') = 0 THEN
  DO i=1 TO nje38.0; SAY nje38.i; END
```

=== NJE38DSN <lib-rxlib-nje38dsn>

#idx("NJE38DSN")
```
NJE38DSN('ALLOC' | 'FREE')
```
#cmd("ALLOC") allocates the NJE38 spool data set to the DD name
#cmd("NETSPOOL"). Its name is taken from the global variable
#cmd("NETSPOOL") or from #cmd("MVSVAR('NJEDSN')"), and kept in the
global variable. Returns the return code of the allocation, or #cmd("8")
with #cmd("ZERRSM") and #cmd("ZERRLM") set. #cmd("FREE") frees the DD
name.

=== MTTSCAN <lib-rxlib-mttscan>

#idx("MTTSCAN")#idx("master trace table", "watch")
```
MTTSCAN('REGISTER', text, routine)
MTTSCAN('SCAN' [, interval])
```
Watches the master trace table. #cmd("REGISTER") makes MTTSCAN call
#var("routine") with every new trace-table line that contains
#var("text"). #cmd("SCAN") then reads the trace table every
#var("interval") milliseconds (default 5000) until a line contains
#cmd("TTSCAN STOP"); the sample MTTSTOP writes that line with
#cmd("WTO"), from any user. Both write a #cmd("WTO") at start and stop.
The registrations are kept in the stem #cmd("TTREG."), which the
caller must not drop.

```
CALL mttscan 'REGISTER','$HASP373','JOBSTART'
CALL mttscan 'SCAN',2000
EXIT
jobstart: SAY 'started:' arg(1); RETURN
```

The sample MTTSCANT registers LOGON and LOGOFF messages.

=== RXISPF <lib-rxlib-rxispf>

#idx("RXISPF")
```
RXISPF(option)
```
Clears the screen and starts an ISPF function with
#cmd("ADDRESS ISPEXEC SELECT"): #cmd("0") settings, #cmd("1") browse,
#cmd("2") edit, #cmd("3") utilities, #cmd("3.1") to #cmd("3.4") and
#cmd("3.8") through RFE and REVIEW, #cmd("4") foreground, #cmd("6")
command; anything else, the primary menu. It needs ISPF, and RFE and
REVIEW for the #cmd("3.")#var("n") options.

== Printing <lib-rxlib-print>

=== PRINT <lib-rxlib-printfn>

#idx("PRINT")#idx("SYSOUT", "print to")
```
CALL PRINT '$ONTO', class
CALL PRINT [action,] line
CALL PRINT '$TITLE', title
CALL PRINT '$PAGE'
CALL PRINT '$HEADER', 'ON' | 'OFF'
CALL PRINT '$BANNER', text
CALL PRINT '$CLOSE'
```
Prints to a SYSOUT data set with page breaks. #cmd("$ONTO") allocates
the DD name #cmd("SYSOUT") to SYSOUT class #var("class") with
#cmd("RECFM=VBA"), #cmd("LRECL=123"), using the TSO commands
#cmd("ATTR") and #cmd("ALLOC"), so PRINT needs TSO. A page has 60 lines;
a line longer than the record is cut. Each new page begins with
#var("title"), in which #cmd("&page") is replaced by the page number.

If the calling exec has a label #cmd("$PRINT_header"), it is called after
each title line to print further heading lines; #cmd("$HEADER OFF")
suppresses that call. #var("action") before a line is #cmd("$SKIP")
(an empty line first), #cmd("$NOSKIP") (print over the previous line) or
#cmd("$BOLD") (print the line twice). #cmd("$PAGE") (or #cmd("$EJECT"))
starts a new page, #cmd("$BANNER") prints #var("text") in large letters
with PRTBANNR, and #cmd("$CLOSE") closes and frees the file. A line
printed before #cmd("$ONTO") stops the exec with a message.

```
CALL print '$ONTO','A'
CALL print '$TITLE','My report                page &page'
CALL print 'first line'
CALL print '$SKIP','after an empty line'
CALL print '$CLOSE'
```

=== PRTBANNR and FMTBANNR <lib-rxlib-banner>

#idx("PRTBANNR")#idx("FMTBANNR")#idx("banner")
```
PRTBANNR(text [, [width] [, char]])
FMTBANNR(text [, [width] [, char]])
```
Both draw #var("text") in large letters made of #var("char") (default
#cmd("*")), with the font of the BREXX sample BANNER by Vasilis
Vlachoudis. PRTBANNR prints the lines with PRINT, which must have been
opened with #cmd("$ONTO"); #var("width") is not used. FMTBANNR puts 17
lines into the stem #cmd("BUFFER."), for FMTLIST, centred in
#var("width") columns (default 80) unless the variable #cmd("FSSSHIFT")
gives the indentation.

== Arithmetic and Matrices <lib-rxlib-math>

=== GCD and LCM <lib-rxlib-gcd>

#idx("GCD")#idx("LCM")
```
GCD(n1, n2 [, n3] ...)
LCM(n1, n2 [, n3] ...)
```
Return the greatest common divisor and the least common multiple of
whole numbers; fractions are truncated.

```
SAY gcd(12,18,27)          /* 3 */
SAY lcm(4,6,10)            /* 60 */
```

=== PFACTOR <lib-rxlib-pfactor>

#idx("PFACTOR")#idx("prime factor")
```
PFACTOR(number)
```
Puts the prime factors of #var("number") into the stem #cmd("PRIMES."),
smallest first, and returns their number. It also writes #var("number")
with #cmd("SAY") (a defect, brexx370 issue 386).

```
n = pfactor(360)           /* says 360 */
SAY n primes.1 primes.6    /* 6 2 5 */
```

=== MATIN, MPRINT, MCOREL and REGRESSN <lib-rxlib-matrix>

#idx("MATIN")#idx("MPRINT")#idx("MCOREL")#idx("REGRESSN")#idx("matrix")
```
MATIN(dsname [, 'DELIM'])
MPRINT(matrix [, [label] [, [title] [, half]]])
MCOREL(matrix [, 1])
REGRESSN(x, y [, debug])
```
Statistics on the matrices of the interpreter (_BREXX/370 Reference_,
"MCREATE").

MATIN reads a matrix from #var("dsname"): the first line holds the column
titles, the following lines the rows, one number per column. With
#cmd("DELIM"), the titles are the line after #cmd("$DATA") and the rows
end before #cmd("$ENDDATA"). It returns the matrix, with the titles in
#cmd("MTITLE.")#var("matrix")#cmd(".")#var("k"). If the data set cannot
be allocated, the exec ends with return code 8.

MPRINT prints a matrix, at most 15 columns and the first and last 50 rows
of a longer one, headed by #var("title"); #var("label") is printed beside
each row. With #var("half"), a square matrix prints only its lower
triangle. In batch the lines are written with #cmd("SAY"); under TSO they
are added to the stem #cmd("BUFFER."), for FMTLIST. Returns #cmd("4") if
#var("matrix") is not a number.

MCOREL returns the correlation matrix of the columns of #var("matrix");
#cmd("1") prints the steps. REGRESSN computes a linear regression of
#var("y"), a one-column matrix, on the columns of #var("x"), and puts the
factors into #cmd("_REGRESSION.1") (the constant) to
#cmd("_REGRESSION.")#var("n"); it returns #cmd("0"). The samples CORELT
and REGRESST use them.

```
m0 = matin('MY.DATA(HOUSING)','DELIM')
m1 = mcorel(m0)
CALL mprint m1,,'Correlation Matrix','HALF'
```

== Formatted Screens and Servers <lib-rxlib-screens>

=== FMTCOLUM <lib-rxlib-fmtcolum>

#idx("FMTCOLUM")
```
FMTCOLUM(columns, title, text1 [, text2] ...)
```
Displays a formatted screen with one input field after each
#var("text"), arranged in #var("columns") columns, and returns the key
that ended the dialog (#cmd("PF03") and #cmd("PF04") end it). The input
is in #cmd("_SCREEN.INPUT.")#var("n"). It uses the FSS API
(@lib-fssmenu); the samples #cmd("#FSS1COL") to #cmd("#FSS4CLX") show it.

```
k = fmtcolum(2,'Two Columns','Name ===>','City ===>')
SAY _screen.input.1 _screen.input.2
```

=== FMTLISTC <lib-rxlib-fmtlistc>

#idx("FMTLISTC")
```
FMTLISTC([caller])
```
Calls FMTLIST to display the stem #cmd("BUFFER.") with heading lines from
the variables #cmd("_FMTHEADER") and #cmd("_FMTHEADER2"), the footer
#cmd("_FMTFOOTER") and a message line. #var("caller") names the exec
whose line commands FMTLIST calls back; it defaults to the calling exec.
FMTLIST is described in @lib-fssmenu.

=== MTTLOG <lib-rxlib-mttlog>

#idx("MTTLOG")
```
MTTLOG([filter])
```
Shows the master trace table on a formatted screen that refreshes
itself, newest line first and coloured by kind. On the command line,
#cmd("@")#var("text") sends #var("text") to the console with #cmd("WTO"),
#cmd("/S") #var("word") ... shows only the lines that contain the words,
#cmd("/T") #var("ms") changes the refresh interval, #cmd("/HB")
#var("seconds") writes a heartbeat #cmd("WTO") at that interval, and
anything else is issued as an operator command. #var("filter") names a
function that is given the string array of lines and returns the array
to show. MTTLOG is built on FMTMON (@lib-fssmenu).

=== TCPSF <lib-rxlib-tcpsf>

#idx("TCPSF")
#cmd("TCPSF(")#var("port")#cmd(" [, ")#var("timeout")#cmd(" [, ")#var("name")#cmd(" [, ")#var("level")#cmd("]]])")
runs a complete TCP server and calls back labels of the calling exec for
each event. It is described with the TCP functions in the _BREXX/370
Reference_ ("TCPSF"). The sample #cmd("$TCPSERV") uses it.

=== NJE38DIR <lib-rxlib-nje38dir>

#idx("NJE38DIR", "RXLIB member")
The NJE38 spool browser, an application on FMTLIST. It is started with
the TSO command #cmd("NJE38DIR") and described there
(@lib-tsocmd-nje38dir).

== Members Described Elsewhere <lib-rxlib-others>

#idx("RXLIB", "members described elsewhere")
These members of RXLIB are described in other chapters:

#tab(caption: [RXLIB members described in other chapters])[
  #table(columns: (2.1in, 1fr),
    [Members], [Described in],
    [FSSAPI, FSSMENU, FMTMENU, FMTLIST, FMTMON, FMTMONAR, FMTMONX,
      FSSCREEN], [@lib-fssmenu, formatted screens],
    [FSSDASH, FSSTICKY, STDASH, STICKY, STICKYDF, STICKYDS, STICKYSH,
      DSHAPI, DSHHDR, DSHHDR2, DSHHDR3, DSHINFO, DSHMTT, DSHPOP1, DSHREGN,
      DSHSMSG, DSHTIME, DSHTSO, DSHUSER, SETHDR, SETHDR2, SETHDR3, SETINFO,
      SETPOP1, SETSMSG, STMTT, STREGION, STSMSG, STTIME, STTSO, STUSER],
      [@lib-fssmenu: the dashboard and the "sticky notes" shown on
      formatted screens. Each #cmd("DSH")#var("xxx") and
      #cmd("ST")#var("xxx") member defines one note; the
      #cmd("SET")#var("xxx") members set the text of one.],
    [KEYVALUE, DBPROF], [@lib-kv, the key/value database],
    [RXCOPY, RXDIFF], [@lib-apps],
    [STARGATE, STARG2MV, STARGDLI, STARGFSS, STARGLCT, STARGMEN, STARGRCF,
      STARGSEL, STARGSL2, STARGSL3, STARGSND, STARGSPL, STARGSUB, STARGSYS,
      SGLDSI, SGPDSLSX, SGSYS1, SHUTD], [@lib-apps, the data exchange
      between systems (Stargate)],
  )
] <lib-rxlib-others-tab>

Two files of the RXLIB directory are not REXX: BUILD.REXX is a note on
the last synchronisation of the library with the source repository, and
README.md describes the directory.

== Functions Built into the Interpreter <lib-rxlib-moved>

#idx("RXLIB", "functions moved into the interpreter")
Earlier editions listed these functions as RXLIB members. In BREXX/370
3.0 they are part of the interpreter, written in REXX and carried in the
load module, and are described in the _BREXX/370 Reference_:

#deflist(width: 1.2in,
  [#cmd("SEC2TIME")], [Converts seconds into #cmd("hh:mm:ss"), or into
    days and #cmd("hh:mm:ss"). The member SECTIMEO is its old copy.],
  [#cmd("STEMCOPY")], [Copies a stem into another.],
)
