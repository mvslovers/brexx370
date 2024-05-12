# BREXX MVS Functions

## Host Environment Commands

### ADDRESS MVS

> Interface to certain REXX environments as VSAM and EXECIO

### ADDRESS TSO

Interface to the TSO commands, e.g. LISTCAT, ALLOC, FREE, etc.

Using the ADDRESS TSO command requires a TSO command processor module of the
specified name. It will be called using the normal MVS conventions. If the
module can’t be loaded an error message will be displayed:

> Error: Command TIME not found
> 1 - ADDRESS TSO TIME
> +++ RC(-3) +++

Any parameter for the module is supplied to the module in the CPPL format.
TSO does some internal routing e.g. TIME, which is not a command processor
module but will output the current time if performed in plain TSO. The
BREXX command ADDRESS TSO TIME will lead to an error.

### ADDRESS COMMAND ‘CP host-command’

Interface to the Host system in which your MVS3.8 is running. Typically
it is Hercules or VM370. The result of the command is displayed on
screen, but can be trapped in a stem by the OUTTRAP command:

```rexx
call outtrap('myresult.')
ADDRESS COMMAND 'CP help'
call outtrap('off')
/* result is stored in stem myresult. */
do i=1 to myresult.0
Say mayresult.i
end
```

Some Hercules commands:

ADDRESS COMMAND ‘CP HELP’ to get a list of Hercules commands:

```default
HHC01603I
HHC01602I Command           Description
HHC01602I ----------------  ----------------------------------
HHC01602I !message          *SCP priority message
HHC01602I #                 Silent comment
HHC01602I *                 Loud comment
HHC01602I .reply            *SCP command
HHC01602I ?                 alias for help
HHC01602I abs               *Display or alter absolute storage
HHC01602I aea               Display AEA tables
HHC01602I aia               Display AIA fields
...
```

ADDRESS COMMAND ‘CP DEVLIST’ shows a list of all active devices:

```default
HHC02279I 0:0009 3215 *syscons cmdpref(/) IO[1541] open
HHC02279I 0:000C 3505 0.0.0.0:3505 sockdev ascii autopad trunc eof IO[3]
HHC02279I      (no one currently connected)
HHC02279I 0:000D 3525 /punchcards/pch00d.txt ebcdic IO[2] open
HHC02279I 0:000E 1403 /printers/prt00e.txt IO[6] open
HHC02279I 0:000F 3211 /printers/prt00f.txt IO[2] open
HHC02279I 0:0010 3270 GROUP=CONSOLE IO[3]
HHC02279I 0:0015 1403 /logs/mvslog.txt IO[2106] open
HHC02279I 0:001A 3505 0.0.0.0:3506 sockdev ebcdic autopad eof IO[3]
HHC02279I      (no one currently connected)
```

And many others: ADDRESS COMMAND ‘CP clocks’:

```default
HHC02274I tod = DC8F485DBB377093    2022.349 21:07:20.582007
HHC02274I h/w = DC8F485DBB377093    2022.349 21:07:20.582007
HHC02274I off = 0000000000000000       0.000 00:00:00.000000
HHC02274I ckc = DC8F485DC0400000    2022.349 21:07:20.602624
HHC02274I cpt = 7FFFFF7A01C85F00
HHC02274I itm = 7C0E1623                     07:31:40.233415
```

If you run under control of VM370 you can run VM commands:
ADDRESS COMMAND ‘CP vm-command’

### ADDRESS FSS

Interface to the Formatted Screen Services. Please refer to formatted_screens.rst
contained in the installation zip file.

#### NOTE
The following host environments enable you to call external programs.
The difference is the linkage conventions, and how input parameters
are treated.

### ADDRESS LINK/LINKMVS/LINKPGM

