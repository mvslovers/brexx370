         TITLE 'VTOC COMMAND FORMAT ROUTINE'                            00010000
*********************************************************************** 00020000
*       MODIFICATIONS                                                   00030000
* NUMBER    DATE    PERSON    REASON                                    00040000
*  001G    072278   GATES     CHANGE MSG MACROS TO VTCMSG TO AVOID      00050000
*                              CONFLICT WITH EXISTING MSG MACRO.        00060000
*  002G    030779   GATES     DON'T DO CATALOG SEARCH WHEN EXTENTS ARE  00070000
*                              EQUAL TO ZERO.                           00080000
*  003G    050284   GATES     RENAME VTFMT MACRO TO VTCFMT,             00090000
*                              RENAME VTLEAVE MACRO TO VTCLEAVE,        00100000
*                              RENAME VTOCOM MACRO TO VTCCOM,           00110000
*                              RENAME VTOCPARS MACRO TO VTCPARS,        00120000
*                              RENAME PDEDSNAM MACRO TO VTCPDEDS,       00130000
*                               RENAME ENTER TO VTCENTER,               00140000
*                              VTOC MORE TRANSPORTABLE.                 00150000
*  004G    051084   GATES     SAVE UNIT TYPE.                           00160000
*  005G    051084   GATES     SAVE WHETHER LAST OPEN WAS UPDATE OR NOT. 00170000
*  006G    052384   GATES     UPGRADE LOGIC TO WORK WITH DATASETS THAT  00180000
*                              CONTAIN MORE THAN 16 EXTENTS.            00190000
*  007G    110584   GATES     FIX BUG WHERE 3380 TRACK LENGTH WAS USED  00191000
*                              AS NEGATIVE VALUE.                       00192000
*  008G    010488   GATES     PUT LOGIC IN FOR KEY LENGTH.              00193000
*  009G    051590   GATES     UPGRADE LOGIC TO ALLOW FOR 3380 DEVICES   00193101
*                             THAT HAVE TRACK COUNT THAT COULD LOOK     00194000
*                             NEGATIVE.                                 00194100
*  010G    072790   GATES     UPGRADE LOGIC TO ADD OPTCD CHECKING       00194202
*                             LOGIC.                                    00194302
*                                                                       00194500
*                                                                       00195000
*                                                                     * 00196000
*                                                                     * 00197000
* TITLE -      VTOC COMMAND FORMAT ROUTINE                            * 00198000
*                                                                     * 00199000
* FUNCTION -   FORMAT THE DATA INTO THE VTFMT  DSECT FROM THE         * 00200000
*              FORMAT 1 ( AND 3 IF NEEDED ) DSCB.  THIS ROUTINE       * 00210000
*              ALSO GETS THE AREA TO CONTAIN THE FORMATTED            * 00220000
*              DSCB INFORMATION.                                      * 00230000
*                                                                     * 00240000
* OPERATION -  FIRST GET AN AREA FROM THE CURRENT BLOCK, OR GET       * 00250000
*              A BLOCK ( 32K ) OF STORAGE TO USE FOR THE FORMATTED    * 00260000
*              DSCB'S.  MOVE THE DATA OVER FROM THE FORMAT 1 DSCB.    * 00270000
*              THE SPACE CALCULATIONS MAY NEED THE FORMAT 3 DSCB.     * 00280000
*              CATALOG INFORMATION IS OBTIANED VIA LOCATE.  SOME      * 00290000
*              OF THE DSCB INFORMATION IS CONVERTED HERE.             * 00300000
*                                                                     * 00310000
* INPUT -      VTOC COMMON AREA ( VTOCOM )                            * 00320000
*              POINTED TO BY REGISTER 1                               * 00330000
*              USE PARSE DATA, CURRENT FORMATTED DSCB, LOCATE         * 00340000
*                                                                     * 00350000
* OUTPUT -     THE FORMATTED DSCB INFORMATION WITH ITS ADDRESS IN     * 00360000
*              FORMATAD.                                              * 00370000
*                                                                     * 00380000
* ATTRIBUTES - REENTRANT, REUSEABLE, REFRESHABLE.                     * 00390000
*                                                                     * 00400000
*                                                                     * 00410000
*         PROGRAMMED BY R. L. MILLER  (415) 485-6241                  * 00420000
*                                                                     * 00430000
*                                                                     * 00440000
*********************************************************************** 00450000
*                                                                       00460000
         EJECT                                                          00470000
         MACRO                                                          00480000
&LAB     DS1TST  &FIELD,&VALUE,&CODE                                    00490000
&LAB     TM    DS1&FIELD,X'&VALUE'  TEST IT                             00500000
         BNO   D&SYSNDX       IF NOT THERE, SKIP ALONG                  00510000
         MVC   VTF&FIELD,=CL3'&CODE'                                    00520000
D&SYSNDX DS    0H                                                       00530000
         MEND                                                           00540000
*                                                                       00550000
*                                                                       00560000
         EJECT                                                          00570000
