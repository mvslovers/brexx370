TSTVPOOL TITLE 'CALL THE VARIABLE ROUTINE OF THE IRXEXTE VECTOR (#602)'
* --------------------------------------------------------------------
*   TEST HELPER FOR TEST/VARPOOL.REXX AND ITS SIBLINGS. A TSO COMMAND
*   THAT AN EXEC CALLS WITH ADDRESS TSO, SO IT RUNS WHILE THE EXEC SITS
*   IN A HOST COMMAND, AND THAT PLAYS THE ROLE OF IKJCT441 / ISPF:
*
*     CPPL -> ECT -> ECTENVBK (ECT+X'30') -> ENVBLOCK -> IRXEXTE
*          -> THE IRXEXCOM ENTRY -> CALL IT WITH AN SHVBLOCK CHAIN.
*
*   THE OPERAND IS THE MODE. A MODE THAT TOUCHES THE VARIABLES RUNS A
*   FIXED SET OF CHECKS AND ENDS WITH RC = THE NUMBER OF CHECKS THAT
*   FAILED. THE EXEC SETS UP THE VARIABLES BEFORE THE CALL AND LOOKS AT
*   THEM AFTER IT, SO THE ROUTINE UNDER TEST DOES NOT JUDGE ITSELF.
*   EVERY FAILED CHECK, AND EVERY OBSERVATION THE CONTRACT DOES NOT PIN
*   DOWN (INFO), IS A WTO LINE: MODE, CHECK NUMBER, WHAT, RC OF THE
*   CALL, SHVRET AND SHVVALL OF THE FIRST BLOCK, AND 16 BYTES OF VALUE.
*
*   MODE      WHAT                                      RC
*   ENV       ECTENVBK, ENVBLOCK, IRXEXTE, ENTRY        FAILED CHECKS
*   FETCH     F, f: SET, EMPTY, UNSET, TRUNC, LONG      FAILED CHECKS
*   STORE     S, s: NEW, OLD, EMPTY, BLANKS, BINARY     FAILED CHECKS
*   DROP      D, d, then F sees the drop                FAILED CHECKS
*   STEM      compound names, direct and symbolic       FAILED CHECKS
*   NEXT      N: the walk, its end, truncation, chain   FAILED CHECKS
*   CHAIN     several blocks in one call, one bad       FAILED CHECKS
*   PRIV      P                                         FAILED CHECKS
*   BAD       invalid codes and names                   FAILED CHECKS
*   CONV      the forms of the parameter list and R0    FAILED CHECKS
*   ENVADDR   nothing checked                           ECTENVBK
*   CHKZERO   ECTENVBK must be 0                        0 OR 1
*   CHKSENT   ECTENVBK must be the address of the CVT   0 OR 1
*   IOSTK     ENVBLOCK+X'130' = IOSTELM; X'134'-X'13F' 0 FAILED CHECKS
*   TOPADDR   nothing checked                           IOSTELM
*   TOPWORD   nothing checked                           ENVBLOCK+X'130'
*   RSVMARK   write a marker into ENVBLOCK+X'134'..13F  0
*   RSVCHK    marker still there? then clear it         0 OR 1
*   STEAL     set ECTENVBK to the address of the CVT    0
*   ZAP       set ECTENVBK to 0                         0
*   ABEND     S0C1                                      -
*
*   NO OPERAND, OR A CALL THAT IS NO TSO COMMAND (TEST --MVS CALLS IT
*   WITH A PARAMETER LIST): RC 0 AND NOTHING DONE.
*
*   RC = ECTENVBK IS AN ADDRESS BELOW 16 MB, SO IT FITS A RETURN CODE.
* --------------------------------------------------------------------
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
         MACRO
         CHECK &C,&ID,&WHAT
         B&C   ZP&SYSNDX            CONDITION HOLDS: PASSED
         LA    R1,=CL16&WHAT
         LA    R0,&ID
         BAL   R14,FAILIT
         B     ZE&SYSNDX
ZP&SYSNDX BAL  R14,PASSIT
ZE&SYSNDX DS   0H
         MEND
         MACRO
         BLK   &B,&CODE,&NAME,&NAML,&VALA,&VALL,&BUFL
         LA    R1,&B
         LA    R2,&CODE
         LA    R3,&NAME
         LA    R4,&NAML
         LA    R5,&VALA
         LA    R6,&VALL
         LA    R0,&BUFL
         BAL   R14,MKB
         MEND
         MACRO
         INFO  &ID,&WHAT
         LA    R1,=CL16&WHAT
         LA    R0,&ID
         BAL   R14,INFOIT
         MEND
         MACRO
         CALLB &B
         LA    R2,&B
         BAL   R14,CALLX
         MEND
TSTVPOOL CSECT
         STM   R14,R12,12(R13)
         LR    R12,R15
         LA    R11,4095(,R12)
         LA    R11,1(,R11)
         LA    R9,4095(,R11)
         LA    R9,1(,R9)
         LA    R8,4095(,R9)
         LA    R8,1(,R8)
         USING TSTVPOOL,R12,R11,R9,R8
         L     R10,ADDRW
         L     R7,ADDRV
         USING TSTVPOOW,R10
         USING TSTVPOOV,R7
         BAL   R14,PRINIT
         B     START
ADDRW    DC    A(TSTVPOOW)
ADDRV    DC    A(TSTVPOOV)
START    DS    0H
         ST    R13,SAVE+4
         LA    R15,SAVE
         ST    R15,8(,R13)
         LR    R13,R15
         XC    EXITRC,EXITRC
         XC    NFAIL,NFAIL
         XC    NCHK,NCHK
         LTR   R1,R1                NO PARAMETER LIST
         BZ    EXIT
         TM    0(R1),X'80'          A PROGRAM'S PARM LIST (TEST --MVS)
         BO    EXIT
         ST    R1,CPPLA
         L     R3,0(,R1)            COMMAND BUFFER
         LH    R4,2(,R3)            OFFSET OF THE OPERAND
         LH    R5,0(,R3)            LENGTH INCLUDING THE 4 BYTE HEADER
         SH    R5,=H'4'
         SR    R5,R4                LENGTH OF THE OPERAND PART
         BNP   EXIT
         LA    R6,4(R3,R4)
         MVC   MODE,=CL8' '
         LA    R4,MODE
         LA    R2,8
