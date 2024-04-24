         COPY  REGS                                                     00000100
* --------------------------------------------------------------------- 00000200
*   UPDATE ISPF STATUS INFORMATION OF PDS MEMBER                        00000300
* --------------------------------------------------------------------- 00000400
RXPDSTAT PPROC TITLE='UPD ISPF STATS FIELDS',PGMREG=(RC,RA)             00000518
         L     R9,=A(COMMAREA)         LOAD ADDRESS OF COM AREA         00000600
         USING COMMAREA,R9             MAKE IT ADDRESSIBLE              00000700
* .... DO SOME INIT STUFF  ......................................       00000810
         BAL   RE,GETREXX              FETCH REXX INPUT VARIABLES       00000910
         BAL   RE,OPNINIT              OPEN DDN, AND INIT STUFF         00001000
         LTR   RF,RF                   BLDL OK?                         00001100
         BNZ   NOMEMBR                 NO: MEMBER DOES NOT EXIST        00001210
* .... TEST EXISTING STATS  .....................................       00001310
TESTSTAT BAL   RE,PRPSTATS             PREPARE AND TEST STATS INFO      00001425
         B     *+4(RF)                                                  00001500
         B     UPDSTAT                 RC: 0 STATS EXIST                00001600
         B     NEWSTAT                 RC: 4 CREATE STATS               00001700
* .... UPDATE EXISTING STATS  ...................................       00001810
UPDSTAT  BAL   RE,UPDSTATS             UPDATE STATUS INFORMATION        00001900
         RXPUT VAR=RXMSGRC,VALFLD==CL14'STATUS UPDATED',VALLEN=14       00002016
         B     SAVESTAT                SAVE STATUS INFORMATION          00002100
* .... INSERT NEW STATS  ........................................       00002210
NEWSTAT  BAL   RE,NEWSTATS             INSERT STATUS INFORMATION        00002300
         RXPUT VAR=RXMSGRC,VALFLD==CL16'NEW STATUS ADDED',VALLEN=16     00002416
         B     SAVESTAT                SAVE STATUS INFORMATION          00002500
* .... SAVE STATS  ............................................         00002610
NOSTAT   DS    0H                                                       00002725
SAVESTAT BAL   RE,CONSTATS                                              00002800
         LA    RF,0                    EVERYTHING FINE                  00002900
NOMEMBR  DS    0H                      MEMBER NOT EXIST, RF STILL SET   00003018
         LA    R2,RPFWORK2             Reestablish RPFWork              00003111
         LR    R4,RF                                                    00003200
         CLOSE ((2)),MF=(E,CLOSED)                                      00003300
         B     *+4+4                                                    00003411
EXIT8    LA    R4,8                    EXIT BEFORE OPENING DSN          00003511
         SRETURN RC=(R4)                                                00003611
         EJECT                                                          00003700
* --------------------------------------------------------------------- 00003810
*   Fetch REXX Input Variables                                          00003910
* --------------------------------------------------------------------- 00004010
GETREXX  DS    0H                                                       00004110
         ST    RE,SAVE01                                                00004210
         RXGET VAR=PDSDDNAME,INTO=INDDNAME,FEX=EXIT8                    00004313
         RXPUT VAR=RXDDNAME,VALFLD=INDDNAME,VALLEN=8                    00004413
         RXGET VAR=PDSMEMBER,INTO=INMEMBER,FEX=EXIT8                    00004513
         RXPUT VAR=RXMEMBER,VALFLD=INMEMBER,VALLEN=8                    00004613
         MVC   COMMBR,INMEMBER                                          00004710
         RXGET VAR=PDSTIME,INTO=INTIME,FEX=EXIT8                        00004810
         RXGET VAR=PDSDATEINS,INTO=INDATINS,FEX=EXIT8                   00004919
         RXGET VAR=PDSDATECHG,INTO=INDATCHG,FEX=EXIT8                   00005019
         RXGET VAR=PDSUSER,INTO=INUSER,FEX=EXIT8                        00005110
         RXGET VAR=PDSLINO,INTO=INLINC,FEX=EXIT8                        00005244
         ZAP   PUTCNT,=PL2'0'                                           00005345
         L     RE,SAVE01                                                00005410
         BR    RE                                                       00005510
