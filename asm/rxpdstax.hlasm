         COPY  REGS                                                     00000100
* --------------------------------------------------------------------- 00000200
*   UPDATE ISPF STATUS INFORMATION OF PDS MEMBER                        00000300
* --------------------------------------------------------------------- 00000400
RXPDSTAT PPROC TITLE='UPD ISPF STATS FIELDS',PGMREG=(RC,RA)             00000500
         L     R9,=A(COMMAREA)         LOAD ADDRESS OF COM AREA         00000600
         USING COMMAREA,R9             MAKE IT ADDRESSIBLE              00000700
* .... DO SOME INIT STUFF  ......................................       00000800
         BAL   RE,GETREXX              FETCH REXX INPUT VARIABLES       00000900
         BAL   RE,OPNINIT              OPEN DDN, AND INIT STUFF         00001000
         LTR   RF,RF                   BLDL OK?                         00001100
         BNZ   NOMEMBR                 NO: MEMBER DOES NOT EXIST        00001200
* .... TEST EXISTING STATS  .....................................       00001300
         CP    INDATINS,=PL2'0'                                         00001400
         BNE   TESTSTAT                PARM NOT SET, LEAVE IT           00001500
         CP    INDATCHG,=PL2'0'                                         00001600
         BNE   TESTSTAT                PARM NOT SET, LEAVE IT           00001700
         B     NOSTAT                                                   00001800
TESTSTAT BAL   RE,PRPSTATS             PREPARE AND TEST STATS INFO      00001900
         B     *+4(RF)                                                  00002000
         B     UPDSTAT                 RC: 0 STATS EXIST                00002100
         B     NEWSTAT                 RC: 4 CREATE STATS               00002200
         B     NOSTAT                  RC: 8 NO STAT CHANGE REQUESTED   00002300
* .... UPDATE EXISTING STATS  ...................................       00002400
UPDSTAT  BAL   RE,UPDSTATS             UPDATE STATUS INFORMATION        00002500
         RXPUT VAR=RXMSGRC,VALFLD==CL14'STATUS UPDATED',VALLEN=14       00002600
         B     SAVESTAT                SAVE STATUS INFORMATION          00002700
* .... INSERT NEW STATS  ........................................       00002800
NEWSTAT  BAL   RE,NEWSTATS             INSERT STATUS INFORMATION        00002900
         RXPUT VAR=RXMSGRC,VALFLD==CL16'NEW STATUS ADDED',VALLEN=16     00003000
         B     SAVESTAT                SAVE STATUS INFORMATION          00003100
* .... SAVE STATS  ............................................         00003200
NOSTAT   DS    0H                                                       00003300
SAVESTAT BAL   RE,CONSTATS                                              00003400
         LA    RF,0                    EVERYTHING FINE                  00003500
NOMEMBR  DS    0H                      MEMBER NOT EXIST, RF STILL SET   00003600
         LA    R2,RPFWORK2             Reestablish RPFWork              00003700
         LR    R4,RF                                                    00003800
         CLOSE ((2)),MF=(E,CLOSED)                                      00003900
         B     *+4+4                                                    00004000
EXIT8    LA    R4,8                    EXIT BEFORE OPENING DSN          00004100
         SRETURN RC=(R4)                                                00004200
         EJECT                                                          00004300
* --------------------------------------------------------------------- 00004400
*   Fetch REXX Input Variables                                          00004500
* --------------------------------------------------------------------- 00004600
GETREXX  DS    0H                                                       00004700
         ST    RE,SAVE01                                                00004800
         RXGET VAR=PDSDDNAME,INTO=INDDNAME,FEX=EXIT8                    00004900
         RXPUT VAR=RXDDNAME,VALFLD=INDDNAME,VALLEN=8                    00005000
         RXGET VAR=PDSMEMBER,INTO=INMEMBER,FEX=EXIT8                    00005100
         RXPUT VAR=RXMEMBER,VALFLD=INMEMBER,VALLEN=8                    00005200
         MVC   COMMBR,INMEMBER                                          00005300
         RXGET VAR=PDSTIME,INTO=INTIME,FEX=EXIT8                        00005400
         RXGET VAR=PDSDATEINS,INTO=INDATINS,FEX=EXIT8                   00005500
         RXGET VAR=PDSDATECHG,INTO=INDATCHG,FEX=EXIT8                   00005600
         RXGET VAR=PDSUSER,INTO=INUSER,FEX=EXIT8                        00005700
         RXGET VAR=PDSLINO,INTO=INLINO,FEX=EXIT8                        00005800
         RXPUT VAR=RXLINO,VALFLD=INLINO,VALLEN=5                        00005900
         ZAP   PUTCNT,INLINO                                            00006000
         L     RE,SAVE01                                                00006100
         BR    RE                                                       00006200
