*
         TITLE 'VTOC - MAIN MODULE'                                017G
***********************************************************************
*      MODIFICATIONS
* NUMBER    DATE    PERSON     REASON
*  001G    062378   GATES      FIX MACRO ERROR (NAME TOO LONG)
*  002G    071978   GATES      CORRECT UCB LOOKUP CODE SO UCB ADDR OF
*                               8XXX WILL NOT CAUSE NEG ADDR.
*  003G    072278   GATES      CHANGE MSG MACROS TO VTCMSG TO AVOID
*                               CONFLICT WITH AN EXISTING MSG MACRO.
*  004S    101678   SAVIT      CHANGE TO ALLOW DISPLAY FOR UNMOUNTED
*                               VOLUMES=>FULLY SPECIFIED VOLS ARE
*                               MOUNTED BY DYNAMIC ALLOCATION.  CORRECT
*                               INCORRECT TEST FOR END OF UCB.
*  005G    030379   GATES      ADD TEST FOR PUBLIC AND STORAGE MOUNTED
*                               VOLUMES SO A JCL FILE TO DELETE DATA
*                               FROM THEM CAN BE GENERATED.
*  006G    120580   GATES      ADD KEYWORDS FOR 3350, 3330, AND 3330V
*                               VOLUMES SO A DEVICE TYPE SEARCH CAN
*                               BE DONE.
*  007G    042882   GATES      BYPASS ERRORS CAUSED BY VM DISKS.
*  008G    100783   GATES      ADD KEYWORDS FOR 3380 VOLUMES SO A
*                               DEVICE TYPE SEARCH CAN BE DONE.
*  009G    100783   GATES      UPGRADE CODE TO WORK UNDER MVS/XA.
*  010G    110883   GATES      UPGRADE CODE TO CALL MAP ROUTINE.
*  011G    111783   GATES      UPGRADE CODE ALWAYS CALL MAP RTN
*                               SO WE CAN REPORT GAPS AND OVERLAPS.
*                               THE MAP WILL ONLY BE DISPLAYED IF
*                               THE USER SAID MAP ON VTOC COMMAND.
*  012G    112383   GATES      REDEFINE VTCPFUNC VALUES.
*  013G    112883   GATES      FIX ERRORS WHEN SCANNING GENERIC WHICH
*                               IS FOLLOWED BY SPECIFIC MSV DIDN'T
*                               DYNAMICALLY MOUNT THE MSV.
*  014G    050284   GATES      RENAME VTLEAVE MACRO TO VTCLEAVE,
*                              RENAME VTOCOM MACRO TO VTCCOM,
*                              RENAME VTOCPARS MACRO TO VTCPARS,
*                               RENAME ENTER TO VTCENTER,
*                              RENAME PDEDSNAM MACRO TO VTCPDEDS,
*                              VTOC MORE TRANSPORTABLE.
*  015G    051084   GATES      ADD UNIT TYPE FIELD.
*  016G    051684   GATES      EXPAND WORK AREA FOR VTOCCHEK.
*  017G    051784   GATES      FIX TITLE TO BE DESCRIPTIVE.
*  018G    051784   GATES      CHANGE ABSOLUTE CODING TO USE TAGS TO
*                               MAKE VTOC MORE TRANSPORTABLE.
*  019G    010688   GATES      TAKE OUT PURGE OPTION. THIS OPTION CAN
*                               BE DONE BY DIRECTING OUTPUT TO VTOCOUT
*                               AND MODIFYING IT. THIS AFFECTS 005G
*                               MOD.
*  020G    041690   GATES      MAKE UNIT TYPE SEARCH ONLY WORK IF
*                               THE COMPLETE VOLSER = UNITNAME, LIKE
*                               3380 NOT 3380XA.
*  021G    050890   GATES      MAKE COMMAND ONLY WORK FOR PEOPLE WITH
*                               OPER AUTHORITY.
*  022G    071494   GATES      UNDO 021G.
*  023G    042098   GATES      REPLACE 3330 REFERENCE WITH 3390, WE
*                               AREN'T GOING TO SUPPORT 3330 ANYMORE.
*  024G    051399   GATES      ADD MISSING 3350 CONSTANT.
*                                                                     *
*  DHC1    091902   CARTWRIGHT RE-INSTATE OS370 UCB LOOKUP
*                                                                     *
*                                                                     *
*                                                                     *
* TITLE -      VTOC COMMAND - LIST DATA SETS AND ATTRIBUTES           *
*                                                                     *
* FUNCTION -   PROVIDE THE ABILITY FOR A TSO USER OR A BATCH JOB      *
*              TO LIST THE CONTENTS OF VARIOUS VOLUMES, WITH A        *
*              FAIR AMOUNT OF SELECTION.                              *
*                                                                     *
*                                                                     *
* OPERATION -  ACCEPT FROM THE TSO USER OR BATCH JOB A COMMAND        *
*              WITH THE FOLLOWING SYNTAX.  THEN CHECK THE COMMAND     *
*              AND LOOP THROUGH, GETTING A DSCB, FORMATTING IT,       *
*              PERFORMING THE DATA SET NAME AND LIMIT CHECKS, AND     *
*              CALLING AN EXIT ROUTINE IF DESIRED, THEN PUT THE       *
*              ENTRY IN THE CORRECT SORT SEQUENCE.                    *
*              FINALLY CALL THE PRINT ROUTINE TO PRINT THE            *
*              SPECIFIED ITEMS, HEADERS, AND BREAKS, OR JUST          *
*              THE TOTALS.                                            *
*                                                                     *
*                                                                     *
* INPUT -      STANDARD COMMAND PROCESSOR PARAMETER LIST              *
*              POINTED TO BY REGISTER 1                               *
*                                                                     *
*                                                                     *
* OUTPUT -     TO SYSOUT, A LIST OF THE REQUESTED DATA SETS AND       *
*              THEIR ATTRIBUTES.                                      *
*                                                                     *
*                                                                     *
* ATTRIBUTES - REENTRANT, REUSEABLE, REFRESHABLE.                     *
*                                                                     *
*                                                                     *
*         PROGRAMMED BY R. L. MILLER  (415) 485-6241                  *
*              FIREMAN'S FUND INSURANCE  CPSD 2N                      *
*              ONE LUCAS GREEN                                        *
*              SAN RAFAEL, CA  94911                                  *
*                                                                     *
*                                                                     *
***********************************************************************
*
         MACRO
