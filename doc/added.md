# Added BREXX Kernel functions and Commands

These are MVS-specific BREXX functions implemented and integrated into
the BREXX kernel code. For the standard BREXX functions take a look into
the BREXX User’s Guide.

#### NOTE
When reading the function descriptions between parentheses the
argument/parameter is required unless surrounded by [] brackets.

## Functions

### ABEND(user-abend-code)

ABEND Terminates the program with specified User-Abend-Code. Valid
values for the user evening abend-code are values between 0 and 4095.

* **Parameters:**
  **user-abend-code** – specified User-Abend-Code
* **Return type:**
  n/a

### AFTER(search-string, string)

> The remaining portion of the string that follows the first
> occurrence of the search-string within the string. If search-string
> is not part of string an empty string is returned.
* **Parameters:**
  * **search-string** – search string
  * **string** – string to search
* **Return type:**
  string

### A2E(ascii-string)

> Translates an ASCII string into EBCDIC. Caveat: not
> all character translations are biunique!
* **Parameters:**
  **ascii-string** – string to translate
* **Return type:**
  string

### E2A(ebcdic-string)

> Translates an EBCDIC string into ASCII. Caveat: not
> all character translations are biunique!
* **Parameters:**
  **ebcdic-string** – string to translate
* **Return type:**
  string

### BEFORE(search-string, string)

The portion of the string that precedes the first occurrence of
search-string within the string. If search-string is not part of
string an empty string is returned.

* **Parameters:**
  * **search-string** – search string
  * **string** – string to search
* **Return type:**
  string

Example:

```rexx
string='The quick brown fox jumps over the lazy dog'
say 'String                 'string
say 'Before Fox             'before('fox',string)
say 'After Fox              'after('fox',string)
```

Result:

```default
STRING                 THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG
BEFORE FOX             THE QUICK BROWN
AFTER FOX               JUMPS OVER THE LAZY DOG
```

### BLDL(program-name)

Reports 1 if the program is callable via the active program library
assignments (STEPLIB, JOBLIB, etc. DD statements). If it is not
found, 0 is returned.

* **Parameters:**
  **program-name** – program name
* **Return type:**
  int

### BASE64ENC(string)

Encodes a string or a binary string into a Base 64 encoded string. It
is not an encryption process; it is, therefore, not usable for
storing passwords.

* **Parameters:**
  **string** – string to encode
* **Return type:**
  string

### BASE64DEC(base64-string)

Decodes a base64 string into a string or binary string.

* **Parameters:**
  **base64-string** – string to decode
* **Return type:**
  string

Example:

```rexx
str='The quick brown fox jumps over the lazy dog'
stre=base64Enc(str)
say 'Encoded 'stre
strd=base64Dec(stre)
say 'Original "'strd'"'
say 'Decoded "'strd'"'
```

Result:

```default
Encoded 44iFQJikiYOSQIKZlqaVQIaWp0CRpJSXokCWpYWZQKOIhUCTgamoQISWhw==
Original "The quick brown fox jumps over the lazy dog"
Decoded "The quick brown fox jumps over the lazy dog"
```

### B2C(bit-string)

Converts bit string into a Character string

* **Parameters:**
  **bit-string** – string to decode
* **Return type:**
  string

Examples:

```default
say B2C('1111000111110000') -> 10
say B2c('1100000111000010') -> AB
```

### C2B(character-string)

Converts a character string into a bit string

Example:

```default
say c2x('64'x) c2B('64'x) -> 64 01100100
say c2x(10) c2B(10)       -> F1F0 1111000111110000
say c2x('AB') c2B('AB')   -> C1C2 1100000111000010
```

### C2U(character-string)

Converts a character string into an unsigned Integer string

Example:

```default
say c2d(' B5918B39'x) -1248752839
say c2u(' B5918B39'x) 3046214457
```

### D2P(number, length)

D2P converts a number (integer or float) into a decimal packed
field. The created field is in binary format. The fraction digit
parameter is non-essential, as the created decimal does not contain
any fraction information, for symmetry reasons to the P2D function
it has been added.

### P2D(number, length, fraction-digit)

P2D converts a decimal packed field (binary format) into a number.

### CEIL(decimal-number)

CEIL returns the smallest integer greater or equal than the decimal number.

### CONSOLE(operator-command)

Performs an operator command, but does not return any output. If you
need the output for checking the result, please use the RXCONSOL
function.

### ENCRYPT(string, password)

Encrypts a string via a password. The encryption/decryption method
is merely XOR-ing the string with the password in several rounds.
This means the process is not foolproof and has not the quality of
an RSA encryption.

### DECRYPT(string, password)

Decrypts an encrypted string via a password.
The encryption/decryption method is merely XOR-ing the string with
the password in several rounds. This means the process is not
foolproof and has not the quality of an RSA encryption.

Example:

```rexx
a10='The quick brown fox jumps over the lazy dog'
a11=encrypt(a10,"myPassword")
a12=decrypt(a11,"myPassword")
say "original "a10
say "encrypted "c2x(a11)
say "decrypted "a12
```

Result:

```default
original The quick brown fox jumps over the lazy dog
encrypted E361A8D7F001D537D0D6CDCAF9EFD83CCA00F984897FBD538AAF964CA80E2806D4310205CEFAC709C9EACB43
decrypted The quick brown fox jumps over the lazy dog
```

### DEFINED('variable-name')

Tests if variable or STEM exists, to avoid variable substitution, the variable-name must be enclosed in quotes.
return values:

|   Return Value | Description                                          |
|----------------|------------------------------------------------------|
|             -1 | not defined, but would be an invalid variable name   |
|              0 | variable-name is not a defined variable              |
|              1 | variable-name is defined it contains a string        |
|              2 | variable-name is defined it contains a numeric value |

To test whether a variable is defined, you can use:
If defined(‘myvar’)> 0 then ..

### DUMPIT(address, dump-length)

DUMPIT displays the content at a given address of a specified length
in hex format. The address must be provided in hex format;
therefore, a conversion with the D2X function is required.

Example:

```rexx
call mvscbs
/* load MVS CB functions */
call dumpit d2x(tcb()),256
```

Result:

```default
009B8148 (+00000000) | 009AE448 00000000 009AD99C 009BF020 | ..U.......R...0.
009B8158 (+00000010) | 00000000 00000000 009B2578 80000000 | ................
009B8168 (+00000020) | 0000FFFF 009C7C88 0013B908 00000000 | ......@h........
009B8178 (+00000030) | 40D871C0 009DA1E0 002C13C0 002C1434 |  Q.{...\...{....
009B8188 (+00000040) | 002C1434 002C30A8 00000085 009ADA3C | .......y...e....
009B8198 (+00000050) | 00000002 00158000 00262F88 4025EBD0 | ...........h ..}
009B81A8 (+00000060) | 00BF52C0 0027F268 4026306E 00000000 | ...{..2. ..>....
009B81B8 (+00000070) | 001D4FB8 00000000 00000000 009DC330 | ..|...........C.
009B81C8 (+00000080) | 00000000 009B8730 00000000 00000000 | ......g.........
009B81D8 (+00000090) | 001D3048 00000000 009DF548 00000000 | ..........5.....
009B81E8 (+000000A0) | 009B23C4 809D5F88 00000000 00000000 | ...D..¬h........
009B81F8 (+000000B0) | 00000000 009DC6EC 00000000 00000000 | ......F.........
009B8208 (+000000C0) | 00000000 00000000 00000000 00000000 | ................
009B8218 (+000000D0) | 009B8270 00000000 00000000 009B8730 | ..b...........g.
009B8228 (+000000E0) | 00000000 00000000 00000000 00000000 | ................
009B8238 (+000000F0) | 80000040 00000000 009B2E58 00000000 | ... ............
```

### DUMPVAR('variable-name')

DUMPVAR displays the content of a variable or stem-variable in hex
format; the displayed length is variable-length +16 bytes. The
variable name must be enclosed in quotes. If no variable is
specified, all so far allocated variables are printed.

Example:

```rexx
v21.1='Stem Variable, item 1'
v21.2='Stem Variable, item 2'
v21.3='Stem Variable, item 3'
call DumpVAR('v21.1')
```

Result:

```default
002C2818 (+00000000) | E2A38594 40E58199 89818293 856B4089 | Stem Variable, i
002C2828 (+00000010) | A3859440 F1000000 00000000 00000000 | tem 1...........
```

### DATE()

The integrated DATE function replaces the RXDATE version stored in
RXLIB. RXDATE will be available to guarantee consistency of
existing REXX scripts. It may be removed in a future release.

The three arguments are options. date defaults to today,

Supported input formats:

| Format        | Description                                                                                    |
|---------------|------------------------------------------------------------------------------------------------|
| Base          | days since 01.01.0001                                                                          |
| JDN           | days since Monday 24. November 4714 BC                                                         |
| UNIX          | days since 1. January 1970                                                                     |
| DEC           | 01-JAN-20 DEC format (Digital Equipment Corporation)                                           |
| XDEC          | 01-JAN-2020 extended DEC format (Digital Equipment Corporation)                                |
| Julian        | yyyyddd e.g. 2018257                                                                           |
| European      | dd/mm/yyyy e.g. 11/11/18                                                                       |
| xEuropean     | dd/mm/yyyy e.g. 11/11/2018, extended European (4 digits year)                                  |
| German        | dd.mm.yyyy e.g. 20.09.2018                                                                     |
| USA           | mm/dd/yyyy e.g. 12.31.18                                                                       |
| xUSA          | mm/dd/yyyy e.g. 12.31.2018, extended USA (4 digits year)                                       |
| STANDARD      | yyyymmdd e.g. 20181219                                                                         |
| ORDERED       | yyyy/mm/dd e.g. 2018/12/19                                                                     |
| LONG          | dd month-name yyyy e.g. 12 March 2018, month is translated into month number (first 3 letters) |
| NORMAL        | dd 3-letter-month yyyy e.g. 12 Mar 2018, month is translated into month number                 |
| QUALIFIED     | Thursday, December 17, 2020                                                                    |
| INTERNATIONAL | date format 2020-12-01                                                                         |
| TIME          | date since 1.1.1970 in seconds                                                                 |

