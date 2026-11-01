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

=== When You Need It

You need ZMG0001 only to start an exec like a TSO command. Without it,
#cmd("RX"), #cmd("REXX") and #cmd("BREXX") run an exec at a terminal and
under TSO in a batch job, and a batch job runs it without TSO (@ug-run);
#cmd("EXEC") and the implicit call of a name stay CLIST-only.

TK5 Update 6 installs ZMG0001 together with BREXX/370 3.0, so there is
nothing to do there. On every other system -- MVS/CE, TK5 before Update 6,
other distributions -- you install it yourself from the release.

The usermod comes as source. The release page of BREXX/370 3.0 and of
every later release carries the jobs as #cmd("ZMG0001-jobs.zip")\; no
object decks and no SMP package file go with them. The job #cmd("ZMG01RC")
holds the usermod itself, with the assembler source of the two modules
#cmd("IKJCT430") and #cmd("IKJCT437") in its in-stream data, and assembles
them on your system, so the objects are made by your own assembler. The
job has about 4200 cards.


#tab(caption: [The ZMG0001 jobs])[
  #table(columns: (1in, 1fr),
    [Job], [Purpose],
    [#cmd("ZMG01CK")], [Lists PTF UY16532 and the usermods ZMG0001 to
      ZMG0003.],
    [#cmd("ZMG01BK")], [Backs up #cmd("EXEC") and #cmd("EX").],
    [#cmd("ZMG01RC")], [Assembles the two modules, receives the usermod and
      checks the apply.],
    [#cmd("ZMG01AP")], [Applies the usermod.],
    [#cmd("ZMG01RS")], [Removes the usermod and copies the backup back.],
  )
]

Change the job card before you submit a job, and the data set name
#cmd("YOUR.ZMG0001.BACKUP") in #cmd("ZMG01BK") and #cmd("ZMG01RS"): it is
the backup library, and both jobs must use the same name. #cmd("ZMG01RC")
has no such name; nothing is uploaded and no data set is renamed.

=== What Changes

ZMG0001 changes the load module #cmd("EXEC") in #cmd("SYS1.CMDLIB") only,
and is active at once, with no IPL.

*A name in both SYSEXEC and SYSPROC.* With ZMG0001 the exec in
#cmd("SYSEXEC") runs, even when the #cmd("SYSPROC") member is a CLIST --
the TSO/E default. Without it, #cmd("EXEC") on MVS 3.8j searches
#cmd("SYSPROC") only, so installing the usermod changes what such a name
runs. Before you apply it, look for member names that are in a
#cmd("SYSEXEC") library and in a #cmd("SYSPROC") library of your logon
procedures, and rename one of the two. On MVS/CE, #cmd("SHUTDOWN") is such
a name.

*Restrictions.*
- An explicit #cmd("EXEC") of a sequential data set always runs as a CLIST;
  a REXX exec must be a member of a partitioned data set.
- The argument of an explicit #cmd("EXEC") loses its leading and trailing
  blanks.
- In a concatenation, a later library with larger blocks than the first
  cannot be read; a member there is taken for a CLIST.

=== Prerequisites

- BREXX/370 3.0 or later in the link list, as the load module
  #cmd("BREXX"). Without it, #cmd("EXEC") stays CLIST-only.
- PTF UY16532 applied. Check it with #cmd("LIST CDS SYSMOD(UY16532) .")
  (job #cmd("ZMG01CK")).
- None of the other two TSO integrations installed: ZMG0002 is the one of
  REKX/370 (rekx370), ZMG0003 (planned) runs BREXX/370 and REKX/370 side by
  side. The three change the same elements and exclude each other\; restore
  the one installed before you apply another.
- The macro libraries #cmd("SYS1.MACLIB") and #cmd("SYS1.AMODGEN") and the
  assembler #cmd("IFOX00"), which #cmd("ZMG01RC") uses.
- *On MVS/CE, update TSO first.* MVS/CE has UY16532 applied but not
  accepted: #cmd("LIST CDS SYSMOD(UY16532) .") shows status
  #cmd("REC APP"). Installing ZMG0001 works that way, but removing it does
  not, because RESTORE needs the PTF accepted (see *Removal*). Accept it
  before you install ZMG0001, as described next.

*Accepting UY16532.* This updates #cmd("SYS1.AOST4"), so it is your decision.
+ Back up #cmd("SYS1.AOST4(IKJCT430,IKJCT431)") with IEBCOPY. Change the
  name of the new library, #cmd("YOUR.AOST4.BACKUP"), and keep the library:
  ```
  //AOST4BK  JOB (BREXX),'AOST4',CLASS=A,
  //         MSGCLASS=H,MSGLEVEL=(1,1)
  //COPY     EXEC PGM=IEBCOPY,REGION=4096K
  //SYSPRINT DD SYSOUT=*
  //SYSUT3   DD UNIT=SYSDA,SPACE=(CYL,(1,1))
  //SYSUT4   DD UNIT=SYSDA,SPACE=(CYL,(1,1))
  //IN       DD DSN=SYS1.AOST4,DISP=SHR
  //OUT      DD DSN=YOUR.AOST4.BACKUP,
  //            DISP=(NEW,CATLG,DELETE),
  //            UNIT=SYSDA,SPACE=(TRK,(10,5,5)),
  //            DCB=(RECFM=U,BLKSIZE=19069,DSORG=PO)
  //SYSIN    DD *
    COPY INDD=IN,OUTDD=OUT
    SELECT MEMBER=(IKJCT430,IKJCT431)
  /*
  //
  ```
+ Run #cmd("ACCEPT SELECT(UY16532) .") with the SMPAPP procedure, as in the
  receive step of the installation below.
+ Check the listing. The accept relinks the two members and ends with
  condition code 4 (unresolved external references with NCAL), which is
  expected. The listing must show #cmd("ACCEPTED") for #cmd("IKJCT430") and
  #cmd("IKJCT431").

=== Installation

+ Check the prerequisites (job #cmd("ZMG01CK")).
+ Back up #cmd("SYS1.CMDLIB(EXEC,EX)") with IEBCOPY (job #cmd("ZMG01BK")).
  This copy is the way back.
+ *Check how full* #cmd("SYS1.CMDLIB") is. The apply rewrites #cmd("EXEC"),
  about 26 KB, behind the last member\; a partitioned data set does not
  reuse the old space. On MVS/CE, #cmd("SYS1.CMDLIB") is one extent and
  93 % full: one apply took it to 95 %, and a removal with a second apply to
  100 %. Compress it before you install, with IEBCOPY copying the library
  onto itself, while no one is logged on to TSO. That brought it back to
  91 %. The job:
  ```
  //COMPRESS JOB (BREXX),'CMDLIB',CLASS=A,
  //         MSGCLASS=H,MSGLEVEL=(1,1)
  //COPY     EXEC PGM=IEBCOPY,REGION=4096K
  //SYSPRINT DD SYSOUT=*
  //SYSUT3   DD UNIT=SYSDA,SPACE=(CYL,(1,1))
  //SYSUT4   DD UNIT=SYSDA,SPACE=(CYL,(1,1))
  //CMD      DD DSN=SYS1.CMDLIB,DISP=OLD
  //SYSIN    DD *
    COPY INDD=CMD,OUTDD=CMD
  /*
  //
  ```
+ Note the extents of #cmd("SYS1.CMDLIB").
+ Assemble, receive and check (job #cmd("ZMG01RC")). Take the job from
  #cmd("ZMG0001-jobs.zip"), change the job card, and submit it. Nothing is
  uploaded first. Its steps are:
  - #cmd("MCS1") writes the first part of the usermod, the cover letter and
    the link-edit control (#cmd("++JCLIN")), to a temporary data set with
    IEBGENER.
  - #cmd("ASM430") assembles #cmd("IKJCT430") with #cmd("IFOX00") against
    #cmd("SYS1.MACLIB") and #cmd("SYS1.AMODGEN") and appends the object
    deck to that data set. #cmd("MCS2") and #cmd("ASM437") do the same for
    #cmd("IKJCT437").
  - #cmd("SMP") runs the SMPAPP procedure on the data set as
    #cmd("SMPPTFIN"):
    ```
     RECEIVE SELECT(ZMG0001) .
     APPLY SELECT(ZMG0001) CHECK .
    ```
  The assemblies must end with condition code 0 and the listing line
  #cmd("NO STATEMENTS FLAGGED")\; a step is skipped when an earlier one
  ended with a code above 0. The apply check changes nothing. Its listing
  must show #cmd("IKJCT430") and #cmd("IKJCT437") as #cmd("APPLIED"), not
  as #cmd("NOT SEL").
+ Apply the usermod (job #cmd("ZMG01AP")). The usermod is received by now,
  so the job has no #cmd("SMPPTFIN") statement, and its only SMP statement is
  #cmd("APPLY SELECT(ZMG0001) ."). The output must show
  #cmd("HMA2390 LINK SUCCESSFUL") for #cmd("IKJCT430") and
  #cmd("IKJCT437").
+ Compare the extents of #cmd("SYS1.CMDLIB") with those you noted. If the
  apply took a new extent, #cmd("EXEC") cannot be loaded
  (#cmd("IEA703I 106-F")) until the next IPL.
+ *Verify the result.* A condition code says the job ran, not that the right
  bytes were linked. #cmd("zmginstall verify") compares the #cmd("EXEC") that
  SMP linked from the objects of your assembler with the #cmd("EXEC") linked
  from the object decks that as370 assembled and the tests ran, byte by
  byte. It belongs to the source tree of BREXX/370
  (#cmd("tso/lab/zmg_install.py"), run with
  #cmd("mbt run zmginstall -- verify")), and needs the test library
  #cmd("BREXX370.TSO.LOADLIB") (under your high-level qualifier) on the
  target, which #cmd("tso/build.sh exec") and
  #cmd("mbt run lmodlink -- testlib exec") build. The job lists the
  #cmd("EXEC") of #cmd("SYS1.CMDLIB") and the one of the test library with
  AMBLIST. The output must end with #cmd("VERIFY OK") and show
  #cmd("0 differ") for #cmd("EXEC"). It prints #cmd("VERIFY FAILED") when
  the modules differ, and says so when the test
  library or one of the two listings is missing.
+ Do not ACCEPT the usermod.

#note[*Receiving twice.* #cmd("ZMG01RC") run a second time ends with
condition code 8 in the SMP step (#cmd("HMA3862")): ZMG0001 is already
received. Run #cmd("REJECT SELECT(ZMG0001) .") first, in a job like the
apply job, and then #cmd("ZMG01RC") again.]

=== Removal

Removal needs PTF UY16532 _accepted_. On MVS/CE, accept it as described under
*Prerequisites* if you did not do so before the installation. If it is only
applied, RESTORE ends with #cmd("HMA3022 ... MISSING/NOGO REQUISITES:
UY16532 PRE").

RESTORE and the copy of the saved members each write #cmd("EXEC") behind the
last member of #cmd("SYS1.CMDLIB"), as the apply does. Make room first, as
the installation step that checks how full the library is describes.

+ Check that #cmd("LIST CDS SYSMOD(UY16532) .") shows UY16532 as accepted
  (job #cmd("ZMG01CK")).
+ Note the extents of #cmd("SYS1.CMDLIB").
+ Run #cmd("RESTORE SELECT(ZMG0001) .") with the SMPAPP procedure of the
  installation (job #cmd("ZMG01RS")). RESTORE relinks #cmd("EXEC") from
  #cmd("SYS1.AOST4"), and takes ZMG0001 off the SMP data sets. It can be
  received again as it is: run #cmd("ZMG01RC") unchanged, with no
  #cmd("REJECT") before it.
+ Copy the saved #cmd("EXEC") and #cmd("EX") back into #cmd("SYS1.CMDLIB")
  (the second step of job #cmd("ZMG01RS")). The backup is the level from
  before the apply.
+ Compare the extents of #cmd("SYS1.CMDLIB") with those you noted, as for the
  installation.

If you do not want to accept the PTF, do not run job #cmd("ZMG01RS"): its
first step is the RESTORE. Copy the saved #cmd("EXEC") and #cmd("EX") back
with IEBCOPY instead. ZMG0001 then stays in the SMP inventory.

== Talking to the Host System <ug-install-cp>

#idx("ADDRESS COMMAND", "CP")#idx("DIAG8CMD")
An exec can pass a command to the control program under which MVS runs --
Hercules, or VM -- with #cmd("ADDRESS COMMAND 'CP ")#var("command")#cmd("'").
Under Hercules the command is a Hercules command, such as
#cmd("ADDRESS COMMAND 'CP DEVLIST'"), and Hercules must accept commands
from the guest: #cmd("DIAG8CMD ENABLE") on the Hercules console. TK4-, TK5
and MVS/CE enable it. BREXX/370 obtains the authorization the command needs
itself; where RAKF refuses it, the command ends with return code -5.
#cmd("ADDRESS COMMAND") needs the exec to be started as a TSO command --
#cmd("RX"), #cmd("REXX") or #cmd("BREXX") at a terminal or under
#cmd("IKJEFT01") -- and ends with return code -3 in a batch step without
TSO (@ug-run-batch). The _BREXX/370 Reference_ describes the command
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

The version shown must be the release you installed, in the form
#cmd("BREXX/370 V3R0M0 (Oct  8 2026)") for release 3.0.0.

#idx("line numbers", "in an exec")
*Keep execs free of line numbers.* BREXX/370 reads columns 73 to 80 as part
of the line, so the sequence numbers of a numbered member become program
text: an exec with numbers usually fails at once, with an error such as
#cmd("Invalid command name syntax") for the number after its first
comment. The primary command #cmd("UNNUM") of the RFE and RPF editors
removes them.
