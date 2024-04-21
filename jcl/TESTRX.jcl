//BRXXTEST JOB 'BREXX VERIFICATION',CLASS=A,                            00000108
//         MSGCLASS=H,MSGLEVEL=(1,1),NOTIFY=&SYSUID                     00000222
//*       INCLUDE 'BREXX.$INSTALL.MASTER.CNTL($RELEASE)'                00000306
//* ----------------------------------------------------------------    00000400
//* REXX BATCH PROCEDURE                                                00000500
//* ----------------------------------------------------------------    00000600
//TSTRX    PROC EXEC='',P=''                                            00000707
//EXEC     EXEC PGM=BREXX,PARM='EXEC &P',REGION=8192K                   00000810
//EXEC     DD   DSN=BREXX.&RELEASE.SAMPLES(&EXEC),DISP=SHR              00000905
//RXLIB    DD   DSN=BREXX.&RELEASE.RXLIB,DISP=SHR                       00001013
//STDIN    DD   DUMMY                                                   00001100
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)          00001200
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)          00001300
// PEND                                                                 00001400
//RXTSO    PROC EXEC='',P='',                                           00001520
//         BREXX='BREXX',                                               00001620
//         LIB='BREXX.&RELEASE.RXLIB',                                  00001725
//         SLIB='BREXX.&RELEASE.SAMPLES'                                00001825
//EXEC     EXEC PGM=IKJEFT01,PARM='&BREXX EXEC &P',REGION=8192K         00001920
//EXEC     DD   DSN=&SLIB(&EXEC),DISP=SHR                               00002020
//TSOLIB   DD   DSN=&LIB,DISP=SHR                                       00002120
//RXLIB    DD   DSN=&LIB,DISP=SHR                                       00002220
//SYSPRINT DD   SYSOUT=*                                                00002320
//SYSTSPRT DD   SYSOUT=*                                                00002420
//SYSTSIN  DD   DUMMY                                                   00002520
//STDOUT   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)          00002620
//STDERR   DD   SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)          00002720
//STDIN    DD   DUMMY                                                   00002820
// PEND                                                                 00002920
//* ----------------------------------------------------------------    00003000
//* VERIFY REXX INSTALLATION                                            00003100
//* ----------------------------------------------------------------    00003200
//SPLASH   EXEC TSTRX,PARM.EXEC=''                                      00003307
//EXEC     DD   DUMMY                                                   00003400
//BANNER   EXEC TSTRX,EXEC=BANNER,P='BREXX/370'                         00003507
//BANNER   DD   DSN=BREXX.&RELEASE.SAMPLES(BANNER),DISP=SHR             00003605
//BLOCK    EXEC TSTRX,EXEC=BLOCK                                        00003707
//BUZZWORD EXEC TSTRX,EXEC=BUZZWORD                                     00003807
//FACTRIAL EXEC TSTRX,EXEC=FACTRIAL,P='12'                              00003907
//PLOT3D   EXEC TSTRX,EXEC=PLOT3D                                       00004007
//POETRY   EXEC TSTRX,EXEC=POETRY                                       00004107
//*  SEARCH IN THE NUMBER RANGE 1-30K ALL PRIMES, THERE ARE 3245        00004212
//PRIMES   EXEC TSTRX,EXEC=PRIMES,P='30000'                             00004312
//*  SEARCH ALL PRIMES IN THE FIRST 3300 PRIME NUMBERS                  00004412
//PRIMES2  EXEC TSTRX,EXEC=SUNDARAM,P='3300'                            00004512
//CORELT   EXEC TSTRX,EXEC=CORELT                                       00004612
//REGRESST EXEC TSTRX,EXEC=REGRESST                                     00004714
//QT       EXEC TSTRX,EXEC=QT                                           00004807
//TB       EXEC TSTRX,EXEC=TB,P='1'                                     00004907
//SINPLOT  EXEC TSTRX,EXEC=SINPLOT                                      00005007
//FIFO     EXEC TSTRX,EXEC=FIFO                                         00005115
//LIFO     EXEC TSTRX,EXEC=LIFO                                         00005215
//LLCOPY   EXEC TSTRX,EXEC=LLCOPY                                       00005315
//SSEARCH  EXEC TSTRX,EXEC=SSEARCH                                      00005415
//SSELECT  EXEC TSTRX,EXEC=SSELECT                                      00005515
//SSUBSTR  EXEC TSTRX,EXEC=SSUBSTR                                      00005629
//SSORT    EXEC TSTRX,EXEC=SSORT                                        00005715
//SNUMBER  EXEC TSTRX,EXEC=SNUMBER                                      00005829
//SKEEP    EXEC TSTRX,EXEC=SKEEP                                        00005929
//SKEEPA   EXEC TSTRX,EXEC=SKEEPAND                                     00006029
//SDROP    EXEC TSTRX,EXEC=SDROP                                        00006129
//S2HASH   EXEC TSTRX,EXEC=S2HASH                                       00006229
//SCHANGE  EXEC TSTRX,EXEC=SCHANGE                                      00006330
//LLREAD   EXEC TSTRX,EXEC=LLREAD                                       00006415
//LLSETX   EXEC TSTRX,EXEC=LLSETX                                       00006515
//LLSORT2  EXEC TSTRX,EXEC=LLSORT2                                      00006615
//LLDEL    EXEC TSTRX,EXEC=LLDEL                                        00006715
//STEM2DLL EXEC TSTRX,EXEC=STEM2LL                                      00006816
//LL2STEM  EXEC TSTRX,EXEC=LL2STEM                                      00006916
//S2STEM   EXEC TSTRX,EXEC=S2STEM                                       00007016
//STEM2S   EXEC TSTRX,EXEC=STEM2SX                                      00007116
//LVOL1    EXEC RXTSO,EXEC=LVOLUME,P='PUB010'                           00007219
//LVOL2    EXEC RXTSO,EXEC=LVOLUME,P='PUB000'                           00007319
//LVOLMVS  EXEC RXTSO,EXEC=LVOLMVS                                      00007433
//LVTOC1   EXEC RXTSO,EXEC=LVTOC,P='PUB010'                             00007519
//LVTOC2   EXEC RXTSO,EXEC=LVTOC,P='PUB000'                             00007619
//LSELECT  EXEC RXTSO,EXEC=LSELECT                                      00007722
//GETCMT   EXEC RXTSO,EXEC=GETCMT                                       00007822
//AINT     EXEC RXTSO,EXEC=AINT                                         00007924
//AFLOAT   EXEC RXTSO,EXEC=AFLOAT                                       00008024
//BASE64   EXEC RXTSO,EXEC=BASE64                                       00008126
//DATETIME EXEC RXTSO,EXEC=$DATETIM                                     00008226
//DATE     EXEC TSTRX,EXEC=$DATE                                        00008327
//ETIME    EXEC TSTRX,EXEC=$ETIME                                       00008427
//PDSDIR   EXEC TSTRX,EXEC=$PDSDIR                                      00008527
//DIFF     EXEC TSTRX,EXEC=DIFFT                                        00008631
//JES2     EXEC TSTRX,EXEC=JESVIEW                                      00008732
//                                                                      00008815