VTOCFORM VTCENTER 12,16       DO THE HOUSEKEEPING                  003G 00580000
         LR    R11,R1         SAVE ADDR OF VTOCOM                       00590000
         USING VTOCOM,R11     SET ITS ADDRESSABILITY                    00600000
         L     R9,ADDRANSR    POINT TO THE PARSE ANSWER                 00610000
         USING PDL,R9         SET ITS ADDRESSABILITY                    00620000
         USING FORMWORK,R13   SET ADDRESSABILITY FOR LOCAL WORK AREA    00630000
         SPACE 3                                                        00640000
*                                                                       00650000
*        CHECK FOR THE FIRST TIME THROUGH                               00660000
*        IF SO, PERFORM SOME INITIALIZATION                             00670000
*                                                                       00680000
         CLI   FIRSTFRM,0     IS THIS THE FIRST TIME?                   00690000
         BNE   GETAREA        NO, KEEP ON TRUCKIN'                      00700000
*                                                                       00710000
*        ROUTINE INITIALIZATION                                         00720000
*                                                                       00730000
         MVI   FIRSTFRM,255   NOTE THE INITIALIZATION AS DONE           00740000
         MVC   CAMLOC(CAMLEN),CAMCONST  SET UP THE CAMLST               00750000
*                                                                       00760000
*        FIND OR GET AN AREA FOR THE FORMATTED DSCB                     00770000
*              FIRST SEE HOW BIG IT IS                                  00780000
*                                                                       00790000
GETAREA  L     R7,DSCBADDR    POINT TO THE DSCB                         00800000
         LA    R7,8(R7)       GET PAST THE HEADER                       00810000
         USING DSCB1,R7       SET ADDRESSABILITY                        00820000
         LH    R1,DSNLEN     GET THE DSNAME LENGTH                      00830000
         LA    R4,VTFMTL(R1)  GET THE FORMATTED DSCB LENGTH             00840000
*                                                                       00850000
*        SEE IF THE CURRENT BLOCK CAN HANDLE IT                         00860000
*                                                                       00870000
FORMFIT  L     R3,VTCCURLN    GET THE CURRENT AVAILABLE                 00880000
         SR    R3,R4          SEE IF IT WILL FIT                        00890000
         BM    GOGETMN        NO, GET ANOTHER BLOCK                     00900000
*                                                                       00910000
*        NO SWEAT, GET THE SPACE FROM THIS BLOCK                        00920000
*                                                                       00930000
         ST    R3,VTCCURLN    STORE THE NEW ( REDUCED ) CURRENT LENGTH  00940000
         L     R3,VTCCURAD    POINT TO THE CURRENT ADDRESS              00950000
         LA    R5,0(R3,R4)    POINT TO THE END OF THE BLOCK             00960000
         ST    R5,VTCCURAD    AND PLACE THE NEW AVAILABLE ADDRESS       00970000
*                                                                       00980000
*        NOW FILL IN THE DATA IN THE FORMATTED DSCB                     00990000
*                                                                       01000000
         USING VTFMT,R3       SET FORMATTED DSCB ADDRESSABILITY         01010000
         ST    R3,FORMATAD    SAVE THIS BLOCK'S ADDRESS                 01020000
         XC    VTFNEXT,VTFNEXT  CLEAR THE SORT POINTER                  01030000
         MVC   VTFVOLUM,VOLID SAVE THE VOLUME SERIAL NUMBER             01040000
         MVC   VTFUNIT,UNITYP SAVE THE UNIT TYPE.                  004G 01050000
         LH    R1,DSNLEN     GET THE LENGTH OF THE DSNAME               01060000
         STH   R1,VTFDSNL     SAVE THE DSNAME LENGTH                    01070000
         BCTR  R1,0           SUBTRACT ONE FOR THE EX                   01080000
         EX    R1,MOVEDSN     MOVE IN THE DSNAME                        01090000
         MVC   VTFNOEPV,DS1NOEPV  NUMBER OF EXTENTS                     01100000
         MVC   VTFLRECL,DS1LRECL  LOGICAL RECORD LENGTH                 01110000
         MVC   VTFBLKSZ,DS1BLKL   BLOCK SIZE                            01120000
         MVC   VTFKEYLE,DS1KEYL   KEY LENGTH                       008G 01130000
*                                                                       01140000
*     MOVE IN THE CREATION DATE, EXPIRATION DATE, AND LAST ACCESS DATE  01150000
*                                                                       01160000
         MVC   VTFCREDT,DS1CREDT  MOVE OVER CREATION DATE               01170000
         MVC   VTFEXPDT,DS1EXPDT  MOVE OVER EXPIRATION DATE             01180000
         MVC   VTFLSTAC,DSCB1+75  MOVE OVER LAST ACCESS DATE            01190000
*                                                                       01200000
*        FORMAT THE RECORD FORMAT INTO CHARACTERS                       01210000
*                                                                       01220000
*                                                                       01230000
         MVC   VTFRECFM,BLANKS  BLANK THE FIELD TO START                01240000
         MVC   VTFACTON,BLANKS  ANOTHER BLANK FIELD                     01250000
         MVI   VTFDSTYP,C' ' AND STILL ANOTHER                          01260000
         LA    R2,VTFRECFM    POINT TO THE FIELD                        01270000
         TM    DS1RECFM,X'C0' UNKNOWN RECFM?                            01280000
         BZ    RECFM2         YES, TROUBLE                              01290000
         TM    DS1RECFM,X'40' IS IT FIXED?                              01300000
         BNZ   RECFM3         NO, KEEP TRYING                           01310000
         MVI   0(R2),C'F'     YES, SET UP THE FIRST CHAR                01320000
         LA    R2,1(R2)       AND BUMP THE POINTER                      01330000
         B     RECFM2         CHECK OTHER ATTRIBUTES                    01340000
