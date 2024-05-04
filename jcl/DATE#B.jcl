//DATETEST JOB (BREXX370),CLASS=A,MSGCLASS=H,
//         REGION=8192K,NOTIFY=&SYSUID
//*
//*
//*RELEASE   SET '{version}'
//* ... BREXX          Version {version} Build Date {date}
//* ... INSTALLER DATE {date}
//* ------------------------------------------------------------------*
//* TEST REXX DATE IN PLAIN BATCH
//* ------------------------------------------------------------------*
//REXX EXEC RXBATCH,BREXX='BREXX',
//     EXEC='DATE#T',
//     SLIB='BREXX.CURRENT.SAMPLES'
