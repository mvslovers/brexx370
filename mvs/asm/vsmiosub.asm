***********************************************************************
*                                                                     *
*       VSAM I/O PROCESSING MODULE
*   WRITTEN BY  : STEVE SCOTT                                         *
*           DATE: 02/89                                               *
*                                                                     *
***********************************************************************
* VSIOMOD  AMODE 31
* VSIOMOD  RMODE 24
***********************************************************************
*                  REGISTER USAGE                                     *
***********************************************************************
*                                                                     *
*    R0    -      WORK                                                *
*    R1    -      WORK/ADDRESS OF PARAMETER LIST                      *
*    R2    -      WORK                                                *
*    R3    -      BASE                                                *
*    R4    -      FILE CONTROL TABLE DSECT REGISTER                   *
*    R5    -      PARAMETER LIST DSECT REGISTER                       *
*    R6    -      WORK AREA DSECT REGISTER                            *
*    R7    -      WORK                                                *
*    R8    -      WORK                                                *
*    R9    -      RETURN ADDRESS *** DO * NOT * SCREW * !! ****       *
*    R10   -      ** UNUSED **                                        *
*    R11   -      ** UNUSED **                                        *
*    R12   -      ** UNUSED **                                        *
*    R13   -      PROGRAM SAVE AREA                                   *
*    R14   -      BAL/WORK                                            *
*    R15   -      WORK/SYSTEM                                         *
*                                                                     *
***********************************************************************
          EJECT
*         GBLB  &TEST
* &TEST     SETB  0     ******   SET TO 1 IF TRACING DESIRED ********
*
VSIOMOD   START 0
R0        EQU   0
R1        EQU   1
R2        EQU   2
R3        EQU   3
R4        EQU   4
R5        EQU   5
R6        EQU   6
R7        EQU   7
R8        EQU   8
R9        EQU   9
R10       EQU   10
R11       EQU   11
R12       EQU   12
R13       EQU   13
R14       EQU   14
R15       EQU   15
          EJECT
          STM   R14,R12,12(R13)
          LR    R3,R15              3'S THE BASE
          USING VSIOMOD,R3          RESET USING STATUS
*
          GETMAIN R,LV=72,SP=0
          ST    R13,4(R1)           SET CHAIN
          ST    R1,8(R13)
          LR    R13,R1              GET SAVE AREA ADDR IN R13
*
          L     R1,4(R13)          GET CALLER SAVE AREA ADDR
          L     R1,24(R1)           RESTORE R1 CONTENTS FROM THEIR SAVE
         L     R5,0(R1)           AND ADDRESS OF PARM LIST ADDR
         L     R5,0(R5)           AND ADDRESS OF PARM LIST
*
          USING VS$#@IOD,R5         SET UP USING
*
         ESTAE SHELSHOK,PARAM=(R5),ASYNCH=NO
*
          LA    R0,WORKALEN         LENGTH OF TEMP WORK AREAS
          GETMAIN R,LV=(0)
          LR    R6,R1               PUT IN R6
          LR   R14,R6   CLEAR THE WORKAREA
          LA   R15,WORKALEN       LENGTH OF AREA
         XR    R0,R0
         XR    R1,R1
         MVCL  R14,R0
          USING WORKADS,R6               SET UP USING
*
          MVI   VS$#@IND,VS$#@ACT  SET ACTIVE INDICATOR
          EJECT
***********************************************************************
*               ENTRY POINT AFTER WAIT ECB POSTED                     *
***********************************************************************
          SPACE
FROMDTOP  DS    0H                 HERES WHERE START AFTER WAIT POSTED
         LA    R9,RETURN          INITIALIZE RETURN ADDRESS
*
          USING FCDSECT,R4          R4 IS THE BASE FOR FILE CONTROL
*
          MVN   TESTBYTE,VS$#@FNC
         AIF   (NOT &TEST).NOTEST1
         BAL   R14,FCTRACE        GO DO TRACE ROUTINE
*
.NOTEST1 ANOP  ,
          CLI   TESTBYTE,VS$#OPEN   OPEN REQUEST?
          BE    CKOPER              YES--> FILE WONT BE FOUND ON OPEN
          ICM   R4,15,VS$#@CTL      GET CONTROL TAB ADDR
          BZ    INVFILE            NOT THERE--> ERROR
*
          CLI   VS$#@FNC,VS$#CLOS+VS$#CLSA CLOSE ALL?
          BE    CKOPER              YES--> DONT TRY TO FIND THE FILE
*
FCLOOP    DS    0H
          CLC   VS$#@FIL,FCDDNAME   THIS ENTRY?
          BE    CKOPER              YES--> GO CHECK AND PROCESS REQ
          L     R4,FCNEXT           GET FOWARD POINTER
          C     R4,=F'-1'           X'FF'S ?
          BE    INVFILE             YES--> FILE NOT FOUND - INVALID
          B     FCLOOP              GO BACK, JACK
*
CKOPER    DS    0H
          XR    R1,R1
          IC    R1,TESTBYTE         GET OPERATION
          SLL   R1,2               MULTIPLY BY 4
*=================>>>>>>>  WARNING...WARNING... <<<<<<<===============
*=================>>>>>>>  WARNING...WARNING... <<<<<<<===============
*   IF ANY OTHER OPERATIONS ARE TO BE ADDED THIS TEST BETTER BE CHANGED
*********************************
          CLI   TESTBYTE,VS$#ENRQ   HIGHER THAN LAST OP?
*********************************
          BH    INVOPER             YES--> INVALID
          B     BRTAB(R1)           GO DO OPERATION
BRTAB     DS    0H
          B     INVOPER             0 IS INVALID
          B     FCOPEN
          B     FCCLOSE
          B     FCREAD
          B     FCWRITE
          B     FCDELET
          B     FCPOINT
          B     FCENDREQ
          DC    D'0'               JUST IN CASE WE GO A LITTLE TOO FAR
          EJECT
***********************************************************************
*                    EVERYBODY COMES BACK HERE!                       *
***********************************************************************
          SPACE
RETURN    DS    0H
*
          LA    R1,VS$#@E02        GET ECB MOMMA IS WAITING ON
          POST  (1)                GIVE 'ER THAT BAD BOY
*
         TM    VS$#@E01,X'40'     HAS IT BEEN POSTED?
         BO    RETNOWT            YES--> DONT WAIT
          LA    R1,VS$#@E01        LETS WAIT TILL WERE NOTIFIED
          WAIT  ECB=(1)
RETNOWT  DS    0H
          XC   VS$#@E01,VS$#@E01  CLEAR ECB
*
          B     FROMDTOP
DETACH    DS    0H
*
          MVI   VS$#@IND,0         CLEAR ACTIVE INDICATOR
          LA    R1,VS$#@E02        GET ECB MOMMA IS WAITING ON
          POST  (1)                GIVE 'ER THAT BAD BOY
          SPACE
          ESTAE 0                 REMOVE OUR EXIT