Supported output formats:

| Format        | Description                                                                                    |
|---------------|------------------------------------------------------------------------------------------------|
| Base          | days since 01.01.0001                                                                          |
| Days          | ddd days in this year e.g. 257                                                                 |
| Weekday       | weekday of day e.g. Monday                                                                     |
| Century       | dddd days in this century                                                                      |
| JDN           | days since Monday 24. November 4714 BC                                                         |
| UNIX          | days since 1. January 1970                                                                     |
| DEC           | 01-JAN-20 DEC format (Digital Equipment Corporation)                                           |
| XDEC          | 01-JAN-2020 extended DEC format (Digital Equipment Corporation)                                |
| Julian        | yyyyddd e.g. 2018257                                                                           |
| European      | dd/mm/yyyy e.g. 11/11/18                                                                       |
| xEuropean     | dd/mm/yyyy e.g. 11/11/2018, extended European (4 digits year)                                  |
| German        | dd.mm.yyyy e.g. 20.09.2018                                                                     |
| USA           | mm/dd/yyyy e.g. 12.31.18                                                                       |
| xUSA          | mm/dd/yyyy e.g. 12.31.2018, extended USA (4 digits year)                                       |
| STANDARD      | yyyymmdd e.g. 20181219                                                                         |
| ORDERED       | yyyy/mm/dd e.g. 2018/12/19                                                                     |
| LONG          | dd month-name yyyy e.g. 12 March 2018, month is translated into month number (first 3 letters) |
| LS            | time of day in microseconds  5 chars (digits) seconds, 6 chars, microseconds w/out delimiters  |
| NORMAL        | dd 3-letter-month yyyy e.g. 12 Mar 2018, month is translated into month number                 |
| QUALIFIED     | Thursday, December 17, 2020                                                                    |
| INTERNATIONAL | date format 2020-12-01                                                                         |
| TIME          | date since 1.1.1970 in seconds                                                                 |

### DATETIME()

Formats a timestamp into various representations.

* **Parameters:**
  * **target-format** – *optional* target-format defaults to Ordered
  * **timestamp** – *optional* timestamp defaults to today current time
  * **input-format** – *optional* input-format defaults to Timestamp
* **Return type:**
  string

Formats are:

| Format   | Description               | Example                                    |
|----------|---------------------------|--------------------------------------------|
| T        | is timestamp in seconds   | 1615310123 (seconds since 1. January 1970) |
| E        | timestamp European format | 09/12/2020-11:41:13                        |
| U        | timestamp US format       | 12.09.2020-11:41:13                        |
| O        | Ordered Time stamp        | 2020/12/09-11:41:13                        |
| B        | Base Time stamp           | Wed Dec 09 07:40:45 2020                   |

### Time(string)

Time has gotten new input parameters. String can be one of:

- MS Time of today in seconds.milliseconds
- HS Time of today in seconds.hundreds
- US Time of today in seconds.microseconds
- CPU Used CPU time in seconds.milliseconds
- LS time of day in microseconds, in string format, 5 chars (digits) seconds, 6 chars microseconds without delimiters

### STDATE()

Calculating the Startrek Stardate.

* **Parameters:**
  * **date-target-format** – *optional* date-target-format defaults to Ordered
  * **timestamp** – *optional* timestamp defaults to today current time
  * **input-format** – *optional* input-format defaults to Timestamp
* **Return type:**
  string

### FILTER(string, character-table)

> The filter function removes all characters defined in the character
> table if ‘drop’ is used as filter-type. If ‘keep’ is specified, just
> those characters which are in the character table are kept.
> Filter-type defaults to drop.
* **Parameters:**
  * **string** – string to filter
  * **character-table** – filter table
  * **filter-type** – *optional* either drop or keep
* **Return type:**
  string

  For example, remove ‘o’ and ‘blank’:
  ```rexx
  say FILTER('The quick brown fox jumps over the lazy dog',' o')
  Thequickbrwnfxjumpsverthelazydg
  ```

### FLOOR(decimal-number)

FLOOR returns the smallest integer less or equal to the decimal number.

### INT(decimal-number)

INT returns the integer value of a decimal number. Fraction digits
are stripped off. There is no rounding in place. It’s faster than
saying intValue=number%1

### JOBINFO()

Returns jobname and additional information about currently running job or TSO session in REXX variables, like JOB.NAME, JOB.NUMBER, STEP.NAME, PROGRAM.NAME

Example:

```rexx
say jobinfo()
say job.name
say job.number
say job.step
say job.program
```

Result:

```default
PEJ
PEJ
TSU02077
ISPFTSO.ISPLOGON
IKJEFT01
```

### JOIN(string, target-string)

Join merges a string into a target-string. The merge occurs byte by
byte; if the byte in target-string is defined in the join-table. The
join-table consists of one or more characters, which may be overwritten.
If it is in the target-string, it is replaced by the equivalent byte of
the string. If it is not part of the join-table, it remains as it is. If
the length of the string is greater than the target-string size is
appending the target-string. The join-table is an optional parameter and
defaults to blank.

Example:

```default
SAY JOIN('     PETER        MUNICH','NAME=        CITY=          ')
NAME=PETER   CITY=MUNICH
```

### LEVEL()

Level returns the current procedure level. The level information is
increased by +1 for every CALL statement or function call.

Example:

```rexx
say 'Entering MAIN 'Level()
call proc1
say 'Returning from proc1 'Level()
return

proc1:
   say 'Entering proc1 'Level()
   call proc2
   say 'Returning from proc2 'Level()
return 0

proc2: procedure
   if level()>5 then return 4
   say 'Entering proc2 'Level()
   prc=proc1()
   say 'Returning from proc1 'Level()
return 0
```

Result:

```default
ENTERING MAIN 0
ENTERING PROC1 1
ENTERING PROC2 2
ENTERING PROC1 3
ENTERING PROC2 4
ENTERING PROC1 5
RETURNING FROM PROC2 5
RETURNING FROM PROC1 4
RETURNING FROM PROC2 3
RETURNING FROM PROC1 2
RETURNING FROM PROC2 1
RETURNING FROM PROC1 0
```

### ARGV(argument-number, calling-level)

Returns the argument specified by argument-number and the calling-level.
With this function, you can determine calling procedure arguments in several stages.

calling-level:

| 0   | is the current procedure                            |
|-----|-----------------------------------------------------|
| -1  | is the procedure calling the current procedure      |
| -2  | the caller of the caller …                          |
| …   |                                                     |
| 1   | is the very first procedure in the calling sequence |
| 2   | is the second procedure                             |
| 3   | …                                                   |

Example:

```rexx
RX MAIN "EUROPE"
call Sub1 "Germany", "Italy","UK"
return

sub1:
call sub2 'Munich','Rome','London'
return

sub2:
say 'argument 1 of SUB2: 'argv(1,0)
say 'argument 2 of SUB2: 'argv(2,0)
say 'argument 3 of SUB2: 'argv(3,0)

say 'argument 1 of SUB1: 'argv(1,-1)
say 'argument 2 of SUB1: 'argv(2,-1)
say 'argument 3 of SUB1: 'argv(3,-1)

say 'Calling argument 1 of main: 'argv(1,-2)
return
```

Result:

> argument 1 of SUB2: Munich
> argument 2 of SUB2: Rome
> argument 3 of SUB2: London
> argument 1 of SUB1: Germany
> argument 2 of SUB1: Italy
> argument 3 of SUB1: UK
> Calling argument 1 of main: EUROPE

### LINKMVS(load-module, parms)

Starts a load module. Parameters work according to standard conventions.

### LINKPGM(load-module, parms)

Starts a load module. Parameters work according to standard conventions.

### LISTIT('variable-prefix')

Returns the content of all variables and stem-variables starting
with a specific prefix. The prefix must be enclosed in quotes. If no
prefix is defined all variables are printed

Example:

```rexx
v2='simple Variable'
v21.0=3
v21.1='Stem Variable, item 1'
v21.2='Stem Variable, item 2'
v21.3='Stem Variable, item 3'
call ListIt 'V2'
```

Result:

```default
List Variables with Prefix 'V2'
-------------------------------
[0001]  "V2" => "SIMPLE VARIABLE"
[0002]  "V21." =>
>[0001] "|.0" => "3"
>[0002] "|.1" => "STEM VARIABLE, ITEM 1"
>[0003] "|.2" => "STEM VARIABLE, ITEM 2"
>[0004] "|.3" => "STEM VARIABLE, ITEM 3"
```

### LOCK('lock-string',['lock-modes'][,timeout])

Locks a resource (could be any string, e.g. dataset-name) for usage
by a concurrent program (which must request the same resource).
Typically it is used to keep the integrity of several datasets.

* **Parameters:**
  * **lock-string** – resource to lock
  * **lock-modes** – *optional* One of TEST/SHARED/EXCLUSIVE. TEST tests whether the resource is available. SHARED shared access is wanted, other programs/tasks are also shared access granted, but no exclusive lock can be granted, while a shared lock is active, EXCLUSIVE no other program/task can use the resource at this point.
  * **timeout** – *optional* defines a maximum wait time in milliseconds to acquire the resource. If no timeout is defined the LOCK ends immediately if it couldn’t be acquired.
* **Returns:**
  **0** if resource was locked, **4** resource could not be acquired in the requested time interval

### UNLOCK('lock-string')

Unlocks a previously locked resource.

* **Returns:**
  0 unlock was successful, otherwise unsuccesful

### MEMORY()

Determines and print the available storage junks:

```default
MVS Free Storage Map
---------------------------
AT ADDR  7909376    1176 KB
AT ADDR  3108864    1166 KB
Total               2342 KB
---------------------------
```

### MTT()

* **Returns:**
  the content of the Master Trace Table in the stem variable \_LINE., \_LINE.0 contains the number ofreturned trace table entries. The return code contains the number of trace table entries fetched. If **-1** is returned the Master Trace Table has not been changed since the last call, \_LINE. remains unchanged.

If the optional ‘REFRESH’ option is used, the Trace Table will be
recreated even it it has not changed.

Example:

```rexx
 Call mtt()
 Do i=1 to _line.0
    Say _line.i
 End
```

