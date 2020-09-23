//BRXXCLEN JOB 'BREXX CLEANUP',CLASS=A,MSGCLASS=H,MSGLEVEL=(0,0)
//*
//*RELEASE   SET 'V2R2M0'
//* ... BREXX          Version V2R2M0 Build Date 23. Oct 2019
//* ... INSTALLER DATE 27 Oct 2019 09:15:34
//* ----------------------------------------------------------------
//* REMOVE INSTALLATION FILES, WHICH ARE COPIES TO SYS2. LIBRARIES
//* ----------------------------------------------------------------
//TSOBTCH  EXEC PGM=IKJEFT01,REGION=8192K
//SYSTSPRT DD   SYSOUT=*
//SYSTSIN  DD   *
  DELETE BREXX.V2R2M0.LINKLIB
  DELETE BREXX.V2R2M0.PROCLIB
//