CPYM     CLI   0(R6),C' '
         BE    CPYDONE
         MVC   0(1,R4),0(R6)
         LA    R6,1(,R6)
         LA    R4,1(,R4)
         BCTR  R5,0
         LTR   R5,R5
         BNP   CPYDONE
         BCT   R2,CPYM
CPYDONE  OC    MODE,=8X'40'         LOWER CASE TO UPPER CASE
         LA    R2,MODETAB
FIND     CLC   0(8,R2),=8X'00'
         BE    UNKNOWN
         CLC   0(8,R2),MODE
         BE    GOT
         LA    R2,12(,R2)
         B     FIND
UNKNOWN  MVC   EXITRC,=F'90'
         B     EXIT
GOT      L     R3,8(,R2)
         LA    R4,0(,R3)            24 BIT ADDRESS OF THE HANDLER
         ST    R4,HANDLER
         TM    8(R2),X'80'          NEEDS THE ENVIRONMENT FIRST
         BNO   RUN
         BAL   R14,FINDENV
         L     R15,NFAIL
         LTR   R15,R15
         BNZ   SUMMARY
RUN      L     R15,HANDLER
         BALR  R14,R15
         CLC   MODE,=CL8'ENVADDR'
         BE    EXIT
         CLC   MODE,=CL8'CHKZERO'
         BE    EXIT
         CLC   MODE,=CL8'CHKSENT'
         BE    EXIT
         CLC   MODE,=CL8'TOPADDR'
         BE    EXIT
         CLC   MODE,=CL8'TOPWORD'
         BE    EXIT
         CLC   MODE,=CL8'RSVMARK'
         BE    EXIT
         CLC   MODE,=CL8'RSVCHK'
         BE    EXIT
SUMMARY  BAL   R14,SUMIT
         MVC   EXITRC,NFAIL
EXIT     L     R15,EXITRC
         L     R13,SAVE+4
         ST    R15,16(,R13)
         LM    R14,R12,12(R13)
         BR    R14
PRINIT   LA    R2,PRTAB
         SR    R3,R3
PRL      STC   R3,0(R3,R2)
         LA    R3,1(,R3)
         C     R3,=F'256'
         BL    PRL
         MVI   PRTAB,C'.'
         MVC   PRTAB+1(63),PRTAB
         MVI   PRTAB+255,C'.'
         BR    R14
* --------------------------------------------------------------------
*   FINDENV: CPPL -> ECT -> ECTENVBK -> ENVBLOCK -> IRXEXTE -> ENTRY.
*   CHECKS 1 TO 4; A FAILED ONE ENDS IT, NFAIL > 0 TELLS THE CALLER.
* --------------------------------------------------------------------
FINDENV  ST    R14,FESAVE
         L     R1,CPPLA
         L     R2,12(,R1)           ECT
         L     R3,48(,R2)           ECTENVBK
         ST    R3,ENVP
         ST    R3,R0VAL
         ST    R3,PLENV
         MVI   NPARM,5
         LTR   R3,R3
         CHECK NZ,1,'ECTENVBK NOT 0'
         L     R15,NFAIL
         LTR   R15,R15
         BNZ   FEOUT
         L     R3,ENVP
         CLC   0(8,R3),=C'ENVBLOCK'
         CHECK E,2,'ENVBLOCK ID'
         L     R15,NFAIL
         LTR   R15,R15
         BNZ   FEOUT
         L     R3,ENVP
         L     R4,28(,R3)           ENVBLOCK_IRXEXTE
         ST    R4,IRXEXTEP
         LTR   R4,R4
         CHECK NZ,3,'IRXEXTE ADDRESS'
         L     R15,NFAIL
         LTR   R15,R15
         BNZ   FEOUT
         L     R4,IRXEXTEP
         L     R5,16(,R4)           IRXEXCOM ENTRY
         ST    R5,XCOMADR
         LTR   R5,R5
         CHECK NZ,4,'IRXEXCOM ENTRY'
FEOUT    L     R14,FESAVE
         BR    R14
* --------------------------------------------------------------------
*   MKB: BUILD AN SHVBLOCK. R1 = BLOCK, R2 = CODE, R3 = NAMA,
*   R4 = NAML,
*   R5 = VALA, R6 = VALL, R0 = BUFL. SHVUSER STAYS 0.
* --------------------------------------------------------------------
MKB      XC    0(32,R1),0(R1)
         STC   R2,SHVCODE(,R1)
         ST    R3,SHVNAMA(,R1)
         ST    R4,SHVNAML(,R1)
         ST    R5,SHVVALA(,R1)
         ST    R6,SHVVALL(,R1)
         ST    R0,SHVBUFL(,R1)
         BR    R14
* --------------------------------------------------------------------
*   CALLX: CALL THE ROUTINE FROM THE IRXEXTE WITH THE CHAIN AT R2.
*   NPARM (4 OR 5) PARAMETERS: 'IRXEXCOM', 0, 0, CHAIN, [ENVBLOCK].
*   R0 = R0VAL. RC IN LASTRC.
* --------------------------------------------------------------------
CALLX    ST    R14,CXSAVE
         XC    PL(24),PL
         LA    R15,IDXCOM
         ST    R15,PL
         ST    R2,PL+12
         MVC   PL+16(4),PLENV
         CLI   NPARM,4
         BNE   CX5
         OI    PL+12,X'80'
         B     CXGO