&LABEL   VTOCEXCP  &FUNC
         AIF   ('&FUNC' NE 'EQ').ECALL
VTCEOPEN EQU   1             DEFINE FUNCTION CODES FOR VTOCEXCP
VTCECLOS EQU   2
VTCEREAD EQU   0
         MEXIT
.ECALL   ANOP                 CALL VTOCEXCP
&LABEL   MVI   VTCEFUNC,VTCE&FUNC   SET THE FUNCTION CODE
         VTCALL EXCP          GO GET A DSCB
         MEND
         MACRO
&LABEL   VTOCMAP   &FUNC                                         010G
         AIF   ('&FUNC' NE 'EQ').MCALL                           010G
VTCMOPEN EQU   0              DEFINE FUNCTION CODES FOR VTOCMAP. 010G
VTCMADD  EQU   1              DEFINE FUNCTION CODES FOR VTOCMAP. 010G
VTCMCLOS EQU   2              DEFINE FUNCTION CODES FOR VTOCMAP. 010G
VTCMSORT EQU   3              DEFINE FUNCTION CODES FOR VTOCMAP. 010G
         MEXIT
.MCALL   ANOP                 CALL VTOCMAP                       010G
&LABEL   MVI   VTCMFUNC,VTCM&FUNC   SET THE FUNCTION CODE        010G
         VTCALL MAP           GO TO MAP ROUTINE.                 010G
         MEND
*
*        MACRO FOR INITIALIZING SUBROUTINE WORK AREA ADDRESSES
*
         MACRO
&LABEL   WORKADDR &RTN,&PARMADD                                    001G
&LABEL   L     R1,=A(WORK&RTN-WORKAREA)  GET THE OFFSET ( OVER 4K )
         LA    R1,0(R1,R13)   RELOCATE IT
         ST    R1,&PARMADD    THEN STORE IT FOR THE ROUTINES       001G
         MEND
*
         EJECT
VTOCCMD  VTCENTER 12,(1,LENWORK,C)  DO THE HOUSEKEEPING            014G
         LR    R2,R1          SAVE ADDR OF CPPL
         SPACE
         USING WORKAREA,WORKREG
         EJECT
         BAL   R14,PARSINIT   PERFORM THE PARSING
         LTR   R15,R15        TEST THE RETURN CODE
         BNZ   RETURN         BAD NEWS, GET OUT
         VTCALL PRNT         INITIALIZE FOR PRINTING
         L     R9,ADDRANSR    ADDR OF PARSE DESCRIPTOR LIST
         USING PDL,R9         RETURNED BY PARSE
*
*        CHECK THROUGH THE UCB'S TO SELECT THE VOLUMES TO PROCESS
*
*
**  FIND A VOLUME SERIAL NUMBER
*
         LA    R3,VOLS        POINT TO THE PDL
LOOP1    L     R5,0(R3)       GET THE ADDRESS OF THE TEXT
         LH    R4,4(R3)       ALSO GET ITS LENGTH
         LTR   R4,R4          FOR EXECUTES, GET THE LENGTH
         BZ    PHASE2         NO MORE VOLUMES, CONTINUE TO NEXT PHASE
         BCTR  R4,0           MAKE IT READY FOR THE EX INSTR
         MVC   VOLSER,BLANKS   INITIALIZE FIELD
         EX    R4,MOVVOL
         MVI   FLAG,X'00'     CLEAR TYPE REQUEST FLAG.             013G
*
**  VOLUME FOUND - VERIFY AND CHECK FOR GLOBAL OR SPECIAL REQUESTS
*
         CH    R4,H5          IS THE ENTIRE NAME THERE?
         BE    VOLSET         YES, IT'S A SPECIFIC VOLUME
         MVI   FLAG,X'01'     IT'S A GENERIC REQUEST
         CH    R4,H2          CHECK FOR THE ALL KEYWORD, FIRST LENGTH
         BNE   DEVCHEK1       NOT A GLOBAL REQUEST                 006G
         CLC   0(3,R5),CHARALL  IS THIS THE KEYWORD 'ALL'?
         BNE   DEVCHEK1       NO, NOT A GLOBAL REQUEST             013G
         MVI   FLAG,X'02'   GLOBAL REQUEST
         B     VOLSET
* CHANGE 023G BELOW
*EVCHEK1 CH    R4,H3          CHECK FOR THE 3350 OR 3330, FIRST LEN006G
*        BNE   DEVCHEK3       NOT A 3350 OR 3330 REQUEST           006G
DEVCHEK1 CH    R4,H3          CHECK FOR THE 3350 OR 3390, FIRST LEN006G
         BNE   DEVCHEK3       NOT A 3350 OR 3390 REQUEST           006G
* CHANGE 023G BELOW
*        CLC   0(4,R5),CHAR3350 IS THIS THE KEYWORD '3350'?    006G020G
         CLC   0(6,R5),CHAR3350 IS THIS THE KEYWORD '3350'?    006G020G
         BNE   DEVCHEK2       NO, NOT A 3350                       006G
         MVI   FLAG,X'18'     INDICATE 3350 REQUEST                006G
         B     VOLSET                                              006G
