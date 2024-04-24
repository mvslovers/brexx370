*********************************************************************** 00000100
*                                                                     * 00000200
*       VSAM I/O PROCESSING MODULE                                      00000300
*   WRITTEN BY  : STEVE SCOTT                                         * 00000400
*           DATE: 02/89                                               * 00000500
*                                                                     * 00000600
*********************************************************************** 00000700
* VSIOMOD  AMODE 31                                                     00000800
* VSIOMOD  RMODE 24                                                     00000900
*********************************************************************** 00001000
*                  REGISTER USAGE                                     * 00001100
*********************************************************************** 00001200
*                                                                     * 00001300
*    R0    -      WORK                                                * 00001400
*    R1    -      WORK/ADDRESS OF PARAMETER LIST                      * 00001500
*    R2    -      WORK                                                * 00001600
*    R3    -      BASE                                                * 00001700
*    R4    -      FILE CONTROL TABLE DSECT REGISTER                   * 00001800
*    R5    -      PARAMETER LIST DSECT REGISTER                       * 00001900
*    R6    -      WORK AREA DSECT REGISTER                            * 00002000
*    R7    -      WORK                                                * 00002100
*    R8    -      WORK                                                * 00002200
*    R9    -      RETURN ADDRESS *** DO * NOT * SCREW * !! ****       * 00002300
*    R10   -      ** UNUSED **                                        * 00002400
*    R11   -      ** UNUSED **                                        * 00002500
*    R12   -      ** UNUSED **                                        * 00002600
*    R13   -      PROGRAM SAVE AREA                                   * 00002700
*    R14   -      BAL/WORK                                            * 00002800
*    R15   -      WORK/SYSTEM                                         * 00002900
*                                                                     * 00003000
*********************************************************************** 00003100
          EJECT                                                         00003200
*         GBLB  &TEST                                                   00003301
* &TEST     SETB  0     ******   SET TO 1 IF TRACING DESIRED ********   00003401
*                                                                       00003500
VSIOMOD   START 0                                                       00003600
R0        EQU   0                                                       00003700
R1        EQU   1                                                       00003800
R2        EQU   2                                                       00003900
R3        EQU   3                                                       00004000
R4        EQU   4                                                       00004100
R5        EQU   5                                                       00004200
R6        EQU   6                                                       00004300
R7        EQU   7                                                       00004400
R8        EQU   8                                                       00004500
R9        EQU   9                                                       00004600
R10       EQU   10                                                      00004700
R11       EQU   11                                                      00004800
R12       EQU   12                                                      00004900
R13       EQU   13                                                      00005000
R14       EQU   14                                                      00005100
R15       EQU   15                                                      00005200
          EJECT                                                         00005300
          STM   R14,R12,12(R13)                                         00005400
          LR    R3,R15              3'S THE BASE                        00005500
          USING VSIOMOD,R3          RESET USING STATUS                  00005600
*                                                                       00005700
          GETMAIN R,LV=72,SP=0                                          00005800
          ST    R13,4(R1)           SET CHAIN                           00005900
          ST    R1,8(R13)                                               00006000
          LR    R13,R1              GET SAVE AREA ADDR IN R13           00006100
*                                                                       00006200
          L     R1,4(R13)          GET CALLER SAVE AREA ADDR            00006300
          L     R1,24(R1)           RESTORE R1 CONTENTS FROM THEIR SAVE 00006400
         L     R5,0(R1)           AND ADDRESS OF PARM LIST ADDR         00006500
         L     R5,0(R5)           AND ADDRESS OF PARM LIST              00006600
*                                                                       00006700
          USING VS$#@IOD,R5         SET UP USING                        00006800
*                                                                       00006900
         ESTAE SHELSHOK,PARAM=(R5),ASYNCH=NO                            00007000
*                                                                       00007100
          LA    R0,WORKALEN         LENGTH OF TEMP WORK AREAS           00007200
          GETMAIN R,LV=(0)                                              00007300
          LR    R6,R1               PUT IN R6                           00007400
          LR   R14,R6   CLEAR THE WORKAREA                              00007500
          LA   R15,WORKALEN       LENGTH OF AREA                        00007600
         XR    R0,R0                                                    00007700
         XR    R1,R1                                                    00007800
         MVCL  R14,R0                                                   00007900
          USING WORKADS,R6               SET UP USING                   00008000
*                                                                       00008100
          MVI   VS$#@IND,VS$#@ACT  SET ACTIVE INDICATOR                 00008200
          EJECT                                                         00008300
*********************************************************************** 00008400
*               ENTRY POINT AFTER WAIT ECB POSTED                     * 00008500
*********************************************************************** 00008600
          SPACE                                                         00008700
FROMDTOP  DS    0H                 HERES WHERE START AFTER WAIT POSTED  00008800
         LA    R9,RETURN          INITIALIZE RETURN ADDRESS             00008900
*                                                                       00009000
          USING FCDSECT,R4          R4 IS THE BASE FOR FILE CONTROL     00009100
*                                                                       00009200
          MVN   TESTBYTE,VS$#@FNC                                       00009300
         AIF   (NOT &TEST).NOTEST1                                      00009400
         BAL   R14,FCTRACE        GO DO TRACE ROUTINE                   00009500
*                                                                       00009600
.NOTEST1 ANOP  ,                                                        00009700
          CLI   TESTBYTE,VS$#OPEN   OPEN REQUEST?                       00009800
          BE    CKOPER              YES--> FILE WONT BE FOUND ON OPEN   00009900
          ICM   R4,15,VS$#@CTL      GET CONTROL TAB ADDR                00010000
          BZ    INVFILE            NOT THERE--> ERROR                   00010100
*                                                                       00010200
          CLI   VS$#@FNC,VS$#CLOS+VS$#CLSA CLOSE ALL?                   00010300
          BE    CKOPER              YES--> DONT TRY TO FIND THE FILE    00010400
*                                                                       00010500
FCLOOP    DS    0H                                                      00010600
          CLC   VS$#@FIL,FCDDNAME   THIS ENTRY?                         00010700
          BE    CKOPER              YES--> GO CHECK AND PROCESS REQ     00010800
          L     R4,FCNEXT           GET FOWARD POINTER                  00010900
          C     R4,=F'-1'           X'FF'S ?                            00011000
          BE    INVFILE             YES--> FILE NOT FOUND - INVALID     00011100
          B     FCLOOP              GO BACK, JACK                       00011200
*                                                                       00011300
CKOPER    DS    0H                                                      00011400
          XR    R1,R1                                                   00011500
          IC    R1,TESTBYTE         GET OPERATION                       00011600
          SLL   R1,2               MULTIPLY BY 4                        00011700
*=================>>>>>>>  WARNING...WARNING... <<<<<<<===============  00011800
*=================>>>>>>>  WARNING...WARNING... <<<<<<<===============  00011900
*   IF ANY OTHER OPERATIONS ARE TO BE ADDED THIS TEST BETTER BE CHANGED 00012000
*********************************                                       00012100
          CLI   TESTBYTE,VS$#ENRQ   HIGHER THAN LAST OP?                00012200
*********************************                                       00012300
          BH    INVOPER             YES--> INVALID                      00012400
          B     BRTAB(R1)           GO DO OPERATION                     00012500
BRTAB     DS    0H                                                      00012600
          B     INVOPER             0 IS INVALID                        00012700
          B     FCOPEN                                                  00012800
          B     FCCLOSE                                                 00012900
          B     FCREAD                                                  00013000
          B     FCWRITE                                                 00013100
          B     FCDELET                                                 00013200
          B     FCPOINT                                                 00013300
          B     FCENDREQ                                                00013400
          DC    D'0'               JUST IN CASE WE GO A LITTLE TOO FAR  00013500
          EJECT                                                         00013600
*********************************************************************** 00013700
*                    EVERYBODY COMES BACK HERE!                       * 00013800
*********************************************************************** 00013900
          SPACE                                                         00014000
RETURN    DS    0H                                                      00014100
*                                                                       00014200
          LA    R1,VS$#@E02        GET ECB MOMMA IS WAITING ON          00014300
          POST  (1)                GIVE 'ER THAT BAD BOY                00014400
*                                                                       00014500
         TM    VS$#@E01,X'40'     HAS IT BEEN POSTED?                   00014600
         BO    RETNOWT            YES--> DONT WAIT                      00014700
          LA    R1,VS$#@E01        LETS WAIT TILL WERE NOTIFIED         00014800
          WAIT  ECB=(1)                                                 00014900
RETNOWT  DS    0H                                                       00015000
          XC   VS$#@E01,VS$#@E01  CLEAR ECB                             00015100
*                                                                       00015200
          B     FROMDTOP                                                00015300