* --------------------------------------------------------------------- 00006300
*   INIT STUFF, OPEN PDS, BLDL MEMBER TO UPDATE, ETC.                   00006400
* --------------------------------------------------------------------- 00006500
OPNINIT  DS    0H                                                       00006600
         ST    RE,SAVE01                                                00006700
         LA    R2,RPFWORK2                                              00006800
         MVC   RPFWORK2,MDLWORK2       Copy DCB                         00006900
         MVC   RPFWORK2+40(8),INDDNAME Insert requested DD Name         00007000
         MVI   OPEND,X'80'             Move default option              00007100
         OPEN  ((2),(UPDAT)),MF=(E,OPEND) Open PDSDCB                   00007200
         LTR   RF,RF                                                    00007300
         BNZ   OPNNOK                                                   00007400
         MVC   BLDLMEM,COMMBR          Move member into BLDL list       00007500
         MVC   BLDLAREA(4),=X'0001004C' 1 entry of 76 bytes             00007600
         BLDL  RPFWORK2,BLDLAREA       Retrieve dir. information        00007700
         LTR   RF,RF                                                    00007800
         BZ    OPNRET                                                   00007900
         RXPUT VAR=RXMSGRC,VALFLD==CL16'MEMBER NOT FOUND',VALLEN=16     00008000
         LA    RF,4                                                     00008100
         B     OPNRET                                                   00008200
OPNNOK   DS    0H                                                       00008300
         RXPUT VAR=RXMSGRC,VALFLD==CL13'NOT ALLOCATED',VALLEN=13        00008400
         LA    RF,8                                                     00008500
OPNRET   L     RE,SAVE01                                                00008600
         BR    RE                                                       00008700
* --------------------------------------------------------------------- 00008800
*   INSPECT STATUS INFORMATION                                          00008900
* --------------------------------------------------------------------- 00009000
PRPSTATS DS    0H                      PREPARE STATS INFO               00009100
         ST    RE,SAVE01                                                00009200
         LA    RF,4                    DEFAULT RETURN CODE: NEWSTATS    00009300
         XR    R3,R3                   DEFAULT C-BYTE TO 0              00009400
         IC    R3,BLDLC                Preserve C-byte                  00009500
         NI    BLDLC,B'00011111'       Preserve only the length bits    00009600
         CLI   BLDLC,X'0F'             Do we have 15 halfwords userdata 00009700
         BE    RPF009                  Yes: possible ISPF stats         00009800
         CLI   BLDLC,X'14'             Do we have 20 halfwords userdata 00009900
         BNE   PRPRETN                 NO: CREATE ISPF STATS            00010000
RPF009   DS    0H                                                       00010100
         TM    INPDATEI+3,X'0C'        Does date contain a sign?  @2000 00010200
         BNO   PRPRETN                 NO: ADD ISPF/RPF STATS           00010300
         TM    INPDATE+3,X'0C'         Does date contain a sign?        00010400
         BNO   PRPRETN                 NO: ADD ISPF/RPF STATS           00010500
         CLI   INPTIME,X'23'       Test TIME field (packed unsigned HH) 00010600
         BH    PRPRETN                 NO: ADD STATS IN RPF/ISPF FORMAT 00010700
         CLI   INPTIME+1,X'59'     Test TIME field (packed unsigned MM) 00010800
         BH    PRPRETN                 NO: ADD STATS IN RPF/ISPF FORMAT 00010900
         LA    RF,0                    UPDATE THE ISPF STATS            00011000
PRPRETN  L     RE,SAVE01                                                00011100
         BR    RE                                                       00011200
* --------------------------------------------------------------------- 00011300
*   ADD NEW STATUS INFORMATION                                          00011400
* --------------------------------------------------------------------- 00011500
NEWSTATS DS    0H                                                       00011600
         ST    RE,SAVE01                                                00011700
         STC   R3,REPC                 Set C byte minus length          00011800
         NI    REPC,B'11100000'        Clear count bits                 00011900
         MVC   REPMEM,COMMBR           Member into directory block      00012000
         BAL   RE,TIMESTMP                                              00012100
         CP    INDATINS,=PL2'0'        INSERT DATE AS PARM?             00012200
         BNE   *+4+6                   NO, USE REPDATE                  00012300
         ZAP   REPDATEI,REPDATE        USE REPDATE                      00012400
         BAL   RE,USERID                                                00012500
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
         L     RE,SAVE01                                                00014600
         BR    RE                                                       00014700
