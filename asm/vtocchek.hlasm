         TITLE 'VTOC COMMAND CHECK  ROUTINE'                            00010000
*********************************************************************** 00020000
*         MODIFICATIONS                                                 00030000
* NUMBER    DATE    PERSON    REASON                                    00040000
*  001G    072278   GATES     CHANGE MSG MACROS TO VTCMSG TO AVOID      00050000
*                              CONFLICT WITH AN EXISTING MSG MACRO.     00060000
*  002S    110978   SAVIT     CHANGE COMPARISON ROUTINE FOR DATE OF     00070000
*                              LAST USE (MVS RELEASE 3.7 SU60).         00080000
*  003G    110182   GATES     CLEAR REG 5 SO HI ORDER IS ZEROED TO      00090000
*                              CORRECT LEV PARAMETER CHECK ALSO         00100000
*                              END AND CONTAINING CHECK.                00110000
*  004G    110383   GATES     FIX BUG WHERE THE PROGRAM USED TO         00120000
*                              ASSUME THAT THE FORMAT 1 DSCB POINTED    00130000
*                              TO A FORMAT 3 DSCB. ISAM MULTI EXTENT    00140000
*                              DATASETS HAVE A FORMAT 1 DSCB POINTING   00150000
*                              TO A FORMAT 2 DSCB WHICH IN TURN POINTS  00160000
*                              TO A FORMAT 3 DSCB. WE NOW HANDLE ISAM   00170000
*                              SPACE STATS ACCURATELY.                  00180000
*  005G    111683   GATES     ADD LOGIC TO GET EXTENT INFO ON DSCB      00190000
*                              TYPES 4, 5, AND 6.                       00200000
*  006G    111883   GATES     ADD LOGIC KEEP FMT 4 DSCB FROM BEING      00210000
*                              PROCESED BY REST OF VTOC COMMAND. IT     00220000
*                              WAS ALREADY PROCESSED AT VTOC OPEN BY    00230000
*                              THE VTOC CSECT.                          00240000
*  007G    111883   GATES     PUT VOLSER IN ERROR MESSAGES.             00250000
*  008G    112183   GATES     ADD LOGIC TO HANDLE NOTLEV, NOTCON, AND   00260000
*                              NOTEND KEYWORDS.                         00270000
*  009G    050284   GATES     RENAME VTFMT MACRO TO VTCFMT,             00280000
*                              RENAME VTLEAVE MACRO TO VTCLEAVE,        00290000
*                              RENAME VTOCOM MACRO TO VTCCOM,           00300000
*                              RENAME VTOCPARS MACRO TO VTCPARS,        00310000
*                              RENAME PDEDSNAM MACRO TO VTCPDEDS,       00320000
*                               RENAME ENTER TO VTCENTER,               00330000
*                              VTOC MORE TRANSPORTABLE.                 00340000
*  010G    051084   GATES     EMBED VTOCMAP MACRO TO MAKE               00350000
*                              VTOC MORE TRANSPORTABLE.                 00360000
*  011G    051084   GATES     GET RID OF UNNEEDED LOGIC.                00370000
*  012G    051084   GATES     CHANGE CONSTANT FOR END OF TITLE TABLE.   00380000
*  013G    051584   GATES     ADD LOGIC FOR AND4/OR4 AND AND5/OR5.      00390000
*  014G    051584   GATES     ALLOW OPER OF = > < ¬= ¬< ¬> >= <=.       00400000
*  015G    051684   GATES     COMBINE LSTUS AND CDATE/EXPDT LOGIC.      00410000
*  016G    051684   GATES     ADD LOGIC FOR DSNAME LIMIT CHECKING.      00420000
*  017G    051684   GATES     UPGRADE LOGIC TO WORK WITH DATASETS WHICH 00430000
*                              CONTAIN MORE THAN 16 EXTENTS. WHAT I DO  00440000
*                              IS SAVE ALL THE FMT3 DSCBS FOR A DATASET 00450000
*                              IN VTOCOM.                               00460000
*  018G    052184   GATES     MOVE CODE TO SPEED PROCESSING UP.         00470000
*  019G    111685   GATES     CHANGE LEVEL AND NLEVEL KEYWORDS TO BE    00480000
*                              THE HIGH LEVEL INDEX INSTEAD OF THE      00490000
*                              BEGINNING CHARACTERS ONLY.               00500000
*  020G    111685   GATES     ADD BEGINNING AND NBEGINNING KEYWORDS     00510000
*                              TO BE THE START CHARACTERS OF THE HIGH   00520000
*                              LEVEL INDEX INSTEAD OF THE WHOLE HIGH    00530000
*                              LEVEL INDEX.  THIS USED TO BE THE        00540000
*                              LEVEL AND NLEVEL KEYWORDS.               00550000
*  021G    122387   GATES     ADD LOGIC TO ALLOW * IN LIMIT/AND/OR      00560000
*                              TO MEAN CURRENT DATE WHEN CHECKING DATE  00570000
*                              FIELDS.                                  00580000
*  022G    122387   GATES     ADD ANOTHER BASE REG (R10).               00581000
*  023G    010488   GATES     ADD LOGIC FOR KEY LENGTH.                 00583000
*  024G    010488   GATES     CHANGE CONSTANT FOR END OF TITLE TABLE.   00584000
*  025G    041388   GATES     ADD LOGIC FOR LOWLEVEL/NOTLOWLEVEL        00585001
*                             KEYWORD.                                  00590001
*                                                                     * 00600000
*                                                                     * 00610000
* TITLE -      VTOC COMMAND CHECK  ROUTINE                            * 00620000
*                                                                     * 00630000
* FUNCTION -   CHECK THE CONDITIONS SPECIFIED ON THE VTOC COMMAND.    * 00640000
*              SEE IF THE DATA SET PASSED SHOULD BE PROCESSED.        * 00650000
*              THE LIMIT, ENDING, CONTAINING, CCHH, LIMIT, AND,       * 00660000
*              AND OR KEYWORDS ARE PROCESSED BY THIS ROUTINE.         * 00670000
*                                                                     * 00680000
* OPERATION -  FIRST GET THE LENGTH OF THE DSNAME AND SAVE IT.        * 00690000
*              THEN GET THE FORMAT 3 DSCB, IF ONE EXISTS.  TRY        * 00700000
*              EACH KEYWORD TO SEE IF IT WILL EXCLUDE THE DATA        * 00710000
*              SET FROM FURTHER PROCESSING.                           * 00720000
*                                                                     * 00730000
* INPUT -      VTOC COMMON AREA ( VTOCOM )                            * 00740000
*              POINTED TO BY REGISTER 1                               * 00750000
*              USE PARSE DATA, FORMAT 1, 3, AND 4 DSCB'S              * 00760000
*              FOR DSORG, RECFM, ALLOC, USED, PROT, CATLG, OR SECAL   * 00770000
*              CALL VTOCFORM TO FORMAT THE PARMS.  USE FORMATTED DSCB * 00780000
*                                                                     * 00790000
* OUTPUT -     A RETURN CODE OF 0 TO CONTINUE PROCESSING OR 8 TO      * 00800000
*              EXCLUDE THIS DATA SET.                                 * 00810000
*                                                                     * 00820000
* ATTRIBUTES - REENTRANT, REUSEABLE, REFRESHABLE.                     * 00830000
*                                                                     * 00840000
*                                                                     * 00850000
*         PROGRAMMED BY R. L. MILLER  (415) 485-6241                  * 00860000
*                                                                     * 00870000
*                                                                     * 00880000
*********************************************************************** 00890000
         EJECT                                                          00900000
*        MACROS FOR CHECK ROUTINE                                       00910000
*                                                                       00920000
         MACRO                                                          00930000
&LABEL   VTCHL &KEY              CALL THE KEYWORD CHECK ROUTINE         00940000
&LABEL   L     R1,SUB&KEY.OPER   GET THE OPERATOR VALUE                 00950000
         BAL   R8,GETOPER        TRANSLATE TO A NUMBER                  00960000
         ST    R15,REFOPER       SAVE IT TOO                            00970000
         LA    R1,SUB&KEY.VALU   GET THE VALUE PDL                      00980000
         ST    R1,REFVAL         SAVE THAT ADDRESS THREE                00990000
         CLI   FLAGNM&KEY,0      HAS IT BEEN CONVERTED?                 01000000
         BNE   VTP&SYSNDX        YES, SKIP ALONG                        01010000
         MVI   FLAGNM&KEY,1      NOTE IT AS CONVERTED                   01020000
         BAL   R8,PDLNUM         GO CONVERT IT                          01030000
         ST    R15,NUMBER&KEY    SAVE THE VALUE                         01040000
.*                                IT WILL BE ZERO FOR NONNUMERIC.       01050000
         LA    R4,SUB&KEY.KEY    POINT TO THE IKJIDENT FOR THE KEYWORD  01060000
         BAL   R8,GETKEY         CONVERT TEXT TO A NUMERIC KEY          01070000
         STC   R15,NUMKEY&KEY    SAVE THAT NUMERIC KEY                  01080000
         LTR   R15,R15           WAS IT SUCCESSFUL?                     01090000
         BNZ   VTP&SYSNDX        YES, SKIP ALONG                        01100000
*        ISSUE A MESSAGE - A BAD LIM, AND, OR KEYWORD                   01110000
         MVC   MSGTEXT2,KEYERR   START THE ERROR MESSAGE                01120000
         L     R1,0(R4)          POINT TO THE TEXT                      01130000
         MVC   MSGTEXT2+49(6),0(R1)  THEN ADD IT TO THE MESSAGE         01140000
         VTOCMSG MSGTEXT2        ISSUE THE ERROR MESSAGE                01150000
VTP&SYSNDX DS  0H                                                       01160000
         SR    R1,R1             CLEAR A REGISTER                       01170000
         ICM   R1,1,NUMKEY&KEY   GET THE KEYWORD VALUE                  01180000
         BZ    VTE&SYSNDX        IF NOT SET, SKIP THE EVALUATION        01190000
         ST    R1,REFKEY         SAVE THE ADDRESS                       01200000
         LA    R1,NUMBER&KEY     GET THE ADDRESS OF CONVERTED NUMBER    01210000
         ST    R1,REFNUM         SAVE IT'S ADDRESS                      01220000
         BAL   R8,LIMEVAL        GO EVALUATE THE EXPRESSION             01230000
VTE&SYSNDX DS  0H                                                       01240000
         MEND                                                           01250000
         SPACE 3                                                        01260000
         MACRO                                                          01270000
&LABEL   VTANDOR &NUM         EVALUATE, THEN DO AND OR OR FUNCTION      01280000
&LABEL   CLI   ANDOR&NUM.K+1,0  WAS THIS KEYWORD SET?                   01290000
         BE    LIMCOMP        NO, JUST CHECK THE FINAL RESULT           01300000
         VTCHL &NUM           YES, EVALUATE                             01310000
         CLI   ANDOR&NUM.K+1,1  WAS IT AN AND ?                         01320000
         BE    VTA&SYSNDX     YES, DO THE AND                           01330000
         O     R15,LIMVAL     NO, OR IT                                 01340000
         B     VTE&SYSNDX     FINISHED WITH THIS EXPRESSION             01350000
VTA&SYSNDX N   R15,LIMVAL     AND THE EXPRESSION VALUE                  01360000
VTE&SYSNDX ST  R15,LIMVAL     SAVE THE VALUE                            01370000
         MEND                                                           01380000
         MACRO                                                          01390000
&LABEL   VTOCMAP   &FUNC                                         010G   01400000
         AIF   ('&FUNC' NE 'EQ').MCALL                           010G   01410000
VTCMOPEN EQU   0              DEFINE FUNCTION CODES FOR VTOCMAP. 010G   01420000
VTCMADD  EQU   1              DEFINE FUNCTION CODES FOR VTOCMAP. 010G   01430000
VTCMCLOS EQU   2              DEFINE FUNCTION CODES FOR VTOCMAP. 010G   01440000
VTCMSORT EQU   3              DEFINE FUNCTION CODES FOR VTOCMAP. 010G   01450000
         MEXIT                                                          01460000