* --------------------------------------------------------------------- 00005600
*   INIT STUFF, OPEN PDS, BLDL MEMBER TO UPDATE, ETC.                   00005700
* --------------------------------------------------------------------- 00005800
OPNINIT  DS    0H                                                       00005900
         ST    RE,SAVE01                                                00006000
         LA    R2,RPFWORK2                                              00006100
         MVC   REPCMT,=CL32'*** REP AREA ***'                           00006236
         MVC   RPFWORK2,MDLWORK2       Copy DCB                         00006317
         MVC   RPFWORK2+40(8),INDDNAME Insert requested DD Name         00006417
         MVI   OPEND,X'80'             Move default option              00006500
         OPEN  ((2),(UPDAT)),MF=(E,OPEND) Open PDSDCB                   00006600
         LTR   RF,RF                                                    00006717
         BNZ   OPNNOK                                                   00006818
         MVC   BLDLMEM,COMMBR          Move member into BLDL list       00006917
         MVC   BLDLAREA(4),=X'0001004C' 1 entry of 76 bytes             00007000
         BLDL  RPFWORK2,BLDLAREA       Retrieve dir. information        00007100
         LTR   RF,RF                                                    00007215
         BZ    OPNRET                                                   00007318
         RXPUT VAR=RXMSGRC,VALFLD==CL16'MEMBER NOT FOUND',VALLEN=16     00007418
         LA    RF,4                                                     00007518
         B     OPNRET                                                   00007617
OPNNOK   DS    0H                                                       00007718
         RXPUT VAR=RXMSGRC,VALFLD==CL13'NOT ALLOCATED',VALLEN=13        00007817
         LA    RF,8                                                     00007918
OPNRET   LR    R5,RF                                                    00008036
*        RXPUT VAR=RXINPCARDS,VALFLD=INPCARDS,VALLEN=2                  00008144
*        RXPUT VAR=RXINPCARDI,VALFLD=INPCARDI,VALLEN=4                  00008244
         RXPUT VAR=RXINPCARDC,VALFLD=INLINC,VALLEN=4                    00008344
         RXPUT VAR=RXINPUID,VALFLD=INPUID,VALLEN=7                      00008432
         LR    RF,R5                                                    00008536
         L     RE,SAVE01                                                00008632
         BR    RE                                                       00008700
* --------------------------------------------------------------------- 00008800
*   INSPECT STATUS INFORMATION                                          00008900
* --------------------------------------------------------------------- 00009000
PRPSTATS DS    0H                      PREPARE STATS INFO               00009100
         ST    RE,SAVE01                                                00009200
         LA    R5,4                    DEFAULT RETURN CODE: NEWSTATS    00009333
         XR    R3,R3                   DEFAULT C-BYTE TO 0              00009414
         IC    R3,BLDLC                Preserve C-byte                  00009500
         NI    BLDLC,B'00011111'       Preserve only the length bits    00009600
         CLI   BLDLC,X'0F'             Do we have 15 halfwords userdata 00009700
         BE    RPF009                  Yes: possible ISPF stats         00009800
         CLI   BLDLC,X'14'             Do we have 20 halfwords userdata 00009900
         BNE   PRPRETN                 NO: CREATE ISPF STATS            00010042
RPF009   TM    INPDATEI+3,X'0C'        Does date contain a sign?  @2000 00010142
         BNO   PRPRETN                 NO: ADD ISPF/RPF STATS           00010242
         TM    INPDATE+3,X'0C'         Does date contain a sign?        00010300
         BNO   PRPRETN                 NO: ADD ISPF/RPF STATS           00010442
         CLI   INPTIME,X'23'       Test TIME field (packed unsigned HH) 00010500
         BH    PRPRETN                 NO: ADD STATS IN RPF/ISPF FORMAT 00010642
         CLI   INPTIME+1,X'59'     Test TIME field (packed unsigned MM) 00010700
         BH    PRPRETN                 NO: ADD STATS IN RPF/ISPF FORMAT 00010842
         LA    R5,0                    UPDATE THE ISPF STATS            00010933
         B     PRPRETN                                                  00011033
