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
CHECKVM  DS    0H                                                       00006840
         MODESET   KEY=ZERO,MODE=SUP GET INTO SUPERVISOR MODE           00006940
         STIDP CPUID              CHECK VM THERE                        00007014
         TWTO  'RXCPCMD VM CHECK'                                       00007124
         CLI   CPUID,X'FF'        SET BY VM TO FOXES                    00007220
*        BNE   NOVM               GIVE NASTY MSG AND GET OUT            00007320
*                                                                       00007400
         TWTO  'RXCPCMD READ CP COMMAND'                                00007524
* ... FETCH INPUT PARAMETER                                             00007633
         BAL   RE,TSOGET                                                00007714
         TWTO  'RXCPCMD CP COMMAND FETCHED'                             00007824
* ... MAKE PROGRAM NOT SWAPPABLE                                        00007933
         SYSEVENT DONTSWAP        STAY IN STORAGE                       00008000
* ... FIX I/O PAGES                                                     00008133
         TWTO  'RXCPCMD FIX MVS/VM I/O AREA'                            00008224
         LA    R1,CPCMND          SPECIFY ADDRS TO FIX                  00008314
         BAL   RE,FIXPAGE                                               00008400
         LA    R1,CPANSWR         SPECIFY ADDRS TO FIX                  00008514
         BAL   RE,FIXPAGE                                               00008600
         TWTO  'RXCPCMD FIX COMPLETED'                                  00008724
         TWTO  'RXCPCMD SEND COMMAND TO VM'                             00008824
* ... SEND COMMAND TO VM                                                00008933
         LA    R5,CPANSWR         POINT TO MSG                          00009018
         LA    R7,L'OKMSG+3       LENGTH                                00009118
         BAL   RE,SEND2VM         SEND VM COMMAND                       00009219
         B     *+4(RF)                                                  00009300
         B     OUTMSG             RF=0   RC=0, MESSAGE RECEIVED         00009424
         B     OKREPLY            RF=4   RC=0, NO MESSAGE RECEIVED      00009524
         B     BADCMND            RF=8   RC=8, INVALID CP COMMAND       00009624
         B     NOREALS            RF=12  RC=12, NO REAL ADDR FOR CMD    00009725
         B     NOREALS            RF=16  RC=16, NO REAL ADDR FOR ANSWER 00009825
* ... OUTPUT RESULTS OF VM CALL                                         00009933
OUTMSG   DS    0H                                                       00010024
         TWTO  'RXCPCMD VM RC=0, REPLY RECEIVED'                        00010124
         BAL   RE,OUTPUT                                                00010241
* ... THERE WERE NO RESULTS PROVIDED                                    00010333
OKREPLY  TWTO  'RXCPCMD VM RC=0, NO REPLY RECEIVED'                     00010424
* ... RETURN CODE 0  .................................................  00010533
OKRESULT SETRC 0                                                        00010634
         SETMSG OKMSG,RC=VMRC     BUILD OK MSG                          00010735
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
* ... FOR HOST TYPE REQUEST DROP OUTPUT, JUST RC IS SET                 00011936
* ... OUTPUT MESSAGE SET BY SETMSG                                      00012036
         L     R1,OUTBEGIN                                              00012146
         LTR   R1,R1                                                    00012246
         BNZ   RETURN                                                   00012346
         BAL   RE,OUTLINE         OUTPUT CP MESSAGE                     00012414
         TWTO  'RXCPCMD RELEASE STORAGE'                                00012524
RETURN   FREEMAIN  RU,            MUST FREE ANSWER AREA                X00012600
               A=(RB),            DSECT BASE REG                       X00012700
               LV=4096            FULL PAGE                             00012800
         TWTO  'RXCPCMD EXIT PROGRAM'                                   00012924
         L     RF,PGMRC                                                 00013000
         MRXEXIT                                                        00013102
* --------------------------------------------------------------------  00013200
*  ERROR HANDLING                                                       00013300
* --------------------------------------------------------------------  00013400
* ... RETURN CODE 8  .................................................  00013533
BADCMND  SETRC 8                                                        00013631
         TWTO  'RXCPCMD BAD COMMAND'                                    00013727
         SETMSG CMDMSG,RC=VMRC                                          00013827
         B     PAGEFREE           GO SEND MSG AND FINISH                00013900
* ... RETURN CODE 12 .................................................  00014033
NOGETS   SETRC 12                                                       00014131
         TWTO  'RXCPCMD ABEND2'                                         00014224
         SETMSG NOGETM                                                  00014325
         B     PAGEFREE                                                 00014400