*
          LA    R1,VS$#@E01        LETS WAIT TILL WERE DETACHED
          WAIT  ECB=(1)
*                                 SHOULDN'T GET HERE, BUT IF....
         DC    D'0'
*
          EJECT
***********************************************************************
*                    FILE OPEN ROUTINE                                *
***********************************************************************
          SPACE
FCOPEN    DS    0H
          SPACE
          ICM   R4,15,VS$#@CTL     GET FIRST CTL BLOCK ADDR
          BZ    ADDITON            NOT THERE--> ADD THE FIRST FILE
*
FCFINDIT  DS    0H
          CLC   VS$#@FIL,FCDDNAME   FOUND FILE?
          BE    DUPOPEN             NOT ALLOWED, SIR
          L     R1,FCNEXT           GET NEXT ENTRY
          C     R1,=F'-1'           AT END?
          BE    ADDITON             YES--> GO ADD FILE
          LR    R4,R1              NEXT ADDRESS IN R4
          B     FCFINDIT           GO TRY TO FIND THE FILE
*
ADDITON   BAL   R14,ADDFILE         GO ADD THE FILE ENTRY
*
          CLC   VS$#@FTY,=CL4'ESDS'  ENTRY SEQUENCED?
          BNE   OPN4WRD             NO--> GO FORWARD WITH THE OPEN!
         SPACE
         L     R2,FCACBAD      GET ACB ADDRESS
         MODCB ACB=(2),MACRF=(ADR,SEQ,IN)
          LTR   R15,R15             CHECK FOR ERROR
          BNZ   VSERRMC             IF SO --> GO
         L     R2,FCSRPLAD     GET SEQ RPL ADDR
         MODCB RPL=(2),OPTCD=(ADR,SEQ,NUP,MVE)
          LTR   R15,R15             CHECK FOR ERROR
          BNZ   VSERRMC             IF SO --> GO
         L     R2,FCRRPLAD     GET SEQ RPL ADDR
         MODCB RPL=(2),OPTCD=(ADR,SEQ,NUP,MVE)
          LTR   R15,R15             CHECK FOR ERROR
          BNZ   VSERRMC             IF SO --> GO
OPN4WRD  DS    0H
         SPACE
          L     R15,FCACBAD         GET ADDR OF ACB
          USING IFGACB,R15
         SPACE
         CLC   VS$#@DBF,=H'0'    ANY DATA BUFFERS REQ?
         BE    CKIBUF            NO--> CHECK INDEX BUFFERS
         MVC   ACBBUFND,VS$#@DBF  MOVE NUMBER OF BUFFERS IN
CKIBUF   DS    0H
         CLC   VS$#@IBF,=H'0'     ANY INDEX REQUESTED?
         BE    NOPERS             NOPE
         MVC   ACBBUFNI,VS$#@IBF  MOVE INDEX BUFFERS IN
NOPERS   DS    0H
          TM    VS$#@FNC,VS$#ORDO   OPEN FOR READ ONLY?
          BO    OPENIT              YES-> OPENIT!
          NI    ACBMACR1,255-ACBIN  TURN OFF READ FLAG
          OI    ACBMACR1,ACBOUT     NO--> SET ACB FOR OUTPUT
          TM    VS$#@FNC,VS$#OLOD+VS$#ORSU   OPEN FOR LOAD OR RESET/UPD
          BZ    OPENIT              NO--> OPEN AS UPDATE
          OI    ACBMACR2,ACBRST     SET TO RESET FILE TO EMPTY
          MVI   ACBSTRNO,X'01'      STRINGS = 1
*
OPENIT    DS    0H
          LR    R2,R15              PUT ACB ADDRESS IN R2
          OPEN  ((2))               OPEN IT
          LTR   R15,R15             CHECK FOR ERROR
          BNZ   VSERROC             IF SO --> GO
*
FCOPENR  DS    0H
*
          L     R7,FCACBAD         GET ACB ADDRESS
          LA    R1,DBLWRD
*
         SHOWCB AREA=(1),                                              X
               FIELDS=(KEYLEN,LRECL,RKP),                              X
               LENGTH=12,                                              X
               ACB=(7)
*
          LTR   R15,R15             DID WE GET THE KEYLENGTH?
          BNZ   VSERROC            NO--> ERROR
          MVC   FCFKEYL,DBLWRD+3    SAVE FULL KEY LENGTH
          MVC   FCFKEYD,FULLWORD+2  SAVE KEY DISPLACEMENT
          MVC   VS$#@KYL,FCFKEYL    SAVE KEY LENGTH IN COMAREA
          MVC   VS$#@KYD,FCFKEYD    SAVE KEY OFFSET IN COMAREA
          L     R0,DBLWRD+4        GET RECORD LENGTH FROM SHOWCB
          GETMAIN R,LV=(0)
          ST    R1,FCSAREA         STORE AREA ADDRESS IN FC TABLE
          L     R0,DBLWRD+4        GET RECORD LENGTH FROM SHOWCB
          GETMAIN R,LV=(0)
          ST    R1,FCRAREA         STORE AREA ADDRESS IN FC TABLE
*
          USING IFGRPL,R1
          L     R1,FCSRPLAD
          L     R0,DBLWRD+4        GET RECORD LENGTH FROM SHOWCB
          ST    R0,RPLRLEN          GET RECORD LENGTH IN RPL
          ST    R0,RPLBUFL          STORE LENGTH OF AREA
          MVC   RPLAREA,FCSAREA    SET AREA ADDR IN RPL
          L     R1,FCRRPLAD         GET RANDOM RPL ADDR
          ST    R0,RPLRLEN          AND STORE LENGTH THERE, TOO
          ST    R0,RPLBUFL          STORE LENGTH OF AREA
          MVC   RPLAREA,FCRAREA    SET AREA ADDR IN RPL
*
          TM    VS$#@FNC,VS$#ORSU   OPEN FOR RESET / UPDATE?
          BO    ORESUP              YES--> DO DUMMY ROUTINE
          STH   R0,VS$#@RLN        STORE LENGTH IN PARAMETER LIST
*
          TM    VS$#@FNC,VS$#OLOD   OPENED FOR LOAD?
          BO    NOPOINT             YES--> SKIP THE POINT
*
          L     R1,FCSRPLAD
          XC    FCKEY,FCKEY         CLEAR KEY FIELD
          POINT RPL=(1)
*                                   POINT TO 1ST RECORD ON SEQ
*                                   RPL. THIS IS DONE TO COMPENSATE
*                                   FOR THE INCONSISTANCY WITH IBM
*                                   DOCUMENTATION ON CONCURRENT
*                                   PROCESSING USING STRINGS
          DROP  R15
          DROP  R1
NOPOINT   DS    0H
          BR    R9
         SPACE