PRPRETN  LR    RF,R5                                                    00011133
         LR    RF,R5                                                    00011236
         L     RE,SAVE01                                                00011333
         BR    RE                                                       00011400
* --------------------------------------------------------------------- 00011500
*   ADD NEW STATUS INFORMATION                                          00011600
* --------------------------------------------------------------------- 00011700
NEWSTATS DS    0H                                                       00011800
         ST    RE,SAVE01                                                00011900
         STC   R3,REPC                 Set C byte minus length          00012014
         NI    REPC,B'11100000'        Clear count bits                 00012100
         MVC   REPMEM,COMMBR           Member into directory block      00012200
         LA    R1,0                    SET MODE "NEW STATS"             00012332
         BAL   RE,USERID                                                00012400
         BAL   RE,TIMESTMP                                              00012534
         XC    REPFLGS(2),REPFLGS      Clear the flags and seconds      00012600
         MVI   REPVERS,X'01'           ISPF version number              00012700
         XC    REPMOD,REPMOD           ISPF/RPF modification            00012800
         XC    REPCARDS(6),REPCARDS    Clear non extension counters     00012900
         ZAP   DBW,PUTCNT              # cards                          00013000
         MVC   BLDLMEM,COMMBR          Move member into BLDL list       00013100
         CVB   R2,DBW                  Convert counter to decimal       00013200
         C     R2,=F'65535'            More than 64K records?           00013300
         BH    NEWSTAT3                No: do not use extended section  00013400
         STCM  R2,R3,REPCARDI          Init # records non-extended      00013500
         STCM  R2,R3,REPCARDS          Current # records non-extended   00013600
         OI    REPC,X'0F'              Set length to 15 halfwords       00013700
         B     NEWRTN                                                   00013800
NEWSTAT3 DS    0H                                                       00013900
         OI    REPFLGS,REPEXT          Extended section present         00014000
         STCM  R2,15,REPECRDI          Init # records in extension      00014100
         STCM  R2,15,REPECRDS          Current # records = init # ext.  00014200
         XC    REPECRDM,REPECRDM       Modified # records = zero ext.   00014300
         OI    REPC,X'14'              Set length to 20 halfwords       00014400
NEWRTN   DS    0H                                                       00014500
         CLC   INLINC,=A(0)                                             00014646
         BNH   NEWRETX                                                  00014746
         MVC   REPECRDS,INLINC                                          00014846
         MVC   REPCARDS,INLINC+2                                        00014946
NEWRETX  L     RE,SAVE01                                                00015046
         BR    RE                                                       00015100
* --------------------------------------------------------------------- 00015200
*   UPDATE EXISTING STATUS INFORMATION                                  00015300
* --------------------------------------------------------------------- 00015400
UPDSTATS DS    0H                                                       00015500
         ST    RE,SAVE01                                                00015600
         MVC   REPC,BLDLC              Copy C byte                      00015700
         NI    REPC,B'11100000'        Clear count bytes                00015800
         MVC   REPFLGS(2),INPFLGS      Copy flags + seconds time-upd    00015900
         TM    REPFLGS,REPEXT          Is extended section present?     00016000
         BO    UPDSTA03                No: use standard line counters   00016137
         MVC   REPCARDI,INPCARDI       Copy initial # records           00016200
         MVC   REPCARDM,INPCARDM       and modified # records           00016342
         B     UPDSTA05                Continue                         00016400
UPDSTA03 DS    0H                                                       00016500
         MVC   REPECRDI,INPECRDI       Copy initial # records extended  00016633
         MVC   REPECRDM,INPECRDM       and modified # records extended  00016733