* ... RETURN CODE 16 .................................................  00014533
NOREALS  SETRC 16                                                       00014631
         TWTO  'RXCPCMD ABEND3'                                         00014724
         SETMSG NOREAL                                                  00014827
         B     PAGEFREE                                                 00014900
* ... RETURN CODE 20 .................................................  00015033
NOVM     SETRC 20                                                       00015132
         TWTO  'RXCPCMD NO VM ACTIVE'                                   00015232
         SETMSG NOVMMSG                                                 00015332
         B     CPEXIT             GO SEND AND GET OUT                   00015432
* ... RETURN CODE 24 .................................................  00015533
NOVMRSP  SETRC 24                                                       00015632
         TWTO  'RXCPCMD NO VM RESPONSE'                                 00015732
         SETMSG NOVMRES                                                 00015832
         B     PAGEFREE           GO SEND MSG AND FINISH                00015932
*                                                                       00016000
* --------------------------------------------------------------------  00016100
* FETCH TSO PARAMETER                                                   00016200
* --------------------------------------------------------------------  00016300
TSOGET   ST    RE,SAVE01                                                00016415
* ... C-CALL PARAMETERS                                                 00016533
* CPCOMMAND(VOID *UPTPTR,VOID *ECTPTR,CHAR *CMDSTR,INT CMDLEN,          00016637
*           0(R6)        4(R6)        8(R6)        12(R6)     16(R6)    00016737
*                        CHAR *OUTPUT, INT OUTLEN);                     00016837
*                        16(R6)        20(R6)                           00016937
         L     R6,INPARM      LOAD R1 REGISTER OF ENTRY                 00017014
         L     R4,8(R6)       BUFF ADDRESS                              00017114
         L     R6,12(R6)      LENGTH OF BUFFER IN R6                    00017214
*                                                                       00017300
         LTR   R6,R6          IS LENGTH ZERO                            00017414
         BNP   DEFAULTC       NO COMMAND SPECIFIED                      00017514
         EX    R6,MVCCMD      MOVE CP COMMAND TO OUR STORAGE            00017614
* ... STRIP OFF TRAILING BLANKS, RE-CALCULATE DATA LENGTH               00017733
NXTBYTE  LA    R2,CPCMND(R6)  STRIP OFF TRAILING BLANKS                 00017814
         CLI   0(R2),C' '                                               00017914
         BE    NXTCHAR                                                  00018021
         CLI   0(R2),X'00'                                              00018121
         BNE   TSORET                                                   00018234
         MVI   0(R2),C' '                                               00018324
NXTCHAR  BCT   R6,NXTBYTE                                               00018421
* ... LENGTH HAS BECOME ZERO, USE DEFAULT                               00018533
DEFAULTC MVC   CPCMND(5),=C'Q T'   DEFAULT COMMAND                      00018620
         LA    R6,2           LENGTH OF DEFAULT - 1                     00018714
TSORET   ST    R6,CMDLEN      STORE LENGTH FOR LATER USE                00018834
* ... ECHO THE REQUESTED CP COMMAND ...................                 00018933
         B     SKIP                                                     00019015
         EX    R6,EXECHO      SET UP  TO SEND MSG                       00019114
         LA    R5,CPANSWR     ADDRESS OF ECHO MSG                       00019214
         LR    R7,R6          LENGTH                                    00019314
         BAL   RE,OUTLINE                                               00019414
SKIP     L     RE,SAVE01                                                00019515
         BR    RE                                                       00019614
MVCCMD   MVC   CPCMND(0),0(R4)  MOVE COMMAND OUT                        00019715
EXECHO   MVC   CPANSWR(0),CPCMND                                        00019814
* --------------------------------------------------------------------  00019900
*  COMMAND IS NOW SET UP IN OUR AREA AND CMDLEN IS LENGTH - 1           00020000
* --------------------------------------------------------------------  00020100
SEND2VM  ST    RE,SAVE01                                                00020219
         L     R6,CMDLEN          MAKE CP COMMAND UPPER CASE            00020300
         EX    R6,UPCASE          MAKE CP COMMAND UPPER CASE            00020400
         LRA   R4,CPCMND          GET REAL ADDR OF COMMAND              00020500
         TSTRET BZ,12,CALLRET     TEST WITH BZ, ELSE RC=12              00020627
         LA    R6,1(,R6)          ADD 1 FOR CORRECT LENGTH              00020727
         ICM   R6,8,BLANKS        FLAG BYTE ON TOP OF LENGTH            00020800
         LRA   R5,CPANSWR         REAL ADDR OF ANSWER AREA              00020900
         TSTRET BZ,16,CALLRET     TEST WITH BZ, ELSE RC=16              00021027
         L     R7,LANSWER         LENGTH OF ANSWER AREA                 00021127
         HVC   R4,R6,8            DO CP COMMAND                         00021200
         STM   R4,R7,CPRETURN     SAVE REGS FROM CP FOR DUMP            00021300
         BZ    *+8                CC1 SET IF OVERFLOW                   00021400
         L     R7,LANSWER         RESET TO 4K IF NECESSARY              00021527
