#import "../bookmaster/bookmaster.typ": *

= Installing BREXX/370 <ug-install>

#idx("installation")
This chapter describes how BREXX/370 is installed on MVS 3.8j and how TSO is
set up to use it. Release 3.0 is installed with SMP, the System Modification
Program of MVS 3.8j, which keeps a record of what was installed and can
replace it with a later release in one step. The installation by hand that
earlier releases used is described as well, for a system where SMP is not
an option.

#note[*Draft.* The SMP package of BREXX/370 3.0 is being built. The
sections on SMP and on the installation by hand describe the procedure as
planned; what is marked _to be confirmed_ has not yet been run on any
system. The preview 3.0.0-dev replaces the load modules of a V2R5M3
installation, as @ug-install-preview describes.]

== Before You Start <ug-install-pre>

#idx("TK4-")#idx("TK5")#idx("MVS/CE")
BREXX/370 is developed and tested on the MVS 3.8j distributions TK4-, TK5
and MVS/CE, and runs on others that keep to the same system level. TK5 and
MVS/CE come with an earlier BREXX/370 release installed.

Check these points first:

- *A test system.* Install a new release on a copy of your system first. A
  Hercules system is a directory; copying it is enough.
- *Region size.* The installation jobs and BREXX/370 itself ask for
  #cmd("REGION=8192K"). A system that answers #cmd("REGION UNAVAILABLE,
  ERROR CODE=20") accepts 4 or 6 MB: change the #cmd("REGION") parameter of
  the job. TK4-, TK5 and MVS/CE accept 8 MB.
- *RECEIVE.* Where #cmd("RECV370") is not in a library of the link list, a
  job that runs it needs a #cmd("STEPLIB") DD statement for it. On MVS/CE
  it is in #cmd("SYSC.LINKLIB")\; TK4- and TK5 need no #cmd("STEPLIB").
- *The BREXX alias.* The BREXX data sets are cataloged under the high-level
  qualifier #cmd("BREXX"). Define it as an alias of a user catalog, so that
  they are not cataloged in the master catalog:
  ```
  //ADDBREXX EXEC PGM=IDCAMS
  //SYSPRINT DD SYSOUT=*
  //SYSIN    DD *
    DEFINE ALIAS (NAME(BREXX) RELATE(your.user.catalog))
  ```
  #cmd("LISTCAT ENTRIES('BREXX') ALL") shows whether it exists. TK5 has it.
- *#cmd("NOTIFY=&SYSUID").* The jobs carry it on the job card. A system
  without the usermod that resolves #cmd("&SYSUID") at submit time
  (ZP60034, applied in TK5 and MVS/CE) needs your user ID there instead.

#idx("full-screen environment")
BREXX/370 works in the TSO full-screen environments RFE and REVIEW, RPF and
the ISPF of Wally McLaughlin.

== Installing with SMP <ug-install-smp>

#idx("SMP", "installation")#idx("TBRX300")
#note[*To be confirmed.* This section describes the SMP package as it is
planned. It is not yet published.]

BREXX/370 3.0 is the SMP function #cmd("TBRX300") (proposed). The SYSMOD
carries the load modules: #cmd("BREXX") with its aliases #cmd("REXX") and
#cmd("RX"), and #cmd("IRXVTOC"), #cmd("IRXVSMIO") and #cmd("IRXVSMTR").
Installing it is a RECEIVE, an APPLY and an ACCEPT. The other libraries --
RXLIB, CMDLIB, the samples, the JCL and the procedures -- come as TSO
TRANSMIT files beside it; whether RXLIB moves into the SYSMOD is open. The
release page of each version carries the package and the jobs.

+ Upload the package to MVS: a sequential data set with #cmd("RECFM=FB") and
  #cmd("LRECL=80").
+ Change the data set names and the job card of the installation job and
  submit it. It receives the function, checks the apply, applies and
  accepts it.
+ *Check the result by listing the target libraries*, not by the condition
  codes. SMP can end every step with condition code 0 and still copy
  nothing, when another function owns a module of the same name. The load
  module #cmd("BREXX") with its aliases #cmd("REXX") and #cmd("RX") must be
  in the load library.

The data set names of release 3.0 carry no version: #cmd("BREXX.LINKLIB"),
#cmd("BREXX.RXLIB") and so on, so that an upgrade changes no allocation.
Whether the load library must be APF-authorized, and how the SYSMOD
replaces a BREXX/370 installed by hand, are to be confirmed with the
package.

#idx("IRXVTOC")
#cmd("IRXVTOC") runs as a TSO command, so it must be in the link list or in
the #cmd("STEPLIB") of the session; the other modules are loaded by the
interpreter.