*EVCHEK2 CLC   0(4,R5),CHAR3330 IS THIS THE KEYWORD '3330'?    006G020G
* CHANGE 023G BELOW
*EVCHEK2 CLC   0(6,R5),CHAR3330 IS THIS THE KEYWORD '3330'?    006G020G
*        BNE   DEVCHEK3       NO, NOT A 3330                       006G
*        MVI   FLAG,X'28'     INDICATE 3330 REQUEST                006G
DEVCHEK2 CLC   0(6,R5),CHAR3390 IS THIS THE KEYWORD '3390'?        023G
         BNE   DEVCHEK3       NO, NOT A 3390                       006G
         MVI   FLAG,X'28'     INDICATE 3390 REQUEST                006G
* CHANGE 023G ABOVE
         B     VOLSET                                              006G
*EVCHEK3 CLC   0(4,R5),CHAR3380 IS THIS THE KEYWORD '3380'?    008G020G
DEVCHEK3 CLC   0(6,R5),CHAR3380 IS THIS THE KEYWORD '3380'?    008G020G
         BNE   DEVCHEK4       NO, NOT A 3380                       008G
         MVI   FLAG,X'48'     INDICATE 3380 REQUEST                008G
         B     VOLSET                                              008G
DEVCHEK4 CH    R4,H4          CHECK FOR THE 3350 OR 3330, FIRST LEN008G
         BNE   VOLSET         NOT A 3330V                          006G
*        CLC   0(5,R5),CHAR333V IS THIS THE KEYWORD '3330V'?   006G020G
         CLC   0(6,R5),CHAR333V IS THIS THE KEYWORD '3330V'?   006G020G
         BNE   VOLSET         NO, NOT A 3330V                      006G
         MVI   FLAG,X'88'     INDICATE 3330V REQUEST               008G
         B     VOLSET                                              006G
*
**  FIND THE A(UCB)
*
VOLSET   XC    LASTADR,LASTADR CLEAR THE UCB COMPARE ADDRESS     009G
*VOLSET   L     R5,CVTPTR                GET A(CVT).          009G018G
         L     R5,CVTPTR                GET A(CVT).          009G018G
         USING CVTMAP,R5                                         018G
**HC1     INITIALIZE FOR UCB SCAN WITH IOSVSUCB RTN
*DHC1     L     R6,=A(WORKUCB-WORKAREA)  GET OFFSET OVER 4K.      009G
*DHC1     LA    R6,0(R6,R13)             RELOCATE IT.             009G
*DHC1     USING WORKUCBD,R6              TELL ASSEMBLER.          009G
*DHC1     XC    WORKUCBA(100),WORKUCBA   CLEAR WORK AREA.         009G
*DHC1     MVI   WORKUCBT,UCB3DACC        SET DASD CLASS.          018G
*DHC1     LA    R1,WORKUCBA              GET A(UCB WORK AREA).    009G
*DHC1     ST    R1,WORKUCBP              SAVE A(UCB WORK AREA).   009G
*DHC1     LA    R1,WORKUCBT              GET A(CLASS OF DEVICES). 009G
*DHC1     ST    R1,WORKUCBP+4            SAVE A(CLASS OF DEVICES).009G
*DHC1     LA    R1,LASTADR               GET A(CURRENT UCB).      009G
*DHC1     ST    R1,WORKUCBP+8            SAVE A(CURRENT UCB).     009G
*DHC1     OI    WORKUCBP+8,X'80'         SET LAST PARM INDICATION.009G
**HC1   REINITIALIZE FOR UCB SCAN WITH IOSVSUCB RTN WHEN DOING NEXTUCB
*NEXTUCB  L     R6,=A(WORKUCB-WORKAREA)  GET OFFSET OVER 4K.      009G
*DHC1     LA    R6,0(R6,R13)             RELOCATE IT.             009G
*DHC1     LA    R1,WORKUCBP              GET A(UCB SCAN PARM LIST).009G
          L     R5,40(R5)   A(UCB ADDRESSES)                      009G
*DHC1     DROP  R6                                                009G
         SR    R6,R6                                             002G
NEXTUCB  ICM   R6,3,0(R5)  A(A UCB)                         002G009G
         LTR   R6,R6                   CHECK FOR VALID ENTRIES. 009G
         BZ    INCR1                   UCB HOLE                 009G
         C     R6,UCBEND  CK FOR END:CHANGED TO REFLECT 002G 004S009G
         BE    NOTMNT   END OF UCB LIST - VOLUME NOT FOUND      009G
*DHC1     SLL   R6,16   REMOVE HI-ORDER BITS                     009G
*DHC1     SRL   R6,16                                            009G
*DHC1     L     R15,CVTUCBSC    GET A(IOSVSUCB).               009G018G
         DROP  R5                                                018G
*DHC1     BALR  R14,R15         GO TO SCAN SERVICE.               009G
*DHC1     LTR   R15,R15         CHECK FOR END.                    009G
*DHC1     BNZ   NOTMNT          END OF UCB LIST VOL NOT FOUND.    009G
*DHC1     L     R6,LASTADR      GET A(CURRENT UCB) FROM SCAN.     009G
         USING UCB,R6          TELL ASSEMBLER BASE OF UCB.       018G
         C     R6,LASTADR      UCB ADDRESSES MUST INCREASE.      009G
         BNH   INCR1           OTHERWISE THEY REPEAT.            009G
         ST    R6,LASTADR      NEW ADDRESS.                      009G
         CLI   18(R6),X'20'    MUST BE DIRECT ACCESS             009G
         BNE   INCR1                                             009G
         TM    FLAG,X'02'   CHECK FOR GLOBAL
         BO    FNDGBL   IT IS
         TM    FLAG,X'01'   CHECK FOR SPECIAL REQUESTS
         BO    SPECUCB   IT IS
         TM    FLAG,X'10'   CHECK FOR 3350 TYPE DASD               006G
         BO    UCB3350   IT IS                                     006G
* CHANGE 023G BELOW
*        TM    FLAG,X'20'   CHECK FOR 3330 TYPE DASD               006G
*        BO    UCB3330   IT IS                                     006G
         TM    FLAG,X'20'   CHECK FOR 3390 TYPE DASD               006G
         BO    UCB3390   IT IS                                     006G
