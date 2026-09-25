         TITLE 'VTOCMAP - VTOC MAPPING SUBROUTINE'                      00010000
*********************************************************************** 00020000
*        SPACE                                                          00030000
* AUTHOR;  MATT GATES                                                   00040000
* NUMBER    DATE    PERSON    REASON                                    00050000
*  000G    110883   GATES     FIRST WRITING OF CODE.                    00060000
*  001G    050284   GATES     RENAME VTOCOM MACRO TO VTCCOM,            00070000
*                              RENAME VTLEAVE MACRO TO VTCLEAVE,        00080000
*                               RENAME ENTER TO VTCENTER,               00090000
*                              VTOC MORE TRANSPORTABLE.                 00100000
*  002G    052384   GATES     UPGRADE LOGIC TO HANDLE DATASETS WITH     00110000
*                              MORE THAN 16 EXTENTS.                    00120000
*  003G    111485   GATES     FIX BUG THAT CAUSED LOOP WHEN MESSAGE     00130000
*                              "VTOCMAP NO MORE STORAGE ...." ISSUED.   00140000
*  004G    122085   GATES     PUT CURRENT VOLID IN "VTOCMAP NO MORE     00150000
*                              STORAGE ...." MESSAGE.                   00160000
*  ???G    ??????   GATES     MIGHT NEED TO CHECK REUSE OF STORAGE      00161001
*                              THAT WAS GETMAINED.                      00162001
*                                                                       00170000
*                                                                       00180000
*                                                                       00190000
*                                                                       00200000
* OPERATION; THIS ROUTINE IS USED TO MAP THE DATASET LOCATIONS ON A     00210000
*        VOLUME. THE ROUTINE HAS TWO CALL MODES;                        00220000
*                                                                       00230000
*        0 - OPEN WILL GET THE MEMORY NECESSARY FOR THE INTERNAL MAP    00240000
*              TABLE.                                                   00250000
*        1 - ADD. WILL ADD THE CURRENT EXTENTS AND DSNAME TO AN         00260000
*              INTERNAL MAP TABLE. THE DSNAMES START FROM THE TOP       00270000
*              AND THE EXTENTS START FROM THE BOTTOM.                   00280000
*                     RETURN CODE = 0    ALL OK                         00290000
*                     RETURN CODE = 8    NOT ENOUGH STORAGE IN TABLE    00300000
*        2 - CLOSE. WILL CAUSE ALL THE ENTRIES CURRENTLY IN THE TABLE   00310000
*              TO BE PRINTED OUT. THIS SHOULD BE CALLED AT THE END      00320000
*              OF THE CURRENT VTOC.                                     00330000
*        3 - SORT. WILL CAUSE ALL THE ENTRIES CURRENTLY IN THE TABLE    00340000
*              TO BE SORTED ASCENDING ON START CCHH.                    00350000
         SPACE                                                          00360000
* ENTRY POINTS:  ENTRY IS ALWAYS TO 'VTOCMAP'.                          00370000
*        ARGUMENTS ARE:                                                 00380000
*                      1 - THE FORMAT1 DSCB                             00390000
*                      2 - THE FORMAT3 DSCB                             00400000
* EXTERNAL ROUTINES:                                                    00410000
*                                                                       00420000
         SPACE                                                          00430000
* EXITS - NORMAL;  RETURNS TO CALLER VIA R14 WITH RETURN                00440000
*        CODE IN REGISTER 15.       (SEE ABOVE FOR RETURN CODE VALUES.) 00450000
*                                                                       00460000
* TABLES AND WORK AREAS;  USES AN AREA PROVIDED BY THE CALLER FOR       00470000
*        ITS SAVEAREA AND FOR WORKING STORAGE IMMEDIATELY FOLLOWING     00480000
*        THE PRIOR SAVEAREA.  IT USES GETMAIN TO OBTAIN AN AREA FOR     00490000
*        THE MAP TABLE TO BE BUILT.  THIS COULD BE AS LARGE AS          00500000
*        8K FOR 3350'S.  IT IS FREED BY THE FINAL CALL.                 00510000
*                                                                       00520000
* ATTRIBUTES;  REENTRANT, REFRESHABLE.                                  00530000
         EJECT                                                          00540000
         MACRO                                                          00550000
