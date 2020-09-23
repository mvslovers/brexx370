//BRXXINST JOB 'INSTALL LIBS',CLASS=A,MSGCLASS=H
//*
//*RELEASE   SET 'V2R2M0'
//* ... BREXX          Version V2R2M0 Build Date 23. Oct 2019
//* ... INSTALLER DATE 27 Oct 2019 09:15:35
//* ------------------------------------------------------------------
//* COPY BREXX MODULE(S) INTO SYS2.LINKLIB
//* ------------------------------------------------------------------
//STEP10  EXEC  PGM=IEBCOPY
//SYSPRINT  DD  SYSOUT=*
//DDIN      DD  DSN=BREXX.V2R2M0.LINKLIB,DISP=SHR
//DDOUT     DD  DSN=SYS2.LINKLIB,DISP=SHR
//SYSIN     DD  *
  COPY INDD=((DDIN,R)),OUTDD=DDOUT
/*
//* ------------------------------------------------------------------
//* COPY BREXX MODULE(S) INTO SYS2.PROCLIB
//* ------------------------------------------------------------------
//STEP20  EXEC  PGM=IEBCOPY
//SYSPRINT  DD  SYSOUT=*
//DDIN      DD  DSN=BREXX.V2R2M0.PROCLIB,DISP=SHR
//DDOUT     DD  DSN=SYS2.PROCLIB,DISP=SHR
//SYSIN     DD  *
  COPY INDD=((DDIN,R)),OUTDD=DDOUT
/*
//* ------------------------------------------------------------------
//* REMOVE BREXX CLIST MEMBERS FROM SYS2.CMDPROC
//* ------------------------------------------------------------------
//STEP30   EXEC PGM=IKJEFT01,DYNAMNBR=64,REGION=4096K
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
 /* -----------------------------------------------  */
 /* REMOVE CLIST MEMBERS, THEY ARE NO LONGER NEEDED  */
 /*   IF ALLOC/DELETE FAIL THE CLISTS HAVE ALREADY   */
 /*   BEEN REMOVED EARLIER. THIS IS NOT AN ERROR!    */
 /* -----------------------------------------------  */
  ALLOC DSN('SYS2.CMDPROC(RX)')       SHR  FILE(RXMEM1)
    DELETE 'SYS2.CMDPROC(RX)'              FILE(RXMEM1)
  ALLOC DSN('SYS2.CMDPROC(REXX)')     SHR  FILE(RXMEM2)
    DELETE 'SYS2.CMDPROC(REXX)'            FILE(RXMEM2)
  ALLOC DSN('SYS2.CMDPROC(REXXINIT)') SHR  FILE(RXMEM3)
    DELETE 'SYS2.CMDPROC(REXXINIT)'        FILE(RXMEM3)
 /* -----------------------------------------------  */
 /* COMPRESS UPDATE LIBRARIES                        */
 /* -----------------------------------------------  */
  COMPRESS 'SYS2.LINKLIB'
  COMPRESS 'SYS2.PROCLIB'
 /* -----------------------------------------------  */
 /* CHECK EXISTENCE OF NEW BREXX LOAD MEMBER AND     */
 /* SET APPROPRIATE RC                               */
 /* -----------------------------------------------  */
  ALLOC DSN('SYS2.LINKLIB(BREXXSTD)') SHR  FILE(BREXX)
/*
//