* --------------------------------------------------------------------- 00014800
*   UPDATE EXISTING STATUS INFORMATION                                  00014900
* --------------------------------------------------------------------- 00015000
UPDSTATS DS    0H                                                       00015100
         ST    RE,SAVE01                                                00015200
         MVC   REPC,BLDLC              Copy C byte                      00015300
         NI    REPC,B'11100000'        Clear count bytes                00015400
         MVC   REPFLGS(2),INPFLGS      Copy flags + seconds time-upd    00015500
         TM    REPFLGS,REPEXT          Is extended section present?     00015600
         BO    UPDSTA03                No: use standard line counters   00015700
         MVC   REPCARDI,INPCARDI       Copy initial # records           00015800
         MVC   REPCARDM,INPCARDM       and modified # records           00015900
         B     UPDSTA05                Continue                         00016000
UPDSTA03 DS    0H                                                       00016100
         MVC   REPECRDI,INPECRDI       Copy initial # records extended  00016200
         MVC   REPECRDM,INPECRDM       and modified # records extended  00016300
UPDSTA05 DS    0H                                                       00016400
         MVC   REPDATEI,INPDATEI       PRESET OLD INSERT DATE           00016500
         BAL   RE,TIMESTMP                                              00016600
         BAL   RE,USERID                                                00016700
         MVC   REPVERS,INPVERS         ISPF/RPF version (vv) number     00016800
         MVC   REPMOD,INPMOD           ISPF/RPF mod (mm) number         00016900
         CLI   REPMOD,X'63'            Is Mod. level 99?                00017000
         BNL   UPDSTA07                Yes: set to 0 and increase vv    00017100
         XR    R2,R2                   Clear register 2                 00017200
         IC    R2,REPMOD               Insert ISPF mm (mod. lvl)        00017300
         LA    R2,1(,R2)               Increase by 1                    00017400
         STC   R2,REPMOD               And save                         00017500
         B     UPDSTA09                Do not increase ISPF vv          00017600
UPDSTA07 DS    0H                      Increase ISPF Version            00017700
         CLI   REPVERS,X'63'           99 or higher?                    00017800
         BNL   UPDSTA09                Yes: leave VV    unchanged       00017900
         XR    R2,R2                   Clear register 2                 00018000
         IC    R2,REPVERS              Insert VV number                 00018100
         LA    R2,1(,R2)               Increase by 1                    00018200
         STC   R2,REPVERS              And save                         00018300
         XC    REPMOD,REPMOD           Clear modification level (MM)    00018400
UPDSTA09 DS    0H                      Increase ISPF Version            00018500
         MVC   REPMEM,COMMBR           Move member name                 00018600
         MVC   REPTTR,BLDLTTR          Duplicate TTR                    00018700
UPDSTA11 DS    0H                      Increase ISPF Version            00018800
         ZAP   DBW,PUTCNT              # cards                          00018900
         CVB   R2,DBW                  Convert to decimal               00019000
         TM    REPFLGS,REPEXT          Is extended section present?     00019100
         BNO   UPDSTA13                No: use standard line counters   00019200
         ICM   R3,15,REPECRDI          Initial # records extended       00019300
         ICM   R4,15,REPECRDM          # modified records  extended     00019400
         B     UPDSTA15                                                 00019500
UPDSTA13 DS    0H                      Increase ISPF Version            00019600
         XR    R3,R3                   Clear register 3                 00019700
         XR    R4,R4                   Clear register 4                 00019800
         ICM   R3,3,REPCARDI           Initial # records standard       00019900
         ICM   R4,3,REPCARDM           Modified # records standard      00020000
UPDSTA15 DS    0H                      Increase ISPF Version            00020100
         A     R4,MODLINES             + new # modified records         00020200
         CR    R4,R2                   Modified > current # records?    00020300
         BNH   *+6                     No: do no changed modified       00020400
         LR    R4,R2                   Modified never > current         00020500
         C     R2,=F'65535'            Current # more than 64K lines?   00020600
         BH    UPDSTA17                No: use standard line counters   00020700
         C     R3,=F'65535'            Initial # more than 64K lines?   00020800
         BH    UPDSTA17                No: use standard line counters   00020900
         STCM  R2,3,REPCARDS           Current # records non-extended   00021000
         STCM  R3,3,REPCARDI           Initial # records non-extended   00021100
         STCM  R4,3,REPCARDM           Modified # records non-extended  00021200
         NI    REPFLGS,255-REPEXT      No extended section              00021300
         OI    REPC,15                 Set count (length in halfwords)  00021400
         B     UPDRETN                 AND BRANCH                       00021500
