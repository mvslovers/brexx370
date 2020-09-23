![Logo](doc/brexx370.png)

# BRexx370

System/370 (MVS) version of the ingenious [BRexx](https://github.com/vlachoudis/brexx/) interpreter originally by Vasilis N. Vlachoudis. 

## What is REXX?

REXX is a programming language designed by Michael Cowlishaw of IBM UK Laboratories.  In his own words:  "REXX is a procedural language that allows programs and  algorithms to be written in a clear and structured way."

Syntactically, REXX doesn't look that different from any other procedural language.  Here's a simple REXX program:

```rexx
/* Count some numbers */

say "Counting..."
do i = 1 to 10
    say "Number" i
end
```

## Background

BRexx is an open source version of the classic Rexx developed by Vasilis Vlachoudis of the Cern Laboratory in Switzerland. Written as an ANSI C language program, BRexx is notable for its high performance. It also provides a nice collection of special built-in functions and function libraries that offer many extra features over most of the existing Classic Rexx implementations.

BRexx was originally written for DOS in the late eighties/early 1990s. Then,with the rise of Windows, it was revised for the 32-bit world of Windows and 32-bit DOS.  BRexx also runs under the Linux and Unix family of operating systems, and has a good set of functions especially written for Windows CE. Other operating systems on which it runs include: MacOS, BeOS, and the Amiga OS.

One of the outstanding features, among so many, of BRexx is its minuscule footprint. The entire product, written in C, including full documentation and examples, takes up only a measly few hundred kilobytes. It is small enough to fit on a single, ol' school floppy diskette!

Hence, BRexx was prime for re-targeting to MVS/VM for TSO/CMS.  And so it was. Recently, the BRexx Rexx Interpreter was made operational onto the MVS 3.8j platform as BRexx/370 version V2R1M0 and it was released in April of 2019.  The MVS 3.8j (now emulated) mainframe platform which pre-dates IBM's official release of TSO/CMS Rexx published initially, in the next (i.e. XA) set of offerings of IBM mainframe OSes. However, the lack of having a Rexx significantly hampers the MVS 3.8j platform of not only the highly utilitarian features of Rexx as the powerful glue it provides as an operating system's command/macro language, tying all of the vast collection of system resources together programmatically, under one umbrella, but also prevents the users and the MVS 3.8j community from taking advantage of the treasure trove of Rexx-ware scripts/programs/applications that exists currently which greatly enhances the MVS 3.8j user's and MVS 3.8j community's mainframe computing experience, many-fold.

BRexx was made operational, as BRexx/370, targeting the MVS 3.8j platform by: **Peter Jacob** (PEJ), **Mike Groβmann** (MIG) and **Gerard Wassink** (GAW). BRexx/370 now provides a Rexx scripting/command language for the MVS 3.8j platform. 

## Download

Full releases with install instructions are available here: https://github.com/mvslovers/brexx370/releases

## Installation

The following is a high level instalation guide for [tk4-](http://wotho.ethz.ch/tk4-/).

1. Download the most recent release and extract the contents
1. Upload BREXX.*version*.XMIT, or BREXX370.*version*.XMIT (replacing *version* with the version of your release), to tk4- in one of two ways:
    1. Using `x3270` use `File`&rarr;`File Transfer` to upload the file. Make sure you're at the TSO `READY` prompt before initiating the file transfter (hit `F3` on your keyboard when presented with the tk4 screen). Upload the file to `'HERC01.BREXX.version.XMIT'` the single quotes mean "Do not prepend the user id to the filename."
    1. Using FTP: Enable the tk4- ftp servers by typing `/s ftpd,srvport=21021` on the hercules console (If you don't have a console exit hercules and run the script `unattended/set_daemon_mode` in the tk4- folder). Then connect to the ftp server `ftp localhost 21021` and logon with username `HERC01` and password `CUL8TR`. Once connected type `put BREXX.version.XMIT HERC01.BREXX.version.XMIT`.
1. With the XMIT file uploaded run the following JCL to "unload" the XMIT file:

:warning: **Note: make sure you replace `version` to match your version of the release (i.e. `V2R3M0`).**

```JCL
//BRXXREC JOB 'XMIT RECEIVE',CLASS=A,MSGCLASS=H
//* ------------------------------------------------------------
//* RECEIVE XMIT FILE AND CREATE DSN OR PDS
//* ------------------------------------------------------------
//RECV370  EXEC PGM=RECV370,REGION=8192K
//RECVLOG  DD SYSOUT=*
//XMITIN   DD DSN=HERC01.BREXX.version.XMIT,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD DSN=&&XMIT2,
//         UNIT=3390,
//         SPACE=(TRK,(300,60)),
//         DISP=(NEW,DELETE,DELETE)
//SYSUT2   DD DSN=BREXX.version.INSTALL,
//         UNIT=3390,
//         SPACE=(TRK,(300,60,20)),
//         DISP=(NEW,CATLG,CATLG)
//SYSIN DD DUMMY
```


## Building

To build BRexx from source requires the following: 

1. Linux
1. tk4- installed from: http://wotho.ethz.ch/tk4-/tk4-_v1.00_current.zip and daemon mode disabled
    1. `mkdir tk4-test`
    1. `cd tk4-test`
    1. `wget http://wotho.ethz.ch/tk4-/tk4-_v1.00_current.zip`
    1. `unzip tk4-_v1.00_current.zip`
    1. `cd unattended;./set_console_mode`
1. A copy of JCC. A current version of the JCC compiler is available here: https://github.com/mvslovers/jcc . JCC is a precompiled C compiler for MVS.
    1. `git clone https://github.com/mvslovers/jcc.git`
1. rdrprep installed using `make install` from https://github.com/mvslovers/rdrprep
    1. `git clone https://github.com/mvslovers/rdrprep.git`
    2. `cd rdrprep`
    3. `make && sudo make install`

Your build environment is almost setup. To submit jobs the `Makefile` and its subsequent scripts in `./build` requires an EBCDIC socket, by default in tk4 a listener is setup on port 3505 in ASCII mode. To switch it to EBCDIC mode you can either type it in the hercules console or use curl.

1. Start hercules/tk4- From the tk4-test folder run `./mvs` 

2. Once it has completed booting type the following in the hercules console:
    1. `detach c`
    2. `attach c 3505 3506 sockdev ebcdic trunc eof`

**OR**

2. Run the following curl commands from your linux prompt:
    1. `curl -d "command=detach+c" -X POST http://localhost:8038/cgi-bin/tasks/syslog`
    2. `curl -d "command=attach+c+3505+3506+sockdev+ebcdic+trunc+eof" -X POST http://localhost:8038/cgi-bin/tasks/syslog`

:warning: **Note: this also changes the sockdev port to 3506**

:warning: **Note: to change it back run the same same command as above but replace `ebcdic` with `ascii` and `3506` with `3505`.**

If you wish to setup a seperate port and reader so you can have both ASCII and EBCDIC readers you can watch [this video](https://youtu.be/GV-dWA5Flec) but just note that on tk4- the reader should be set to device `20C`.

With everything setup you can now make your changes to the source and type the command `make` in the `./build` directory.

Assuming `make` jobs all return with a `RC= 0000` you can now log on to tk4- and in tso type `RX`, `REXX`, or `BREXX` and receive:

```
 READY 
BREXX
 BREXX/370 V2R3M0 (Sep 22 2020)
 READY 
```

## Makefile

The makefile in the `./build` folder was designed to make compiling and installing BRexx370 easier. For each of the make options a JCL file is created, converted to ebcdic and inline files added with `rdrprep`. The JCL files are heavily commented to allow people new to MVS to follow along.

There are mulitple make options:

1. `make` (`link.jcl`) builds brexx from source and installs it to `SYS2.LINKLIB(BREXX)` with an alias to `SYS2.LINKLIB(REXX)`, and `SYS2.LINKLIB(RX)`
1. `make clean` (`clean.jcl`) will delete build files and remove rexx from tk4-
1. `make install` (`install.jcl`) will compile and install BRexx and also supporting files located in `./mvs/install` to `SYS2.PROCLIB` and `BREXX.version.CMDLIB`, `BREXX.version.RXLIB`, and `BREXX.version.SAMPLES`
1. `make uninstall`  (`clean.jcl`) will delete build files and supporting files/datasets/members on tk4-
1. `make test`  (`test.jcl`) will run various test rexx script and display the output :warning: **requires `make install`**
1. `make release` (`release.jcl`) does the following:
    1. uploads and links brexx placing it in to `BREXX.version.LINKLIB`
    1. uploads proclib JCL to `BREXX.version.PROCLIB`
    1. uploads `BREXX.version.CMDLIB`, `BREXX.version.RXLIB`, and `BREXX.version.SAMPLES` similar to `make install`
    1. uploads `./install/*.*` to  `BREXX.version.INSTALL`
    1. Uses `xmit370` on tk4- to create: `BREXX.version.INSTALL(LINKLIB)`, `BREXX.version.INSTALL(PROCLIB)`, `BREXX.version.INSTALL(CMDLIB)`, `BREXX.version.INSTALL(RXLIB)`, `BREXX.version.INSTALL(SAMPLES)`
    1. Uses `xmit370` again to create `BREXX.version.XMIT` from `BREXX.version.INSTALL`

Let's look at the make file settings:

|                     Setting                    | Function                                                               |
|------------------------------------------------|------------------------------------------------------------------------|
| `JCCFOLDER   := ../../jcc`                     | location of the jcc folder relative to the `build` folder              |
| `RDRPREP     := rdrprep`                       | path to rdrprep                                                        |
| `TK4HOST     := localhost`                     | hostname or IP address of tk4-                                         |
| `TK4PORT     := 3506`                          | port of the EBCDIC listener                                            |
| `TK4USER     := HERC01`                        | tk4- user to submit jobs remotely                                      |
| `TK4PASS     := CUL8TR`                        | tk4- password to submit jobs remotely                                  |
| `TK4PRINTER  := ../../tk4-test/prt/prt00e.txt` | Location of the tk4- msgclass=A printerfile relative to `build` folder |
| `CUSTOMCLASS :=`                               | Intentionally blank. By default the makefile will use `msgclass=A` and  search the printer file for return codes for each step, if it can't find the printer file (`TK4PRINTER`) it will  default to `H`. You can use this setting to set a different `msgclass` |


## Community 

For questions and suggestions you can find us at: [Moshix Discord Channel](https://discordapp.com/invite/eyRjj4t)

##

Please also read the original [README](https://github.com/mgrossmann/brexx370/blob/master/README).
