//CREKEYV  JOB (IDCAMS),'KEYVALUE DB',CLASS=A,MSGCLASS=H,
//         MSGLEVEL=(1,1),REGION=8192K
//* ################################################################
//* !!!!  WARNING: THIS JOB DELETES DATA                         !!!!
//* !!!!                                                         !!!!
//* !!!!  IT DELETES THE CLUSTERS BREXX.KEYVALUE AND             !!!!
//* !!!!  BREXX.KEYREFS AND DEFINES THEM AGAIN, EMPTY.           !!!!
//* !!!!  DO NOT RUN IT IF YOU ALREADY HAVE A KEY/VALUE          !!!!
//* !!!!  DATABASE IN USE: EVERY RECORD IN IT IS LOST.           !!!!
//* ################################################################
//*
//* $$CREKEY - CREATE THE KEY/VALUE DATABASE OF THE KEYVALUE
//*            FUNCTIONS (DBOPEN, DBSET, DBGET, DBNEXT, ...).
//*
//* THE FUNCTIONS DO NOT CREATE THEIR CLUSTERS: DBOPEN NEEDS BOTH
//* TO EXIST, AND EACH HOLDS A CONTROL RECORD OF 255 NINES THAT
//* DBNEXT LOOKS FOR AS THE END MARK. THIS JOB WRITES THAT RECORD
//* AND DEFINES AND PRIMES THE TWO CLUSTERS:
//*
//*   BREXX.KEYVALUE   THE SOURCE RECORDS    KEYS(44 0)
//*   BREXX.KEYREFS    THE LINKS BETWEEN THEM  KEYS(105 0)
//*
//* BEFORE YOU SUBMIT THE JOB:
//*   1. CHECK THE JOB CARD (ACCOUNT, CLASS, MSGCLASS).
//*   2. REPLACE THE TWO VOLUMES(......) BELOW BY A VOLUME SERIAL
//*      OF YOUR SYSTEM. IF YOU DO NOT, THE DEFINE FAILS (RETURN
//*      CODE 12), BUT THE DELETE IN FRONT OF IT HAS ALREADY RUN.
//*   3. THE BREXX STEP FINDS THE PROGRAM BREXX IN THE LINK LIST
//*      (LNKLST). IF BREXX.LINKLIB IS NOT IN IT, REMOVE THE
//*      ASTERISK FROM THE STEPLIB LINE OF THE FIRST STEP.
//*   4. IF THE CLUSTERS DO NOT EXIST YET, THE DELETE ENDS WITH
//*      RETURN CODE 8 (ENTRY NOT FOUND). THAT IS EXPECTED: THE
//*      SET MAXCC = 0 AFTER IT CLEARS IT.
//*
//* THE SPACE IS A STARTING SIZE, NOT A LIMIT: 10 CYLINDERS PRIMARY
//* AND 10 SECONDARY FOR THE SOURCE RECORDS (A VALUE CAN BE UP TO
//* 8147 BYTES), 5 AND 5 FOR THE LINKS. A VSAM CLUSTER TAKES THE
//* SECONDARY AMOUNT WHEN IT FILLS UP. A SMALL DATABASE NEVER NEEDS
//* MORE; RAISE THE FIGURES FOR A LARGE ONE BEFORE YOU LOAD IT.
//*
//* A DATABASE WITH OTHER NAMES OR KEY LENGTHS NEEDS A PROFILE OF
//* ITS OWN (SEE DBPROF) AND CLUSTERS DEFINED FROM A COPY OF THIS
//* JOB WITH THE KEY LENGTHS OF THAT PROFILE.
//*
//* ----------------------------------------------------------------
//* STEP 1: WRITE THE CONTROL RECORD (255 NINES) TO A TEMPORARY FILE
//* ----------------------------------------------------------------
//EXEC     EXEC PGM=BREXX,PARM='RXRUN',REGION=6000K
//*STEPLIB DD   DSN=BREXX.LINKLIB,DISP=SHR
//STDIN    DD   DUMMY
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)
//NULLREC  DD   DSN=&&NULLREC,DISP=(,PASS),UNIT=VIO,SPACE=(TRK,(1,1)),
//         DCB=(RECFM=FB,LRECL=255,BLKSIZE=255)
//RXRUN    DD   *
   NULLR.1=COPIES('9',255); NULLR.0=1
  "EXECIO * DISKW NULLREC (STEM NULLR. FINIS"
/*
//* ----------------------------------------------------------------
//* STEP 2: DELETE, DEFINE AND PRIME BREXX.KEYVALUE
//*
//* !!!!  THE DELETE DESTROYS THE SOURCE RECORDS OF AN EXISTING   !!!!
//* !!!!  DATABASE. THERE IS NO WAY BACK.                         !!!!
//* ----------------------------------------------------------------
//KEYVALUE EXEC PGM=IDCAMS
//NULLREC  DD   DSN=&&NULLREC,DISP=(OLD,PASS)
//SYSPRINT DD   SYSOUT=*
//SYSIN    DD   *
  /* DATA LOSS: DELETES AN EXISTING BREXX.KEYVALUE WITH ALL ITS DATA */
  DELETE BREXX.KEYVALUE CLUSTER
  SET MAXCC = 0
  DEFINE CLUSTER                           -
           (NAME(BREXX.KEYVALUE)           -
            INDEXED                        -
            KEYS(44 0)                     -
            RECORDSIZE(64 8192)            -
            SHAREOPTIONS(2,3)              -
            CYLINDERS(10 10)               -
            VOLUMES(......)                -
            UNIQUE                         -
            SPEED)                         -
         DATA                              -
            (NAME(BREXX.KEYVALUE.DATA))    -
         INDEX                             -
            (NAME(BREXX.KEYVALUE.INDEX))
  IF LASTCC = 0 THEN -
     REPRO INFILE(NULLREC) ODS(BREXX.KEYVALUE)
/*
//* ----------------------------------------------------------------
//* STEP 3: DELETE, DEFINE AND PRIME BREXX.KEYREFS
//*
//* !!!!  THE DELETE DESTROYS THE LINKS OF AN EXISTING DATABASE.  !!!!
//* !!!!  THERE IS NO WAY BACK.                                   !!!!
//* ----------------------------------------------------------------
//KEYREF   EXEC PGM=IDCAMS
//NULLREC  DD   DSN=&&NULLREC,DISP=(OLD,DELETE)
//SYSPRINT DD   SYSOUT=*
//SYSIN    DD   *
  /* DATA LOSS: DELETES AN EXISTING BREXX.KEYREFS WITH ALL ITS DATA */
  DELETE BREXX.KEYREFS CLUSTER
  SET MAXCC = 0
  DEFINE CLUSTER                           -
           (NAME(BREXX.KEYREFS)            -
            INDEXED                        -
            KEYS(105 0)                    -
            RECORDSIZE(128 512)            -
            SHAREOPTIONS(2,3)              -
            CYLINDERS(5 5)                 -
            VOLUMES(......)                -
            UNIQUE                         -
            SPEED)                         -
         DATA                              -
            (NAME(BREXX.KEYREFS.DATA))     -
         INDEX                             -
            (NAME(BREXX.KEYREFS.INDEX))
  IF LASTCC = 0 THEN -
     REPRO INFILE(NULLREC) ODS(BREXX.KEYREFS)
/*
