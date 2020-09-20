//BRXVSMIN JOB CLASS=A,MSGCLASS=H,REGION=8192K,
//         NOTIFY=&SYSUID
//*
//*RELEASE   SET 'V2R2M0'
//* ... BREXX          Version V2R2M0 Build Date 23. Oct 2019
//* ... INSTALLER DATE 27 Oct 2019 09:15:40
//* -----------------------------------------------------------------
//* STEP 1 INSERT RECORDS INTO VSAM FILE
//* -----------------------------------------------------------------
//*
//BATCH EXEC RXTSO,BREXX='BREXXSTD',
//         EXEC='@STUDENI',
//         SLIB='BREXX.V2R2M0.SAMPLES'
//SYSPRINT DD  SYSOUT=*,
//             DCB=(RECFM=FBA,LRECL=133,BLKSIZE=133)
//SYSUDUMP DD  SYSOUT=*
//