&NAME    VTCEXT1 &OPT,&NUMB                                             00560000
&NAME    LA    R5,&OPT                                                  00570000
         AIF   ('&NUMB'(1,1) EQ '(').CONTA                         002G 00580000
         LA    R6,&NUMB                                                 00590000
         AGO   .CONTB                                              002G 00600000
.CONTA   ANOP                                                      002G 00610000
         LR    R6,&NUMB                                            002G 00620000
         AGO   .CONTB                                              002G 00630000
.CONTB   ANOP                                                      002G 00640000
         BAL   R14,CNVTEXT1                                             00650000
         MEND                                                           00660000
         MACRO                                                          00670000
&NAME    VTCEXT2 &OPT,&NUMB                                             00680000
&NAME    LA    R5,&OPT                                                  00690000
         AIF   ('&NUMB'(1,1) EQ '(').CONTA                         002G 00700000
         LA    R6,&NUMB                                                 00710000
         AGO   .CONTB                                              002G 00720000
.CONTA   ANOP                                                      002G 00730000
         LR    R6,&NUMB                                            002G 00740000
         AGO   .CONTB                                              002G 00750000
.CONTB   ANOP                                                      002G 00760000
         BAL   R14,CNVTEXT2                                             00770000
         MEND                                                           00780000
* ENTER HERE AND PERFORM STANDARD REGISTER SAVE AREA HOUSEKEEPING.      00790000
         SPACE                                                          00800000
VTOCMAP  VTCENTER 12,8                 USE THE PROVIDED SAVEAREA   001G 00810000
         USING VTOCWORK,R13   SET ADDRESSABILITY FOR WORK AREA          00820000
         LR    R11,R1                  SAVE PARAMETER REGISTER          00830000
         USING VTOCOM,R11              SET ADDRESSABILITY               00840000
         SPACE                                                          00850000
* SELECT MODE FROM CONTENTS AT ADDRESS IN REGISTER 1.                   00860000
         SPACE                                                          00870000
         SR    RWA,RWA                 CLEAR THE REGISTER               00880000
         IC    RWA,VTCMFUNC            GET CALL MODE                    00890000
         SLL   RWA,2                   MODE TIMES 4                     00900000
         B     *+4(RWA)                BRANCH ON MODE                   00910000
         SPACE                                                          00920000
         B     OPENRTN                 MODE 0, GET MEMORY               00930000
*                                              OPEN MAP TABLE.          00940000
         B     ADDRTN                  MODE 1, ADD MAP ENTRY.           00950000
         B     CLOSRTN                 MODE 2, CLOSE MAP TABLE          00960000
*                                              FREE MEMORY.             00970000
         B     SORTRTN                 MODE 3, SORT TABLE ENTRIES.      00980000
         SPACE 3                                                        00990000
***********                                                             01000000
* RETURNS *                                                             01010000
***********                                                             01020000
         SPACE                                                          01030000
RETURN0  SR    R15,R15                 CLEAR THE RETURN CODE            01040000
RETURN   VTCLEAVE EQ                   EXIT W/CURRENT RET CODE.    001G 01050000
         EJECT                                                          01060000
*************************************************                       01070000
* MODE 0 - OPEN, GETMAIN THE INTERNAL MAP TABLE *                       01080000
*************************************************                       01090000
         SPACE                                                          01100000
*   SAVE AREA HAS DSN'S SAVED AT THE TOP GOING DOWN AND THE             01110000
*    EXTENT INFO SAVED AT THE BOTTOM GOING UP.                          01120000
*                                                                       01130000
OPENRTN  EQU   *                                                        01140000
         GETMAIN R,LV=VTCMPGET                                          01150000
         ST    R1,VTCMPEXT    SAVE A(AREA FOR EXTENT SAVE).             01160000
         ST    R1,VTCMPMEM    SAVE A(BEGINNING OF MAP AREA).            01170000
         MVI   0(R1),X'FF'    INDICATE END OF EXTENTS INFO.             01180000
         CNOP  0,4            ALIGN FOR BAL IF NECESSARY.               01190000
         BAL   R2,GOTMAIN     GET L(GETMAINED AREA).                    01200000
         DC    A(VTCMPGET)    GET L(GETMAINED AREA).                    01210000