.MCALL   ANOP                 CALL VTOCMAP                       010G   01470000
&LABEL   MVI   VTCMFUNC,VTCM&FUNC   SET THE FUNCTION CODE        010G   01480000
         VTCALL MAP           GO TO MAP ROUTINE.                 010G   01490000
         MEND                                                           01500000
*                                                                       01510000
         EJECT                                                          01520000
VTOCCHEK VTCENTER (R12,R10),12   DO THE HOUSEKEEPING         009G022G   01530000
         LR    R11,R1         SAVE ADDR OF VTOCOM                       01540000
         USING VTOCOM,R11     SET ITS ADDRESSABILITY                    01550000
         L     R9,ADDRANSR    POINT TO THE PARSE ANSWER                 01560000
         USING PDL,R9         SET ITS ADDRESSABILITY                    01570000
         USING CHEKWORK,R13   SET ADDRESSABILITY FOR LOCAL WORK AREA    01580000
*                                                                       01590000
*        SEE WHAT THE FORMAT ID IS                                      01600000
*                                                                       01610000
CHEKFMT  L     R7,DSCBADDR    POINT TO THE DSCB                         01620000
         LA    R7,8(R7)       GET PAST THE HEADER                       01630000
         USING FMT1DSEC,R7    SET ADDRESSABILITY                   005G 01640000
*        CLI   FORMATK+1,0    DID HE SPECIFY VARIOUS DSCB'S        011G 01650000
*        BNE   CHEKFMTI       YES, GO DO HIS CHECKS                011G 01660000
*HEKFMTI DS    0H             NOT YET PROGRAMMED                   011G 01670000
*                                                                       01680000
*        STANDARD IS ONLY TO ALLOW FORMAT ONES TO GO                    01690000
*                                                                       01700000
         CLI   DS1FMTID,C'1'  IS THIS A FORMAT 1?                       01710000
         BE    GOTFMT1        YES, SEE IF SHOULD INCLUDE IT.       005G 01720000
         CLI   DS1FMTID,C'4'  IS THIS A FORMAT 4?                  005G 01730000
         BE    GOTFMT4        YES, KEEP TO GATHER EXTENT INFO ONLY.005G 01740000
         CLI   DS1FMTID,C'5'  IS THIS A FORMAT 5?                  005G 01750000
         BE    GOTFMT5        YES, KEEP TO GATHER EXTENT INFO ONLY.005G 01760000
         CLI   DS1FMTID,C'6'  IS THIS A FORMAT 6?                  005G 01770000
         BE    CHECKOUT       EXCLUDE IT;ALREADY DONE ON FMT4.     005G 01780000
         B     CHECKOUT       EXCLUDE IT FROM MORE PROCESSING.     005G 01790000
*                                                                       01800000
*              FIRST SEE HOW BIG THE DSNAME IS                          01810000
*                                                                       01820000
GOTFMT1  LA    R1,DS1FMTID    POINT PAST THE DSNAME                005G 01830000
         TRT   DS1DSNAM,BLKTRTAB  FIND THE FIRST BLANK                  01840000
         SR    R1,R7          SUBTRACT TO GET THE LENGTH                01850000
         STH   R1,DSNLEN      SAVE THE DSNAME LENGTH                    01860000
         LR    R3,R1          KEEP THE LENGTH FOR LATER                 01870000
*                                                                       01880000
*        GET THE FORMAT 3 DSCB, IF IT EXISTS                            01890000
*                                                                       01900000
*MT3GET  XC    FMT3,FMT3      CLEAR IT FIRST.                  004G018G 01910000
FMT3GET  CLC   DS1PTRDS,=XL5'0000000000'  IS THERE A FORMAT 3?     018G 01920000
         BE    FMT3LAST       NO, SKIP ALONG.                      018G 01930000
*        XC    FMT3,FMT3      CLEAR FORMAT 3 WORK AREA.            018G 01940000
         LA    R0,FMT3        GET A(FORMAT 3 WORK AREA).           017G 01950000
         XR    R1,R1          CLEAR FORMAT 3 WORK AREA.            017G 01960000
         LR    R4,R0          GET A(FORMAT 3 WORK AREA).           017G 01970000
         LA    R5,FMT3LEN     GET L(FORMAT 3 WORK AREA).           017G 01980000
         MVCL  R4,R0          CLEAR FORMAT 3 WORK AREA.            017G 01990000
         LA    R4,FMT3        GET A(WORK AREA BEGINNING).          017G 02000000
FMT3NEXT CLC   DS1PTRDS,=XL5'0000000000'  IS THERE ANOTHER FMT3?   017G 02010000
         BE    FMT3LAST       NO, I'VE HIT LAST ONE.               017G 02020000
         LA    R1,DS1PTRDS    GET THE CCHHR ADDRESS OF NEXT FMT3.  017G 02030000
*        LA    R15,FMT3       POINT TO TEMP AREA FOR THE DSCB3.005G017G 02040000
         LR    R15,R4         GET A(NEXT AVAIL FMT3 SLOT).         017G 02050000
         BAL   R2,OBTAINIT             GET THE RECORD.             005G 02060000
         LTR   R15,R15        TEST THE RETURN CODE                      02070000
         BNZ   OBT3ERR        BAD NEWS, ISSUE THE MESSAGE               02080000
*        CLI   DS3FMTID,C'2'  IS IT A FORMAT 2 DSCB?               004G 02090000
*        BNE   FMT3NO         NO, GO PROCESS FORMAT 3 DSCB.        004G 02100000
         CLI   44(R4),C'2'    IS IT A FORMAT 2 DSCB?          004G 017G 02110000
         BNE   FMT3YES        NO, GO PROCESS FORMAT 3 DSCB.        017G 02120000
         MVC   DS1PTRDS,135(R4)   MOVE REAL FORMAT 3 POINTER       004G 02130000
*                                   FROM THE FORMAT 2 DSCB.        004G 02140000
         B     FMT3GET        GET THE FORMAT 3.                    004G 02150000
FMT3YES  MVC   DS1PTRDS,135(R4)  GET NEXT FORMAT 3 POINTER.        017G 02160000
*        MAKE 13 CONTIGUOUS EXTENTS.                               017G 02170000
         MVC   0(40,R4),4(R4)    SHOVE FIRST 4 EXT LEFT.           017G 02180000
         MVC   40(90,R4),45(R4)  SHOVE NEXT 9 EXT LEFT.            017G 02190000
         LA    R4,130(R4)     GET A(NEXT AVAIL FMT3 SLOT).         017G 02200000
         B     FMT3NEXT       GET THE NEXT FORMAT 3.               017G 02210000
FMT3LAST DS    0H                                                  017G 02220000
*                                                                       02230000
*        PROCESS THE LEVEL KEYWORD                                      02240000
*                                                                       02250000
FMT3NO   CLI   LEVKEY+1,0     WAS LEVEL SPECIFIED?                      02260000
         BE    LEVEND         NO, SKIP ON.                              02270000
         LA    R4,LEVEL       ASSUME LEVEL SPECIFIED.                   02280000
         USING PDEDSNAM,R4    SET ADDRESSABILITY                        02290000
         LR    R2,R7          POINT TO THE START OF THE DSNAME          02300000
LEVNEXT  SR    R5,R5          CLEAR REG 5.                         003G 02310000
         ICM   R5,B'0011',PDEDSNL  GET THE DSNAME LENGTH           003G 02320000
         BZ    CHECKOUT       END OF THE LINE, EXCLUDE IT               02330000
         L     R6,PDEDSN      POINT TO THE LEVEL                        02340000
         CR    R3,R5          COMPARE LENGTHS                           02350000
         BL    LEVINC         THIS LEVEL IS LONGER THAN DSN, NO MATCH   02360000
         AR    R7,R5          BUMP TO WHERE PERIOD SHOULD BE.      019G 02370000
         CLC   0(1,R7),PERIOD THERE BETTER BE A PERIOD HERE.       019G 02380000
         BE    LEVCHK         IF PERIOD COMPARE LEVEL CHARACTERS.  019G 02390000
         SR    R7,R5          RESET TO START OF DSNAME.            019G 02400000
         B     LEVINC         THIS LEVEL WON'T MATCH.              019G 02410000
LEVCHK   SR    R7,R5          RESET TO START OF DSNAME.            019G 02420000
         BCTR  R5,0           MINUS ONE FOR THE EX                      02430000
         EX    R5,COMPARE     CHECK THE LENGTHS                         02440000
         BE    LEVEND         IT MATCHES, ALLOW IT.                     02450000
LEVINC   ICM   R4,B'0111',PDEDCHN GET THE NEXT LEVEL PDE POINTER        02460000
         BNZ   LEVNEXT        IF IT'S THERE, KEEP LOOKING               02470000
         B     CHECKOUT       NO MATCHES, EXCLUDE THIS DSNAME           02480000
LEVEND   DS    0H                                                       02490000
         DROP  R4             FINISHED WITH THE PDE                     02500000
*                                                                  020G 02510000
*        PROCESS THE BEGINNING KEYWORD                             020G 02520000
*                                                                  020G 02530000
         CLI   BEGKEY+1,0     WAS BEGINNING SPECIFIED?             020G 02540000
         BE    BEGEND         NO, SKIP ON.                         020G 02550000
         LA    R4,BEGIN       ASSUME BEGINNING SPECIFIED.          020G 02560000
         USING PDEDSNAM,R4    SET ADDRESSABILITY                   020G 02570000
         LR    R2,R7          POINT TO THE START OF THE DSNAME     020G 02580000
BEGNEXT  SR    R5,R5          CLEAR REG 5.                         020G 02590000
         ICM   R5,B'0011',PDEDSNL  GET THE DSNAME LENGTH           020G 02600000
         BZ    CHECKOUT       END OF THE LINE, EXCLUDE IT          020G 02610000
         L     R6,PDEDSN      POINT TO THE BEGIN                   020G 02620000
         CR    R3,R5          COMPARE LENGTHS                      020G 02630000
         BL    BEGINC         BEGIN IS LONGER THAN DSN, NO MATCH   020G 02640000
         BCTR  R5,0           MINUS ONE FOR THE EX                 020G 02650000
         EX    R5,COMPARE     CHECK THE LENGTHS                    020G 02660000
         BE    BEGEND         IT MATCHES, ALLOW IT.                020G 02670000
BEGINC   ICM   R4,B'0111',PDEDCHN GET THE NEXT BEGIN PDE POINTER   020G 02680000
         BNZ   BEGNEXT        IF IT'S THERE, KEEP LOOKING          020G 02690000
         B     CHECKOUT       NO MATCHES, EXCLUDE THIS DSNAME      020G 02700000
BEGEND   DS    0H                                                  020G 02710000
         DROP  R4             FINISHED WITH THE PDE                020G 02720000
*                                                                       02730000
*        PROCESS THE NOTLEVEL KEYWORD                                   02740000
*                                                                       02750000
         CLI   NLEVKEY+1,0    WAS NOTLEVEL SPECIFIED?            008G   02760000
         BE    NLEVEND        NO, SKIP ON.                       008G   02770000
         LA    R4,NLEVEL      YES, POINT TO PDE.                 008G   02780000
         USING PDEDSNAM,R4    SET ADDRESSABILITY                 008G   02790000
         LR    R2,R7          POINT TO THE START OF THE DSNAME   008G   02800000
NLEVNEXT SR    R5,R5          CLEAR REG 5.                       008G   02810000
         ICM   R5,B'0011',PDEDSNL  GET THE DSNAME LENGTH         008G   02820000
         BZ    NLEVEND        END OF THE LINE, INCLUDE IT        008G   02830000
         L     R6,PDEDSN      POINT TO THE LEVEL                 008G   02840000
         CR    R3,R5          COMPARE LENGTHS                    008G   02850000
         BL    NLEVINC        LEVEL IS LONGER THAN DSN, NO MATCH 008G   02860000
         AR    R7,R5          BUMP TO WHERE PERIOD SHOULD BE.      019G 02870000
         CLC   0(1,R7),PERIOD THERE BETTER BE A PERIOD HERE.       019G 02880000
         BE    NLEVCHK        IF PERIOD COMPARE LEVEL CHARACTERS.  019G 02890000
         SR    R7,R5          RESET TO START OF DSNAME.            019G 02900000
         B     NLEVINC        NO PERIOD, WON'T MATCH.              019G 02910000
