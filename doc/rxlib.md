# RXLIB functions

BREXX can implement new functions or commands in REXX. They are
transparent and are called in the same way as basic BREXX functions.
They are stored in the library BREXX.RXLIB and are automatically
allocated (via DD RXLIB) in RXBATCH and RXTSO (Batch). In this
release, BREXX delivers the following functions.

### RXCOPY(source-dsn, target-dsn)

Copies a source dataset to a target dataset using the internal IEBCOPY or
REPRO command. You can optionally define a target volume and the REPLACE
option. As IEBCOPY requires an authorised mode, it can only run in ISPF
environment, if it is also authorised. If not, you can run it in plain
TSO command mode.

```rexx
RXCOPY  pej.tempfb, pej.tempfb.copy,PEJ001
```

Results:

> DSN PEJ.TEMPFB is sequential, invoke REPRO
> Create ‘PEJ.TEMPFB.COPY’ with DSORG=PS,RECFM=FB,UNIT=SYSDA,LRECL=80,BLKSIZE=6400,PRI=1,SEC=1,VOLSER=PEJ001
> ‘PEJ.TEMPFB.COPY’ successfully created
> NUMBER OF RECORDS PROCESSED WAS 318

### JES2QUEUE()

Returns the current content of the JES2 queue in an SARRAY

```rexx
spool=JESQUEUE()
call slist spool
exit
```

Results:

```default
     Entries of Source Array: 1
Entry   Data
-------------------------------------------------------
00001   BRXCLEAN   JOB04378  PRTPUN  ANY
00002   BRXKEYAC   JOB04326  PRTPUN  ANY
00003   BRXLINK    JOB04376  PRTPUN  ANY
00004   BRXLINK    JOB04379  PRTPUN  ANY
00005   BRXXBLD    JOB04380  PRTPUN  ANY
00006   BSPPILOT   STC01186  OUTPUT
00007   HERC01C    JOB03584  PRTPUN  ANY
00008   HERC01C    JOB03585  PRTPUN  ANY
00009   INIT       STC01187  OUTPUT
00010   INIT       STC01188  OUTPUT
00011   INIT       STC01189  OUTPUT
00012   INIT       STC01190  OUTPUT
00013   INIT       STC01191  OUTPUT
00014   INIT       STC01192  OUTPUT
00015   MFFBUILD   JOB03151  PRTPUN  HOLD
00016   MIGTEST    JOB04268  PRTPUN  ANY
00017   MVSMF      STC01140  PRTPUN  HOLD
00018   MVSMF      STC01142  PRTPUN  HOLD
00019   MVSMF      STC01147  PRTPUN  HOLD
00020   MVSMF      STC01153  PRTPUN  HOLD
00021   MVSMF      STC01173  PRTPUN  HOLD
00022   MVSMF      STC01174  PRTPUN  HOLD
00023   MVSMF      STC01199  OUTPUT
00024   MVSMF      STC01202  PRTPUN  ANY
00025   NET        STC01195  OUTPUT
00026   NJE38      STC01198  OUTPUT
00027   PEJ        TSU00860  PRTPUN  HOLD
00028   PEJ        TSU01002  OUTPUT
00029   PEJTEMP    JOB04201  PRTPUN  ANY
00030   PEJ1       TSU01303  PRTPUN  ANY
00031   PRINTPDS   JOB03250  PRTPUN  HOLD
00032   PRINTPDS   JOB04003  PRTPUN  ANY
00033   STCRX      STC01287  PRTPUN  ANY
00034   STCRX      STC01288  PRTPUN  ANY
00035   SUBTASM    JOB03150  PRTPUN  HOLD
00036   SYSLOG     STC01155  PRTPUN  HOLD
00037   SYSLOG     STC01185  OUTPUT
00038   TSO        STC01196  OUTPUT
38 Entries
```

### RXMSG(msg-number, 'msg-level', 'message')

Standard message module to display a message in a formatted way