CX5      OI    PL+16,X'80'
CXGO     L     R0,R0VAL
         LA    R1,PL
         L     R15,XCOMADR
         BALR  R14,R15
         ST    R15,LASTRC
         L     R14,CXSAVE
         BR    R14
* --------------------------------------------------------------------
*   CLRV: FILL THE VALUE BUFFER WITH '.' SO THAT A BYTE THE ROUTINE
*   DID NOT WRITE CAN BE TOLD FROM ONE IT DID.
* --------------------------------------------------------------------
CLRV     MVI   VBUF,C'.'
* FILLR: FILL VBUF WITH VBUF(1); ONE MVC MOVES 256 AT MOST
FILLR    STM   R0,R2,FLSV
         MVC   VBUF+1(255),VBUF
         LA    R1,VBUF+256
         LA    R2,14
FILLP    MVC   0(256,R1),VBUF
         LA    R1,256(,R1)
         BCT   R2,FILLP
         MVC   0(160,R1),VBUF
         LM    R0,R2,FLSV
         BR    R14
* --------------------------------------------------------------------
*   PASSIT / FAILIT / INFOIT: R0 = NUMBER OF THE CHECK, R1 = 16
*   BYTES OF
*   TEXT. FAILIT AND INFOIT WRITE A LINE.
* --------------------------------------------------------------------
PASSIT   L     R15,NCHK
         LA    R15,1(,R15)
         ST    R15,NCHK
         BR    R14
FAILIT   L     R15,NCHK
         LA    R15,1(,R15)
         ST    R15,NCHK
         L     R15,NFAIL
         LA    R15,1(,R15)
         ST    R15,NFAIL
         MVC   MSGKIND,=C'FAIL'
         B     MSGOUT
INFOIT   MVC   MSGKIND,=C'INFO'
MSGOUT   ST    R14,MOSAVE
         STM   R2,R9,MOREGS
         MVC   MSGWHAT,0(R1)
         MVC   MSGMODE,MODE
         CVD   R0,DW
         UNPK  MSGID(3),DW+6(2)
         OI    MSGID+2,X'F0'
         L     R2,LASTRC
         LA    R3,MSGRC
         BAL   R14,HEX8
         SR    R2,R2
         IC    R2,B1+SHVRET
         LA    R3,HX
         BAL   R14,HEX8
         MVC   MSGRET,HX+6
         L     R2,B1+SHVVALL
         LA    R3,MSGVALL
         BAL   R14,HEX8
         MVC   MSGVAL,VBUF
         TR    MSGVAL,PRTAB
         LA    R1,MSGBUF
         SVC   35
         LM    R2,R9,MOREGS
         L     R14,MOSAVE
         BR    R14
* HEX8: R2 = VALUE, R3 = WHERE TO PUT 8 HEX DIGITS
HEX8     ST    R2,HW
         UNPK  HXW(9),HW(5)
         TR    HXW(8),HEXTAB-240
         MVC   0(8,R3),HXW
         MVC   HX(8),HXW
         BR    R14
* SUMIT: THE LAST LINE OF A MODE
SUMIT    ST    R14,SUSAVE
         MVC   SUMMODE,MODE
         L     R0,NCHK
         CVD   R0,DW
         UNPK  SUMCHK(3),DW+6(2)
         OI    SUMCHK+2,X'F0'
         L     R0,NFAIL
         CVD   R0,DW
         UNPK  SUMFAIL(3),DW+6(2)
         OI    SUMFAIL+2,X'F0'
         LA    R1,SUMBUF
         SVC   35
         L     R14,SUSAVE
         BR    R14
* --------------------------------------------------------------------
*   ENV: THE CHAIN OF POINTERS ITSELF (CHECKS 1 TO 4 RAN IN FINDENV).
* --------------------------------------------------------------------
H_ENV    ST    R14,HSAVE
         BAL   R14,FINDENV
         L     R15,NFAIL
         LTR   R15,R15
         BNZ   HEOUT
         L     R4,IRXEXTEP
         L     R2,0(,R4)            IRXEXTE_ENTRY_COUNT
         ST    R2,LASTRC
         XC    B1,B1
         INFO  5,'IRXEXTE COUNT'
HEOUT    L     R14,HSAVE
         BR    R14
* --------------------------------------------------------------------
*   FETCH. THE EXEC SETS A='alpha', E='' (SET, EMPTY), LONG = 3000 'x'
*   AND LEAVES UNSETX UNSET.
* --------------------------------------------------------------------
H_FETCH  ST    R14,HSAVE
         BAL   R14,CLRV
         BLK   B1,C'F',NMA,1,VBUF,0,4000
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,10,'F A RC=0'
         CLI   B1+SHVRET,0
         CHECK E,11,'F A SHVRET=0'
         CLC   B1+SHVVALL(4),=F'5'
         CHECK E,12,'F A SHVVALL=5'
         CLC   VBUF(6),=C'alpha.'
         CHECK E,13,'F A VALUE'
         BAL   R14,CLRV
         BLK   B1,C'F',NME,1,VBUF,0,4000
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,14,'F E (EMPTY) RC=0'
         CLI   B1+SHVRET,0
         CHECK E,15,'F E SHVRET=0'
         CLC   B1+SHVVALL(4),=F'0'
         CHECK E,16,'F E SHVVALL=0'
         BAL   R14,CLRV
         BLK   B1,C'F',NMUNS,6,VBUF,0,4000
         CALLB B1
         TM    B1+SHVRET,X'01'
         CHECK O,17,'F UNSET SHVNEWV'
         CLC   B1+SHVVALL(4),=F'6'
         CHECK E,18,'F UNSET VALL=6'
         CLC   VBUF(7),=C'UNSETX.'
         CHECK E,19,'F UNSET NAME'
         INFO  20,'F UNSET (RC)'
         BAL   R14,CLRV
         BLK   B1,C'F',NMA,1,VBUF,0,2
         CALLB B1
         TM    B1+SHVRET,X'04'
         CHECK O,21,'F A SHORT TRUNC'
         CLC   VBUF(3),=C'al.'
         CHECK E,22,'F A SHORT DATA'
         CLC   B1+SHVVALL(4),=F'5'
         CHECK E,23,'F A SHORT VALL=5'
         BAL   R14,CLRV
         BLK   B1,C'F',NMLONG,4,VBUF,0,4000
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,24,'F LONG RC=0'
         CLC   B1+SHVVALL(4),=F'3000'
         CHECK E,25,'F LONG VALL'
         CLI   VBUF,C'x'
         CHECK E,26,'F LONG FIRST'
         CLI   VBUF+2999,C'x'
         CHECK E,27,'F LONG LAST'
         CLI   VBUF+3000,C'.'
         CHECK E,28,'F LONG NO MORE'
         BAL   R14,CLRV
         BLK   B1,C'f',NMA,1,VBUF,0,4000
         CALLB B1
         CLC   VBUF(6),=C'alpha.'
         CHECK E,29,'f A (SYMBOLIC)'
         CLI   B1+SHVRET,0
         CHECK E,30,'f A SHVRET=0'
         L     R14,HSAVE
         BR    R14