ORESUP   DS    0H
         SPACE
         CLC   VS$#@RLN,=H'0'     LENGTH SUPPLIED?
         BNE   SUPPLEN            YES--> SKIP STORE
         STH   R0,VS$#@RLN        SAVE LENGTH FROM OPEN
SUPPLEN  DS    0H
         L     R1,FCSRPLAD        SEQUENTIAL RPL ADDR IN 1
         USING IFGRPL,R1
         L     R14,RPLAREA        GET AREA ADDRESS
         LH    R15,VS$#@RLN       YES--> PUT LENGTH IN R15
         DROP  R1
         XR    R1,R1              CLEAR THE AREA
         LR    R0,R1
         MVCL  R14,R0
*
         BAL   R9,FCWRITE         GO EXECUTE WRITE ROUTINE FOR DUMMY
         MVI   VS$#@FNC,X'00'     SET FUNCTION BYTE  0  INTERNAL SW
         BAL   R9,FCCLOSE         DO CLOSE ROUTINE
         OI    VS$#@FNC,VS$#OPEN+VS$#OUPD
         LA    R9,RETURN
         B     FCOPEN
          EJECT
***********************************************************************
*                    FILE CLOSE ROUTINE                               *
***********************************************************************
          SPACE
FCCLOSE   DS    0H
          SPACE
          TM    VS$#@FNC,VS$#CLSA   CLOSE ALL?
          BZ    FCLOSIT             NO--> CONTINUE
*
          L     R4,VS$#@CTL        GET BEGINNING CONTROL TABLE ADDR
*
FCLOSIT   DS    0H
          MVC   VS$#@FIL,FCDDNAME  MOVE DDNAME TO PARM LIST
          L     R1,FCRRPLAD       GET RANDOM RPL ADDR
          USING IFGRPL,R1
          L     R7,RPLBUFL         GET RECORD LENGTH BEFORE WE CLOSE
          DROP  R1
          L    R2,FCACBAD         ACB ADDR IN R2
          CLOSE ((2))              CLOSE THE FILE
*
          LTR   R15,R15            CHECK FOR ERROR
          BNZ   VSERROC
*
FCCLOSR   DS    0H                 RETURN ADDRESS ON CLOSE ERROR
*                                  BECAUSE WE STILL WANT TO FREE
*                                  ASSOCIATED AREAS
          LR    R0,R7
          L     R1,FCSAREA         FREE SEQ I/O AREA ADRESS
          FREEMAIN R,LV=(0),A=(1)
          LR    R0,R7              RESET LENGTH
          L     R1,FCRAREA         FREE RANDOM I/O AREA ADRESS
          FREEMAIN R,LV=(0),A=(1)
*
          BAL   R14,DELFILE        GO DELETE FILE ENTRY FROM TABLE
*
          ICM   R1,15,VS$#@CTL     IS CTL TABLE ADDR ZEROS?
          BNZ   CKCLOSA            NO--> CHECK IF CLOSE ALL
          CLI  VS$#@FNC,X'00'     INTERNAL FUNCTION?
          BER   R9                YES--> RETURN DO NOT DETACH
          B     DETACH             ALL GONE--> DETACH
*                                  AND FREE ASSOCIATED BLOCKS
CKCLOSA  DS    0H
          TM    VS$#@FNC,VS$#CLSA   CLOSE ALL?
          BO    FCLOSIT             YES--> CONTINUE
          BR    R9                  NO--> RETURN
*
          EJECT
***********************************************************************
*                    FILE READ ROUTINE                               *
***********************************************************************
          SPACE
FCREAD    DS    0H
          SPACE
          USING IFGRPL,R1
*
          L     R1,FCSRPLAD       GET SEQUENTIAL RPL ADDR
          CLI  VS$#@KYL,0         ANY KEY?
          BE   FCRPLOK            NO--> USE SEQ RPL
          L     R1,FCRRPLAD       YES--> USE RANDOM RPL
FCRPLOK  DS    0H
          TM    VS$#@FNC,VS$#RUPD  READ FOR UPDATE?
          BZ    FCREADO            NO--> SET READ ONLY
          OI    RPLOPT2,RPLUPD     TURN UPDATE FLAG ON
          B    CKKEYF
FCREADO  DS    0H
          NI    RPLOPT2,255-RPLUPD ASSURE UPDATE FLAG OFF
          DROP  R1
CKKEYF    DS    0H
          ICM   R1,15,VS$#@KEY     ANY KEY?
          BZ    SEQREAD            NOT PRESENT--> ASSUME SEQ ACCESS
          XC    FCKEY,FCKEY        CLEAR KEY AREA
          XR    R7,R7              CLEAR R7
          IC    R7,VS$#@KYL        INSERT KEY LENGTH
          BCTR  R7,0               DECREMENT FOR MOVE
          EX    R7,MOVEKEY         MOVE THE KEY IN
*
          L     R1,FCRRPLAD        RANDOM RPL ADDRESS IN R1
FCSVNGET DS    0H
          ST    R1,WHATRPL         SAVE ADDRESS FOR LATER
*
          GET   RPL=(1)
*
          LTR   R15,R15            IF ERROR, INVESTIGATE
          BNZ   VSERREQ
*
          CLC   FCFKEYL,VS$#@KYL   GENERIC READ?
          BH    MOVEREC            YES--> GIVE EM WHAT WE GOT
          XR    R8,R8
          ICM   R8,B'0011',FCFKEYD GET KEY DISPLACEMENT
          XR    R7,R7
          IC    R7,FCFKEYL         FULL KEY LENGTH IN R7
          BCTR  R7,0               DOWN BY 1 FOR EX COMPARE
          L     R1,FCRAREA         GET RANDOM RECORD ADDRESS
          AR   R1,R8              BUMP TO KEY OFFSET
          EX    R7,KEYCLC          COMPARE THE KEY
          BE    MOVEREC            EQUAL--> OK
          BAL   R9,FCENDREQ        RELEASE THE RECORD WE JUST READ
          LA    R9,RETURN          RESET RETURN ADDRESS
          B     EOFNRF             NOT EQUAL--> NOT FOUND
*
SEQREAD   DS    0H
          L     R1,FCSRPLAD        GET SEQ RPL ADDRESS
          ST    R1,WHATRPL         SAVE ADDRESS FOR LATER
*
          GET   RPL=(1)
*
          LTR   R15,R15            ERROR?
          BNZ   VSERREQ            YES--> CHECK IT OUT
*
MOVEREC   DS    0H
          L     R1,WHATRPL         GET RPL ADDRES WE JUST ACCESSED
          USING IFGRPL,R1
*
          L     R14,RPLAREA   GET FROM ADDRESS(EITHER FCRAREA/FCSAREA)
          L     R15,RPLRLEN        AND LENGTH OF RECORD READ