NLEVCHK  SR    R7,R5          RESET TO START OF DSNAME.            019G 02920000
         BCTR  R5,0           MINUS ONE FOR THE EX               008G   02930000
         EX    R5,COMPARE     CHECK THE LENGTHS                  008G   02940000
         BE    CHECKOUT       IT MATCHES, EXCLUDE IT.            008G   02950000
NLEVINC  ICM   R4,B'0111',PDEDCHN GET THE NEXT LEVEL PDE POINTER 008G   02960000
         BNZ   NLEVNEXT       IF IT'S THERE, KEEP LOOKING        008G   02970000
         B     NLEVEND        NO MATCHES, INCLUDE THIS DSNAME    008G   02980000
NLEVEND  DS    0H                                                008G   02990000
         DROP  R4             FINISHED WITH THE PDE              008G   03000000
*                                                                  020G 03010000
*        PROCESS THE NOTBEGINNING KEYWORD                          020G 03020000
*                                                                  020G 03030000
         CLI   NBEGKEY+1,0    WAS NBEGIN SPECIFIED?                020G 03040000
         BE    NBEGEND        NO, SKIP ON.                         020G 03050000
         LA    R4,NBEGIN      YES, POINT TO PDE.                   020G 03060000
         USING PDEDSNAM,R4    SET ADDRESSABILITY                   020G 03070000
         LR    R2,R7          POINT TO THE START OF THE DSNAME     020G 03080000
NBEGNEXT SR    R5,R5          CLEAR REG 5.                         020G 03090000
         ICM   R5,B'0011',PDEDSNL  GET THE DSNAME LENGTH           020G 03100000
         BZ    NBEGEND        END OF THE LINE, INCLUDE IT          020G 03110000
         L     R6,PDEDSN      POINT TO THE NBEGIN VALUE.           020G 03120000
         CR    R3,R5          COMPARE LENGTHS                      020G 03130000
         BL    NBEGINC        NBEGIN IS LONGER THAN DSN, NO MATCH  020G 03140000
         BCTR  R5,0           MINUS ONE FOR THE EX                 020G 03150000
         EX    R5,COMPARE     CHECK THE LENGTHS                    020G 03160000
         BE    CHECKOUT       IT MATCHES, EXCLUDE IT.              020G 03170000
NBEGINC  ICM   R4,B'0111',PDEDCHN GET THE NEXT NBEGIN PDE POINTER  020G 03180000
         BNZ   NBEGNEXT       IF IT'S THERE, KEEP LOOKING          020G 03190000
         B     NBEGEND        NO MATCHES, INCLUDE THIS DSNAME      020G 03200000
NBEGEND  DS    0H                                                  020G 03210000
         DROP  R4             FINISHED WITH THE PDE                020G 03220000
*                                                                       03230000
*        PROCESS THE ENDING KEYWORD                                     03240000
*                                                                       03250000
         CLI   ENDKEY+1,0     WAS ENDING SPECIFIED?                     03260000
         BE    ENDEND         NO, SKIP ON                               03270000
         LA    R4,ENDING      YES, POINT TO THE PDE                     03280000
         USING PDEDSNAM,R4    SET ADDRESSABILITY                        03290000
ENDNEXT  SR    R5,R5          CLEAR HI ORDER OF REG 5.            003G  03300000
         ICM   R5,B'0011',PDEDSNL  GET THE DSNAME LENGTH          003G  03310000
         BZ    CHECKOUT       END OF THE LINE, EXCLUDE IT               03320000
         L     R6,PDEDSN      POINT TO THE ENDING                       03330000
         CR    R3,R5          COMPARE LENGTHS                           03340000
         BL    ENDINC         THIS ENDING IS LONGER THAN DSN, NO MATCH  03350000
         LR    R2,R7          POINT TO THE START OF THE DSNAME          03360000
         AR    R2,R3          POINT TO THE END                          03370000
         SR    R2,R5          BACKUP TO COMPARE THIS LENGTH             03380000
         BCTR  R5,0           MINUS ONE FOR THE EX                      03390000
         EX    R5,COMPARE     CHECK THE LENGTHS                         03400000
         BE    ENDEND         IT MATCHES, ALLOW IT                      03410000
ENDINC   ICM   R4,B'0111',PDEDCHN GET THE NEXT ENDING PDE POINTER       03420000
         BNZ   ENDNEXT        IF IT'S THERE, KEEP LOOKING               03430000
         B     CHECKOUT       NO MATCHES, EXCLUDE THIS DSNAME           03440000
ENDEND   DS    0H                                                       03450000
         DROP  R4             FINISHED WITH THE PDE                     03460000
*                                                                       03470000
*        PROCESS THE NOTENDING KEYWORD                                  03480000
*                                                                       03490000
         CLI   NENDKEY+1,0    WAS NOTENDING SPECIFIED?            008G  03500000
         BE    NENDEND        NO, SKIP ON                         008G  03510000
         LA    R4,NENDING     YES, POINT TO THE PDE               008G  03520000
         USING PDEDSNAM,R4    SET ADDRESSABILITY                  008G  03530000
NENDNEXT SR    R5,R5          CLEAR HI ORDER OF REG 5.            008G  03540000
         ICM   R5,B'0011',PDEDSNL  GET THE DSNAME LENGTH          008G  03550000
         BZ    NENDEND        END OF THE LINE, INCLUDE IT         008G  03560000
         L     R6,PDEDSN      POINT TO THE ENDING                 008G  03570000
         CR    R3,R5          COMPARE LENGTHS                     008G  03580000
         BL    NENDINC        NOTENDING IS LONGER THAN DSN, NO MATCH    03590000
         LR    R2,R7          POINT TO THE START OF THE DSNAME    008G  03600000
         AR    R2,R3          POINT TO THE END                    008G  03610000
         SR    R2,R5          BACKUP TO COMPARE THIS LENGTH       008G  03620000
         BCTR  R5,0           MINUS ONE FOR THE EX                008G  03630000
         EX    R5,COMPARE     CHECK THE LENGTHS                   008G  03640000
         BE    CHECKOUT       IT MATCHES, EXCLUDE IT.             008G  03650000
NENDINC  ICM   R4,B'0111',PDEDCHN GET THE NEXT ENDING PDE POINTER 008G  03660000
         BNZ   NENDNEXT       IF IT'S THERE, KEEP LOOKING         008G  03670000
         B     NENDEND        NO MATCHES, INCLUDE THIS DSNAME     008G  03680000
NENDEND  DS    0H                                                 008G  03690000
         DROP  R4             FINISHED WITH THE PDE               008G  03700000
*                                                                  025G 03701001
*        PROCESS THE LOWLEVEL KEYWORD                              025G 03702001
*                                                                  025G 03703001
         CLI   LOWKEY+1,0     WAS LOWLEVEL SPECIFIED?              025G 03704001
         BE    LOWEND         NO, SKIP ON.                         025G 03705001
         LA    R4,LOWLEV      ASSUME LOWLEVEL SPECIFIED.           025G 03706002
         USING PDEDSNAM,R4    SET ADDRESSABILITY.                  025G 03707001
LOWNEXT  SR    R5,R5          CLEAR REG 5.                         025G 03708001
         ICM   R5,B'0011',PDEDSNL  GET THE DSNAME LENGTH.          025G 03709001
         BZ    CHECKOUT       END OF THE LINE, EXCLUDE IT.         025G 03709101
         L     R6,PDEDSN      POINT TO THE LOWLEVEL.               025G 03709201
         CR    R3,R5          COMPARE LENGTHS.                     025G 03709301
         BL    LOWINC         LOWLEVEL IS LONGER THAN DSN, NO MATCH025G 03709401
         LR    R2,R7          POINT TO THE START OF THE DSNAME.    025G 03709501
         AR    R2,R3          POINT TO THE END.                    025G 03709601
         SR    R2,R5          BACKUP TO COMPARE THIS LENGTH.       025G 03709701
         BCTR  R2,0           SUBTRACT ONE TO CHECK FOR PERIOD.    025G 03709801
         CLC   0(1,R2),PERIOD THERE BETTER BE A PERIOD HERE.       025G 03709901
         LA    R2,1(R2)       RESET TO STRING TO COMPARE.          025G 03710001
         BNE   LOWINC         THIS LOWLEVEL WON'T MATCH.           025G 03710301
         BCTR  R5,0           MINUS ONE FOR THE EX.                025G 03710501
         EX    R5,COMPARE     CHECK THE LENGTHS.                   025G 03710601
         BE    LOWEND         IT MATCHES, ALLOW IT.                025G 03710701
LOWINC   ICM   R4,B'0111',PDEDCHN GET THE NEXT LOWLEVEL PDE POINTER025G 03710801
         BNZ   LOWNEXT        IF IT'S THERE, KEEP LOOKING          025G 03710901
         B     CHECKOUT       NO MATCHES, EXCLUDE THIS DSNAME      025G 03711001
LOWEND   DS    0H                                                  025G 03711101
         DROP  R4             FINISHED WITH THE PDE                025G 03711201
*                                                                  025G 03711301
*        PROCESS THE NOTLOWLEVEL KEYWORD                           025G 03711401
*                                                                  025G 03711501
         CLI   NLOWKEY+1,0    WAS NLOWLEV SPECIFIED?               025G 03711601
         BE    NLOWEND        NO, SKIP ON.                         025G 03711701
         LA    R4,NLOWLEV     ASSUME NLOWLEV SPECIFIED.            025G 03711801
         USING PDEDSNAM,R4    SET ADDRESSABILITY.                  025G 03711901
NLOWNEXT SR    R5,R5          CLEAR REG 5.                         025G 03712001
         ICM   R5,B'0011',PDEDSNL  GET THE DSNAME LENGTH.          025G 03712101
         BZ    NLOWEND        END OF THE LINE, INCLUDE IT.         025G 03712201
         L     R6,PDEDSN      POINT TO THE NLOWLEV.                025G 03712301
         CR    R3,R5          COMPARE LENGTHS.                     025G 03712401
         BL    NLOWINC        NLOWLEV IS LONGER THAN DSN, NO MATCH.025G 03712501
         LR    R2,R7          POINT TO THE START OF THE DSNAME.    025G 03712601
         AR    R2,R3          POINT TO THE END.                    025G 03712701
         SR    R2,R5          BACKUP TO COMPARE THIS LENGTH.       025G 03712801
         BCTR  R2,0           SUBTRACT ONE TO CHECK FOR PERIOD.    025G 03712901
         CLC   0(1,R2),PERIOD THERE BETTER BE A PERIOD HERE.       025G 03713001
         LA    R2,1(R2)       RESET TO STRING TO COMPARE.          025G 03713101
         BNE   NLOWINC        THIS NLOWLEV WON'T MATCH.            025G 03713201
         BCTR  R5,0           MINUS ONE FOR THE EX.                025G 03713301
         EX    R5,COMPARE     CHECK THE LENGTHS.                   025G 03713401
         BE    CHECKOUT       IT MATCHES, EXCLUDE IT.              025G 03713501
NLOWINC  ICM   R4,B'0111',PDEDCHN GET THE NEXT NLOWLEV PDE POINTER.025G 03713601
         BNZ   NLOWNEXT       IF IT'S THERE, KEEP LOOKING          025G 03713701
         B     NLOWEND        NO MATCHES, INCLUDE THIS DSNAME      025G 03713801
NLOWEND  DS    0H                                                  025G 03713901
         DROP  R4             FINISHED WITH THE PDE                025G 03714001