Result:

```default
...
4000 08.48.56 JOB  891  $HASP395 BRXLINK  ENDED"
4000 08.48.56 JOB  891  IEF404I BRXLINK - ENDED - TIME=08.48.56"
0004 08.48.56 JOB  891  BRXLINK    ALIASES             IKJEFT01  RC= 0000"
0004 08.48.55 JOB  891  BRXLINK    LINKAUTH            IEWL      RC= 0000"
0004 08.48.53 JOB  891  BRXLINK    BRXLNK              IEWL      RC= 0004"
0004 08.48.53 JOB  891  IEFACTRT - Stepname  Procstep  Program   Retcode"
4000 08.48.51 JOB  891  IEF403I BRXLINK - STARTED - TIME=08.48.51"
4000 08.48.51 JOB  891  $HASP373 BRXLINK  STARTED - INIT  1 - CLASS A - SYS TK4-"
0200 08.48.50 JOB  891  $HASP100 BRXLINK  ON READER2"
...
```

### MTTSCAN()

MTTSCAN is an application that constantly analyses the Master Trace
Table and passes control to the user’s procedures for a registered
function to perform user actions.

Example in BREXX.V2R5M3.SAMPLE(MTTSCANT)

In this example, the trace entries $HASP373 (LOGON) and
$HASP395 (LOGOFF) are registered, and the associated call-back
procedures will be called to initiate further actions.

Example:

```rexx
/* ------------------------------------------------------------------
 * Scan Master Trace Table for LOGON/LOGOFF actions
 * ------------------------------------------------------------------
 */
/* ------------------------------------------------------------------*/
/*            + ---  REGISTER requestesd action                      */
/*            |           + --- action keyword in trace table        */
/*            |           |          + --- associated call back proc */
/*            Y           Y          Y                               */
call mttscan 'REGISTER','$HASP373','hasp373'
call mttscan 'REGISTER','$HASP395','hasp395'

/*            + ---  Start scanning Trace Table                      */
/*            |     + --- scan frequency in millisedonds             */
/*            Y     Y          default is 5000                       */
call mttscan 'SCAN',2000
return
/* --------------------------------------------------------------------
 * Call Back to handle $HASP373 Entries of the Trace Table: user LOGON
 *    arg(1) contains the selected line of the Trace Table
 * --------------------------------------------------------------------
 */
hasp373:
  user=word(arg(1),6)
/* call console 'c u='user     You can for example cancel the user   */
  say user ' has logged on'
  say 'Trace Table entry: 'arg(1)
  say copies('-',72)
return
/* --------------------------------------------------------------------
 * Call Back to handle $HASP395 Entries of the Trace Table: user LOGOFF
 *   arg(1) contains the selected line of the Trace Table
 * --------------------------------------------------------------------
 */
hasp395:
  user=word(arg(1),6)
  say user ' has logged off'
  say 'Trace Table entry: 'arg(1)
  say copies('-',72)
return
```

### RXCONSOL()

An application that returns the output of a requested Console command in the stem variable CONSOLE.n

* **Returns:**
  **>0** the command output could not be identified in the Master Trace Table

Example in BREXX.V2R5M3.SAMPLE(CONSOLE):

```rexx
/* -----------------------------------------------------------
 *  RXCONSOL Sample: Show output of a Console command
 * -----------------------------------------------------------
 */
call rxconsol('D A,L')
say copies('-',72)
say center('Console Output of D A,L',72)
say copies('-',72)
do i=1 to console.0
   say console.i
end
```

#### WARNING
The result of an operator command is not synchronously returned, but
asynchronously assigned via the activity number. In certain
situations, this may fail, then an exact match of operator command
and its output is impossible. You will then see more output than
expected.

### RXLIST()

Prints the currently loaded BREXX modules including their originating DSN.
The first entry is the starting REXX.

Example:

```default
Loaded Rexx Modules
    REXX      Member   DDNAME   DSN
-----------------------------------------------------
  1 #RXL      RXL      SYSUEXEC PEJ.EXEC
  2 RXSORT    RXSORT   RXLIB    BREXX.RXLIB
  3 FMTLIST   FMTLIST  RXLIB    BREXX.RXLIB
  4 FSSAPI    FSSAPI   RXLIB    BREXX.RXLIB
```

### NJE38CMD()

An application that returns the output of a requested NJE38 command
in the stem variable NJE38.n

* **Returns:**
  **>0** means the NJE38 command output could not be identified in the Master Trace Table

Example in BREXX.V2R5M3.SAMPLE(NJECMD)

```rexx
/* -----------------------------------------------------------
 *  NJE38 Sample: Show available files in NJE38 inbox
 *    pass command to NJE38CMD and retrieve output
 * -----------------------------------------------------------
 */
rc=nje38CMD('NJE38 D fILes')
if rc>0 then do
   say 'Unable to pickup NJE38 results'
   return 8
end
say copies('-',72)
say center('NJE38 Spool Queue',72)
say copies('-',72)
do i=1 to nje38.0
   say nje38.i
end
```

Result:

```default
------------------------------------------------------------------------
                           NJE38 SPOOL QUEUE
------------------------------------------------------------------------
NJE014I  File status for node DRNBRX3A
File  Origin   Origin    Dest     Dest
 ID   Node     Userid    Node     Userid    CL  Records
0006  DRNBRX3A PEJ1      DRNBRX3A PEJ       A   50
0010  CZHETH3C FIX0MIG   DRNBRX3A MIG       A   119
Spool 00% full
```

### VLIST(pattern)

VLIST scans all defined REXX-variable names for a specific pattern.
This is mainly for stem-variables useful, where they can have
various compound components. The pattern must be coded in the form
p1.p2.p3.p4.p5, p1, p2, p3,p4,p5 are subpatterns that must match
the stem variable name. There are up to 5 subpatterns allowed.
You may use \* as a subpattern for any variable in this position.

Example:

```rexx
ADDRESS.PEJ.CITY='Munich'
ADDRESS.MIG.CITY='Berlin'
ADDRESS.pej.pub='Hofbrauhaus'
ADDRESS.mig.pub='Steakhaus'
ADDRESS='set'
call xlist('*.*.CITY')
call xlist('ADDRESS')
call xlist('ADDRESS.*.CITY')
call xlist('ADDRESS.PEJ')
call xlist('ADDRESS.MIG')
call xlist()
exit
xlist:
say '>>> 'arg(1)
say vlist(arg(1))
return
```

Result:

```default
>>> *.*.CITY
ADDRESS.MIG.CITY="BERLIN"
ADDRESS.PEJ.CITY="MUNICH"

>>> ADDRESS
ADDRESS="SET"
ADDRESS.MIG.CITY="BERLIN"
ADDRESS.MIG.PUB="STEAKHAUS"
ADDRESS.PEJ.CITY="MUNICH"
ADDRESS.PEJ.PUB="HOFBRAUHAUS"

>>> ADDRESS.*.CITY
ADDRESS.MIG.CITY="BERLIN"
ADDRESS.PEJ.CITY="MUNICH"

>>> ADDRESS.PEJ
ADDRESS.PEJ.CITY="MUNICH"
ADDRESS.PEJ.PUB="HOFBRAUHAUS"

>>> ADDRESS.MIG
ADDRESS.MIG.CITY="BERLIN"
ADDRESS.MIG.PUB="STEAKHAUS"

>>>
ADDRESS="SET"
ADDRESS.MIG.CITY="BERLIN"
ADDRESS.MIG.PUB="STEAKHAUS"
ADDRESS.PEJ.CITY="MUNICH"
ADDRESS.PEJ.PUB="HOFBRAUHAUS"
SIGL="11"
VLIST.0="2"
```

### LASTWORD(string)

Returns the last word of the provided string.

### PEEKS(decimal-address, length)

PEEKS returns the content (typically a string) of a main-storage
address in a given length. The address must be in decimal format.

PEEKS is a shortcut of STORAGE(d2x(decimal-address),length).

### PEEKA(decimal-address)

PEEKA returns an address (4 bytes) stored at a given address. The
address must be in decimal format.

PEEKA is a shortcut of STORAGE(d2x(decimal-address),4).

### PEEKU(decimal-address)

PEEKU returns an unsigned integer stored at the given decimal
address (4 bytes). The address must be in decimal format.

### RACAUTH(userid, password)

The RACFAUTH function validates the userid and password against the
RAKF definitions. If both pieces of information are valid, a one is
returned.

### RHASH(string)

The function returns a numeric hash value of the provided string.
The optional slots parameter defines the highest hash number before
it restarts with 0. Slots default to 2,147,483,647 Even before
reaching the maximum slot, the returned number is not necessarily
unique; it may repeat (collide) for various strings. The calculation
is based on a polynomial rolling hash function

### ROUND(decimal-number, fraction-digits)

The function rounds a decimal number to the precision defined by
fraction-digits. If the decimal number does not contain the number
of fraction digits requested, it is padded with 0s.

### ROTATE(string, position)

The function is a rotating substring if the requested length for the
substring is not available, it takes the remaining characters from
the beginning of the string. If the optional length parameter is not
coded, the length of the string is used.

Example:

```default
Rotate("1234567890ABCDEF",10,10)
Rotate("1234567890ABCDEF",1)
Rotate("1234567890ABCDEF",5)
```

Result:

```default
'0ABCDEF123'
'1234567890ABCDEF'
'567890ABCDEF1234'
```

### PUTSMF(smf-record-type, smf-message)

Writes an SMF message of type smf-record-type. If you use a defined
type with a certain structure, it must be reflected in smf-message.
If necessary you can use den BREXX conversion functions (D2C, D2P, etc.)
to create binary data.

### SUBMIT(options)

Submits a job via the internal reader to your MVS system. Options are:

- fully qualified dataset name containing the JCL
- stem variable containing the JCL
- stack containing the JCL

Example:

```default
submit("'pds-name(member-name)'") submit a DSN or a member in a PDS
submit('stem-variable.')          submit JCL stored in stem-variable
submit('*')                       submit JCL stored in a stack (queue)
```

