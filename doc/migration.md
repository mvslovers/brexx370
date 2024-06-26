# Migration and Upgrade Notices

This section covers the changes in the new version, migration
instruction to upgrade from the previous Release. The installation
process is separately described in the BREXX/370 Installation section.

## Upgrade from a previous BREXX/370 Version

Before upgrading backup your system. The easiest way is creating a copy
of your TK4- directory containing all of your settings DASD volumes. In
the cases of errors or unwanted behaviour, you can easily recover to
the backup version.

## BREXX V2R1M0

### Important Changes

Due to the extended calling functionality in the new version of
BREXX/370 an import of required REXX scripts is no longer necessary.
For this reason, all pre-defined import libraries have been removed from
the JCL Procedures RXTSO and RXBATCH. The installation will update them
in SYS2.PROCLIB. For similar reasons the CLISTs RX and REXX are no
longer necessary and will be therefore removed from SYS2.CMDPROC,
there will be an RX and REXX member in SYS2.LINKLIB which replaces the
CLIST version.

### Libraries

The following BREXX libraries are necessary for running REXX:

- BREXX.JCL
- BREXX.SAMPLES
- BREXX.SAMPLIB **new with this version**
- BREXX.RXLIB

They will be delivered and created during the installation process,
existing libraries will be overwritten!

#### WARNING
If you made changes or added your own entries in one of
these libraries, save them before beginning with the installation
process!

### Calling external REXX Scripts or Functions

It is now possible to call external REXX scripts, either by:

```default
CALL your-script parm1,parm2...
```

or a function call:

```default
Value=your-script(parm1,parm2,...)
```

The called script will be sought by the following sequence:

- Internal subprocedure or label (contained in the running script)
- current library (where the calling REXX is originated)
- BREXX.RXLIB

### Software Changes requiring actions

The STORAGE function has been changed to become compatible with IBM’s
z/OS REXX STORAGE version.

In IBM’s REXX, the storage address must be in hex format, in BREXX it
was decimal. With this version, we match with IBM’s specification and
allow only hex notation.

### New Functionality

BREXX functions coded in REXX

### ABEND(abend-code)

Terminate program with Abend-Code, produces an SYSUDUMP

### USERID()

Signed in UserId (available in Batch and Online)

### WAIT(wait-time)

Stops REXX script for some time, wait-time is in hundreds of a second

### WTO(console-message)

Write a message to the operator’s console

### SYSVAR(request-type)

a TSO-only function to retrieve certain TSO runtime information
request-type:

| Request Type   | Description                                   |
|----------------|-----------------------------------------------|
| SYSENV         | FORE/BACK - Foreground TSO / Batch TSO        |
| SYSISPF        | ACTIVE/NOT ACTIVE                             |
| SYSPREF        | TSO Prefix (only available in Foreground TSO) |
| SYSUID         | Userid                                        |

Brexx has the capability code new functions or command in REXX. They are
transparent and will be called in the same way as basic BREXX function.

Overview:

### BSTORAGE(...)

Storage command in the original BREXX decimal implementation

### LISTALC()

Lists all allocated Datasets in this session or region

### BRXMSG(...)

Standard message module to display a message in a formatted way,
examples:

```rexx
rc=brxmsg( 10,'I','Program has been started')
rc=brxmsg(100,'E','Value is not Numeric')
rc=brxmsg(200,'W','Value missing, default used')
rc=brxmsg(999,'C','Division will fail as divisor is zero')
```

will return::
: BRX0010I PROGRAM HAS BEEN STARTED
  BRX0100E VALUE IS NOT NUMERIC
  BRX0200W VALUE MISSING, DEFAULT USED
  BRX0999C DIVISION WILL FAIL AS DIVISOR IS ZERO

### DAYSBETW(date1, date-2, ...)

Return days between 2 dates

### JOBINFO(request-type)

Return information about currently running job or TSO session.

Request-type:

- JOBNAME - returns job name
- JOBNUMBER - returns job number
- STEPNAME - returns step name
- PROGRAMNAME - returns running program name

### LINKMVS(load-module, parms)

Starts a load module. Parameters (if any) will send in the format
JCL would pass it.

### MVSCBS()

Allows addressing of some MVS control blocks. This function must be
imported, then the following functions can be used: Cvt(), Tcb(),
Ascb(), Tiot(), Jscb(), Rmct(), Asxb(), Acee(), Ecvt(), Smca()

### PDSDIR(dsn)

Return directory entries in a stem variable

### RXDATE(...)

Return and optionally convert dates in certain formats

### RXDSINFO(dsn/dd-name, options)

Return dsn or dd-name attributes

### 3RXDYNALC(...)

Allows dynamic allocations of datasets or output

### RXSORT(...)

Sorts a stemvariable with different sort algorithms

### SEC2TIME(seconds)

Converts an amount of seconds into the format [days ]hh:mm:ss

### SORTCOPY(stem-variable)

Copies any stem variable into the stem SORTIN, which can be used
by RXSORT

### STEMCOPY(source-stem-variable, target-stem-variable)

Copies any stem variable into another stem variable