* **Parameters:**
  * **msg-number** – message number to be displayed
  * **msg-level** – One of: I, W, E, C

message level can be:

| Message Level   | Description                |
|-----------------|----------------------------|
| I               | for an information message |
| W               | for a warning message      |
| E               | for an error message       |
| C               | for a critical message     |

Example:

```rexx
rc=rxmsg( 10,'I','Program started')
rc=rxmsg(200,'W','Value missing')
rc=rxmsg(100,'E','Value not Numeric')
rc=rxmsg(999,'C','Divisor is zero')
```

Results:

```default
RX0010I    PROGRAM STARTED
RX0200W    VALUE MISSING
RX0100E    VALUE NOT NUMERIC
RX0999C    DIVISOR IS ZERO
```

Additionally, the following REXX variables are maintained and can be
used in the calling REXX script.

Return code from call **RXMSG**:

|   Return Code | Description                        |
|---------------|------------------------------------|
|             0 | an information message was written |
|             4 | a warning message was written      |
|             8 | an error message was written       |
|            12 | a critical message was written     |

**MSLV** contains the written message level

> | Message Level   | Description                |
> |-----------------|----------------------------|
> | I               | for an information message |
> | W               | for a warning message      |
> | E               | for an error message       |
> | C               | for a critical message     |

**MSTX** contains the written message text part

**MSLN** includes the complete message with the message number,
message level and text

**MAXRC** contains the highest return code so far; this can be used
to exit the top level REXX. If you used nested procedures, it is
required to expose MAXRC, to make it available in the calling
procedures.

### DCL('field-name', length)

Defines a structure of fields which maps typically to an I/O record.
The function returns the next available offset in the structure.

Initialize the function with DCL(‘$DEFINE’,’structure-name’)
where:

- $DEFINE initialises the structure definition
- structure-name all following field definitions are associated
  with the structure-name.

* **Parameters:**
  * **field-name** – name of the rexx variable containing/receiving
    the field content of the record
  * **offset** – offset of the field in the record. This definition is
    optional if left out the next offset from the previous
    DCL(field…) definition is used, or 1 if there was none.
  * **length** – length if the field in the record
  * **type** – field-type either  **CHAR** no translation takes place,
    CHAR is default or **PACKED** decimal Packed field. Translation
    into/from Decimal packed into Numeric REXX value takes place

call SPLITRECORD ‘structure_name,record-to-split splits
record-to-split in the defined field-names (aka REXX variables). The
variable containing the record to split is typically read from a
dataset.

Record=SETRECORD(‘student’) combines the content of all defined
fields (aka REXX variables) at the defined position and the defined
length to a new record.

Example:

```rexx
 n=DCL('$DEFINE','student')
 n=DCL('Name',1,32,'CHAR')
 n=DCL('FirstName',1,16,'CHAR')
 n=DCL('LastName',,16,'CHAR')
 n=DCL('Address',,32,'CHAR')
 recin='Fred            Flintstone      Bedrock'
 /*    '12345678901234567890123456789012345678901234567890 */
 call splitRecord 'student',recin
 say Name
 say FirstName
 say LastName
 say Address
 firstName='Barney'
 LastName='Rubble'
 address='Bedrock'
 say setRecord('student')
```

Results:

```default
FRED            FLINTSTONE
FRED
FLINTSTONE
BEDROCK
BARNEY          RUBBLE          BEDROCK
```

### DAYSBETW(date1, date-2)

Return days between 2 dates of a given format.

* **Parameters:**
  * **format-date1** – date format of date1 defaults to European
  * **format-date2** – date format of date2 defaults to European

the format-dates reflect the Input-Format of DATE and can be found
in details there.

### DUMP(string)

Displays string as a Hex value, useful to check if a received a
string contains unprintable characters. One can specify hdr as an
optional title.

Example:

```rexx
CALL DUMP 'THIS IS THE NEW VERSION OF BREXX/370 V2R5M3','DUMP LINE'
```