* TRLOOP   CLI   0(R14),X'00'
*         BNE   TRLNXT
*         MVI   0(R14),C' '
*TRLNXT   LA    R14,1(R14)
*         BCT   R15,TRLOOP
*         L     R14,RPLAREA   GET FROM ADDRESS(EITHER FCRAREA/FCSAREA)
*         L     R15,RPLRLEN        AND LENGTH OF RECORD READ
          STH   R15,VS$#@RLN       STORE LENGTH IN PARAMETER LIST
          ICM   R0,15,VS$#@ARE     DID THEY SUPPLY A RECORD ADDRESS?
          BZ    NOMOVE             NO--> SUPPLY ONLY OUR ADDRESS
          DROP  R1
          LR    R1,R15             PUT LENGTH IN R1 ALSO
          MVCL  R0,R14             MOVE RECORD TO USER AREA
*
          BR    R9
*
NOMOVE    DS    0H
          ST    R14,VS$#@ARE        STORE IN PARAMETER LIST
          BR    R9                 AND EXIT
*
MOVEKEY   MVC   FCKEY(0),0(R1)     EXECUTED MOVE
KEYCLC    CLC   FCKEY(0),0(R1)    EXECUTED COMPARE
          EJECT
***********************************************************************
*                    FILE WRITE ROUTINE                              *
***********************************************************************
          SPACE
FCWRITE   DS    0H
          SPACE
          ICM   R1,15,VS$#@KEY     GET ADDRESS OF KEY
          BZ    SEQWRITE           NOT PRESENT--> ASSUME SEQ WRITE
*
          L     R1,FCRRPLAD        RANDOM RPL ADDRESS IN R1
          LR    R7,R1              PUT ADDRESS IN R7
          B     CKMOVEIT
*
SEQWRITE  DS    0H
          L     R1,FCSRPLAD        GET SEQ RPL ADDRESS
          LR    R7,R1              PUT ADDR IN R7
*
CKMOVEIT  DS    0H
          USING IFGRPL,R1
          L     R14,RPLAREA   GET TO ADDRESS(EITHER FCRAREA/FCSAREA)
          L     R15,RPLBUFL       SET MAX LENGTH AS DEFAULT
          CLI   RPLREQ,RPLGET     WAS LAST REQUEST A GET?
          BE    FCCKUPD           YES--> GO CHECK IF UPDATE
          NI    RPLOPT2,255-RPLUPD  NO--> TURN OFF UPDATE FLAG IF ON
          B     FCCKRLEN          AND USE MAX FOR DEFAULT
FCCKUPD  DS    0H                 CHECK IF UPDATE
          TM    RPLOPT2,RPLUPD    FOR UPDATE?
          BZ    FCCKRLEN          NO---> USE MAX LENGTH AS DEFAULT
          L     R15,RPLRLEN       PREVIOUS REQUEST WAS READ/UPDATE
*                                 SO DEFAULT IS LENGTH OF RECORD READ
FCCKRLEN  DS    0H
          CLC   VS$#@RLN,=H'0'     DID THEY SUPPLY A LENGTH?
          BE    NOPE               NO--> USE RPL LENGTH
          LH    R15,VS$#@RLN       YES--> PUT LENGTH IN R15
NOPE      DS    0H
          ST    R15,RPLRLEN        STORE NEW/OLD LENGTH IN RPL
*
          TM    VS$#@FNC,VS$#OPEN
          BO    PUTIT         DON'T CHECK AREA ON OPEN RESET/UPD
*
          ICM   R0,15,VS$#@ARE     DID THEY SUPPLY A RECORD ADDRESS?
          BZ    PUTIT              NO--> THEY UPDATED IN OUR AREA
          DROP  R1
          LR    R1,R15             PUT LENGTH IN R1 ALSO
          MVCL  R14,R0             MOVE USER AREA TO OURS
*
PUTIT     DS    0H
          PUT   RPL=(7)
*
          LTR   R15,R15            IF ERROR, INVESTIGATE
          BNZ   VSERREQ
*
          BR    R9
*
          EJECT
***********************************************************************
*                    FILE DELETE ROUTINE                              *
***********************************************************************
          SPACE
FCDELET   DS    0H
          SPACE
          ICM   R1,15,VS$#@KEY     GET ADDRESS OF KEY
          BNZ   RANDELET           PRESENT--> DO RANDOM DELETE
*
          L     R1,FCSRPLAD        GET SEQ RPL ADDRESS
          B     BYEBYE            NO AUTOREAD ON SEQ DELETE
*
RANDELET  DS    0H
          CLC   FCFKEYL,VS$#@KYL   IS IT A FULL KEY DELETE?
          BNE   DELERR             NO--> ERROR
*
          XC    FCKEY,FCKEY        CLEAR KEY AREA
          XR    R7,R7              CLEAR R7
          IC    R7,VS$#@KYL        INSERT KEY LENGTH
          BCTR  R7,0               DECREMENT FOR MOVE
          EX    R7,MOVEKEY         MOVE THE KEY IN
*
          L     R1,FCRRPLAD        RANDOM RPL ADDRESS IN R1
          USING IFGRPL,R1
*
          CLI   RPLREQ,RPLGET     WAS LAST REQUEST A GET?
          BNE   GETU              NO--> GET RECORD
          TM    RPLOPT2,RPLUPD    YES--> FOR UPDATE?
          BO    BYEBYE            YES--> GO DO DELETE
*
GETU     DS    0H
          OI    RPLOPT2,RPLUPD     TURN UPDATE FLAG ON
*         NI    RPLOPT2,255-RPLNSP TURN OFF NOTE STRING POS
          DROP  R1
*
          GET   RPL=(1)           GET THE RECORD FOR UPDATE
*
          LTR   R15,R15            IF ERROR, INVESTIGATE
          BNZ   VSERREQ
*
         L     R1,FCRRPLAD        RESTORE RPL ADDRESS
*
BYEBYE    DS    0H
          ERASE RPL=(1)
*
          LTR   R15,R15            IF ERROR, INVESTIGATE
          BNZ   VSERREQ
*
          BR    R9
*
          EJECT
***********************************************************************
*                    FILE POINT ROUTINE                               *
*                    SEQUENTIAL RPL ASSUMED                           *
***********************************************************************
          SPACE
FCPOINT   DS    0H
          SPACE
          ICM   R1,15,VS$#@KEY     GET ADDRESS OF KEY
          BZ    INVKEY             NOT PRESENT--> ERROR...ERROR...ERROR
*
          XC    FCKEY,FCKEY        CLEAR KEY AREA
          XR    R7,R7              CLEAR R7
          IC    R7,VS$#@KYL        INSERT KEY LENGTH
          BCTR  R7,0               DECREMENT FOR MOVE
          EX    R7,MOVEKEY         MOVE THE KEY IN
*
          L     R1,FCSRPLAD        SEQ RPL ADDRESS IN R1
*
POINTIT   DS    0H
          POINT RPL=(1)
*
          LTR   R15,R15            IF ERROR, INVESTIGATE
          BNZ   VSERREQ
