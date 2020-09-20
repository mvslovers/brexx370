//BRXVSMNX JOB CLASS=A,MSGCLASS=H,REGION=8192K,
//         NOTIFY=&SYSUID
//*
//*RELEASE   SET 'V2R2M0'
//* ... BREXX          Version V2R2M0 Build Date 23. Oct 2019
//* ... INSTALLER DATE 27 Oct 2019 09:15:41
//* -----------------------------------------------------------------
//* READ STUDENT VSAM FILE VIA LOCATE/NEXT
//* -----------------------------------------------------------------
//*
//BATCH EXEC RXTSO,BREXX='BREXXSTD',
//         EXEC='@STUDENN',
//         SLIB='BREXX.V2R2M0.SAMPLES'
//SYSPRINT DD  SYSOUT=*,
//             DCB=(RECFM=FBA,LRECL=133,BLKSIZE=133)
//SYSUDUMP DD  SYSOUT=*
//
