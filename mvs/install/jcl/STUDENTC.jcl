//BRXVSMCL JOB CLASS=A,MSGCLASS=H,REGION=8192K,
//         NOTIFY=&SYSUID
//* -----------------------------------------------------------------
//* CREATE AND LOAD VSAM FILE
//* -----------------------------------------------------------------
//* -----------------------------------------------------------------
//* STEP 1 CREATE NEW CLUSTER DEFINITION
//* -----------------------------------------------------------------
// EXEC PGM=IDCAMS,REGION=512K
//SYSPRINT DD  SYSOUT=*
//FIRSTREC DD  *
0000000000NULL RECORD
/*
//SYSIN    DD  *
  DELETE 'BREXX.VSAM.STUDENTM'
 
  DEFINE CLUSTER                             -
      ( NAME('BREXX.VSAM.STUDENTM') INDEXED  -
           RECSZ(100 200) KEYS(28 0)         -
           TRACKS(15 30)                     -
           VOLUMES(PUB013)                   -
           SHAREOPTIONS(2 3) UNIQUE          -
      )                                      -
      DATA (NAME('BREXX.VSAM.STUDENTM.DATA') ) -
      INDEX (NAME('BREXX.VSAM.STUDENTM.INDEX') )
  REPRO INFILE(FIRSTREC) ODS('BREXX.VSAM.STUDENTM')
/*
//