== Installing by Hand <ug-install-manual>

#idx("installation", "by hand")
#note[*To be confirmed.* The procedure of V2R5M3, below, uploads one TSO
TRANSMIT file and unpacks it with a series of jobs. Which of these steps
release 3.0 keeps is decided with its package; the aim is fewer steps.]

The installation by hand of V2R5M3 has these steps:

+ Upload the release file, a TSO TRANSMIT file, to a data set with
  #cmd("RECFM=FB") and #cmd("LRECL=80"), and RECEIVE it into
  #cmd("BREXX.")#var("version")#cmd(".INSTALL"). That data set must not be
  cataloged from an earlier attempt: RECEIVE then leaves the new one
  uncataloged with #cmd("NOT CATLG 2"), and the later jobs use the old one.
+ Submit #cmd("$UNPACK") from that library. It unpacks the libraries
  #cmd("CMDLIB"), #cmd("SAMPLE"), #cmd("JCL"), #cmd("LINKLIB"),
  #cmd("APFLLIB"), #cmd("PROCLIB") and #cmd("RXLIB") under
  #cmd("BREXX.")#var("version"). It deletes earlier copies first, and
  those delete steps end with return code 4 when there is nothing to
  delete.
+ Submit #cmd("$INSTALL"), which copies the load modules into
  #cmd("SYS2.LINKLIB") and the procedures into #cmd("SYS2.PROCLIB") -- or
  #cmd("$INSTAPF") instead, for the authorized form (@ug-install-apf).
+ Log off and on again, so that TSO loads the new modules.
+ Submit #cmd("$TESTRX") to test the installation. Every step should end
  with return code 0.
+ Submit #cmd("$CLEANUP") to delete the installation libraries that are no
  longer needed.

#note[If BREXX/370 abends with S106 after an installation, the copy into
#cmd("SYS2.LINKLIB") has taken a new extent of the library. MVS reads the
extents of the link list at IPL: re-IPL, or compress #cmd("SYS2.LINKLIB")
with IEBCOPY.]

=== The Preview 3.0.0-dev <ug-install-preview>

#idx("3.0.0-dev")
The preview of release 3.0 carries the load modules only. It is installed
over a V2R5M3 installation, whose RXLIB, samples and procedures it keeps:

+ Upload #cmd("brexx370-3.0.0-dev-load.xmit") in binary to a data set with
  #cmd("RECFM=FB") and #cmd("LRECL=80").
+ In TSO, #cmd("RECEIVE INDSN('")#var("your.BREXX.XMIT")#cmd("')"), and at
  the prompt answer #cmd("DSNAME('")#var("your.BREXX.V3R0M0D.LINKLIB")#cmd("')").
  The library holds #cmd("BREXX") with its aliases #cmd("REXX") and
  #cmd("RX"), and #cmd("IRXVTOC"), #cmd("IRXVSMIO") and #cmd("IRXVSMTR").
+ Try it with a #cmd("STEPLIB") first. Then copy every member, the aliases
  included, over the V2R5M3 modules in your link list library with IEBCOPY
  and #cmd("INDD=((IN,R))"). Keep a copy of the old modules.
+ Use an authorized library if V2R5M3 was installed authorized.
+ Remove the DD statements #cmd("STDOUT"), #cmd("STDERR") and
  #cmd("STDIN") from your #cmd("RXTSO") procedure (@ug-run).

== Setting Up TSO <ug-install-tso>

#idx("logon procedure", "allocations")#idx("SYSEXEC")#idx("SYSUEXEC")
For #cmd("RX") and #cmd("REXX") to find execs and the functions of RXLIB,
the TSO session needs some allocations. The example uses the data set names
of an installation by hand, #cmd("BREXX.")#var("version")#cmd(".RXLIB")\;
with release 3.0 installed by SMP the name has no version. Make them in the logon CLIST --
#cmd("SYS1.CMDPROC(USRLOGON)") on TK4- and TK5,
#cmd("SYS1.CMDPROC(TSOLOGON)") on MVS/CE -- before the line
#cmd("%STDLOGON"). Back up the CLIST first: an error in it can keep every
user from logging on.

```
/* ALLOCATE RXLIB IF PRESENT */
IF &SYSDSN('BREXX.version.RXLIB') EQ &STR(OK) THEN DO
  FREE FILE(RXLIB)
  ALLOC FILE(RXLIB) DSN('BREXX.version.RXLIB') SHR
END
/* ALLOCATE SYSEXEC TO SYS2 EXEC */
IF &SYSDSN('SYS2.EXEC') EQ &STR(OK) THEN DO
  FREE FILE(SYSEXEC)
  ALLOC FILE(SYSEXEC) DSN('SYS2.EXEC') SHR
END
/* ALLOCATE SYSUEXEC TO USER EXECS */
IF &SYSDSN('&SYSUID..EXEC') EQ &STR(OK) THEN DO
  FREE FILE(SYSUEXEC)
  ALLOC FILE(SYSUEXEC) DSN('&SYSUID..EXEC') SHR
END
```