* CHANGE 023G ABOVE
         TM    FLAG,X'40'   CHECK FOR 3380 TYPE DASD               008G
         BO    UCB3380   IT IS                                     008G
         TM    FLAG,X'80'   CHECK FOR 3330V TYPE DASD              008G
         BO    UCB333V   IT IS                                     006G
         CLC   VOLSER,UCBVOLI  COMPARE FULL VOLSER.                018G
         BE    FNDUCB   FOUND IT
         B     INCR1                                               DHC1
SPECUCB  EX    R4,CLCVOL   COMPARE FIRST X CHARACTERS ONLY
         BE    CHKRDY
*DHC1    B     NEXTUCB        TRY NEXT UCB.                        009G
INCR1    LA    R5,2(R5)                                           009G
         B     NEXTUCB   TRY NEXT UCB                             009G
*
*        VARIOUS ERRORS, LET THE PERSON KNOW
*
*                             MODIFIED FOR DYNAMIC MOUNT.          004S
NOTMNT   DS    0H                                                  004S
         TM    FLAG,X'0B'     NEITHER GENERIC NOR GLOBAL:SPECIFIC  004S
         BZ    VOLNOTUP       ALLOW ALLOC. EVEN IF VOL UNMOUNTED.  004S
         TM    FLAG,X'04'     WAS A VOLUME  FOUND?
         BO    NEXTVOL        YES, LOOK FOR THE NEXT SPEC
         MVC   MSGTEXT2,MSGNOTMT  NO, GET THE ERROR MESSAGE
SETVOL   MVC   MSGTEXT2+5(6),VOLSER ADD THE VOLUME SERIAL NUMBER
         VTOCMSG MSGTEXT2     AND ISSUE THE MESSAGE
         B     NEXTVOL       GO GET THE NEXT VOLUME FROM PARSE
PENDING  MVC   MSGTEXT2,MSGPEND   SET UP THE MESSAGE
*
*        SEE IF THIS IS A GENERIC OR GLOBAL REQUEST
*
         TM    FLAG,X'03'    WAS IT ALL OR A PARTIAL VOLUME SERIAL?
         BNZ   NEXTUCB       IN EITHER CASE, SKIP THE MESSAGE      009G
*                            THEN FIND MORE VOLUMES
*
*        OUTPUT THE OFFLINE PENDING MESSAGE
         B     SETVOL         THEN ADD THE VOLUME
OFFLINE  MVC   MSGTEXT2,MSGOFFLN SET UP THE MESSAGE
         B     SETVOL         THEN ADD THE VOLUME
*                                                                  004S
***** SPECIFIC VOLUME REQUEST AND VOLUME NOT MOUNTED.              004S
*                                                                  004S
VOLNOTUP DS    0H                                                  004S
         MVC   VOLID,VOLSER   COPY VOLSER THAT UCB SEARCH USED.    004S
         MVC   UNITYP,=C'3330V ' ASSUME IT IS A 3330V TYPE VOL.    015G
         XC    ADDR,ADDR      UNIT ADDRESS=0: NOT MOUNTED.         004S
         OI    FLAG,X'04'     INDICATE VOLUME FOUND.               004S
         B     OPENMAP        ALLOCATE AND READ VTOC.         004S 010G
UCB3350  CLI   UCBUNTYP,X'0B' 3350 TYPE?                      006G 018G
         BNE   NEXTUCB        NOPE                            006G 009G
         B     TESTONRD       GO TEST ONLINE AND READY             006G
UCB3380  CLI   UCBUNTYP,X'0E' 3380 TYPE?                      008G 018G
         BNE   NEXTUCB        NOPE                            008G 009G
         B     TESTONRD       GO TEST ONLINE AND READY             008G
* CHANGE 023G BELOW
*CB3330  CLI   UCBUNTYP,X'0D' 3330-11 TYPE?                   006G 018G
*        BE    TESTONRD       YES, GO SEE NOT 3330V                006G
*        CLI   UCBUNTYP,X'09' 3330-1 OR 3330V TYPE?                006G
*        BNE   NEXTUCB        NOPE                            006G 009G
*ESTNOTV TM    UCBTBYT2,UCBRVDEV DONT WANT VIRT DASD(3330V).  006G 018G
*        BO    NEXTUCB        IF FOUND SKIP IT                006G 009G
*        B     TESTONRD       ELSE SEE IF ONLINE READY             006G
UCB3390  CLI   UCBUNTYP,X'0F' 3390 TYPE?                      006G 018G
         BNE   NEXTUCB        NOPE                            008G 009G
         B     TESTONRD       GO TEST ONLINE AND READY             008G
* CHANGE 023G ABOVE
UCB333V  CLI   UCBUNTYP,X'09' 3330 TYPE?                      006G 018G
         BNE   NEXTUCB        NOPE                            006G 009G
         TM    UCBTBYT2,UCBRVDEV TEST IF VIRTUAL DASD(3330V)  006G 018G
         BNO   NEXTUCB        NO, SKIP IT FOR 3330V           006G 009G
TESTONRD EQU   *                                                   006G
*
**  FOR GLOBAL REQUESTS JUST LIST ONLINE PACKS
*
FNDGBL   TM    UCBSTAT,UCBONLI  CHECK IS IT ONLINE?                018G
         BZ    NEXTUCB           NOPE.                             009G
*
**  FOR GLOBAL AND SPECIAL REQUESTS, CHECK FOR DEVICE READY
*
CHKRDY   TM    UCBFLA,UCBNRY     IS IT READY?                      018G
         BO    NEXTUCB           NO.                               009G
*
**  MOVE UCB INFORMATION TO OUTPUT LINE
*
FNDUCB   MVC   VOLID,UCBVOLI     MOVE VOLID.                       018G
         MVC   ADDR,UCBNAME      MOVE UNIT ADDRESS.                018G
         OI    FLAG,X'04'      NOTE THE VOLUME AS FOUND