### TODAY()

Returns todays date in certain formats

## BREXX V2R2M0

### Software Changes requiring actions

### OPEN()

In the OPEN(ds-name,, ‘DSN’) function the third parameter DSN has
been removed to achieve closer compatibility to z/OS REXX.

Change Required: Replace OPEN(ds-name,,’DSN’) by OPEN(‘ds-name’,)
putting the ds-name in quotes or double-quotes signals BREXX that an
open for a ds-name instead of a dd-name. If you use a BREXX variable
instead of a fixed ds-name the quotes must be coded like this:

```default
file='BREXX.RXLIB'
OPEN("'"file"'")
```

### QUALIFY()

The QUALIFY(ds-name) function added in TSO environments the
user-prefix. This function has been removed as its functionality
has been integrated into the OPEN function.

### BSTORAGE()

The BSTORAGE function has been removed as it was a temporary
solution for users of the very first BREXX/370 version. If you plan
to keep it, take a copy from the previous RXLIB library.

### Reduction of Console Messages

In previous releases, console messages have been displayed during the
search of a called REXX script in the BREXX search path. It reported
the library name if it was not located in the specific library. This
messaging has been significantly brought down. These messages only
appear if the called member could not found anywhere in the search path.

### Known Problems

#### Reading Lines fromsequential Dataset

Reading lines of sequential datasets always truncate trailing spaces.
This may be an unwanted behaviour for fixed-length datasets. To
circumvent this problem you can use the following method:

If the dataset is allocated via a DD statement:

```default
X=LISTDSI('INFILE FILE')
fhandle=OPEN(infile,'RB')
Record=READ(fhandle,SYSLRECL)
```

If the dataset is used directly:

```default
dsn='HERC01.TEMP'
X=LISTDSI("'"dsn"'")
fhandle=OPEN("'"dsn"'",'RB')
Record=READ(fhandle,SYSLRECL)
```

LISTDSI returns the necessary DCB information (SYSLRECL). The OPEN
must be performed with OPTION ‘RB’ which means READ, BINARY. Read
uses the record length to create the record.

#### BREXX FORMAT Function

The BREXX FORMAT function differs from the standard behaviour of
REXX FORMAT:

> FORMAT rounds and formats number with before integer digits and
> after decimal places. expp accepts the values 1 or 2 (WARNING
> Totally different from the Ansi-REXX spec) where 1 means to use
> the “G” (General) format of C, and 2 the “E” exponential format of
> C. Where the place of the total width specifier in C is replaced by
> before+after+1. ( expt is ignored! )

After determining the code we discovered that a complete re-write
would be necessary. As the effort does not stand in proportion to the
benefit, we decided to leave it as it is.

### New Functionality

### BREXX functions

- **Support of Formatted Screens** Refer to the section on formatted
  screens for more information.
- **Integration of VSAM I/O** Refer to the section on VSAM files for
  more information.
- **EXECIO Command** Allows accessing sequential datasets either fully
  or line by line.

### CLRSCRN()

Clears the TSO screen by removing all lines from the TSO Buffer.

### CEIL()

Returns the smallest integer greater or equal then the decimal number

### FLOOR()

Returns the greatest Integer less or equal then the decimal number

### DCL()

Enables definition of copybook like definitions of REXX Variables,
including conversion from and to decimal packed fields.

### P2D()

Converts Decimal Packed Field into REXX Numeric value.

### D2P()

Converts REXX Numeric value into Decimal Packed Field.

## BREXX V2R3M0

### Authorised BREXX Version available

With this release, we ship a standard installation of BREXX as well as
an authorised version, which allows to system programs as IEBCOPY,
NJE38, etc. The decision about what to install must be made before
installation.

### BREXXSTD load module removed

We have straightened the load module structure and removed the
BREXXSTD load module from the installation library. If you use JCL
with an explicit BREXXSTD call, replace it by BREXX. During the
installation process, any existing BREXXSTD module will be removed from
SYS2.LINKLIB.

### Call PLI Functions

Example compile jobs for callable PLI Functions can be found in
BREXX.V2R5M3.JCL:

- RXPI calculate PI with 500 digits
- RXCUT Return every n.th character of a string

### New and amended functionality

### BREXX functions

### CEIL(decimal-number)

CEIL returns the smallest integer greater or equal than the decimal
number.

### D2P(number, length, fraction-digit)

Converts a number (integer or float) into a decimal packed field.
The created field is in binary format

### P2D(number, length, fraction-digit)

Converts a decimal packed field into a number.

### ENCRYPT(string, password <, rounds>)

### DECRYPT(string, password <, rounds>)

Encrypts/Decrypts a string

### DUMPIT(address, dump-length)

DUMPIT displays the content at a given address of a specified length
in hex format. The address must be provided in hex format;
therefore, a conversion with the D2X function is required.

### DUMPVAR('variable-name')

DUMPVAR displays the content of a variable or stem in Hex format-

### FILTER(string, character-table <, drop/keep>)

The filter function removes all characters defined in the
character-table

### FLOOR(decimal-number)

