//BRXVSMCL JOB CLASS=A,MSGCLASS=H,REGION=8192K,                         00000105
//         NOTIFY=&SYSUID                                               00000200
//* -----------------------------------------------------------------   00000301
//* CREATE AND LOAD VSAM FILE                                           00000401
//* -----------------------------------------------------------------   00000501
//* -----------------------------------------------------------------   00000600
//* STEP 1 CREATE NEW CLUSTER DEFINITION                                00000700
//* -----------------------------------------------------------------   00000800
// EXEC PGM=IDCAMS,REGION=512K                                          00000900
//SYSPRINT DD  SYSOUT=*                                                 00001000
//FIRSTREC DD  *                                                        00001100
0000000000NULL RECORD                                                   00001200
/*                                                                      00001300
//SYSIN    DD  *                                                        00001400
  DELETE 'BREXX.VSAM.STUDENTM'                                          00001506
                                                                        00001602
  DEFINE CLUSTER                             -                          00001700
      ( NAME('BREXX.VSAM.STUDENTM') INDEXED  -                          00001806
           RECSZ(100 200) KEYS(28 0)         -                          00001902
           TRACKS(15 30)                     -                          00002001
           VOLUMES(PUB013)                   -                          00002106
           SHAREOPTIONS(2 3) UNIQUE          -                          00002200
      )                                      -                          00002300
      DATA (NAME('BREXX.VSAM.STUDENTM.DATA') ) -                        00002406
      INDEX (NAME('BREXX.VSAM.STUDENTM.INDEX') )                        00002506
  REPRO INFILE(FIRSTREC) ODS('BREXX.VSAM.STUDENTM')                     00002606
/*                                                                      00002701
//                                                                      00002801