GOTMAIN  L     R2,0(R2)       GET L(GETMAINED AREA).                    01220000
         AR    R1,R2          CALC END OF GETMAINED AREA.               01230000
         ST    R1,VTCMPDSN    SAVE A(AREA FOR DSNAME SAVE).             01240000
         B     RETURN0        THEN RETURN                               01250000
         EJECT                                                          01260000
**************************                                              01270000
* MODE 1 - ADD MAP ENTRY *                                              01280000
**************************                                              01290000
         SPACE                                                          01300000
ADDRTN   EQU   *                                                        01310000
         L     R2,DSCBADDR             GET A(FMT1 DSCB).                01320000
         LA    R2,8(R2)                BUMP PAST HEADER.                01330000
         USING FMT1DSEC,R2             TELL ASSEMBLER                   01340000
         L     R3,VTCMPDSN             GET A(PREV DSN SAVED).           01350000
         SH    R3,=H'44'               CALC THIS DSN SAVE AREA.         01360000
         MVC   0(44,R3),DS1DSNAM       MOVE DSN TO SAVE AREA            01370000
         ST    R3,VTCMPDSN              AND SAVE ADDR.                  01380000
         CLI   DS1FMTID,C'4'           IS IT THE VTOC AREA?             01390000
         BNE   NOTVTOC                 NO, TRY NEXT.                    01400000
         VTCEXT1 DS1EXT1,1             CONVERT THE VTOC EXTENT.         01410000
         LTR   R15,R15                 WAS CONVERSION OK?               01420000
         BNZ   RETURN                  NO, QUIT AND PASS BACK ERROR.    01430000
         B     ENDEXT                  ONLY 1, QUIT.                    01440000
NOTVTOC  CLI   DS1FMTID,C'5'           IS IT THE FREE SPACE?            01450000
         BNE   NOTFREE                 NO, TRY NEXT.                    01460000
         DROP  R2                                                       01470000
         USING FMT5DSEC,R2             TELL ASSEMBLER                   01480000
         SR    R7,R7                   CLEAR EXTENT COUNT.              01490000
         VTCEXT2 DS5AVEXT,8            CONVERT FIRST 8 EXTENTS.         01500000
         LTR   R15,R15                 WAS CONVERSION OK?               01510000
         BNZ   RETURN                  NO, QUIT AND PASS BACK ERROR.    01520000
         VTCEXT2 DS5MAVET,18           CONVERT LAST 18 EXTENTS.         01530000
         LTR   R15,R15                 WAS CONVERSION OK?               01540000
         BNZ   RETURN                  NO, QUIT AND PASS BACK ERROR.    01550000
         B     ENDEXT                  GOT ALL GOOD EXTENTS.            01560000
NOTFREE  EQU   *                                                        01570000
         DROP  R2                                                       01580000
         USING FMT1DSEC,R2             TELL ASSEMBLER                   01590000
         CLI   DS1FMTID,C'6'           IS IT THE SPLIT AREA?            01600000
         BNE   ITSAFMT1                NO, TRY NEXT.                    01610000
         DROP  R2                                                       01620000
         USING FMT6DSEC,R2             TELL ASSEMBLER                   01630000
         VTCEXT2 DS6EXTAV,7            CONVERT FIRST 7 EXTENTS.         01640000
         LTR   R15,R15                 WAS CONVERSION OK?               01650000
         BNZ   RETURN                  NO, QUIT AND PASS BACK ERROR.    01660000
         VTCEXT2 DS6MAVET,18           CONVERT LAST 18 EXTENTS.         01670000
         LTR   R15,R15                 WAS CONVERSION OK?               01680000
         BNZ   RETURN                  NO, QUIT AND PASS BACK ERROR.    01690000
         B     ENDEXT                  ONLY 1, QUIT.                    01700000