DETACH    DS    0H                                                      00015400
*                                                                       00015500
          MVI   VS$#@IND,0         CLEAR ACTIVE INDICATOR               00015600
          LA    R1,VS$#@E02        GET ECB MOMMA IS WAITING ON          00015700
          POST  (1)                GIVE 'ER THAT BAD BOY                00015800
          SPACE                                                         00015900
          ESTAE 0                 REMOVE OUR EXIT                       00016000
*                                                                       00016100
          LA    R1,VS$#@E01        LETS WAIT TILL WERE DETACHED         00016200
          WAIT  ECB=(1)                                                 00016300
*                                 SHOULDN'T GET HERE, BUT IF....        00016400
         DC    D'0'                                                     00016500
*                                                                       00016600
          EJECT                                                         00016700
*********************************************************************** 00016800
*                    FILE OPEN ROUTINE                                * 00016900
*********************************************************************** 00017000
          SPACE                                                         00017100
FCOPEN    DS    0H                                                      00017200
          SPACE                                                         00017300
          ICM   R4,15,VS$#@CTL     GET FIRST CTL BLOCK ADDR             00017400
          BZ    ADDITON            NOT THERE--> ADD THE FIRST FILE      00017500
*                                                                       00017600
FCFINDIT  DS    0H                                                      00017700
          CLC   VS$#@FIL,FCDDNAME   FOUND FILE?                         00017800
          BE    DUPOPEN             NOT ALLOWED, SIR                    00017900
          L     R1,FCNEXT           GET NEXT ENTRY                      00018000
          C     R1,=F'-1'           AT END?                             00018100
          BE    ADDITON             YES--> GO ADD FILE                  00018200
          LR    R4,R1              NEXT ADDRESS IN R4                   00018300
          B     FCFINDIT           GO TRY TO FIND THE FILE              00018400
*                                                                       00018500
ADDITON   BAL   R14,ADDFILE         GO ADD THE FILE ENTRY               00018600
*                                                                       00018700
          CLC   VS$#@FTY,=CL4'ESDS'  ENTRY SEQUENCED?                   00018800
          BNE   OPN4WRD             NO--> GO FORWARD WITH THE OPEN!     00018900
         SPACE                                                          00019000
         L     R2,FCACBAD      GET ACB ADDRESS                          00019100
         MODCB ACB=(2),MACRF=(ADR,SEQ,IN)                               00019200
          LTR   R15,R15             CHECK FOR ERROR                     00019300
          BNZ   VSERRMC             IF SO --> GO                        00019400
         L     R2,FCSRPLAD     GET SEQ RPL ADDR                         00019500
         MODCB RPL=(2),OPTCD=(ADR,SEQ,NUP,MVE)                          00019600
          LTR   R15,R15             CHECK FOR ERROR                     00019700
          BNZ   VSERRMC             IF SO --> GO                        00019800
         L     R2,FCRRPLAD     GET SEQ RPL ADDR                         00019900
         MODCB RPL=(2),OPTCD=(ADR,SEQ,NUP,MVE)                          00020000
          LTR   R15,R15             CHECK FOR ERROR                     00020100
          BNZ   VSERRMC             IF SO --> GO                        00020200
OPN4WRD  DS    0H                                                       00020300
         SPACE                                                          00020400
          L     R15,FCACBAD         GET ADDR OF ACB                     00020500
          USING IFGACB,R15                                              00020600
         SPACE                                                          00020700
         CLC   VS$#@DBF,=H'0'    ANY DATA BUFFERS REQ?                  00020800
         BE    CKIBUF            NO--> CHECK INDEX BUFFERS              00020900
         MVC   ACBBUFND,VS$#@DBF  MOVE NUMBER OF BUFFERS IN             00021000
CKIBUF   DS    0H                                                       00021100
         CLC   VS$#@IBF,=H'0'     ANY INDEX REQUESTED?                  00021200
         BE    NOPERS             NOPE                                  00021300
         MVC   ACBBUFNI,VS$#@IBF  MOVE INDEX BUFFERS IN                 00021400
NOPERS   DS    0H                                                       00021500
          TM    VS$#@FNC,VS$#ORDO   OPEN FOR READ ONLY?                 00021600
          BO    OPENIT              YES-> OPENIT!                       00021700
          NI    ACBMACR1,255-ACBIN  TURN OFF READ FLAG                  00021800
          OI    ACBMACR1,ACBOUT     NO--> SET ACB FOR OUTPUT            00021900
          TM    VS$#@FNC,VS$#OLOD+VS$#ORSU   OPEN FOR LOAD OR RESET/UPD 00022000
          BZ    OPENIT              NO--> OPEN AS UPDATE                00022100
          OI    ACBMACR2,ACBRST     SET TO RESET FILE TO EMPTY          00022200
          MVI   ACBSTRNO,X'01'      STRINGS = 1                         00022300
*                                                                       00022400
OPENIT    DS    0H                                                      00022500
          LR    R2,R15              PUT ACB ADDRESS IN R2               00022600
          OPEN  ((2))               OPEN IT                             00022700
          LTR   R15,R15             CHECK FOR ERROR                     00022800
          BNZ   VSERROC             IF SO --> GO                        00022900
*                                                                       00023000
FCOPENR  DS    0H                                                       00023100
*                                                                       00023200
          L     R7,FCACBAD         GET ACB ADDRESS                      00023300
          LA    R1,DBLWRD                                               00023400
*                                                                       00023500
         SHOWCB AREA=(1),                                              X00023600
               FIELDS=(KEYLEN,LRECL,RKP),                              X00023700
               LENGTH=12,                                              X00023800
               ACB=(7)                                                  00023900
*                                                                       00024000
          LTR   R15,R15             DID WE GET THE KEYLENGTH?           00024100
          BNZ   VSERROC            NO--> ERROR                          00024200
          MVC   FCFKEYL,DBLWRD+3    SAVE FULL KEY LENGTH                00024300
          MVC   FCFKEYD,FULLWORD+2  SAVE KEY DISPLACEMENT               00024400
          MVC   VS$#@KYL,FCFKEYL    SAVE KEY LENGTH IN COMAREA          00024501
          MVC   VS$#@KYD,FCFKEYD    SAVE KEY OFFSET IN COMAREA          00024601
          L     R0,DBLWRD+4        GET RECORD LENGTH FROM SHOWCB        00024700
          GETMAIN R,LV=(0)                                              00024800
          ST    R1,FCSAREA         STORE AREA ADDRESS IN FC TABLE       00024900
          L     R0,DBLWRD+4        GET RECORD LENGTH FROM SHOWCB        00025000
          GETMAIN R,LV=(0)                                              00025100
          ST    R1,FCRAREA         STORE AREA ADDRESS IN FC TABLE       00025200
*                                                                       00025300
          USING IFGRPL,R1                                               00025400
          L     R1,FCSRPLAD                                             00025500
          L     R0,DBLWRD+4        GET RECORD LENGTH FROM SHOWCB        00025600
          ST    R0,RPLRLEN          GET RECORD LENGTH IN RPL            00025700
          ST    R0,RPLBUFL          STORE LENGTH OF AREA                00025800
          MVC   RPLAREA,FCSAREA    SET AREA ADDR IN RPL                 00025900
          L     R1,FCRRPLAD         GET RANDOM RPL ADDR                 00026000
          ST    R0,RPLRLEN          AND STORE LENGTH THERE, TOO         00026100
          ST    R0,RPLBUFL          STORE LENGTH OF AREA                00026200
          MVC   RPLAREA,FCRAREA    SET AREA ADDR IN RPL                 00026300
*                                                                       00026400
          TM    VS$#@FNC,VS$#ORSU   OPEN FOR RESET / UPDATE?            00026500
          BO    ORESUP              YES--> DO DUMMY ROUTINE             00026600
          STH   R0,VS$#@RLN        STORE LENGTH IN PARAMETER LIST       00026700
*                                                                       00026800
          TM    VS$#@FNC,VS$#OLOD   OPENED FOR LOAD?                    00026900
          BO    NOPOINT             YES--> SKIP THE POINT               00027000
*                                                                       00027100
          L     R1,FCSRPLAD                                             00027200
          XC    FCKEY,FCKEY         CLEAR KEY FIELD                     00027300
          POINT RPL=(1)                                                 00027400
*                                   POINT TO 1ST RECORD ON SEQ          00027500
*                                   RPL. THIS IS DONE TO COMPENSATE     00027600
*                                   FOR THE INCONSISTANCY WITH IBM      00027700
*                                   DOCUMENTATION ON CONCURRENT         00027800
*                                   PROCESSING USING STRINGS            00027900
          DROP  R15                                                     00028000
          DROP  R1                                                      00028100
NOPOINT   DS    0H                                                      00028200
          BR    R9                                                      00028300
         SPACE                                                          00028400
ORESUP   DS    0H                                                       00028500
         SPACE                                                          00028600
         CLC   VS$#@RLN,=H'0'     LENGTH SUPPLIED?                      00028700
         BNE   SUPPLEN            YES--> SKIP STORE                     00028800
         STH   R0,VS$#@RLN        SAVE LENGTH FROM OPEN                 00028900
