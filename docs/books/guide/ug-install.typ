#import "../bookmaster/bookmaster.typ": *

= Installing BREXX/370 <ug-install>

#idx("installation")
This chapter describes how BREXX/370 is installed on MVS 3.8j and how TSO is
set up to use it. Release 3.0 is installed with SMP, the System Modification
Program of MVS 3.8j, which keeps a record of what was installed and can
replace it with a later release in one step. The installation by hand that
earlier releases used is described as well, because the installations of
TK5 and MVS/CE were made that way and an upgrade has to deal with them.

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
#note[*Not yet run.* This section follows the design of the SMP package.
The installation job has not yet been run in a clean system, and the names
of the jobs and of the transmit files are not final. What is not measured
is marked in the text; check the list of members (step 3) after you have
installed.]

BREXX/370 3.0 is the SMP function #cmd("TBRX300"). The SYSMOD carries:

- the load modules in #cmd("BREXX.LINKLIB"): #cmd("BREXX") with its aliases
  #cmd("REXX") and #cmd("RX"), and #cmd("IRXVTOC"), #cmd("IRXVSMIO") and
  #cmd("IRXVSMTR");
- the function library as #cmd("BREXX.RXLIB") and the samples as
  #cmd("BREXX.SAMPLIB"), as macro elements, so that all 80 columns of a
  member survive.

The jobs, the procedures and the TSO commands (JCL, PROCLIB, CMDLIB) come as
TSO TRANSMIT files beside the SYSMOD, and are not under SMP's control. The
release page of each version carries the package and the jobs.

The data set names of release 3.0 carry no version, so that an upgrade
changes no allocation. BREXX/370 needs no APF authorization: the load
library is not authorized and the installation does not add it to the APF
list.

+ Upload the package to MVS: a sequential data set with #cmd("RECFM=FB") and
  #cmd("LRECL=80").
+ Change the data set names and the job card of the installation job and
  submit it. It receives the function, checks the apply, applies and
  accepts it.
+ *Check the result by listing the target libraries*, not by the condition
  codes. SMP can end every step with condition code 0 and still copy
  nothing, when another function owns a module of the same name. The load
  module #cmd("BREXX") with its aliases #cmd("REXX") and #cmd("RX") must be
  in #cmd("BREXX.LINKLIB"), and #cmd("LIST SYSMOD(TBRX300)") must show the
  function as applied and accepted.
