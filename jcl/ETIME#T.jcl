//TIMETEST JOB (BREXX370),CLASS=A,MSGCLASS=H,
//         REGION=8192K,NOTIFY=&SYSUID
//*
//*RELEASE   SET '{version}'
//* ... BREXX          Version {version} Build Date {date}
//* ... INSTALLER DATE {date}
//* ------------------------------------------------------------------*
//* TEST REXX DATE AS TSO BATCH
//* ------------------------------------------------------------------*
//REXX EXEC RXTSO,EXEC='$ETIME',SLIB='BREXX.CURRENT.SAMPLES'