*
          CLC   FCFKEYL,VS$#@KYL   GENERIC POINT?
          BHR   R9                 YES--> GIVE EM WHAT WE GOT
          XR    R7,R7
          IC    R7,FCFKEYL         FULL KEY LENGTH IN R7
          BCTR  R7,0               DOWN BY 1 FOR EX COMPARE
          XR    R8,R8
          ICM   R8,B'0011',FCFKEYD GET KEY DISPLACEMENT
          L     R1,FCSAREA         GET SEQ RECORD ADDRESS
          AR    R1,R8             BUMP TO KEY
          EX    R7,KEYCLC          COMPARE THE KEY
          BER   R9                 EQUAL--> OK
          BAL   R9,FCENDREQ        RELEASE THE VSAM STRING/POINTER
          LA    R9,RETURN          RESET RETURN ADDRESS
          B     EOFNRF             NOT EQUAL--> NOT FOUND
*
          EJECT
***********************************************************************
*                    FILE ENDREQ ROUTINE                              *
***********************************************************************
          SPACE
FCENDREQ  DS    0H
          SPACE
          L     R1,FCSRPLAD        GET SEQ RPL ADDRESS
          ICM   R0,15,VS$#@KEY     GET ADDRESS OF KEY
          BZ    ERQIT              NOT PRESENT--> USE SEQ RPL
*
          L     R1,FCRRPLAD        GET RANDOM RPL ADDR
*
ERQIT     DS    0H
          ENDREQ RPL=(1)
*
          LTR   R15,R15            IF ERROR, INVESTIGATE
          BNZ   VSERREQ
*
          BR    R9
*
          EJECT
***********************************************************************
*                    ADD FILE TO CONTROL TABLE                       *
***********************************************************************
*      THIS ROUTINE ASSUMES THAT R4 CONTAINS EITHER:                 *
*         THE LAST FILE ENTRY IN THE FILE CONTROL TABLE              *
*                       *** OR ***                                   *
*                         ZEROS                                      *
*   THIS ROUTINE WILL ACQUIRE THE STORAGE REQUIRED FOR A NEW         *
*  FILE CONTROL TABLE ENTRY, ADJUST FC CHAIN, GETMAIN STORAGE        *
*  FOR THE ACB/RPL'S BLOCK, AND SETS THE FOLLOWING ADDRESSES         *
*  IN THE RPL'S:                                                     *
*      RPLDACB  - ACB ADDRESS                                        *
*      RPLARG   - ADDRESS OF SEARCH KEY (FCKEY)                      *
*                                                                    *
*    UPON RETURN, R4 WILL CONTAIN THE ADDRESS OF THE NEW ENTRY       *
*   CREATED.                                                         *
*                                                                    *
***********************************************************************
          SPACE
ADDFILE   DS    0H
          SPACE
          ST    R14,SAVER14
*
          LA    R0,FCELEN          GET THE AREA
*
          GETMAIN R,LV=(0)
*
          LTR   R4,R4              DO WE HAVE A TABLE YET?
          BNZ   TACKITON           YES--> TACK THIS GUY ON THE END
*
          ST    R1,VS$#@CTL        NO--> SAVE BEGINNING ADDRESS
          LR    R4,R1              SET FC DSECT REG
          MVC   FCPREV,=F'-1'      SET BACKWARD CHAIN = X"FF"S
          B     BLDFILE            GO BUILD ENTRY/RPL'S/ACB
*
TACKITON  DS    0H
*
          ST    R1,FCNEXT          SET FOWARD CHAIN TO NEW AREA
          LR    R2,R4              SAVE PREV ADDR
          LR    R4,R1              SET FC DSECT REG TO NEW ENTRY
          ST    R2,FCPREV          SET BACKWARD CHAIN
BLDFILE   DS    0H
          MVC   FCNEXT,=F'-1'      SET FOWARD PTR = EOC
          MVC   FCDDNAME,VS$#@FIL  SET DDNAME
          SPACE
          LA    R0,VSCBLEN         GET LENGTH OF ACB/RPL BLOCK
          GETMAIN R,LV=(0)
          SPACE
          MVC  0(VSCBLEN,R1),VSACB MOVE DUMMY CONTROL BLOCKS IN
          ST    R1,FCACBAD         STORE ACB ADDRESS
          LA    R15,VSSRPLOF(,R1)   SET R15 AT SEQ RPL ADDR
          ST    R15,FCSRPLAD       STORE IT IN SEQ RPL ADDR
          LA    R15,VSRRPLOF(,R1)   SET R15 AT RANDOM RPL ADDR
          ST    R15,FCRRPLAD       STORE IT IN RANDOM RPL ADDR
          SPACE
          L     R15,FCSRPLAD       NOW SET RPL PTRS TO APPROPRIATE
          USING IFGRPL,R15         ADDRESS
          SPACE
          MVC   RPLDACB,FCACBAD    SET ACB ADDRESS IN RPL
          LA    R1,FCKEY           ADDR OF KEY IN R1
          ST    R1,RPLARG          STORE KEY ADDR IN RPL
          SPACE
          L     R15,FCRRPLAD       DO RANDOM RPL ALSO
          SPACE
          MVC   RPLDACB,FCACBAD    SET ACB ADDRESS IN RPL
          LA    R1,FCKEY           ADDR OF KEY IN R1
          ST    R1,RPLARG          STORE KEY ADDR IN RPL
          DROP  R15
          L    R1,FCACBAD         GET ACBADDR
          USING IFGACB,R1
          MVC   ACBDDNM,VS$#@FIL  SET FILENAME IN ACB
         DROP  R1
          L     R14,SAVER14
          BR    R14
*
          EJECT
***********************************************************************
*                 DELETE FILE FROM CONTROL TABLE                      *
***********************************************************************
*      THIS ROUTINE ASSUMES THAT R4 CONTAINS THE CURRENT FILE        *
*         ENTRY TO BE DELETED.                                       *
*   THIS ROUTINE WILL RELEASE ALL STORAGE ACQUIRED FOR A CLOSED      *
*  FILE CONTROL TABLE ENTRY, AND ADJUST THE FC CHAIN APPROPRIATELY.  *
*                                                                    *
***********************************************************************
          SPACE
DELFILE   DS    0H
          SPACE
          ST    R14,SAVER14
*
          L     R1,FCACBAD         GET ADDRESS OF ACB
          LA    R0,VSCBLEN         GET LENGTH OF ACB/RPL BLOCK
          FREEMAIN R,LV=(0),A=(1)
          SPACE
*
          L     R0,FCPREV          R0= PREV ENTRY ADDR
          L     R1,FCNEXT          R1= NEXT ENTRY ADDR
          LR    R7,R4              AND REMEMBER WHO GETS DELETED
*
          C     R0,=F'-1'        1ST ENTRY?
          BE    CKNEXTE            YES--> SEE IF NEXT ENTRY
          LR    R4,R0              NO--> SET R4 TO PREV ENTRY
          ST    R1,FCNEXT          PUT FOWARD POINTER IN PREV ENTRY