*                                                                       03715000
*        PROCESS THE CONTAINING KEYWORD                                 03720000
*                                                                       03730000
         CLI   CONTAINK+1,0   WAS CONTAINING SPECIFIED?                 03740000
         BE    CONEND         NO, SKIP ON                               03750000
         LA    R4,CONTAIN     YES, POINT TO THE PDE                     03760000
         USING PDEDSNAM,R4    SET ADDRESSABILITY                        03770000
CONNEXT  SR    R5,R5          CLEAR HIORDER OF REG 5.             003G  03780000
         ICM   R5,B'0011',PDEDSNL  GET THE DSNAME LENGTH          003G  03790000
         BZ    CHECKOUT       END OF THE LINE, EXCLUDE IT               03800000
         L     R6,PDEDSN      POINT TO THE CONTAINING                   03810000
         CR    R3,R5          COMPARE LENGTHS                           03820000
         BL    CONINC         THIS CONTAIN IS LONGER THAN DSN, NO MATCH 03830000
         LR    R1,R7          POINT TO THE START OF THE DSNAME          03840000
         AR    R1,R3          POINT TO THE END                          03850000
         SR    R1,R5          BACKUP TO COMPARE THIS LENGTH - LAST ONE  03860000
         LR    R2,R7          POINT TO THE START OF THE DSNAME          03870000
         BCTR  R5,0           MINUS ONE FOR THE EX                      03880000
CONCOMP  EX    R5,COMPARE     CHECK THE LENGTHS                         03890000
         BE    CONEND         IT MATCHES, ALLOW IT                      03900000
         LA    R2,1(R2)       CHECK THE WHOLE DSNAME                    03910000
         CR    R2,R1          CHECK FOR THE END OF THE REAL DSN         03920000
         BNH   CONCOMP        NOT THERE YET                             03930000
CONINC   ICM   R4,B'0111',PDEDCHN GET THE NEXT CONTAINING PDE POINTER   03940000
         BNZ   CONNEXT        IF IT'S THERE, KEEP LOOKING               03950000
         B     CHECKOUT       NO MATCHES, EXCLUDE THIS DSNAME           03960000
CONEND   DS    0H                                                       03970000
         DROP  R4             FINISHED WITH THE PDE                     03980000
*                                                                       03990000
*        PROCESS THE NOTCONTAINING KEYWORD                              04000000
*                                                                       04010000
         CLI   NCONKEY+1,0    WAS NOTCONTAINING SPECIFIED?        008G  04020000
         BE    NCONEND        NO, SKIP ON                         008G  04030000
         LA    R4,NCONTAIN    YES, POINT TO THE PDE               008G  04040000
         USING PDEDSNAM,R4    SET ADDRESSABILITY                  008G  04050000
NCONNEXT  SR    R5,R5         CLEAR HIORDER OF REG 5.             008G  04060000
         ICM   R5,B'0011',PDEDSNL  GET THE DSNAME LENGTH          008G  04070000
         BZ    NCONEND        END OF THE LINE, INCLUDE IT         008G  04080000
         L     R6,PDEDSN      POINT TO THE NOTCONTAINING          008G  04090000
         CR    R3,R5          COMPARE LENGTHS                     008G  04100000
         BL    NCONINC        NOTCONTAIN IS LONGER THAN DSN, NO MATCH   04110000
         LR    R1,R7          POINT TO THE START OF THE DSNAME    008G  04120000
         AR    R1,R3          POINT TO THE END                    008G  04130000
         SR    R1,R5          BACKUP TO COMPARE THIS LENGTH - LAST ONE  04140000
         LR    R2,R7          POINT TO THE START OF THE DSNAME    008G  04150000
         BCTR  R5,0           MINUS ONE FOR THE EX                008G  04160000
NCONCOMP EX    R5,COMPARE     CHECK THE LENGTHS                   008G  04170000
         BE    CHECKOUT       IT MATCHES, EXCLUDE IT.             008G  04180000
         LA    R2,1(R2)       CHECK THE WHOLE DSNAME              008G  04190000
         CR    R2,R1          CHECK FOR THE END OF THE REAL DSN   008G  04200000
         BNH   NCONCOMP       NOT THERE YET                       008G  04210000
NCONINC  ICM   R4,B'0111',PDEDCHN GET THE NEXT CONTAINING PDE POINTER   04220000
         BNZ   NCONNEXT       IF IT'S THERE, KEEP LOOKING         008G  04230000
         B     NCONEND        NO MATCHES, INCLUDE THIS DSNAME     008G  04240000
NCONEND  DS    0H                                                 008G  04250000
         DROP  R4             FINISHED WITH THE PDE               008G  04260000
*                                                                       04270000
*        NOW THE BIG MESS, CHECK FOR LIMIT, AND'S, AND OR'S             04280000
*                                                                       04290000
         CLI   LIMITK+1,0     WAS LIMIT SPECIFIED                       04300000
         BE    LIMEND         NO, THEN THERE CAN BE NO AND'S OR OR'S    04310000
         NI    VTCFMTCK,255-VTCFMTCC  TURN OFF THE ROUTINE CALL FLAG    04320000
         VTCHL L              EVALUATE THE LIMIT 1=TRUE 0=FALSE         04330000
         ST    R15,LIMVAL     SAVE THE ANSWER                           04340000
         VTANDOR 1            CHECK AND1 OR OR1                         04350000
         VTANDOR 2            CHECK AND2 OR OR2                         04360000
         VTANDOR 3            CHECK AND3 OR OR3                         04370000
         VTANDOR 4            CHECK AND4 OR OR4                    013G 04380000
         VTANDOR 5            CHECK AND5 OR OR5                    013G 04390000
LIMCOMP  L     R15,LIMVAL     GET THE RESULT OF ALL THIS                04400000
         LTR   R15,R15        TEST IT                                   04410000
         BZ    CHECKOUT       IT GETS EXCLUDED                          04420000
LIMEND   DS    0H                                                       04430000
         B     CHECKIN        ALL TESTS PASSED, INCLUDE THIS ONE        04440000
         SPACE 5                                                        04450000
*                                                                       04460000
*        EVALUATION ROUTINE FOR   KEYWORD  OPER  VALUE                  04470000
*                                                                       04480000
LIMEVAL  L     R5,REFKEY      GET THE KEYWORD VALUE                     04490000
         MH    R5,H12         MULTIPLY IT BY 12                         04500000
         A     R5,ATABTITL    THEN RELOCATE IT                          04510000
*        SR    R10,R10        CLEAR THE ROUTINE POINTER            022G 04520000
         SR    R2,R2          CLEAR THE ROUTINE POINTER            022G 04521000
         TM    1(R5),X'80'    IS IT A FORMATTED ITEM?                   04530000
         BO    LIMFORM        YES, GO DO IT                             04540000
         SR    R6,R6          CLEAR A REGISTER                          04550000
         IC    R6,2(R5)       GET THE OFFSET INTO VTFMT                 04560000
*        IC    R10,1(R5)      GET THE ROUTINE NUMBER               022G 04571000
         IC    R2,1(R5)       GET THE ROUTINE NUMBER               022G 04572000
*        LTR   R10,R10        SEE IF IT'S A GOOD NUMBER            022G 04580000
         LTR   R2,R2          SEE IF IT'S A GOOD NUMBER            022G 04581000
         BP    LIMEVAL1       IT'S ALL RIGHT                            04590000
LIMABEND ABEND 702,DUMP       CRASH AND BURN                            04600000
*IMEVAL1 B     *(R10)         AND GO TO IT                         022G 04610000
LIMEVAL1 B     *(R2)          AND GO TO IT                         022G 04611000
         B     LIMDATE      4 CDATE, EXPDT, LAST USE DATES.        015G 04620000
         B     LIMCCHH      8 CCHH CHECKING.                       016G 04630000
         B     LIMFORM     12 FORM , USED SPACE                         04640000
         B     LIMFORM     16 UNUSED SPACE                              04650000
         B     LIMFORM     20 PCT USED                                  04660000
         B     LIMEXT      24 EXTENTS                                   04670000
         B     LIMBLREC    28 LRECL, BLKSZ, SEC Q                       04680000
*        B     LIMCCHH     32 CCHH CHECKING                        016G 04690000
         B     LIMFORM     32 DSN CHECKING.                        016G 04700000
         B     LIMKEYLE    36 KEY LENGTH CHECKING.                 023G 04702000
         SPACE 5                                                        04710000
*                                                                       04720000
*        PERFORM THE FORMATTED ITEM CHECKING                            04730000
*                                                                       04740000
LIMFORM  DS    0H                                                       04750000
         TM    VTCFMTCK,VTCFMTCC  WAS FORMAT CALLED BEFORE FOR THIS DS  04760000
         BO    LIMFCALD       YES, DON'T CALL IT AGAIN                  04770000
         VTCALL FORM          NO, CALL IT TO GET THE ITEMS              04780000
         OI    VTCFMTCK,VTCFMTCC+VTCFMTCD  THEN SET THE SWITCHES        04790000
*IMFCALD SR    R2,R2          CLEAR A WORK REG                     022G 04800000
LIMFCALD DS    0H                                                  022G 04801000
         A     R6,FORMATAD   RELOCATE THE BLOCK                         04810000
*        B     *+4(R10)         AND GO TO IT                       022G 04820000
         B     *+4(R2)          AND GO TO IT                       022G 04821000
         B     LIMFORMA     0 FORMATTED ITEM                            04830000
         B     LIMABEND     4 CDATE, EXPDT, LAST USE DATE.         015G 04840000
         B     LIMABEND     8 CCHH.                                016G 04850000
         B     LIMALLOC    12 ALLOC, USED SPACE                         04860000
         B     LIMUNUSD    16 UNUSED SPACE                              04870000
         B     LIMPCT      20 PCT USED                                  04880000
         B     LIMABEND    24 EXTENTS                              016G 04890000
         B     LIMABEND    28 LRECL, BLKSZ, SECQ                   016G 04900000
         B     LIMDSN      32 DSNAME                               016G 04910000
LIMFORMA DS    0H                                                       04920000
         SR    R2,R2          CLEAR A WORK REG                     022G 04921000
         IC    R2,2(R5)       GET THE OFFSET IN VTFMT                   04930000
         A     R2,FORMATAD    THEN RELOCATE IT                          04940000
         L     R4,REFVAL      GET THE VALUE PDE                         04950000
         LH    R3,4(R4)       GET THE LENGTH OF THE STRING              04960000
         L     R1,0(R4)       AND ITS ADDRESS                           04970000
*                                                                       04980000
*        DO THE ACTUAL COMPARE                                          04990000
*                                                                       05000000
         BCTR  R3,0           DOWN ONE FOR AN EX                        05010000
         EX    R3,COMPLIM     COMPARE AS SPECIFIED                      05020000
COMPDONE DS    0H             GET THE OPERATOR ADDRESS                  05030000
         BL    COMPLOW        CHECK THE OPERATOR, VALUE LESS THAN ITEM  05040000
         BE    COMPEQ         CHECK THE OPERATOR, KEYWORD EQUALS VALUE  05050000
*                             KEYWORD IS GREATER THAN THE VALUE         05060000
COMPHI   CLI   REFOPER+3,NE       WAS OPERATOR NE                       05070000
         BE    COMPYES        HIGH SATISFIES THE EXPRESSION             05080000
         CLI   REFOPER+3,GT       ALSO FOR GT                           05090000
         BE    COMPYES        HIGH SATISFIES THE EXPRESSION             05100000
         CLI   REFOPER+3,GE       AND FOR GE                            05110000
         BE    COMPYES        HIGH SATISFIES THE EXPRESSION             05120000
         B     COMPNO         THIS ONE DOESN'T FIT                      05130000
*                             KEYWORD IS EQUAL TO THE VALUE             05140000
COMPEQ   CLI   REFOPER+3,EQ       WAS OPERATOR EQ                       05150000
         BE    COMPYES        EQ   SATISFIES THE EXPRESSION             05160000
         CLI   REFOPER+3,LE       ALSO FOR LE                           05170000
         BE    COMPYES        EQ   SATISFIES THE EXPRESSION             05180000
         CLI   REFOPER+3,GE       AND FOR GE                            05190000
         BE    COMPYES        EQ   SATISFIES THE EXPRESSION             05200000
         B     COMPNO         THIS ONE DOESN'T FIT                      05210000