* CHANGE 023G BELOW
         CLI   UCBUNTYP,X'0F' IS IT 3390 DEVICE?
         BNE   NOT3390          NO.
         MVC   UNITYP,=C'3390  ' YES.
         B     CKOFF            CONTINUE.
*        CLI   UCBUNTYP,X'01' IS IT 2311 DEVICE?              015G 018G
NOT3390  CLI   UCBUNTYP,X'01' IS IT 2311 DEVICE?              015G 018G
* CHANGE 023G ABOVE
         BNE   NOT2311          NO.                                015G
         MVC   UNITYP,=C'2311  ' YES.                              015G
         B     CKOFF            CONTINUE.                          015G
NOT2311  CLI   UCBUNTYP,X'02' IS IT 2301 DEVICE?              015G 018G
         BNE   NOT2301          NO.                                015G
         MVC   UNITYP,=C'2301  ' YES.                              015G
         B     CKOFF            CONTINUE.                          015G
NOT2301  CLI   UCBUNTYP,X'03' IS IT 2303 DEVICE?              015G 018G
         BNE   NOT2303          NO.                                015G
         MVC   UNITYP,=C'2303  ' YES.                              015G
         B     CKOFF            CONTINUE.                          015G
NOT2303  CLI   UCBUNTYP,X'04' IS IT 2302 DEVICE?              015G 018G
         BNE   NOT2302          NO.                                015G
         MVC   UNITYP,=C'2302  ' YES.                              015G
         B     CKOFF            CONTINUE.                          015G
NOT2302  CLI   UCBUNTYP,X'05' IS IT 2321 DEVICE?              015G 018G
         BNE   NOT2321          NO.                                015G
         MVC   UNITYP,=C'2321  ' YES.                              015G
         B     CKOFF            CONTINUE.                          015G
NOT2321  CLI   UCBUNTYP,X'06' IS IT 2305-1 DEVICE?            015G 018G
         BNE   NOT23051          NO.                               015G
         MVC   UNITYP,=C'2305-1' YES.                              015G
         B     CKOFF            CONTINUE.                          015G
NOT23051 CLI   UCBUNTYP,X'07' IS IT 2305-2 DEVICE?            015G 018G
         BNE   NOT23052         NO.                                015G
         MVC   UNITYP,=C'2305-2' YES.                              015G
         B     CKOFF            CONTINUE.                          015G
NOT23052 CLI   UCBUNTYP,X'08' IS IT 2314 DEVICE?              015G 018G
         BNE   NOT2314          NO.                                015G
         MVC   UNITYP,=C'2314  ' YES.                              015G
         B     CKOFF            CONTINUE.                          015G
NOT2314  CLI   UCBUNTYP,X'09' IS IT 3330 DEVICE?              015G 018G
         BNE   NOT3330          NO.                                015G
         MVC   UNITYP,=C'3330  ' YES.                              015G
         TM    UCBTBYT2,UCBRVDEV IS IT 3330V DEVICE?               015G
         BNO   CKOFF            NO, ONLY 3330, CONTINUE.           015G
         MVI   UNITYP+4,C'V'    YES, INDICATE 3330V.               015G
         B     CKOFF            CONTINUE.                          015G
NOT3330  CLI   UCBUNTYP,X'0A' IS IT 3340 DEVICE?              015G 018G
         BNE   NOT3340          NO.                                015G
         MVC   UNITYP,=C'3340  ' YES.                              015G
         B     CKOFF            CONTINUE.                          015G
NOT3340  CLI   UCBUNTYP,X'0B' IS IT 3350 DEVICE?              015G 018G
         BNE   NOT3350          NO.                                015G
         MVC   UNITYP,=C'3350  ' YES.                              015G
         B     CKOFF            CONTINUE.                          015G
NOT3350  CLI   UCBUNTYP,X'0C' IS IT 3375 DEVICE?              015G 018G
         BNE   NOT3375          NO.                                015G
         MVC   UNITYP,=C'3375  ' YES.                              015G
         B     CKOFF            CONTINUE.                          015G
NOT3375  CLI   UCBUNTYP,X'0D' IS IT 3330-11 DEVICE?           015G 018G
         BNE   NOT3331          NO.                                015G
         MVC   UNITYP,=C'3330-1' YES.                              015G
         B     CKOFF            CONTINUE.                          015G
NOT3331  CLI   UCBUNTYP,X'0E' IS IT 3380 DEVICE?              015G 018G
         BNE   NOT3380          NO.                                015G
         MVC   UNITYP,=C'3380  ' YES.                              015G
         B     CKOFF            CONTINUE.                          015G
NOT3380  MVC   UNITYP,=C'UNKNWN' YES.                              015G
         B     CKOFF            CONTINUE.                          015G
*
**  IF OFFLINE, DO NOT PROCESS
*
CKOFF    TM    UCBSTAT,UCBCHGS   IS IT PENDING STATUS?        015G 018G
         BO    PENDING           YES.
         TM    UCBSTAT,UCBONLI   IS IT ONLINE?                     018G
         BZ    OFFLINE           NO.
*        MVI   VOLPORS,0     PRESET NOT PUB OR STOR FOR PURGE. 005G019G
*        TM    UCBSTAB,UCBBPUB+UCBBSTR  PUB AND STOR BITS  005G018G019G
*        BNO   OPENMAP       INDICATE JCL FOR PURGE NOT REQ005G010G019G
*        MVI   VOLPORS,1     JCL FOR PURGE CAN BE GENERATED.   005G019G
*
*
*        WE WILL NOW READ VTOC AND PROCESS VOLUME
*
*
*
*        GO GET MEMORY TO MAP VOLUME
*
OPENMAP  DS    0H             SPECIFIC VOLUME REQUESTS.        004S010G
         VTOCMAP  OPEN        OPEN THE VTOC MAP.                   010G