RECFM3   TM    DS1RECFM,X'80' SEE IF IT'S V OR U                        01350000
         BZ    RECFM4         VARIABLE RECFM                            01360000
         MVI   0(R2),C'U'     RECFM = U                                 01370000
         B     RECFM4A        ADD TO THE POINTER AND KEEP LOOKING       01380000
RECFM4   MVI   0(R2),C'V'     VARIABLE                                  01390000
RECFM4A  LA    R2,1(R2)       GET PAST THIS CHAR                        01400000
RECFM2   DS    0H                                                       01410000
RECFM5   TM    DS1RECFM,X'10' IS IT BLOCKED?                            01420000
         BZ    RECFM6         NO, SKIP ON                               01430000
         MVI   0(R2),C'B'     YES, SET THE SYMBOL                       01440000
         LA    R2,1(R2)       GET PAST THE CHAR                         01450000
RECFM6   TM    DS1RECFM,X'08' IS IT SPANNED OR STANDARD?                01460000
         BZ    RECFM6A        NO                                        01470000
         MVI   0(R2),C'S'     YES, SET IT                               01480000
         LA    R2,1(R2)       GET PAST THIS CHARACTER                   01490000
RECFM6A  TM    DS1RECFM,X'20' CHECK TRACK OVERFLOW                      01500000
         BZ    RECFM7         NO DICE                                   01510000
         MVI   0(R2),C'T'     YES, SET IT                               01520000
         LA    R2,1(R2)       PUSH THE POINTER ON                       01530000
RECFM7   TM    DS1RECFM,X'04' IS IT ASA CONTROL                         01540000
         BZ    RECFM8         NO, SKIP ON                               01550000
         MVI   0(R2),C'A'     YES, SET IT                               01560000
         LA    R2,1(R2)       GET PAST THIS CHAR                        01570000
RECFM8   TM    DS1RECFM,X'02' HOW ABOUT MACHINE CARRIAGE CONTROL        01580000
         BZ    RECFM9         NO, SKIP ON                               01590000
         MVI   0(R2),C'M'     YES, SET IT                               01600000
RECFM9   DS    0H                                                       01610002
*                                                                  010G 01611102
*        FORMAT THE OPTCD VALUE INTO CHARACTERS                    010G 01611202
*                                                                  010G 01611302
*                                                                  010G 01611402
         MVC   VTFOPTCD,BLANKS  BLANK THE FIELD TO START.          010G 01611502
*        WRITE VALIDITY IS ONLY VALID FOR CERTAIN DSORGS           010G 01611803
         LA    R2,VTFOPTCD    POINT TO THE FIELD.                  010G 01611903
         TM    DS1DSORG,DS1DSGPS CHECK FOR DSORG=PS                010G 01612103
         BO    OPTCD1         YES, CHECK FURTHER.                  010G 01612203
         TM    DS1DSORG,DS1DSGPO CHECK FOR DSORG=PO                010G 01612303
         BO    OPTCD1         YES, CHECK FURTHER.                  010G 01612403
         TM    DS1DSORG,DS1DSGDA CHECK FOR DSORG=DA                010G 01612503
         BO    OPTCD1         YES, CHECK FURTHER.                  010G 01612603
         TM    DS1DSORG,DS1DSGIS CHECK FOR DSORG=IS                010G 01612703
         BNO   OPTCD2         NO, DON'T CHECK FURTHER.             010G 01612803
OPTCD1   TM    DS1OPTCD,X'80' IS IT WRITE VALIDITY?                010G 01613103
         BZ    OPTCD2         NO, DON'T CHECK FURTHER.             010G 01613204
         MVI   0(R2),C'W'     YES, SET UP THE FIRST CHAR.          010G 01613302
         LA    R2,1(R2)       AND BUMP THE POINTER.                010G 01613402
         B     OPTCD2         CHECK OTHER ATTRIBUTES.              010G 01613502
OPTCD2   DS    0H                                                  010G 01613602
*                                                                       01620000
*        FORMAT THE DSORG                                               01630000
*                                                                       01640000
         MVC   VTFDSORG,=CL3'   '  CLEAR THE FIELD                      01650000
         DS1TST DSORG,80,IS   TRY ISAM                                  01660000
         DS1TST DSORG,40,PS   TRY SEQUENTIAL                            01670000
         DS1TST DSORG,20,DA   TRY DIRECT ACCESS                         01680000
         DS1TST DSORG,02,PO   TRY PARTITIONED                           01690000
         CLC   DS1DSORG(2),=X'0008'  IS IT VSAM?                        01700000
         BNE   DSORG05       NO, KEEP LOOKING                           01710000
         MVC   VTFDSORG,=CL3'VS ' YES, FLAG IT                          01720000
