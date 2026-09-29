* --------------------------------------------------------------------
*   SOME INTERNAL MACROS, JUST NEEDED TO EASE CODING
* --------------------------------------------------------------------
         MACRO
&LABEL   SETDUMP &D1
.* ..... CREATE A SPECIFIC DUMP LINE .................................
&LABEL   L     R1,0(R9)
         BAL   RE,BIN2HEX
         MVC   D&D1,FULLW
         L     R1,TOTLEN
         AH    R1,=AL2(4)
         ST    R1,TOTLEN
         CLI   MODE,X'1'
         BE    R&SYSNDX
         MVC   C&D1,DUMPVIS
R&SYSNDX LA    R9,4(R9)         NEXT ENTRY
         C     R9,MAXADR
         BNL   DUMPEND
         MEND
         MACRO
         PUTLINE &CMT
.* ..... OUTPUT A LINE TO THE DUMP DATASET  ..........................
         LCLA  &CLEN
&CLEN    SETA  K'&CMT-2
         BLANK DUMP
         MVC   DUMP+1(&CLEN),=C&CMT
         PUT   MFDUMP,DUMP
         MEND
         COPY REGS
* --------------------------------------------------------------------
*   MAIN PROGRAM
* --------------------------------------------------------------------
MVSDUMP  PPROC TITLE='MVSDUMP - DUMP PROGRAM'
         BAL   RE,DUMPINIT             INIT DUMPIT
         L     R9,DUMPFROM             START DUMP AT START ADDRESS
* ...... LOOP THROUGH AREA LINE BY LINE  .............................
NXTLINE  BAL   RE,CRELINE              BUILD ONE DUMP LINE
         C     R9,MAXADR               IS NEXT OFFSET > MAX
         BL    NXTLINE                 NO, THEN LOOP