#### WARNING
The internal reader has no knowledge of your userid, therefore the
&SYSUID variable will not be resolved with your userid. It also
does not return any “SUBMIT” message, this can easily be achieved by
a small rexx script analysing the master trace table.

### SPLIT(string, stem-variable)

SPLIT splits a string into its words and store them in a stem
variable. The optional delimiter table defines the split
character(s), which shall be used to separate the words. SPLIT
returns the number of found words. Also, stem-variable.0 contains
the number of words. The words are stored in the stem-variable.1,
stem-variable.2, etc. It is recommended to enclose the receiving
stem-variable-name in quotes.

Example:

```rexx
Say Split('The quick brown fox jumps over the lazy dog','myStem.')
Call LISTIT
```

Result:

```default
9
List all Variables
------------------
[0001]  "MYSTEM." =>
>[0001] "|.0" => "9"
>[0002] "|.1" => "THE"
>[0003] "|.2" => "QUICK"
>[0004] "|.3" => "BROWN"
>[0005] "|.4" => "FOX"
>[0006] "|.5" => "JUMPS"
>[0007] "|.6" => "OVER"
>[0008] "|.7" => "THE"
>[0009] "|.8" => "LAZY"
>[0010] "|.9" => "DOG"
```

Example with list of word delimiters:

```rexx
say split('City=London,Address=Picadelly Circus 24(7th floor)','mystem.','()=,')
call listit
```

Result:

```default
5
List all Variables
------------------
[0001]  "MYSTEM." =>
>[0001] "|.0" => "5"
>[0002] "|.1" => "CITY"
>[0003] "|.2" => "LONDON"
>[0004] "|.3" => "ADDRESS"
>[0005] "|.4" => "PICADELLY CIRCUS 24"
>[0006] "|.5" => "7TH FLOOR"
[0002]  "X" => "CITY=LONDON,ADDRESS=PICADELLY CIRCUS 24(7TH FLOOR)"
```

### SPLITBS(string, stem-variable)

SPLIT splits a string into its words and store them in a stem
variable. The split-string defines the string which shall be used to
separate the words. SPLIT returns the number found words. Also,
stem-variable.0 contains the number of words. The words are stored
in the stem-variable.1, stem-variable.2, etc. It is recommended to
enclose the receiving stem-variable-name in quotes.

Example:

```rexx
say splitbs('today</N>tomorrow</N>yesterday','mystem.','</N>')
call listit 'mystem.'
```

result:

```default
3
List Variables with Prefix 'MYSTEM.'
------------------------------------
[0001]  "MYSTEM." =>
>[0001] "|.0" => "3"
>[0002] "|.1" => "TODAY"
>[0003] "|.2" => "TOMORROW"
>[0004] "|.3" => "YESTERDAY"
```

### EPOCHTIME()

EPOCHTIME returns the Unix (epoch) time of a given date. It’s the
seconds since 1. January 1970. You can easily extend the date by
adding the seconds of the day.

As calculation internally is done on integer fields, the maximum
date which is supported is 19 January 2038 04:14:07. If no
parameters are specified, the current date/time will be returned.

Example:

```rexx
time= EPOCHTIME(1,1,2000)+3600*hours+60*minutes+seconds
```

### EPOCH2DATE(unix-epochtime)

EPOCH2DATE translates a Unix (epoch) time-stamp into a readable
date/time format. Internally the date conversion is done by the
RXDATE module of RXLIB

Example:

```rexx
tstamp=EPOCHTIME()
say tstamp
SAY EPOCH2DATE(tstamp)
```

Result:

```default
1600630022
20/09/2020 19:27:02
```

### STIME()

Time since midnight in hundreds of a second

### USERID()

USERID returns the identifier of the currently logged-on user. (available in Batch and Online)

### UPPER(string)

UPPER returns the provided string in upper cases.

### LOWER(string)

LOWER returns the provided string in lower cases.

### MOD(number, divisor)

MOD divides and returns the remainder, equivalent to the // operation.

### LOADRX(STEM, stemname., procname)

Sometimes it is useful to create a rexx procedure on the fly. For example,
if you read field names from an external dataset and have to build an
extraction routine. There are 2 ways to do so:

1. Create a stem containing the code line by line

```rexx
xset.1="c=0"
xset.2="c=c+1"
xset.3="d=c+5"
xset.4="e=c+15"
xset.5="say c d e"
xset.0=5
call loadRX("STEM","XSET.","myrexx")
```

1. Create a sarray adding the lines to it:

```rexx
s1=screate(32)
call sset(s1,,"A=0")
call sset(s1,,"A=A+1")
call sset(s1,,"A=A+1")
call sset(s1,,"A=A+1")
call sset(s1,,"A=A+1")
call sset(s1,,"say a")
call slist(s1)
xset.1="c=0"
xset.2="c=c+1"
xset.3="d=c+5"
xset.4="e=c+15"
xset.5="say c d e"
xset.0=5
s2=stem2str("xset.")
say "STEMSTR "s2
call loadRX("ARRAY",s1,"rexx2")
```

Once LOADRX is executed, the REXX-name is usable and can be called. A REXX
procedure can be used just once, a reloading has no effect, as it does not
overwrite an existing version.

### STCSTOP()

Check in a started task (STC) if a STOP command has been sent via the console.