To use the TSO commands of CMDLIB by name, add
#cmd("BREXX.")#var("version")#cmd(".CMDLIB") to the #cmd("SYSPROC")
concatenation of the same CLIST. Most of them run an exec of the samples
library, which must then be in #cmd("SYSEXEC") or #cmd("SYSUEXEC") as well.

After an upgrade, change the data set name of the RXLIB allocation to that
of the new release. @ug-calling describes in which order the libraries are
searched.

== Running Authorized <ug-install-apf>

#idx("authorized", "BREXX/370")#idx("APF")
An exec that calls a program which must run authorized -- IEBCOPY, NJE38
and other utilities -- needs BREXX/370 to run authorized itself: the load
modules in an APF-authorized library, and TSO told that the command
#cmd("BREXX") and its aliases may run authorized. On TK4-, as V2R5M3
installed it with #cmd("$INSTAPF"):

+ Add #cmd("BREXX"), #cmd("REXX") and #cmd("RX") to the table of
  authorized commands in #cmd("SYS1.UMODSRC(IKJEFTE2)") and
  #cmd("SYS1.UMODSRC(IKJEFTE8)"):
  ```
           DC    C'BREXX   '             BREXX/370
           DC    C'REXX    '             BREXX/370
           DC    C'RX      '             BREXX/370
  ```
+ Submit #cmd("SYS1.UMODCNTL(ZUM0001)") and #cmd("SYS1.UMODCNTL(ZUM0014)").
+ IPL with #cmd("CLPA"), shut down, and IPL normally.

The environment that starts BREXX/370 must be authorized as well: plain TSO
is, the ISPF of Wally McLaughlin and RFE must be made so, or an exec called
from them abends, usually with S306.

#note[*To be confirmed* for release 3.0 and the SMP package. The 3.0 load
module is linked with authorization code 1, and runs unauthorized from a
library that is not APF-authorized as well.]

== The TSO Integration: ZMG0001 <ug-install-zmg>

#idx("ZMG0001")#idx("EXEC command", "runs REXX")
With the usermod ZMG0001, the TSO command #cmd("EXEC") and the implicit
call of an exec run REXX through BREXX/370, by the rules of TSO/E:

- #cmd("%")#var("name") or #var("name"): the member is searched in
  #cmd("SYSUEXEC"), #cmd("SYSUPROC"), #cmd("SYSEXEC") and #cmd("SYSPROC"),
  in that order. A member found in #cmd("SYSUEXEC") or #cmd("SYSEXEC") is
  REXX. A member found in #cmd("SYSUPROC") or #cmd("SYSPROC") is REXX only
  if line 1 is a comment containing #cmd("REXX")\; otherwise a
  #cmd("SYSUPROC") member is passed over and a #cmd("SYSPROC") member runs
  as a CLIST.
- #cmd("EXEC '")#var("ds")#cmd("(")#var("member")#cmd(")'"): REXX if line
  1 is such a comment, whatever the library; otherwise a CLIST.
- #cmd("EXEC '")#var("ds")#cmd("(")#var("member")#cmd(")' EXEC") (also
  #cmd("E"), #cmd("EX"), #cmd("EXE")): REXX. An unqualified name gets the
  suffix #cmd(".EXEC") instead of #cmd(".CLIST").
- The exec gets its argument as on z/OS: called implicitly, the operands
  after the name as typed, without leading and trailing blanks; called with
  #cmd("EXEC"), the quoted value list without its outer quotes, with
  #cmd("''") halved.

*A name in both SYSEXEC and SYSPROC.* With ZMG0001 the exec in
#cmd("SYSEXEC") runs, even when the #cmd("SYSPROC") member is a CLIST --
the TSO/E default. Without it, #cmd("EXEC") on MVS 3.8j searches
#cmd("SYSPROC") only, so installing the usermod changes what such a name
runs. Before you apply it, look for member names that are in a
#cmd("SYSEXEC") library and in a #cmd("SYSPROC") library of your logon
procedures, and rename one of the two. On MVS/CE, #cmd("SHUTDOWN") is such
a name.

ZMG0001 changes the load module #cmd("EXEC") in #cmd("SYS1.CMDLIB") only,
and is active at once, with no IPL.

*Prerequisites.*
- BREXX/370 3.0 or later in the link list, as the load module
  #cmd("BREXX"). Without it, #cmd("EXEC") stays CLIST-only.