*
          C     R1,=F'-1'        WAS THIS THE LAST GUY?
          BE    FREEIT             YES--> WERE DONE! FREEMAIN IT
          LR    R4,R1              NO--> SET R4 TO NEXT ENTRY
          ST    R0,FCPREV          PUT BACKWARD PTR IN NEXT ENTRY
          B     FREEIT             AND GO FREE THE AREA
*
CKNEXTE   DS    0H              ONLY IF WERE FREEING THE FIRST ENTRY
          XC    VS$#@CTL,VS$#@CTL  CLEAR THE CONTROL TAB ADDR
*                                  WERE GOING TO BE CHANGING IT ANYWAY
          C     R1,=F'-1'          FIRST AND ONLY?
          BE    FREEIT             YES--> DONE!
          LR    R4,R1              NO--> SET R4 TO NEXT ENTRY
          MVC   FCPREV,=F'-1'      INDICATE FIRST IN CHAIN
          ST    R4,VS$#@CTL        SAVE NEW CTL TAB START
*                                  AND FREE THE ENTRY
FREEIT    DS    0H
          LA    R0,FCELEN          GET THE ENTRY LENGTH
          LR    R1,R7              GET ADDRESS OF ENTRY AREA
*
          FREEMAIN R,LV=(0),A=(1)
*
          L     R14,SAVER14
          BR    R14
*
          EJECT
***********************************************************************
*                VSAM OPEN/CLOSE ERROR ROUTINES                       *
***********************************************************************
INVKEY    DS    0H
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS
          MVC   VSMBLD1+46(7),=CL7'POINT'
          MVC   VSMBLD1+13(8),VS$#@FIL GET FILENAME
          WTO   MF=(E,VSMBLD1)
          WTO   MF=(E,VSMINVK)
          MVC   VS$#@RCD,=X'FF0004'
          BR    R9
          SPACE
DELERR    DS    0H
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS
          MVC   VSMBLD1+46(7),=CL7'DELETE'
          MVC   VSMBLD1+13(8),VS$#@FIL GET FILENAME
          WTO   MF=(E,VSMBLD1)
          WTO   MF=(E,VSMDELK)
          MVC   VS$#@RCD,=X'FF0004'
          BR    R9
          SPACE
INVOPER   DS    0H
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS
          MVC   VSMBLD1+46(7),=CL7'UNKNOWN'
          MVC   VSMBLD1+13(8),VS$#@FIL GET FILENAME
          WTO   MF=(E,VSMBLD1)
          WTO   MF=(E,VSMINVO)
          MVC   VS$#@RCD,=X'FF0004'
          BR    R9
          SPACE
INVFILE   DS    0H
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS
          MVC   VSMBLD1+46(7),=CL7'--N/A--'
          MVC   VSMBLD1+13(8),VS$#@FIL GET FILENAME
          WTO   MF=(E,VSMBLD1)
          WTO   MF=(E,VSMNOTO)
          MVC   VS$#@RCD,=X'080004'
          BR    R9
          SPACE
DUPOPEN   DS    0H
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS
          MVC   VSMBLD1+46(7),=CL7'OPEN'
          MVC   VSMBLD1+13(8),VS$#@FIL GET FILENAME
          WTO   MF=(E,VSMBLD1)
          WTO   MF=(E,VSMDUPO)
          MVC   VS$#@RCD,=X'080004'
          BR    R9
          SPACE
VSERROC   DS    0H
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS
          MVC   VSMBLD2(VSMSG2L),VSMSG2
*
          L     R1,FCACBAD         GET ACB ADDRESS
          USING IFGACB,R1
*
          MVC   VSMBLD1+46(7),=CL7'OPEN'
          CLI   TESTBYTE,VS$#OPEN  OPEN REQUEST?
          BE    CHKERR             YES--> GO CHECK ERROR TYPE
          MVC   VSMBLD1+46(7),=CL7'CLOSE' OTHERWISE SET AS CLOSE
*
CHKERR    DS    0H
          STC   R15,VS$#@RCD       STORE R15 VALUE IN PLIST
          MVC   VS$#@RCD+L'VS$#@RCD-1(1),ACBERFLG
          B     DOMSGS             GO WRITE MESSAGES TO LOG
          DROP  R1
          SPACE
VSERRMC   DS    0H
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS
          MVC   VSMBLD2(VSMSG2L),VSMSG2
*
          L     R1,FCACBAD         GET ACB ADDRESS
          USING IFGACB,R1
*
          MVC   VSMBLD1+46(7),=CL7'MODCB'
          STC   R15,VS$#@RCD       STORE R15 VALUE IN PLIST
          MVC   VS$#@RCD+L'VS$#@RCD-1(1),ACBERFLG
          B     DOMSGS             GO WRITE MESSAGES TO LOG
          DROP  R1
          EJECT
***********************************************************************
*                VSAM I/O REQUEST ERROR ROUTINE                       *
***********************************************************************
          SPACE
VSERREQ   DS    0H
          MVC   VSMBLD1(VSMSG1L),VSMSG1   MESSAGE BUILD AREAS
          MVC   VSMBLD2(VSMSG2L),VSMSG2
*
          USING IFGRPL,R1
          STC   R15,VS$#@RCD          STORE R15 VALUE
          MVC   VS$#@RCD+L'VS$#@RCD-1(1),RPLERRCD   ERROR CODE
*
          MVC   VSMBLD1+46(7),=CL7'GET'   SET OPERATION TYPE
          CLI   RPLREQ,RPLGET      GET REQUEST?
          BE    DOMSGS             YES--> GOTIT
          MVC   VSMBLD1+46(7),=CL7'PUT'   SET OPERATION TYPE
          CLI   RPLREQ,RPLPUT      PUT REQUEST?
          BE    DOMSGS             YES--> GOTIT
          MVC   VSMBLD1+46(7),=CL7'POINT' SET OPERATION TYPE
          CLI   RPLREQ,RPLPOINT    POINT REQUEST?
          BE    DOMSGS             YES--> GOTIT
          MVC   VSMBLD1+46(7),=CL7'ERASE' SET OPERATION TYPE
          CLI   RPLREQ,RPLERASE    ERASE REQUEST?
          BE    DOMSGS             YES--> GOTIT
          MVC   VSMBLD1+46(7),=CL7'ENDREQ' SET OPERATION TYPE
          CLI   RPLREQ,RPLENDRE    ERASE REQUEST?
          BE    DOMSGS             YES--> GOTIT
          MVC   VSMBLD1+46(7),=CL7'UNKNOWN' SET OPERATION TYPE
*
DOMSGS    DS    0H
          MVC   VSMBLD1+13(8),VS$#@FIL GET FILENAME
          MVI   VSMBLD2+19,0  MAKE R15 VALUE DISPLAYABLE HEX
          MVZ   VSMBLD2+19(1),VS$#@RCD
          MVI   VSMBLD2+20,0
          MVN   VSMBLD2+20(1),VS$#@RCD
          TR    VSMBLD2+19(2),=C'0123456789ABCDEF'
