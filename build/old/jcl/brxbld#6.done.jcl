//BRXBLD#6 JOB (BREXX),                                                 00000107
//            'BREXX BUILD STEP#6',                                     00000207
//            CLASS=A,                                                  00000305
//            MSGCLASS=H,                                               00000405
//            REGION=8M,                                                00000505
//            MSGLEVEL=(1,1)                                            00000605
//********************************************************************  00000705
//*                                                                     00000805
//* BUILDING BREXX VARIABLE ACCESS ROUTINE - IRXEXCOM                   00000905
//*                                                                     00001005
//********************************************************************  00001105
//JCCCP    PROC SOUT='*',JCC='JCC',INFILE='',JOPTS='',JS2='',JS3=''     00001204
//COMPILE  EXEC PGM=JCC,                                                00001304
//         PARM='-I//DDN:JCCINCL //DDN:SYSIN &JOPTS &JS2 &JS3'          00001404
//STEPLIB  DD   DSN=&JCC..LINKLIB,DISP=SHR                              00001504
//JCCINCL  DD   DSN=&JCC..INCLUDE,DISP=SHR                              00001604
//JCCINCS  DD   DSN=&JCC..INCLUDE,DISP=SHR                              00001704
//JCCOUTPT DD   UNIT=SYSDA,SPACE=(TRK,(50,20)),DISP=(,PASS),DSN=&&OUTPT 00001804
//STDOUT   DD   SYSOUT=&SOUT                                            00001904
//JCCOASM  DD   SYSOUT=&SOUT                                            00002004
//SYSIN    DD   DSN=&INFILE,DISP=SHR                                    00002104
//         PEND                                                         00002204
//********************************************************************* 00002304
//*                                                                     00002400
//* compile lstring in systemr mode                                     00002500
//*                                                                     00002600
//LUPPER  EXEC JCCCP,INFILE='BRXBLD.C.SRC(UPPER)',                      00002705
//        JOPTS='-o -systemr -fstk -list=//DDN:SYSPRINT',               00002800
//        JS2='-D__MVS__',                                              00002900
//        JS3='-D__METAL_C__'                                           00003000
//COMPILE.JCCINCS  DD DISP=SHR,DSN=BRXBLD.C.INC                         00003105
//COMPILE.JCCOASM  DD DISP=SHR,DSN=BRXBLD.METAL.OBJ(UPPER)              00003205
//*COMPILE.SYSPRINT DD DISP=SHR,DSN=BREXX.LIST.CX(UPPER)                00003304
//*                                                                     00003403
//* compile lstring in systemr mode                                     00003503
//*                                                                     00003603
//LSTRING EXEC JCCCP,INFILE='BRXBLD.C.SRC(LSTRING)',                    00003705
//        JOPTS='-o -systemr -fstk -list=//DDN:SYSPRINT',               00003803
//        JS2='-D__MVS__',                                              00003903
//        JS3='-D__METAL_C__'                                           00004003
//COMPILE.JCCINCS  DD DISP=SHR,DSN=BRXBLD.C.INC                         00004105
//COMPILE.JCCOASM  DD DISP=SHR,DSN=BRXBLD.METAL.OBJ(LSTRING)            00004205
//*COMPILE.SYSPRINT DD DISP=SHR,DSN=BREXX.LIST.CX(LSTRING)              00004304
//*                                                                     00004401
//* compile bintree in systemr mode                                     00004501
//*                                                                     00004601
//BINTREE EXEC JCCCP,INFILE='BRXBLD.C.SRC(BINTREE)',                    00004705
//        JOPTS='-o -systemr -fstk -list=//DDN:SYSPRINT',               00004801
//        JS2='-D__MVS__',                                              00004901
//        JS3='-D__METAL_C__'                                           00005001
//COMPILE.JCCINCS  DD DISP=SHR,DSN=BRXBLD.C.INC                         00005105
//COMPILE.JCCOASM  DD DISP=SHR,DSN=BRXBLD.METAL.OBJ(BINTREE)            00005205
//*COMPILE.SYSPRINT DD DISP=SHR,DSN=BREXX.LIST.CX(BINTREE)              00005305
//*                                                                     00005401
//* compile brexx variable interface in systemr mode                    00005501
//*                                                                     00005601
//IRXEXCOM EXEC JCCCP,INFILE='BRXBLD.C.SRC(IRXEXCOM)',                  00005705
//        JOPTS='-o -systemr -fstk -list=//DDN:SYSPRINT',               00005801
//        JS2='-D__MVS__',                                              00005901
//        JS3='-D__METAL_C__'                                           00006001
//COMPILE.JCCINCS  DD DISP=SHR,DSN=BRXBLD.C.INC                         00006105
//COMPILE.JCCOASM  DD DISP=SHR,DSN=BRXBLD.METAL.OBJ(IRXEXCOM)           00006205
//*COMPILE.SYSPRINT DD DISP=SHR,DSN=BREXX.LIST.CX(IRXEXCOM)             00006305
//*                                                                     00006401
//* prelink all into one object file                                    00006501
//*                                                                     00006601
//PRELINK  EXEC PGM=PRELINK,                                            00006701
//         PARM='-s NOLIB //DDN:O -//DDN:I'                             00006801
//STEPLIB  DD   DSN=JCC.LINKLIB,DISP=SHR                                00006901
//*STDOUT   DD   DISP=SHR,DSN=BREXX.LIST.PRELNK(IRXEXCOM)               00007005
//STDERR   DD   SYSOUT=*                                                00007101
//I        DD   DDNAME=LINKLIST                                         00007201
//UPPER    DD   DISP=SHR,DSN=BRXBLD.METAL.OBJ(UPPER)                    00007305
//LSTRING  DD   DISP=SHR,DSN=BRXBLD.METAL.OBJ(LSTRING)                  00007405
//BINTREE  DD   DISP=SHR,DSN=BRXBLD.METAL.OBJ(BINTREE)                  00007505
//IRXEXCOM DD   DISP=SHR,DSN=BRXBLD.METAL.OBJ(IRXEXCOM)                 00007605
//O        DD   UNIT=3390,SPACE=(TRK,(30,10),RLSE),DSN=&&OBJMOD,        00007701
//         DCB=(RECFM=FB,LRECL=80,BLKSIZE=3200),DISP=(,PASS)            00007801
//LINKLIST DD DATA,DLM=@@                                               00007901
//DDN:UPPER                                                             00008003
//DDN:LSTRING                                                           00008103
//DDN:BINTREE                                                           00008201
//DDN:IRXEXCOM                                                          00008301
@@                                                                      00008401
//*                                                                     00008501
//* linked the final IRXEXCOM module                                    00008601
//*                                                                     00008701
//LKED     EXEC PGM=IEWL,PARM='NCAL,MAP,LIST,XREF,NORENT'               00008801
//SYSUT1   DD UNIT=SYSDA,SPACE=(CYL,(5,2))                              00008901
//*YSPRINT DD DISP=SHR,DSN=BREXX.LIST.LKED(IRXEXCOM)                    00009001
//*YSPUNCH DD DISP=SHR,DSN=BREXX.LIST.LKED(IRXEXCOM)                    00009101
//SYSPRINT DD SYSOUT=*                                                  00009201
//SYSPUNCH DD SYSOUT=*                                                  00009301
//OBJECT   DD DSN=&&OBJMOD,DISP=(OLD,DELETE)                            00009401
//SYSOBJ   DD DSN=BRXBLD.METAL.OBJ,DISP=SHR                             00009505
//SYSLMOD  DD DSN=BRXBLD.LOADLIB(IRXEXCOM),DISP=SHR                     00009606
//SYSLIN   DD *                                                         00009701
 INCLUDE OBJECT                                                         00009801
 INCLUDE SYSOBJ(METAL)                                                  00009901
 ENTRY IRXEXCOM                                                         00010001
 NAME IRXEXCOM(R)                                                       00010102
/*                                                                      00010201