* --------------------------------------------------------------------
*   STORE. THE EXEC SETS A='old' AND LEAVES B, C, D2, LONG2, BIN AND
*   LOWSET UNSET; IT CHECKS THE VARIABLES AFTER THE CALL.
* --------------------------------------------------------------------
H_STORE  ST    R14,HSAVE
         BLK   B1,C'S',NMB,1,VTWO,3,0
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,10,'S B RC=0'
         CLI   B1+SHVRET,X'01'
         CHECK E,11,'S NEW SHVNEWV'
         BLK   B1,C'S',NMA,1,VNEW,3,0
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,12,'S A RC=0'
         CLI   B1+SHVRET,0
         CHECK E,13,'S A OLD SHVRET'
         BLK   B1,C'S',NMC,1,VTWO,0,0
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,14,'S C EMPTY RC=0'
         BLK   B1,C'S',NMD2,2,VBLANK,15,0
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,15,'S D2 BLANKS RC'
         MVI   VBUF,C'y'
         BAL   R14,FILLR
         BLK   B1,C'S',NMLONG2,5,VBUF,3000,0
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,16,'S LONG2 RC=0'
         BLK   B1,C'S',NMBIN,3,VBIN,6,0
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,17,'S BIN RC=0'
         BLK   B1,C's',NMLOW,6,VTWO,3,0
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,18,'s LOWSET RC=0'
         L     R14,HSAVE
         BR    R14
* --------------------------------------------------------------------
*   DROP. THE EXEC SETS A='x', LEAVES UNSETD UNSET AND CHECKS THAT A
*   IS GONE.
* --------------------------------------------------------------------
H_DROP   ST    R14,HSAVE
         BLK   B1,C'D',NMA,1,0,0,0
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,10,'D A RC=0'
         CLI   B1+SHVRET,0
         CHECK E,11,'D A SHVRET=0'
         BAL   R14,CLRV
         BLK   B1,C'F',NMA,1,VBUF,0,4000
         CALLB B1
         TM    B1+SHVRET,X'01'
         CHECK O,12,'F AFTER D: NEWV'
         CLC   VBUF(2),=C'A.'
         CHECK E,13,'F AFTER D: NAME'
         BLK   B1,C'D',NMUNSD,6,0,0,0
         CALLB B1
         INFO  14,'D UNSET'
         BLK   B1,C'd',NMDS,2,0,0,0
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,15,'d DS RC=0'
         L     R14,HSAVE
         BR    R14
* --------------------------------------------------------------------
*   STEM. THE EXEC SETS ST.1='x', ST.2='y', I=2, AND LEAVES J, NEWST.
*   AND ST.I UNSET.
* --------------------------------------------------------------------
H_STEM   ST    R14,HSAVE
         BAL   R14,CLRV
         BLK   B1,C'F',NMST1,4,VBUF,0,4000
         CALLB B1
         CLC   VBUF(2),=C'x.'
         CHECK E,10,'F ST.1'
         CLI   B1+SHVRET,0
         CHECK E,11,'F ST.1 SHVRET=0'
         BLK   B1,C'S',NMST3,4,VZ,1,0
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,12,'S ST.3 RC=0'
         BAL   R14,CLRV
         BLK   B1,C'f',NMSTI,4,VBUF,0,4000
         CALLB B1
         CLC   VBUF(2),=C'y.'
         CHECK E,13,'f ST.I TAIL'
         BLK   B1,C's',NMSTI,4,VY2,2,0
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,14,'s ST.I RC=0'
         BLK   B1,C'S',NMSTI,4,VLIT,3,0
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,15,'S ST.I DIRECT'
         BLK   B1,C'S',NMNEWST,6,VDFLT,4,0
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,16,'S NEWST. RC=0'
         BAL   R14,CLRV
         BLK   B1,C'F',NMNEWST,6,VBUF,0,4000
         CALLB B1
         CLC   VBUF(5),=C'dflt.'
         CHECK E,17,'F NEWST. VALUE'
         BLK   B1,C'D',NMST,3,0,0,0
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,18,'D ST. RC=0'
         BAL   R14,CLRV
         BLK   B1,C'F',NMST1,4,VBUF,0,4000
         CALLB B1
         TM    B1+SHVRET,X'01'
         CHECK O,19,'F ST.1 AFTER D'
         L     R14,HSAVE
         BR    R14
