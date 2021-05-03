* ....................................................................  00000126
*  SOME INTERNAL MAKROS                                                 00000226
* ....................................................................  00000326
         MACRO                         *                                00000400
&NAME    HVC       &A1,&A2,&A3         *                                00000500
.*       HYPERVISOR CALL                                                00000600
.*       DIAGNOSE INTERFACE TO CP                                       00000700
&NAME    CNOP      0,4                 *                                00000800
         DC        X'83',AL.4(&A1),AL.4(&A2),AL2(&A3)                   00000900
         MEND                          *                                00001000
* ....................................................................  00001127
         MACRO                         *                                00001224
&NAME    TWTO  &MSG                                                     00001324
.*   WTOS IF NECESSARY                                                  00001426
&NAME    DS    0H                                                       00001524
* &NAME    WTO   &MSG                                                   00001624
         MEND                                                           00001724
* ....................................................................  00001827
         MACRO                         *                                00001925
&NAME    SETMSG &MSG,&RC=                                               00002027
.*   MOVE MESSAGE AND PREPARE OUTPUT                                    00002126
&NAME    MVC   CPANSWR(L'&MSG),&MSG SET UP  TO SEND MSG                 00002225
         LA    R5,CPANSWR         POINT TO MSG                          00002327
         AIF   ('&RC' EQ '').NORC                                       00002427
         L     R6,&RC                                                   00002527
         CVD   R6,DBLEWRD         GET RTN CODE IN DEC                   00002627
         UNPK  CPANSWR+L'&MSG.(3),DBLEWRD+6(2) PUT IN RTN CODE          00002727
         OI    CPANSWR+L'&MSG+2,X'F0'          CLEAR SIGN               00002827
         LA    R7,L'&MSG+3        MESSAGE LENGTH                        00002927
         MEXIT                                                          00003027
.NORC    ANOP                                                           00003127
         LA    R7,L'&MSG          MESSAGE LENGTH                        00003227
         MEND                                                           00003327
         MACRO                                                          00003427
         TSTRET &BC,&RC,&RETURN                                         00003527
         &BC   E&SYSNDX           ENSURE IN STORAGE                     00003627
         LA    RF,&RC                                                   00003727
         B     &RETURN                                                  00003827
E&SYSNDX DS    0H                                                       00003927
         MEND                                                           00004027
* --------------------------------------------------------------------  00004100
*  MVS2CP MAIN PROGRAM                                                  00004200
* --------------------------------------------------------------------  00004300
RXCPCMD  MRXSTART A2PLIST=NO      INPUT AREA PROVIDED IN RB             00004410
         ST    RB,INPARM          SAVE INPUT PARAMETERS                 00004506
         TWTO  'RXCPCMD ENTERED'                                        00004624
         BAL   RE,CPINIT          RB SET FOR DSECT                      00004700
         B     *+4(RF)                                                  00004800
         B     CHECKVM                                                  00004900
         B     NOGETS                                                   00005025
         USING CPADSECT,RB        DSECT FOR ANSWER FOR CP COMMAND       00005100
*   SWITCH TO SUPERVISOR MODE                                           00005226
CHECKVM  MODESET   KEY=ZERO,MODE=SUP GET INTO SUPERVISOR MODE           00005300
         STIDP CPUID              CHECK VM THERE                        00005414
         TWTO  'RXCPCMD VM CHECK'                                       00005524
         CLI   CPUID,X'FF'        SET BY VM TO FOXES                    00005620
*        BNE   NOVM               GIVE NASTY MSG AND GET OUT            00005720
*                                                                       00005800
         TWTO  'RXCPCMD READ CP COMMAND'                                00005924
*   FETCH INPUT PARAMETER                                               00006026
         BAL   RE,TSOGET                                                00006114
         TWTO  'RXCPCMD CP COMMAND FETCHED'                             00006224
*   MAKE PROGRAM NOT SWAPPABLE                                          00006326
         SYSEVENT DONTSWAP        STAY IN STORAGE                       00006400
*   FIX I/O PAGES                                                       00006526
         TWTO  'RXCPCMD FIX MVS/VM I/O AREA'                            00006624
         LA    R1,CPCMND          SPECIFY ADDRS TO FIX                  00006714
         BAL   RE,FIXPAGE                                               00006800
         LA    R1,CPANSWR         SPECIFY ADDRS TO FIX                  00006914
         BAL   RE,FIXPAGE                                               00007000
         TWTO  'RXCPCMD FIX COMPLETED'                                  00007124
         TWTO  'RXCPCMD SEND COMMAND TO VM'                             00007224
*   SEND COMMAND TO VM                                                  00007326
         LA    R5,CPANSWR         POINT TO MSG                          00007418
         LA    R7,L'OKMSG+3       LENGTH                                00007518
         BAL   RE,SEND2VM         SEND VM COMMAND                       00007619
         B     *+4(RF)                                                  00007700
         B     OUTMSG             RF=0   RC=0, MESSAGE RECEIVED         00007824
         B     OKREPLY            RF=4   RC=0, NO MESSAGE RECEIVED      00007924
         B     BADCMND            RF=8   RC=8, INVALID CP COMMAND       00008024
         B     NOREALS            RF=12  RC=12, NO REAL ADDR FOR CMD    00008125
         B     NOREALS            RF=16  RC=16, NO REAL ADDR FOR ANSWER 00008225
*   OUTPUT RESULTS OF VM CALL                                           00008326
OUTMSG   DS    0H                                                       00008424
         TWTO  'RXCPCMD VM RC=0, REPLY RECEIVED'                        00008524
         BAL   RE,OUTPUT                                                00008624
         B     OKRESULT                                                 00008724
*   THERE WERE NO RESULTS PROVIDED                                      00008826
OKREPLY  TWTO  'RXCPCMD VM RC=0, NO REPLY RECEIVED'                     00008924
OKRESULT LA    R1,0                                                     00009024
         ST    R1,PGMRC                                                 00009100
         SETMSG OKMSG,RC=VMRC     BUILD OK MSG                          00009227
*                                                                       00009326
*   PREPARE RE NO RESULTS PROVIDED                                      00009426
PAGEFREE LA    R8,CPCMND          FREE THE COMMAND                      00009500
         TWTO  'RXCPCMD DETACH FIXED MVS/VM I/O AREA'                   00009624
         PGFREE   R,A=(R8)        FREE STORAGE                          00009700
         LA       R8,CPANSWR      FREE THE RESPONSE                     00009800
         PGFREE   R,A=(R8)        FREE STORAGE                          00009900
         SYSEVENT OKSWAP          NOT CRITICAL  TO STAY ANYMORE         00010000
*                                                                       00010100
CPEXIT   MODESET KEY=NZERO,MODE=PROB  BACK TO PROBLEM MODE              00010214
         TWTO  'RXCPCMD OUTPUT MESSAGE(S)'                              00010324
         BAL   RE,OUTLINE         OUTPUT CP MESSAGE                     00010414
         TWTO  'RXCPCMD RELEASE STORAGE'                                00010524
RETURN   FREEMAIN  RU,            MUST FREE ANSWER AREA                X00010600
               A=(RB),            DSECT BASE REG                       X00010700
               LV=4096            FULL PAGE                             00010800
         TWTO  'RXCPCMD EXIT PROGRAM'                                   00010924
         L     RF,PGMRC                                                 00011000
         LR    RF,R5              RESTORE RETURN CODE                   00011114
         MRXEXIT                                                        00011202
* --------------------------------------------------------------------  00011300
*  ERROR HANDLING                                                       00011400
* --------------------------------------------------------------------  00011500
NOVM     TWTO  'RXCPCMD NO VM ACTIVE'                                   00011625
         LA    R1,4                                                     00011725
         ST    R1,PGMRC                                                 00011825
         SETMSG NOVMMSG                                                 00011925
         B     CPEXIT             GO SEND AND GET OUT                   00012014
*                                                                       00012100
NOVMRSP  TWTO  'RXCPCMD NO VM RESPONSE'                                 00012226
         SETMSG NOVMRES                                                 00012325
         B     PAGEFREE           GO SEND MSG AND FINISH                00012418
*                                                                       00012518
BADCMND  LA    R1,8                                                     00012626
         ST    R1,PGMRC                                                 00012725
         TWTO  'RXCPCMD BAD COMMAND'                                    00012827
         SETMSG CMDMSG,RC=VMRC                                          00012927
         B     PAGEFREE           GO SEND MSG AND FINISH                00013000
*                                                                       00013100
NOGETS   LA    R1,12                                                    00013225
         ST    R1,PGMRC                                                 00013325
         TWTO  'RXCPCMD ABEND2'                                         00013424
         SETMSG NOGETM                                                  00013525
         B     PAGEFREE                                                 00013600
*                                                                       00013700
NOREALS  LA    R1,16                                                    00013825
         ST    R1,PGMRC                                                 00013925
         TWTO  'RXCPCMD ABEND3'                                         00014024
         SETMSG NOREAL                                                  00014127
         B     PAGEFREE                                                 00014200
*                                                                       00014300
* --------------------------------------------------------------------  00014400
* FETCH TSO PARAMETER                                                   00014500
* --------------------------------------------------------------------  00014600
TSOGET   ST    RE,SAVE01                                                00014715
* INT CPCOMMAND(VOID *UPTPTR, VOID *ECTPTR, CHAR *CMDSTR, INT CMDLEN);  00014806
*               0(R11)        4(R11)        8(12)         12(R11)       00014906
         L     R6,INPARM      LOAD R1 REGISTER OF ENTRY                 00015014
         L     R4,8(R6)       BUFF ADDRESS                              00015114
         L     R6,12(R6)      LENGTH OF BUFFER IN R6                    00015214
*                                                                       00015300
         LTR   R6,R6          IS LENGTH ZERO                            00015414
         BNP   DEFAULTC       NO COMMAND SPECIFIED                      00015514
         EX    R6,MVCCMD      MOVE CP COMMAND TO OUR STORAGE            00015614
*  STRIP OFF TRAILING BLANKS, RE-CALCULATE DATA LENGTH                  00015700
NXTBYTE  LA    R2,CPCMND(R6)  STRIP OFF TRAILING BLANKS                 00015814
         CLI   0(R2),C' '                                               00015914
         BE    NXTCHAR                                                  00016021
         CLI   0(R2),X'00'                                              00016121
         BNE   TSORET                                                   00016224
         MVI   0(R2),C' '                                               00016324
NXTCHAR  BCT   R6,NXTBYTE                                               00016421
*  LENGTH HAS BECOME ZERO, USE DEFAULT                                  00016500
DEFAULTC MVC   CPCMND(5),=C'Q T'   DEFAULT COMMAND                      00016620
         LA    R6,2           LENGTH OF DEFAULT - 1                     00016714
TSORET   ST    R6,CMDLEN      STORE LENGTH FOR LATER USE                00016814
* ..... ECHO THE REQUESTED CP COMMAND ...................               00016914
         B     SKIP                                                     00017015
         EX    R6,EXECHO      SET UP  TO SEND MSG                       00017114
         LA    R5,CPANSWR     ADDRESS OF ECHO MSG                       00017214
         LR    R7,R6          LENGTH                                    00017314
         BAL   RE,OUTLINE                                               00017414
SKIP     L     RE,SAVE01                                                00017515
         BR    RE                                                       00017614
MVCCMD   MVC   CPCMND(0),0(R4)  MOVE COMMAND OUT                        00017715
EXECHO   MVC   CPANSWR(0),CPCMND                                        00017814
* --------------------------------------------------------------------  00017900
*  COMMAND IS NOW SET UP IN OUR AREA AND CMDLEN IS LENGTH - 1           00018000
* --------------------------------------------------------------------  00018100
SEND2VM  ST    RE,SAVE01                                                00018219
         L     R6,CMDLEN          MAKE CP COMMAND UPPER CASE            00018300
         EX    R6,UPCASE          MAKE CP COMMAND UPPER CASE            00018400
         LRA   R4,CPCMND          GET REAL ADDR OF COMMAND              00018500
         TSTRET BZ,12,CALLRET     TEST WITH BZ, ELSE RC=12              00018627
         LA    R6,1(,R6)          ADD 1 FOR CORRECT LENGTH              00018727
         ICM   R6,8,BLANKS        FLAG BYTE ON TOP OF LENGTH            00018800
         LRA   R5,CPANSWR         REAL ADDR OF ANSWER AREA              00018900
         TSTRET BZ,16,CALLRET     TEST WITH BZ, ELSE RC=16              00019027
         L     R7,LANSWER         LENGTH OF ANSWER AREA                 00019127
         HVC   R4,R6,8            DO CP COMMAND                         00019200
         STM   R4,R7,CPRETURN     SAVE REGS FROM CP FOR DUMP            00019300
         BZ    *+8                CC1 SET IF OVERFLOW                   00019400
         L     R7,LANSWER         RESET TO 4K IF NECESSARY              00019527
*  POST PROCESSING OF HOST CALL                                         00019627
         ST    R6,VMRC            SAVE VM RETURN CODE                   00019726
         LTR   R6,R6              CHECK RTN CODE FROM CP                00019800
         TSTRET BZ,8,CALLRET      TEST WITH BZ, ELSE RC=8               00019927
         LTR   R7,R7              CHECK LENGTH OF ANSWER FROM CP        00020027
         TSTRET BP,4,CALLRET      TEST WITH BP, ELSE RC=4               00020127
         LA    RF,0               MESSAGE RECEIVED                      00020227
         ST    R7,CPMSLEN         GET VIRT ADDR OF ANSWER               00020324
CALLRET  L     RE,SAVE01                                                00020400
         BR    RE                                                       00020500
UPCASE   OC    CPCMND(0),BLANKS   CONVERT CP COMMAND TO CAPS            00020624
* --------------------------------------------------------------------  00020700
* OUTPUT RESULT OF CP COMMAND                                           00020800
*   R7 <- LENGTH OF STRING                                              00020914
* --------------------------------------------------------------------  00021000
OUTPUT   ST    RE,SAVE01                                                00021100
         L     R7,CPMSLEN         GET VIRT ADDR OF ANSWER               00021224
         LA    R3,CPANSWR         GET VIRT ADDR OF ANSWER               00021324
         LR    R4,R7              CHECK AGAINST MAX POSSIBLE            00021415
         C     R4,LANSWER         CHECK AGAINST MAX POSSIBLE            00021515
         BNH   *+8                IT'S OK                               00021600
         L     R4,LANSWER         CHECK AGAINST MAX POSSIBLE            00021715
         LA    R5,PUTMSG          ADDRESS PUTLINE                       00021815
         XR    R7,R7                                                    00021915
NEXTC    CLI   0(R3),X'15'                                              00022015
         BE    LINBREAK                                                 00022115
         CLI   0(R3),X'25'                                              00022224
         BE    LINBREAK                                                 00022324
         MVC   0(1,R5),0(R3)                                            00022415
         LA    R5,1(R5)                                                 00022515
         LA    R7,1(R7)                                                 00022615
         LA    R3,1(R3)                                                 00022715
         CH    R7,=AL2(80)                                              00022815
         BE    LINOVL                                                   00022915
         BCT   R4,NEXTC                                                 00023015
         LA    R5,PUTMSG                                                00023115
         BAL   RE,OUTLINE         GO WRITE OUT                          00023215
         B     OUTRET                                                   00023315
LINBREAK DS    0H                                                       00023415
         LA    R3,1(R3)                                                 00023515
LINOVL   LA    R5,PUTMSG                                                00023615
         BAL   RE,OUTLINE         GO WRITE OUT                          00023715
         XR    R7,R7                                                    00023815
         BCT   R4,NEXTC                                                 00023915
OUTRET   L     RE,SAVE01                                                00024000
         BR    RE                                                       00024100
* --------------------------------------------------------------------  00024200
* OUTPUT A SINGLE LINE OF THE CP COMMAND RESULT                         00024300
*   R5 <- POINTER TO DATA TO PRINT                                      00024400
*   R7 <- LENGTH OF DATA TO PRINT                                       00024500
* --------------------------------------------------------------------  00024600
OUTLINE  ST    RE,SAVE02               *WRITE THE LINE                  00024714
         LTR   R7,R7              ZERO LENGTH?                          00024800
         BNPR  RE                 GET OUT IF SO                         00024900
*        TPUT  (R5),(R7),EDIT     CP SETS CURRENT LNTH IN R7            00025000
         L     R8,UPTADR          LOAD UPT ADDRESS                      00025100
         L     R9,ECTADR          LOAD ECT ADDRESS                      00025200
         XC    ECBADR,ECBADR      INITIALISE ECB                        00025300
         LA    R1,4(R7)           LOAD PUTLINE LENGTH +4 FOR ...        00025400
         STH   R1,MSGLEN          PUTLINE HEADER, SAVE IT               00025500
         BCTR  R7,0               -1 FOR EX MVC                         00025600
         EX    R7,EXMVC           MOVE CP OUTPUT LINE TO MESSAGE AREA   00025700
         PUTLINE PARM=PUTBLOCK,UPT=(R8),ECT=(R9),ECB=ECBADR,           X00025824
               OUTPUT=(MESSAGE,TERM,SINGLE,DATA),                      X00025924
               MF=(E,IOPLADS)                                           00026000
         L     RE,SAVE02                                                00026100
         BR    RE                 RETURN                                00026200
EXMVC    MVC   MSGTEXT(0),0(R5)   MOVE COMMAND OUT                      00026300
* --------------------------------------------------------------------  00026400
* FIX REQUEST PAGE IN STORAGE                                           00026500
* --------------------------------------------------------------------  00026600
FIXPAGE  ST    RE,SAVE01                                                00026700
         XC    PGECB,PGECB        CLEAR ECB                             00026824
         PGFIX R,                 WIRE DOWN PGM                        X00026924
               A=(R1),            START AT BEGINNING OF COMMAND        X00027024
               LONG=N,            SHORT TERM FIX                       X00027100
               ECB=PGECB          POST WHEN DONE                        00027200
         WAIT  ECB=PGECB          DONE.                                 00027300
         L     RE,SAVE01                                                00027400
         BR    RE                                                       00027500
* --------------------------------------------------------------------  00027600
* INIT PROGRAM                                                          00027700
*      GET STORAGE FOR  ANSWR AREA - VM REQUIRES REAL STORAGE ADDRESS   00027800
*      THERE IS NO WAY TO GET CONTIGUOUS REAL ADDRESSES                 00027900
*      SO...  MAXIMUM REPLY FROM VM MUST BE 4K                          00028000
* --------------------------------------------------------------------  00028100
CPINIT   DS    0H                                                       00028200
         ST    RE,SAVE01                                                00028300
         L     R6,INPARM           LOAD R1 REGISTER OF ENTRY            00028415
         MVC   UPTADR,0(R6)        FETCH UPT ADDRESS FOR PUTLINE        00028515
         MVC   ECTADR,4(R6)        FETCH ECT ADDRESS FOR PUTLINE        00028615
         GETMAIN RU,BNDRY=PAGE,LV=4096 ON   PAGE BOUNDRY, FULL PAGE     00028700
         LA    RF,4                                                     00028800
         LTR   R1,R1               ADDRESS CAN'T BE ZERO                00028900
         BZ    NOSTOR              MUST BE PROBLEM                      00029000
         LR    RB,R1               SET UP BASE REG FOR DSECT            00029100
         LA    RF,0                                                     00029200
NOSTOR   L     RE,SAVE01                                                00029300
         BR    RE                                                       00029400
*                                      *                                00029500
********                               *                                00029600
*                                      *                                00029700
         LTORG                        ANY LITERALS                      00029800
         EJECT                                                          00029900
*                                                                       00030000
ECBADR   DS    F                                                        00030100
UPTADR   DS    F                                                        00030200
ECTADR   DS    F                                                        00030300
PUTBLOCK PUTLINE MF=L                                                   00030400
MESSAGE  DS    0H                 MESAGE PUTLINE FORMAT                 00030500
MSGLEN   DS    H                  LENGTH OF OUTPUT LINE                 00030600
         DC    H'0'               RESERVED                              00030700
MSGTEXT  DS    CL79               MESSAGE TEXT                          00030800
INPARM   DS    A                                                        00030900
SAVE01   DS    A                                                        00031000
SAVE02   DS    A                                                        00031100
*                                                                       00031200
IOPLADS  DC    4F'0'                                                    00031300
CPRETURN DC    2D'0'              SAVE RETURN REGS FROM CP HERE         00031400
CPUID    DC    D'0'               CPU IDENT TO ENSURE VM THERE          00031500
DBLEWRD  DC    D'0'               TEMP FOR DECIMAL CONVERSIONS          00031600
PGECB    DC    F'0'               POSTED WHEN PAGEFIX DONE              00031700
LANSWER  DC    A(4096)            LENGTH OF RESPONSE AREA               00031800
CPMSLEN  DS    A                  REAL LENGTH OF RETURNED CP MESSAGE    00031924
CMDLEN   DS    A                  COMMAND LENGTH                        00032024
PGMRC    DS    A                  PROGRAM RETURN CODE                   00032126
VMRC     DS    A                  RETURN VM RETURN CODE                 00032226
PUTMSG   DS    CL132                                                    00032315
         DC    C'***** CPCMND *****'                                    00032415
CPCMND   DC    CL132' '           CP COMMAND TO BE DONE                 00032515
         DC    CL32' '                                                  00032624
BLANKS   DC    CL132' '           FOR CONVERTING TO CAPS                00032715
*                                                                       00032800
NOVMMSG  DC    C'VM NOT ACTIVE. CPCMD TERMINATING'                      00032915
NOVMRES  DC    C'VM HAS NOT RESPONDED. CPCMD TERMINATING'               00033018
NOREAL   DC    C'REAL STORAGE CANNOT DETERMINED, CPCMD TERMINATING'     00033125
NOGETM   DC    C'GETMAIN OF FIXED STORAGE FAILED, CPCMD TERMINATING'    00033225
CMDMSG   DC    C'COMMAND ERROR .. RETURN CODE FROM CP = '               00033315
OKMSG    DC    C'COMMAND COMPLETE. RC = '                               00033415
*                                                                       00033500
         DS    0D                                                       00033615
********                                                                00033700
********                                                                00033800
CPADSECT DSECT     ,              PAGE FOR THE ANSWER FROM CP           00033900
CPANSWR  DS     4096C             RESPONSE FROM CP                      00034015
********                                                                00034100
         IHAPSA    ,              DEFINE LOW STORAGE                    00034200
         IHAASCB   ,              DEFINE ADDR SPACE CTL BLOCK           00034300
         COPY  MRXREGS                                                  00034403
         END                                                            00034500