*
          SR    R7,R7
          ICM   R7,3,VS$#@RCD+1     GET VSAM ERROR CODE
          CVD   R7,DBLWRD
          OI    DBLWRD+L'DBLWRD-1,X'0F'
          UNPK  VSMBLD2+37(4),DBLWRD+L'DBLWRD-3(3)
          SPACE
          CLI   VS$#@RCD+L'VS$#@RCD-1,X'04' EOF?
          BE    EOFNRF
          CLI   VS$#@RCD+L'VS$#@RCD-1,X'10' NRF?
          BE    EOFNRF
          CLI   VS$#@RCD+L'VS$#@RCD-1,X'08' DUP RECORD?
          BER   R9                          YES--> NO MESSAGE PLEASE
WRITMSG   DS    0H
          WTO   MF=(E,VSMBLD1)
          WTO   MF=(E,VSMBLD2)
*
         CLI   TESTBYTE,VS$#CLOS  CLOSE REQUEST?
         BE    FCCLOSR            YES--> FREE AREAS
         CLI   TESTBYTE,VS$#OPEN  OPEN REQUEST?
         BNER  R9                 NO--> EXIT
         CLI   VS$#@RCD,X'04'     WARNING?
         BE    FCOPENR            YES--> CONTINUE WITH OPEN PROCESSING
          BR    R9                NO--> EXIT
EOFNRF    DS    0H
          MVC   VS$#@RCD,=X'040004' INDICATE EOFNRF
          NI    RPLOPT2,255-RPLUPD  RESET RPL UPDATE FLAG
         AIF   (NOT &TEST).NOTEST2
          WTO   MF=(E,TREOFMSG)
.NOTEST2 ANOP  ,
          BR    R9
          DROP  R1
          EJECT
         AIF   (NOT &TEST).NOTEST3
FCTRACE  DS    0H
         ST    R14,TRSAV14
*
          MVC   TRMBLD1(TRMSG1L),TRMSG1   MESSAGE BUILD AREAS
          MVC   TRMBLD2(TRMSG2L),TRMSG2   MESSAGE BUILD AREAS
