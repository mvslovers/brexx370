//*
//*RELEASE   SET 'V2R5M3'
//* ... BREXX          Version V2R5M3 Build Date 01. Feb 2024
//* ... INSTALLER DATE 03/02/2024 17:40:25
//* ------------------------------------------------------------------*
//* REXX BATCH                                                        *
//* ------------------------------------------------------------------*
//REXX     PROC EXEC='',P='',
//         BREXX='BREXX',
//         LIB='BREXX.CURRENT.RXLIB',
//         SLIB=
//EXEC     EXEC PGM=&BREXX,PARM='RXRUN &P',REGION=8192K
//RXRUN    DD   DSN=&SLIB(&EXEC),DISP=SHR
//RXLIB    DD   DSN=&LIB,DISP=SHR
//STDIN    DD   DUMMY
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//* PEND