SUPPLEN  DS    0H                                                       00029000
         L     R1,FCSRPLAD        SEQUENTIAL RPL ADDR IN 1              00029100
         USING IFGRPL,R1                                                00029200
         L     R14,RPLAREA        GET AREA ADDRESS                      00029300
         LH    R15,VS$#@RLN       YES--> PUT LENGTH IN R15              00029400
         DROP  R1                                                       00029500
         XR    R1,R1              CLEAR THE AREA                        00029600
         LR    R0,R1                                                    00029700
         MVCL  R14,R0                                                   00029800
*                                                                       00029900
         BAL   R9,FCWRITE         GO EXECUTE WRITE ROUTINE FOR DUMMY    00030000
         MVI   VS$#@FNC,X'00'     SET FUNCTION BYTE  0  INTERNAL SW     00030100
         BAL   R9,FCCLOSE         DO CLOSE ROUTINE                      00030200
         OI    VS$#@FNC,VS$#OPEN+VS$#OUPD                               00030300
         LA    R9,RETURN                                                00030400
         B     FCOPEN                                                   00030500
          EJECT                                                         00030600
*********************************************************************** 00030700
*                    FILE CLOSE ROUTINE                               * 00030800
*********************************************************************** 00030900
          SPACE                                                         00031000
FCCLOSE   DS    0H                                                      00031100
          SPACE                                                         00031200
          TM    VS$#@FNC,VS$#CLSA   CLOSE ALL?                          00031300
          BZ    FCLOSIT             NO--> CONTINUE                      00031400
*                                                                       00031500
          L     R4,VS$#@CTL        GET BEGINNING CONTROL TABLE ADDR     00031600
*                                                                       00031700
FCLOSIT   DS    0H                                                      00031800
          MVC   VS$#@FIL,FCDDNAME  MOVE DDNAME TO PARM LIST             00031900
          L     R1,FCRRPLAD       GET RANDOM RPL ADDR                   00032000
          USING IFGRPL,R1                                               00032100
          L     R7,RPLBUFL         GET RECORD LENGTH BEFORE WE CLOSE    00032200
          DROP  R1                                                      00032300
          L    R2,FCACBAD         ACB ADDR IN R2                        00032400
          CLOSE ((2))              CLOSE THE FILE                       00032500
*                                                                       00032600
          LTR   R15,R15            CHECK FOR ERROR                      00032700
          BNZ   VSERROC                                                 00032800
*                                                                       00032900
FCCLOSR   DS    0H                 RETURN ADDRESS ON CLOSE ERROR        00033000
*                                  BECAUSE WE STILL WANT TO FREE        00033100
*                                  ASSOCIATED AREAS                     00033200
          LR    R0,R7                                                   00033300
          L     R1,FCSAREA         FREE SEQ I/O AREA ADRESS             00033400
          FREEMAIN R,LV=(0),A=(1)                                       00033500
          LR    R0,R7              RESET LENGTH                         00033600
          L     R1,FCRAREA         FREE RANDOM I/O AREA ADRESS          00033700
          FREEMAIN R,LV=(0),A=(1)                                       00033800
*                                                                       00033900
          BAL   R14,DELFILE        GO DELETE FILE ENTRY FROM TABLE      00034000
*                                                                       00034100
          ICM   R1,15,VS$#@CTL     IS CTL TABLE ADDR ZEROS?             00034200
          BNZ   CKCLOSA            NO--> CHECK IF CLOSE ALL             00034300
          CLI  VS$#@FNC,X'00'     INTERNAL FUNCTION?                    00034400
          BER   R9                YES--> RETURN DO NOT DETACH           00034500
          B     DETACH             ALL GONE--> DETACH                   00034600
*                                  AND FREE ASSOCIATED BLOCKS           00034700
CKCLOSA  DS    0H                                                       00034800
          TM    VS$#@FNC,VS$#CLSA   CLOSE ALL?                          00034900
          BO    FCLOSIT             YES--> CONTINUE                     00035000
          BR    R9                  NO--> RETURN                        00035100
*                                                                       00035200
          EJECT                                                         00035300
*********************************************************************** 00035400
*                    FILE READ ROUTINE                               *  00035500
*********************************************************************** 00035600
          SPACE                                                         00035700
FCREAD    DS    0H                                                      00035800
          SPACE                                                         00035900
          USING IFGRPL,R1                                               00036000
*                                                                       00036100
          L     R1,FCSRPLAD       GET SEQUENTIAL RPL ADDR               00036200
          CLI  VS$#@KYL,0         ANY KEY?                              00036300
          BE   FCRPLOK            NO--> USE SEQ RPL                     00036400
          L     R1,FCRRPLAD       YES--> USE RANDOM RPL                 00036500
FCRPLOK  DS    0H                                                       00036600
          TM    VS$#@FNC,VS$#RUPD  READ FOR UPDATE?                     00036700
          BZ    FCREADO            NO--> SET READ ONLY                  00036800
          OI    RPLOPT2,RPLUPD     TURN UPDATE FLAG ON                  00036900
          B    CKKEYF                                                   00037000
FCREADO  DS    0H                                                       00037100
          NI    RPLOPT2,255-RPLUPD ASSURE UPDATE FLAG OFF               00037200
          DROP  R1                                                      00037300
CKKEYF    DS    0H                                                      00037400
          ICM   R1,15,VS$#@KEY     ANY KEY?                             00037500
          BZ    SEQREAD            NOT PRESENT--> ASSUME SEQ ACCESS     00037600
          XC    FCKEY,FCKEY        CLEAR KEY AREA                       00037700
          XR    R7,R7              CLEAR R7                             00037800
          IC    R7,VS$#@KYL        INSERT KEY LENGTH                    00037900
          BCTR  R7,0               DECREMENT FOR MOVE                   00038000
          EX    R7,MOVEKEY         MOVE THE KEY IN                      00038100
*                                                                       00038200
          L     R1,FCRRPLAD        RANDOM RPL ADDRESS IN R1             00038300
FCSVNGET DS    0H                                                       00038400
          ST    R1,WHATRPL         SAVE ADDRESS FOR LATER               00038500
*                                                                       00038600
          GET   RPL=(1)                                                 00038700
*                                                                       00038800
          LTR   R15,R15            IF ERROR, INVESTIGATE                00038900
          BNZ   VSERREQ                                                 00039000
*                                                                       00039100
          CLC   FCFKEYL,VS$#@KYL   GENERIC READ?                        00039200
          BH    MOVEREC            YES--> GIVE EM WHAT WE GOT           00039300
          XR    R8,R8                                                   00039400
          ICM   R8,B'0011',FCFKEYD GET KEY DISPLACEMENT                 00039500
          XR    R7,R7                                                   00039600
          IC    R7,FCFKEYL         FULL KEY LENGTH IN R7                00039700
          BCTR  R7,0               DOWN BY 1 FOR EX COMPARE             00039800
          L     R1,FCRAREA         GET RANDOM RECORD ADDRESS            00039900
          AR   R1,R8              BUMP TO KEY OFFSET                    00040000
          EX    R7,KEYCLC          COMPARE THE KEY                      00040100
          BE    MOVEREC            EQUAL--> OK                          00040200
          BAL   R9,FCENDREQ        RELEASE THE RECORD WE JUST READ      00040300
          LA    R9,RETURN          RESET RETURN ADDRESS                 00040400
          B     EOFNRF             NOT EQUAL--> NOT FOUND               00040500
*                                                                       00040600
SEQREAD   DS    0H                                                      00040700
          L     R1,FCSRPLAD        GET SEQ RPL ADDRESS                  00040800
          ST    R1,WHATRPL         SAVE ADDRESS FOR LATER               00040900
*                                                                       00041000
          GET   RPL=(1)                                                 00041100
*                                                                       00041200
          LTR   R15,R15            ERROR?                               00041300
          BNZ   VSERREQ            YES--> CHECK IT OUT                  00041400
*                                                                       00041500
MOVEREC   DS    0H                                                      00041600
          L     R1,WHATRPL         GET RPL ADDRES WE JUST ACCESSED      00041700
          USING IFGRPL,R1                                               00041800
*                                                                       00041900
          L     R14,RPLAREA   GET FROM ADDRESS(EITHER FCRAREA/FCSAREA)  00042000
          L     R15,RPLRLEN        AND LENGTH OF RECORD READ            00042100
