RXVSAM   TITLE 'REXX/VSMIO API'
* ---------------------------------------------------------------------
*   API TO VSMIO (STEVE SCOTT), CALLED FROM C (FOR BREXX)
*   AUTHOR  : PETER JACOB (PEJ)
*   CREATED : 06.08.2019  PEJ
*   JCC PROLOGUE : JUERGEN WINKELMANN, ETH ZUERICH.
* ---------------------------------------------------------------------
*        DDNAME PREFIX      #%  RUN WITH EXTENDED TRACE (JUST ON OPEN)
*        DDNAME PREFIX      #+  IMMEDIATE 0C1
*        DDNAMEVPREFIX      #=  0C1 AFTER RETURNING FROM VSIOMOD
         PRINT GEN
* --------------------------------------------------------------------
*   INTERNAL MACRO DEFINITIONS
* --------------------------------------------------------------------
         MACRO
         VSTEST &VSREQ,&VSPROC,&VSTYPE
         CLC   =C'&VSREQ',VSMFUNC
         BNE   N&SYSNDX
         MVI   VSMTYPE,X'&VSTYPE'
         AIF   ('&VSREQ' EQ 'READN').CLEARKY
         AIF   ('&VSREQ' EQ 'READNU').CLEARKY
         AIF   ('&VSREQ' EQ 'WRITEN').CLEARKY
         AGO   .NOCLEAR
.CLEARKY ANOP
         BLANK VSMKEY
.NOCLEAR ANOP
         BAL   RE,&VSPROC
         B     RXVSEXT
N&SYSNDX DS    0H
         MEND
         MACRO
         B2NUM &TARGET,&FROM
         AIF   ('&FROM'(1,1) EQ '(').ISREG
         L     R1,&FROM
         CVD   R1,STRPACK
         AGO   .UNPK
.ISREG   ANOP
         CVD   &FROM(1),STRPACK
.UNPK    ANOP
         UNPK  &TARGET,STRPACK
         OI    &TARGET+L'&TARGET-1,X'F0'
         MEND
*
* --------------------------------------------------------------------
* RXVSAM MAIN PROGRAM
* --------------------------------------------------------------------
RXVSAM   MRXSTART A2PLIST=YES
         GETMAIN R,LV=WORKLEN       GET STORAFE FOR WORK AREA
         LR    RA,R1                SAVE GETMAIN POINTER
         USING WORKAREA,RA
         VSAMIO FUNC=PLIST
         USING VSMCOMM,RB
         CLI   VSMDDN,C'#'
         BNE   VSEXEC
         BAL   RE,RXDEBUG
* .... PERFORM REQUESTED CALL
VSEXEC   BAL   RE,RXVSEXEC
         CLI   RXDBGFLG,C'2'
         BNE   EXITA
* .... DEBUG AFTER VSMIO CALL REQUESTED, ABEND
         DS    A
* --------------------------------------------------------------------
*   EXIT PROGRAM
* --------------------------------------------------------------------
EXITA    LR    R5,RF                SAVE RETURN CODE
         FREEMAIN R,LV=WORKLEN,A=(RA)
         LR    RF,R5                RESTORE RETURN CODE
         MRXEXIT
* --------------------------------------------------------------------
*     RXVSAM CONTROL
* --------------------------------------------------------------------
*  OPEN CALLS
* VS$#OPEN     EQU   X'01'               OPEN FILE
* VS$#OUPD     EQU   X'10'               UPDATE INTENDED
* VS$#OLOD     EQU   X'20'               RESET FILE FOR LOAD
* VS$#ORDO     EQU   X'40'               READ ONLY
* VS$#ORSU     EQU   X'80'               RESET FILE W/DUMMY-OPEN
* --------------------------------------------------------------------
RXVSEXEC DS    0H
         ST    RE,SAVE01
         BAL   RE,INITV
         BAL   RE,TRACEBEG