* ... POST PROCESSING OF HOST CALL                                      00021633
         ST    R6,VMRC            SAVE VM RETURN CODE                   00021726
         LTR   R6,R6              CHECK RTN CODE FROM CP                00021800
         TSTRET BZ,8,CALLRET      TEST WITH BZ, ELSE RC=8               00021927
         LTR   R7,R7              CHECK LENGTH OF ANSWER FROM CP        00022027
         TSTRET BP,4,CALLRET      TEST WITH BP, ELSE RC=4               00022127
         LA    RF,0               MESSAGE RECEIVED                      00022227
         ST    R7,CPMSLEN         GET VIRT ADDR OF ANSWER               00022324
CALLRET  L     RE,SAVE01                                                00022400
         BR    RE                                                       00022500
UPCASE   OC    CPCMND(0),BLANKS   CONVERT CP COMMAND TO CAPS            00022624
* --------------------------------------------------------------------  00022700
* OUTPUT RESULT OF CP COMMAND                                           00022800
*   R7 <- LENGTH OF STRING                                              00022914
* --------------------------------------------------------------------  00023000
OUTPUT   ST    RE,SAVE01                                                00023100
         L     R1,OUTBEGIN        IS THERE AN OUTPUT AREA?              00023245
         LTR   R1,R1                                                    00023345
         BNZ   OUTBUFF            YES, MOVE TO OURPUT BUFFER            00023445
         L     R7,CPMSLEN         GET LENGTH OF ANSWER                  00023537
         LA    R3,CPANSWR         GET VIRT ADDR OF ANSWER               00023624
         LR    R4,R7              CHECK AGAINST MAX POSSIBLE            00023715
         C     R4,LANSWER         CHECK AGAINST MAX POSSIBLE            00023815
         BNH   *+8                IT'S OK                               00023900
         L     R4,LANSWER         CHECK AGAINST MAX POSSIBLE            00024015
         LA    R5,PUTMSG          ADDRESS PUTLINE                       00024115
         XR    R7,R7                                                    00024215
NEXTC    CLI   0(R3),X'15'                                              00024315
         BE    LINBREAK                                                 00024415
         CLI   0(R3),X'25'                                              00024524
         BE    LINBREAK                                                 00024624
         CLC   0(2,R3),=X'0D0A'                                         00024744
         BNE   ISCHAR                                                   00024843
         LA    R3,1(R3)                                                 00024943
         B     LINBREAK                                                 00025043
ISCHAR   MVC   0(1,R5),0(R3)                                            00025143
         LA    R5,1(R5)                                                 00025215
         LA    R7,1(R7)                                                 00025315
         LA    R3,1(R3)                                                 00025415
         CH    R7,=AL2(80)                                              00025515
         BE    LINOVL                                                   00025615
         BCT   R4,NEXTC                                                 00025715
         LA    R5,PUTMSG                                                00025815
         BAL   RE,OUTLINE         GO WRITE OUT                          00025915
         B     OUTRET                                                   00026015
LINBREAK DS    0H                                                       00026115
         LA    R3,1(R3)                                                 00026215
LINOVL   LA    R5,PUTMSG                                                00026315
         BAL   RE,OUTLINE         GO WRITE OUT                          00026415
         XR    R7,R7                                                    00026515
         BCT   R4,NEXTC                                                 00026615
OUTRET   L     RE,SAVE01                                                00026700
         BR    RE                                                       00026800