- Rc=0 no stop was requested
- Rc=1 STOP has been requested

If a STOP has been received the REXX script should terminate.

Sample STC:

```rexx
DO forever
    if stcstop()=1 then do
       CALL WTO 'STC STOP COMMAND RECEIVED'
       leave
    end
    call wait 1000
    /* do STC stuff             */
...
    /* loop to check STC status */
end
exit 0
```

### VERSION()

Returns BREXX/370 version information, if FULL is specified the Build Date of BREXX is added and returned.

Example:

```default
SAY VERSION()       -> V2R5M3
SAY VERSION('FULL') -> Version V2R5M1 Build Date 15. Jan 2021
```

### WAIT(wait-time)

Stops REXX script for some time, wait-time is in thousands of a second

### WORDDEL(string, word-to-delete)

WORDDEL removes a specific word from the string. If the specified
word does not exist, the full string is returned.

Example:

```rexx
say worddel('I really love Brexx',1)
say worddel('I really love Brexx',2)
say worddel('I really love Brexx',3)
say worddel('I really love Brexx',4)
say worddel('I really love Brexx',5)
```

Result:

```default
REALLY LOVE BREXX
I LOVE BREXX
I REALLY BREXX
I REALLY LOVE
I REALLY LOVE BREXX
```

### WORDINS(new-word, string, after-word-number)

WORDINS inserts a new word after the specified word number. If 0 is
used as wobaserd number it is inserted at the beginning of the string.

Example:

```rexx
say wordins('really','I love BREXX',1)
say wordins('really','I love BREXX',2)
say wordins('really','I love BREXX',3)
say wordins('really','I love BREXX',0)
```

Result:

```default
I REALLY LOVE BREXX
I LOVE REALLY BREXX
I LOVE BREXX REALLY
REALLY I LOVE BREXX
```

### WORDREP(new-word, string, word-to-replace)

WORDREP replace a word value by a new value.

Example:

```rexx
say wordrep('!!!','I love Brexx',1)
say wordrep('!!!','I love Brexx',2)
say wordrep('!!!','I love Brexx',3)
```

Result:

```default
!!! LOVE BREXX
I !!! BREXX
I LOVE !!!
```

### WTO(console-message)

Write a message to the operator’s console. It also appears in the
JES Output of the Job.

### XPULL()

PULL function which returns the stack content casesensitive.

### GETDATA()

The GETDATA function fetches all Data-Sections of the currently running
REXX and creates either a stem, a sarray, an integer array (IARRAY) a
or float array (FARRAY). The format of Data-Sections is embedded in a
comment block and has the following format:

The comment which contains the data have the format:

```default
/* DATA STEM stemname …
Content 1
Content 2
…
*/
```

The first line defines the target which receives the content, it can be:

- /\* DATA STEM stemname.
- /\* DATA SARRAY array-variable
- /\* DATA IARRAY array-variable
- /\* DATA FARRAY array-variable

Neither of the arrays needs to be created prior to the call, they are
created during the execution of the GETDATA function. It works on the
current running rexx. If you have a complex and/or nested structure it is
recommended to define the rexx-module as the parameter:

```default
/* DATA STEM stemname
/* DATA STEM BANDS.
  LED ZEPPELIN          STAIRWAY TO HEAVEN
  EAGLES                   HOTEL CALIFORNIA
  AC/DC                    BACK IN BLACK
  JOURNEY                  DON'T STOP BELIEVIN'
  PINK FLOYD               ANOTHER BRICK IN THE WALL
  QUEEN                    BOHEMIAN RHAPSODY
  TOTO                     HOLD THE LINE
  DEEP PURPLE                   SMOKE ON THE WATER
*/
```

The first comment line starts with /\* DATA STEM BANDS. DATA defines the
beginning of a data section, STEM stem-name associates a stem that will
receive the data. If you prefer a SARRAY to receive them, you can use
alternatively: /\* DATA SARRAY BANDS, in this case, a SARRAY is created
and will receive the data, and the array number is stored in the specified
variable (BANDS in the example). The SARRAY can be processed with the
array functions.

The end of the data section is defined by a closing comment string in a separate
line.

To eventually receive the data you must call GETDATA. GETDATA pushes all data
sections of the REXX script in the requested stem or sarray.

> ```rexx
> call GetData

> do i=1 to bands.0
>    say i bands.i
> end
> Result
> 1 LED ZEPPELIN                  STAIRWAY TO HEAVEN
> 2 EAGLES                        HOTEL CALIFORNIA
> 3 AC/DC                         BACK IN BLACK
> 4 JOURNEY                       DON'T STOP BELIEVIN'
> 5 PINK FLOYD                    ANOTHER BRICK IN THE WALL
> 6 QUEEN                         BOHEMIAN RHAPSODY
> 7 TOTO                          HOLD THE LINE
> 8 DEEP PURPLE                                    SMOKE ON THE WATER
> ```

### LCS(‘string1’, ’string2”)

Longest Common Subsequence. Find the Longest Common Subsequence of
two strings.

```rexx
Say LCS("thisisatest", "testing123testing")
```

Result:

```default
tsitest
```
