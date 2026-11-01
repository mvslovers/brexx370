//BRXVSMNX JOB (BREXX370),'BREXX/370',CLASS=A,MSGCLASS=H,REGION=8192K,
//         NOTIFY=&SYSUID
//*
//* -----------------------------------------------------------------
//* READ STUDENT VSAM FILE VIA LOCATE/NEXT
//* -----------------------------------------------------------------
//*
//BATCH EXEC RXTSO,BREXX='BREXX',
//         EXEC='@STUDENN',
//         SLIB='BREXX.SAMPLIB'
//SYSPRINT DD  SYSOUT=*,
//             DCB=(RECFM=FBA,LRECL=133,BLKSIZE=133)
//SYSUDUMP DD  SYSOUT=*
//