Results:

```default
DUMP LINE
0000(0000)  THIS  IS  THE  NEW    VERS ION  OF B REXX
0000(0000)  ECCE 4CE4 ECC4 DCE4   ECDE CDD4 DC4C DCEE
0000(0000)  3892 0920 3850 5560   5592 9650 6602 9577

0032(0020)  /370  V2R 1M0
0032(0020)  6FFF 4EFD FDF
0032(0020)  1370 0529 140
```

### LISTALC()

Lists all allocated Datasets in this session or region.

Example:

```rexx
CALL LISTALC
```

Results:

```default
STDOUT    *terminal
STDIN     *terminal
SYSPROC   SYS1.CMDPROC
SYSHELP   SYS1.HELP
          SYS2.HELP
SYS00002  UCPUB001
RXLIB     BREXX.V2R5M3.RXLIB
SYSEXEC   SYS2.EXEC
SYS00005  UCPUB000
ISPPROF   IBMUSER.ISP.PROF
ISPMLIB   SYSGEN.ISPF.MLIB
STDERR    *terminal
ISPSLIB   SYSGEN.ISPF.SLIB
ISPCLIB   SYSGEN.ISPF.CLIB
          SYSGEN.REVIEW.CLIST
ISPLLIB   SYSGEN.ISPF.LLIB
          SYSGEN.REVIEW.LOAD
ISPTABL   SYSGEN.ISPF.TLIB
ISPPLIB   SYSGEN.ISPF.PLIB
          SYSGEN.ISPF.RFEPLIB
ISPTLIB   SYSGEN.ISPF.TLIB
REVPROF   IBMUSER.ISP.PROF
SYS00012  SYSGEN.ISPF.LLIB
SYS00013  IBMUSER.CLIST
```

### LISTCAT()

Returns listcat output in the stem LISTCAT.

### LISTALL(<list-cat-parameter>)

List all datasets in the system by scanning all VTOCs.

### LISTNCATL(<list-cat-parameter>)

List all not catalogued datasets in the system by scanning all VTOCs.

### MVSCBS()

Allows addressing of some MVS control blocks. There are several
dependent control blocks combined. To use them, MVSCBS must be
imported first. After that, they can be used.

Currently integrated control blocks are:
- CVT()
- TCB()
- ASCB()
- TIOT()
- JSCB()
- RMCT()
- ASXB()
- ACEE()
- ECT()
- SMCA()

The definition and the content of the MVS control blocks can be
found in the appropriate IBM manuals: MVS Data Areas, Volume 1 to 5.