Call external an external program. The linkage convention of the called program can be found here:
[The LINK and ATTACH host command environments](https://www.ibm.com/support/knowledgecenter/SSLTBW_2.3.0/com.ibm.zos.v2r3.ikja300/ikja30030.htm)

### ADDRESS LINKMVS

Call an external program. The linkage convention of the called program can be found here:
[The LINKMVS and ATTCHMVS host command environments](https://www.ibm.com/support/knowledgecenter/SSLTBW_2.3.0/com.ibm.zos.v2r3.ikja300/ikja30031.htm)

Example:

```rexx
/* REXX - INVOKE IEBGENER WITH ALTERNATE DDNAMES. */
PROG = 'IEBGENER'
PARM = ''                    /* STANDARD PARM, AS FROM JCL */
DDLIST = COPIES('00'X,8) ||, /* DDNAME 1 OVERRIDE: SYSLIN   */
COPIES('00'X,8) ||,          /* DDNAME 2 OVERRIDE: N/A      */
COPIES('00'X,8) ||,          /* DDNAME 3 OVERRIDE: SYSLMOD  */
COPIES('00'X,8) ||,          /* DDNAME 4 OVERRIDE: SYSLIB   */
LEFT('CTL', 8) ||,           /* DDNAME 5 OVERRIDE: SYSIN    */
LEFT('REP', 8) ||,           /* DDNAME 6 OVERRIDE: SYSPRINT */
COPIES('00'X,8) ||,          /* DDNAME 7 OVERRIDE: SYSPUNCH */
LEFT('INP', 8) ||,           /* DDNAME 8 OVERRIDE: SYSUT1   */
LEFT('OUT', 8) ||,           /* DDNAME 9 OVERRIDE: SYSUT2   */
COPIES('00'X,8) ||,          /* DDNAME 10 OVERRIDE: SYSUT3  */
COPIES('00'X,8) ||,          /* DDNAME 11 OVERRIDE: SYSUT4  */
COPIES('00'X,8) ||,          /* DDNAME 12 OVERRIDE: SYSTERM */
COPIES('00'X,8) ||,          /* DDNAME 13 OVERRIDE: N/A     */
COPIES('00'X,8)              /* DDNAME 14 OVERRIDE: SYSCIN  */
ADDRESS 'LINKMVS' PROG 'PARM DDLIST'
```

### ADDRESS LINKPGM

Call an external program. The linkage convention of the called program can be found here:

[The LINKPGM and ATTCHPGM host command environments](https://www.ibm.com/support/knowledgecenter/SSLTBW_2.3.0/com.ibm.zos.v2r3.ikja300/ikja30034.htm)

### ADDRESS ISPEXEC

Support calls functions to **Wally Mclaughlin ISPF** for MVS on
Hercules. The functions supported depend on the functionality
implemented in his API. Example:

```default
ADDRESS ISPEXEC
"CONTROL ERRORS RETURN"
"DISPLAY PANEL(PANEL1)"
```

### OUTTRAP

If the commands writes output to terminal you can trap the output using
the OUTTRAP command. This will redirect it to a stem variable of your
choice. Output produced by TSO full-screen macros cannot be trapped. OUTTRAP
is not able to catch all output written to the terminal, it depends on the
style which is used to perform the write. It may also happen that functions
using TSO services will stop the recording without an OUTTRAP(‘OFF’).

```rexx
call outtrap('lcat.')
ADDRESS TSO 'LISTCAT LEVEL “BREXX”'
call outtrap('off')
/* listcat result is stored in stem lcat. */
do i=1 to lcat.0
  Say lcat.i
end
```

Result:

```default
NONVSAM ------- PEJ.BLOX
    IN-CAT --- SYS1.UCAT.TSO
NONVSAM ------- PEJ.BREXX.INST
    IN-CAT --- SYS1.UCAT.TSO
NONVSAM ------- PEJ.BREXX.INST2
    IN-CAT --- SYS1.UCAT.TSO
NONVSAM ------- PEJ.BREXX.NJE.INST2
    IN-CAT --- SYS1.UCAT.TSO
NONVSAM ------- PEJ.CMDPROC
    IN-CAT --- SYS1.UCAT.TSO
NONVSAM ------- PEJ.CNTL
    IN-CAT --- SYS1.UCAT.TSO
NONVSAM ------- PEJ.DSSLOAD.JCL
    IN-CAT --- SYS1.UCAT.TSO
...
```

### ARRAYGEN

Similar to OUTTRAP, ARRAYGEN records output and places it in a source
array (SARRAY).  The recording is stopped with an ARRAGEN(‘OFF’), returning,
the source array number. Where array-number receives the created array number
which can be processed with the SARRAY functions. ARRAYGEN the same
limitations apply as for OUTTRAP.

```rexx
call arraygen('ON')
ADDRESS TSO 'LISTCAT LEVEL(BREXX)'
s1=arraygen('OFF')
call slist(s1)
```

Result:

```default
    Entries of Source Array: 0
Entry   Data
-------------------------------------------------------
00001   NONVSAM ------- BREXX.$FIX.LINKAPF.NJE38.XMIT
00002        IN-CAT --- SYS1.VMASTCAT
00003   NONVSAM ------- BREXX.$FIX.LINKAPF.XMIT
00004        IN-CAT --- SYS1.VMASTCAT
00005   NONVSAM ------- BREXX.$FIX.LINKLIB.NJE38.XMIT
00006        IN-CAT --- SYS1.VMASTCAT
00007   NONVSAM ------- BREXX.$FIX.LINKLIB.XMIT
00008        IN-CAT --- SYS1.VMASTCAT
00009   NONVSAM ------- BREXX.$INSTALL.MASTER.CNTL
00010        IN-CAT --- SYS1.VMASTCAT
```