*                             KEYWORD IS LESS THAN THE VALUE            05220000
COMPLOW  CLI   REFOPER+3,NE       WAS OPERATOR NE                       05230000
         BE    COMPYES        LOW  SATISFIES THE EXPRESSION             05240000
         CLI   REFOPER+3,LT       ALSO FOR LT                           05250000
         BE    COMPYES        LOW  SATISFIES THE EXPRESSION             05260000
         CLI   REFOPER+3,LE       AND FOR LE                            05270000
         BE    COMPYES        LOW  SATISFIES THE EXPRESSION             05280000
         B     COMPNO         THIS ONE DOESN'T FIT                      05290000
*                                                                       05300000
*        IT FITS OR IT DOESN'T                                          05310000
*                                                                       05320000
COMPYES  LA    R15,1          SET A TRUE VALUE                          05330000
         BR    R8             THEN RETURN                               05340000
COMPNO   SR    R15,R15        SET A FALSE VALUE                         05350000
         BR    R8             THEN RETURN                               05360000
*                                                                       05370000
*        SPECIAL ROUTINES TO CHECK NON-FORMATTED ITEMS                  05380000
*                                                                       05390000
LIMDATE  DS    0H                                                       05400000
*                                                                       05410000
*        COMPARE DATES                                                  05420000
*                                                                       05430000
         LA    R14,DS1CREDT        POINT TO CREATION DATE.         015G 05440000
         CLI   REFKEY+3,CDATE      IS THAT WHAT I'M COMPARING?     015G 05450000
         BE    LIMDGET             YES, USE IT.                    015G 05460000
         LA    R14,DS1EXPDT        NO, POINT TO EXPIRATION DATE.   015G 05470000
         CLI   REFKEY+3,EXPDT      IS THAT WHAT I'M COMPARING?     015G 05480000
         BE    LIMDGET             YES, USE IT.                    015G 05490000
         LA    R14,DS1REFD         NO, USE LAST REFERENCED DATE.   015G 05500000
LIMDGET  SR    R15,R15       CLEAR A WORK REG                           05510000
         IC    R15,0(R14)    GET THE YEAR                               05520000
         MH    R15,H1000     TIMES 1000                                 05530000
         SR    R1,R1         CLEAR ANOTHER WORK REG                     05540000
         ICM   R1,3,1(R14)    GET THE DAYS                              05550000
         AR    R15,R1        PUT THE DATE TOGETHER                      05560000
         L     R1,REFNUM     GET THE ADDRESS OF THE VALUE               05570000
         L     R1,0(R1)      GET THE VALUE ITSELF                       05580000
         LTR   R1,R1         SEE IF NON-NUMERIC.                   021G 05590000
         BNZ   COMPDATE      NON-ZERO MEANS NUMERIC DATE PRESENT.  021G 05600000
*                            ZERO MEANS NON-NUMERIC DATE PRESENT.  021G 05610000
         L     R2,REFVAL     GET THE VALUE PDE.                    021G 05620000
         L     R3,0(R2)      GET A(STRING).                        021G 05630000
         CLI   0(R3),C'*'    SEE IF CURRENT DATE SHOULD BE USED.   021G 05640000
         BE    LIMDGET1      YES, GET SYSTEM CURRENT DATE.         021G 05650000
         VTOCMSG BADDATE     ONLY NUMERIC OR * ALLOWED ISSUE MSG   021G 05651000
LIMDGET1 L     R4,CVTPTR     GET A(CVT).                           021G 05660000
         USING CVTMAP,R4     TELL ASSEMBLER.                       021G 05670000
         XC    CHEKDBLW,CHEKDBLW CLEAR WORK AREA.                  021G 05680000
         MVC   CHEKDBLW+4(4),CVTDATE   MOVE CURRENT DATE.          021G 05690000
         DROP  R4            UNTELL ASSEMBLER.                     021G 05700000
         CVB   R1,CHEKDBLW   CONVERT CURRENT DATE TO BINARY.       021G 05710000
         LH    R4,4(R2)      GET L(STRING).                        021G 05720000
         CH    R4,H3         SEE IF ADD'L INFO.                    021G 05730000
         BL    COMPDATE      NO, GO COMPARE DATES.                 021G 05740000
         LA    R3,1(R3)      POINT A(STRING) PAST *.               021G 05750000
         ST    R3,0(R2)      RESET A(STRING) IN PDL.               021G 05760000
         BCT   R4,0          DECREMENT L(STRING) BY ONE.           021G 05770000
         ST    R4,4(R2)      RESET L(STRING) IN PDL.               021G 05780000
         LR    R1,R2         POINT TO VALUE PDL.                   021G 05790000
         LR    R2,R15        SAVE KEYWORD DATE VALUE.              021G 05800000
         LR    R3,R1         SAVE CURRENT DATE VALUE.              021G 05810000
         BAL   R8,PDLNUM     GO CONVERT IT.                        021G 05820000
         AR    R15,R3        CURRENT DATE + OFFSET NUMBER OF DAYS. 021G 05830000
         LR    R1,R15        SET UP REFVALUE DATE FOR COMPARE.     021G 05840000
         LR    R15,R2        SET UP KEYWORD DATE VALUE FOR COMPARE.021G 05850000
COMPDATE CR    R15,R1        COMPARE DATES.                        021G 05860000
         B     COMPDONE      GO CHECK OPERANDS.                         05870000
*IMLUSE  DS    0H                                                  015G 05880000
*                                                                       05890000
*        LAST USE DATE   --- MODIFIED FOR MVS SU60.                002S 05900000
*                                                                       05910000
*        LA    R14,75(,R7)   POINT TO THE DATE-LAST-USE FIELD  002S015G 05920000
*        B     LIMDGET       USE THE STANDARD DATE TEST LOGIC  002S015G 05930000
*                                                                  002S 05940000
**       THE ORIGINAL CODE BELOW INVALID WITH MVS SU60 (GIVES 0C7) 002S 05950000
*                                                                  002S 05960000
*        SR    R14,R14       CLEAR THE DATE                             05970000
*        CLC   ZERO,75(R7)   CHECK FOR NO DATA                          05980000
*        BE    LIMLUCMP      RIGHT, SKIP ON                             05990000
*        MVC   CHEKDBLW+5(3),75(R7)  MOVE IN THE LAST USE DATE          06000000
*        CVB   R14,CHEKDBLW  CONVERT IT TO BINARY                       06010000
*LIMLUCMP L    R1,REFNUM     GET THE ADDRESS OF THE VALUE               06020000
*        L     R1,0(R1)      GET THE VALUE                              06030000
*        CR    R14,R1        DO THE COMPARE                             06040000
*        B     COMPDONE      THEN CHASE DOWN THE OPERANDS               06050000
LIMEXT   DS    0H                                                       06060000
*                                                                       06070000
*        EXTENTS                                                        06080000
*                                                                       06090000
         L     R1,REFNUM     GET THE COMPARE VALUE ADDRESS              06100000
         CLC   DS1NOEPV,3(R1)        COMPARE THEM                       06110000
         B     COMPDONE      GO CHECK OPERANDS                          06120000
LIMBLREC DS    0H                                                       06130000
*                                                                       06140000
*        LRECL, BLKSZ, SECQ                                             06150000
*                                                                       06160000
         L     R1,REFNUM     GET THE ADDRESS OF THE COMPARE VALUE       06170000
         L     R15,0(R1)      THEN GET THE VALUE ITSELF                 06180000
         CLI   REFKEY+3,BLKSZ      BLOCK SIZE?                          06190000
         BNE   LIMB1         NO, KEEP CHECKING                          06200000
         LH    R1,DS1BLKL    COMPARE TO THE BLOCK SIZE                  06210000
         CR    R1,R15        COMPARE THEM                               06220000
         B     COMPDONE      GO SIFT THROUGH THE OPERANDS               06230000
LIMB1    CLI   REFKEY+3,LRECL  LOGICAL RECORD LENGTH                    06240000
         BNE   LIMB2         NO, KEEP GOING                             06250000
         LH    R1,DS1LRECL   COMPARE TO THE LRECL                       06260000
         CR    R1,R15        COMPARE THEM                               06270000
         B     COMPDONE      GO CHECK THE OPERANDS                      06280000
LIMB2    MVC   HWORK,DS1SCALO+2 GET THE SECONDARY QUANTITY              06290000
         LH    R1,HWORK      DO THE COMPARE                             06300000
         CR    R1,R15        COMPARE THEM                               06310000
         B     COMPDONE      THEN CHECK THE OPERANDS                    06320000
*                                                                  023G 06322000
*        KEY LENGTH                                                023G 06323000
*                                                                  023G 06324000
LIMKEYLE DS    0H                                                  023G 06324100
         L     R1,REFNUM     GET THE COMPARE VALUE ADDRESS         023G 06325000
         CLC   DS1KEYL,3(R1) COMPARE THEM                          023G 06326000
         B     COMPDONE      GO CHECK OPERANDS                     023G 06327000
*                                                                       06330000
*        SPACE CHECKING ROUTINES                                        06340000
*                                                                       06350000
LIMALLOC DS    0H                                                       06360000
*                                                                       06370000
*        ALLOC AND USED                                                 06380000
*                                                                       06390000
         SR    R2,R2          CLEAR A WORK REG                     022G 06391000
         L     R1,REFNUM     GET THE ADDRESS OF THE CONVERTED NUMBER    06400000
         L     R1,0(R1)      GET THE VALUE                              06410000
         L     R15,0(R6)     GET THE AMOUNT                             06420000
         CR    R15,R1        COMPARE THEM                               06430000
         B     COMPDONE      THEN CHECK THE OPERANDS                    06440000
LIMUNUSD DS    0H                                                       06450000
*                                                                       06460000
*        UNUSED                                                         06470000
*                                                                       06480000
         SR    R2,R2          CLEAR A WORK REG                     022G 06481000
         L     R6,FORMATAD   POINT TO THE FORMATTED VTOC                06490000
         USING VTFMT,R6      SET ADDRESSABILITY                         06500000
         ICM   R14,15,VTFUSED      GET THE AMOUNT USED                  06510000
         BM    LIMUNUAL      IF MINUS, WE DON'T KNOW                    06520000
         L     R14,VTFALLOC  GET ALLOC                                  06530000
         S     R14,VTFUSED   MINUS THE AMOUNT USED                      06540000
LIMUNUAL L     R1,REFNUM     GET THE ENTERED VALUE                      06550000
         L     R1,0(R1)      NOW ITS VALUE FOR REAL                     06560000
         CR    R14,R1        COMPARE THE VALUES                         06570000
         B     COMPDONE      THEN GO CHECK THE OPERANDS                 06580000
LIMPCT   DS    0H                                                       06590000
*                                                                       06600000
*        PER CENT                                                       06610000
*                                                                       06620000
         SR    R2,R2          CLEAR A WORK REG                     022G 06621000
         L     R6,FORMATAD   POINT TO THE FORMATTED VTOC                06630000
         USING VTFMT,R6      SET ADDRESSABILITY                         06640000
         SR    R14,R14       CLEAR A REGISTER                           06650000
         ICM   R15,15,VTFUSED      GET THE AMOUNT USED                  06660000
         BM    LIMP100       IF UNKNOWN USED, SET 100 PER CENT          06670000
         CLC   VTFALLOC,ZERO ZERO ALLOCATED SPACE?                      06680000
         BNE   LIMPCTOK      NO, CONTINUE                               06690000
         CLC   VTFUSED,ZERO  ZERO USED SPACE?                           06700000
         BE    LIMPCOMP      YES, PCT IS ZERO                           06710000
*              ZERO ALLOCATED, NONZERO USED, INCLUDE THIS ONE           06720000
         B     COMPYES                                                  06730000