* --------------------------------------------------------------------
*   NEXT. THE EXEC SETS W1='one', W2='two', W3.A='tri', W3.B='quad'
*   BESIDE ITS OWN VARIABLES.
* --------------------------------------------------------------------
H_NEXT   ST    R14,HSAVE
         BLK   B1,C'F',NMA,1,VBUF,0,4000
         CALLB B1                   ANY CALL BUT N RESETS THE WALK
         BAL   R14,WALK
         CLI   LVARF,1
         CHECK E,10,'N LAST VAR FLAG'
         CLI   SEEN,X'0F'
         CHECK E,11,'N ALL MARKERS'
         CLI   DUPF,0
         CHECK E,12,'N NO DUPLICATE'
         CLI   VALBAD,0
         CHECK E,13,'N MARKER VALUES'
         CLC   WCNT,=F'4'
         CHECK NL,14,'N COUNT >= 4'
         CLC   WRC,=F'0'
         CHECK E,15,'N RC=0 ALL THE WAY'
         MVC   WCNT1,WCNT
         BLK   B1,C'F',NMA,1,VBUF,0,4000
         CALLB B1
         BAL   R14,WALK
         CLC   WCNT,WCNT1
         CHECK E,16,'N 2ND WALK COUNT'
         BLK   B1,C'F',NMA,1,VBUF,0,4000
         CALLB B1
         BLK   B1,C'N',NBUF,0,VBUF,0,4000
         MVC   B1+SHVUSER(4),=F'1'
         CALLB B1
         TM    B1+SHVRET,X'04'
         BO    NXTOK
         CLC   B1+SHVNAML(4),=F'1'
         BNH   NXTOK
         LA    R0,17
         LA    R1,=CL16'N NAME TRUNC'
         BAL   R14,FAILIT
         B     NXTCH
NXTOK    BAL   R14,PASSIT
NXTCH    DS    0H
         BLK   B1,C'F',NMA,1,VBUF,0,4000
         CALLB B1
         BLK   B1,C'N',NB1,0,VB1,0,100
         MVC   B1+SHVUSER(4),=F'64'
         BLK   B2,C'N',NB2,0,VB2,0,100
         MVC   B2+SHVUSER(4),=F'64'
         BLK   B3,C'N',NB3,0,VB3,0,100
         MVC   B3+SHVUSER(4),=F'64'
         LA    R1,B2
         ST    R1,B1+SHVNEXT
         LA    R1,B3
         ST    R1,B2+SHVNEXT
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,18,'N CHAIN RC=0'
         L     R2,B1+SHVNAML
         CL    R2,FIRST3
         BNE   NXTBAD
         BCTR  R2,0
         EX    R2,CMPN1
         BNE   NXTBAD
         L     R2,B2+SHVNAML
         CL    R2,FIRST3+44
         BNE   NXTBAD
         BCTR  R2,0
         EX    R2,CMPN2
         BNE   NXTBAD
         L     R2,B3+SHVNAML
         CL    R2,FIRST3+88
         BNE   NXTBAD
         BCTR  R2,0
         EX    R2,CMPN3
         BNE   NXTBAD
         BAL   R14,PASSIT
         B     NXTEND
NXTBAD   LA    R0,19
         LA    R1,=CL16'N CHAIN ORDER'
         BAL   R14,FAILIT
NXTEND   L     R14,HSAVE
         BR    R14
CMPN1    CLC   NB1(0),FIRST3+4
CMPN2    CLC   NB2(0),FIRST3+44+4
CMPN3    CLC   NB3(0),FIRST3+88+4
* WALK WITH ONE N BLOCK AT A TIME UNTIL SHVLVAR
WALK     ST    R14,WSAVE
         XC    WCNT,WCNT
         XC    WRC,WRC
         MVI   SEEN,0
         MVI   DUPF,0
         MVI   LVARF,0
         MVI   VALBAD,0
WLOOP    BAL   R14,CLRV
         BLK   B1,C'N',NBUF,0,VBUF,0,4000
         MVC   B1+SHVUSER(4),=F'256'
         CALLB B1
         L     R2,LASTRC
         ST    R2,WRC
         LTR   R2,R2
         BNZ   WOUT
         L     R2,WCNT
         LA    R2,1(,R2)
         ST    R2,WCNT
         C     R2,=F'3'
         BH    WMARK
         BCTR  R2,0                 SAVE THE FIRST THREE NAMES
         MH    R2,=H'44'
         LA    R3,FIRST3(R2)
         L     R4,B1+SHVNAML
         ST    R4,0(,R3)
         C     R4,=F'40'
         BNH   WSAVEN
         LA    R4,40
WSAVEN   BCTR  R4,0
         EX    R4,MVN
WMARK    LA    R2,MARKTAB
WMLOOP   CLI   0(R2),0
         BE    WNEXT
         SR    R3,R3
         IC    R3,0(,R2)
         C     R3,B1+SHVNAML
         BNE   WMSKIP
         BCTR  R3,0
         EX    R3,CMPMARK
         BNE   WMSKIP
         SR    R5,R5
         IC    R5,2(,R2)
         EX    R5,TMSEEN
         BNO   WFIRST
         MVI   DUPF,1
WFIRST   EX    R5,OISEEN
         SR    R3,R3
         IC    R3,1(,R2)
         C     R3,B1+SHVVALL
         BNE   WVBAD
         BCTR  R3,0
         EX    R3,CMPVAL
         BE    WNEXT
WVBAD    MVI   VALBAD,1
         B     WNEXT
WMSKIP   LA    R2,28(,R2)
         B     WMLOOP
WNEXT    TM    B1+SHVRET,X'02'
         BNO   WCONT
         MVI   LVARF,1
         B     WOUT
WCONT    L     R2,WCNT
         C     R2,=F'2000'
         BL    WLOOP
WOUT     L     R14,WSAVE
         BR    R14
