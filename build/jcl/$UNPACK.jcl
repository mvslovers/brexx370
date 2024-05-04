//BRXXUNP JOB 'XMIT UNPACK',CLASS=A,MSGCLASS=H,NOTIFY=&SYSUID
//*
//*RELEASE   SET '{version}'
//* ... BREXX          Version {version} Build Date {date}
//* ... INSTALLER DATE {date}
//* ------------------------------------------------------------------
//* UNPACK XMIT FILES INTO INSTALL LIBRARIES
//*   *** CHANGE XMITLIB= TO THE EXPANDED XMIT LIBRARY OF INSTALLATION
//* ------------------------------------------------------------------
//*           ---->   CHANGE XMITLIB TO YOUR UNPACKED XMIT FILE  <----
//*                          XXXXXXXXXXX
//*                         X     X     X
//*                        X      X      X
//*                       X       X       X
//*                      X        X        X
//XMITLOAD PROC XMITLIB='BREXX.{HLQ}.INSTALL',
//         HLQ='BREXX.{HLQ}',     <-- DO NOT CHANGE HLQ ----
//         MEMBER=
//* 1. DELETE OLD VERSION OF TARGET FILE
//STEP10   EXEC PGM=IKJEFT01,
//         PARM='EXEC ''&XMITLIB(RXINSTDL)'' ''&HLQ..&MEMBER'''
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD DUMMY
//* 2. RECEIVE XMIT FILE AND CREATE TARGET FILE
//STEP20   EXEC PGM=RECV370,REGION=4096K
//RECVLOG  DD SYSOUT=*
//XMITIN   DD DSN=&XMITLIB(&MEMBER),DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD DSN=&&SYSUT1,
//         UNIT=3390,
//         SPACE=(TRK,(250,250)),
//         DISP=(NEW,DELETE,DELETE)
//SYSUT2   DD DSN=&HLQ..&MEMBER,
//         UNIT=3390,
//         SPACE=(TRK,(250,250,25),RLSE),
//         DISP=(NEW,CATLG,DELETE)
//SYSIN    DD DUMMY
// PEND
//* ------------------------------------------------------------------
//* UNPACK XMIT FILES INTO INSTALL LIBRARIES
//*        SAVE XMIT IN BREXX.$RELEASE.XMIT(AS-MEMBER)
//* ------------------------------------------------------------------
//UNPK10   EXEC XMITLOAD,MEMBER=LINKLIB
//UNPK20   EXEC XMITLOAD,MEMBER=PROCLIB
//UNPK30   EXEC XMITLOAD,MEMBER=JCL
//UNPK40   EXEC XMITLOAD,MEMBER=SAMPLES
//UNPK50   EXEC XMITLOAD,MEMBER=RXLIB
//UNPK50   EXEC XMITLOAD,MEMBER=CMDLIB
//UNPK60   EXEC XMITLOAD,MEMBER=APFLLIB
//