+ Make the load library known to the system: add #cmd("BREXX.LINKLIB") to
  the link list (#cmd("SYS1.PARMLIB(LNKLST00)") on TK5; on MVS/CE the
  member also lists #cmd("SYS2.LINKLIB") and the command libraries), or
  name it in the #cmd("STEPLIB") of the sessions and jobs that run BREXX/370.
  The link list is read at IPL. If a V2R5M3 copy of the modules is in
  #cmd("SYS2.LINKLIB"), it wins unless #cmd("BREXX.LINKLIB") comes before
  it (_Upgrading an Installation_ in the Appendix).
+ Give the users who need the privileged functions their FACILITY profiles
  (@ug-install-facility).
+ Set up TSO (@ug-install-tso) and, if you want #cmd("EXEC") to run REXX,
  apply the usermod ZMG0001 (@ug-install-zmg). On MVS/CE, PTF UY16532 is
  applied but not accepted: ZMG0001 applies anyway, but accept the PTF
  first if you want to be able to remove the usermod again.

#idx("IRXVTOC")
#cmd("IRXVTOC") runs as a TSO command, so it must be in the link list or in
the #cmd("STEPLIB") of the session; the other modules are loaded by the
interpreter.

== Installations by Hand: V2R5M3 and Earlier <ug-install-manual>

#idx("installation", "by hand")
Release 3.0 is installed with SMP. V2R5M3 and the releases before it were
installed by hand, and so were the BREXX/370 of TK5 and MVS/CE; the steps
are described here so that you can recognise what such an installation
consists of (_Upgrading an Installation_ in the Appendix). V2R5M3 uploads one
TSO TRANSMIT file and unpacks it with a series of jobs:

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

== Setting Up TSO <ug-install-tso>

#idx("logon procedure", "allocations")#idx("SYSEXEC")#idx("SYSUEXEC")
For #cmd("RX") and #cmd("REXX") to find execs and the functions of RXLIB,
the TSO session needs some allocations. The example uses the names of
release 3.0, #cmd("BREXX.RXLIB") for the functions and #cmd("BREXX.CMDLIB")
for the TSO commands. The first comes with the SMP function; the second is
the name you give when you receive the CMDLIB transmit file, so use
whatever name you chose. Make the allocations in the logon CLIST --
#cmd("SYS1.CMDPROC(USRLOGON)") on TK4- and TK5,
#cmd("SYS1.CMDPROC(TSOLOGON)") on MVS/CE -- before the line
#cmd("%STDLOGON"). Back up the CLIST first: an error in it can keep every
user from logging on.

```
/* ALLOCATE RXLIB IF PRESENT */
IF &SYSDSN('BREXX.RXLIB') EQ &STR(OK) THEN DO
  FREE FILE(RXLIB)
  ALLOC FILE(RXLIB) DSN('BREXX.RXLIB') SHR
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
#cmd("BREXX.CMDLIB") to the #cmd("SYSPROC")
concatenation of the same CLIST. Most of them run an exec of the samples
library, which must then be in #cmd("SYSEXEC") or #cmd("SYSUEXEC") as well.

After an upgrade from V2R5M3, change the data set name of the RXLIB
allocation to #cmd("BREXX.RXLIB"). @ug-calling describes in which order the libraries are
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

Release 3.0 does not need this. Its SMP package neither authorizes the
library nor changes TSO's table of authorized commands. The load module is
linked with authorization code 1 and runs unauthorized from a library that
is not APF-authorized; an exec that calls a program needing authorization
then fails as that program does when it is called from any unauthorized
program. If you need an authorized BREXX/370, authorize the library and make
the changes above yourself.

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

The release page of BREXX/370 3.0 and of every later release carries the
usermod as #cmd("ZMG0001.smp") and the jobs as #cmd("ZMG0001-jobs.zip"):

#tab(caption: [The ZMG0001 jobs])[
  #table(columns: (1in, 1fr),
    [Job], [Purpose],
    [#cmd("ZMG01CK")], [Lists PTF UY16532 and the usermods ZMG0001 to
      ZMG0003.],
    [#cmd("ZMG01BK")], [Backs up #cmd("EXEC") and #cmd("EX").],
    [#cmd("ZMG01RC")], [Receives the usermod and checks the apply.],
    [#cmd("ZMG01AP")], [Applies the usermod.],
    [#cmd("ZMG01RS")], [Removes the usermod and copies the backup back.],
  )
]

Change the job card before you submit a job, and the data set names that
start with #cmd("YOUR."). Two jobs have such names:
#cmd("YOUR.ZMG0001.SMP") in #cmd("ZMG01RC") is the data set that holds the
uploaded usermod, and #cmd("YOUR.ZMG0001.BACKUP") in #cmd("ZMG01BK") and
#cmd("ZMG01RS") is the backup library. Use the same name for the backup in
both jobs.

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
- Neither ZMG0002 (the TSO integration of REXX/370) nor ZMG0003 (both side
  by side) installed. The three change the same elements; restore the one
  installed before you apply another.
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
+ Upload #cmd("ZMG0001.smp") in binary to a sequential data set with
  #cmd("RECFM=FB") and #cmd("LRECL=80"). The job #cmd("ZMG01RC") reads it
  from #cmd("YOUR.ZMG0001.SMP"): change that name to the one you chose.
+ Receive the usermod and check the apply (job #cmd("ZMG01RC")), with the
  SMPAPP procedure:
  ```
  //SMP      EXEC SMPAPP
  //HMASMP.CMDLIB   DD DSN=SYS1.CMDLIB,DISP=SHR
  //HMASMP.AOST4    DD DSN=SYS1.AOST4,DISP=SHR
  //HMASMP.SMPPTFIN DD DSN=YOUR.ZMG0001.SMP,DISP=SHR
  //HMASMP.SMPCNTL  DD *
   RECEIVE SELECT(ZMG0001) .
   APPLY SELECT(ZMG0001) CHECK .
  /*
  ```
  The apply check changes nothing. Its listing must show #cmd("IKJCT430")
  and #cmd("IKJCT437") as #cmd("APPLIED"), not as #cmd("NOT SEL").
+ Apply the usermod (job #cmd("ZMG01AP")). The usermod is received by now,
  so the job has no #cmd("SMPPTFIN") statement, and its only SMP statement is
  #cmd("APPLY SELECT(ZMG0001) ."). The output must show
  #cmd("HMA2390 LINK SUCCESSFUL") for #cmd("IKJCT430") and
  #cmd("IKJCT437").
+ Compare the extents of #cmd("SYS1.CMDLIB") with those you noted. If the
  apply took a new extent, #cmd("EXEC") cannot be loaded
  (#cmd("IEA703I 106-F")) until the next IPL.
+ Do not ACCEPT the usermod.

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
  #cmd("SYS1.AOST4"), and takes ZMG0001 off the SMP data sets, so it can be
  received again.
+ Copy the saved #cmd("EXEC") and #cmd("EX") back into #cmd("SYS1.CMDLIB")
  (the second step of job #cmd("ZMG01RS")). The backup is the level from
  before the apply.
+ Compare the extents of #cmd("SYS1.CMDLIB") with those you noted, as for the
  installation.

If you do not want to accept the PTF, do not run job #cmd("ZMG01RS"): its
first step is the RESTORE. Copy the saved #cmd("EXEC") and #cmd("EX") back
with IEBCOPY instead. ZMG0001 then stays in the SMP inventory.

== Authorizing Users: the FACILITY Profiles <ug-install-facility>

#idx("FACILITY", "profiles")#idx("RAKF", "profiles")#idx("SVC244")#idx("DIAG8CMD")
BREXX/370 runs unauthorized. A few functions need more than that -- they
issue a restricted SVC, or send a command to Hercules -- and BREXX/370
takes the authorization for the call only if RAKF says the user may have
it. RAKF is the security product of TK4-, TK5 and MVS/CE; the decision is
READ access to one of two profiles in the class #cmd("FACILITY"):

#tab(caption: [FACILITY profiles of BREXX/370])[
  #table(columns: (1in, 1fr),
    [Profile], [What it permits],
    [#cmd("SVC244")], [The functions #cmd("PRIVILEGE"), #cmd("CONSOLE"),
      #cmd("MTT") and #cmd("MTTX"), and the environment
      #cmd("ADDRESS CONSOLE"), exist for the user. The authorization that
      #cmd("ADDRESS COMMAND"), #cmd("CONSOLE") and #cmd("ADDRESS CONSOLE")
      take for the call, and the values #cmd("SYSCP"), #cmd("SYSCPLVL") and
      #cmd("SYSNODE") of #cmd("SYSVAR") need it as well; #cmd("SYSVAR")
      gives #cmd("not authorized") without it.],
    [#cmd("DIAG8CMD")], [The environment #cmd("ADDRESS COMMAND") exists
      for the user (@ug-install-cp).],
  )
] <ug-install-facility-tab>

Without the profile the function is not registered: a call of
#cmd("PRIVILEGE") by a user with no access to #cmd("SVC244") ends with
error 43, #cmd("Routine not found"), and not with a message about
authorization. The Reference shows which return code each case gives
(_BREXX/370 Reference_, “Host Command Environments” and the function
#cmd("RACCHECK")).

TK5 defines both profiles and permits them to the groups #cmd("ADMIN") and
#cmd("STCGROUP"), and #cmd("SVC244") to #cmd("FTPD"). They are in
#cmd("SYS1.SECURE.CNTL(PROFILES)"), in this form:

```
FACILITYDIAG8CMD                                            NONE        00008800
FACILITYDIAG8CMD                                    ADMIN   READ        00008900
FACILITYDIAG8CMD                                    STCGROUPREAD        00009000
FACILITYSVC244                                              NONE        00015800
FACILITYSVC244                                      ADMIN   READ        00015900
FACILITYSVC244                                      FTPD    READ        00016013
FACILITYSVC244                                      STCGROUPREAD        00016100
```

The class begins in column 1, the profile in column 9, the user ID or group
in column 53 and the access in column 61. The line with #cmd("NONE") is the
universal access, and must come before the lines that permit an ID.

To give a user the host command, add a line for the ID after the other
lines of the profile, and tell RAKF to read the profiles again from the
operator console:

```
FACILITYDIAG8CMD                                    HERC03  READ
```

```
S RAKFPROF
RAKFPROF7  RAKF PROFILES UPDATED
```

The change is in effect for a job that starts afterwards. An exec that is
running does not see it: #cmd("RACCHECK") keeps its answers for the length
of a run (_BREXX/370 Reference_, #cmd("RACCHECK")).
A system without RAKF needs no profiles; BREXX/370 then allows all.

*Check the result with RACCHECK* for the user concerned:

```
SAY raccheck('FACILITY', 'SVC244',   'READ')
SAY raccheck('FACILITY', 'DIAG8CMD', 'READ')
```

For the regular user HERC03 on TK5, who is in neither group, the two lines
show #cmd("0") and #cmd("0"). After the line above has been added for
HERC03, they show #cmd("0") and #cmd("1").

== Talking to the Host System <ug-install-cp>

#idx("ADDRESS COMMAND", "CP")
An exec can pass a command to the control program under which MVS runs --
Hercules, or VM -- with #cmd("ADDRESS COMMAND 'CP ")#var("command")#cmd("'").
Under Hercules the command is a Hercules command, such as
#cmd("ADDRESS COMMAND 'CP DEVLIST'"), and Hercules must accept commands
from the guest: #cmd("DIAG8CMD ENABLE") on the Hercules console. TK4-, TK5
and MVS/CE enable it.

The user also needs the two profiles of @ug-install-facility. Without
#cmd("DIAG8CMD") the environment does not exist for the user, and the
command ends with return code -3. With it, and without #cmd("SVC244"), the
command ends with return code -5, because BREXX/370 cannot obtain the
authorization the command needs, and nothing is sent. A user with both gets
the answer of Hercules.

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