*
         CLI   TESTBYTE,TROPENT
         BH    FCUNKN             BAD CODE
         XR    R7,R7
         IC    R7,TESTBYTE        GET LOW HALF OF OPER
         MH    R7,=AL2(L'TROPTAB)
         A     R7,=A(TROPTAB)
*
          MVC   TRMBLD1+46(7),0(R7)       SET OPERATION TYPE
*
          CLI   TESTBYTE,VS$#READ  READ REQ?
          BH    TRMSGS             HIGH--> NO SUBFLAGS
          BE    TRREAD            EQ--> CHECK SUBFLAG
*
          CLI   TESTBYTE,VS$#OPEN  OPEN REQ?
          BNE   MUSBCLOS           NO--> MUST BE CLOSED
*
          MVI   TRMBLD1+50,C'U'    OPEN UPDATE
         TM    VS$#@FNC,VS$#OUPD  IS IT?
         BO    TRMSGS
*
          MVI   TRMBLD1+50,C'L'    OPEN LOAD
         TM    VS$#@FNC,VS$#OLOD  IS IT?
         BO    TRMSGS
*
          MVI   TRMBLD1+50,C' '    OPEN READ ONLY
         TM    VS$#@FNC,VS$#ORDO  IS IT?
         BO    TRMSGS
*
          MVC   TRMBLD1+50(2),=C'RU'  RESET/UPD
         B     TRMSGS
TRREAD   DS    0H
          MVI   TRMBLD1+50,C'U'    READ UPDATE
         TM    VS$#@FNC,VS$#RUPD  IS IT?
         BO    TRMSGS
          MVI   TRMBLD1+50,C'O'    READ ONLY
         B     TRMSGS
MUSBCLOS DS    0H
         TM    VS$#@FNC,VS$#CLSA
         BZ    TRMSGS
         MVC   TRMBLD1+51(2),=C'AL'
         B     TRMSGS
FCUNKN    MVC   TRMBLD1+46(7),=CL7'UNKNOWN' SET OPERATION TYPE
TRMSGS    DS    0H
          MVC   TRMBLD1+13(8),VS$#@FIL GET FILENAME
*
         CLI   VS$#@KYL,0         ANY KEY?
         BNE   TRKEY
         MVC   TRMBLD2+17(131),=CL131'NONE'
         B     TRWTOIT
TRKEY    DS    0H
         XC    DECKEY,DECKEY      CLEAR KEY AREA
         L     R7,VS$#@KEY        GET ADDRESS OF KEY
         XR    R14,R14            CLEAR R14
         IC    R14,VS$#@KYL       GET KEY LENGTH
         LA    R8,DECKEY          GET TRANSLATED AREA
         LA    R2,DECKEY+L'DECKEY END OF AREA
LOOPIT   DS    0H
         XR    R15,R15
         IC    R15,0(R7)
         MVN   1(1,R8),0(R7)
         SRL   R15,4
         STC   R15,0(R8)
         LA    R8,2(,R8)
         LA    R7,1(R7)
         CR    R8,R2
         BNL   TRDONE
         BCT   R14,LOOPIT
TRDONE   DS    0H
         TR    DECKEY,=C'0123456789ABCDEF'
         LA    R7,DECKEY+L'DECKEY  R7 TO END OF KEY
         CR    R7,R8
         BNH   TRMVKEY
         SR    R7,R8        SUBTRACT R8 FROM R7 = LENGTH REMAINING
         BCTR  R7,0               DECREMENT BY 1
         EX    R7,FILLKEY
TRMVKEY  DS    0H
         MVC   TRMBLD2+19(128),DECKEY
TRWTOIT  DS    0H
          WTO   MF=(E,TRMBLD1)
          WTO   MF=(E,TRMBLD2)
         L     R14,TRSAV14
         BR    R14
*
FILLKEY  MVC   0(1,R8),=CL128'"'
         EJECT
TRMSG1    WTO   'VSAMIO - DDDDDDDD ACCESS TRACE, REQUEST = ZZZZZZZ',   X
               ROUTCDE=(8,11),MF=L
TRMSG1L   EQU   *-TRMSG1
TRMSG2    WTO   'VSAMIO - KEY=X"NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNX
               NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNX
               NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN"',ROUTCDE=(8,11),MF=L
TRMSG2L   EQU   *-TRMSG2
TREOFMSG  WTO   'VSAMIO - EOF/NRF ENCOUNTERED',                        X
               ROUTCDE=(8,11),MF=L
*
TROPTAB   DC    CL7'UNKNOWN'    TRACE OPERATION TABLE
          DC    CL7'OPEN'
          DC    CL7'CLOSE'
          DC    CL7'READ'
          DC    CL7'WRITE'
          DC    CL7'DELETE'
          DC    CL7'POINT'
          DC    CL7'ENDREQ'
TROPENT   EQU   (*-TROPTAB)/L'TROPTAB    LET ASSEMBLER CALC #ENTRIES
.NOTEST3 ANOP  ,
         EJECT
**********************************************************************
*                                                                    *
**********************************************************************
*
SHELSHOK DS    0H
*
         USING SHELSHOK,R15
*
         C     R0,=F'12'         ANY SDWA?
         BNE   SDWAOK           YES-> GET PARAM FROM SDWA
*
         LR    R5,R2              PARMS ARE IN R2 IF NO SDWA
*
*
          MVI   VS$#@IND,0         CLEAR ACTIVE INDICATOR
          MVC   VS$#@RCD,=3X'FF'   MAJOR BAD ERROR CODE
          LA    R1,VS$#@E02        GET ECB
          POST  (1)                POST IT
          SPACE
*
         XR    R15,R15            CLEAR 15 = CONTINUE TERMINATION
         BR    R14                RETURN TO CP
*
         DROP  R15
SDWAOK   DS    0H
          STM   R14,R12,12(R13)
          LR    R3,R15              3'S THE BASE
          USING SHELSHOK,R3         RESET USING STATUS
*
          GETMAIN R,LV=72,SP=0
          ST    R13,4(R1)           SET CHAIN
          ST    R1,8(R13)           "       "
          LR    R13,R1              GET SAVE AREA ADDR IN R13
*
          L     R1,4(R13)          GET CALLER SAVE AREA ADDR
          L     R1,24(R1)           RESTORE R1 CONTENTS FROM THEIR SAVE
         USING SDWA,R1
         L     R5,0(R1)           AND ADDRESS OF PARM LIST ADDR
*
         SETRP WKAREA=(1),DUMP=YES,RC=0
*
          MVI   VS$#@IND,0         CLEAR ACTIVE INDICATOR
          MVC   VS$#@RCD,=3X'FF'   MAJOR BAD ERROR CODE
          LA    R1,VS$#@E02        GET ECB
          POST  (1)                POST IT
          SPACE
          L    R13,4(R13)         RESTORE CALLER SAVE AREA
         LM    R14,R12,12(R13)    THEN THE REGISTERS
         XR    R15,R15 CLEAR R15
         BR    R14 EXIT
*
         DROP  R1
         DROP  R3
         EJECT
         LTORG
          EJECT
**********************************************************************
*                  DUMMY ACB AND RPL'S                               *
**********************************************************************
          SPACE
VSACB     ACB   AM=VSAM,                                               X
               BUFND=4,                                                X
               BUFNI=6,                                                X
               MACRF=(KEY,SEQ,IN),                                     X
               STRNO=2
          SPACE
VSSRPL   RPL   ACB=VSACB,                                              X
               OPTCD=(KEY,SEQ,NUP,KGE,MVE)
          SPACE
VSRRPL   RPL   ACB=VSACB,                                              X
               OPTCD=(KEY,DIR,NUP,KGE,MVE)
          SPACE
VSCBLEN   EQU   *-VSACB            LENGTH OF VSAM CONTROL BLOCK AREAS
VSSRPLOF  EQU   VSSRPL-VSACB       OFFSET OF SEQ RPL FROM TOP
VSRRPLOF  EQU   VSRRPL-VSACB       OFFSET OF RANDOM RPL FROM TOP
          SPACE
          EJECT
VSMINVK   WTO   'VSAMIO - NO KEY SUPPLIED',                            X
               ROUTCDE=(8,11),MF=L
VSMDELK   WTO   'VSAMIO - GENERIC KEY NOT ALLOWED FOR DELETE REQUEST', X
               ROUTCDE=(8,11),MF=L
VSMINVO   WTO   'VSAMIO - INVALID OPERATION SUPPLIED/PARM LIST INVALID'X
               ,ROUTCDE=(8,11),MF=L
VSMNOTO   WTO   'VSAMIO - FILE HAS NOT BEEN OPENED',                   X
               ROUTCDE=(8,11),MF=L
VSMDUPO   WTO   'VSAMIO - FILE PREVIOUSLY OPENED',                     X
               ROUTCDE=(8,11),MF=L
VSMSG1    WTO   'VSAMIO - DDDDDDDD ACCESS ERROR, REQUEST = ZZZZZZZ',   X
               ROUTCDE=(8,11),MF=L
VSMSG1L   EQU   *-VSMSG1
VSMSG2    WTO   'VSAMIO - R15 = XX, RETURN CODE = NNNN DECIMAL',       X
               ROUTCDE=(8,11),MF=L
VSMSG2L   EQU   *-VSMSG2
          EJECT
WORKADS   DSECT ,
DBLWRD    DS    D
FULLWORD  DS    D
VS$#@CTL  DS    F                  CONTROL TABLE BEGIN ADDRESS
SAVER14   DS    F
FWORD     DS    F
WHATRPL   DS    F                  SAVE ADDRESS OF RPL ACCESSED
TESTBYTE  DS    XL1
VSMBLD1   DS    CL(VSMSG1L)
VSMBLD2   DS    CL(VSMSG2L)
         AIF   (NOT &TEST).NOTEST4
TRMBLD1  DS    CL(TRMSG1L)
TRMBLD2  DS    CL(TRMSG2L)
DECKEY   DS    CL128
TRSAV14  DS    F
.NOTEST4 ANOP  ,
WORKALEN  EQU   *-WORKADS
VSIOMOD   CSECT ,
          EJECT
          VSAMIO ,FUNC=PLIST
          EJECT
FCDSECT   DSECT ,
FCBLOCK   DS    0F                 ALIGN THE STARS
FCDDNAME  DS    CL8                DDNAME
FCACBAD   DS    AL4                ADDRESS OF ACB
FCSRPLAD  DS    AL4                SEQ RPL ADDRESS
FCSAREA   DS    AL4                SEQ RECORD AREA ADDRESS
FCRRPLAD  DS    AL4                RANDOM RPL ADDRESS
FCRAREA   DS    AL4                RANDOM RECORD AREA ADDRESS
FCPREV    DS    AL4                BACKWARD CHAIN
FCNEXT    DS    AL4                FOWARD CHAIN
FCKEY     DS    XL255              RECORD KEY
FCFKEYL   DS    XL1                FULL KEY LENGTH
FCFKEYD   DS    XL2                KEY DISPLACEMENT INTO RECORD
*
FCELEN    EQU   *-FCBLOCK
***********************************************************************
*        SYSTEM DSECTS                                                *
***********************************************************************
          IFGRPL DSECT=YES,AM=VSAM
          EJECT
          IFGACB DSECT=YES,AM=VSAM
          EJECT
          IHASDWA
*
VSIOMOD   CSECT ,
         END   VSIOMOD