MVN      MVC   4(0,R3),NBUF
CMPMARK  CLC   NBUF(0),4(R2)
CMPVAL   CLC   VBUF(0),16(R2)
TMSEEN   TM    SEEN,0
OISEEN   OI    SEEN,0
* --------------------------------------------------------------------
*   CHAIN. THE EXEC SETS X1='a' AND LEAVES UNSETC UNSET.
* --------------------------------------------------------------------
H_CHAIN  ST    R14,HSAVE
         BAL   R14,CLRV
         BLK   B1,C'S',NMQ1,2,VTWO,3,0
         BLK   B2,C'X',NMA,1,0,0,0
         BLK   B3,C'F',NMX1,2,VBUF,0,4000
         BLK   B4,C'F',NMUNSC,6,VB4,0,100
         LA    R1,B2
         ST    R1,B1+SHVNEXT
         LA    R1,B3
         ST    R1,B2+SHVNEXT
         LA    R1,B4
         ST    R1,B3+SHVNEXT
         CALLB B1
         CLI   B1+SHVRET,X'01'
         CHECK E,10,'CHAIN B1 NEWV'
         TM    B2+SHVRET,X'80'
         CHECK O,11,'CHAIN B2 SHVBADF'
         CLI   B3+SHVRET,0
         CHECK E,12,'CHAIN B3 SHVRET=0'
         CLC   VBUF(2),=C'a.'
         CHECK E,13,'CHAIN B3 VALUE'
         TM    B4+SHVRET,X'01'
         CHECK O,14,'CHAIN B4 NEWV'
         CLC   LASTRC,=F'0'
         BNE   CHRC
         LA    R0,15
         LA    R1,=CL16'CHAIN RC NOT 0'
         BAL   R14,FAILIT
         B     CHEND
CHRC     BAL   R14,PASSIT
CHEND    DS    0H
         INFO  16,'CHAIN RC'
         L     R14,HSAVE
         BR    R14
* --------------------------------------------------------------------
*   PRIV. P FETCHES PRIVATE INFORMATION OF THE EXEC.
* --------------------------------------------------------------------
H_PRIV   ST    R14,HSAVE
         BAL   R14,CLRV
         BLK   B1,C'P',NMSRC,6,VBUF,0,4000
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,10,'P SOURCE RC=0'
         CLI   B1+SHVRET,0
         CHECK E,11,'P SOURCE SHVRET'
         CLC   B1+SHVVALL(4),=F'0'
         CHECK H,12,'P SOURCE VALL>0'
         BAL   R14,CLRV
         BLK   B1,C'P',NMVER,7,VBUF,0,4000
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,13,'P VERSION RC=0'
         CLC   B1+SHVVALL(4),=F'0'
         CHECK H,14,'P VERSION VALL>0'
         INFO  15,'P VERSION'
         BAL   R14,CLRV
         BLK   B1,C'P',NMPARM,4,VBUF,0,4000
         CALLB B1
         INFO  16,'P PARM'
         BAL   R14,CLRV
         BLK   B1,C'P',NMXYZ,5,VBUF,0,4000
         CALLB B1
         INFO  17,'P UNKNOWN NAME'
         L     R14,HSAVE
         BR    R14
* --------------------------------------------------------------------
*   BAD. INVALID CODES AND NAMES. THE EXEC CHECKS A STILL HAS 'alpha'.
* --------------------------------------------------------------------
H_BAD    ST    R14,HSAVE
         BLK   B1,C'X',NMA,1,VTWO,3,0
         CALLB B1
         TM    B1+SHVRET,X'80'
         CHECK O,10,'CODE X SHVBADF'
         CLC   LASTRC,=F'0'
         CHECK NE,11,'CODE X RC NOT 0'
         INFO  12,'CODE X'
         BLK   B1,C'S',NMA,0,VTWO,3,0
         CALLB B1
         TM    B1+SHVRET,X'08'
         CHECK O,13,'S EMPTY NAME'
         BLK   B1,C'S',NMDIG,4,VTWO,3,0
         CALLB B1
         TM    B1+SHVRET,X'08'
         CHECK O,14,'S 1ABC SHVBADN'
         BLK   B1,C'S',NMBLK,3,VTWO,3,0
         CALLB B1
         TM    B1+SHVRET,X'08'
         CHECK O,15,'S A B SHVBADN'
         BAL   R14,CLRV
         BLK   B1,C'F',NMBLK,3,VBUF,0,4000
         CALLB B1
         TM    B1+SHVRET,X'08'
         CHECK O,16,'F A B SHVBADN'
         BLK   B1,C'D',NMDIG,4,0,0,0
         CALLB B1
         TM    B1+SHVRET,X'08'
         CHECK O,17,'D 1ABC SHVBADN'
         BLK   B1,C'S',NMA,1,VTWO,3,0
         CALLB B1
         CLC   LASTRC,=F'0'
         CHECK E,18,'VALID S AFTER BAD'
         L     R14,HSAVE
         BR    R14
* --------------------------------------------------------------------
*   CONV. THE FORMS OF THE CALL. THE EXEC SETS A='alpha'.
* --------------------------------------------------------------------
H_CONV   ST    R14,HSAVE
         MVI   NPARM,4
         BAL   R14,CLRV
         BLK   B1,C'F',NMA,1,VBUF,0,4000
         CALLB B1
         CLC   VBUF(6),=C'alpha.'
         CHECK E,10,'4 PARMS, R0=ENV'
         MVI   NPARM,5
         XC    R0VAL,R0VAL
         BAL   R14,CLRV
         BLK   B1,C'F',NMA,1,VBUF,0,4000
         CALLB B1
         CLC   VBUF(6),=C'alpha.'
         CHECK E,11,'5 PARMS, R0=0'
         MVI   NPARM,4
         BAL   R14,CLRV
         BLK   B1,C'F',NMA,1,VBUF,0,4000
         CALLB B1
         INFO  12,'4 PARMS, R0=0'
         MVC   R0VAL,ENVP
         MVI   NPARM,5
         MVC   IDXCOM,=C'NOTIRXEX'
         BAL   R14,CLRV
         BLK   B1,C'F',NMA,1,VBUF,0,4000
         CALLB B1
         INFO  13,'PARM 1 WRONG'
         MVC   IDXCOM,=C'IRXEXCOM'
         MVC   PLENV,=A(BOGUS)
         MVC   R0VAL,=A(BOGUS)
         BAL   R14,CLRV
         BLK   B1,C'F',NMA,1,VBUF,0,4000
         CALLB B1
         INFO  14,'BOGUS ENVBLOCK'
         MVC   PLENV,ENVP
         MVC   R0VAL,ENVP
         L     R14,HSAVE
         BR    R14