* ...... AREA DUMP COMPLETED, ADD TOTAL STATISTIC  ...................
         BIN2CHR TOTLENC,TOTLEN
         STRLC TOTLENC                 BLANK LEADING ZEROS
         BLANK DUMP
         MVC   DUMP+1(L'TOTLENC),TOTLENC
         MOVCMT DUMP+1+L'TOTLENC+3,'BYTES IN TOTAL DUMPED    '
         PUT   MFDUMP,DUMP             PRINT TOTAL LINE
         PUTLINE '    '                BLANK LINE, IF MORE IS COMING
* ...... CLOSE DUMP FILE AND RETURN  .................................
         CLOSE MFDUMP
         SRETURN
*  THIS IS HOW TO PRINT INTERNALLY AN AREA
*        PUTLINE 'PREVIOUS SAVE AREA'
*        L     R9,4(RD)
*        BAL   RE,DUMPLCL
         EJECT
* --------------------------------------------------------------------
*    CREATE A SINGLE DUMP LINE
* --------------------------------------------------------------------
CRELINE  DS    0H
         ST    RE,SAVE01
         BLANK DUMP                    CLEAR DUMP LINE
         CLI   MODE,X'1'               REGISTER PRINT REQUESTED?
         BE    REGMODE                 YES, JUST HEX PART NEEDED
         MVI   C0,C'*'                 SET THE LEFT DELIMITER
         MVI   C9,C'*'                 SET THE RIGHT DELIMITER
         LR    R1,R9                   LOAD CURRENT ADDRESS TO PRINT
         CLI   DISPMOD,X'1'            DISPLACEMENT MODE
         BNE   FULLADR
         S     R1,DUMPFROM
FULLADR  BAL   RE,BIN2HEX              CONVERT ADDRESS TO HEX
         MVC   DADDR,FULLW             MOVE IT INTO ADDRESS COLUMN
         B     ADRMODE                 CONTINUE WITH 8 FULL WORDS
* ...... REGISTERS ARE PRINTED .......................................
REGMODE  CLI   RMODE,C'1'              REGISTER 1. LINE?
         BNE   REGM2                   NO, THEN PRINT 8-15 COMMENT
         MVC   DADDR,=CL8'REG 0-7'     MOVE 0-7 COMMENT
         MVI   RMODE,C'2'              NEXT WILL BE THE 8-15 COMMENT
         B     ADRMODE
REGM2    MVC   DADDR,=CL8'REG 8-15'    MOVE 8-15 COMMENT
         MVI   RMODE,C'1'              SWITCH BACK TO 1. REGISTER LINE
* ...... HEX CONTENT LINE WILL BE BUILT ..............................
ADRMODE  DS    0H                      PREPARE 1. FULL WORD
         SETDUMP 1                     PREPARE 1. FULL WORD
         SETDUMP 2                     PREPARE 2. FULL WORD
         SETDUMP 3                     PREPARE 3. FULL WORD
         SETDUMP 4                     PREPARE 4. FULL WORD
         SETDUMP 5                     PREPARE 5. FULL WORD
         SETDUMP 6                     PREPARE 6. FULL WORD
         SETDUMP 7                     PREPARE 7. FULL WORD
         SETDUMP 8                     PREPARE 8. FULL WORD
* ...... CREATE LINE WILL BE PRINT ...................................
DUMPEND  PUT   MFDUMP,DUMP             PRINT PREPARED LINE
         L     RE,SAVE01
         BR    RE
* --------------------------------------------------------------------
*    CREATE HEX VALUE FOR ONE FULL WORD
*      R1:  CONTAINS FULL WORD TO CONVERT
*      CALL: BAL   RE,BIN2HEX
*      FULLW CONTAINS RETURNED HEX VALUE OF R1, LENGTH IS 8 CHAR
* --------------------------------------------------------------------
BIN2HEX  DS    0H
         ST    RE,SAVE02
         STCM  R1,B'1111',HEXWK        STORE FULLWORD IN WORK AREA
         MVC   DUMPVIS,HEXWK           KEEP ORIGINAL TO ALSO DISPLAY IT
         UNPK  FULLW,HEXWK
         TR    FULLW,HEXTAB-C'0'       TRANSLATE TO CHARACTERS
         L     RE,SAVE02
         BR    RE
* --------------------------------------------------------------------
*    DUMP A LOCAL AREA (OUTSIDE REQUESTED ONE)
*      R9:  CONTAINS START ADDRESS
* --------------------------------------------------------------------
DUMPLCL  DS    0H
         ST    RE,SAVE09
         L     R7,MAXADR              SAVE MAX ADDR FOR THE MOMENT
         LA    R3,64(R9)
         ST    R3,MAXADR
         PUTLINE '---------------'
AREA1    BAL   RE,CRELINE             BUILD ONE DUMP LINE
         C     R9,MAXADR              IS NEXT OFFSET > MAX
         BNH   AREA1
         ST    R7,MAXADR
         PUTLINE '---------------'
         L     RE,SAVE09
         BR    RE
* --------------------------------------------------------------------
*    INIT DUMP PROGRAM
* --------------------------------------------------------------------
DUMPINIT DS    0H
         ST    RE,SAVE01
         L     R1,4(RD)                POINT TO CALLER'S REGSAVE
         L     R6,24(R1)               LOAD ADDRESS OF CALLERS R1
         USING DUMPDMY,R6
         L     R9,DUMPADR              ADDRESS OF AREA TO DUMP
         L     R4,DUMPLEN              LENGTH TO DUMP
         LA    R4,0(R4,R9)             START+LENGTH = END ADDRESS
         ST    R9,DUMPFROM             SAVE DUMP START ADDRESS
         ST    R4,MAXADR
         MVC   MODE,DUMPMOD+3          SAVE DUMP MODE
         MVI   RMODE,C'1'              REGISTER MODE LINE 1/2
         MVC   DISPMOD,DUMPDIS+3       DISPLACEMENT MODE
         OPEN  (MFDUMP,(OUTPUT))       OPEN DUMPFILE
         BLANK DUMP
         CLI   MODE,X'3'               HAS AN ADDITIONAL HEADING LINE
         BNE   DMP01                   BRANCH BEFORE CHECK FOR COMMENT
* ...... SAVE AREA 1. HEADING  .......................................
         PUT   MFDUMP,DUMP
         LH    R2,DUMPLVL
         BIN2CHR TOTLENC,(R2)
         STRLC TOTLENC,(R2)
         LTR   R2,R2
         BZ    SIS0
         MOVCMT DUMP+12,'CALLER SAVEAREA, LEVEL -'
         MVC   DUMP+36(L'TOTLENC-6),TOTLENC+6
         B     SIS1
SIS0     MOVCMT DUMP+12,'CALLER SAVEAREA, LEVEL 0'
SIS1     PUT   MFDUMP,DUMP
         BLANK DUMP
* ...... TEST VARIOUS MODES  .........................................
DMP01    L     R2,DUMPCMT
         LTR   R2,R2
         BNZ   NCOMMENT
         CLI   MODE,X'1'
         BE    ISREG
         CLI   MODE,X'2'
         BE    ISPARM
         CLI   MODE,X'3'
         BE    ISSAVE
* ...... STORAGE DUMP  ...............................................
         MOVCMT DUMP+12,'DUMP OUTPUT FROM '
         PUT   MFDUMP,DUMP
         PUTLINE '           -----------------'
         B     INIT09
* ...... REGISTER DUMP  ..............................................
ISREG    PUT   MFDUMP,DUMP
         MOVCMT DUMP+12,'CURRENT REGISTERS'
         PUT   MFDUMP,DUMP
         PUTLINE '           -----------------'
         B     INIT09
* ...... PARAMETER DUMP  .............................................
ISPARM   PUT   MFDUMP,DUMP
         MOVCMT DUMP+12,'PASSED PARAMETERS (<= 12)'
         PUT   MFDUMP,DUMP
         PUTLINE '           -------------------------'
         B     INIT09
* ...... SAVE AREA DUMP  .............................................
ISSAVE   MOVCMT DUMP+12,'OFFSET 4: B-CHAIN, 8: F-CHAIN, +12: RE->RC'
         PUT   MFDUMP,DUMP
         PUTLINE '           ------------------------------------------X
               -'
         B     INIT09
* ...... NON STANDARD COMMENT PROVIDED  ..............................
NCOMMENT DS    0H
         L     R3,DUMPCLN
         BCTR  R3,0
         EX    R3,EXMVC1
         PUT   MFDUMP,DUMP
         EX    R3,EXMVC2
         PUT   MFDUMP,DUMP
* ...... RETUTN TO CALLER  ...........................................
INIT09   XC    TOTLEN,TOTLEN
         L     RE,SAVE01
         BR    RE
         DROP  R6
EXMVC1   MVC   DUMP+12(0),0(R2)
EXMVC2   MVC   DUMP+12(0),=C'-----------------------------------------'
*
         LTORG
HEXTAB   DC    C'0123456789ABCDEF' TRANSLATION TABLE FOR HEX TO CHAR
*
         WORKAREA  SYSOUT=MFDUMP
         DS    0D
STRPACK  DS    PL8     8-BYTE PACKED, MAX 999,999,999,999,999           00039333
WTOMSG   DS    0CL72                                                    00047100
STRADR   DS    CL8                                                      00047200
WTOMSGC  DS    CL64                                                     00047300
         DS    0D
FULLW    DS    0CL9
FULLWORD DS    CL8
         DS    CL1
DUMPFROM DS    A
MAXADR   DS    A
TOTLEN   DS    A
TOTLENC  DS    CL8
MODE     DS    CL1
DISPMOD  DS    CL1
RMODE    DS    CL1
HEXWK    DS    CL5 WORK AREA FOR HEX TO CHAR
DUMPVIS  DS    CL4
ASIDHEX  DS    CL4                 ASID IN HEX CHAR
DUMP     DS    CL133
WDUMP    DS    CL72
         ORG   DUMP
         DS    CL1
DADDR    DS    CL8
         DS    CL3
D1       DS    CL8
         DS    CL1
D2       DS    CL8
         DS    CL1
D3       DS    CL8
         DS    CL1
D4       DS    CL8
         DS    CL5
D5       DS    CL8
         DS    CL1
D6       DS    CL8
         DS    CL1
D7       DS    CL8
         DS    CL1
D8       DS    CL8
         DS    CL4
C0       DS    CL1
C1       DS    CL4
C2       DS    CL4
C3       DS    CL4
C4       DS    CL4
C5       DS    CL4
C6       DS    CL4
C7       DS    CL4
C8       DS    CL4
C9       DS    CL1
         DS    CL32
DUMPLN   EQU   *-DUMP
         DS    CL255        RESERVE
         WORKEND
DUMPDMY  DSECT
         DUMPIT MODE=DEFINE
         END   MVSDUMP