ITSAFMT1 EQU   *                                                        01710000
         DROP  R2                                                       01720000
         USING FMT1DSEC,R2             TELL ASSEMBLER                   01730000
         VTCEXT1 DS1EXT1,3             CONVERT FIRST 3 EXTENTS.         01740000
         LTR   R15,R15                 WAS CONVERSION OK?               01750000
         BNZ   RETURN                  NO, QUIT AND PASS BACK ERROR.    01760000
*        CLC   DS1PTRDS,=5X'00'        IS THERE A FORMAT 3?        002G 01770000
*        BE    ENDEXT                  NO, SKIP CONVERTING OTHERS. 002G 01780000
*        VTCEXT1 DS3EXTNT,4            CONVERT NEXT 4 EXTENTS.     002G 01790000
*        LTR   R15,R15                 WAS CONVERSION OK?          002G 01800000
*        BNZ   RETURN                  NO, QUIT AND PASS BACK ERROR002G 01810000
*        VTCEXT1 DS3ADEXT,9            CONVERT NEXT 9 EXTENTS.     002G 01820000
         XR    R6,R6                   CLEAR WORK REG.             002G 01830000
         ICM   R6,X'0001',DS1NOEPV     GET NUMBER OF EXTENTS.      002G 01840000
         CH    R6,=H'3'                IS THERE MORE THAN 3 EXTENTS002G 01850000
         BNH   RETURN0                 NO, FMT 1 WAS ENOUGH.       002G 01860000
         SH    R6,=H'3'                YES, SUBT ONES IN FMT1.     002G 01870000
         LA    R15,8                   SET ERROR RET CODE IN CASE. 002G 01880000
         BM    RETURN                  THIS SHOULDN'T HAPPEN.      002G 01890000
         VTCEXT1 FMT3,(R6)             CONVERT REST OF EXTENTS.    002G 01900000
         LTR   R15,R15                 WAS CONVERSION OK?               01910000
         BNZ   RETURN                  NO, QUIT AND PASS BACK ERROR.    01920000
ENDEXT   B     RETURN0                                                  01930000
         EJECT                                                          01940000
******************                                                      01950000
* MODE 2 - CLOSE *                                                      01960000
******************                                                      01970000
         SPACE                                                          01980000
CLOSRTN  EQU   *                                                        01990000
         L     R1,VTCMPMEM    GET A(GOTMAINED AREA).                    02000000
FREEMAIN FREEMAIN R,LV=VTCMPGET,A=(1)                                   02010000
         B     RETURN0        THEN RETURN                               02020000
*                                                                       02030000
ERRET    LA    R15,8          SET AN ERROR RETURN CODE                  02040000
         B     RETURN         THEN EXIT                                 02050000
*                                                                       02060000
         EJECT                                                          02070000
********************                                                    02080000
* SERVICE ROUTINES *                                                    02090000
********************                                                    02100000
         SPACE                                                          02110000
***************************************************************         02120000
* ROUTINES TO CONVERT EXTENTS TO TRACKS AND SAVE IN TRACK MAP *         02130000
*    CNVTEXT1 IS FOR FMT1, FMT3, AND FMT4 DSCBS               *         02140000
*    CNVTEXT2 IS FOR FMT5 AND FMT6 DSCBS                      *         02150000
*    INPUTS:  R5=A(EXT INFO TO BE CONVERTED)                  *         02160000
*             R6=NUMBER OF EXTENTS THIS TIME THRU             *         02170000
***************************************************************         02180000
         SPACE                                                          02190000
CNVTEXT1 L     R4,VTCMPEXT             WHERE TO SAVE EXTENT INFO.       02200000
         MVI   0(R4),X'FF'             INDICATE END OF EXT INFO.        02210000
         USING OEXTDSEC,R4             TELL ASSEMBLER.                  02220000
         USING IEXTDS1,R5              TELL ASSEMBLER.                  02230000