IMPORT command is described in Vassilis N. Vlachoudis BREXX
documentation: [http://home.cern.ch/~bnv](http://home.cern.ch/~bnv)

### QUOTE(string, qtype)

Enclose string in quotes, double quotes, or parenthesis,

* **Parameters:**
  **qtype** – can be:

- ‘ single quote (default),
- “ double quote
- ( bracket, the closing character is ‘)’
- [ square bracket, the closing character is ‘]’

Example:

```rexx
 Mystring='string to be quoted'
 Say QUOTE(mystring,'"')
 Say QUOTE(mystring,"'")
 Say QUOTE(mystring,'(')
 Say QUOTE(mystring,'[')
```

Results:

```default
'STRING TO BE QUOTED'
'STRING TO BE QUOTED'
(STRING TO BE QUOTED)
[STRING TO BE QUOTED]
```

### PDSRESET(pds-name)

Removes all members of a PDS and runs a compress. After execution,
the PDS is empty.

### READALL(file, variable)

Reads the entire file into a stem variable. The file can be either a
dd-name or a ds-name. After successful completion, the stem
variable.0 contains the number of lines read into the stem. The
file name can either represent an allocated dd name or a fully
qualified DSN. The third parameter defines the file type and is
either DSN or DDN. If it is missing DDN is the default.

### PERFORM(pds-name, process-member-rexx)

Reads member list of a PDS and runs the process-member-rexx against
each member. The REXX to be called receives the parameters:

- Pds-name
- Member-name

### RXSORT(sort-type)

Sorts the stem variable SORTIN. SORTIN.0 must contain the number of
entries of SORTIN. The sort algorithms supported are: QUICKSORT,
SHELLSORT, HEAPSORT, BUBBLESORT. After Completion of RXSORT the
stem variable SORTIN. is sorted. If you requested ASCENDING (also
default) it is in ascending order, for DESCENDING in descending
order.

Sorting with REXX is only recommended for a small number of stem
entries. Up to 1000 entries, RXSORT works in a reasonable time.

If the stem you want to sort is not in SORTIN, you can use the
SORTCOPY function to copy it over to SORTIN.

### SEC2TIME(seconds)

Converts a number of seconds into the format hh:mm:ss, or days
hh:mm:ss if the ‘DAYS’ parameter is specified.

Example:

```rexx
say sec2Time(345000)
say sec2Time(345000,'DAYS')
```

Results:

```default
95:50:00
3 day(s) 23:50:00
```

### SORTCOPY(stem-variable)

Copies any stem variable into the stem SORTIN., which then can be
used by RXSORT. Stem-variable.0 must contain the number of entries
of the stem.

### STEMCOPY(source-stem-variable, target-stem-variable)

Copies any stem variable into another stem variable.
source-stem-variable.0 must contain the number of entries of the
stem. Stem-variables must end with a trailing ‘.’, e.g. mystem.

### STEMCLEN(stem-variable)

Cleansing of a stem variable, it removes empty and unset stem items
and adjusts the stem numbering. Stem-variable.0 must contain the
number of entries of the stem and will after the cleansing the
modified number of entries. Stem-variables must end with a
trailing ‘.’, e.g. mystem.

### STEMGET(dataset-name)

Reads the saved content of one or more stem variables and re-apply
the stem. Stem names are save in the dataset.

### STEMINS(stem-to-insert, insert-into-stem, position)

Inserts stem-to-insert into insert-into-stem beginning at position.
The content of the original stem at the position is shifted down n
positions, whereby n is the size of the stem to be inserted.
Stem-variable(s).0 must contain the number of entries of the stem.
Stem-variables must end with a trailing ‘.’, e.g. mystem.

### STEMPUT(dataset-name,stem1[,stem2{,stem3]...)

Saves the content of one or more stems in a fully qualified
dataset-name Stem-variable.0 must contain the number of entries of
the stem. Stem-variables must end with a trailing ‘.’, e.g.
mystem.

### STEMREOR(stem-variable)

reorders stem variable from top to bottom.

1. element becomes last,
2. next to last, etc.

Stem-variable.0 must contain the number of entries of the stem.
Stem-variables must end with a trailing ‘.’, e.g. mystem.

### TODAY([output_date_format[,date[,input_date_format]]) [date-format])

Returns today’s date based on the requested format. You can also use
a date which is in the past or the future. Details of date-formats
can be found in the DATE output-format description.

### UNQUOTE(string)

Remove from string leading and trailing quotes, double quotes,
parenthesis and ‘<’ and ‘>’ signs.

Example:

```rexx
 Say UNQUOTE(" 'quoted-string' ")
 Say UNQUOTE("<entry 1>")
 Say UNQUOTE("(entry 2)")
 Say UNQUOTE("[entry 3]")
```

Results:

```default
'QUOTED-STRING'
ENTRY 1
ENTRY 2
ENTRY 3
```

### WRITEALL(file, variable)

Writes a stem variable into a file. The file can be either a dd-name
or a ds-name. The stem variable.0 must contain the number of entries
of the stem. The file name can either represent an allocated dd name
or a fully qualified DSN. The third parameter defines the file type
and is either DSN or DDN. If it is missing DDN is the default.
