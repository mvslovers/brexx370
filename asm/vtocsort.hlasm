         TITLE 'VTOC COMMAND  SORT  ROUTINE'                            00010000
*********************************************************************** 00020000
*         MODIFICATIONS                                                 00030003
* NUMBER    DATE    PERSON    REASON                                    00040003
*  001G    050284   GATES     RENAME VTFMT MACRO TO VTCFMT,             00050003
*                              RENAME VTLEAVE MACRO TO VTCLEAVE,        00060003
*                              RENAME VTOCOM MACRO TO VTCCOM,           00070003
*                              RENAME VTOCPARS MACRO TO VTCPARS,        00080003
*                              RENAME PDEDSNAM MACRO TO VTCPDEDS,       00090004
*                               RENAME ENTER TO VTCENTER,               00100006
*                              VTOC MORE TRANSPORTABLE.                 00110003
*                                                                     * 00120000
*                                                                     * 00130000
* TITLE -      VTOC COMMAND  SORT  ROUTINE                            * 00140000
*                                                                     * 00150000
* FUNCTION -   PUT THIS FORMATTED DSCB INTO THE SORTED LIST.          * 00160000
*                                                                     * 00170000
* OPERATION -  IF THIS IS A NOSORT RUN, JUST CALL THE PRINT ROUTINE.  * 00180000
*              TO BUILD THE SORTED LIST, FIRST DO A SIMPLE HASH       * 00190000
*              ON THE FIRST CHARACTER.  BUILD UP TO 256 SEPARATE      * 00200000
*              LISTS TO SAVE SORT TIME.  THEN SEARCH THROUGH THESE    * 00210000
*              LISTS SEQUENTIALLY.                                    * 00220000
*                                                                     * 00230000
* INPUT -      VTOC COMMON AREA ( VTOCOM )                            * 00240000
*              POINTED TO BY REGISTER 1                               * 00250000
*              USE PARSE DATA, CURRENT FORMATTED DSCB, SORTED LIST    * 00260000
*                                                                     * 00270000
* OUTPUT -     THE FORMATTED DSCB IS PLACED INTO THE SORTED LIST.     * 00280000
*                                                                     * 00290000
* ATTRIBUTES - REENTRANT, REUSEABLE, REFRESHABLE.                     * 00300000
*                                                                     * 00310000
*                                                                     * 00320000
*         PROGRAMMED BY R. L. MILLER  (415) 485-6241                  * 00330000
*                                                                     * 00340000
*                                                                     * 00350000
*********************************************************************** 00360000
*                                                                       00370000
*   NOTE - EXTENSION -                                                  00380000
*   THIS VERSION SORTS BY DSNAME ONLY.                                  00390000
*   HOPEFULLY IT CAN BE MADE TO SORT FOR MULTIPLE KEYS AND MOST OF THE  00400000
*   ITEMS IN VTFMT.                                                     00410000
*                                                                       00420000
         EJECT                                                          00430000
VTOCSORT VTCENTER 12,24       DO THE HOUSEKEEPING                  001G 00440005
         LR    R11,R1         SAVE ADDR OF VTOCOM                       00450000
         USING VTOCOM,R11     SET ITS ADDRESSABILITY                    00460000
         L     R9,ADDRANSR    POINT TO THE PARSE ANSWER                 00470000
         USING PDL,R9         SET ITS ADDRESSABILITY                    00480000
         USING SORTWORK,R13   SET ADDRESSABILITY FOR LOCAL WORK AREA    00490000
         SPACE 3                                                        00500000
*                                                                       00510000
*        IS THIS A NOSORT RUN ?                                         00520000
*        IF SO, JUST CALL PRINT                                         00530000
*                                                                       00540000
         CLI   SORTK+1,2      IS THIS NOSORT?                           00550000
         BNE   GOSORT         NO, KEEP ON TRUCKIN'                      00560000
         VTCALL PRNT          YES, CALL PRINT AND GET OUT               00570000
         B     SORTRET        GET OUT OF HERE                           00580000
*                                                                       00590000
*        PUT THIS ENTRY WHERE IT BELONGS                                00600000
*                                                                       00610000
GOSORT   L     R3,FORMATAD    POINT TO THE FORMATTED DSCB               00620000
         USING VTFMT,R3       SET ADDRESSABILITY                        00630000
         LA    R4,VTFDSN      POINT TO THE FIRST CHARACTER              00640000
         SR    R2,R2          CLEAR A REGISTER                          00650000
         IC    R2,0(R4)       GET THE FIRST CHARACTER                   00660000
         SLA   R2,2           MULTIPLY BY FOUR                          00670000
         LA    R2,VTCSORTH(R2)  POINT TO THE CORRECT LIST               00680000
         ICM   R5,B'1111',0(R2) GET THE HEAD OF THE LIST                00690000
         BNZ   NOTFIRST       IF NON-ZERO, SEARCH THE LIST              00700000