DSORG05  TM    DS1DSORG,X'01'      IS IT UNMOVEABLE?                    01730000
         BNO   DSORG06       NO, KEEP ON TRUCKIN'                       01740000
         MVI   VTFDSORG+2,C'U'     YES, NOTE IT                         01750000
DSORG06  DS    0H                                                       01760000
*                                                                       01770000
*        FORMAT THE SECONDARY ALLOCATION                                01780000
*                                                                       01790000
         SR    R1,R1          CLEAR A WORK REGISTER                     01800000
         IC    R1,DS1SCALO    GET THE ALLOCATION FLAG                   01810000
         SRL   R1,6           REMOVE THE BOTTOM 6 BITS ( 75 CENTS )     01820000
         IC    R2,SECAL(R1)   GET THE CHARACTER CODE                    01830000
         STC   R2,VTFSECAL    AND SAVE IT FOR LATER                     01840000
         MVC   VTFSECAM,DS1SCALO+2  SAVE THE SECONDARY AMOUNT TOO       01850000
         MVI   VTFROUND,C'N'  SET CODE FOR NO ROUND                     01860000
         TM    DS1SCALO,X'01' SEE IF ROUND WAS SET                      01870000
         BNO   PROTFORM       NO, THE CODE IS SET RIGHT                 01880000
         MVI   VTFROUND,C'R'  YES, RESET THE CODE                       01890000
*                                                                       01900000
*        FORMAT THE PASSWORD PROTECTION                                 01910000
*                                                                       01920000
PROTFORM TM    DS1DSIND,X'14' CHECK THE PASSWORD BITS                   01930000
         BO    PROTWRIT       WRITE PROTECT IS X'14'                    01940000
         BM    PROTREAD       READ PROTECT IS X'10'                     01950000
         MVI   VTFPROT,C'N'   NO PASSWORD PROTECTION                    01960000
         B     PROTEND        END OF PROTECTION FORMATTING              01970000
PROTWRIT MVI   VTFPROT,C'W'   SET CODE FOR WRITE PROTECT                01980000
         B     PROTEND        THEN CHECK OTHER ITEMS                    01990000
PROTREAD MVI   VTFPROT,C'R'   SET CODE FOR READ/WRITE PROTECT           02000000
PROTEND  DS    0H             END OF PROTECTION FORMATTING              02010000
*                                                                       02020000
*        FORMAT THE OPENED FOR UPDATE FIELD                             02030000
*                                                                       02040000
OPENFORM MVI   VTFUPDAT,C'N'     ASSUME LAST OPEN WAS INPUT.       005G 02050000
         TM    DS1DSIND,DS1IND02 CHECK THE OPENED FOR OUTPUT INDIC.005G 02060000
         BNO   OPENEND           LAST OPEN WAS INPUT.              005G 02070000
         MVI   VTFUPDAT,C'Y'     INDICATE LAST OPEN WAS OUTPUT.    005G 02080000
OPENEND  DS    0H                END OF OPEN FORMATTING.           005G 02090000
*                                                                       02100000
*        FORMAT THE CATLG                                               02110000
*                                                                       02120000
         MVI   VTFCATLG,C' ' INITIALIZE IT TO BLANKS                    02130000
         CLI   LOCAT,0        SHOULD WE DO THE LOCATE?                  02140000
         BE    CATEND         NO, SKIP PAST IT                          02150000
         CLI   DS1NOEPV,0     FOR ZERO EXTENTS SKIP LOCATE.        002G 02160000
         BE    CATEND                                              002G 02170000
*                                                                       02180000
*        SET UP THE CAMLST                                              02190000
*                                                                       02200000
         LA    R1,DS1DSNAM    POINT TO THE DSNAME                       02210000
         ST    R1,CAMLOC+4    SAVE IT IN THE CAMLST                     02220000
         LA    R1,LOCWORK     LOCATE WORKAREA                           02230000
         ST    R1,CAMLOC+12   SAVE IT IN THE CAMLST                     02240000
         LOCATE CAMLOC        CHECK THE CATALOG                         02250000
         LTR   R15,R15        TEST THE CATALOG RETURN CODE              02260000
         BZ    CATOK          ZERO, THERE IS AN ENTRY                   02270000
         MVI   VTFCATLG,C'N'  SET CODE FOR NOT CATALOGED                02280000
         CH    R15,H8         SEE IF THAT'S THE CASE                    02290000
         BE    CATEND         YES, LET IT STAND                         02300000
         MVI   VTFCATLG,C'E'  CATALOG ERROR, PROBLEMS                   02310000
*                                                                       02320000
*        CATALOG ENTRY IS THERE, SEE THAT THE VOLUME IS THIS ONE        02330000
*                                                                       02340000
CATOK    MVI   VTFCATLG,C'C'  SET UP AS A GOOD ENTRY                    02350000
         CLC   VOLID,LOCWORK+6  COMPARE THE VOLUME SERIAL NUMBERS       02360000
         BE    CATEND         GOOD, WE'RE DONE                          02370000
         MVI   VTFCATLG,C'W'  WRONG VOLUME, NOT CATALOGED               02380000