- PTF UY16532 applied: #cmd("LIST CDS SYSMOD(UY16532) .")
- Neither ZMG0002 (the TSO integration of REXX/370) nor ZMG0003 (both side
  by side) installed. The three change the same elements; restore the one
  installed before applying another.

*Jobs.* Every release page carries the usermod as #cmd("ZMG0001.smp") and
the jobs as #cmd("ZMG0001-jobs.zip"): #cmd("ZMG01CK") checks the
prerequisites, #cmd("ZMG01BK") backs up #cmd("EXEC"), #cmd("ZMG01RC")
receives the usermod and checks the apply, #cmd("ZMG01AP") applies it and
#cmd("ZMG01RS") removes it. Change the data set names marked
#cmd("YOUR...") and the job card before you submit them.

*Installation.*
+ Back up #cmd("SYS1.CMDLIB(EXEC,EX)") with IEBCOPY. This copy is the way
  back.
+ Note the extents of #cmd("SYS1.CMDLIB"). The apply rewrites #cmd("EXEC"),
  about 26 KB.
+ Receive the usermod and check the apply with the SMPAPP procedure:
  ```
  //SMP      EXEC SMPAPP
  //HMASMP.CMDLIB   DD DSN=SYS1.CMDLIB,DISP=SHR
  //HMASMP.AOST4    DD DSN=SYS1.AOST4,DISP=SHR
  //HMASMP.SMPPTFIN DD DSN=your.ZMG0001.SMPPTFIN,DISP=SHR
  //HMASMP.SMPCNTL  DD *
    RECEIVE SELECT(ZMG0001) .
    APPLY SELECT(ZMG0001) CHECK .
  /*
  ```
  Then run the job again with #cmd("APPLY SELECT(ZMG0001) .") in place of
  both statements. The output must show #cmd("HMA2390 LINK SUCCESSFUL") for
  #cmd("IKJCT430") and #cmd("IKJCT437").
+ Compare the extents of #cmd("SYS1.CMDLIB") with those you noted. If the
  apply took a new extent, #cmd("EXEC") cannot be loaded
  (#cmd("IEA703I 106-F")) until the next IPL.
+ Do not ACCEPT the usermod.

*Restrictions.*
- An explicit #cmd("EXEC") of a sequential data set always runs as a CLIST;
  a REXX exec must be a member of a partitioned data set.
- The argument of an explicit #cmd("EXEC") loses its leading and trailing
  blanks.
- In a concatenation, a later library with larger blocks than the first
  cannot be read; a member there is taken for a CLIST.

*Removal* (job #cmd("ZMG01RS")). Run #cmd("RESTORE SELECT(ZMG0001) .")
with the same procedure, then copy the saved #cmd("EXEC") and #cmd("EX")
back into #cmd("SYS1.CMDLIB"): RESTORE relinks #cmd("EXEC") from
#cmd("SYS1.AOST4"), and the backup is the level from before the apply.
RESTORE also takes ZMG0001 off the SMP data sets, so it can be received
again. It needs PTF UY16532 _accepted_\; if it is only applied, RESTORE
ends with #cmd("HMA3022 ... MISSING/NOGO REQUISITES: UY16532 PRE"). Accept
it first with #cmd("ACCEPT SELECT(UY16532) .") (back up
#cmd("SYS1.AOST4(IKJCT430,IKJCT431)") before), or copy the saved
#cmd("EXEC") and #cmd("EX") back without SMP and leave ZMG0001 in the
inventory.

== Talking to the Host System <ug-install-cp>

#idx("ADDRESS COMMAND", "CP")#idx("DIAG8CMD")
An exec can pass a command to the control program under which MVS runs --
Hercules, or VM -- with #cmd("ADDRESS COMMAND 'CP ")#var("command")#cmd("'").
Under Hercules the command is a Hercules command, such as
#cmd("ADDRESS COMMAND 'CP DEVLIST'"), and Hercules must accept commands
from the guest: #cmd("DIAG8CMD ENABLE") on the Hercules console. TK4-, TK5
and MVS/CE enable it. BREXX/370 obtains the authorization the command needs
itself; where RAKF refuses it, the command ends with return code -5. The _BREXX/370 Reference_ describes the command
environment.

== Checking the Installation <ug-install-check>

#idx("installation", "checking")
Log off and on again, so that TSO loads the new modules, and run an exec
that shows the version:

```
/* REXX */
PARSE VERSION v
SAY v
```

The version shown must be the release you installed. If an exec reports
errors in strange places, check that it has no line numbers: BREXX/370
reads columns 73 to 80 as part of the line. The primary command
#cmd("UNNUM") of the RFE and RPF editors removes them.