* TRLOOP   CLI   0(R14),X'00'                                           00042207
*         BNE   TRLNXT                                                  00042307
*         MVI   0(R14),C' '                                             00042407
*TRLNXT   LA    R14,1(R14)                                              00042507
*         BCT   R15,TRLOOP                                              00042607
*         L     R14,RPLAREA   GET FROM ADDRESS(EITHER FCRAREA/FCSAREA)  00042707
*         L     R15,RPLRLEN        AND LENGTH OF RECORD READ            00042807
          STH   R15,VS$#@RLN       STORE LENGTH IN PARAMETER LIST       00042900
          ICM   R0,15,VS$#@ARE     DID THEY SUPPLY A RECORD ADDRESS?    00043000
          BZ    NOMOVE             NO--> SUPPLY ONLY OUR ADDRESS        00043100
          DROP  R1                                                      00043200
          LR    R1,R15             PUT LENGTH IN R1 ALSO                00043300
          MVCL  R0,R14             MOVE RECORD TO USER AREA             00043400
*                                                                       00043500
          BR    R9                                                      00043600
*                                                                       00043700
NOMOVE    DS    0H                                                      00043800
          ST    R14,VS$#@ARE        STORE IN PARAMETER LIST             00043900
          BR    R9                 AND EXIT                             00044000
*                                                                       00044100
MOVEKEY   MVC   FCKEY(0),0(R1)     EXECUTED MOVE                        00044200
KEYCLC    CLC   FCKEY(0),0(R1)    EXECUTED COMPARE                      00044300
          EJECT                                                         00044400
*********************************************************************** 00044500
*                    FILE WRITE ROUTINE                              *  00044600
*********************************************************************** 00044700
          SPACE                                                         00044800
FCWRITE   DS    0H                                                      00044900
          SPACE                                                         00045000
          ICM   R1,15,VS$#@KEY     GET ADDRESS OF KEY                   00045100
          BZ    SEQWRITE           NOT PRESENT--> ASSUME SEQ WRITE      00045200
*                                                                       00045300
          L     R1,FCRRPLAD        RANDOM RPL ADDRESS IN R1             00045400
          LR    R7,R1              PUT ADDRESS IN R7                    00045500
          B     CKMOVEIT                                                00045600
*                                                                       00045700
SEQWRITE  DS    0H                                                      00045800
          L     R1,FCSRPLAD        GET SEQ RPL ADDRESS                  00045900
          LR    R7,R1              PUT ADDR IN R7                       00046000
*                                                                       00046100
CKMOVEIT  DS    0H                                                      00046200
          USING IFGRPL,R1                                               00046300
          L     R14,RPLAREA   GET TO ADDRESS(EITHER FCRAREA/FCSAREA)    00046400
          L     R15,RPLBUFL       SET MAX LENGTH AS DEFAULT             00046500
          CLI   RPLREQ,RPLGET     WAS LAST REQUEST A GET?               00046600
          BE    FCCKUPD           YES--> GO CHECK IF UPDATE             00046700
          NI    RPLOPT2,255-RPLUPD  NO--> TURN OFF UPDATE FLAG IF ON    00046800
          B     FCCKRLEN          AND USE MAX FOR DEFAULT               00046900
FCCKUPD  DS    0H                 CHECK IF UPDATE                       00047000
          TM    RPLOPT2,RPLUPD    FOR UPDATE?                           00047100
          BZ    FCCKRLEN          NO---> USE MAX LENGTH AS DEFAULT      00047200
          L     R15,RPLRLEN       PREVIOUS REQUEST WAS READ/UPDATE      00047300
*                                 SO DEFAULT IS LENGTH OF RECORD READ   00047400
FCCKRLEN  DS    0H                                                      00047500
          CLC   VS$#@RLN,=H'0'     DID THEY SUPPLY A LENGTH?            00047600
          BE    NOPE               NO--> USE RPL LENGTH                 00047700
          LH    R15,VS$#@RLN       YES--> PUT LENGTH IN R15             00047800
NOPE      DS    0H                                                      00047900
          ST    R15,RPLRLEN        STORE NEW/OLD LENGTH IN RPL          00048000
*                                                                       00048100
          TM    VS$#@FNC,VS$#OPEN                                       00048200
          BO    PUTIT         DON'T CHECK AREA ON OPEN RESET/UPD        00048300
*                                                                       00048400
          ICM   R0,15,VS$#@ARE     DID THEY SUPPLY A RECORD ADDRESS?    00048500
          BZ    PUTIT              NO--> THEY UPDATED IN OUR AREA       00048600
          DROP  R1                                                      00048700
          LR    R1,R15             PUT LENGTH IN R1 ALSO                00048800
          MVCL  R14,R0             MOVE USER AREA TO OURS               00048900
*                                                                       00049000
PUTIT     DS    0H                                                      00049100
          PUT   RPL=(7)                                                 00049200
*                                                                       00049300
          LTR   R15,R15            IF ERROR, INVESTIGATE                00049400
          BNZ   VSERREQ                                                 00049500
*                                                                       00049600
          BR    R9                                                      00049700
*                                                                       00049800
          EJECT                                                         00049900
*********************************************************************** 00050000
*                    FILE DELETE ROUTINE                              * 00050100
*********************************************************************** 00050200
          SPACE                                                         00050300
FCDELET   DS    0H                                                      00050400
          SPACE                                                         00050500
          ICM   R1,15,VS$#@KEY     GET ADDRESS OF KEY                   00050600
          BNZ   RANDELET           PRESENT--> DO RANDOM DELETE          00050700
*                                                                       00050800
          L     R1,FCSRPLAD        GET SEQ RPL ADDRESS                  00050900
          B     BYEBYE            NO AUTOREAD ON SEQ DELETE             00051000
*                                                                       00051100
RANDELET  DS    0H                                                      00051200
          CLC   FCFKEYL,VS$#@KYL   IS IT A FULL KEY DELETE?             00051300
          BNE   DELERR             NO--> ERROR                          00051400
*                                                                       00051500
          XC    FCKEY,FCKEY        CLEAR KEY AREA                       00051600
          XR    R7,R7              CLEAR R7                             00051700
          IC    R7,VS$#@KYL        INSERT KEY LENGTH                    00051800
          BCTR  R7,0               DECREMENT FOR MOVE                   00051900
          EX    R7,MOVEKEY         MOVE THE KEY IN                      00052000
*                                                                       00052100
          L     R1,FCRRPLAD        RANDOM RPL ADDRESS IN R1             00052200
          USING IFGRPL,R1                                               00052300
*                                                                       00052400
          CLI   RPLREQ,RPLGET     WAS LAST REQUEST A GET?               00052500
          BNE   GETU              NO--> GET RECORD                      00052600
          TM    RPLOPT2,RPLUPD    YES--> FOR UPDATE?                    00052700
          BO    BYEBYE            YES--> GO DO DELETE                   00052800
*                                                                       00052900
GETU     DS    0H                                                       00053000
          OI    RPLOPT2,RPLUPD     TURN UPDATE FLAG ON                  00053100
*         NI    RPLOPT2,255-RPLNSP TURN OFF NOTE STRING POS             00053200
          DROP  R1                                                      00053300
*                                                                       00053400
          GET   RPL=(1)           GET THE RECORD FOR UPDATE             00053500
*                                                                       00053600
          LTR   R15,R15            IF ERROR, INVESTIGATE                00053700
          BNZ   VSERREQ                                                 00053800
*                                                                       00053900
         L     R1,FCRRPLAD        RESTORE RPL ADDRESS                   00054000
*                                                                       00054100
BYEBYE    DS    0H                                                      00054200
          ERASE RPL=(1)                                                 00054300
*                                                                       00054400
          LTR   R15,R15            IF ERROR, INVESTIGATE                00054500
          BNZ   VSERREQ                                                 00054600
*                                                                       00054700
          BR    R9                                                      00054800
*                                                                       00054900
          EJECT                                                         00055000
*********************************************************************** 00055100
*                    FILE POINT ROUTINE                               * 00055200
*                    SEQUENTIAL RPL ASSUMED                           * 00055300
*********************************************************************** 00055400
          SPACE                                                         00055500
FCPOINT   DS    0H                                                      00055600
          SPACE                                                         00055700
          ICM   R1,15,VS$#@KEY     GET ADDRESS OF KEY                   00055800
          BZ    INVKEY             NOT PRESENT--> ERROR...ERROR...ERROR 00055900
*                                                                       00056000
          XC    FCKEY,FCKEY        CLEAR KEY AREA                       00056100
          XR    R7,R7              CLEAR R7                             00056200
          IC    R7,VS$#@KYL        INSERT KEY LENGTH                    00056300
          BCTR  R7,0               DECREMENT FOR MOVE                   00056400
          EX    R7,MOVEKEY         MOVE THE KEY IN                      00056500
*                                                                       00056600
          L     R1,FCSRPLAD        SEQ RPL ADDRESS IN R1                00056700
*                                                                       00056800
POINTIT   DS    0H                                                      00056900
          POINT RPL=(1)                                                 00057000
*                                                                       00057100
          LTR   R15,R15            IF ERROR, INVESTIGATE                00057200
          BNZ   VSERREQ                                                 00057300