CATEND   DS    0H                                                       02390000
*                                                                       02400000
*        FORMAT THE ALLOCATION AND USED QUANTITIES                      02410000
*                                                                       02420000
         SPACE                                                          02430000
*        CHECK THROUGH THE EXTENTS                                      02440000
         SPACE                                                          02450000
         SR    R2,R2          CLEAR A WORK REGISTER                     02460000
         ICM   R2,B'0001',DS1NOEPV  GET THE NUMBER OF EXTENTS           02470000
         BZ    SPACEND        NO EXTENTS MEANS NO SPACE                 02480000
         SR    R4,R4          ZERO THE SPACE COUNTER FOR THE DATA SET   02490000
*                                                                       02500000
*        GET EACH EXTENT AND PROCESS IT                            006G 02510000
*                                                                  006G 02520000
*        SR    R6,R6          FIRST EXTENT                         006G 02530000
*XTNEXT  LR    R5,R6          GET THE CURRENT EXTENT NUMBER        006G 02540000
*        SLL   R5,2           MULTIPLY IT BY FOUR                  006G 02550000
*        EX    R0,GETEXT(R5)  GET THE CORRECT ADDRESS              006G 02560000
         SR    R6,R6         FIRST EXTENT                          006G 02570000
EXTNEXT  LR    R5,R6         GET THE CURRENT EXTENT                006G 02580000
         CH    R5,=H'2'      IS IT IN FMT1 DSCB?                   006G 02590000
         BH    EXTFMT3       NO, IT'S IN FMT3 DSCB.                006G 02600000
         SLL   R5,2          TIMES 4                               006G 02610000
         EX    R0,GETEXT(R5) GET THE EXTENT ADDRESS INTO R5        006G 02620000
         B     EXTGOT                                              006G 02630000
EXTFMT3  DS    0H            MUST PROCESS FMT3 DIFFERENTLY.        006G 02640000
         SH    R5,=H'3'      MAKE IT RELATIVE TO BEGIN FMT3.       006G 02650000
         MH    R5,=H'10'     CALCULATE OFFSET FROM BEGIN FMT3.     006G 02660000
         LA    R5,FMT3(R5)   GET A(CURRENT EXT).                   006G 02670000
EXTGOT   DS    0H            GOT A(EXTENT).                        006G 02680000
*                                                                       02690000
*                                                                       02700000
*        PROCESS THIS EXTENT                                            02710000
*                                                                       02720000
         USING XTDSECT,R5     SET ADDRESSABILITY                        02730000
         CLI   XTFLAGS,XTNOEXT  IS THERE AN EXTENT                      02740000
         BE    NOEXT          NO, THE EXTENT ISN'T THERE                02750000
         CLI   XTFLAGS,XTCYLBD  IS IT ON CYLINDER BOUNDARIES            02760000
         BNE   FORMALOC       NO, DO IT FOR CYLS AND TRACKS             02770000
*                                                                       02780000
*        CYLINDER BOUNDS - BE SURE THE ALLOCATION IS CORRECT            02790000
*                                                                       02800000
         ICM   R1,B'0011',XTLOWHH GET THE LOWER TRACK                   02810000
         BZ    LOWOK          IT'S ZERO                                 02820000
         MVC   VTFACTON(6),=C'CYLERR'  NOTE THE ERROR                   02830000
         MVI   VTFACTON+6,C'L'  ON THE LOW CCHH                         02840000
LOWOK    DS    0H                                                  009G 02850001
*OWOK    LH    R1,XTHIHH      GET THE HIGH TRACK                        02851001
         SR    R1,R1                                               009G 02852001
         ICM   R1,3,XTHIHH    GET THE HIGH TRACK.                  009G 02853001
         LA    R1,1(R1)       ADD ONE FOR ZERO ADDRESSING               02860000
         CH    R1,DS4DEVSZ+2  IS THIS THE NUMBER OF TRACKS/CYL          02870000
         BE    FORMALOC       YES, GO CALCULATE                         02880000
         MVC   VTFACTON(6),=C'CYLERR'  NOTE THE ERROR                   02890000
         MVI   VTFACTON+7,C'H'  ON THE HIGH CCHH                        02900000
*                                                                       02910000
*        GET THE SPACE FOR NON-CYLINDER ALLOCATIONS                     02920000
*                                                                       02930000
FORMALOC DS    0H                                                  009G 02931001
*ORMALOC LH    R1,XTHICC      GET THE HIGH CYLINDER                009G 02940001
         SR    R1,R1                                               009G 02941001
         ICM   R1,3,XTHICC    GET THE HIGH CYLINDER.               009G 02942001
*        SH    R1,XTLOWCC     MINUS THE LOW CYLINDER               009G 02950001
         SR    R8,R8                                               009G 02951001
         ICM   R8,3,XTLOWCC   GET THE LOW CYLINDER.                009G 02952001
         SR    R1,R8          MINUS THE LOW CYLINDER               009G 02953001
         MH    R1,DS4DEVSZ+2  TIMES THE NUMBER OF TRACKS PER CYLINDER   02960000
         LH    R8,XTHIHH      GET THE HIGH TRACK                        02970000
         SH    R8,XTLOWHH     MINUS THE LOW TRACK                       02980000
         AR    R8,R1          TRACKS IN THIS EXTENT ( MINUS 1 )         02990000
         LA    R4,1(R4,R8)    ADD THE TRACKS TOGETHER FOR THIS DATA SET 03000000
