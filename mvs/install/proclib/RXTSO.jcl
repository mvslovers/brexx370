//*
//*RELEASE   SET 'V2R2M0'
//* ... BREXX          Version V2R2M0 Build Date 23. Oct 2019
//* ... INSTALLER DATE 27 Oct 2019 09:15:37
//* ------------------------------------------------------------------*
//* REXX BATCH TSO                                                    *
//* ------------------------------------------------------------------*
//RXTSO    PROC EXEC='',P='',
//         BREXX='BREXX',
//         LIB='BREXX.V2R2M0.RXLIB',
//         SLIB=
//EXEC     EXEC PGM=IKJEFT01,PARM='&BREXX EXEC &P',REGION=8192K
//EXEC     DD   DSN=&SLIB(&EXEC),DISP=SHR
//TSOLIB   DD   DSN=&LIB,DISP=SHR
//RXLIB    DD   DSN=&LIB,DISP=SHR
//SYSPRINT DD   SYSOUT=*
//SYSTSPRT DD   SYSOUT=*
//SYSTSIN  DD   DUMMY
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDIN    DD   DUMMY
//*    PEND
