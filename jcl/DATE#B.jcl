//DATETEST JOB (BREXX370),'BREXX/370',CLASS=A,MSGCLASS=H,
//         REGION=8192K,NOTIFY=&SYSUID
//*
//*
//* ------------------------------------------------------------------*
//* TEST REXX DATE IN PLAIN BATCH
//* ------------------------------------------------------------------*
//REXX EXEC RXBATCH,BREXX='BREXX',
//     EXEC='DATE#T',
//     SLIB='BREXX.SAMPLIB'
