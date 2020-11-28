//BREXXTST JOB CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1),
//         USER=HERC01,PASSWORD=CUL8TR
//* ------------------------------------------------------------------
//* BREXX V2R4DEV INSTALL
//* ------------------------------------------------------------------
//*
//* ------------------------------------------------------------------
//* DELETE DATASETS IF ALREADY INSTALLED
//* ------------------------------------------------------------------
//*
//BRDELETE EXEC PGM=IDCAMS,REGION=1024K
//SYSPRINT DD  SYSOUT=A
//SYSIN    DD  *
    DELETE BREXX.V2R4DEV.TESTS NONVSAM SCRATCH PURGE
 /* IF THERE WAS NO DATASET TO DELETE, RESET CC           */
 IF LASTCC = 8 THEN
   DO
       SET LASTCC = 0
       SET MAXCC = 0
   END
/*
//*
//* ------------------------------------------------------------------
//* CREATE RTEST IN REXXLIB
//* ------------------------------------------------------------------
//*
//RTESTLIB EXEC PGM=IEBUPDTE,REGION=1024K,PARM=NEW
//SYSUT2   DD  DSN=BREXX.V2R4DEV.RXLIB,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DATA,DLM='##'
./ ADD NAME=RTEST,LIST=ALL
::a rxtest.rxlib
##
/*
//*
//* ------------------------------------------------------------------
//* CREATE THE PDS
//* ------------------------------------------------------------------
//*
//BRCREATE EXEC PGM=IEFBR14
//DDJCL    DD  DSN=BREXX.V2R4DEV.TESTS,DISP=(,CATLG,DELETE),
//             UNIT=3380,VOL=SER=PUB012,SPACE=(TRK,(255,,10)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)
//*
//* ------------------------------------------------------------------
//* ADD TESTS RELEASE V2R4DEV CONTENTS
//* ------------------------------------------------------------------
//*
//* This is written in **rdrprep** syntax
//* It will only work with rdrprep
//* ::a path/file means 'include ascii version of file'
//*
//BRTESTS EXEC PGM=IEBUPDTE,REGION=1024K,PARM=NEW
//SYSUT2   DD  DSN=BREXX.V2R4DEV.TESTS,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DATA,DLM='##'
./ ADD NAME=LINEOUT,LIST=ALL
::a lineout.rexx
##
//*
//* ------------------------------------------------------------------
//* TESTING BREXX VERSION V2R4DEV
//* ------------------------------------------------------------------
//*
//LINEOUT  EXEC RXBATCH,SLIB='BREXX.V2R4DEV.TESTS',EXEC=LINEOUT
//* ------------------------------------------------------------------
//* DELETE BREXX.V2R4DEV.RXLIB(RTEST)
//* ------------------------------------------------------------------
//BRXDEL1  EXEC PGM=IKJEFT01,REGION=8192K
//SYSTSPRT DD   SYSOUT=*
//SYSTSIN  DD   *
  DELETE 'BREXX.V2R4DEV.RXLIB(RTEST)'
  COMPRESS 'BREXX.V2R4DEV.RXLIB'
/*