LIMP100  LA    R15,100       SET UP 100 PER CENT                        06740000
         B     LIMPCOMP      GO COMPARE                                 06750000
LIMPCTOK M     R14,F100      MULTIPLY BY 100 PERCENT                    06760000
         D     R14,VTFALLOC  DIVIDE BY THE ALLOCATION                   06770000
LIMPCOMP L     R1,REFNUM     GET THE VALUE ADDRESS                      06780000
         L     R1,0(R1)      THEN THE VALUE                             06790000
         CR    R15,R1        THEN COMPARE THEM                          06800000
         B     COMPDONE      THEN GO SIFT THROUGH THE OPERANDS          06810000
LIMDSN   DS    0H                                                  016G 06821000
*                                                                  016G 06830000
*        DSNAME CHECKING                                           016G 06840000
*                                                                  016G 06850000
         SR    R2,R2          CLEAR A WORK REG                     022G 06851000
         MVI   HOLDSDSN,C' '             CLEAR HOLD AREA.          016G 06860000
         MVC   HOLDSDSN+1(43),HOLDSDSN   CLEAR HOLD AREA.          016G 06870000
         MVI   HOLDVDSN,C' '             CLEAR HOLD AREA.          016G 06880000
         MVC   HOLDVDSN+1(43),HOLDVDSN   CLEAR HOLD AREA.          016G 06890000
         L     R6,FORMATAD    POINT TO THE FORMATTED VTOC.         016G 06900000
         USING VTFMT,R6       SET ADDRESSABILITY.                  016G 06910000
         SR    R2,R2          CLEAR WORK REG.                      016G 06920000
         LH    R2,VTFDSNL     GET THE LENGTH OF DSNAME.            016G 06930000
         BCTR  R2,0           DOWN ONE FOR AN EX.                  016G 06940000
         LA    R1,VTFDSN      GET A(VTFDSN).                       016G 06950000
         EX    R2,MOVEVDSN    MOVE VTFDSN TO WORK AREA.            016G 06960000
         L     R4,REFVAL      GET THE VALUE PDE.                   016G 06970000
         LH    R2,4(R4)       GET THE LENGTH OF THE STRING.        016G 06980000
         BCTR  R2,0           DOWN ONE FOR AN EX.                  016G 06990000
         L     R1,0(R4)       GET A(STRING).                       016G 07000000
         EX    R2,MOVESDSN    MOVE STRING TO WORK AREA.            016G 07010000
         LA    R1,HOLDSDSN    GET A(STRING DSN).                   016G 07020000
         LA    R2,HOLDVDSN    GET A(STRING DSN).                   016G 07030000
         LA    R3,43          SET L(STRING VS VTFDSN COMPARE).     016G 07040000
         EX    R3,COMPLIM     COMPARE AS SPECIFIED.                016G 07050000
         B     COMPDONE       YES, DO STANDARD COMPARISON.         016G 07060000
*                                                                       07070000
*        CCHH CHECKING IS NOT QUITE STANDARD BECAUSE THERE MAY          07080000
*        MAY BE UP TO 127 EXTENTS TO COMPARE.  THE DATA MAY BE     017G 07090000
*        CC OR CCHH FORMATS.  THE DATA SET MAY BE EQUAL TO,             07100000
*        LESS THAN, AND GREATER THAN ANY PARTICULAR VALUE.              07110000
*                                                                       07120000
LIMCCHH  DS    0H                                                       07130000
*                                                                       07140000
*        FIRST SEE IF THE CCHH WAS CONVERTED                            07150000
*              CONVERT IT IF NOT, SKIP IF IT'S DONE                     07160000
*                                                                       07170000
         L     R5,REFNUM     GET THE ADDRESS OF THE COMPARISON VALUE    07180000
         L     R4,0(R5)      GET THE VALUE                              07190000
         ICM   R6,3,4(R5)    GET THE COMPARE LENGTH                     07200000
         BP    LIMCSET       IF IT'S SET, THE CONVERSION IS DONE        07210000
*                      IT WASN'T SET, CONVERT FROM CHARS TO BINARY      07220000
         L     R1,REFVAL     GET THE ADDRESS OF THE IKJIDENT            07230000
         L     R2,0(R1)      POINT TO THE TEXT                          07240000
         LH    R3,4(R1)      GET THE LENGTH OF THE TEXT                 07250000
*        IT SHOULD BE 4 OR 8 CHARACTERS                                 07260000
         XC    DOUBLE,DOUBLE CLEAR OUT A PLACE TO WORK                  07270000
         CH    R3,H4         IS IT A CYLINDER ONLY?                     07280000
         BH    LIMCCON2      NO, TRY FOR A CCHH                         07290000
         BE    LIMCCON1      YES, JUST CONVERT IT                       07300000
         VTOCMSG CCHHLEN     LESS THAN FOUR CHARS, ISSUE A MSG          07310000
LIMCCON1 LA    R6,1          SET THE COMPARE LENGTH                     07320000
         B     LIMCMOVE      GO MOVE IT IN                              07330000
LIMCCON2 LA    R6,3          SET THE COMPARE LENGTH                     07340000
         CH    R3,H8         WAS IT A CCHH?                             07350000
         BE    LIMCMOVE      YES, JUST THE RIGHT LENGTH                 07360000
         VTOCMSG CCHHLEN     WARN THE PERSON                            07370000
         CH    R3,H8         CHECK AGAIN                                07380000
         BL    LIMCMOVE      IS IT OVER 8 CHARS?                        07390000
         LH    R3,H8         YES, SET IT FOR THE MAX - IGNORE RR        07400000
LIMCMOVE BCTR  R3,0          MINUS ONE FOR THE EX                       07410000
         EX    R3,MOVECCHH   MOVE IN THE CHARS                          07420000
         TR    DOUBLE,DECTABLE TRANSLATE HEX EBCDIC TO HEX BINARY       07430000
         PACK  CYLH(5),DOUBLE(9)  SQUISH OUT THE ZONES                  07440000
         L     R4,CYLH       GET THE CCHH                               07450000
         ST    R4,0(R5)      SAVE IT FOR LATER                          07460000
         STH   R6,4(R5)      SAVE THE LENGTH TOO                        07470000
LIMCSET  DS    0H            THE NUMBER IS CONVERTED                    07480000
*                                                                       07490000
*        COMPARE THE EXTENTS TO THE CCHH VALUE.                         07500000
*        ANY EXTENT MAY BE LT, EQ, AND GT A PARTICULAR                  07510000
*        VALUE, AND ALL THE EXTENTS MUST BE CHECKED.                    07520000
*                                                                       07530000
         MVI   CCHHCOMP,0    CLEAR THE FLAGS                            07540000
         SR    R2,R2         CLEAR A REG FOR AN EXTENT COUNTER          07550000
         ICM   R2,1,DS1NOEPV GET THE NUMBER OF EXTENTS                  07560000
         BZ    COMPNO        NO EXTENTS, JUST GO SEE                    07570000
*                                                                       07580000
*        GET EACH EXTENT AND PROCESS IT                                 07590000
*                                                                       07600000
*        SR    R1,R1         FIRST EXTENT                          017G 07610000
*XTNEXT  LR    R3,R1         GET THE CURRENT EXTENT                017G 07620000
*        SLL   R3,2          TIMES 4                               017G 07630000
*        EX    R0,GETEXT(R3) GET THE EXTENT ADDRESS INTO R3        017G 07640000
         SR    R1,R1         FIRST EXTENT                          017G 07650000
EXTNEXT  LR    R3,R1         GET THE CURRENT EXTENT                017G 07660000
         CH    R3,H2         IS IT IN FMT1 DSCB?                   017G 07670000
         BH    EXTFMT3       NO, IT'S IN FMT3 DSCB.                017G 07680000
         SLL   R3,2          TIMES 4                               017G 07690000
         EX    R0,GETEXT(R3) GET THE EXTENT ADDRESS INTO R3        017G 07700000
         B     EXTGOT                                              017G 07710000
EXTFMT3  DS    0H            MUST PROCESS FMT3 DIFFERENTLY.        017G 07720000
         SH    R3,H3         MAKE IT RELATIVE TO BEGIN FMT3.       017G 07730000
         MH    R3,H10        CALCULATE OFFSET FROM BEGIN FMT3.     017G 07740000
         LA    R3,FMT3(R3)   GET A(CURRENT EXT).                   017G 07750000
EXTGOT   DS    0H            GOT A(EXTENT).                        017G 07760000
*                                                                       07770000
*        CHECK THE BOTTOM OF THE EXTENT                                 07780000
*                                                                       07790000
         NI    CCHHCOMP,255-CCHHX TURN OFF THE STRADDLE FLAG            07800000
         EX    R6,CLCEXTLO    DO THE COMPARE                            07810000
         BH    SETH1         THE FIELD IS HIGHER THAN THE VALUE         07820000
         BE    SETEQ1        THE FIELD IS EQUAL TO THE VALUE            07830000
         OI    CCHHCOMP,CCHHLOW+CCHHX  LOWER -  POSSIBLE STRADDLE       07840000
         B     CHECKHI       GO CHECK THE TOP OF THIS EXTENT            07850000
SETH1    OI    CCHHCOMP,CCHHHIGH  SET THE FLAG                          07860000
         B     CHECKHI       GO CHECK THE TOP OF THIS EXTENT            07870000
SETEQ1   OI    CCHHCOMP,CCHHEQ   SET THE FLAG                           07880000
*                                                                       07890000
*        CHECK THE TOP OF THE EXTENT                                    07900000
*                                                                       07910000
CHECKHI  EX    R6,CLCEXTHI   DO THE COMPARE                             07920000
         BE    SETEQ2        EQUAL, GO SET IT                           07930000
         BL    EXTSET        LOW, GO SET IT                             07940000
*                                                                       07950000
*        THIS IS THE ONLY SLIGHTLY TRICKY PART, A STRADDLE              07960000
*        IF THE BOTTOM OF THE EXTENT IS LOWER THAN THE VALUE AND THE    07970000
*        TOP OF THE EXTENT IS HIGHER THAN THE VALUE, THEN THE           07980000
*        EQ FLAG SHOULD BE SET TOO.                                     07990000
*                                                                       08000000
         OI    CCHHCOMP,CCHHHIGH  SET THE HIGH FLAG                     08010000
         TM    CCHHCOMP,CCHHX     WAS THE BOTTOM LOWER THAN THE VALUE?  08020000
         BZ    EXTSET        NO, SKIP ON                                08030000
SETEQ2   OI    CCHHCOMP,CCHHEQ    SET THE EQ FLAG                       08040000
*                                                                       08050000
*        FINISHED WITH THAT EXTENT, CHECK FOR MORE                      08060000
*                                                                       08070000
EXTSET   DS    0H                                                       08080000
         LA    R1,1(R1)      INCREMENT THE EXTENT COUNTER               08090000
         CR    R1,R2         CHECK THE EXTENT COUNTER                   08100000
         BNL   LIMCOPER      THAT'S ALL FOLKS                           08110000
         TM    CCHHCOMP,CCHHHIGH+CCHHEQ+CCHHLOW  ARE THEY ALL SET?      08120000
         BNO   EXTNEXT       NO, CONTINUE LOOKING                       08130000
*                            YES, STOP NOW - ALL THE FLAGS ARE SET      08140000
LIMCOPER L     R4,REFOPER    GET THE NUMERIC VALUE OF THE KEY           08150000
         IC    R4,CCHHTAB(R4)  GET A FLAG MASK                          08160000
         EX    R4,CCHHOPER   CHECK TO SEE IF THE CONDITION IS SET       08170000
         BZ    COMPNO        NOT THERE                                  08180000
         B     COMPYES       YES                                        08190000
*                                                                       08200000
*        EXECUTED INSTRUCTIONS TO GET THE ADDRESS OF THIS EXTENT        08210000
*                                                                       08220000
GETEXT   LA    R3,DS1EXT1     1ST EXTENT                                08230000
         LA    R3,DS1EXT2     2ND EXTENT                                08240000
         LA    R3,DS1EXT3     3RD EXTENT                                08250000