*                                                                       00057400
          CLC   FCFKEYL,VS$#@KYL   GENERIC POINT?                       00057500
          BHR   R9                 YES--> GIVE EM WHAT WE GOT           00057600
          XR    R7,R7                                                   00057700
          IC    R7,FCFKEYL         FULL KEY LENGTH IN R7                00057800
          BCTR  R7,0               DOWN BY 1 FOR EX COMPARE             00057900
          XR    R8,R8                                                   00058000
          ICM   R8,B'0011',FCFKEYD GET KEY DISPLACEMENT                 00058100
          L     R1,FCSAREA         GET SEQ RECORD ADDRESS               00058200
          AR    R1,R8             BUMP TO KEY                           00058300
          EX    R7,KEYCLC          COMPARE THE KEY                      00058400
          BER   R9                 EQUAL--> OK                          00058500
          BAL   R9,FCENDREQ        RELEASE THE VSAM STRING/POINTER      00058600
          LA    R9,RETURN          RESET RETURN ADDRESS                 00058700
          B     EOFNRF             NOT EQUAL--> NOT FOUND               00058800
*                                                                       00058900
          EJECT                                                         00059000
*********************************************************************** 00059100
*                    FILE ENDREQ ROUTINE                              * 00059200
*********************************************************************** 00059300
          SPACE                                                         00059400
FCENDREQ  DS    0H                                                      00059500
          SPACE                                                         00059600
          L     R1,FCSRPLAD        GET SEQ RPL ADDRESS                  00059700
          ICM   R0,15,VS$#@KEY     GET ADDRESS OF KEY                   00059800
          BZ    ERQIT              NOT PRESENT--> USE SEQ RPL           00059900
*                                                                       00060000
          L     R1,FCRRPLAD        GET RANDOM RPL ADDR                  00060100
*                                                                       00060200
ERQIT     DS    0H                                                      00060300
          ENDREQ RPL=(1)                                                00060400
*                                                                       00060500
          LTR   R15,R15            IF ERROR, INVESTIGATE                00060600
          BNZ   VSERREQ                                                 00060700
*                                                                       00060800
          BR    R9                                                      00060900
*                                                                       00061000
          EJECT                                                         00061100
*********************************************************************** 00061200
*                    ADD FILE TO CONTROL TABLE                       *  00061300
*********************************************************************** 00061400
*      THIS ROUTINE ASSUMES THAT R4 CONTAINS EITHER:                 *  00061500
*         THE LAST FILE ENTRY IN THE FILE CONTROL TABLE              *  00061600
*                       *** OR ***                                   *  00061700
*                         ZEROS                                      *  00061800
*   THIS ROUTINE WILL ACQUIRE THE STORAGE REQUIRED FOR A NEW         *  00061900
*  FILE CONTROL TABLE ENTRY, ADJUST FC CHAIN, GETMAIN STORAGE        *  00062000
*  FOR THE ACB/RPL'S BLOCK, AND SETS THE FOLLOWING ADDRESSES         *  00062100
*  IN THE RPL'S:                                                     *  00062200
*      RPLDACB  - ACB ADDRESS                                        *  00062300
*      RPLARG   - ADDRESS OF SEARCH KEY (FCKEY)                      *  00062400
*                                                                    *  00062500
*    UPON RETURN, R4 WILL CONTAIN THE ADDRESS OF THE NEW ENTRY       *  00062600
*   CREATED.                                                         *  00062700
*                                                                    *  00062800
*********************************************************************** 00062900
          SPACE                                                         00063000
ADDFILE   DS    0H                                                      00063100
          SPACE                                                         00063200
          ST    R14,SAVER14                                             00063300
*                                                                       00063400
          LA    R0,FCELEN          GET THE AREA                         00063500
*                                                                       00063600
          GETMAIN R,LV=(0)                                              00063700
*                                                                       00063800
          LTR   R4,R4              DO WE HAVE A TABLE YET?              00063900
          BNZ   TACKITON           YES--> TACK THIS GUY ON THE END      00064000
*                                                                       00064100
          ST    R1,VS$#@CTL        NO--> SAVE BEGINNING ADDRESS         00064200
          LR    R4,R1              SET FC DSECT REG                     00064300
          MVC   FCPREV,=F'-1'      SET BACKWARD CHAIN = X"FF"S          00064400
          B     BLDFILE            GO BUILD ENTRY/RPL'S/ACB             00064500
*                                                                       00064600
TACKITON  DS    0H                                                      00064700
*                                                                       00064800
          ST    R1,FCNEXT          SET FOWARD CHAIN TO NEW AREA         00064900
          LR    R2,R4              SAVE PREV ADDR                       00065000
          LR    R4,R1              SET FC DSECT REG TO NEW ENTRY        00065100
          ST    R2,FCPREV          SET BACKWARD CHAIN                   00065200
BLDFILE   DS    0H                                                      00065300
          MVC   FCNEXT,=F'-1'      SET FOWARD PTR = EOC                 00065400
          MVC   FCDDNAME,VS$#@FIL  SET DDNAME                           00065500
          SPACE                                                         00065600
          LA    R0,VSCBLEN         GET LENGTH OF ACB/RPL BLOCK          00065700
          GETMAIN R,LV=(0)                                              00065800
          SPACE                                                         00065900
          MVC  0(VSCBLEN,R1),VSACB MOVE DUMMY CONTROL BLOCKS IN         00066000
          ST    R1,FCACBAD         STORE ACB ADDRESS                    00066100
          LA    R15,VSSRPLOF(,R1)   SET R15 AT SEQ RPL ADDR             00066200
          ST    R15,FCSRPLAD       STORE IT IN SEQ RPL ADDR             00066300
          LA    R15,VSRRPLOF(,R1)   SET R15 AT RANDOM RPL ADDR          00066400
          ST    R15,FCRRPLAD       STORE IT IN RANDOM RPL ADDR          00066500
          SPACE                                                         00066600
          L     R15,FCSRPLAD       NOW SET RPL PTRS TO APPROPRIATE      00066700
          USING IFGRPL,R15         ADDRESS                              00066800
          SPACE                                                         00066900
          MVC   RPLDACB,FCACBAD    SET ACB ADDRESS IN RPL               00067000
          LA    R1,FCKEY           ADDR OF KEY IN R1                    00067100
          ST    R1,RPLARG          STORE KEY ADDR IN RPL                00067200
          SPACE                                                         00067300
          L     R15,FCRRPLAD       DO RANDOM RPL ALSO                   00067400
          SPACE                                                         00067500
          MVC   RPLDACB,FCACBAD    SET ACB ADDRESS IN RPL               00067600
          LA    R1,FCKEY           ADDR OF KEY IN R1                    00067700
          ST    R1,RPLARG          STORE KEY ADDR IN RPL                00067800
          DROP  R15                                                     00067900
          L    R1,FCACBAD         GET ACBADDR                           00068000
          USING IFGACB,R1                                               00068100
          MVC   ACBDDNM,VS$#@FIL  SET FILENAME IN ACB                   00068200
         DROP  R1                                                       00068300
          L     R14,SAVER14                                             00068400
          BR    R14                                                     00068500
*                                                                       00068600
          EJECT                                                         00068700
*********************************************************************** 00068800
*                 DELETE FILE FROM CONTROL TABLE                      * 00068900
*********************************************************************** 00069000
*      THIS ROUTINE ASSUMES THAT R4 CONTAINS THE CURRENT FILE        *  00069100
*         ENTRY TO BE DELETED.                                       *  00069200
*   THIS ROUTINE WILL RELEASE ALL STORAGE ACQUIRED FOR A CLOSED      *  00069300
*  FILE CONTROL TABLE ENTRY, AND ADJUST THE FC CHAIN APPROPRIATELY.  *  00069400
*                                                                    *  00069500
*********************************************************************** 00069600
          SPACE                                                         00069700
DELFILE   DS    0H                                                      00069800
          SPACE                                                         00069900
          ST    R14,SAVER14                                             00070000
*                                                                       00070100
          L     R1,FCACBAD         GET ADDRESS OF ACB                   00070200
          LA    R0,VSCBLEN         GET LENGTH OF ACB/RPL BLOCK          00070300
          FREEMAIN R,LV=(0),A=(1)                                       00070400
          SPACE                                                         00070500
*                                                                       00070600
          L     R0,FCPREV          R0= PREV ENTRY ADDR                  00070700
          L     R1,FCNEXT          R1= NEXT ENTRY ADDR                  00070800
          LR    R7,R4              AND REMEMBER WHO GETS DELETED        00070900
*                                                                       00071000
          C     R0,=F'-1'        1ST ENTRY?                             00071100
          BE    CKNEXTE            YES--> SEE IF NEXT ENTRY             00071200
          LR    R4,R0              NO--> SET R4 TO PREV ENTRY           00071300
          ST    R1,FCNEXT          PUT FOWARD POINTER IN PREV ENTRY     00071400
