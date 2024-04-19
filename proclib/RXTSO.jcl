//*
//*RELEASE   SET 'V2R5M3'
//* ... BREXX          Version V2R5M3 Build Date 01. Feb 2024
//* ... INSTALLER DATE 03/02/2024 17:40:25
//* ------------------------------------------------------------------*
//* REXX BATCH TSO                                                    *
//* ------------------------------------------------------------------*
//RXTSO    PROC EXEC='',P='',
//         BREXX='BREXX',
//         LIB='BREXX.V2R5M3.RXLIB',
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
