//BRXXINST JOB 'INSTALL LIBS',CLASS=A,MSGCLASS=H,NOTIFY=&SYSUID
//*
//*RELEASE   SET '{version}'
//* ... BREXX          Version {version} Build Date {date}
//* ... INSTALLER DATE {date}
//* ------------------------------------------------------------------
//* COPY BREXX MODULE(S) INTO SYS2.LINKLIB
//* ------------------------------------------------------------------
//STEP10  EXEC  PGM=IEBCOPY
//SYSPRINT  DD  SYSOUT=*
//DDIN      DD  DSN=BREXX.{HLQ}.LINKLIB,DISP=SHR
//DDOUT     DD  DSN=SYS2.LINKLIB,DISP=SHR
//SYSIN     DD  *
  COPY INDD=((DDIN,R)),OUTDD=DDOUT
/*
//* ------------------------------------------------------------------
//* COPY BREXX MODULE(S) INTO SYS2.PROCLIB
//* ------------------------------------------------------------------
//STEP20  EXEC  PGM=IEBCOPY
//SYSPRINT  DD  SYSOUT=*
//DDIN      DD  DSN=BREXX.{HLQ}.PROCLIB,DISP=SHR
//DDOUT     DD  DSN=SYS2.PROCLIB,DISP=SHR
//SYSIN     DD  *
  COPY INDD=((DDIN,R)),OUTDD=DDOUT
/*
//
