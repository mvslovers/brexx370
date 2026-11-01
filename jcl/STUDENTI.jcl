//BRXVSMIN JOB (BREXX370),'BREXX/370',CLASS=A,MSGCLASS=H,REGION=8192K,
//         NOTIFY=&SYSUID
//*
//* -----------------------------------------------------------------
//* STEP 1 INSERT RECORDS INTO VSAM FILE
//* -----------------------------------------------------------------
//*
//BATCH EXEC RXTSO,BREXX='BREXX',
//         EXEC='@STUDENI',
//         SLIB='BREXX.SAMPLIB'
//SYSPRINT DD  SYSOUT=*,
//             DCB=(RECFM=FBA,LRECL=133,BLKSIZE=133)
//SYSUDUMP DD  SYSOUT=*
//