* --------------------------------------------------------------------  00026900
* OUTPUT A SINGLE LINE OF THE CP COMMAND RESULT                         00027000
*   R5 <- POINTER TO DATA TO PRINT                                      00027100
*   R7 <- LENGTH OF DATA TO PRINT                                       00027200
* --------------------------------------------------------------------  00027300
OUTLINE  ST    RE,SAVE02         *WRITE THE LINE                        00027444
         LTR   R7,R7              ZERO LENGTH?                          00027500
         BNPR  RE                 GET OUT IF SO                         00027600
         L     R8,UPTADR          LOAD UPT ADDRESS                      00027700
         L     R9,ECTADR          LOAD ECT ADDRESS                      00027800
         XC    ECBADR,ECBADR      INITIALISE ECB                        00027900
         LA    R1,4(R7)           LOAD PUTLINE LENGTH +4 FOR ...        00028000
         STH   R1,MSGLEN          PUTLINE HEADER, SAVE IT               00028100
         BCTR  R7,0               -1 FOR EX MVC                         00028200
         EX    R7,EXMVC1          MOVE CP OUTPUT LINE TO MESSAGE AREA   00028337
         PUTLINE PARM=PUTBLOCK,UPT=(R8),ECT=(R9),ECB=ECBADR,           X00028424
               OUTPUT=(MESSAGE,TERM,SINGLE,DATA),                      X00028524
               MF=(E,IOPLADS)                                           00028600
         L     RE,SAVE02                                                00028739
         BR    RE                 RETURN                                00028800
* ...OUTPUT TO BUFFER, INSTEAD PUTLINE                                  00028939
OUTBUFF  DS    0H                 WRITE TO BUFFER                       00029039
         ST    R2,WRK01                                                 00029145
         ST    R3,WRK02                                                 00029245
* --------------------------------------------------------------------- 00029345
*     MOVE LONG                                                         00029445
* --------------------------------------------------------------------- 00029545
         L     R2,OUTBEGIN        GET LENGTH OF ANSWER                  00029645
         L     R3,CPMSLEN         GET LENGTH OF ANSWER                  00029745
         LA    RE,CPANSWR         GET VIRT ADDR OF ANSWER               00029845
         C     R3,OUTLEN          CHECK AGAINST MAX POSSIBLE            00029945
         BNH   *+8                IT'S OK                               00030045
         L     R3,OUTLEN          CHECK AGAINST MAX POSSIBLE            00030145
         LR    RF,R3              PROPAGATE LENGTH                      00030245
         MVCL  R2,RE              BIG MOVE TO GET IT ALL                00030345
         L     R2,WRK01                                                 00030445
         L     R3,WRK02                                                 00030545
         L     RE,SAVE01                                                00030645
         BR    RE                 RETURN                                00030739
* .... EXECUTES                                                         00030839
EXMVC1   MVC   MSGTEXT(0),0(R5)   MOVE COMMAND OUT                      00030937
EXMVC2   MVC   0(0,R1),0(R5)      MOVE COMMAND OUT                      00031037
* --------------------------------------------------------------------  00031100
* FIX REQUEST PAGE IN STORAGE                                           00031200
* --------------------------------------------------------------------  00031300
FIXPAGE  ST    RE,SAVE01                                                00031400
         XC    PGECB,PGECB        CLEAR ECB                             00031524
         PGFIX R,                 WIRE DOWN PGM                        X00031624
               A=(R1),            START AT BEGINNING OF COMMAND        X00031724
               LONG=N,            SHORT TERM FIX                       X00031800
               ECB=PGECB          POST WHEN DONE                        00031900
         WAIT  ECB=PGECB          DONE.                                 00032000
         L     RE,SAVE01                                                00032100
         BR    RE                                                       00032200
* --------------------------------------------------------------------  00032300
* INIT PROGRAM                                                          00032400
*      GET STORAGE FOR  ANSWR AREA - VM REQUIRES REAL STORAGE ADDRESS   00032500
*      THERE IS NO WAY TO GET CONTIGUOUS REAL ADDRESSES                 00032600
*      SO...  MAXIMUM REPLY FROM VM MUST BE 4K                          00032700
* --------------------------------------------------------------------  00032800
CPINIT   DS    0H                                                       00032900
         ST    RE,SAVE01                                                00033000
         L     R6,INPARM          LOAD R1 REGISTER OF ENTRY             00033137
         MVC   UPTADR,0(R6)       FETCH UPT ADDRESS FOR PUTLINE         00033237
         MVC   ECTADR,4(R6)       FETCH ECT ADDRESS FOR PUTLINE         00033337
         XC    OUTBEGIN,OUTBEGIN  CLEAR OUTPUT BEGIN AREA               00033437
         XC    OUTLEN,OUTLEN      CLEAR OUTPUT END AREY                 00033545
         L     R1,16(R6)          ADDRESS OF OUTPUT BUFFER              00033638
         LTR   R1,R1              OUTPUT AREA PROVIDED?                 00033737
         BZ    NOOUT              NO, NOT PROVIDED                      00033837
         ST    R1,OUTBEGIN        STORE BEGIN OF DIRECT OUTPUT AREA     00033937
         L     R2,20(R6)          LENGTH OF BUFFER                      00034038
         LTR   R2,R2              IS THERE A LENGTH?                    00034137
         BZ    NOOUT              NO, NOT PROVIDED                      00034237
         ST    R2,OUTLEN          STORE END OF DIRECT OUTPUT AREA       00034345
