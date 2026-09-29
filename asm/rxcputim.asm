* --------------------------------------------------------------------- 00000112
* CPU USAGE Function called from BREXX                                  00000212
* --------------------------------------------------------------------- 00000312
* Adopted from this site:                                               00000412
* https://h390-mvs.yahoogroups.narkive.com/q4XvuIYD/reliable-high-resol 00000512
* ution-cpu-time-retrieval-under-mvs-3-8j                               00000612
* --------------------------------------------------------------------- 00000712
RXCPUTIM TITLE 'RETURN CPU Time in Micro Seconds'                       00000812
* --------------------------------------------------------------------- 00000900
*   RETURN USED CPU TIME IN MICRO SECONDS (SINCE JOB BEGIN)             00001000
*   AUTHOR  : PETER JACOB (PEJ)                                         00001100
*   CREATED : 01.09.2020  PEJ                                           00001200
*   JCC PROLOGUE : JUERGEN WINKELMANN, ETH ZUERICH.                     00001300
* --------------------------------------------------------------------- 00001400
         PRINT GEN                                                      00001500
* --------------------------------------------------------------------  00001600
*   RXCPUTIME CODE: RETURN USED CPU TIME SINCE JOB BEGIN                00001701
* --------------------------------------------------------------------  00001800
RXCPUTIM MRXSTART A2PLIST=YES                                           00001901
         USING STIMPARM,RB   ENABLE ADDRESSIBILTY OF C INPUT AREA       00002000
         L     RA,WPTWKADR   LOAD WORK AREA OF INPUT PARM               00002101
* --------------------------------------------------------------------  00002200
*   EXTRACT CPU TIME                                                    00002300
* --------------------------------------------------------------------  00002400
         USING PSA,R0                                                   00002501
         USING LCCA,R6                                                  00002601
         USING ASCB,R7                                                  00002701
*                                                                       00002801
         L     R6,PSALCCAV        get LCCA ptr                          00002901
         L     R7,PSAAOLD         get ASCB ptr                          00003001
         LA    R10,9              init retry loop count                 00003101
*                                                                       00003201
CPUTIMR  LM    R8,R9,LCCADTOD     get initial LCCADTOD                  00003301
         STM   R8,R9,SAVDTOD      and save it                           00003401
*                                                                       00003501
         STCK  CKBUF              store TOD                             00003601
         LM    R0,R1,CKBUF                                              00003701
         SLR   R1,R9              low order:  sum=TOD-LCCADTOD          00003801
         BC    3,*+4+4            check for borrow                      00003901
         SL    R0,=F'1'           and correct if needed                 00004001
         SLR   R0,R8              high order: sum=TOD-LCCADTOD          00004101
*                                                                       00004201
         LM    R8,R9,ASCBEJST     load ASCBEJST                         00004301
         ALR   R1,R9              low order:  sum+=ASCBEJST             00004401
         BC    12,*+4+4           check for carry                       00004501
         AL    R0,=F'1'           and correct if needed                 00004601
         ALR   R0,R8              high order: sum+=ASCBEJST             00004701
*                                                                       00004801
         LM    R8,R9,ASCBSRBT     load ASCBSRBT                         00004901
         ALR   R1,R9              low order:  sum+=ASCBSRBT             00005001
         BC    12,*+4+4           check for carry                       00005101
         AL    R0,=F'1'           and correct if needed                 00005201
         ALR   R0,R8              high order: sum+=ASCBSRBT             00005301
*                                                                       00005401
         LM    R8,R9,LCCADTOD     get final LCCADTOD                    00005501
         C     R9,SAVDTOD+4       check low order                       00005601
         BNE   CPUTIMN            if ne, dispatch detected              00005701
         C     R8,SAVDTOD         check high order                      00005801
         BE    CPUTIMX            if eq, all fine                       00005901
*                                                                       00006001
CPUTIMN  BCT   R10,CPUTIMR        retry in case dispatch detected       00006101
*                                                                       00006201
CPUTIMX  STM   R0,R1,SAVSUM       save full sum                         00006301
         SRDL  R0,12              shift to convert to microsec          00006411
         ST    R1,CPUTIML         SAVE TIME IN USEC                     00006510
         BIN2CHR CPUTIME,CPUTIML                                        00006610
         LA    RA,WPTWKADR                                              00006704
         L     RA,0(RA)                                                 00006805
         MVC   0(15,RA),CPUTIME+1                                       00006910
*                                                                       00007001
* --------------------------------------------------------------------  00007100
*   EXIT PROGRAM                                                        00007200
* --------------------------------------------------------------------  00007300
         LA    RF,0          SET RC=0                                   00007400
EXIT     MRXEXIT                                                        00007500
         LTORG                                                          00007600
         DC    C'###CPU###'                                             00007704
CPUTIME  DS    CL16          BIN2CHR DESTINATION FIELD                  00007804
CPUTIML  DS    A             CPU TIME IN BINARY                         00007904
CKBUF    DS    D                                                        00008004
SAVDTOD  DS    D                                                        00008104
SAVSUM   DS    D                                                        00008204
STRPACK  DS    PL8           BIN2PCK TEMP MAXIMUM 999,999,999,999,999   00008304
* --------------------------------------------------------------------  00008400
*    INCOMING STORAGE DEFINITION (FROM C PROGRAM)                       00008500
* --------------------------------------------------------------------  00008600
*    INPUT PARM DSECT, PROVIDED AS INPUT PARAMETER BY THE C PROGRAM     00008700
STIMPARM DSECT               INPUT PARM DSECT                           00008800
WPTWKADR DS    A             ADDRESS RESULT RETURNED FROM PGM           00008904
* --------------------------------------------------------------------  00009001
*    OTHER DEFS                                                         00009101
* --------------------------------------------------------------------  00009201
         IHAPSA                                                         00009301
         IHALCCA                                                        00009401
         IHAASCB                                                        00009501
* --------------------------------------------------------------------  00009600
*    REGISTER DEFINITIONS                                               00009700
* --------------------------------------------------------------------  00009800
         COPY  MRXREGS                                                  00009900
         END   RXCPUTIM                                                 00010002