*
*        NOW GET DSCB'S FROM THE VOLUME
*
*
*        SET UP THE PARM LIST FOR VTOCEXCP
*
*                         ARRIVE HERE BY BRANCH FOR UNMOUNTED  004S010G
OPENVTOC VTOCEXCP OPEN        OPEN THE VTOC.                       010G
         LTR   R15,R15        DID IT OPEN OK?
         BNE   ENDVTOC        NO, JUST EXIT                        007G
         LA    R15,FMT4-8     GET A(VTOC DSCB)-8 TO FOOL MAP.      011G
         ST    R15,DSCBADDR   SAVE ADDR SO WE CAN MAP.             011G
         VTOCMAP ADD         ADD VTOC EXTENT TO MAP.               011G
         LTR   R15,R15        DID IT ADD OK?                       011G
         BNE   ENDVTOC        NO, JUST EXIT                        011G
READDSCB CLI   TABFULL,0     CHECK FOR FULL TABLES
         BNE   ENDVTOC       IF FULL, TRY END OF VTOC TO CLEAR
         VTOCEXCP READ        GET A DSCB
         CH    R15,H4         CHECK THE RETURN CODE
         BE    ENDVTOC        END OF VTOC
         BH    RETURN         BAD ERROR, VTOCEXCP GAVE THE MESSAGE
*
*        CHECK THE DATA SET QUALIFICATIONS, LIMIT, AND, OR
*
         VTCALL CHEK          CALL THE CHECK ROUTINE
         LTR   R15,R15        DOES THIS DATA SET GET PASSED ON?
         BNZ   READDSCB       NO, GET ANOTHER
*                             YES, CONTINUE PROCESSING
*
*        GATHER THE DATA TO MAP THE VOLUME AND SHOW IF REQUESTED
*
         CLI   MAPK+1,2       HAS USER REQUESTED TO SEE MAP?       011G
         BE    MAPADD         NO, CONTINUE                         011G
         MVI   SORTK+1,1      YES, INDICATE SORT(VOLUME)           010G
         MVI   SUBSORT+1,2         INDICATE SORT(VOLUME)           010G
MAPADD   VTOCMAP ADD          CALL THE MAP ROUTINE TO ADD ENTRY.   011G
*                             FORMAT 4, 5, AND 6 DSCB HAVE THEIR   010G
*                              EXTENT INFO ADDED, NO OTHER PROCESS.010G
         LTR   R15,R15        DOES THIS DATA SET GET PASSED ON?    010G
         BNZ   READDSCB       NO, GET ANOTHER.                     010G
*
*        FORMAT THE DSCB INFORMATION
*
FMTDSCB  L     R15,DSCBADDR   GET A(CURRENT DSCB).                 010G
         LA    R15,8(R15)     BUMP PAST HEADER.                    010G
         USING FMT1DSEC,R15   TELL ASSEMBLER                       010G
         CLI   DS1FMTID,C'1'  IS IT A FMT 1 DSCB?                  010G
         BNE   READDSCB       NO, SKIP IT.                         010G
         DROP  R15                                                 010G
         TM    VTCFMTCK,VTCFMTCD WAS FORMAT CALLED BY CHECK?
         BO    CALLEXIT       YES, DON'T CALL IT AGAIN
         VTCALL FORM          CALL THE FORMATTING ROUTINE
         LTR   R15,R15        DID IT FUNCTION?
         BNZ   READDSCB       NO, GET ANOTHER DSCB
*
*        CALL THE EXIT ROUTINE IF ONE WAS SPECIFIED
*
CALLEXIT VTCALL EXIT,TEST     CALL THE EXIT ROUTINE
         LTR   R15,R15        SHOULD THE DATA SET BE PASSED ON?
         BNZ   READDSCB       NO, GET ANOTHER DSCB
*
*        SORT THE ENTRIES INTO THE NEW LIST
*
         VTCALL SORT          CALL THE SORT ROUTINE
         B     READDSCB       GET ANOTHER DSCB
*
*        END OF THE VOLUME, CHECK FOR MORE
*
ENDVTOC  VTOCEXCP CLOS       FIRST CLOSE THE VTOC
*
*        IF THE SORT IS BY VOLUME, CALL PRINT NOW
*
         CLI   SUBSORT+1,2    IS THIS A VOLUME SORT
         BNE   ENDVOL         NO, CONTINUE
         VTCALL PRNT          CALL THE PRINT ROUTINE
*
*        THIS VOLUME DONE, FREEMAIN THE MAP MEMORY
*
ENDVOL   VTOCMAP SORT         CALL THE MAP ROUTINE TO SORT MAP.    011G
         OI    VTCPFUNC,X'01' TELL PRINT RTN TO PRINT MAP INFO.011G012G
         VTCALL PRNT          CALL THE PRINT RTN.                  011G
         NI    VTCPFUNC,X'FE' TELL PRINT RTN TO PRINT DSN INFO.011G012G
         VTOCMAP CLOS         CALL THE MAP ROUTINE TO CLOSE.  010G 011G
         TM    FLAG,X'0B'         IS THIS A GENERIC VOLUME SEARCH  011G
         BNZ   NEXTUCB            YES, SEARCH FOR MORE             009G
NEXTVOL  ICM   R3,B'0111',25(R3)  GET THE NEXT VOLUME FROM THE PDL
         BP    LOOP1              THERE IS ANOTHER, GET IT
*
*        PRINT THE SELECTED ITEMS FOR THE SELECTED DATA SETS
*
PHASE2   DS    0H
         CLI   SUBSORT+1,2    IS THIS A VOLUME SORT
         BE    EXIT0          YES, PRINT HAS BEEN CALLED
         VTCALL PRNT          CALL THE PRINT ROUTINE
         EJECT
*
*        PROCESSING IS COMPLETE, EXIT
*
EXIT0    SR    R15,R15
         SPACE 3