* --------------------------------------------------------------------
*   THE MODES THAT LOOK AT ECTENVBK ONLY
* --------------------------------------------------------------------
H_ENVAD L    R1,CPPLA
         L     R2,12(,R1)
         L     R3,48(,R2)
         ST    R3,EXITRC
         BR    R14
H_CHKZ ST   R14,HSAVE
         L     R1,CPPLA
         L     R2,12(,R1)
         L     R3,48(,R2)
         ST    R3,LASTRC
         XC    B1,B1
         XC    EXITRC,EXITRC
         LTR   R3,R3
         BZ    CZOUT
         MVC   EXITRC,=F'1'
         INFO  1,'ECTENVBK NOT 0'
CZOUT    L     R14,HSAVE
         BR    R14
H_CHKS ST   R14,HSAVE
         L     R1,CPPLA
         L     R2,12(,R1)
         L     R3,48(,R2)
         ST    R3,LASTRC
         XC    B1,B1
         XC    EXITRC,EXITRC
         L     R4,16               CVT
         CR    R3,R4
         BE    CSOUT
         MVC   EXITRC,=F'1'
         INFO  1,'ECTENVBK CHANGED'
CSOUT    L     R14,HSAVE
         BR    R14
H_TOPA   L     R1,CPPLA
         L     R2,12(,R1)
         L     R3,4(,R2)            ECTIOWA
         LTR   R3,R3
         BZR   R14
         L     R4,0(,R3)            IOSTELM
         ST    R4,EXITRC
         BR    R14
H_TOPW   L     R1,CPPLA
         L     R2,12(,R1)
         L     R3,48(,R2)           ECTENVBK
         LTR   R3,R3
         BZR   R14
         L     R4,304(,R3)          ENVBLOCK+X'130'
         ST    R4,EXITRC
         BR    R14
H_RSVM   L     R1,CPPLA
         L     R2,12(,R1)
         L     R3,48(,R2)
         LTR   R3,R3
         BZR   R14
         MVC   308(12,R3),RSVMRK
         BR    R14
H_RSVC   ST    R14,HSAVE
         XC    B1,B1
         XC    EXITRC,EXITRC
         L     R1,CPPLA
         L     R2,12(,R1)
         L     R3,48(,R2)
         ST    R3,LASTRC
         LTR   R3,R3
         BNZ   RC1
         MVC   EXITRC,=F'1'
         INFO  1,'NO ENVBLOCK'
         B     RCOUT
RC1      CLC   308(12,R3),RSVMRK
         BE    RC2
         MVC   EXITRC,=F'1'
         INFO  2,'RESERVED CHANGED'
RC2      XC    308(12,R3),308(R3)
RCOUT    L     R14,HSAVE
         BR    R14
* IOSTK: THE CONTRACT WORD ENVBLOCK+X'130' HOLDS THE TOP ELEMENT OF
* THE INPUT STACK, ECT -> ECTIOWA -> IOSRL, IOSTELM AT +0; THE THREE
* WORDS BEHIND IT ARE RESERVED AND STAY 0 UNTIL SOMEONE ELSE USES THEM.
H_IOSTK  ST    R14,HSAVE
         XC    B1,B1
         L     R1,CPPLA
         L     R2,12(,R1)
         L     R3,4(,R2)            ECTIOWA
         LTR   R3,R3
         CHECK NZ,20,'ECTIOWA NOT 0'
         L     R2,12(,R1)
         L     R3,4(,R2)
         LTR   R3,R3
         BZ    IKOUT
         L     R4,0(,R3)            IOSTELM
         L     R5,ENVP
         L     R6,304(,R5)          ENVBLOCK+X'130'
         ST    R6,LASTRC
         CR    R6,R4
         CHECK E,21,'TOP WORD=IOSTELM'
         LTR   R4,R4
         BNZ   IK3
         ST    R4,LASTRC
         INFO  22,'IOSTELM IS 0'
IK3      CLC   308(12,R5),=XL12'00'
         CHECK E,23,'RESERVED ARE 0'
IKOUT    L     R14,HSAVE
         BR    R14
H_STEAL  L     R1,CPPLA
         L     R2,12(,R1)
         L     R4,16               CVT
         ST    R4,48(,R2)
         BR    R14
H_ZAP    L     R1,CPPLA
         L     R2,12(,R1)
         XC    48(4,R2),48(R2)
         BR    R14
H_ABEND  DC    H'0'                 OPERATION EXCEPTION -> S0C1
* --------------------------------------------------------------------
         LTORG