*                                                                       03010000
*        GET THE NEXT EXTENT                                            03020000
*                                                                       03030000
NOEXT    LA    R6,1(R6)       INCREMENT THE EXTENT COUNTER              03040000
         CR    R6,R2          CHECK FOR THE END                         03050000
         BL    EXTNEXT        NOT YET, KEEP GOING                       03060000
*                                                                       03070000
*        ALL THE EXTENTS ARE SUMMED REGISTER 4 HAS THE SUM              03080000
*                                                                       03090000
         BAL   R8,SPACUNIT    CHANGE IT TO THE APPROPRIATE UNITS        03100000
         ST    R4,VTFALLOC    STORE IT FOR LATER                        03110000
SPACEND  DS    0H                                                       03120000
*                                                                       03130000
*        GET THE TRACKS USED                                            03140000
*                                                                       03150000
         SR    R4,R4          CLEAR THE TRACK ( WOO WOO )               03160000
         CLC   DS1LSTAR,ZEROES IS THE TRACK USED COUNTER SET?           03170000
         BNE   USEDOK         YES, ACCEPT IT                            03180000
*        NO, SEE IF THE ZERO IS VALID                                   03190000
         TM    DS1DSORG,X'40' IS IT SEQUENTIAL?                         03200000
         BO    USEDOK0        YES,THE ZERO IS VALID                     03210000
         CLC   DSORG(4),ZEROES  MAYBE IT WASN'T EVER OPENED             03220000
         BE    USEDOK0        THEN NO SPACE USED IS OK                  03230000
         TM    DS1DSORG,X'0C' CHECK FOR AN INVALID DSORG                03240000
         BO    USEDOK0        NO SPACE USED IS STILL OK                 03250000
         MVC   VTFUSED,FMIN1  SET A FLAG UNUSED SPACE UNKNOWN           03260000
         B     USEDEND        USED SPACE IS SET                         03270000
*                                                                       03280000
*        THE TRACKS USED COUNTER SEEMS OK                               03290000
*                                                                       03300000
USEDOK   DS    0H                                                  009G 03301001
*SEDOK   LH    R4,DS1LSTAR    GET THE LAST TRACK USED              009G 03310001
         SR    R4,R4                                               009G 03311001
         ICM   R4,3,DS1LSTAR  GET THE LAST TRACK USED.             009G 03312001
         LA    R4,1(R4)       ADD ONE ( ZERO ADDRESSING )               03320000
         BAL   R8,SPACUNIT    CONVERT TO APPROPRIATE UNITS              03330000
USEDOK0  ST    R4,VTFUSED     SAVE THE AMOUNT OF SPACE USED             03340000
USEDEND  DS    0H                                                       03350000
*                                                                       03360000
*        RETURN                                                         03370000
*                                                                       03380000
FORMRET  VTCLEAVE EQ,RC=0                                          003G 03390000
*                                                                       03400000
*                                                                       03410000
         EJECT                                                          03420000
*                                                                       03430000
*        ROUTINES USED ABOVE                                            03440000
*                                                                       03450000
*                                                                       03460000
*        CONVERT FROM TRACKS TO THE APPROPRIATE UNITS                   03470000
*              KBYTES, MBYTES, TRKS, OR CYLS                            03480000
*                                                                       03490000
SPACUNIT LH    R1,SPACEK      GET THE UNIT TYPE                         03500000
         SLL   R1,2           MULTIPLY BY 4                             03510000
         B     *+4(R1)        THEN BRANCH TO THE CORRECT ROUTINE        03520000
         B     SPACKB         R1=0  KILOBYTES                           03530000
         B     SPACKB         R1=1  KILOBYTES                           03540000
         B     SPACMB         R1=2  MEGABYTES                           03550000
         B     SPACTRK        R1=3  TRACKS                              03560000
         B     SPACCYL        R1=4  CYLINDERS                           03570000
*        TRACKS                                                         03580000
SPACTRK  BR    R8             WAS SET WHEN WE STARTED                   03590000
*        CYLINDERS                                                      03600000
SPACCYL  SR    R0,R0          CLEAR A REGISTER                          03610000
         LR    R1,R4          GET THE NUMBER OF TRACKS                  03620000
         LH    R4,DS4DEVSZ+2  GET THE NUMBER OF TRACKS PER CYLINDER     03630000
         SRL   R4,2           DIVIDE BY 2 FOR ROUNDING                  03640000
         AR    R1,R4          ADD IT IN                                 03650000
         LH    R4,DS4DEVSZ+2  GET THE NUMBER OF TRACKS PER CYLINDER     03660000
         DR    R0,R4          DIVIDE TO GET ROUNDED CYLINDERS           03670000
         LR    R4,R1          GET THE ANSWER BACK INTO R4               03680000
         BR    R8             THEN RETURN                               03690000