RETURN   LTR   R2,R15         NORMAL EXIT?
         BZ    RETURN1        YES, LEAVE EVERY THING ALONE
         SPACE 2
         LA    R1,PARMLIST    AREA FOR STACK PARM LIST
         USING IOPL,R1        AN ERROR WAS FOUND, FLUSH THE STACK
         SPACE
         MVC   IOPLUPT,ADDRUPT
         MVC   IOPLECT,ADDRECT
         LA    R0,ATTNECB
         MVI   ATTNECB,0
         ST    R0,IOPLECB
         SPACE 2
         STACK PARM=PARMLIST+16,DELETE=ALL,MF=(E,(1))
         SPACE 3
         TCLEARQ INPUT        CLEAR INPUT BUFFERS
         SPACE 3
RETURN1  DS    0H
         BAL   R14,FREEPDL    FREE THE PARSE STROAGE
         OI    VTCPFUNC,X'08' TELL PRINT TO CLEAN UP HIS ACT CLOSE
*                               DATA SETS AND FREE MAIN STORAGE.   012G
         VTCALL PRNT          CALL THE PRINT ROUTINE
         SPACE
         LR    R15,R2          GET THE RETURN CODE AGAIN
         VTCLEAVE EQ                                               014G
WORKREG  EQU   13
*
*        PARSE INITIALIZATION
*
         SPACE 3
PARSINIT DS    0H
         ST    R2,CPPLADDR    AND THE CPPL ADDRESS
         USING CPPL,R2        BASE FOR COMMAND PARM LIST
         MVC   ADDRUPT,CPPLUPT ADDR OF USER PROFILE TABLE
         MVC   ADDRPSCB,CPPLPSCB ADDR OF PROTECTED STEP CONTROL BLK
         MVC   ADDRECT,CPPLECT ADDR OF ENVIROMENT TABLE
         MVC   ADDRCBUF,CPPLCBUF
         DROP  R2
         SPACE 3
*
*        PUT THE WORK AREA ADDRESSES INTO THE PARM LISTS
*
         WORKADDR MSG,VTCWMSG     WORK AREA FOR VTOCMSG
         WORKADDR EXCP,VTCWEXCP   WORK AREA FOR VTOCEXCP
         WORKADDR CHEK,VTCWCHEK   WORK AREA FOR VTOCCHEK
         WORKADDR FORM,VTCWFORM   WORK AREA FOR VTOCFORM
         WORKADDR EXIT,VTCWEXIT   WORK AREA FOR VTOCEXIT
         WORKADDR SORT,VTCWSORT   WORK AREA FOR VTOCSORT
         WORKADDR PRNT,VTCWPRNT   WORK AREA FOR VTOCPRNT
         WORKADDR MAP,VTCWMAP     WORK AREA FOR VTOCMAP           010G
         SPACE 3
*        SET UP THE ADDRESSES FOR CALLING
*
         MVC   VADMSG(RTNADLEN),RTNADDRS  MOVE IN THE ADDRESSES
*
*
*
*        BUILD PARSE PARAMETER LIST AND INVOKE
*        IKJPARS TO ANALYZE COMMAND OPERANDS
*
         SPACE 3
GOPARSE  DS    0H
         ST    R14,R14PARSE   SAVE THE RETURN ADDRESS
         LA    R1,PARSELST    AREA FOR PARSE PARAMETERS
         USING PPL,R1         BASE FOR PARSE PARAMETER LIST
         SPACE 2
         MVC   PPLUPT,ADDRUPT PASS UPT ADDRESS
         MVC   PPLECT,ADDRECT AND ECT ADDRESS
         MVC   PPLCBUF,ADDRCBUF AND COMMAND BUFFER ADDR
         SPACE
         ST    WORKREG,PPLUWA ALSO WORK AREA ADDR FOR VALIDITY EXITS
         SPACE
         LA    R0,ATTNECB     ECB FOR ATTN INTERRUPTS
         MVI   ATTNECB,0      CLEAR ECB
         ST    R0,PPLECB      PASS TO PARSE
         SPACE
         LA    R0,ADDRANSR    PASS ADDR OF WORD WHERE PARSE
         ST    R0,PPLANS      RETURNS PDL ADDRESS
         SPACE
         MVC   PPLPCL,ADDRPCL STORE PCL ADDRESS
         SPACE 3
         CALLTSSR EP=IKJPARS  INVOKE PARSE
         DROP  R1
         SPACE 2
         LA    R14,MAXPARSE   RETURN CODE LIMIT
         SPACE
         CR    R15,R14        VERIFY RETURN CODE WITHIN LIMITS
         BH    PARSEBAD       NO, ERROR
         SPACE
         B     *+4(R15)       PROCESS RETURN CODE
         SPACE
PARSERET B     PARSEOK         0- SUCESSFUL
         B     PARSEERR        4- PARSE UNABLE TO PROMPT
         B     PARSEERR        8- USER ENTERED ATTENTION
         B     PARSEBAD       12- INVALID PARAMETERS
         B     PARSEBAD       16- PARSE INTERNAL FAILURE
         B     PARSEERR       20 - VALIDITY CHECK ERROR
MAXPARSE EQU   *-PARSERET
         SPACE 5