UPDSTA17 DS    0H                      Increase ISPF Version            00021600
         XC    REPCARDS(6),REPCARDS    Clear the not extension counters 00021700
         STCM  R2,15,REPECRDS          Current # records in extension   00021800
         STCM  R3,15,REPECRDI          Initial # records in extension   00021900
         STCM  R4,15,REPECRDM          Modified # records in extension  00022000
         OI    REPFLGS,REPEXT          Extended section present         00022100
         OI    REPC,20                 Set count (length in halfwords)  00022200
UPDRETN  L     RE,SAVE01                                                00022300
         BR    RE                                                       00022400
* --------------------------------------------------------------------- 00022500
*   STORE STATUS INFORMATION                                            00022600
* --------------------------------------------------------------------- 00022700
CONSTATS DS    0H                                                       00022800
         ST    RE,SAVE01                                                00022900
         STOW  RPFWORK2,REPAREA,R      Replace directory info           00023000
         MVI   CLOSED,X'80'            Move default option code         00023100
         L     RE,SAVE01                                                00023200
         BR    RE                                                       00023300
* --------------------------------------------------------------------- 00023400
*   CREATE TIMESTAMP                                                    00023500
* --------------------------------------------------------------------- 00023600
TIMESTMP DS    0H                                                       00023700
         ST    RE,SAVE02                                                00023800
* ... 1. SET INSERT DATE ........................................       00023900
         CP    INDATINS,=PL2'0'                                         00024000
         BE    *+4+6                   PARM NOT SET, LEAVE IT           00024100
         ZAP   REPDATEI,INDATINS       ADD PROVIDED INSERT DATE         00024200
         OI    REPDATEI+3,X'0F'        MAKE SIGN ABSOLUTE               00024300
* ... 2. SET LAST CHANGED DATE ..................................       00024400
         CP    INDATCHG,=PL2'0'        PROVIDED VIA PARM                00024500
         BP    RXDATE                  YES, TAKE IT                     00024600
         L     R2,X'4C'                USE SYSTEM DATE: POINTER CVT     00024700
         ZAP   REPDATE,56(4,R2)        Move CVTDATE               @2000 00024800
         B     *+4+6                                                    00024900
RXDATE   ZAP   REPDATE,INDATCHG                                         00025000
         OI    REPDATE+3,X'0F'         Make sign absolute               00025100
         RXPUT VAR=RXREPDATE,VALFLD=REPDATE,VALLEN=4                    00025200
         RXPUT VAR=RXINSDATE,VALFLD=REPDATEI,VALLEN=4                   00025300
* ... 3. SET TIME ...............................................       00025400
         CP    INDATCHG,=PL2'0'                                         00025500
         BP    RXTIME                                                   00025600
         TIME  DEC                     Get time of day                  00025700
         SRL   R0,16                   Shift out fractions of seconds   00025800
         B     SETTIME                                                  00025900
RXTIME   L     R0,INTIME                                                00026000
         SRL   R0,4                    SHIFT OUT PACKED SIGNE           00026100
SETTIME  STCM  R0,3,REPTIME            MOVE TIME IN REPAREA NO SIGN     00026200
         RXPUT VAR=RXREPTIME,VALFLD=REPTIME,VALLEN=2                    00026300
         L     RE,SAVE02                                                00026400
         BR    RE                                                       00026500
* --------------------------------------------------------------------- 00026600
*   SET USERID                                                          00026700
* --------------------------------------------------------------------- 00026800
USERID   DS    0H                                                       00026900
         ST    RE,SAVE02                                                00027000
         MVI   REPUID,C' '             Blank userid +                   00027100
         MVC   REPUID+1(9),REPUID            bytes 28, 29 and 30        00027200
         MVC   REPUID(7),INUSER        MOVE USER ID                     00027300
         L     RE,SAVE02                                                00027400
         BR    RE                                                       00027500
         EJECT                                                          00027600
         LTORG                                                          00027700
MDLWORK  DCB   DDNAME=RXDDNAME,DSORG=PS,MACRF=PM                        00027800
MDLLEN   EQU   *-MDLWORK                                                00027900
MDLWORK2 DCB   DSORG=PO,DDNAME=$$$LMMDD,MACRF=(R,W)                     00028000
MDLLEN2  EQU   *-MDLWORK2                                               00028100
         DS    0F                                                       00028200
         SHVCB DSECT                                                    00028300