*                                                                       00071500
          C     R1,=F'-1'        WAS THIS THE LAST GUY?                 00071600
          BE    FREEIT             YES--> WERE DONE! FREEMAIN IT        00071700
          LR    R4,R1              NO--> SET R4 TO NEXT ENTRY           00071800
          ST    R0,FCPREV          PUT BACKWARD PTR IN NEXT ENTRY       00071900
          B     FREEIT             AND GO FREE THE AREA                 00072000
*                                                                       00072100
CKNEXTE   DS    0H              ONLY IF WERE FREEING THE FIRST ENTRY    00072200
          XC    VS$#@CTL,VS$#@CTL  CLEAR THE CONTROL TAB ADDR           00072300
*                                  WERE GOING TO BE CHANGING IT ANYWAY  00072400
          C     R1,=F'-1'          FIRST AND ONLY?                      00072500
          BE    FREEIT             YES--> DONE!                         00072600
          LR    R4,R1              NO--> SET R4 TO NEXT ENTRY           00072700
          MVC   FCPREV,=F'-1'      INDICATE FIRST IN CHAIN              00072800
          ST    R4,VS$#@CTL        SAVE NEW CTL TAB START               00072900
*                                  AND FREE THE ENTRY                   00073000
FREEIT    DS    0H                                                      00073100
          LA    R0,FCELEN          GET THE ENTRY LENGTH                 00073200
          LR    R1,R7              GET ADDRESS OF ENTRY AREA            00073300
*                                                                       00073400
          FREEMAIN R,LV=(0),A=(1)                                       00073500
*                                                                       00073600
          L     R14,SAVER14                                             00073700
          BR    R14                                                     00073800
*                                                                       00073900
          EJECT                                                         00074000
*********************************************************************** 00074100
*                VSAM OPEN/CLOSE ERROR ROUTINES                       * 00074200
*********************************************************************** 00074300
INVKEY    DS    0H                                                      00074400
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS           00074500
          MVC   VSMBLD1+46(7),=CL7'POINT'                               00074600
          MVC   VSMBLD1+13(8),VS$#@FIL GET FILENAME                     00074700
          WTO   MF=(E,VSMBLD1)                                          00074800
          WTO   MF=(E,VSMINVK)                                          00074900
          MVC   VS$#@RCD,=X'FF0004'                                     00075000
          BR    R9                                                      00075100
          SPACE                                                         00075200
DELERR    DS    0H                                                      00075300
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS           00075400
          MVC   VSMBLD1+46(7),=CL7'DELETE'                              00075500
          MVC   VSMBLD1+13(8),VS$#@FIL GET FILENAME                     00075600
          WTO   MF=(E,VSMBLD1)                                          00075700
          WTO   MF=(E,VSMDELK)                                          00075800
          MVC   VS$#@RCD,=X'FF0004'                                     00075900
          BR    R9                                                      00076000
          SPACE                                                         00076100
INVOPER   DS    0H                                                      00076200
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS           00076300
          MVC   VSMBLD1+46(7),=CL7'UNKNOWN'                             00076400
          MVC   VSMBLD1+13(8),VS$#@FIL GET FILENAME                     00076500
          WTO   MF=(E,VSMBLD1)                                          00076600
          WTO   MF=(E,VSMINVO)                                          00076700
          MVC   VS$#@RCD,=X'FF0004'                                     00076800
          BR    R9                                                      00076900
          SPACE                                                         00077000
INVFILE   DS    0H                                                      00077100
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS           00077200
          MVC   VSMBLD1+46(7),=CL7'--N/A--'                             00077300
          MVC   VSMBLD1+13(8),VS$#@FIL GET FILENAME                     00077400
          WTO   MF=(E,VSMBLD1)                                          00077500
          WTO   MF=(E,VSMNOTO)                                          00077600
          MVC   VS$#@RCD,=X'080004'                                     00077700
          BR    R9                                                      00077800
          SPACE                                                         00077900
DUPOPEN   DS    0H                                                      00078000
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS           00078100
          MVC   VSMBLD1+46(7),=CL7'OPEN'                                00078200
          MVC   VSMBLD1+13(8),VS$#@FIL GET FILENAME                     00078300
          WTO   MF=(E,VSMBLD1)                                          00078400
          WTO   MF=(E,VSMDUPO)                                          00078500
          MVC   VS$#@RCD,=X'080004'                                     00078600
          BR    R9                                                      00078700
          SPACE                                                         00078800
VSERROC   DS    0H                                                      00078900
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS           00079000
          MVC   VSMBLD2(VSMSG2L),VSMSG2                                 00079100
*                                                                       00079200
          L     R1,FCACBAD         GET ACB ADDRESS                      00079300
          USING IFGACB,R1                                               00079400
*                                                                       00079500
          MVC   VSMBLD1+46(7),=CL7'OPEN'                                00079600
          CLI   TESTBYTE,VS$#OPEN  OPEN REQUEST?                        00079700
          BE    CHKERR             YES--> GO CHECK ERROR TYPE           00079800
          MVC   VSMBLD1+46(7),=CL7'CLOSE' OTHERWISE SET AS CLOSE        00079900
*                                                                       00080000
CHKERR    DS    0H                                                      00080100
          STC   R15,VS$#@RCD       STORE R15 VALUE IN PLIST             00080200
          MVC   VS$#@RCD+L'VS$#@RCD-1(1),ACBERFLG                       00080300
          B     DOMSGS             GO WRITE MESSAGES TO LOG             00080400
          DROP  R1                                                      00080500
          SPACE                                                         00080600
VSERRMC   DS    0H                                                      00080700
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS           00080800
          MVC   VSMBLD2(VSMSG2L),VSMSG2                                 00080900
*                                                                       00081000
          L     R1,FCACBAD         GET ACB ADDRESS                      00081100
          USING IFGACB,R1                                               00081200
*                                                                       00081300
          MVC   VSMBLD1+46(7),=CL7'MODCB'                               00081400
          STC   R15,VS$#@RCD       STORE R15 VALUE IN PLIST             00081500
          MVC   VS$#@RCD+L'VS$#@RCD-1(1),ACBERFLG                       00081600
          B     DOMSGS             GO WRITE MESSAGES TO LOG             00081700
          DROP  R1                                                      00081800
          EJECT                                                         00081900
*********************************************************************** 00082000
*                VSAM I/O REQUEST ERROR ROUTINE                       * 00082100
*********************************************************************** 00082200
          SPACE                                                         00082300
VSERREQ   DS    0H                                                      00082400
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS           00082500
          MVC   VSMBLD2(VSMSG2L),VSMSG2                                 00082600
*                                                                       00082700
          USING IFGRPL,R1                                               00082800
          STC   R15,VS$#@RCD          STORE R15 VALUE                   00082900
          MVC   VS$#@RCD+L'VS$#@RCD-1(1),RPLERRCD   ERROR CODE          00083000
*                                                                       00083100
          MVC   VSMBLD1+46(7),=CL7'GET'   SET OPERATION TYPE            00083200
          CLI   RPLREQ,RPLGET      GET REQUEST?                         00083300
          BE    DOMSGS             YES--> GOTIT                         00083400
          MVC   VSMBLD1+46(7),=CL7'PUT'   SET OPERATION TYPE            00083500
          CLI   RPLREQ,RPLPUT      PUT REQUEST?                         00083600
          BE    DOMSGS             YES--> GOTIT                         00083700
          MVC   VSMBLD1+46(7),=CL7'POINT' SET OPERATION TYPE            00083800
          CLI   RPLREQ,RPLPOINT    POINT REQUEST?                       00083900
          BE    DOMSGS             YES--> GOTIT                         00084000
          MVC   VSMBLD1+46(7),=CL7'ERASE' SET OPERATION TYPE            00084100
          CLI   RPLREQ,RPLERASE    ERASE REQUEST?                       00084200
          BE    DOMSGS             YES--> GOTIT                         00084300
          MVC   VSMBLD1+46(7),=CL7'ENDREQ' SET OPERATION TYPE           00084400
          CLI   RPLREQ,RPLENDRE    ERASE REQUEST?                       00084500
          BE    DOMSGS             YES--> GOTIT                         00084600
          MVC   VSMBLD1+46(7),=CL7'UNKNOWN' SET OPERATION TYPE          00084700
*                                                                       00084800
DOMSGS    DS    0H                                                      00084900
          MVC   VSMBLD1+13(8),VS$#@FIL GET FILENAME                     00085000
          MVI   VSMBLD2+19,0  MAKE R15 VALUE DISPLAYABLE HEX            00085100
          MVZ   VSMBLD2+19(1),VS$#@RCD                                  00085200
          MVI   VSMBLD2+20,0                                            00085300
          MVN   VSMBLD2+20(1),VS$#@RCD                                  00085400
          TR    VSMBLD2+19(2),=C'0123456789ABCDEF'                      00085500