*        KILOBYTES                                                      03700000
*SPACKB   MH    R4,DS4DEVTK    MULTIPLY BY BYTES PER TRACK         007G 03710000
SPACKB   SR    R0,R0          CLEAR WORK REG.                      007G 03720000
         ICM   R0,3,DS4DEVTK  GET TRACK LENGTH.                    007G 03730000
         ST    R0,WORKWORD    SAVE IT.                             007G 03740000
         LR    R1,R4          GET VALUE TO BE MULTIPLIED.          007G 03750000
         M     R0,WORKWORD    MULTIPLY BY BYTES PER TRACK.         007G 03760000
         SR    R0,R0          CLEAR THE TOP                             03770000
*        LR    R1,R4          GET THE NUMBER TO DIVIDE             007G 03780000
         A     R1,F500        ADD UP TO ROUND                           03790000
         D     R0,F1000       DIVIDE TO GET KILOBYTES                   03800000
         LR    R4,R1          GET THE ANSWER BACK INTO R4               03810000
         BR    R8             THEN RETURN                               03820000
*        MEGABYTES                                                      03830000
*SPACMB   MH    R4,DS4DEVTK    MULTIPLY BY BYTES PER TRACK         007G 03840000
SPACMB   SR    R0,R0          CLEAR WORK REG.                      007G 03841000
         ICM   R0,3,DS4DEVTK  GET TRACK LENGTH.                    007G 03842000
         ST    R0,WORKWORD    SAVE IT.                             007G 03843000
         LR    R1,R4          GET VALUE TO BE MULTIPLIED.          007G 03843100
         M     R0,WORKWORD    MULTIPLY BY BYTES PER TRACK.         007G 03843200
         SR    R0,R0          CLEAR THE TOP                             03843300
*        LR    R1,R4          GET THE NUMBER TO DIVIDE             007G 03843400
         A     R1,F500000     ADD UP TO ROUND                           03843500
         D     R0,F1000000    DIVIDE TO GET MEGABYTES                   03843600
         LR    R4,R1          GET THE ANSWER BACK INTO R4               03843700
         BR    R8             THEN RETURN                               03843800
*                                                                       03843900
*        GET A NEW BLOCK OF MAIN STORAGE                                03844000
*                                                                       03845000
GOGETMN  GETMAIN R,LV=VTCGETMS  GET SOME                                03846000
         ST    R1,VTCCURAD    SET UP THE AVAILABLE ADDRESS              03847000
         LA    R2,VTCGETMS/1024   GET THE SIZE OF THE BLOCK IN K        03848000
         SLL   R2,10          GET IT INTO BYTES ( TIMES 1024 )          03849000
         ST    R2,VTCCURLN    SO THE FORMATTED DSCB'S CAN USE IT        03850000
*                                                                       03860000
*        SAVE THE BLOCK ADDRESS IN THE VTCGETMN TABLE                   03870000
*                                                                       03880000
         LA    R2,VTCGETMN    POINT TO THE TABLE                        03890000
         LA    R5,VTCGETMX    GET THE NUMBER OF ENTRIES IN THE TABLE    03900000
GOGETTAB ICM   R3,B'1111',0(R2) GET THIS ENTRY                          03910000
         BNZ   GOGETINC       IF NOT ZERO, KEEP LOOKING                 03920000
         ST    R1,0(R2)       SAVE THE NEW ENTRY                        03930000
         B     FORMFIT        THEN GO ALLOCATE A FORMATTED DSCB         03940000
*                                                                       03950000
*        THIS ENTRY WAS TAKEN, GET THE NEXT ONE                         03960000
*                                                                       03970000
GOGETINC LA    R2,4(R2)       POINT TO THE NEXT ENTRY                   03980000
         BCT   R5,GOGETTAB    COUNT AND LOOP                            03990000
*                                                                       04000000
*        TABLE OVERFLOW  - ISSUE ERROR MSG                              04010000
*              SET A FLAG TO STOP INPUT                                 04020000
*                                                                       04030000
         VTOCMSG TABOVFLW,TABOVSEC  ISSUE A MESSAGE                     04040000
         MVI   TABFULL,255    SET A STOP FLAG                           04050000
         B     FORMRET        RETURN FROM FORMATTING                    04060000
         EJECT                                                          04070000
*                                                                       04080000
*                                                                       04090000
*                                                                       04100000
*        PROGRAM CONSTANTS                                              04110000
*                                                                       04120000
         SPACE                                                          04130000
*        INSTRUCTIONS EXECUTED TO GET THE NEXT EXTENT                   04140000
GETEXT   LA    R5,DS1EXT1        1ST EXTENT                             04150000
         LA    R5,DS1EXT2        2ND EXTENT                             04160000
         LA    R5,DS1EXT3        3RD EXTENT                             04170000