*                                                                       00710000
*        FIRST ENTRY ON THE LIST, IT'S EASY                             00720000
*                                                                       00730000
         ST    R3,0(R2)       START UP THE LIST                         00740000
         B     SORTRET        THEN RETURN                               00750000
*                                                                       00760000
*        FIND A SLOT FOR THIS ENTRY                                     00770000
*              FIRST GET THE SHORTER DSN LENGTH                         00780000
*                                                                       00790000
NOTFIRST LH    R1,VTFDSNL     LENGTH OF NEW ENTRY                       00800000
         CH    R1,VTFDSNL-VTFMT(R5)  IS IT SMALLER THAN THIS LIST ENTRY 00810000
         BNH   GOTLEN         YES, NEW ONE IS OK                        00820000
         LH    R1,VTFDSNL-VTFMT(R5)  NO, GET THE LIST ENTRY LENGTH      00830000
GOTLEN   BCTR  R1,0           SUBTRACT ONE FOR EX                       00840000
         EX    R1,COMPDSN     COMPARE THE DSN'S                         00850000
         BL    NEXTENT        LIST ENTRY IS LOWER, UP THE CHAIN         00860000
         BE    CHECKLEN       IDENTICAL, SHORTER ONE WINS               00870000
*                                                                       00880000
*        THE NEW ENTRY GOES HERE                                        00890000
*                                                                       00900000
INSERT   ST    R3,0(R2)       SAVE THE NEW POINTER                      00910000
         ST    R5,VTFNEXT     JUST BEFORE THIS LIST ENTRY               00920000
         B     SORTRET        THEN EXIT                                 00930000
*                                                                       00940000
*        THE DSNAMES ARE IDENTICAL AS FAR AS THEY COMPARE               00950000
*              THE ONE WITH THE SHORTER DSNAME IS FIRST                 00960000
*                                                                       00970000
CHECKLEN LA    R1,1(R1)       GET BACK TO THE ORIGINAL LENGTH           00980000
         CH    R1,VTFDSNL     IS THIS THE NEW ENTRY LENGTH              00990000
         BE    INSERT         YES, USE IT (TIE GOES TO NEW ENTRY)       01000000
*                                                                       01010000
*        GET THE NEXT ENTRY ON THIS LIST                                01020000
*                                                                       01030000
NEXTENT  LA    R2,VTFNEXT-VTFMT(R5)  POINT BACK TO THIS ENTRY           01040000
         ICM   R5,B'1111',VTFNEXT-VTFMT(R5)  GET THE NEXT ENTRY         01050000
         BNZ   NOTFIRST       THERE IS ONE, CHECK IT                    01060000
         ST    R3,0(R2)       LAST ENTRY ON THE LIST, PUT IT THERE      01070000
*                                                                       01080000
*        RETURN                                                         01090000
*                                                                       01100000
SORTRET  VTCLEAVE EQ,RC=0                                          001G 01110003
*                                                                       01120000
*                                                                       01130000
*                                                                       01140000
*        PROGRAM CONSTANTS                                              01150000
*                                                                       01160000
COMPDSN  CLC   VTFDSN-VTFMT(0,R5),VTFDSN    EXECUTED COMPARE            01170000
*                                                                       01180000
*                                                                       01190000
         EJECT                                                          01200000
*                                                                       01210000
*                                                                       01220000
*        P A R S E   C O N T R O L   L I S T                            01230000
*                                                                       01240000
*                                                                       01250000
         COPY  VTCPARS                                             001G 01260003
*                                                                       01270000
*        DYNAMIC WORK AREA                                              01280000
*                                                                       01290000
         SPACE 3                                                        01300000
SORTWORK DSECT                                                          01310000
         DS    18A            PRINT ROUTINE SAVE AREA                   01320000
         SPACE                                                          01330000
         DS    0D                                                       01340000
LENWORK  EQU   *-SORTWORK                                               01350000
*                                                                       01360000
*        VTOC COMMAND COMMON AREA                                       01370000
*                                                                       01380000
         VTCCOM                                                    001G 01390003
         SPACE 3                                                        01400000
*                                                                       01410000
*        FORMATTED DSCB                                                 01420000
*                                                                       01430000
         VTCFMT                                                    001G 01440003
         SPACE 3                                                        01450000
         VTCPDEDS                                                  001G 01460004
         SPACE 3                                                        01470000
         END                                                            01480000