TSTVPOOW CSECT
MODETAB  DC    CL8'ENV',X'00',AL3(H_ENV)
         DC    CL8'FETCH',X'80',AL3(H_FETCH)
         DC    CL8'STORE',X'80',AL3(H_STORE)
         DC    CL8'DROP',X'80',AL3(H_DROP)
         DC    CL8'STEM',X'80',AL3(H_STEM)
         DC    CL8'NEXT',X'80',AL3(H_NEXT)
         DC    CL8'CHAIN',X'80',AL3(H_CHAIN)
         DC    CL8'PRIV',X'80',AL3(H_PRIV)
         DC    CL8'BAD',X'80',AL3(H_BAD)
         DC    CL8'CONV',X'80',AL3(H_CONV)
         DC    CL8'ENVADDR',X'00',AL3(H_ENVAD)
         DC    CL8'CHKZERO',X'00',AL3(H_CHKZ)
         DC    CL8'CHKSENT',X'00',AL3(H_CHKS)
         DC    CL8'IOSTK',X'80',AL3(H_IOSTK)
         DC    CL8'TOPADDR',X'00',AL3(H_TOPA)
         DC    CL8'TOPWORD',X'00',AL3(H_TOPW)
         DC    CL8'RSVMARK',X'00',AL3(H_RSVM)
         DC    CL8'RSVCHK',X'00',AL3(H_RSVC)
         DC    CL8'STEAL',X'00',AL3(H_STEAL)
         DC    CL8'ZAP',X'00',AL3(H_ZAP)
         DC    CL8'ABEND',X'00',AL3(H_ABEND)
         DC    8X'00',F'0'
* NAME, VALUE LENGTH, BIT; NAME (12), VALUE (12): 28 BYTES
MARKTAB  DC    AL1(2),AL1(3),AL1(1),AL1(0),CL12'W1',CL12'one'
         DC    AL1(2),AL1(3),AL1(2),AL1(0),CL12'W2',CL12'two'
         DC    AL1(4),AL1(3),AL1(4),AL1(0),CL12'W3.A',CL12'tri'
         DC    AL1(4),AL1(4),AL1(8),AL1(0),CL12'W3.B',CL12'quad'
         DC    AL1(0)
IDXCOM   DC    CL8'IRXEXCOM'
RSVMRK   DC    C'ABCDEFGHIJKL'
HEXTAB   DC    C'0123456789ABCDEF'
NMA      DC    C'A'
NMB      DC    C'B'
NMC      DC    C'C'
NME      DC    C'E'
NMD2     DC    C'D2'
NMDS     DC    C'DS'
NMX1     DC    C'X1'
NMQ1     DC    C'Q1'
NMLONG   DC    C'LONG'
NMLONG2  DC    C'LONG2'
NMBIN    DC    C'BIN'
NMLOW    DC    C'LOWSET'
NMUNS    DC    C'UNSETX'
NMUNSD   DC    C'UNSETD'
NMUNSC   DC    C'UNSETC'
NMST     DC    C'ST.'
NMST1    DC    C'ST.1'
NMST3    DC    C'ST.3'
NMSTI    DC    C'ST.I'
NMNEWST  DC    C'NEWST.'
NMSRC    DC    C'SOURCE'
NMVER    DC    C'VERSION'
NMPARM   DC    C'PARM'
NMXYZ    DC    C'XYZZY'
NMDIG    DC    C'1ABC'
NMBLK    DC    C'A B'
VNEW     DC    C'new'
VTWO     DC    C'two'
VZ       DC    C'z'
VY2      DC    C'Y2'
VLIT     DC    C'lit'
VDFLT    DC    C'dflt'
VBLANK   DC    C'  lead  trail '
VBIN     DC    C'ab',X'00',C'cd',X'FF'
         DS    0D
SAVE     DS    18F
DW       DS    D
EXITRC   DS    F
NFAIL    DS    F
NCHK     DS    F
CPPLA    DS    F
HANDLER  DS    F
ENVP     DS    F
IRXEXTEP DS    F
XCOMADR  DS    F
R0VAL    DS    F
PLENV    DS    F
LASTRC   DS    F
FESAVE   DS    F
CXSAVE   DS    F
HSAVE    DS    F
WSAVE    DS    F
MOSAVE   DS    F
SUSAVE   DS    F
MOREGS   DS    8F
FLSV     DS    3F
WCNT     DS    F
WCNT1    DS    F
WRC      DS    F
HW       DS    F
PL       DS    6F
B1       DS    CL32
B2       DS    CL32
B3       DS    CL32
B4       DS    CL32
FIRST3   DS    CL132
NPARM    DS    X
SEEN     DS    X
DUPF     DS    X
LVARF    DS    X
VALBAD   DS    X
HXW      DS    CL9
HX       DS    CL8
MODE     DS    CL8
NBUF     DS    CL260
NB1      DS    CL64
NB2      DS    CL64
NB3      DS    CL64
VB1      DS    CL100
VB2      DS    CL100
VB3      DS    CL100
VB4      DS    CL100
BOGUS    DS    CL64
PRTAB    DS    CL256
MSGBUF   DS    0H
MSGLEN   DC    AL2(MSGEND-MSGBUF)
         DC    H'0'
         DC    C'TSTVPOOL '
MSGMODE  DC    CL8' '
         DC    C' '
MSGKIND  DC    C'FAIL'
         DC    C' '
MSGID    DC    C'000'
         DC    C' '
MSGWHAT  DC    CL16' '
         DC    C' RC='
MSGRC    DC    CL8' '
         DC    C' RET='
MSGRET   DC    CL2' '
         DC    C' VALL='
MSGVALL  DC    CL8' '
         DC    C' VAL='
MSGVAL   DC    CL16' '
MSGEND   EQU   *
SUMBUF   DC    AL2(SUMEND-SUMBUF)
         DC    H'0'
         DC    C'TSTVPOOL '
SUMMODE  DC    CL8' '
         DC    C' DONE CHECKS='
SUMCHK   DC    C'000'
         DC    C' FAILED='
SUMFAIL  DC    C'000'
SUMEND   EQU   *
SHVNEXT  EQU   0
SHVUSER  EQU   4
SHVCODE  EQU   8
SHVRET   EQU   9
SHVBUFL  EQU   12
SHVNAMA  EQU   16
SHVNAML  EQU   20
SHVVALA  EQU   24
SHVVALL  EQU   28
TSTVPOOV CSECT
VBUF     DS    CL4000
         END   TSTVPOOL