*        LA    R3,DS3EXTNT    4TH EXTENT                           017G 08260000
*        LA    R3,DS3EXTNT+10 5TH EXTENT                           017G 08270000
*        LA    R3,DS3EXTNT+20 6TH EXTENT                           017G 08280000
*        LA    R3,DS3EXTNT+30 7TH EXTENT                           017G 08290000
*        LA    R3,DS3ADEXT    8TH EXTENT                           017G 08300000
*        LA    R3,DS3ADEXT+10 9TH EXTENT                           017G 08310000
*        LA    R3,DS3ADEXT+20 10TH EXTENT                          017G 08320000
*        LA    R3,DS3ADEXT+30 11TH EXTENT                          017G 08330000
*        LA    R3,DS3ADEXT+40 12TH EXTENT                          017G 08340000
*        LA    R3,DS3ADEXT+50 13TH EXTENT                          017G 08350000
*        LA    R3,DS3ADEXT+60 14TH EXTENT                          017G 08360000
*        LA    R3,DS3ADEXT+70 15TH EXTENT                          017G 08370000
*        LA    R3,DS3ADEXT+80 16TH EXTENT                          017G 08380000
*                                                                       08390000
*        SAVE FMT4 (VTOC) AND FMT6 EXTENT INFO                          08400000
*                                                                       08410000
*                                      FMT4 ALREADY ADDED TO MAP.  005G 08420000
GOTFMT4  MVI   VTCCFUNC,0              INDICATE NO FMT5 PROCESSED. 005G 08430000
         CLC   DS4F6PTR,=XL5'0000000000'  IS THERE A FMT6?         005G 08440000
         BE    CHECKOUT                 NO, SKIP ALONG.            005G 08450000
         LA    R1,DS4F6PTR             YES, GET A(CCHHR ADDRESS).  005G 08460000
FMT6GET  L     R7,DSCBADDR             GET A(AREA TO READ INTO).   005G 08470000
         LA    R7,8(R7)                BUMP PAST HEADER AREA.      005G 08480000
         DROP  R7                                                       08490000
         USING FMT6DSEC,R7             TELL ASSEMBLER.             005G 08500000
         LR    R15,R7                  GET A(AREA TO READ INTO).   005G 08510000
         BAL   R2,OBTAINIT             GET THE RECORD.             005G 08520000
         LTR   R15,R15                 TEST THE RETURN CODE.       005G 08530000
         BNZ   OBT6ERR                 BAD NEWS, ISSUE MESSAGE.    005G 08540000
         VTOCMAP ADD                   ADD SPLIT EXTENT TO MAP.    005G 08550000
         CLC   DS6PTRDS,=XL5'0000000000' IS THERE ANOTHER FMT6?    005G 08560000
         BE    CHECKOUT                NO, SKIP ALONG.             005G 08570000
         LA    R1,DS6PTRDS             YES, GET THE CCHHR ADDRESS. 005G 08580000
         B     FMT6GET                 GET THE NEXT FMT6.          005G 08590000
*                                                                       08600000
*        SAVE FMT5 EXTENT INFO                                          08610000
*                                                                       08620000
GOTFMT5  CLI   VTCCFUNC,0              HAVE ALL FMT5 BEEN PROCESSD.005G 08630000
         BNE   CHECKOUT                YES.                        005G 08640000
         MVI   VTCCFUNC,1              INDICATE FMT5 ALL PROCESSED.005G 08650000
NEXTFMT5 VTOCMAP ADD                   ADD FREE EXTENT TO MAP.     005G 08660000
         DROP  R7                                                       08670000
         USING FMT5DSEC,R7             TELL ASSEMBLER.             005G 08680000
         L     R7,DSCBADDR             GET A(FMT5 JUST GOTTEN).    005G 08690000
         LA    R7,8(R7)                BUMP PAST HEADER.           005G 08700000
         CLC   DS5PTRDS,=XL5'0000000000'  IS THERE ANOTHER FMT5?   005G 08710000
         BE    CHECKOUT                 NO, SKIP ALONG.            005G 08720000
         LA    R1,DS5PTRDS             YES, GET THE CCHHR ADDRESS. 005G 08730000
         LR    R15,R7                  GET A(AREA TO READ INTO).   005G 08740000
         BAL   R2,OBTAINIT             GET THE RECORD.             005G 08750000
         LTR   R15,R15                 TEST THE RETURN CODE        005G 08760000
         BNZ   OBT5ERR                 ERROR ON OBTAIN.            005G 08770000
         B     NEXTFMT5                SAVE EXTENT INFO.           005G 08780000
*                                                                       08790000
*        ISSUE ERROR MESSAGES AND RETURN                                08800000
*                                                                       08810000
OBT3ERR  MVC   MSGTEXT2,OBT3ERRM            MOVE MESSAGE.          007G 08820000
         MVC   MSGTEXT2+15(6),VOLID         MOVE VOLSER.           007G 08830000
         VTOCMSG MSGTEXT2                   ISSUE ERROR MESSAGE.   007G 08840000
         B     CHECKOUT                                            005G 08850000
OBT5ERR  MVC   MSGTEXT2,OBT5ERRM            MOVE MESSAGE.          007G 08860000
         MVC   MSGTEXT2+15(6),VOLID         MOVE VOLSER.           007G 08870000
         VTOCMSG MSGTEXT2                   ISSUE ERROR MESSAGE.   007G 08880000
         B     CHECKOUT                                            005G 08890000
OBT6ERR  MVC   MSGTEXT2,OBT6ERRM            MOVE MESSAGE.          007G 08900000
         MVC   MSGTEXT2+15(6),VOLID         MOVE VOLSER.           007G 08910000
         VTOCMSG MSGTEXT2                   ISSUE ERROR MESSAGE.   007G 08920000
         B     CHECKOUT                                            005G 08930000
CHECKOUT LA    R15,8          EXCLUDE THIS DATA SET                     08940000
         B     CHEKRET        RETURN                                    08950000
*                                                                       08960000
CHECKIN  SR    R15,R15        CLEAR THE REGISTER, PROCESS THIS DATA SET 08970000
CHEKRET  VTCLEAVE EQ                                               009G 08980000
*                                                                       08990000
*                                                                       09000000
         EJECT                                                          09010000
*                                                                       09020000
*        ROUTINES USED ABOVE                                            09030000
*                                                                       09040000
**************************************************************          09050000
*  ROUTINE TO OBTAIN A RECORD                                           09060000
* INPUT: R1=CCHHR OF RECORD TO OBTAIN                                   09070000
* CALLED VIA R2                                                         09080000
**************************************************************          09090000
OBTAINIT ST    R15,CAMSEEK+12  SAVE A(AREA FOR THE DSCB).          005G 09100000
         ST    R1,CAMSEEK+4    SAVE A(CCHHR TO SEEK).              005G 09110000
         MVC   CAMSEEK(4),CAMSCON      MOVE FIRST WORD OF CAMLST.  005G 09120000
         LA    R1,VOLID       POINT TO THE VOLUME SERIAL                09130000
         ST    R1,CAMSEEK+8   SAVE IT                                   09140000
         OBTAIN CAMSEEK       GET THE DSCB                              09150000
         BR    R2             RETURN TO CALLER.                    005G 09160000
         EJECT                                                          09170000
*                                                                       09180000
*        PDLNUM - CONVERT FROM CHARACTERS ( EBCDIC ) TO AN INTEGER      09190000
*              BINARY FORM, PASSED BACK VIA REGISTER 15                 09200000
*              A PARSE PDE IS THE INPUT AS SHOWN IN THE SAMPLE BELOW    09210000
*                       LA    R1,PDL     POINT TO THE PARSE DECRIPTION  09220000
*                       BAL   R8,PDLNUM  GO CONVERT TO NUMERICS         09230000
*              THE ROUTINE WILL TERMINATE IF IT FINDS NON-NUMERICS      09240000
*                 ANY CHARACTERS OTHER THEN 0-9, +, -                   09250000
*              REGISTERS 1, 2, 5, 6, AND 7 ARE USED                     09260000
*                                                                       09270000
PDLNUM   STM   R1,R8,PDLNSAVE SAVE THE REGISTERS                        09280000
         LH    R2,4(R1)       GET THE STRING LENGTH                     09290000
         L     R1,0(R1)       GET THE STRING ADDRESS                    09300000
         MVI   PDLMINUS,0     CLEAR THE NEGATIVE NUMBER FLAG            09310000
         SR    R5,R5          CLEAR THE CHARACTER COUNTER               09320000
         SR    R15,R15        CLEAR THE ANSWER                          09330000
PDLLOOP  LA    R6,0(R5,R1)    POINT TO THIS DIGIT                       09340000
         LA    R5,1(R5)       GET TO THE NEXT DIGIT                     09350000
         CR    R5,R2          IS THIS THE END OF THE STRING?            09360000
         BH    PDLFINI        YES, EXIT                                 09370000
         SR    R7,R7          CLEAR A WORK REGISTER                     09380000
         IC    R7,0(R6)       GET THE CHARACTER                         09390000
         SH    R7,PDLH240     SUBTRACT THE CHARACTER C'0'               09400000
         BM    PDLSP          IF NEGATIVE, CHECK SPECIAL CHARACTERS     09410000
         MH    R15,PDLH10     IT'S A DIGIT, MULTIPLY PRIOR NUM BY TEN   09420000
         AR    R15,R7         ADD ON THE NEW DIGIT                      09430000
         B     PDLLOOP        AND LOOP FOR MORE                         09440000
*                                                                       09450000
*        CHECK FOR SPECIAL CHARACTERS                                   09460000
*                                                                       09470000
PDLSP    CLI   0(R6),C' '     IS IT A BLANK?                            09480000
         BE    PDLLOOP        THEN IT'S OK                              09490000
         CLI   0(R6),C'+'     IS IT A PLUS?                             09500000
         BE    PDLLOOP        THAT'S ALSO OK                            09510000
         CLI   0(R6),C'-'     IS IT A MINUS?                            09520000
         BNE   PDLFINI        NO, JUST QUIT                             09530000
         MVI   PDLMINUS,1     YES, NOTE IT                              09540000
         B     PDLLOOP        AND LOOK FOR MORE                         09550000
*                                                                       09560000
*        QUIT, AFTER SETTING R15 TO NEGATIVE IF NEEDED                  09570000
*                                                                       09580000
PDLFINI  CLI   PDLMINUS,1     WAS A MINUS SIGN FOUND?                   09590000
         BNE   PDLLEAVE       NO, EXIT                                  09600000
         LNR   R15,R15        YES, MAKE IT NEGATIVE                     09610000
PDLLEAVE LM    R1,R8,PDLNSAVE RESTORE THE REGISTERS                     09620000
         BR    R8             RETURN                                    09630000
PDLH10   DC    H'10'                                                    09640000
PDLH240  DC    H'240'                                                   09650000
         EJECT                                                          09660000
*                                                                       09670000
*        ROUTINE TO CONVERT A TEXT DSCB ITEM                            09680000
*        INTO ITS KEY NUMBER                                            09690000
*        INPUT IS REG 4 - IKJIDENT PTR                                  09700000
*        OUTPUT IS REG 15 - KEY NUMBER                                  09710000
*        ENTRY VIA BAL   R8,GETKEY                                      09720000
*                                                                       09730000
GETKEY   L     R1,ATABTITL     POINT TO THE TABLE                       09740000
         LA    R1,12(R1)     POINT TO THE FIRST ENTRY                   09750000
         LA    R15,1           SET UP THE KEY NUMBER COUNTER            09760000
         L     R6,0(R4)      POINT TO THE ENTERED TEXT                  09770000
         ICM   R3,3,4(R4)    GET THE LENGTH OF THE ENTERED TEXT         09780000
         BNP   GETKNOTF      NOT FOUND IF ZERO                          09790000
         BCTR  R3,0          MINUS ONE FOR THE EX                       09800000