FLOOR returns the smallest integer less or equal than the decimal
number.

### LISTIT('variable-prefix')

Returns the content of all variables and stem-variables starting
with a specific prefix

### RHASH(string, <slots>)

The function returns a numeric hash value of the provided string.

### ROUND(decimal-number, fraction-digits)

The function rounds a decimal number to the precision defined by
fraction-digits

### UPPER(string)

### LOWER(string)

UPPER returns the provided string in upper cases. LOWER in lower
cases.

### ROTATE(string, position<, length>)

The function returns a rotating substring

### TIMESTAMP()

TIMESTAMP returns the unix (epoch) time, seconds since 1.
January 1970.

#### Dataset Functions

### CREATE(dataset-name, allocation-information)

The CREATE function creates and catalogues a new dataset

### DIR(partitioned-dataset-name)

The DIR command returns the directory of a partitioned-dataset

### EXISTS(dataset-name)

### EXISTS(partitioned-dataset(member))

The EXISTS function checks the existence of a dataset or the
presence of a member in a partitioned dataset.

### REMOVE(dataset-name)

The REMOVE function un-catalogues and removes the specified dataset

### REMOVE(partitioned-dataset(member))

The REMOVE function on members of a partitioned dataset removes the
specified member.

### RENAME(old-dataset-name, new-dataset-name)

The RENAME function renames the specified dataset.

### RENAME(partitioned-dataset(old-member), partitioned-name(new-member))

The RENAME function on members renames the specified member into a
new one.

### ALLOCATE(ddname, dataset-name)

### ALLOCATE(ddname, partitioned-dataset(member-name))

The ALLOCATE function links an existing dataset or a member of a
partitioned dataset to a dd-name.

### FREE(ddname)

The FREE function de-allocates an existing allocation of a dd-name.

### OPEN(dataset-name, open-option, allocation-information)

The OPEN function has now a third parameter, which allows creating
ew datasets with appropriate DCB and system definitions.

#### TCP Functions

### TCPINIT()

TCPINIT initialises the TCP functionality.

### TCPSERVE(port-number)

Opens a TCP Server on the defined port-number for all its assigned
IP-addresses.

### TCPOPEN(host-ip, port-number)

TCPOPEN opens a client session to a server.

### TCPWAIT()

TCPWAIT is a Server function; it waits for incoming requests from a
client.

### TCPSEND(clientToken, message)

SendLength=TCPSEND(clientToken, message[,time-out-secs]) sends a
message to a client.

### TCPReceive(clientToken)

Receives a message from another client or server.

### TCPTERM()

Closes all client sockets and removes the TCP functionality

#### New BREXX functions coded in REXX

### GETTOKEN()

returns a token which is unique within a running MVS System or in this century

### BAS64ENC()

Encodes a string or binary string with Base64.

### BAS64DEC()

Decodes a base64 encoded string into a string or
binary string Returns the hash number of a string

### STIME()

Time since midnight in hundreds of a second

## BREXX V2R4M0

### Functions with changed functionality

There is a major change in every time functions. We have increased the
precision of the time format from hundreds of a second to milliseconds
in some cases to microseconds. If you use them or rely on the format,
please change your REXX scripts accordingly:

```default
say TIME('L') /* 16:38:03.112765 */
call wait 100 /* now waits 0.1 seconds */
call wait 5000 /* waits 5 seconds */
```

### New Functions

This sections contains all new or changed BREXX V2R4M0 functions

### DATE(target-date-format, date, input-date-format)

The new date function has now the “used” formats provided by the
original REXX.

### DATETIME(target-format, timestamp, input-format)

Formats are:

```default
T is timestamp in seconds 1615310123
E timestamp European format 09/12/2020-11:41:13
U timestamp US format 12.09.2020-11:41:13
O Ordered Time stamp 2020/12/09-11:41:13
B Base Time stamp Wed Dec 09 07:40:45 2020
```

### Time('MS'/'US'/'CPU')

Time has gotten new input parameters:

- MS Time of today in seconds.milliseconds
- US Time of today in seconds.microseconds
- CPU used CPU time in seconds.milliseconds

### LINKMVS(load-module, parms)

### LINKPGM(load-module, parms)

Start a load module. Parameters work according to standard
conventions.

### LOCK('lock-string', <TEST/SHARED/EXCLUSIVE><, timeout>)

### UNLOCK('lock-string')

Locks/unlocks a resource to avoid concurrent access to it

### TIMESTAMP()

TIMESTAMP returns the unix (epoch) time, seconds since 1.
January 1970.

## BREXX V2R4M1

### Important Changes

#### RAKF restrictions lifted

We have removed the rigid RAKF checking during the BREXX startup,
which caused unnecessary ABENDS for non-authorized users (e.g. HERC03,
HERC04). Some of the BREXX functions which require access to system
resources (SVC244, DIAGCMD) are no longer available to non-authorized
users, they will be reported as unknown functions.

#### Matrix and Integer Arrays

Added are mathematical Matrix functions and integer arrays. Both allow
high-performance access and large-sized matrices and integer arrays
outside the standard stem notation.