* --------------------------------------------------------------------
*     READ VSAM RECORD WITH KEY
*       VS$#READ   EQU   X'03'               READ FILE (NON-UPDATE)
*       VS$#RUPD    EQU   X'10'                  UPDATE INTENDED
* --------------------------------------------------------------------
         VSTEST READKU,READK,13
         VSTEST READK,READK,03
         VSTEST READNU,READN,13
         VSTEST READN,READN,03
* --------------------------------------------------------------------
*     LOCATE VSAM RECORD
*       VS$#PONT   EQU   X'06'               POINT TO SPECIFIED KEY
* --------------------------------------------------------------------
         VSTEST POINT,LOCATE,06
         VSTEST LOCATE,LOCATE,06
* --------------------------------------------------------------------
*     WRITE VSAM RECORD
* VS$#WRIT   EQU   X'04'               WRITE RECORD (INSERT/UPDATE)
* VS$#INST   EQU   X'14'               INSERT RECORD (INSERT/UPDATE)
* --------------------------------------------------------------------
         VSTEST WRITEK,WRITEK,04
         VSTEST WRITEN,WRITEN,04
         VSTEST WRITE,WRITEK,04
         VSTEST INSERT,WRITEK,14
* --------------------------------------------------------------------
*     DELETE VSAM RECORD
* VS$#DELT   EQU   X'05'               DELETE RECORD
* --------------------------------------------------------------------
         VSTEST DELETEK,DELETEK,05
         VSTEST DELETEN,DELETEN,05
         VSTEST DELETE,DELETE,05
* --------------------------------------------------------------------
*     OPEN VSAM DSN
* --------------------------------------------------------------------
         VSTEST OPENR,OPEN,41
         VSTEST OPENU,OPEN,11
         VSTEST OPENL,OPEN,21
         VSTEST OPENX,OPEN,81
* --------------------------------------------------------------------
*     CLOSE VSAM FILE
* VS$#CLOS   EQU   X'02'               CLOSE FILE
* VS$#CLSA    EQU   X'10'                  CLOSE ALL FILES
* --------------------------------------------------------------------
         VSTEST CLOSE,CLOSE,02
         VSTEST CLOSEA,CLOSE,12
         VSTEST SHUTD,SHUTDOWN,0
* --------------------------------------------------------------------
*     UNKNOWN REQUEST
* --------------------------------------------------------------------
         LA   RF,16
RXVSEXT  ST   RF,SAVE03
         BAL  RE,TRACEEND
         L    RF,SAVE03
         L    RE,SAVE01
         BR   RE
* --------------------------------------------------------------------
*     INIT ENVIRONMENT
*      PRE-ALLOCATE COMMUNICATION BLOCK
* --------------------------------------------------------------------
INITV    DS    0H
         ST    RE,SAVE02
         BLANK VSMMSG
         MVC   VSMMFUNC,VSMFUNC
         MVC   VSMMDDN,VSMDDN
         MVC   VSMMRCTX,=CL3'RC='
         L     R1,VSMSUBT            ALLOCATED BY PREVIOUS C-CALL?
         LTR   R1,R1                 ALREADY SET?
         BZ    INITGM                NO, ALLOCATE STORAGE
         ST    R1,VS$#@LST           SAVE PARM LIST ADDR
         L     RE,SAVE02
         BR    RE                    THEN RETURN, NO INIT NECESSARY