*        LA    R5,DS3EXTNT+00    4TH EXTENT                        006G 04180000
*        LA    R5,DS3EXTNT+10    5TH EXTENT                        006G 04190000
*        LA    R5,DS3EXTNT+20    6TH EXTENT                        006G 04200000
*        LA    R5,DS3EXTNT+30    7TH EXTENT                        006G 04210000
*        LA    R5,DS3ADEXT+00    8TH EXTENT                        006G 04220000
*        LA    R5,DS3ADEXT+10    9TH EXTENT                        006G 04230000
*        LA    R5,DS3ADEXT+20   10TH EXTENT                        006G 04240000
*        LA    R5,DS3ADEXT+30   11TH EXTENT                        006G 04250000
*        LA    R5,DS3ADEXT+40   12TH EXTENT                        006G 04260000
*        LA    R5,DS3ADEXT+50   13TH EXTENT                        006G 04270000
*        LA    R5,DS3ADEXT+60   14TH EXTENT                        006G 04280000
*        LA    R5,DS3ADEXT+70   15TH EXTENT                        006G 04290000
*        LA    R5,DS3ADEXT+80   16TH EXTENT                        006G 04300000
MOVEDSN  MVC   VTFDSN(0),DS1DSNAM   EXECUTED COMPARE                    04310000
ZEROES   DC    2F'0'                                                    04320000
FMIN1    DC    F'-1'                                                    04330000
F500     DC    F'500'                                                   04340000
F1000    DC    F'1000'                                                  04350000
F500000  DC    F'500000'                                                04360000
F1000000 DC    F'1000000'                                               04370000
BLANKS   DC    CL8'                '                                    04380000
CAMCONST CAMLST NAME,*,,*                                               04390000
H8       DC    H'8'                                                     04400000
SECAL    DC    C'ABTC'        SECONDARY ALLOCATION CODES                04410000
*              ABSOLUTE TRK, BLOCKS, TRACKS, CYLINDERS                  04420000
*                                                                       04430000
*                                                                       04440000
*                                                                       04450000
*                                                                       04460000
*        PROGRAM MESSAGES                                               04470000
*                                                                       04480000
TABOVFLW VTCMSG ' THE VTOC TABLES (1.6 MEG) ARE NOT LARGE ENOUGH TO HANX04490000
               DLE THIS REQUEST'                                   001G 04500000
TABOVSEC VTCMSG ' PARTIAL PROCESSING WILL CONTINUE '               001G 04510000
*                                                                       04520000
*                                                                       04530000
*                                                                       04540000
*                                                                       04550000
*                                                                       04560000
*                                                                       04570000
         EJECT                                                          04580000
*                                                                       04590000
*                                                                       04600000
*        P A R S E   C O N T R O L   L I S T                            04610000
*                                                                       04620000
*                                                                       04630000
         COPY  VTCPARS                                             003G 04640000
*                                                                       04650000
*        DYNAMIC WORK AREA                                              04660000
*                                                                       04670000
         SPACE 3                                                        04680000
FORMWORK DSECT                                                          04690000
         DS    18A            PRINT ROUTINE SAVE AREA                   04700000
FIRSTFRM DS    X              INITIALIZATION FOR THIS ROUTINE           04710000
CHARS    DS    CL16           CONVERSION TO CHARACTERS                  04720000
CAMLOC   CAMLST NAME,*,,*                                               04730000
CAMLEN   EQU   *-CAMLOC                                                 04740000
         DS    0D                                                       04750000
LOCWORK  DS    265C                                                     04760000
         SPACE                                                          04770000
         DS    0D                                                       04780000
WORKWORD DS    F                                                   007G 04790000
LENWORK  EQU   *-FORMWORK                                               04800000
*                                                                       04810000
*        VTOC COMMAND COMMON AREA                                       04820000
*                                                                       04830000
         VTCCOM                                                    003G 04840000
         SPACE 3                                                        04850000
*                                                                       04860000
*        FORMATTED DSCB                                                 04870000
*                                                                       04880000
         VTCFMT                                                    003G 04890000
         SPACE 3                                                        04900000
         VTCPDEDS                                                  003G 04910000
         SPACE 3                                                        04920000
         SPACE 3                                                        04930000
DSCB1    DSECT                                                          04940000
         IECSDSL1 1                                                     04950000
         SPACE 3                                                        04960000
*        FORMAT 1 AND 3 EXTENT DESCRIPTION                              04970000
XTDSECT  DSECT                                                          04980000
XTFLAGS  DS    X                                                        04990000
XTNOEXT  EQU   X'00'          NO EXTENT                                 05000000
XTDATAB  EQU   X'01'          DAT BLOCKS                                05010000
XTOVFLW  EQU   X'02'          OVERFLOW AREA                             05020000
XTINDEX  EQU   X'04'          INDEX AREA                                05030000
XTUSRLAB EQU   X'40'          USER LABEL EXTENT                         05040000
XTSHRCYL EQU   X'80'          SHARING CYLINDERS                         05050000
XTCYLBD  EQU   X'81'          CYLINDER BOUNDARIES                       05060000
XTSEQ    DS    X              EXTENT SEQUENCE NUMBER                    05070000
XTLOWCC  DS    H              LOWER CYLINDER                            05080000
XTLOWHH  DS    H              LOWER TRACK                               05090000
XTHICC   DS    H              UPPER CYLINDER                            05100000
XTHIHH   DS    H              UPPER TRACK                               05110000
         END                                                            05120000