UPDSTA05 DS    0H                                                       00016800
         MVC   REPDATEI,INPDATEI       PRESET OLD INSERT DATE           00016924
         OI    REPDATEI+3,X'0F'        MAKE SIGN ABSOLUTE               00017032
         LA    R1,1                    SET MODE "EXISTING STATS"        00017132
         BAL   RE,USERID                                                00017200
         BAL   RE,TIMESTMP                                              00017334
         MVC   REPVERS,INPVERS         ISPF/RPF version (vv) number     00017400
         MVC   REPMOD,INPMOD           ISPF/RPF mod (mm) number         00017500
         CLI   REPMOD,X'63'            Is Mod. level 99?                00017600
         BNL   UPDSTA07                Yes: set to 0 and increase vv    00017700
         XR    R2,R2                   Clear register 2                 00017800
         IC    R2,REPMOD               Insert ISPF mm (mod. lvl)        00017900
         LA    R2,1(,R2)               Increase by 1                    00018000
         STC   R2,REPMOD               And save                         00018100
         B     UPDSTA09                Do not increase ISPF vv          00018200
UPDSTA07 DS    0H                      Increase ISPF Version            00018300
         CLI   REPVERS,X'63'           99 or higher?                    00018400
         BNL   UPDSTA09                Yes: leave VV    unchanged       00018500
         XR    R2,R2                   Clear register 2                 00018600
         IC    R2,REPVERS              Insert VV number                 00018700
         LA    R2,1(,R2)               Increase by 1                    00018800
         STC   R2,REPVERS              And save                         00018900
         XC    REPMOD,REPMOD           Clear modification level (MM)    00019000
UPDSTA09 DS    0H                      Increase ISPF Version            00019100
         MVC   REPMEM,COMMBR           Move member name                 00019200
         MVC   REPTTR,BLDLTTR          Duplicate TTR                    00019300
UPDSTA11 DS    0H                      Increase ISPF Version            00019400
         ZAP   DBW,PUTCNT              # cards                          00019500
         CVB   R2,DBW                  Convert to decimal               00019600
         TM    REPFLGS,REPEXT          Is extended section present?     00019700
         BNO   UPDSTA13                No: use standard line counters   00019800
         ICM   R3,15,REPECRDI          Initial # records extended       00019900
         ICM   R4,15,REPECRDM          # modified records  extended     00020000
         B     UPDSTA15                                                 00020100
UPDSTA13 DS    0H                      Increase ISPF Version            00020200
         XR    R3,R3                   Clear register 3                 00020300
         XR    R4,R4                   Clear register 4                 00020400
         ICM   R3,3,REPCARDI           Initial # records standard       00020500
*        ICM   R4,3,REPCARDM           MODIFIED # RECORDS STANDARD      00020633
         LH    R1,REPCARDI                                              00020733
         XC    REPCARDM,REPCARDM       CLEAR MODIFIED RECORD COUNTER    00020833
UPDSTA15 DS    0H                      Increase ISPF Version            00020900
         A     R4,MODLINES             + NEW # MODIFIED RECORDS         00021033
         CR    R4,R2                   MODIFIED > CURRENT # RECORDS?    00021133
         BNH   *+6                     NO: DO NO CHANGED MODIFIED       00021233
         LR    R4,R2                   MODIFIED NEVER > CURRENT         00021333
         C     R2,=F'65535'            CURRENT # MORE THAN 64K LINES?   00021433
         BH    UPDSTA17                NO: USE STANDARD LINE COUNTERS   00021533
         C     R3,=F'65535'            INITIAL # MORE THAN 64K LINES?   00021633
         BH    UPDSTA17                NO: USE STANDARD LINE COUNTERS   00021733
         STCM  R2,3,REPCARDS           Current # records non-extended   00021800
         STCM  R3,3,REPCARDI           Initial # records non-extended   00021900
         LH    R1,REPCARDI                                              00022033
         STCM  R4,3,REPCARDM           Modified # records non-extended  00022100
         NI    REPFLGS,255-REPEXT      No extended section              00022200
         OI    REPC,15                 Set count (length in halfwords)  00022300
         B     UPDRETN                 AND BRANCH                       00022400
