//* ------------------------------------------------------------------*
//* REXX BATCH                                                        *
//*   EXEC=   member to run          SLIB=   library of the member    *
//*   P=      argument string        LIB=    RXLIB                    *
//*   LINKLIB= load library of BREXX (STEPLIB)                        *
//* ------------------------------------------------------------------*
//RXBATCH  PROC EXEC='',P='',
//         BREXX='BREXX',
//         LINKLIB='BREXX.LINKLIB',
//         LIB='BREXX.RXLIB',
//         SLIB=
//EXEC     EXEC PGM=&BREXX,PARM='RXRUN &P',REGION=8192K
//STEPLIB  DD   DSN=&LINKLIB,DISP=SHR
//RXRUN    DD   DSN=&SLIB(&EXEC),DISP=SHR
//RXLIB    DD   DSN=&LIB,DISP=SHR
//STDIN    DD   DUMMY
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//* PEND