CNVTNXT1 CLI   0(R5),X'00'             DOES EXTENT DESCRIBE ANYTHING?   02240000
         BE    NEXTEXT1                NO, CHECK NEXT EXTENT.           02250000
         ST    R3,OEXTADSN             SAVE A(ASSOCIATED DSN ENTRY).    02260000
         MVC   OEXTNUMB(1),IEXTNUMB    MOVE EXTENT NUMBER.              02270000
         MVC   DOUBLE(2),IEXTSTRT      LOW LIM. OF EXT., CC OF CCHH     02280000
         LH    R9,DOUBLE                                                02290000
         MH    R9,DS4DEVSZ+2           CONVERT CC TO ACTUAL TRACK NO.   02300000
         MVC   DOUBLE(2),IEXTSTRT+2    LOW LIM. OF EXT., HH OF CCHH     02310000
         AH    R9,DOUBLE               ACTUAL TRK OF START OF EXTENT    02320000
         STH   R9,OEXTSTRT             SAVE IT.                         02330000
         MVC   DOUBLE(2),IEXTEND       UPR LIM. OF EXT., CC OF CCHH     02340000
         LH    R8,DOUBLE                                                02350000
         MH    R8,DS4DEVSZ+2           CONVERT CC TO ACTUAL TRACK NO.   02360000
         MVC   DOUBLE(2),IEXTEND+2     UPR LIM. OF EXT., HH OF CCHH     02370000
         AH    R8,DOUBLE               ACTUAL TRK OF END OF EXTENT      02380000
         STH   R8,OEXTEND              SAVE IT.                         02390000
         SR    R8,R9                   CALC L(EXTENT) IN TRKS.          02400000
         LA    R8,1(R8)                ALWAYS ONE LESS THAN ACTUAL.     02410000
         STH   R8,OEXTLEN              SAVE IT.                         02420000
         MVI   OEXTL(R4),X'FF'         INDICATE END OF EXTENT INFO.     02430000
         LA    R4,OEXTL(R4)            UPDATE POINTER TO NEXT OUT EXT.  02440000
NEXTEXT1 LA    R5,IEXTL1(R5)           UPDATE POINTER TO NEXT IN EXT.   02450000
         LR    R8,R3                   DONT KILL R3.                    02460000
         SR    R8,R4                   DID TOP AND BOTTOM MEET YET?     02470000
         BM    ERRSTOR                 YES, ERROR NO STORAGE LEFT.      02480000
         BCT   R6,CNVTNXT1             CONVERT NUMB EXTENTS REQUESTED   02490000
         ST    R4,VTCMPEXT             SAVE A(NEXT EXT SAVE AREA).      02500000
         SR    R15,R15                 ZERO RETURN CODE.                02510000
         BR    R14                                                      02520000
         SPACE                                                          02530000
CNVTEXT2 L     R4,VTCMPEXT             WHERE TO SAVE EXTENT INFO.       02540000
         MVI   0(R4),X'FF'             INDICATE END OF EXT INFO.        02550000
         USING OEXTDSEC,R4             TELL ASSEMBLER.                  02560000
         USING IEXTDS2,R5              TELL ASSEMBLER.                  02570000
CNVTNXT2 CLC   IEXTRTRK(2),=H'0'       DOES EXTENT DESCRIBE ANYTHING?   02580000
         BE    CNVTRET2                NO, SKIP THIS DSCB.              02590000
         ST    R3,OEXTADSN             SAVE A(ASSOCIATED DSN ENTRY).    02600000
         STC   R7,OEXTNUMB             SAVE EXTENT NUMBER.              02610000
         MVC   DOUBLE(2),IEXTRTRK      GET ACTUAL TRK START OF EXT.     02620000
         LH    R9,DOUBLE                                                02630000
         STH   R9,OEXTSTRT             SAVE ACTUAL TRK START OF EXT.    02640000
         MVC   DOUBLE(2),IEXTCYL       GET NUMBER OF CYLS.              02650000
         LH    R8,DOUBLE                                                02660000
         MH    R8,DS4DEVSZ+2           CONVERT CC TO NUMBER TRKS.       02670000
         CLI   DS1FMTID,C'6'           IS IT A FORMAT6?                 02680000
         BE    CNVTF62                 YES, NO TRKS INFO.               02690000
         MVI   DOUBLE,0                CLEAR FIRST BYTE FOR ADD.        02700000
         MVC   DOUBLE+1(1),IEXTTRK     GET REST OF TRKS.                02710000
         AH    R8,DOUBLE               ADD IN REST OF TRKS.             02720000