PARSEBAD DS    0H
         MVC   MSGTEXT2+4(L'MSGPARSE),MSGPARSE
         LA    R1,MSGTEXT2+4+L'MSGPARSE
         SPACE
         CVD   R15,DOUBLE
         OI    DOUBLE+7,X'0F'
         UNPK  0(2,R1),DOUBLE
         SPACE
         LA    R0,MSGTEXT2-2
         SR    R1,R0
         SLL   R1,16
         ST    R1,MSGTEXT2
         SPACE 2
         VTOCMSG MSGCMDER,MSGTEXT2    PUT OUT 'COMMAND ERROR' MSG
         SPACE 3
PARSEERR LA    R15,12         ERROR CODE 12 - COMMAND FAILED
         B     PARSERTN       RETURN FROM PARSE
         SPACE
PARSEOK  SR    R15,R15        CLEAR THE RETURN CODE
*  CHANGE 022G BELOW
*                                                                  021G
*        CHECK TO SEE IF USER AUTHORIZED (OPER AUTHORITY)          021G
*                                                                  021G
*        L     R14,ADDRPSCB       GET A(PSCB).                     021G
*        USING PSCB,R14           ESTABLISH ADDRESSABILITY.        021G
*        TM    PSCBATR1,PSCBCTRL  SEE IF OPER AUTHORITY.           021G
*        DROP  R14                DROP ADDRESSABILITY.             021G
*        BO    PARSERTN           YES, CONTINUE.                   021G
*        SPACE 1                                                   021G
*        LA    R15,12             NO, ERROR CODE 12 COMMAND FAILED 021G
*  CHANGE 022G ABOVE
PARSERTN L     R14,R14PARSE   GET THE RETURN LOCATION
         BR    R14            AND GET OUT OF HERE
         SPACE
         EJECT
*
*        PARSE CLEANUP ROUTINE
*
         SPACE 3
FREEPDL  DS    0H
         SPACE
         ST    R14,R14SAVE
         SPACE
         IKJRLSA ADDRANSR     RELEASE THE STORAGE
         SPACE 2
         XC    ADDRANSR,ADDRANSR
         SPACE
         L     R14,R14SAVE
         BR    R14
         EJECT
*
*
*        CONSTANTS
*
*
RTNADDRS DC    V(VTOCMSG)
         DC    A(0)           DUMMY ENTRY FOR THE EXIT ROUTINE
         DC    V(VTOCEXCP)
         DC    V(VTOCCHEK)
         DC    V(VTOCFORM)
         DC    V(VTOCPRNT)
         DC    V(VTOCSORT)
         DC    V(VTOCMAP)                                          010G
RTNADLEN EQU   *-RTNADDRS
ADDRPCL  DC    A(PCLMAIN)     ADDR OF MAIN PARSE CONTROL LIST
UCBEND   DC    X'0000FFFF'    END OF UCB LIST (HALFWORD -1)  004S 009G
BLANKS   DC    CL8' '         BALNKS
H2       DC    H'2'
H3       DC    H'3'
H4       DC    H'4'
H5       DC    H'5'
*
*
*
*
*
CHARALL  DC    CL3'ALL'
*HAR3380 DC    CL4'3380'                                       008G020G
*HAR3350 DC    CL4'3350'                                       006G020G
*HAR3330 DC    CL4'3330'                                       006G020G
*HAR333V DC    CL5'3330V'                                      006G020G
CHAR3350 DC    CL6'3350'                                   008G020G024G
CHAR3380 DC    CL6'3380'                                       008G020G
CHAR3390 DC    CL6'3390'                                           023G
CHAR3330 DC    CL6'3330'                                       006G020G
CHAR333V DC    CL6'3330V'                                      006G020G
MOVVOL   MVC   VOLSER(0),0(R5)
CLCVOL   CLC   VOLSER(0),UCBVOLI                                   018G
         DROP  R6                                                  018G
         EJECT
*
*        PROGRAM MESSAGES
*
         SPACE 2
         SPACE
MSGPARSE VTCMSG 'PARSE ERROR CODE '                                003G
MSGCMDER VTCMSG ' COMMAND SYSTEM ERROR'                            003G
MSGNOTMT VTCMSG ' VVVVVV VOLUME IS NOT MOUNTED'                    003G
MSGOFFLN VTCMSG ' VVVVVV VOLUME IS OFFLINE'                        003G
MSGPEND  VTCMSG ' VVVVVV VOLUME IS PENDING OFFLINE'                003G
*
*
         EJECT
*
*
*        P A R S E   C O N T R O L   L I S T
*
*
         SPACE 3
         COPY  VTCPARS                                             014G
         EJECT
*
*        DYNAMIC WORK AREA
*
         SPACE 3
WORKAREA DSECT
MAINSAVE DS    18A
         SPACE
         VTOCEXCP EQ          DEFINE VTOCEXCP CODES
         VTOCMAP  EQ          DEFINE VTOCMAP  CODES
         SPACE
PARSELST DS    8A             AREA FOR PARSE PARAMETER LIST
         SPACE
R14SAVE  DS    A
R14PARSE DS    A
*
*        VTOC COMMAND COMMON AREA
*
         VTCCOM  NODSECT                                           014G
         SPACE 3
*
*        WORK AREAS FOR SUBROUTINES
*
WORKMSG  DS    XL256
WORKEXCP DS    4XL256
WORKCHEK DS    2XL256                                              016G
WORKFORM DS    2XL256
WORKEXIT DS    8XL256
WORKSORT DS    XL256
WORKPRNT DS    10XL256
WORKMAP  DS    XL256                                              010G
         DS    0D                                                 009G
WORKUCB  DS    30F        WORK AREA FOR UCB SCAN RTN IOSVSUCB     009G
         DS    0D
LENWORK  EQU   *-WORKAREA
         SPACE 3
         VTCPDEDS                                                  014G
         SPACE 3
         IKJPPL
         SPACE 3
         IKJIOPL
         SPACE 3
         IKJPSCB
         SPACE 3
         IKJECT
         SPACE 3
         IKJCPPL
         SPACE 3
         IKJUPT
         SPACE 3
*        PRINT NOGEN
         DS    0D                      FORCE DOUBLEWORD SIZE
         CVT   DSECT=YES
UCB      DSECT                                                    018G
         IEFUCBOB                                                 018G
WORKUCBD DSECT                                                    009G
         DS    0D                                                 009G
WORKUCBA DS    XL100      WORK AREA FOR UCB SCAN RTN IOSVSUCB     009G
WORKUCBC DS    F          A(CURRENT UCB) FROM SCAN RTN IOSVSUCB   009G
WORKUCBP DS    3F         PARM LIST FOR UCB SCAN RTN IOSVSUCB     009G
WORKUCBT DS    X          DEVICE CLASS X20 FOR SCAN RTN IOSVSUCB  009G
FMT1DSEC DSECT                                                    010G
         IECSDSL1 (1)
         END