UPDSTA17 DS    0H                      Increase ISPF Version            00022500
         XC    REPCARDS(6),REPCARDS    Clear the not extension counters 00022600
         STCM  R2,15,REPECRDS          Current # records in extension   00022700
         STCM  R3,15,REPECRDI          Initial # records in extension   00022800
         STCM  R4,15,REPECRDM          Modified # records in extension  00022900
         OI    REPFLGS,REPEXT          Extended section present         00023000
         OI    REPC,20                 Set count (length in halfwords)  00023100
UPDRETN  DS    0H                                                       00023240
         CLC   INLINC,=A(0)                                             00023346
         BNH   UPDRETX                                                  00023446
         MVC   REPECRDS,INLINC                                          00023546
         MVC   REPCARDS,INLINC+2                                        00023646
UPDRETX  L     RE,SAVE01                                                00023746
         BR    RE                                                       00023800
* --------------------------------------------------------------------- 00023900
*   STORE STATUS INFORMATION                                            00024000
* --------------------------------------------------------------------- 00024100
CONSTATS DS    0H                                                       00024200
         ST    RE,SAVE01                                                00024300
         STOW  RPFWORK2,REPAREA,R      Replace directory info           00024400
         MVI   CLOSED,X'80'            Move default option code         00024500
         L     RE,SAVE01                                                00024600
         BR    RE                                                       00024700
* --------------------------------------------------------------------- 00024800
*   CREATE TIMESTAMP                                                    00024900
* --------------------------------------------------------------------- 00025000
TIMESTMP DS    0H                                                       00025100
         ST    RE,SAVE02                                                00025200
         LR    R7,R1                   SAVE STATUS MODE PARM            00025334
         L     R2,X'4C'                SAVE SYSTEM DATE (CVT)           00025427
         ZAP   CURDATE,56(4,R2)        MOVE CVTDATE                     00025527
* ... 1. SET INSERT DATE ........................................       00025624
         CP    INDATINS,=PL2'0'        0 MEANS TAKE ACTUAL TIME         00025727
         BE    DATECI                  TAKE SYSTEM DATE                 00025832
         BH    DATESTI                 TAKE GIVEN DATE                  00025932
         LTR   R7,R7                   TEST IF NEW/EXISTING STATS       00026034
         BZ    DATECI                  0: NEW STAT, DATE MUST BE INSRTD 00026132
         CP    INDATINS,=PL2'-1'       -1 NO TIME CHANGE REQUESTED      00026232
         BE    NODATEI                 PARM NOT SET, LEAVE IT           00026332
DATESTI  ZAP   REPDATEI,INDATINS       ADD PROVIDED INSERT DATE         00026432
         B     *+4+6                   PARM NOT SET, LEAVE IT           00026527
DATECI   ZAP   REPDATEI,CURDATE        ADD PROVIDED INSERT DATE         00026627
         OI    REPDATEI+3,X'0F'        MAKE SIGN ABSOLUTE               00026724
* ... 2. SET LAST CHANGED DATE ..................................       00026824
NODATEI  DS    0H                                                       00026927
         CP    INDATCHG,=PL2'0'        0 MEANS TAKE ACTUAL TIME         00027027
         BE    DATECC                  TAKE SYSTEM DATE                 00027132
         BH    DATESTC                 TAKE GIVEN DATE                  00027232
         LTR   R7,R7                   TEST IF NEW/EXISTING STATS       00027334
         BZ    DATECC                  0: NEW STAT, TIME MUST BE INSRTD 00027432
         CP    INDATCHG,=PL2'-1'       -1 NO TIME CHANGE REQUESTED      00027532
         BE    NODATEC                 PARM NOT SET, LEAVE IT           00027632
DATESTC  ZAP   REPDATE,INDATCHG        ADD PROVIDED INSERT DATE         00027732
         B     *+4+6                   PARM NOT SET, LEAVE IT           00027827