*                                                                       00085600
          SR    R7,R7                                                   00085700
          ICM   R7,3,VS$#@RCD+1     GET VSAM ERROR CODE                 00085800
          CVD   R7,DBLWRD                                               00085900
          OI    DBLWRD+L'DBLWRD-1,X'0F'                                 00086000
          UNPK  VSMBLD2+37(4),DBLWRD+L'DBLWRD-3(3)                      00086100
          SPACE                                                         00086200
          CLI   VS$#@RCD+L'VS$#@RCD-1,X'04' EOF?                        00086300
          BE    EOFNRF                                                  00086400
          CLI   VS$#@RCD+L'VS$#@RCD-1,X'10' NRF?                        00086500
          BE    EOFNRF                                                  00086600
          CLI   VS$#@RCD+L'VS$#@RCD-1,X'08' DUP RECORD?                 00086700
          BER   R9                          YES--> NO MESSAGE PLEASE    00086800
WRITMSG   DS    0H                                                      00086900
          WTO   MF=(E,VSMBLD1)                                          00087000
          WTO   MF=(E,VSMBLD2)                                          00087100
*                                                                       00087200
         CLI   TESTBYTE,VS$#CLOS  CLOSE REQUEST?                        00087300
         BE    FCCLOSR            YES--> FREE AREAS                     00087400
         CLI   TESTBYTE,VS$#OPEN  OPEN REQUEST?                         00087500
         BNER  R9                 NO--> EXIT                            00087600
         CLI   VS$#@RCD,X'04'     WARNING?                              00087700
         BE    FCOPENR            YES--> CONTINUE WITH OPEN PROCESSING  00087800
          BR    R9                NO--> EXIT                            00087900
EOFNRF    DS    0H                                                      00088000
          MVC   VS$#@RCD,=X'040004' INDICATE EOFNRF                     00088100
          NI    RPLOPT2,255-RPLUPD  RESET RPL UPDATE FLAG               00088200
         AIF   (NOT &TEST).NOTEST2                                      00088300
          WTO   MF=(E,TREOFMSG)                                         00088400
.NOTEST2 ANOP  ,                                                        00088500
          BR    R9                                                      00088600
          DROP  R1                                                      00088700
          EJECT                                                         00088800
         AIF   (NOT &TEST).NOTEST3                                      00088900
FCTRACE  DS    0H                                                       00089000
         ST    R14,TRSAV14                                              00089100
*                                                                       00089200
          MVC   TRMBLD1(TRMSG1L),TRMSG1   MESSAGE BUILD AREAS           00089300
          MVC   TRMBLD2(TRMSG2L),TRMSG2   MESSAGE BUILD AREAS           00089400