GETKLOOP LA    R2,4(R1)      POINT TO THE COMPARISON TEXT               09810000
         CLI   0(R2),C' '    IS IT HERE?                                09820000
         BNE   GETKSTD       YES, THIS IS IT                            09830000
         LA    R2,1(R2)      NO, MOVE OVER ONE MORE                     09840000
         CLI   0(R2),C' '    IS IT HERE?                                09850000
         BNE   GETKSTD       YES, THIS IS IT                            09860000
         LA    R2,1(R2)      NO, MOVE OVER ONE MORE                     09870000
GETKSTD  EX    R3,GETKCOMP   COMPARE THE KEY TEXT                       09880000
         BE    GETKFND       I FOUND IT                                 09890000
         LA    R1,12(R1)     GET TO THE NEXT KEY                        09900000
         LA    R15,1(R15)    INCREMENT THE KEY COUNTER                  09910000
*        CH    R15,H27       CHECK FOR THE END OF THE TABLE    012G024G 09920000
         CH    R15,H29       CHECK FOR THE END OF THE TABLE        024G 09921000
         BNH   GETKLOOP      NOT YET, KEEP LOOKING                      09930000
*                                                                       09940000
*        KEY WAS NOT FOUND, SEND BACK A ZERO                            09950000
*                                                                       09960000
GETKNOTF SR    R15,R15       SET UP THE ZERO AND RETURN                 09970000
GETKFND  BR    R8            JUST RETURN                                09980000
GETKCOMP CLC   0(0,R6),0(R2) EXECUTED TEXT COMPARE                      09990000
*H27      DC    H'27'         PREVIOUSLY 26.                   012G024G 10000000
H29      DC    H'29'         PREVIOUSLY 27.                        024G 10001000
         EJECT                                                          10010000
*                                                                       10020000
*        ROUTINE TO CONVERT THE OPERATOR TEXT                           10030000
*        INTO A NUMERIC VALUE                                           10040000
*                                                                       10050000
GETOPER  LA    R15,1         NUMERIC VALUE COUNTER                      10060000
GETOLOP1 LR    R14,R15       GET THE NUMBER                        014G 10070000
         SLA   R14,1         MULTIPLY BY 2                              10080000
         LA    R14,OPERS1(R14)     RELOCATE IT                     014G 10090000
         CLC   0(2,R14),0(R1)      IS THIS THE TEXT?                    10100000
         BE    GETOFND       YES, RETURN THE NUMBER                     10110000
         LA    R15,1(R15)    NO, TRY THE NEXT ONE                       10120000
         CH    R15,H7        CHECK FOR THE END                          10130000
         BL    GETOLOP1      NOT THERE YET, KEEP TRYING            014G 10140000
*        GIVE A SECOND TRY FOR OTHER WAYS OF SAYING OPER.          014G 10150000
         LA    R15,1         NUMERIC VALUE COUNTER                 014G 10160000
GETOLOP2 LR    R14,R15       GET THE NUMBER                        014G 10170000
         SLA   R14,1         MULTIPLY BY 2                         014G 10180000
         LA    R14,OPERS2(R14)     RELOCATE IT                     014G 10190000
         CLC   0(2,R14),0(R1)      IS THIS THE TEXT?               014G 10200000
         BE    GETOFND       YES, RETURN THE NUMBER                014G 10210000
         LA    R15,1(R15)    NO, TRY THE NEXT ONE                  014G 10220000
         CH    R15,H7        CHECK FOR THE END                     014G 10230000
         BL    GETOLOP2      NOT THERE YET, KEEP TRYING            014G 10240000
         VTOCMSG OPERERR,OPERERR2  ISSUE THE MESSAGE                    10250000
         LA    R15,1         SET THE DEFAULT OPERATOR, EQ               10260000
GETOFND  BR    R8            THEN RETURN                                10270000
         EJECT                                                          10280000
*                                                                       10290000
*        PROGRAM CONSTANTS                                              10300000
*                                                                       10310000
COMPLIM  CLC   0(0,R2),0(R1)      COMPARE KEYWORD TO VALUE              10320000
MOVEVDSN MVC   HOLDVDSN(0),0(R1)  MOVE VTFDSN TO WORK AREA.        016G 10330000
MOVESDSN MVC   HOLDSDSN(0),0(R1)  MOVE STRING TO WORK AREA.        016G 10340000
MOVECCHH MVC   DOUBLE(0),0(R2)                                          10350000
CLCEXTLO CLC   2(0,R3),0(R5)                                            10360000
CLCEXTHI CLC   6(0,R3),0(R5)                                            10370000
CCHHOPER TM    CCHHCOMP,0                                               10380000
CCHHTAB  DC    X'0040A0206080C0'  CCHHCOMP FLAGS                        10390000
OPERS1   DC    C'  EQNELTLEGTGE'                                   014G 10400000
OPERS2   DC    C'  = ¬=< <=> >='                                   014G 10410000
*    FOR  EQ, NE, LT, LE, GT, GE                                        10420000
PERIOD   DC    C'.'                                                019G 10430000
EDMASK   DC    XL16'40202020202020202020202020202120'                   10440000
BLANKS   DC    CL16'                '                                   10450000
STARS    DC    CL16'****************'                                   10460000
BLKTRTAB DC    XL64'00',X'04',XL192'00'                                 10470000
CAMSCON  CAMLST SEEK,*,*,*                                              10480000
COMPARE  CLC   0(0,R6),0(R2)  EXECUTED COMPARE                          10490000
DECTABLE EQU   *-C'A'   CONVERT EBCDIC HEX TO BINARY                    10500000
         DC    X'0A0B0C0D0E0F'                                          10510000
         DC    (C'0'-C'F'-1)X'FF'  FILLER                               10520000
         DC    X'00010203040506070809'                                  10530000
*                                                                       10540000
*                                                                       10550000
*                                                                       10560000
H2       DC    H'2'                                                017G 10570000
H3       DC    H'3'                                                     10580000
H4       DC    H'4'                                                     10590000
H7       DC    H'7'                                                     10600000
H8       DC    H'8'                                                     10610000
H10      DC    H'10'                                                    10620000
H12      DC    H'12'                                                    10630000
ZERO     DC    F'0'                                                     10640000
F100     DC    F'100'                                                   10650000
H1000    DC    H'1000'                                                  10660000
F127     DC    F'127'                                                   10670000
*                                                                       10680000
*                                                                       10690000
*                                                                       10700000
*        PROGRAM MESSAGES                                               10710000
*                                                                       10720000
* 001G 005G 006G 001G 005G 006G 021G BELOW 7 LINES CHANGED              10730000
OBT3ERRM VTCMSG ' VTOCCHEK -VVVVVV- ERROR IN OBTAIN ON FMT 3 DSCB '     10740000
OBT5ERRM VTCMSG ' VTOCCHEK -VVVVVV- ERROR IN OBTAIN ON FMT 5 DSCB '     10750000
OBT6ERRM VTCMSG ' VTOCCHEK -VVVVVV- ERROR IN OBTAIN ON FMT 6 DSCB '     10760000
KEYERR   VTCMSG ' VTOCCHEK - LIM, AND, OR OR SUBPARM ERROR - XXXXXX '   10770000
CCHHLEN  VTCMSG ' VTOCCHEK - CCHH SHOULD BE 4 OR 8 HEX CHARS '          10780000
OPERERR VTCMSG ' VTOCCHEK - OPERATOR WAS NOT EQ, NE, LT, LE, GT, OR GE' 10790000
OPERERR2 VTCMSG '          - ASSUMING EQ'                               10800000
BADDATE  VTCMSG ' VTOCCHEK - USE JULIAN DATE (YYDDD) OR *'              10801000
*                                                                       10810000
         EJECT                                                          10820000
*                                                                       10830000
*                                                                       10840000
*        P A R S E   C O N T R O L   L I S T                            10850000
*                                                                       10860000
*                                                                       10870000
         COPY  VTCPARS                                             009G 10880000
*                                                                       10890000
*        DYNAMIC WORK AREA                                              10900000
*                                                                       10910000
         SPACE 3                                                        10920000
CHEKWORK DSECT                                                          10930000
         DS    18A            PRINT ROUTINE SAVE AREA                   10940000
CHARS    DS    CL16           CONVERSION TO CHARACTERS                  10950000
CAMSEEK  CAMLST SEEK,*,*,*                                              10960000
CAMLEN   EQU   *-CAMSEEK                                                10970000
         DS    0D                                                       10980000
CYLH     DS    F                                                        10990000
         DS    X              PAD FOR CCHH                              11000000
EQ       EQU   1              EQUATES FOR OPERATOR VALUES               11010000
NE       EQU   2                                                        11020000
LT       EQU   3                                                        11030000
LE       EQU   4                                                        11040000
GT       EQU   5                                                        11050000
GE       EQU   6                                                        11060000
HWORK    DS    H                                                        11070000
LIMVAL   DS    F                                                        11080000
NUMBERL  DS    F                                                        11090000
NUMLENL  DS    H                                                        11100000
FLAGNML  DS    X                                                        11110000
NUMKEYL  DS    X                                                        11120000
NUMBER1  DS    F                                                        11130000
NUMLEN1  DS    H                                                        11140000
FLAGNM1  DS    X                                                        11150000
NUMKEY1  DS    X                                                        11160000
NUMBER2  DS    F                                                        11170000
NUMLEN2  DS    H                                                        11180000
FLAGNM2  DS    X                                                        11190000
NUMKEY2  DS    X                                                        11200000
NUMBER3  DS    F                                                        11210000
NUMLEN3  DS    H                                                        11220000
FLAGNM3  DS    X                                                        11230000
NUMKEY3  DS    X                                                        11240000
NUMBER4  DS    F                                                   013G 11250000
NUMLEN4  DS    H                                                   013G 11260000
FLAGNM4  DS    X                                                   013G 11270000
NUMKEY4  DS    X                                                   013G 11280000
NUMBER5  DS    F                                                   013G 11290000
NUMLEN5  DS    H                                                   013G 11300000
FLAGNM5  DS    X                                                   013G 11310000
NUMKEY5  DS    X                                                   013G 11320000
REFKEY   DS    F                                                        11330000
REFOPER  DS    F                                                        11340000
REFVAL   DS    A                                                        11350000
REFNUM   DS    A                                                        11360000
PDLNSAVE DS    8A             REGISTER SAVE AREA FOR PDLNUM RTN         11370000
PDLMINUS DC    X'00'                                                    11380000
CHEKDBLW DS    D                                                        11390000
CCHHCOMP DS    X                                                        11400000
CCHHHIGH EQU   X'80'                                                    11410000
CCHHEQ   EQU   X'40'                                                    11420000
CCHHLOW  EQU   X'20'                                                    11430000
CCHHX    EQU   X'08'                                                    11440000
HOLDVDSN DS    CL44                 TO EXPAND VTFDSN TO 44 BYTES.  016G 11450000
HOLDSDSN DS    CL44                 TO EXPAND STRING TO 44 BYTES.  016G 11460000
         DS    0D                                                       11470000
LENWORK  EQU   *-CHEKWORK                                               11480000
         VTOCMAP EQ                                                005G 11490000
*                                                                       11500000
*        VTOC COMMAND COMMON AREA                                       11510000
*                                                                       11520000
         VTCCOM                                                    009G 11530000
         SPACE 3                                                        11540000
*                                                                       11550000
*        FORMATTED DSCB                                                 11560000
*                                                                       11570000
         VTCFMT                                                    009G 11580000
         SPACE 3                                                        11590000
         VTCPDEDS                                                  009G 11600000
         SPACE 3                                                        11610000
         SPACE 3                                                        11620000
FMT1DSEC DSECT                                                     005G 11630000
         IECSDSL1 (1)                                                   11640000
FMT3DSEC DSECT                                                     017G 11650000
         IECSDSL1 (3)                                                   11660000
FMT5DSEC DSECT                                                     005G 11670000
         IECSDSL1 (5)                                                   11680000
FMT6DSEC DSECT                                                     005G 11690000
         IECSDSL1 (6)                                                   11700000
         CVT   DSECT=YES                                           021G 11710000
         END                                                            11720000
