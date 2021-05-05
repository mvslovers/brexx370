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
         MACRO                         *                                00001231
&NAME    SETRC &RC                                                      00001331
&NAME    LA    R0,&RC                                                   00001431
         ST    R0,PGMRC                                                 00001531
         MEND                          *                                00001631
* ....................................................................  00001731
         MACRO                         *                                00001824
&NAME    TWTO  &MSG                                                     00001924
         GBLA  &WTO                                                     00002031
         AIF   ('&WTO' NE '1').NOWTO                                    00002131
&NAME    WTO   &MSG                                                     00002231
         MEXIT                                                          00002331
.NOWTO   ANOP                                                           00002431
         AIF   ('&NAME' EQ '').NONAME                                   00002531
&NAME    DS    0H                                                       00002631
.NONAME  ANOP                                                           00002731
         MEND                                                           00002824
* ....................................................................  00002927
         MACRO                         *                                00003025
&NAME    SETMSG &MSG,&RC=                                               00003127
.*   MOVE MESSAGE AND PREPARE OUTPUT                                    00003226
&NAME    MVC   CPANSWR(L'&MSG),&MSG SET UP  TO SEND MSG                 00003325
         LA    R5,CPANSWR         POINT TO MSG                          00003427
         AIF   ('&RC' EQ '').NORC                                       00003527
         L     R6,&RC                                                   00003627
         CVD   R6,DBLEWRD         GET RTN CODE IN DEC                   00003727
         UNPK  CPANSWR+L'&MSG.(3),DBLEWRD+6(2) PUT IN RTN CODE          00003827
         OI    CPANSWR+L'&MSG+2,X'F0'          CLEAR SIGN               00003927
         LA    R7,L'&MSG+3        MESSAGE LENGTH                        00004027
         MEXIT                                                          00004127
.NORC    ANOP                                                           00004227
         LA    R7,L'&MSG          MESSAGE LENGTH                        00004327
         MEND                                                           00004427
         MACRO                                                          00004527
         TSTRET &BC,&RC,&RETURN                                         00004627
         &BC   E&SYSNDX           ENSURE IN STORAGE                     00004727
         LA    RF,&RC                                                   00004827
         B     &RETURN                                                  00004927
E&SYSNDX DS    0H                                                       00005027
         MEND                                                           00005127
* ....................................................................  00005231
         GBLA     &WTO                                                  00005331
&WTO     SETA      0                                                    00005431
         PRINT GEN                                                      00005531
* --------------------------------------------------------------------  00005600
*  MVS2CP MAIN PROGRAM                                                  00005700
* --------------------------------------------------------------------  00005800
RXCPCMD  MRXSTART A2PLIST=NO      INPUT AREA PROVIDED IN RB             00005910
         ST    RB,INPARM          SAVE INPUT PARAMETERS                 00006006
         TWTO  'RXCPCMD ENTERED'                                        00006124
         BAL   RE,CPINIT          RB SET FOR DSECT                      00006200
         B     *+4(RF)                                                  00006300
         B     CHECKVM                                                  00006400
         B     NOGETS                                                   00006525
         USING CPADSECT,RB        DSECT FOR ANSWER FOR CP COMMAND       00006600
* ... SWITCH TO SUPERVISOR MODE                                         00006733
CHECKVM  MODESET   KEY=ZERO,MODE=SUP GET INTO SUPERVISOR MODE           00006800
         STIDP CPUID              CHECK VM THERE                        00006914
         TWTO  'RXCPCMD VM CHECK'                                       00007024
         CLI   CPUID,X'FF'        SET BY VM TO FOXES                    00007120
*        BNE   NOVM               GIVE NASTY MSG AND GET OUT            00007220
*                                                                       00007300
         TWTO  'RXCPCMD READ CP COMMAND'                                00007424
* ... FETCH INPUT PARAMETER                                             00007533
         BAL   RE,TSOGET                                                00007614
         TWTO  'RXCPCMD CP COMMAND FETCHED'                             00007724
* ... MAKE PROGRAM NOT SWAPPABLE                                        00007833
         SYSEVENT DONTSWAP        STAY IN STORAGE                       00007900
* ... FIX I/O PAGES                                                     00008033
         TWTO  'RXCPCMD FIX MVS/VM I/O AREA'                            00008124
         LA    R1,CPCMND          SPECIFY ADDRS TO FIX                  00008214
         BAL   RE,FIXPAGE                                               00008300
         LA    R1,CPANSWR         SPECIFY ADDRS TO FIX                  00008414
         BAL   RE,FIXPAGE                                               00008500
         TWTO  'RXCPCMD FIX COMPLETED'                                  00008624
         TWTO  'RXCPCMD SEND COMMAND TO VM'                             00008724
* ... SEND COMMAND TO VM                                                00008833
         LA    R5,CPANSWR         POINT TO MSG                          00008918
         LA    R7,L'OKMSG+3       LENGTH                                00009018
         BAL   RE,SEND2VM         SEND VM COMMAND                       00009119
         B     *+4(RF)                                                  00009200
         B     OUTMSG             RF=0   RC=0, MESSAGE RECEIVED         00009324
         B     OKREPLY            RF=4   RC=0, NO MESSAGE RECEIVED      00009424
         B     BADCMND            RF=8   RC=8, INVALID CP COMMAND       00009524
         B     NOREALS            RF=12  RC=12, NO REAL ADDR FOR CMD    00009625
         B     NOREALS            RF=16  RC=16, NO REAL ADDR FOR ANSWER 00009725
* ... OUTPUT RESULTS OF VM CALL                                         00009833
OUTMSG   DS    0H                                                       00009924
         TWTO  'RXCPCMD VM RC=0, REPLY RECEIVED'                        00010024
         BAL   RE,OUTPUT                                                00010124
         B     OKRESULT                                                 00010224
* ... THERE WERE NO RESULTS PROVIDED                                    00010333
OKREPLY  TWTO  'RXCPCMD VM RC=0, NO REPLY RECEIVED'                     00010424
* ... RETURN CODE 0  .................................................  00010533
OKRESULT SETRC 0                                                        00010631
         SETMSG OKMSG,RC=VMRC     BUILD OK MSG                          00010727
*                                                                       00010826
* ... PREPARE RE NO RESULTS PROVIDED                                    00010933
PAGEFREE LA    R8,CPCMND          FREE THE COMMAND                      00011000
         TWTO  'RXCPCMD DETACH FIXED MVS/VM I/O AREA'                   00011124
         PGFREE R,A=(R8)          FREE STORAGE                          00011233
         LA     R8,CPANSWR        FREE THE RESPONSE                     00011333
         PGFREE R,A=(R8)          FREE STORAGE                          00011433
         SYSEVENT OKSWAP          NOT CRITICAL  TO STAY ANYMORE         00011500
*                                                                       00011600
CPEXIT   MODESET KEY=NZERO,MODE=PROB  BACK TO PROBLEM MODE              00011714
         TWTO  'RXCPCMD OUTPUT MESSAGE(S)'                              00011824
* ... OUTPUT MESSAGE SET BY SETMSG                                      00011933
         BAL   RE,OUTLINE         OUTPUT CP MESSAGE                     00012014
         TWTO  'RXCPCMD RELEASE STORAGE'                                00012124
RETURN   FREEMAIN  RU,            MUST FREE ANSWER AREA                X00012200
               A=(RB),            DSECT BASE REG                       X00012300
               LV=4096            FULL PAGE                             00012400
         TWTO  'RXCPCMD EXIT PROGRAM'                                   00012524
         L     RF,PGMRC                                                 00012600
         MRXEXIT                                                        00012702
* --------------------------------------------------------------------  00012800
*  ERROR HANDLING                                                       00012900
* --------------------------------------------------------------------  00013000
* ... RETURN CODE 8  .................................................  00013133
BADCMND  SETRC 8                                                        00013231
         TWTO  'RXCPCMD BAD COMMAND'                                    00013327
         SETMSG CMDMSG,RC=VMRC                                          00013427
         B     PAGEFREE           GO SEND MSG AND FINISH                00013500
* ... RETURN CODE 12 .................................................  00013633
NOGETS   SETRC 12                                                       00013731
         TWTO  'RXCPCMD ABEND2'                                         00013824
         SETMSG NOGETM                                                  00013925
         B     PAGEFREE                                                 00014000
* ... RETURN CODE 16 .................................................  00014133
NOREALS  SETRC 16                                                       00014231
         TWTO  'RXCPCMD ABEND3'                                         00014324
         SETMSG NOREAL                                                  00014427
         B     PAGEFREE                                                 00014500
* ... RETURN CODE 20 .................................................  00014633
NOVM     SETRC 20                                                       00014732
         TWTO  'RXCPCMD NO VM ACTIVE'                                   00014832
         SETMSG NOVMMSG                                                 00014932
         B     CPEXIT             GO SEND AND GET OUT                   00015032
* ... RETURN CODE 24 .................................................  00015133
NOVMRSP  SETRC 24                                                       00015232
         TWTO  'RXCPCMD NO VM RESPONSE'                                 00015332
         SETMSG NOVMRES                                                 00015432
         B     PAGEFREE           GO SEND MSG AND FINISH                00015532
*                                                                       00015600
* --------------------------------------------------------------------  00015700
* FETCH TSO PARAMETER                                                   00015800
* --------------------------------------------------------------------  00015900
TSOGET   ST    RE,SAVE01                                                00016015
* ... C-CALL PARAMETERS                                                 00016133
* INT CPCOMMAND(VOID *UPTPTR, VOID *ECTPTR, CHAR *CMDSTR, INT CMDLEN);  00016206
*               0(R11)        4(R11)        8(12)         12(R11)       00016306
         L     R6,INPARM      LOAD R1 REGISTER OF ENTRY                 00016414
         L     R4,8(R6)       BUFF ADDRESS                              00016514
         L     R6,12(R6)      LENGTH OF BUFFER IN R6                    00016614
*                                                                       00016700
         LTR   R6,R6          IS LENGTH ZERO                            00016814
         BNP   DEFAULTC       NO COMMAND SPECIFIED                      00016914
         EX    R6,MVCCMD      MOVE CP COMMAND TO OUR STORAGE            00017014
* ... STRIP OFF TRAILING BLANKS, RE-CALCULATE DATA LENGTH               00017133
NXTBYTE  LA    R2,CPCMND(R6)  STRIP OFF TRAILING BLANKS                 00017214
         CLI   0(R2),C' '                                               00017314
         BE    NXTCHAR                                                  00017421
         CLI   0(R2),X'00'                                              00017521
         BNE   TSORET                                                   00017624
         MVI   0(R2),C' '                                               00017724
NXTCHAR  BCT   R6,NXTBYTE                                               00017821
* ... LENGTH HAS BECOME ZERO, USE DEFAULT                               00017933
DEFAULTC MVC   CPCMND(5),=C'Q T'   DEFAULT COMMAND                      00018020
         LA    R6,2           LENGTH OF DEFAULT - 1                     00018114
TSORET   ST    R6,CMDLEN      STORE LENGTH FOR LATER USE                00018214
* ... ECHO THE REQUESTED CP COMMAND ...................                 00018333
         B     SKIP                                                     00018415
         EX    R6,EXECHO      SET UP  TO SEND MSG                       00018514
         LA    R5,CPANSWR     ADDRESS OF ECHO MSG                       00018614
         LR    R7,R6          LENGTH                                    00018714
         BAL   RE,OUTLINE                                               00018814
SKIP     L     RE,SAVE01                                                00018915
         BR    RE                                                       00019014
MVCCMD   MVC   CPCMND(0),0(R4)  MOVE COMMAND OUT                        00019115
EXECHO   MVC   CPANSWR(0),CPCMND                                        00019214
* --------------------------------------------------------------------  00019300
*  COMMAND IS NOW SET UP IN OUR AREA AND CMDLEN IS LENGTH - 1           00019400
* --------------------------------------------------------------------  00019500
SEND2VM  ST    RE,SAVE01                                                00019619
         L     R6,CMDLEN          MAKE CP COMMAND UPPER CASE            00019700
         EX    R6,UPCASE          MAKE CP COMMAND UPPER CASE            00019800
         LRA   R4,CPCMND          GET REAL ADDR OF COMMAND              00019900
         TSTRET BZ,12,CALLRET     TEST WITH BZ, ELSE RC=12              00020027
         LA    R6,1(,R6)          ADD 1 FOR CORRECT LENGTH              00020127
         ICM   R6,8,BLANKS        FLAG BYTE ON TOP OF LENGTH            00020200
         LRA   R5,CPANSWR         REAL ADDR OF ANSWER AREA              00020300
         TSTRET BZ,16,CALLRET     TEST WITH BZ, ELSE RC=16              00020427
         L     R7,LANSWER         LENGTH OF ANSWER AREA                 00020527
         HVC   R4,R6,8            DO CP COMMAND                         00020600
         STM   R4,R7,CPRETURN     SAVE REGS FROM CP FOR DUMP            00020700
         BZ    *+8                CC1 SET IF OVERFLOW                   00020800
         L     R7,LANSWER         RESET TO 4K IF NECESSARY              00020927
* ... POST PROCESSING OF HOST CALL                                      00021033
         ST    R6,VMRC            SAVE VM RETURN CODE                   00021126
         LTR   R6,R6              CHECK RTN CODE FROM CP                00021200
         TSTRET BZ,8,CALLRET      TEST WITH BZ, ELSE RC=8               00021327
         LTR   R7,R7              CHECK LENGTH OF ANSWER FROM CP        00021427
         TSTRET BP,4,CALLRET      TEST WITH BP, ELSE RC=4               00021527
         LA    RF,0               MESSAGE RECEIVED                      00021627
         ST    R7,CPMSLEN         GET VIRT ADDR OF ANSWER               00021724
CALLRET  L     RE,SAVE01                                                00021800
         BR    RE                                                       00021900
UPCASE   OC    CPCMND(0),BLANKS   CONVERT CP COMMAND TO CAPS            00022024
* --------------------------------------------------------------------  00022100
* OUTPUT RESULT OF CP COMMAND                                           00022200
*   R7 <- LENGTH OF STRING                                              00022314
* --------------------------------------------------------------------  00022400
OUTPUT   ST    RE,SAVE01                                                00022500
         L     R7,CPMSLEN         GET VIRT ADDR OF ANSWER               00022624
         LA    R3,CPANSWR         GET VIRT ADDR OF ANSWER               00022724
         LR    R4,R7              CHECK AGAINST MAX POSSIBLE            00022815
         C     R4,LANSWER         CHECK AGAINST MAX POSSIBLE            00022915
         BNH   *+8                IT'S OK                               00023000
         L     R4,LANSWER         CHECK AGAINST MAX POSSIBLE            00023115
         LA    R5,PUTMSG          ADDRESS PUTLINE                       00023215
         XR    R7,R7                                                    00023315
NEXTC    CLI   0(R3),X'15'                                              00023415
         BE    LINBREAK                                                 00023515
         CLI   0(R3),X'25'                                              00023624
         BE    LINBREAK                                                 00023724
         MVC   0(1,R5),0(R3)                                            00023815
         LA    R5,1(R5)                                                 00023915
         LA    R7,1(R7)                                                 00024015
         LA    R3,1(R3)                                                 00024115
         CH    R7,=AL2(80)                                              00024215
         BE    LINOVL                                                   00024315
         BCT   R4,NEXTC                                                 00024415
         LA    R5,PUTMSG                                                00024515
         BAL   RE,OUTLINE         GO WRITE OUT                          00024615
         B     OUTRET                                                   00024715
LINBREAK DS    0H                                                       00024815
         LA    R3,1(R3)                                                 00024915
LINOVL   LA    R5,PUTMSG                                                00025015
         BAL   RE,OUTLINE         GO WRITE OUT                          00025115
         XR    R7,R7                                                    00025215
         BCT   R4,NEXTC                                                 00025315
OUTRET   L     RE,SAVE01                                                00025400
         BR    RE                                                       00025500
* --------------------------------------------------------------------  00025600
* OUTPUT A SINGLE LINE OF THE CP COMMAND RESULT                         00025700
*   R5 <- POINTER TO DATA TO PRINT                                      00025800
*   R7 <- LENGTH OF DATA TO PRINT                                       00025900
* --------------------------------------------------------------------  00026000
OUTLINE  ST    RE,SAVE02               *WRITE THE LINE                  00026114
         LTR   R7,R7              ZERO LENGTH?                          00026200
         BNPR  RE                 GET OUT IF SO                         00026300
*        TPUT  (R5),(R7),EDIT     CP SETS CURRENT LNTH IN R7            00026400
         L     R8,UPTADR          LOAD UPT ADDRESS                      00026500
         L     R9,ECTADR          LOAD ECT ADDRESS                      00026600
         XC    ECBADR,ECBADR      INITIALISE ECB                        00026700
         LA    R1,4(R7)           LOAD PUTLINE LENGTH +4 FOR ...        00026800
         STH   R1,MSGLEN          PUTLINE HEADER, SAVE IT               00026900
         BCTR  R7,0               -1 FOR EX MVC                         00027000
         EX    R7,EXMVC           MOVE CP OUTPUT LINE TO MESSAGE AREA   00027100
         PUTLINE PARM=PUTBLOCK,UPT=(R8),ECT=(R9),ECB=ECBADR,           X00027224
               OUTPUT=(MESSAGE,TERM,SINGLE,DATA),                      X00027324
               MF=(E,IOPLADS)                                           00027400
         L     RE,SAVE02                                                00027500
         BR    RE                 RETURN                                00027600
EXMVC    MVC   MSGTEXT(0),0(R5)   MOVE COMMAND OUT                      00027700
* --------------------------------------------------------------------  00027800
* FIX REQUEST PAGE IN STORAGE                                           00027900
* --------------------------------------------------------------------  00028000
FIXPAGE  ST    RE,SAVE01                                                00028100
         XC    PGECB,PGECB        CLEAR ECB                             00028224
         PGFIX R,                 WIRE DOWN PGM                        X00028324
               A=(R1),            START AT BEGINNING OF COMMAND        X00028424
               LONG=N,            SHORT TERM FIX                       X00028500
               ECB=PGECB          POST WHEN DONE                        00028600
         WAIT  ECB=PGECB          DONE.                                 00028700
         L     RE,SAVE01                                                00028800
         BR    RE                                                       00028900
* --------------------------------------------------------------------  00029000
* INIT PROGRAM                                                          00029100
*      GET STORAGE FOR  ANSWR AREA - VM REQUIRES REAL STORAGE ADDRESS   00029200
*      THERE IS NO WAY TO GET CONTIGUOUS REAL ADDRESSES                 00029300
*      SO...  MAXIMUM REPLY FROM VM MUST BE 4K                          00029400
* --------------------------------------------------------------------  00029500
CPINIT   DS    0H                                                       00029600
         ST    RE,SAVE01                                                00029700
         L     R6,INPARM           LOAD R1 REGISTER OF ENTRY            00029815
         MVC   UPTADR,0(R6)        FETCH UPT ADDRESS FOR PUTLINE        00029915
         MVC   ECTADR,4(R6)        FETCH ECT ADDRESS FOR PUTLINE        00030015
         GETMAIN RU,BNDRY=PAGE,LV=4096 ON   PAGE BOUNDRY, FULL PAGE     00030100
         LA    RF,4                                                     00030200
         LTR   R1,R1               ADDRESS CAN'T BE ZERO                00030300
         BZ    NOSTOR              MUST BE PROBLEM                      00030400
         LR    RB,R1               SET UP BASE REG FOR DSECT            00030500
         LA    RF,0                                                     00030600
NOSTOR   L     RE,SAVE01                                                00030700
         BR    RE                                                       00030800
         LTORG                        ANY LITERALS                      00030900
         EJECT                                                          00031000
* --------------------------------------------------------------------  00031133
* DATA DEFINITIONS                                                      00031233
* --------------------------------------------------------------------  00031333
ECBADR   DS    F                                                        00031400
UPTADR   DS    F                                                        00031500
ECTADR   DS    F                                                        00031600
PUTBLOCK PUTLINE MF=L                                                   00031700
MESSAGE  DS    0H                 MESAGE PUTLINE FORMAT                 00031800
MSGLEN   DS    H                  LENGTH OF OUTPUT LINE                 00031900
         DC    H'0'               RESERVED                              00032000
MSGTEXT  DS    CL79               MESSAGE TEXT                          00032100
INPARM   DS    A                  CALLING PARAMETER (R1)                00032233
SAVE01   DS    A                                                        00032300
SAVE02   DS    A                                                        00032400
*                                                                       00032500
IOPLADS  DC    4F'0'                                                    00032600
CPRETURN DC    2D'0'              SAVE RETURN REGS FROM CP HERE         00032700
CPUID    DC    D'0'               CPU IDENT TO ENSURE VM THERE          00032800
DBLEWRD  DC    D'0'               TEMP FOR DECIMAL CONVERSIONS          00032900
PGECB    DC    F'0'               POSTED WHEN PAGEFIX DONE              00033000
LANSWER  DC    A(4096)            LENGTH OF RESPONSE AREA               00033100
CPMSLEN  DS    A                  REAL LENGTH OF RETURNED CP MESSAGE    00033224
CMDLEN   DS    A                  COMMAND LENGTH                        00033324
PGMRC    DS    A                  PROGRAM RETURN CODE                   00033426
VMRC     DS    A                  RETURN VM RETURN CODE                 00033526
PUTMSG   DS    CL132                                                    00033615
         DC    C'***** CPCMND *****'                                    00033715
CPCMND   DC    CL132' '           CP COMMAND TO BE DONE                 00033815
         DC    CL32' '                                                  00033924
BLANKS   DC    CL132' '           FOR CONVERTING TO CAPS                00034015
* ... RETURN MESSAGE                                                    00034133
NOVMMSG  DC    C'VM NOT ACTIVE. CPCMD TERMINATING'                      00034215
NOVMRES  DC    C'VM HAS NOT RESPONDED. CPCMD TERMINATING'               00034318
NOREAL   DC    C'REAL STORAGE CANNOT DETERMINED, CPCMD TERMINATING'     00034425
NOGETM   DC    C'GETMAIN OF FIXED STORAGE FAILED, CPCMD TERMINATING'    00034525
CMDMSG   DC    C'COMMAND ERROR .. RETURN CODE FROM CP = '               00034615
OKMSG    DC    C'COMMAND COMPLETE. RC = '                               00034715
*                                                                       00034800
         DS    0D                                                       00034915
* ... DUMMY SECTION FOR REPLY AREA                                      00035033
CPADSECT DSECT     ,              PAGE FOR THE ANSWER FROM CP           00035100
CPANSWR  DS     4096C             RESPONSE FROM CP                      00035215
* ... SYSTEM CONTROL BLOCKS                                             00035333
         IHAPSA    ,              DEFINE LOW STORAGE                    00035400
         IHAASCB   ,              DEFINE ADDR SPACE CTL BLOCK           00035500
         COPY  MRXREGS                                                  00035603
         END                                                            00035700