*                                                                       00089500
         CLI   TESTBYTE,TROPENT                                         00089600
         BH    FCUNKN             BAD CODE                              00089700
         XR    R7,R7                                                    00089800
         IC    R7,TESTBYTE        GET LOW HALF OF OPER                  00089900
         MH    R7,=AL2(L'TROPTAB)                                       00090000
         A     R7,=A(TROPTAB)                                           00090100
*                                                                       00090200
          MVC   TRMBLD1+46(7),0(R7)       SET OPERATION TYPE            00090300
*                                                                       00090400
          CLI   TESTBYTE,VS$#READ  READ REQ?                            00090500
          BH    TRMSGS             HIGH--> NO SUBFLAGS                  00090600
          BE    TRREAD            EQ--> CHECK SUBFLAG                   00090700
*                                                                       00090800
          CLI   TESTBYTE,VS$#OPEN  OPEN REQ?                            00090900
          BNE   MUSBCLOS           NO--> MUST BE CLOSED                 00091000
*                                                                       00091100
          MVI   TRMBLD1+50,C'U'    OPEN UPDATE                          00091200
         TM    VS$#@FNC,VS$#OUPD  IS IT?                                00091300
         BO    TRMSGS                                                   00091400
*                                                                       00091500
          MVI   TRMBLD1+50,C'L'    OPEN LOAD                            00091600
         TM    VS$#@FNC,VS$#OLOD  IS IT?                                00091700
         BO    TRMSGS                                                   00091800
*                                                                       00091900
          MVI   TRMBLD1+50,C' '    OPEN READ ONLY                       00092000
         TM    VS$#@FNC,VS$#ORDO  IS IT?                                00092100
         BO    TRMSGS                                                   00092200
*                                                                       00092300
          MVC   TRMBLD1+50(2),=C'RU'  RESET/UPD                         00092400
         B     TRMSGS                                                   00092500
TRREAD   DS    0H                                                       00092600
          MVI   TRMBLD1+50,C'U'    READ UPDATE                          00092700
         TM    VS$#@FNC,VS$#RUPD  IS IT?                                00092800
         BO    TRMSGS                                                   00092900
          MVI   TRMBLD1+50,C'O'    READ ONLY                            00093000
         B     TRMSGS                                                   00093100
MUSBCLOS DS    0H                                                       00093200
         TM    VS$#@FNC,VS$#CLSA                                        00093300
         BZ    TRMSGS                                                   00093400
         MVC   TRMBLD1+51(2),=C'AL'                                     00093500
         B     TRMSGS                                                   00093600
FCUNKN    MVC   TRMBLD1+46(7),=CL7'UNKNOWN' SET OPERATION TYPE          00093700
TRMSGS    DS    0H                                                      00093800
          MVC   TRMBLD1+13(8),VS$#@FIL GET FILENAME                     00093900
*                                                                       00094000
         CLI   VS$#@KYL,0         ANY KEY?                              00094100
         BNE   TRKEY                                                    00094200
         MVC   TRMBLD2+17(131),=CL131'NONE'                             00094300
         B     TRWTOIT                                                  00094400
TRKEY    DS    0H                                                       00094500
         XC    DECKEY,DECKEY      CLEAR KEY AREA                        00094600
         L     R7,VS$#@KEY        GET ADDRESS OF KEY                    00094700
         XR    R14,R14            CLEAR R14                             00094800
         IC    R14,VS$#@KYL       GET KEY LENGTH                        00094900
         LA    R8,DECKEY          GET TRANSLATED AREA                   00095000
         LA    R2,DECKEY+L'DECKEY END OF AREA                           00095100
LOOPIT   DS    0H                                                       00095200
         XR    R15,R15                                                  00095300
         IC    R15,0(R7)                                                00095400
         MVN   1(1,R8),0(R7)                                            00095500
         SRL   R15,4                                                    00095600
         STC   R15,0(R8)                                                00095700
         LA    R8,2(,R8)                                                00095800
         LA    R7,1(R7)                                                 00095900
         CR    R8,R2                                                    00096000
         BNL   TRDONE                                                   00096100
         BCT   R14,LOOPIT                                               00096200
TRDONE   DS    0H                                                       00096300
         TR    DECKEY,=C'0123456789ABCDEF'                              00096400
         LA    R7,DECKEY+L'DECKEY  R7 TO END OF KEY                     00096500
         CR    R7,R8                                                    00096600
         BNH   TRMVKEY                                                  00096700
         SR    R7,R8        SUBTRACT R8 FROM R7 = LENGTH REMAINING      00096800
         BCTR  R7,0               DECREMENT BY 1                        00096900
         EX    R7,FILLKEY                                               00097000
TRMVKEY  DS    0H                                                       00097100
         MVC   TRMBLD2+19(128),DECKEY                                   00097200
TRWTOIT  DS    0H                                                       00097300
          WTO   MF=(E,TRMBLD1)                                          00097400
          WTO   MF=(E,TRMBLD2)                                          00097500
         L     R14,TRSAV14                                              00097600
         BR    R14                                                      00097700
*                                                                       00097800
FILLKEY  MVC   0(1,R8),=CL128'"'                                        00097900
         EJECT                                                          00098000
TRMSG1    WTO   'VSAMIO - DDDDDDDD ACCESS TRACE, REQUEST = ZZZZZZZ',   X00098100
               ROUTCDE=(8,11),MF=L                                      00098200
TRMSG1L   EQU   *-TRMSG1                                                00098300
TRMSG2    WTO   'VSAMIO - KEY=X"NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNX00098400
               NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNX00098500
               NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN"',ROUTCDE=(8,11),MF=L  00098600
TRMSG2L   EQU   *-TRMSG2                                                00098700
TREOFMSG  WTO   'VSAMIO - EOF/NRF ENCOUNTERED',                        X00098800
               ROUTCDE=(8,11),MF=L                                      00098900
*                                                                       00099000
TROPTAB   DC    CL7'UNKNOWN'    TRACE OPERATION TABLE                   00099100
          DC    CL7'OPEN'                                               00099200
          DC    CL7'CLOSE'                                              00099300
          DC    CL7'READ'                                               00099400
          DC    CL7'WRITE'                                              00099500
          DC    CL7'DELETE'                                             00099600
          DC    CL7'POINT'                                              00099700
          DC    CL7'ENDREQ'                                             00099800
TROPENT   EQU   (*-TROPTAB)/L'TROPTAB    LET ASSEMBLER CALC #ENTRIES    00099900
.NOTEST3 ANOP  ,                                                        00100000
         EJECT                                                          00100100
**********************************************************************  00100200
*                                                                    *  00100300
**********************************************************************  00100400
*                                                                       00100500
SHELSHOK DS    0H                                                       00100600
*                                                                       00100700
         USING SHELSHOK,R15                                             00100800
*                                                                       00100900
         C     R0,=F'12'         ANY SDWA?                              00101000
         BNE   SDWAOK           YES-> GET PARAM FROM SDWA               00101100
*                                                                       00101200
         LR    R5,R2              PARMS ARE IN R2 IF NO SDWA            00101300
*                                                                       00101400
*                                                                       00101500
          MVI   VS$#@IND,0         CLEAR ACTIVE INDICATOR               00101600
          MVC   VS$#@RCD,=3X'FF'   MAJOR BAD ERROR CODE                 00101700
          LA    R1,VS$#@E02        GET ECB                              00101800
          POST  (1)                POST IT                              00101900
          SPACE                                                         00102000
*                                                                       00102100
         XR    R15,R15            CLEAR 15 = CONTINUE TERMINATION       00102200
         BR    R14                RETURN TO CP                          00102300
*                                                                       00102400
         DROP  R15                                                      00102500
SDWAOK   DS    0H                                                       00102600
          STM   R14,R12,12(R13)                                         00102700
          LR    R3,R15              3'S THE BASE                        00102800
          USING SHELSHOK,R3         RESET USING STATUS                  00102900
*                                                                       00103000
          GETMAIN R,LV=72,SP=0                                          00103100
          ST    R13,4(R1)           SET CHAIN                           00103200
          ST    R1,8(R13)           "       "                           00103300
          LR    R13,R1              GET SAVE AREA ADDR IN R13           00103400
*                                                                       00103500
          L     R1,4(R13)          GET CALLER SAVE AREA ADDR            00103600
          L     R1,24(R1)           RESTORE R1 CONTENTS FROM THEIR SAVE 00103700
         USING SDWA,R1                                                  00103800
         L     R5,0(R1)           AND ADDRESS OF PARM LIST ADDR         00103900
*                                                                       00104000
         SETRP WKAREA=(1),DUMP=YES,RC=0                                 00104100
*                                                                       00104200
          MVI   VS$#@IND,0         CLEAR ACTIVE INDICATOR               00104300
          MVC   VS$#@RCD,=3X'FF'   MAJOR BAD ERROR CODE                 00104400
          LA    R1,VS$#@E02        GET ECB                              00104500
          POST  (1)                POST IT                              00104600
          SPACE                                                         00104700
          L    R13,4(R13)         RESTORE CALLER SAVE AREA              00104800
         LM    R14,R12,12(R13)    THEN THE REGISTERS                    00104900
         XR    R15,R15 CLEAR R15                                        00105000
         BR    R14 EXIT                                                 00105100
*                                                                       00105200
         DROP  R1                                                       00105300
         DROP  R3                                                       00105400
         EJECT                                                          00105500
         LTORG                                                          00105600
          EJECT                                                         00105700
**********************************************************************  00105800
*                  DUMMY ACB AND RPL'S                               *  00105900
**********************************************************************  00106000
          SPACE                                                         00106100
VSACB     ACB   AM=VSAM,                                               X00106200
               BUFND=4,                                                X00106300
               BUFNI=6,                                                X00106400
               MACRF=(KEY,SEQ,IN),                                     X00106500
               STRNO=2                                                  00106600
          SPACE                                                         00106700
VSSRPL   RPL   ACB=VSACB,                                              X00106800
               OPTCD=(KEY,SEQ,NUP,KGE,MVE)                              00106900
          SPACE                                                         00107000
VSRRPL   RPL   ACB=VSACB,                                              X00107100
               OPTCD=(KEY,DIR,NUP,KGE,MVE)                              00107200
          SPACE                                                         00107300
VSCBLEN   EQU   *-VSACB            LENGTH OF VSAM CONTROL BLOCK AREAS   00107400
VSSRPLOF  EQU   VSSRPL-VSACB       OFFSET OF SEQ RPL FROM TOP           00107500
VSRRPLOF  EQU   VSRRPL-VSACB       OFFSET OF RANDOM RPL FROM TOP        00107600
          SPACE                                                         00107700
          EJECT                                                         00107800
VSMINVK   WTO   'VSAMIO - NO KEY SUPPLIED',                            X00107900
               ROUTCDE=(8,11),MF=L                                      00108000
VSMDELK   WTO   'VSAMIO - GENERIC KEY NOT ALLOWED FOR DELETE REQUEST', X00108100
               ROUTCDE=(8,11),MF=L                                      00108200
VSMINVO   WTO   'VSAMIO - INVALID OPERATION SUPPLIED/PARM LIST INVALID'X00108300
               ,ROUTCDE=(8,11),MF=L                                     00108400
VSMNOTO   WTO   'VSAMIO - FILE HAS NOT BEEN OPENED',                   X00108500
               ROUTCDE=(8,11),MF=L                                      00108600
VSMDUPO   WTO   'VSAMIO - FILE PREVIOUSLY OPENED',                     X00108700
               ROUTCDE=(8,11),MF=L                                      00108800
VSMSG1    WTO   'VSAMIO - DDDDDDDD ACCESS ERROR, REQUEST = ZZZZZZZ',   X00108900
               ROUTCDE=(8,11),MF=L                                      00109000
VSMSG1L   EQU   *-VSMSG1                                                00109100
VSMSG2    WTO   'VSAMIO - R15 = XX, RETURN CODE = NNNN DECIMAL',       X00109200
               ROUTCDE=(8,11),MF=L                                      00109300
VSMSG2L   EQU   *-VSMSG2                                                00109400
          EJECT                                                         00109500
WORKADS   DSECT ,                                                       00109600
DBLWRD    DS    D                                                       00109700
FULLWORD  DS    D                                                       00109800
VS$#@CTL  DS    F                  CONTROL TABLE BEGIN ADDRESS          00109900
SAVER14   DS    F                                                       00110000
FWORD     DS    F                                                       00110100
WHATRPL   DS    F                  SAVE ADDRESS OF RPL ACCESSED         00110200
TESTBYTE  DS    XL1                                                     00110300
VSMBLD1   DS    CL(VSMSG1L)                                             00110400
VSMBLD2   DS    CL(VSMSG2L)                                             00110500
         AIF   (NOT &TEST).NOTEST4                                      00110600
TRMBLD1  DS    CL(TRMSG1L)                                              00110700
TRMBLD2  DS    CL(TRMSG2L)                                              00110800
DECKEY   DS    CL128                                                    00110900
TRSAV14  DS    F                                                        00111000
.NOTEST4 ANOP  ,                                                        00111100
WORKALEN  EQU   *-WORKADS                                               00111200
VSIOMOD   CSECT ,                                                       00111300
          EJECT                                                         00111400
          VSAMIO ,FUNC=PLIST                                            00111500
          EJECT                                                         00111600
FCDSECT   DSECT ,                                                       00111700
FCBLOCK   DS    0F                 ALIGN THE STARS                      00111800
FCDDNAME  DS    CL8                DDNAME                               00111900
FCACBAD   DS    AL4                ADDRESS OF ACB                       00112000
FCSRPLAD  DS    AL4                SEQ RPL ADDRESS                      00112100
FCSAREA   DS    AL4                SEQ RECORD AREA ADDRESS              00112200
FCRRPLAD  DS    AL4                RANDOM RPL ADDRESS                   00112300
FCRAREA   DS    AL4                RANDOM RECORD AREA ADDRESS           00112400
FCPREV    DS    AL4                BACKWARD CHAIN                       00112500
FCNEXT    DS    AL4                FOWARD CHAIN                         00112600
FCKEY     DS    XL255              RECORD KEY                           00112700
FCFKEYL   DS    XL1                FULL KEY LENGTH                      00112800
FCFKEYD   DS    XL2                KEY DISPLACEMENT INTO RECORD         00112900
*                                                                       00113000
FCELEN    EQU   *-FCBLOCK                                               00113100
*********************************************************************** 00113200
*        SYSTEM DSECTS                                                * 00113300
*********************************************************************** 00113400
          IFGRPL DSECT=YES,AM=VSAM                                      00113500
          EJECT                                                         00113600
          IFGACB DSECT=YES,AM=VSAM                                      00113700
          EJECT                                                         00113800
          IHASDWA                                                       00113900
*                                                                       00114000
VSIOMOD   CSECT ,                                                       00114100
         END   VSIOMOD                                                  00114200