CNVTF62  STH   R8,OEXTLEN              SAVE L(EXTENT IN TRKS).          02730000
         AR    R8,R9                   CALC ACTUAL TRK END OF EXTENT.   02740000
         BCTR  R8,0                    SUBT ONE.                        02750000
         STH   R8,OEXTEND              SAVE IT.                         02760000
         MVI   OEXTL(R4),X'FF'         INDICATE END OF EXTENT INFO.     02770000
         LA    R4,OEXTL(R4)            UPDATE POINTER TO NEXT OUT EXT.  02780000
NEXTEXT2 LA    R5,IEXTL2(R5)           UPDATE POINTER TO NEXT IN EXT.   02790000
         LR    R8,R3                   DONT KILL R3.                    02800000
         SR    R8,R4                   DID TOP AND BOTTOM MEET YET?     02810000
         BM    ERRSTOR                 YES, ERROR NO STORAGE LEFT.      02820000
         LA    R7,1(R7)                BUMP EXTENT NUMBER.              02830000
         BCT   R6,CNVTNXT2             CONVERT NUMB EXTENTS REQUESTED   02840000
CNVTRET2 ST    R4,VTCMPEXT             SAVE A(NEXT EXT SAVE AREA).      02850000
         SR    R15,R15                 ZERO RETURN CODE.                02860000
         BR    R14                                                      02870000
*ERRSTOR  VTOCMSG NOSTORM               PUT MESSAGE OUT.           004G 02880000
ERRSTOR  MVC   MSGTEXT2,NOSTORM        SET UP THE MESSAGE.         004G 02890000
         MVC   MSGTEXT2+65(6),VOLSER   AND ADD THE VOLSER.         004G 02900000
         VTOCMSG MSGTEXT2              PUT MESSAGE OUT.            004G 02910000
         LA    R15,8                   SET AN ERROR RETURN CODE.        02920000
*        BR    R14                                                 003G 02930000
         B     RETURN                                              003G 02940000
         SPACE                                                          02950000
**************************************************                      02960000
* MODE 3 - SORT THE EXTENTS INTO ASCENDING ORDER *                      02970000
**************************************************                      02980000
         SPACE                                                          02990000
SORTRTN  EQU   *                                                        03000000
*                                                                       03010000
*        ALL SORTING IS ON STARTING CCHH OF EXTENTS                     03020000
*                                                                       03030000
         L     R4,VTCMPMEM         GET A(FIRST ENTRY).                  03040000
         CLI   00(R4),X'FF'        IS THIS THE LAST ENTRY?              03050000
         BE    SORTEND             YES, QUIT.                           03060000
         NI    VTCMFUNC,X'7F'      INDICATE LIST NOT REARRANGED.        03070000
SORTIT   CLI   12(R4),X'FF'        IS THIS THE LAST ENTRY?              03080000
         BE    SORTLAST            YES, SEE IF MORE SORT NEEDED.        03090000
         CLC   6(2,R4),18(R4)      COMPARE CURRENT VS NEXT ENTRY.       03100000
         BE    SORTNEXT              START CCHH SAME COMPARE NEXT.      03110000
         BL    SORTNEXT              CURR START CCHH LOW COMPARE NEXT.  03120000
*                                    CURR START CCHH HIGH EXCHANGE THEM 03130000
         XC    0(12,R4),12(R4)           EXCHANGE                       03140000
         XC    12(12,R4),0(R4)           EXCHANGE                       03150000
         XC    0(12,R4),12(R4)           EXCHANGE                       03160000
         OI    VTCMFUNC,X'80'      INDICATE LIST REARRANGED THIS PASS.  03170000
