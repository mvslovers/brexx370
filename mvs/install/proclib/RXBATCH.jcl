//*
//*RELEASE   SET 'V2R2M0'
//* ... BREXX          Version V2R2M0 Build Date 23. Oct 2019
//* ... INSTALLER DATE 27 Oct 2019 09:15:37
//* ------------------------------------------------------------------*
//* REXX BATCH                                                        *
//* ------------------------------------------------------------------*
//REXX     PROC EXEC='',P='',
//         BREXX='BREXX',
//         LIB='BREXX.V2R2M0.RXLIB',
//         SLIB=
//EXEC     EXEC PGM=&BREXX,PARM='RXRUN &P',REGION=8192K
//RXRUN    DD   DSN=&SLIB(&EXEC),DISP=SHR
//RXLIB    DD   DSN=&LIB,DISP=SHR
//STDIN    DD   DUMMY
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//* PEND