DATECC   ZAP   REPDATE,CURDATE         ADD PROVIDED INSERT DATE         00027927
         OI    REPDATE+3,X'0F'         MAKE SIGN ABSOLUTE               00028027
         RXPUT VAR=RXREPDATE,VALFLD=REPDATE,VALLEN=4                    00028105
         RXPUT VAR=RXINSDATE,VALFLD=REPDATEI,VALLEN=4                   00028224
NODATEC  DS    0H                                                       00028330
* ... 3. SET TIME ...............................................       00028424
         CP    INTIME,=PL2'0'          0 MEANS TAKE ACTUAL TIME         00028530
         BE    TIMECI                  TAKE SYSTEM TIME                 00028632
         BH    TIMEST                  TAKE GIVEN  TIME                 00028744
         LTR   R7,R7                   TEST IF NEW/EXISTING STATS       00028834
         BZ    TIMECI                  0: NEW STAT, TIME MUST BE INSRTD 00028932
         CP    INTIME,=PL2'-1'         -1 NO TIME CHANGE REQUESTED      00029032
         BE    NOTIME                  PARM NOT SET, LEAVE IT           00029132
TIMEST   L     R0,INTIMX                                                00029232
         SRL   R0,12              SHIFT OUT FRACTIONS OF SECONDS        00029331
         B     TIMESET                 TIME NOW SET                     00029427
TIMECI   DS    0H                                                       00029527
         TIME  DEC                     GET TIME OF DAY                  00029627
         SRL   R0,16                   Shift out fractions of seconds   00029700
TIMESET  DS    0H                      SHIFT OUT PACKED SIGN            00029830
         STCM  R0,3,REPTIME            MOVE TIME IN REPAREA NO SIGN     00029927
         RXPUT VAR=RXREPTIME,VALFLD=REPTIME,VALLEN=2                    00030027
NOTIME   DS    0H                                                       00030127
         L     RE,SAVE02                                                00030200
         BR    RE                                                       00030300
* --------------------------------------------------------------------- 00030400
*   SET USERID                                                          00030500
* --------------------------------------------------------------------- 00030600
USERID   DS    0H                                                       00030700
         ST    RE,SAVE02                                                00030800
         MVI   REPUID,C' '             Blank userid +                   00030900
         MVC   REPUID+1(9),REPUID            bytes 28, 29 and 30        00031000
         MVC   REPUID,INPUID           MOVE existing                    00031144
         CLI   INUSER,C'0'             NO EXTERNAL USER PROVIDED        00031247
         BE    *+4+6                   THEN LEAVE IT AS IT IS           00031345
         MVC   REPUID(7),INUSER        MOVE USER ID                     00031444
         L     RE,SAVE02                                                00031544
         BR    RE                                                       00031600
         EJECT                                                          00031700
         LTORG                                                          00031800
MDLWORK  DCB   DDNAME=RXDDNAME,DSORG=PS,MACRF=PM                        00031900
MDLLEN   EQU   *-MDLWORK                                                00032000
MDLWORK2 DCB   DSORG=PO,DDNAME=$$$LMMDD,MACRF=(R,W)                     00032112
MDLLEN2  EQU   *-MDLWORK2                                               00032200
         DS    0F                                                       00032300
         SHVCB DSECT                                                    00032404
RXPDSTAT CSECT                                                          00032504
         WORKAREA                                                       00032605
         DS    CL32                                                     00032700
OUTMSG   DS    CL123                                                    00032800
INDDNAME DS    CL8                     INPUT DDNAME bY REXX             00032913
INMEMBER DS    CL8                     INPUT Member by REXX             00033013
INDATINS DS    PL4                     INSERT DATE BY REXX              00033119
INDATCHG DS    PL4                     CHANGE DATE BY REXX              00033219
INTIMX   DS    0A                      INPUT TIME BY REXX               00033330
INTIME   DS    PL4                     INPUT TIME BY REXX               00033430
INUSER   DS    CL8                     INPUT USER BY REXX               00033505
INLINC   DS    XL4                     INPUT MEMBER LINE COUNT BY REXX  00033644
CURDATE  DS    PL4                                                      00033742
BINTEMP  DS    CL16                                                     00033833
         DS    0A                                                       00033933