SORTNEXT LA    R4,12(R4)           MAKE NEXT ENTRY CURRENT ENTRY.       03180000
         B     SORTIT              THEN CONTINUE SORTING LIST.          03190000
SORTLAST TM    VTCMFUNC,X'80'      WAS THE LIST REARRANGED THIS PASS?   03200000
         BNO   SORTEND             NO, WE ARE FINISHED SORTING.         03210000
         B     SORTRTN             GO TO START SORT FROM BEGINNING.     03220000
SORTEND  B     RETURN0             RETURN TO CALLER.                    03230000
         EJECT                                                          03240000
********************************                                        03250000
* CONSTANTS, VARIABLES, ETC... *                                        03260000
********************************                                        03270000
         SPACE                                                          03280000
*        ERROR MESSAGES                                                 03290000
*                                                                       03300000
*NOSTORM  VTCMSG ' VTOCMAP - NO MORE STORAGE TO SORT EXTENTS QUITTING'  03310000
NOSTORM  VTCMSG ' VTOCMAP - NO MORE STORAGE TO SORT EXTENTS QUITTING DUX03320000
               RING VOLUME VVVVVV  '                              004G  03330000
         LTORG                                                          03340000
         EJECT                                                          03350000
* SECTION DEFINITION AND REGISTER ASSIGNMENTS;                          03360000
         SPACE 2                                                        03370000
RWA      EQU   2                                                        03380000
RWB      EQU   3                                                        03390000
RWC      EQU   4                                                        03400000
RDCB     EQU   8              DCB POINTER                               03410000
RRCODE   EQU   10              RETURN CODE REGISTER                     03420000
RRET     EQU   9               LOCAL SUBROUTINE EXIT REGISTER           03430000
         SPACE 3                                                        03440000
         EJECT                                                          03450000
         SPACE 2                                                        03460000
         VTCCOM                                                    001G 03470000
         SPACE 2                                                        03480000
*                                                                       03490000
*        AREA USED BY VTOCREAD, PASSED VIA R13                          03500000
*                                                                       03510000
VTOCWORK DSECT                                                          03520000
         DS    18F             SAVE AREA                                03530000
         SPACE                                                          03540000
MAPSAVE  DS    18F             INTERNAL SAVE AREA                       03550000
VTOCWLEN EQU   *-VTOCWORK                                               03560000
IEXTDS1  DSECT                                                          03570000
         DS    X               EXTENT TYPE                              03580000
IEXTNUMB DS    X               EXTENT NUMBER                            03590000
IEXTSTRT DS    4X              CCHH START                               03600000
IEXTEND  DS    4X              CCHH END                                 03610000
IEXTL1   EQU   *-IEXTDS1                                                03620000
IEXTDS2  DSECT                                                          03630000
IEXTRTRK DS    2X              RELATIVE TRK OF START                    03640000
IEXTCYL  DS    2X              NUMBER OF CYLS                           03650000
IEXTTRK  DS    0X              NUMBER OF TRKS                           03660000
IEXTDSS  DS    1X              NUMBER OF DSN SHARING SPACE              03670000
IEXTL2   EQU   *-IEXTDS2                                                03680000
OEXTDSEC DSECT                                                          03690000
         DS    0F                                                       03700000
OEXTADSN DS    AL4             A(ASSOCIATED DSN ENTRY IN MAP TABLE)     03710000
         DS    X               FILLER                                   03720000
OEXTNUMB DS    X               EXTENT NUMBER                            03730000
OEXTSTRT DS    2X              CCHH START                               03740000
OEXTEND  DS    2X              CCHH END                                 03750000
OEXTLEN  DS    2X              EXTENT LENGTH                            03760000
OEXTL    EQU   *-OEXTDSEC                                               03770000
FMT1DSEC DSECT                                                          03780000
         IECSDSL1 (1)                                                   03790000
FMT5DSEC DSECT                                                          03800000
         IECSDSL1 (5)                                                   03810000
FMT6DSEC DSECT                                                          03820000
         IECSDSL1 (6)                                                   03830000
         END                                                            03840000
