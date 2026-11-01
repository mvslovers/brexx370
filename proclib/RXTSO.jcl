//* ------------------------------------------------------------------*
//* REXX BATCH TSO                                                    *
//*   EXEC=   member to run          SLIB=   library of the member    *
//*   P=      argument string        LIB=    RXLIB                    *
//*   LINKLIB= load library of BREXX (STEPLIB)                        *
//* ------------------------------------------------------------------*
//RXTSO    PROC EXEC='',P='',
//         BREXX='BREXX',
//         LINKLIB='BREXX.LINKLIB',
//         LIB='BREXX.RXLIB',
//         SLIB=
//EXEC     EXEC PGM=IKJEFT01,PARM='&BREXX EXEC &P',REGION=8192K
//STEPLIB  DD   DSN=&LINKLIB,DISP=SHR
//EXEC     DD   DSN=&SLIB(&EXEC),DISP=SHR
//RXLIB    DD   DSN=&LIB,DISP=SHR
//SYSPRINT DD   SYSOUT=*
//SYSTSPRT DD   SYSOUT=*
//SYSTSIN  DD   DUMMY
//*    PEND