STRPACK  DS    PL8     8-BYTE PACKED, MAX 999,999,999,999,999           00034033
RPFWORK  DS    CL(MDLLEN)              Sequential DCB                   00034100
RPFWORK2 DS    CL(MDLLEN2)             PDS DCB                          00034200
BLDLAREA DS    0A                                                       00034342
         DC    AL2(1)                  Retrieve 1 member                00034400
         DC    AL2(76)                 Maximum length of dir entry      00034500
BLDLMEM  DC    CL8' '                                                   00034600
BLDLTTR  DS    XL3                                                      00034700
BLDLKZ   DS    CL2                                                      00034800
BLDLC    DS    X                                                        00034900
BLDLUSER DS    0CL62                   Obtained userdata if present     00035000
INPVERS  DS    C                       ISPF or                          00035100
INPMOD   DS    C                              RPF stats                 00035200
INPFLGS  DS    X                       Flags                            00035300
INPEXT   EQU   32                      Extended part of stats present   00035400
INPSECU  DS    X                       Seconds part of time updated     00035500
INPDATEI DS    PL4                                                @2000 00035600
INPDATE  DS    PL4                                                      00035700
INPTIME  DS    XL2                                                      00035800
INPCARDS DS    XL2                                                      00035900
INPCARDI DS    XL2                                                      00036000
INPCARDM DS    XL2                                                      00036100
INPUID   DS    CL7                                                      00036200
         DS    CL1                     Should be blank                  00036300
INPECRDS DS    XL4                     Current number of records        00036400
INPECRDI DS    XL4                     Initial number of records        00036500
INPECRDM DS    XL4                     Number of records modified       00036600
INPREST  DS    CL22                    Data not from ISPF/RPF           00036700
BLDLALEN EQU   *-BLDLAREA                                               00036838
*                                                                       00036900
REPCMT   DS    CL32                                                     00037036
REPAREA  DS    0H                      Member entry of STOW macro       00037100
REPMEM   DS    CL8                     with new ISPF or RPF stats       00037200
REPTTR   DS    XL3                                                      00037300
REPC     DS    X                                                        00037400
REPUSER  DS    0CL62                                                    00037500
REPVERS  DS    X                       ISPF vv                          00037600
REPMOD   DS    X                       ISPF mm                          00037700
REPFLGS  DS    X                       Flags                            00037800
REPEXT   EQU   32                      Extended part of stats present   00037900
REPSECU  DS    X                       Seconds part of time updated     00038000
REPDATEI DS    PL4                                                @2000 00038100
REPDATE  DS    PL4                                                      00038200
REPTIME  DS    XL2                                                      00038300
REPCARDS DS    XL2                     Current number of records        00038400
REPCARDI DS    XL2                     Initial number of records        00038500
REPCARDM DS    XL2                     Number of records modified       00038600
REPUID   DS    CL7                                                      00038700
         DS    CL5                     SHOULD BE BLANK                  00038833
REPECRDS DS    XL4                     Current number of records        00038900
REPECRDI DS    XL4                     Initial number of records        00039000
REPECRDM DS    XL4                     Number of records modified       00039100
         ORG   REPUSER+L'REPUSER                                        00039240
REPALEN  EQU   *-REPAREA                                                00039340
*        DUMPIT MODE=DEFINE                                             00039446
*                                                                       00039500
SAVEAREA DS    18F                                                      00039600
OPEND    DS    F                       OPEN MF=L                        00039700
CLOSED   DS    F                       CLOSE MF=L                       00039800
DBW      DS    D                                                        00039900
AUTO     DS    C                                                        00040000
MODLINES DS    F                                                        00040100
PUTCNT   DC    PL5'0'                                                   00040200
SCR1MEM  DS    CL8                                                      00040300
SCR2MEM  DS    CL8                                                      00040400
         SHVCB DEFINE                                                   00040502
         WORKEND                                                        00040600
COMMAREA RPFCOMM DSECT=NO                                               00040700
         DS    0D                      FORCE DOUBLEWORD SIZE            00040800
         END                                                            00040900
