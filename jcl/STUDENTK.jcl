//BRXVSMKY JOB CLASS=A,MSGCLASS=H,REGION=8192K,
//         NOTIFY=&SYSUID
//*
//* -----------------------------------------------------------------
//* READ STUDENT VSAM FILE VIA KEY
//* -----------------------------------------------------------------
//*
//BATCH EXEC RXTSO,BREXX='BREXX',
//         EXEC='@STUDENK',
//         SLIB='BREXX.SAMPLIB'
//SYSPRINT DD  SYSOUT=*,
//             DCB=(RECFM=FBA,LRECL=133,BLKSIZE=133)
//SYSUDUMP DD  SYSOUT=*
//
