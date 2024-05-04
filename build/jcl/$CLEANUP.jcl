//BRXXCLEN JOB 'BREXX CLEANUP',CLASS=A,
//         MSGCLASS=H,MSGLEVEL=(0,0),NOTIFY=&SYSUID
//*
//*RELEASE   SET '{version}'
//* ... BREXX          Version {version} Build Date {date}
//* ... INSTALLER DATE {date}
//* ----------------------------------------------------------------
//* REMOVE INSTALLATION FILES, WHICH ARE COPIES TO SYS2. LIBRARIES
//* ----------------------------------------------------------------
//TSOBTCH  EXEC PGM=IKJEFT01,REGION=8192K
//SYSTSPRT DD   SYSOUT=*
//SYSTSIN  DD   *
  DELETE BREXX.{HLQ}.LINKLIB
  DELETE BREXX.{HLQ}.APF.LINKLIB
  DELETE BREXX.{HLQ}.PROCLIB
//