RXPDSTAT CSECT                                                          00028400
         WORKAREA                                                       00028500
         DS    CL32                                                     00028600
OUTMSG   DS    CL123                                                    00028700
INDDNAME DS    CL8                     INPUT DDNAME bY REXX             00028800
INMEMBER DS    CL8                     INPUT Member by REXX             00028900
INDATINS DS    PL4                     INSERT DATE BY REXX              00029000
INDATCHG DS    PL4                     CHANGE DATE BY REXX              00029100
INTIME   DS    F                       INPUT TIME BY REXX               00029200
INUSER   DS    CL8                     INPUT USER BY REXX               00029300
INLINO   DS    PL5                     INPUT MEMBER LINE COUNT BY REXX  00029400
RPFWORK  DS    CL(MDLLEN)              Sequential DCB                   00029500
RPFWORK2 DS    CL(MDLLEN2)             PDS DCB                          00029600
BLDLAREA DS    0H                                                       00029700
         DC    AL2(1)                  Retrieve 1 member                00029800
         DC    AL2(76)                 Maximum length of dir entry      00029900
BLDLMEM  DC    CL8' '                                                   00030000
BLDLTTR  DS    XL3                                                      00030100
BLDLKZ   DS    CL2                                                      00030200
BLDLC    DS    X                                                        00030300
BLDLUSER DS    0CL62                   Obtained userdata if present     00030400
INPVERS  DS    C                       ISPF or                          00030500
INPMOD   DS    C                              RPF stats                 00030600
INPFLGS  DS    X                       Flags                            00030700
INPEXT   EQU   32                      Extended part of stats present   00030800
INPSECU  DS    X                       Seconds part of time updated     00030900
INPDATEI DS    PL4                                                @2000 00031000
INPDATE  DS    PL4                                                      00031100
INPTIME  DS    XL2                                                      00031200
INPCARDS DS    XL2                                                      00031300
INPCARDI DS    XL2                                                      00031400
INPCARDM DS    XL2                                                      00031500
INPUID   DS    CL7                                                      00031600
         DS    CL1                     Should be blank                  00031700
INPECRDS DS    XL4                     Current number of records        00031800
INPECRDI DS    XL4                     Initial number of records        00031900
INPECRDM DS    XL4                     Number of records modified       00032000
INPREST  DS    CL22                    Data not from ISPF/RPF           00032100
*                                                                       00032200
REPAREA  DS    0H                      Member entry of STOW macro       00032300
REPMEM   DS    CL8                     with new ISPF or RPF stats       00032400
REPTTR   DS    XL3                                                      00032500
REPC     DS    X                                                        00032600
REPUSER  DS    0CL62                                                    00032700
REPVERS  DS    X                       ISPF vv                          00032800
REPMOD   DS    X                       ISPF mm                          00032900
REPFLGS  DS    X                       Flags                            00033000
REPEXT   EQU   32                      Extended part of stats present   00033100
REPSECU  DS    X                       Seconds part of time updated     00033200
REPDATEI DS    PL4                                                @2000 00033300
REPDATE  DS    PL4                                                      00033400
REPTIME  DS    XL2                                                      00033500
REPCARDS DS    XL2                     Current number of records        00033600
REPCARDI DS    XL2                     Initial number of records        00033700
REPCARDM DS    XL2                     Number of records modified       00033800
REPUID   DS    CL7                                                      00033900
         DS    CL1                     Should be blank                  00034000
REPECRDS DS    XL4                     Current number of records        00034100
REPECRDI DS    XL4                     Initial number of records        00034200
REPECRDM DS    XL4                     Number of records modified       00034300
*                                                                       00034400
SAVEAREA DS    18F                                                      00034500
OPEND    DS    F                       OPEN MF=L                        00034600
CLOSED   DS    F                       CLOSE MF=L                       00034700
DBW      DS    D                                                        00034800
AUTO     DS    C                                                        00034900
MODLINES DS    F                                                        00035000
PUTCNT   DC    PL5'0'                                                   00035100
SCR1MEM  DS    CL8                                                      00035200
SCR2MEM  DS    CL8                                                      00035300
         SHVCB DEFINE                                                   00035400
         WORKEND                                                        00035500
COMMAREA RPFCOMM DSECT=NO                                               00035600
         DS    0D                      FORCE DOUBLEWORD SIZE            00035700
         END                                                            00035800