INITGM   DS    0H
         GETMAIN R,LV=VS$#@LEN,SP=0
         ST    R1,VSMSUBT            SAVE PARM LIST ADDR
         ST    R1,VS$#@LST           SAVE PARM LIST ADDR
         XC    0(VS$#@LEN,R1),0(R1)
         L     RE,SAVE02
         BR    RE
* --------------------------------------------------------------------
*     SHUT DOWN VSAM SUB SYSTEM
*     IF AN OPEN FAILS, THE SUB SYSTEM IS NOT SHUTDOWN AUTOMATICALLY
*     SHUTDOWN FORCES THE TERMINATION OF THE VSAM SUB SYSTEM
* --------------------------------------------------------------------
SHUTDOWN DS    0H
         ST    RE,SAVE02
         USING VS$#@IOD,R3
         L     R3,VS$#@LST        RESTORE LIST ADDR
         L     R1,VS$#@TCB        LOAD VSAM SUB SYSTEM TCB
         LTR   R1,R1              TEST IF AVAILABLE
         BZ    NOSHUTD            NO, DO NOT DETACH
         CHAP  -1,VS$#@TCB        BUMP THE PRIORITY DOWN
         DETACH VS$#@TCB          KILL SUBTASK
NOSHUTD  XC    VS$#@TCB,VS$#@TCB
         XC    VS$#@LST,VS$#@LST
         DROP  R3
         XR    RF,RF
         L     RE,SAVE02
         BR    RE
* --------------------------------------------------------------------
*     OPEN VSAM FILE
* --------------------------------------------------------------------
OPEN     DS    0H
         ST    RE,SAVE02
         LA    R3,VSIOMODT
         CLI   VSMIOVMD,C'T'
         BE    OPENNOW
         LA    R3,VSIOMOD
OPENNOW  DS    0H
         VSAMIO VSMDDN,FUNC=OPEN,TYPE=VSMTYPE,INTENT=READ,             X
               ERROR=VSEXIT8,RCODE=VSMRCODE,MODULE=(R3)
         B     VSEXIT0
* --------------------------------------------------------------------
*     READ VSAM RECORD WITH KEY
*       VS$#READ   EQU   X'03'               READ FILE (NON-UPDATE)
*       VS$#RUPD    EQU   X'10'                  UPDATE INTENDED
* --------------------------------------------------------------------
READK    DS    0H
         ST    RE,SAVE02
         L     R5,VSMRECAD
         VSAMIO VSMDDN,FUNC=READ,TYPE=VSMTYPE,IOREG=R5,KEY=VSMKEY,     X
               EOFNRF=VSEXIT4,ERROR=VSEXIT8,LENGTH=VSMRECLN,           X
               KEYVLEN=VSMKEYLN,RCODE=VSMRCODE
         ST    R5,VSMRECAD
         STH   RF,VSMRECLN
         B     VSEXIT0
* --------------------------------------------------------------------
*     READ NEXT VSAM RECORD  (SEQUENTIAL)
*       VS$#READ   EQU   X'03'               READ FILE (NON-UPDATE)
*       VS$#RUPD    EQU   X'10'                  UPDATE INTENDED
* --------------------------------------------------------------------
READN    DS    0H
         ST    RE,SAVE02     THERE ARE MAYBE SUBSEQUENT CALLS
         L     R5,VSMRECAD
         VSAMIO VSMDDN,FUNC=READ,TYPE=VSMTYPE,IOREG=R5,                X
               EOFNRF=VSEXIT4,ERROR=VSEXIT8,LENGTH=VSMRECLN,           X
               RCODE=VSMRCODE
         ST    R5,VSMRECAD
         STH   RF,VSMRECLN
         B     VSEXIT0
* --------------------------------------------------------------------
*     LOCATE VSAM RECORD
*       VS$#PONT   EQU   X'06'               POINT TO SPECIFIED KEY
* --------------------------------------------------------------------
LOCATE   DS    0H
         ST    RE,SAVE02
         MVC   VSMTYPE,=X'06'
         L     R5,VSMRECAD
         VSAMIO VSMDDN,FUNC=POINT,TYPE=VSMTYPE,KEY=VSMKEY,             X
               IOREG=R5,EOFNRF=NOLOC,ERROR=ERROR5,KEYVLEN=VSMKEYLN,    X
               RCODE=VSMRCODE
         ST    R5,VSMRECAD
         B     VSEXIT0
NOLOC    MVC   VSMTYPE,=X'03'
         MVC   VSMFUNC,=CL8'READN'
         BAL   RE,TRACEBEG
         L     R5,VSMRECAD
         VSAMIO VSMDDN,FUNC=READ,TYPE=VSMTYPE,IOREG=R5,                X
               EOFNRF=NONOLOC,ERROR=ERROR5,LENGTH=VSMRECLN,            X
               RCODE=VSMRCODE
         ST    R5,VSMRECAD
         BAL   RE,TRACEEND
         MVC   VSMTYPE,=X'06'
         MVC   VSMFUNC,=CL8'POINT'
         L     R5,VSMRECAD
         VSAMIO VSMDDN,FUNC=POINT,TYPE=VSMTYPE,KEY=VSMKEY,             X
               IOREG=R5,EOFNRF=OKLOC,ERROR=ERROR5,KEYVLEN=VSMKEYLN,    X
               RCODE=VSMRCODE
         ST    R5,VSMRECAD
OKLOC    B     VSEXIT0
NONOLOC  B     VSEXIT4
ERROR5   B     VSEXIT8
* --------------------------------------------------------------------
*     WRITE VSAM RECORD  WITH KEY
* VS$#WRIT   EQU   X'04'               WRITE RECORD (INSERT/UPDATE)
* VS$#WINS    EQU   X'10'
* --------------------------------------------------------------------
WRITEK   DS    0H
         ST    RE,SAVE02
         L     R5,VSMRECAD
         VSAMIO VSMDDN,FUNC=WRITE,TYPE=VSMTYPE,KEY=VSMKEY,             X
               AREA=(R5),ERROR=VSEXIT8,LENGTH=VSMRECLN,                X
               KEYVLEN=VSMKEYLN,RCODE=VSMRCODE
         ST    R5,VSMRECAD
         B     VSEXIT0
* --------------------------------------------------------------------
*     WRITE VSAM RECORD (NEXT SEQUENTIALLY)
* VS$#WRIT   EQU   X'04'               WRITE RECORD (INSERT/UPDATE)
* VS$#WINS    EQU   X'10'
* --------------------------------------------------------------------
WRITEN   DS    0H
         ST    RE,SAVE02
         L     R5,VSMRECAD
         VSAMIO VSMDDN,FUNC=WRITE,TYPE=VSMTYPE,AREA=(R5),              X
               ERROR=VSEXIT8,LENGTH=VSMRECLN,RCODE=VSMRCODE
         ST    R5,VSMRECAD
         B     VSEXIT0
* --------------------------------------------------------------------
*     DELETE VSAM RECORD WITH KEY
* VS$#DELT   EQU   X'05'               DELETE RECORD
* --------------------------------------------------------------------
DELETE   DS    0H
DELETEK  DS    0H
         ST    RE,SAVE02
         CLC   =C'$NEXT',VSMKEY
         BE    DELETEN1
         L     R5,VSMRECAD
         VSAMIO VSMDDN,FUNC=WRITE,TYPE=VSMTYPE,AREA=(R5),              X
               KEY=VSMKEY,ERROR=VSEXIT8,                               X
               KEYVLEN=VSMKEYLN,RCODE=VSMRCODE
         B     VSEXIT0
* --------------------------------------------------------------------
*     DELETE VSAM RECORD NEXT
* VS$#DELT   EQU   X'05'               DELETE RECORD
* --------------------------------------------------------------------
DELETEN  DS    0H
         ST    RE,SAVE02
DELETEN1 L     R5,VSMRECAD
         VSAMIO VSMDDN,FUNC=WRITE,TYPE=VSMTYPE,AREA=(R5),              X
               ERROR=VSEXIT8,RCODE=VSMRCODE
         B     VSEXIT0
* --------------------------------------------------------------------
*     CLOSE VSAM FILE
* VS$#CLOS   EQU   X'02'               CLOSE FILE
* VS$#CLSA    EQU   X'10'                  CLOSE ALL FILES
* --------------------------------------------------------------------
CLOSE    DS    0H
         ST    RE,SAVE02
         VSAMIO VSMDDN,FUNC=CLOSE,TYPE=VSMTYPE,RCODE=VSMRCODE
         B     VSEXIT0
* --------------------------------------------------------------------
*     DEBUG AND TRACE CALL
* --------------------------------------------------------------------
RXDEBUG  DS    0H
         ST    RE,SAVE01
         BLANK RXDDN
         MVC   RXDDN(6),VSMDDN+2   SAVE DDN WITHOUT PREFIX
         MVC   RXEYEC,=CL12'**COMSAVE**'
         LA    R0,RXCCOMM
         LA    R1,VSMDLEN1
         LA    RE,VSMCOMM
         LR    RF,R1
         MVCL  R0,RE
         CLI   VSMDDN+1,C'='     #=  0C1 AFTER RETURNING FROM VSMIOMOD
         BE    DEBUGB
         CLI   VSMDDN+1,C'+'     #+  IMMEDIATE 0C1
         BE    DEBUGA
         CLI   VSMDDN+1,C'%'     #%  RUN WITH EXTENDED TRACE
         BNE   DEBUGEND
* ... CREATE 0C1 TO DEBUG CALLING PARMS FROM C .................
         MVC   VSMDDN,RXDDN
         MVI   VSMIOVMD,C'T'
         B     DEBUGEND
* ... CREATE 0C1 TO DEBUG CALLING PARMS FROM C .................
DEBUGA   MVI   RXDBGFLG,C'1'
         DS    A              CREATE 0C1 NOW
* ... SET DEBUG AFTER VSMIO FLAG ...............................
DEBUGB   MVI   RXDBGFLG,C'2'
         MVC   VSMDDN,RXDDN
DEBUGEND L     RE,SAVE01
         BR    RE
* --------------------------------------------------------------------
*     GENERAL EXIT FROM ALL VSAM IO CALLS
* --------------------------------------------------------------------
VSEXIT0  LA    RF,0
         MVC   VSMMRCOD,=CL2'00'
VSEXIT   DS    0H
         XR    R1,R1
         IC    R1,VSMRCODE
         B2NUM VSMRR,(R1)
         XR    R1,R1
         ICM   R1,B'0011',VSMRCODE+1
         B2NUM VSMVSRX,(R1)
         MVC   VSMEXTRR,VSMRR
         MVI   VSMEXTHY,C'-'
         MVC   VSMEXTVS,VSMVSRX
         XC    VSMEXT00,VSMEXT00
         L     RE,SAVE02
         BR    RE
VSEXIT4  LA    RF,4
         MVC   VSMMRCOD,=CL2'04'
         B     VSEXIT
VSEXIT8  LA    RF,8
         MVC   VSMMRCOD,=CL2'08'
         B     VSEXIT
* --------------------------------------------------------------------
*     TRACE VSAM CALLS
* --------------------------------------------------------------------
TRACEBEG DS    0H
         ST    RE,SAVE04
         BLANK RXMSG
         MVC   RXDDN,VSMDDN
         MVC   RXFUNC,VSMFUNC
         MVC   RXKEY,VSMKEY
         MVC   RXMSG1,=CL11'BEGIN, KEY='
         L     RE,SAVE04
         BR    RE
TRACEEND DS    0H
         ST    RE,SAVE04
         BLANK RXMSG
         MVC   RXDDN,VSMDDN
         MVC   RXFUNC,VSMFUNC
         MVC   RXMSG1,=CL11'END,   RC ='
         B2NUM RCOD,(RF)
         CLC   =C'READ',VSMFUNC
         BNE   NOTRREC
         MVC   RXRECORD,VSMLINE
NOTRREC  DS    0H
         L     RE,SAVE04
         BR    RE
**********************************************************************
*                           LITERALS                                 *
**********************************************************************
VS$#@LST DS    A
VSIOMOD  DC    CL8'VSIOMOD'
VSIOMODT DC    CL8'VSIOMODT'
         LTORG
* --------------------------------------------------------------------
*    INCOMING STORAGE DEFINITION (FROM C PROGRAM)
* --------------------------------------------------------------------
*
**********************************************************************
*        REXX VSAM IO CONTROL BLOCK                                  *
**********************************************************************
VSMCOMM  DSECT        VSAM IO CONTROL BLOCK
VSMFUNC  DS    CL8    VSAM FUNCTION TO CALL
*  OPEN FUNCS
*    OPENR              OPEN READ
*    OPENU              OPEN UPDATE
*    OPENL              OPEN LOAD
*    OPENX              OPEN RESET
*  CLOSE FUNCS
*    CLOSE              CLOSE
*    CLOSEA             CLOSE ALL
*    SHUTDOWN           SHUT DOWN
*  READ FUNCS
*    READKU             READ WITH KEY UPDATE
*    READK              READ WITH KEY
*    READNU             READ NEXT SEQUENTIAL UPDATE
*    READN              READ NEXT SEQUENTIAL
*    LOCATE             LOCATE RECORD FOR READNEXT
*    POINT              SYNONYM FOR POINT
*  WRITE FUNCS
*    WRITE              WRITE RECORD WITH KEY
*    INSERT             INSERT RECORD
VSMTYPE  DS    XL1                 VSAM TYPE
VSMKSDS    EQU   C'K'                FOR KSDS  (DEFAULT)
VSMRRDS    EQU   C'R'                FOR RRDS
VSMESDS    EQU   C'E'                FOR ESDS
VSMDDN   DC    CL8'VSIN'           DD NAME OF VSAM FILE
VSMKEY   DC    CL255'52345678'     MAX KEY LENGTH IS 255
VSMKEYLN DC    XL1'8'              MAX KEY LENGTH IS UP TO 255=FF
VSMIOVMD DC    CL1'T'              VSMIOMOD WITH/WITHOUT WTO TRACE
VSMADJ1  DS    XL2                 FILLER TO ADJUST TO ADDRESS BOUNDARY
VSMRECAD DS    A                   RECORD ADDRESS
VSMRECLN DS    H                   RECORD LENGTH UP TO 65,535 BYTE
VSMADJ2  DS    XL2                 FILLER TO ADJUST TO ADDRESS BOUNDARY
VSMSUBT  DS    A
VSMRCODE DS    A                   VSAM IO RETURN CODE
VSMDLEN1 EQU   *-VSMCOMM           LENGTH OF DUMMY SECTION
VSMEXTRC DS    0CL8
VSMEXTRR DS    CL3
VSMEXTHY DS    CL1
VSMEXTVS DS    CL5
VSMEXT00 DS    XL1
VSMMSG   DS    0CL80
VSMMFUNC DS    CL8
         DS    CL1
VSMMDDN  DS    CL8
         DS    CL1
VSMMRCTX DC    CL3'RC='
VSMMRCOD DS    CL2
         DS    CL1
VSMRR    DS    CL3
         DS    CL1
VSMVSRX  DS    CL5
         DS    CL1
         ORG   VSMMSG+80
         DS    XL1
VSMTRC   DS    CL80
         DS    XL1
VSMDLEN  EQU   *-VSMCOMM           LENGTH OF DUMMY SECTION
*
* --------------------------------------------------------------------
*    PROGRAM WORK AREA
* --------------------------------------------------------------------
WORKAREA DSECT
SAVE01   DS    A
SAVE02   DS    A
SAVE03   DS    A
SAVE04   DS    A
RXDBGFLG DS    CL1
RXEYEC   DS    CL12
RXCCOMM  DS    CL(VSMDLEN)
RXBYTE   DS    XL1
RXHALFW  DS    XL2
         DS    0D
STRPACK  DS    PL8
RXMSGD   DS    CL2
RXDDN    DS    CL8
         DS    CL1
RXFUNC   DS    CL8
RXMSG1   DS    CL11
RXKEY    DS    CL8
         ORG   RXKEY
RCOD     DS    CL4
         DS    CL4
         DS    CL2
RXRECORD DS    CL64
         ORG   RXMSGD
RXMSG    DS    CL133
RXVSARLN DS    0CL133              VSMDLEN
VSMLINE  DS    0CL130
         DS    CL1
         ORG   *+128
WORKLEN  EQU   *-WORKAREA
* --------------------------------------------------------------------
*    REGISTER DEFINITIONS
* --------------------------------------------------------------------
         COPY  MRXREGS
         END   RXVSAM