NOOUT    GETMAIN RU,BNDRY=PAGE,LV=4096 ON   PAGE BOUNDRY, FULL PAGE     00034437
         LA    RF,4                                                     00034500
         LTR   R1,R1              ADDRESS CAN'T BE ZERO                 00034637
         BZ    NOSTOR             MUST BE PROBLEM                       00034737
         LR    RB,R1              SET UP BASE REG FOR DSECT             00034837
         LA    RF,0                                                     00034900
NOSTOR   L     RE,SAVE01                                                00035000
         BR    RE                                                       00035100
         LTORG                                                          00035237
         EJECT                                                          00035300
* --------------------------------------------------------------------  00035433
* DATA DEFINITIONS                                                      00035533
* --------------------------------------------------------------------  00035633
ECBADR   DS    F                                                        00035700
UPTADR   DS    F                                                        00035800
ECTADR   DS    F                                                        00035900
OUTBEGIN DS    F                  BEGIN OF OUTPUT AREA                  00036037
OUTLEN   DS    F                  END OF OUTPUT AREA                    00036145
PUTBLOCK PUTLINE MF=L                                                   00036200
MESSAGE  DS    0H                 MESAGE PUTLINE FORMAT                 00036300
MSGLEN   DS    H                  LENGTH OF OUTPUT LINE                 00036400
         DC    H'0'               RESERVED                              00036500
MSGTEXT  DS    CL79               MESSAGE TEXT                          00036600
INPARM   DS    A                  CALLING PARAMETER (R1)                00036733
SAVE01   DS    A                                                        00036800
SAVE02   DS    A                                                        00036900
*                                                                       00037045
WRK01    DS    A                                                        00037145
WRK02    DS    A                                                        00037245
*                                                                       00037300
IOPLADS  DC    4F'0'                                                    00037400
CPRETURN DC    2D'0'              SAVE RETURN REGS FROM CP HERE         00037500
CPUID    DC    D'0'               CPU IDENT TO ENSURE VM THERE          00037600
DBLEWRD  DC    D'0'               TEMP FOR DECIMAL CONVERSIONS          00037700
PGECB    DC    F'0'               POSTED WHEN PAGEFIX DONE              00037800
LANSWER  DC    A(4096)            LENGTH OF RESPONSE AREA               00037900
CPMSLEN  DS    A                  REAL LENGTH OF RETURNED CP MESSAGE    00038024
CMDLEN   DS    A                  COMMAND LENGTH                        00038124
PGMRC    DS    A                  PROGRAM RETURN CODE                   00038226
VMRC     DS    A                  RETURN VM RETURN CODE                 00038326
PUTMSG   DS    CL132                                                    00038415
         DC    C'***** CPCMND *****'                                    00038515
CPCMND   DC    CL132' '           CP COMMAND TO BE DONE                 00038615
         DC    CL32' '                                                  00038724
BLANKS   DC    CL132' '           FOR CONVERTING TO CAPS                00038815
* ... RETURN MESSAGE                                                    00038933
NOVMMSG  DC    C'VM NOT ACTIVE. CPCMD TERMINATING'                      00039015
NOVMRES  DC    C'VM HAS NOT RESPONDED. CPCMD TERMINATING'               00039118
NOREAL   DC    C'REAL STORAGE CANNOT DETERMINED, CPCMD TERMINATING'     00039225
NOGETM   DC    C'GETMAIN OF FIXED STORAGE FAILED, CPCMD TERMINATING'    00039325
CMDMSG   DC    C'COMMAND ERROR .. RETURN CODE FROM CP = '               00039415
OKMSG    DC    C'COMMAND COMPLETE. RC = '                               00039515
*                                                                       00039600
         DS    0D                                                       00039715
* ... DUMMY SECTION FOR REPLY AREA                                      00039833
CPADSECT DSECT     ,              PAGE FOR THE ANSWER FROM CP           00039900
CPANSWR  DS     4096C             RESPONSE FROM CP                      00040015
* ... SYSTEM CONTROL BLOCKS                                             00040133
         IHAPSA    ,              DEFINE LOW STORAGE                    00040200
         IHAASCB   ,              DEFINE ADDR SPACE CTL BLOCK           00040300
         COPY  MRXREGS                                                  00040403
         END                                                            00040500
