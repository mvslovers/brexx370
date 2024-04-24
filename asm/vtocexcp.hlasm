         TITLE 'VTOCEXCP- VTOC READING SUBROUTINE'                      00010000
*********************************************************************** 00020000
*        SPACE                                                          00030000
* AUTHOR;  R. F. MORSE, MIT INSTRUMENTATION LABORATORY  AUG 5,1968.     00040000
* MODIFIED;   E.BANK, FIREMAN'S FUND  MAY 15,1975.                      00050000
* MODIFIED;   R.MILLER  FIREMAN'S FUND  MAR 20,1977.                    00060000
* MODIFICATIONS                                                         00070003
* NUMBER    DATE    PERSON    REASON                                    00080003
*  001K    072178   KOUBA     LINE 5117000 CHANGED TO UNIT=SYSALLDA     00090003
*                              TO ALLOW ACCESS TO OUR PRODUCTION PACKS. 00100003
*  002G    072278   GATES     CHANGE MSG MACROS TO VTCMSG TO AVOID      00110003
*                              CONFLICT WITH EXISTING MSG MACRO.        00120003
*  003G    012082   GATES     FIX DYNAMIC ALLOCATION RETURN CODE SAVE,  00130003
*                              WAS GIVING ERRONEOUS DYNAMIC ALLOC RET   00140003
*                              CODE.                                    00150003
*  004G    111883   GATES     PUT VOLID IN ERROR MESSAGES.              00160007
*  005G    112983   GATES     IF ADDR IS ZEROS ASSUME 3330V UNIT TYPE.  00170010
*  006G    120283   GATES     IF ADDR IS NON ZEROS USE ADDRESS INSTEAD  00180014
*                              OF SYSALLDA UNIT NAME.                   00190014
*  007G    120283   GATES     PUT VOLID IN TRACKERR MESSAGE.            00200014
*  008G    050284   GATES     RENAME VTOCOM MACRO TO VTCCOM,            00210015
*                              RENAME VTLEAVE MACRO TO VTCLEAVE,        00220015
*                              RENAME ENTER TO VTCENTER,                00230018
*                              RENAME ALLOC TO VTCALLOC,                00240018
*                              RENAME FREE TO VTCFREE,                  00250018
*                              RENAME DYNSPACE TO VTCDYNSP,             00260018
*                              RENAME S99FAIL TO VTCS99NG,              00270018
*                              VTOC MORE TRANSPORTABLE.                 00280015
*  009G    050384   GATES     EMBED THE FOLLOWING MACROS TO MAKE        00290019
*                              VTOC MORE TRANSPORTABLE:                 00300019
*                              RCPDSN,RCPDDNRT,RCPUNIT,RCPDISP,         00310019
*                              RCPSR2,RCPDDN,RCPUNALC,RCPDINC,          00320019
*                              RCPVCHAR, RCPFDDN,                       00330020
*                              RCPTUBFR, AND RCPBTU.                    00340019
*                                                                       00350003
*                                                                       00360003
* FUNCTION; THIS SUBROUTINE READS THE VOLUME TABLE OF CONTENTS (VTOC)   00370000
*        FROM A DIRECT-ACCESS DEVICE AND PRESENTS IT TO THE CALLER      00380000
*        ONE RECORD (DSCB) AT A TIME.                                   00390000
*                                                                       00400000
* OPERATION; THIS ROUTINE IS A SPECIALIZED SEQUENTIAL ACCESS METHOD     00410000
*        FOR VTOC'S.  ITS ADVANTAGE OVER ORDINARY BSAM IS THAT IT READS 00420000
*        AN ENTIRE TRACK IN ONE REVOLUTION, THUS SAVING CONSIDERABLE    00430000
*        TIME.  THE ROUTINE HAS THREE CALL MODES;                       00440000
*                                                                       00450000
*        0 - READ.  RETURNS WITH THE CORE ADDRESS OF A DSCB IN THE 3RD  00460000
*              PARAMETER.  THE CORE CONSISTS OF 148 CONSECUTIVE BYTES,  00470000
*              CONTAINING THE COUNT (8 BYTES), KEY (44 BYTES), AND DATA 00480000
*              (96 BYTES) FOR ONE DSCB.  RETURN CODES (REGISTER 15)     00490000
*              ARE;                                                     00500000
*                      0 - NORMAL;                                      00510000
*                      4 - END OF FILE, NO DATA PRESENTED;              00520000
*                      8 - PERMANENT I/O ERROR.  THE KEY AND DATA AREAS 00530000
*                          WILL BE SET TO ZEROS; THE COUNT AREA WILL    00540000
*                          CONTAIN THE CORRECT CCHHR.  SINCE READING    00550000
*                          IS DONE A TRACK AT A TIME, ALL THE DSCB'S    00560000
*                          FOR THAT TRACK WILL BE MARKED IN ERROR.      00570000
*                          READING MAY CONTINUE ON TO THE NEXT TRACK.   00580000
*                                                                       00590000
*        1 - OPEN.  THE SECOND PARAMETER SHOULD POINT TO                00600000
*              A  6-BYTE FIELD CONTAINING THE VOLSER TO BE USED FOR THE 00610000
*              ALLOCATION.                                              00620000
*              RETURN CODES ( REG 15 )  ARE DIRECT FROM DYNAMIC ALLOC.  00630000
*                      0 - NORMAL;                                      00640000
*                      4 - UNABLE TO OPEN (PROBABLY MISSING DD CARD);   00650000
*                      8 - DD CARD DID NOT REFER TO A DIRECT-ACCESS     00660000
*                          DEVICE, OR DEVICE TYPE UNKNOWN.              00670000
*                                                                       00680000
*        2 - CLOSE.  NO ARGUMENTS ARE REQUIRED OR RETURNED.  RETURN     00690000
*              CODE ( REG 15 ) IS FROM DYNAMIC UNALLOCATION.            00700000
         SPACE                                                          00710000
* ENTRY POINTS:  ENTRY IS ALWAYS TO 'VTOCEXCP'.                         00720000
*        ARGUMENTS ARE:                                                 00730000
*                      1 - A(FULL-WORD BINARY ENTRY TYPE);              00740000
*                      2 - A(PTR FOR DSCB);                             00750000
*                      3 - A(VOLSER).                                   00760000
* DATA SETS:  READS VOLUME TABLE OF CONTENTS FROM ANY DIRECT-ACCESS     00770000
*        DEVICE.  USES EXCP TO EXECUTE A CHAINED CHANNEL PROGRAM TO     00780000
*        READ AN ENTIRE TRACK AT A TIME.                                00790000
*                                                                       00800000
* EXTERNAL ROUTINES:  USES SUPERVISOR ROUTINE 'IECPCNVT' TO CONVERT     00810000
*        A RELATIVE TRACK NUMBER TO AN ABSOLUTE ADDRESS.                00820000
         SPACE                                                          00830000
* EXITS - NORMAL;  RETURNS TO CALLER VIA R14 WITH RETURN                00840000
*        CODE IN REGISTER 15.       (SEE ABOVE FOR RETURN CODE VALUES.) 00850000
*                                                                       00860000
* TABLES AND WORK AREAS;  USES AN AREA PROVIDED BY THE CALLER FOR       00870000
*        ITS SAVEAREA AND FOR WORKING STORAGE IMMEDIATELY FOLLOWING     00880000
*        THE PRIOR SAVEAREA.  IT USES GETMAIN TO OBTAIN AN AREA FOR     00890000
*        THE DSCB'S TO BE READ INTO.  THIS COULD BE AS LARGE AS         00900000
*        8K FOR 3350'S.  IT IS FREED BY THE FINAL CALL.                 00910000
*                                                                       00920000
* ATTRIBUTES;  REENTRANT, REFRESHABLE.                                  00930000
         EJECT                                                          00940000
         MACRO                                                          00950019
         RCPDSN &DSN,&MEM                                               00960019
         LCLC  &MEMBER                                                  00970019
         GBLC  &DYNP                                                    00980019
         SPACE                                                          00990019
*********************************************************************** 01000019
**   BUILD THE DSNAME TEXT UNIT                                      ** 01010019
*********************************************************************** 01020019
         AIF   ('&DSN'(1,1) EQ '''').Q                                  01030019
         AIF   ('&DSN'(K'&DSN,1) EQ '/').BD                             01040019
         AIF   ('&DSN'(1,1) EQ '(').REG                                 01050019
         AIF   ('&DSN'  EQ '*').TERM                                    01060019
         RCPSR2                                                         01070019
         L     R14,&DSN                LOAD ADDRESS OF DSNAME           01080019
         LH    R2,&DSN+4               LOAD LENGTH OF DSNAME            01090019
.STH     STH   R2,S99TULNG             STORE DSNAME LENGTH              01100019
         BCTR  R2,0                    DECREMENT FOR EXECUTE            01110019
         EX    R2,&DYNP.MVC            MOVE DSNAME                      01120019
         MVI   S99TUKEY+1,DALDSNAM     MOVE IN DSNAME KEY               01130019
         MVI   S99TUNUM+1,1            SET NUMBER FIELD                 01140019
         RCPDINC 50                                                     01150019
         AGO   .TMEMBER                                                 01160019
.REG     L     R14,0&DSN               LOAD ADDRESS OF DSNAME           01170019
         RCPSR2                                                         01180019
         LH    R2,4&DSN                LOAD LENGTH OF DSNAME            01190019
         AGO   .STH                                                     01200019
.TERM    MVI   S99TUKEY+1,DALTERM                                       01210019
         RCPDINC 4                                                      01220019
         MEXIT                                                          01230019
.BD      RCPTUBFR DALDSNAM,50,&DSN                                      01240019
         AGO   .TMEMBER                                                 01250019
.Q       RCPBTU DALDSNAM,1,&DSN                                         01260019
.TMEMBER AIF   ('&MEM' EQ '').EXIT                                      01270019
         SPACE                                                          01280019
*********************************************************************** 01290019
**   BUILD THE MEMBER NAME TEXT UNIT                                 ** 01300019
*********************************************************************** 01310019
&MEMBER  SETC  '&MEM'                                                   01320019
         AIF   ('&MEM' NE '*').MOK                                      01330019
         AIF   ('&DSN'(1,1) NE '''').MAST                               01340019
         MNOTE 8,'MEMBER=* INVALID WITH QUOTED DSNAME'                  01350019
         MEXIT                                                          01360019
.MAST    ANOP                                                           01370019
&MEMBER  SETC  '8+&DSN'                                                 01380019
.MOK     ANOP                                                           01390019
         AIF   ('&MEMBER'(K'&MEMBER,1) EQ '/').BM                       01400019
         RCPSR2                                                         01410019
         AIF   ('&MEMBER'(1,1) EQ '(').RM                               01420019
         LH    R2,4+&MEMBER            LOAD LENGTH OF MEMBER NAME       01430019
         LTR   R2,R2                   TEST FOR ZERO                    01440019
         BZ    *+30                    IF NO MEMBER, SKIP               01450019
         L     R14,&MEMBER             LOAD ADDRESS OF MEMBER           01460019
         AGO   .STHM                                                    01470019
.RM      LH    R2,4&MEMBER             LOAD LENGTH OF MEMBER            01480019
         LTR   R2,R2                   AND TEST FOR ZERO                01490019
         BZ    *+30                    IF NO MEMBER, SKIP               01500019
         L     R14,0&MEMBER            LOAD ADDRESS OF MEMBER           01510019
.STHM    STH   R2,S99TULNG             STORE LENGTH OF MEMBER           01520019
         BCTR  R2,0                    DECREMENT FOR EXECUTE            01530019
         EX    R2,&DYNP.MVC            MOVE IN MEMBER NAME              01540019
         MVI   S99TUKEY+1,DALMEMBR     MOVE IN MEMBER KEY               01550019
         MVI   S99TUNUM+1,1            SET NUMBER FIELD                 01560019
         RCPDINC 14                                                     01570019
         MEXIT                                                          01580019
.BM      RCPTUBFR DALMEMBR,14,&MEMBER                                   01590019
         MEXIT                                                          01600019
.QM      RCPBTU DALMEMBR,1,&MEMBER                                      01610019
.EXIT    MEND                                                           01620019
         MACRO                                                          01630019
         RCPDDNRT                                                       01640019
         SPACE 1                                                        01650019
*********************************************************************** 01660019
**    DDNAME RETURN TEXT UNIT                                        ** 01670019
*********************************************************************** 01680019
         MVI   S99TUKEY+1,DALRTDDN     SET RETURN DDNAME KEY            01690019
         MVI   S99TUNUM+1,1            SET NUMBER FIELD                 01700019
         MVI   S99TULNG+1,8            SET LENGTH FIELD                 01710019
         MVC   S99TUPAR(8),=CL8' '     INITIALIZE FIELD TO BLANKS       01720019
         RCPDINC 14                                                     01730019
         MEND                                                           01740019
         MACRO                                                          01750019
         RCPUNIT &U,&V                                                  01760019
         GBLC  &DYNP                                                    01770019
         AIF   ('&U' EQ '').TVOL                                        01780019
         SPACE 1                                                        01790019
*********************************************************************** 01800019
**       UNIT NAME TEXT UNIT                                         ** 01810019
*********************************************************************** 01820019
         RCPVCHAR DALUNIT,14,&U                                         01830019
.TVOL    AIF   ('&V' EQ '').EXIT                                        01840019
         SPACE 1                                                        01850019
*********************************************************************** 01860019
**       VOLUME SERIAL TEXT UNIT                                     ** 01870019
*********************************************************************** 01880019
         RCPVCHAR DALVLSER,14,&V                                        01890019
.EXIT    MEND                                                           01900019
         MACRO                                                          01910019
         RCPDISP &DISP                                                  01920019
         LCLA  &I                                                       01930019
         LCLB  &B(4)                                                    01940019
         AIF   ('&DISP(1)' EQ '').TD2                                   01950019
         SPACE                                                          01960019
*********************************************************************** 01970019
**     DATA SET INITIAL STATUS                                       ** 01980019
*********************************************************************** 01990019
&B(1)    SETB  ('&DISP(1)' EQ 'SHR')                                    02000019
&B(2)    SETB  ('&DISP(1)' EQ 'NEW')                                    02010019
&B(3)    SETB  ('&DISP(1)' EQ 'MOD')                                    02020019
&B(4)    SETB  ('&DISP(1)' EQ 'OLD')                                    02030019
         AIF   (&B(1) OR &B(2) OR &B(3) OR &B(4)).OK1                   02040019
         MNOTE 8,'&DISP(1) IS INVALID, DISP=SHR USED'                   02050019
&B(1)    SETB  1                                                        02060019
.OK1     ANOP                                                           02070019
&I       SETA  8*&B(1)+4*&B(2)+2*&B(3)+&B(4)                            02080019
         MVC   S99TUKEY(8),=Y(DALSTATS,1,1,X'0&I.00')                   02090019
         RCPDINC 8                                                      02100019
.TD2     AIF   ('&DISP(2)' EQ '').TD3                                   02110019
         SPACE                                                          02120019
*********************************************************************** 02130019
**    DATA SET NORMAL DISPOSITION                                    ** 02140019
*********************************************************************** 02150019
&B(1)    SETB  ('&DISP(2)' EQ 'KEEP')                                   02160019
&B(2)    SETB  ('&DISP(2)' EQ 'DELETE')                                 02170019
&B(3)    SETB  ('&DISP(2)' EQ 'CATLG')                                  02180019
&B(4)    SETB  ('&DISP(2)' EQ 'UNCATLG')                                02190019
         AIF   (&B(1) OR &B(2) OR &B(3) OR &B(4)).OK2                   02200019
         MNOTE 8,'&DISP(2) IS INVALID, DISP=(,KEEP) USED'               02210019
&B(1)    SETB  1                                                        02220019
.OK2     ANOP                                                           02230019
&I       SETA  8*&B(1)+4*&B(2)+2*&B(3)+&B(4)                            02240019
         MVC   S99TUKEY(8),=Y(DALNDISP,1,1,X'0&I.00')                   02250019
         RCPDINC 8                                                      02260019
.TD3     AIF   ('&DISP(3)' EQ '').EXIT                                  02270019
         SPACE                                                          02280019
*********************************************************************** 02290019
**   DATASET CONDITIONAL DISPOSITION                                 ** 02300019
*********************************************************************** 02310019
&B(1)    SETB  ('&DISP(3)' EQ 'KEEP')                                   02320019
&B(2)    SETB  ('&DISP(3)' EQ 'DELETE')                                 02330019
&B(3)    SETB  ('&DISP(3)' EQ 'CATLG')                                  02340019
&B(4)    SETB  ('&DISP(3)' EQ 'UNCATLG')                                02350019
         AIF   (&B(1) OR &B(2) OR &B(3) OR &B(4)).OK3                   02360019
         MNOTE 8,'&DISP(3) IS INVALID, DISP=(,,KEEP) USED'              02370019
&B(1)    SETB  1                                                        02380019
.OK3     ANOP                                                           02390019
&I       SETA  8*&B(1)+4*&B(2)+2*&B(3)+&B(4)                            02400019
         MVI   S99TUKEY(8),=Y(DALCDISP,1,1,X'0&I.00')                   02410019
         RCPDINC 8                                                      02420019
.EXIT    MEND                                                           02430019
         MACRO                                                          02440019
         RCPSR2 &A                                                      02450019
         GBLB  &RCPSR2                                                  02460019
         GBLC  &DYNP                                                    02470019
         LCLC  &C                                                       02480019
.*   TO SAVE REG 2 IN REG 0 FOR ALLOC INNER MACROS FIRST TIME ONLY      02490019
.*    IF OPERAND SUPPLIED AND SAVE DONE, RESTORES REG 2 AND             02500019
.*    GENERATES MOVE INSTRUCTION FOR EXECUTE                            02510019
         AIF   ('&A' NE '').UNSAVE                                      02520019
         AIF   (&RCPSR2).EXIT                                           02530019
&RCPSR2  SETB  1                                                        02540019
         LR    R0,R2                   SAVE CONTENTS OF REGISTER 2      02550019
         MEXIT                                                          02560019
.UNSAVE  AIF   (NOT &RCPSR2).EXIT                                       02570019
         B     *+10                    SKIP NEXT INSTRUCTION            02580019
&C       SETC  '&DYNP.MVC'                                              02590019
&C       MVC   S99TUPAR(0),0(R14)      EXECUTED MOVE                    02600019
         LR    R2,R0                   RESTORE CONTENTS OF REGISTER 2   02610019
&RCPSR2  SETB  0                                                        02620019
.EXIT    MEND                                                           02630019
         MACRO                                                          02640019
         RCPDDN &DDN                                                    02650019
         GBLC  &DYNP                                                    02660019
         SPACE 1                                                        02670019
*********************************************************************** 02680019
**   BUILD THE DDNAME TEXT UNIT                                      ** 02690019
*********************************************************************** 02700019
         AIF   ('&DDN'(K'&DDN,1) EQ '/').BTU                            02710019
         AIF   ('&DDN'(1,1) EQ '''').Q                                  02720019
         RCPSR2                                                         02730019
         AIF   ('&DDN'(1,1) EQ '(').R                                   02740019
         L     R14,&DDN                LOAD ADDRESS OF DDNAME           02750019
         LH    R2,&DDN+4               LOAD LENGTH OF DDNAME            02760019
         AGO   .STH                                                     02770019
.R       L     R14,0&DDN               LOAD ADDRESS OF DDNAME           02780019
         LH    R2,4&DDN                LOAD LENGTH OF DDNAME            02790019
.STH     STH   R2,S99TULNG             STORE DDNAME LENGTH              02800019
         BCTR  R2,0                    DECREMENT FOR EXECUTE            02810019
         EX    R2,&DYNP.MVC            MOVE DDNAME                      02820019
         MVI   S99TUKEY+1,DALDDNAM     MOVE IN DDNAME KEY               02830019
         MVI   S99TUNUM+1,1            SET NUMBER FIELD                 02840019
         RCPDINC 14                                                     02850019
         MEXIT                                                          02860019
.Q       RCPBTU DALDDNAM,1,&DDN                                         02870019
         MEXIT                                                          02880019
.BTU     RCPTUBFR DALDDNAM,14,&DDN                                      02890019
         MEND                                                           02900019
         MACRO                                                          02910019
         RCPUNALC                                                       02920019
         SPACE 1                                                        02930019
*********************************************************************** 02940019
**     FREE EVEN IF PERMANENTLY ALLOCATED                            ** 02950019
*********************************************************************** 02960019
         MVI   S99TUKEY+1,DUNUNALC     SET TEXT UNIT KEY                02970019
         RCPDINC  4                                                     02980019
         MEND                                                           02990019
         MACRO                                                          03000019
         RCPDINC &L1                                                    03010019
         GBLA  &DTUO,&DTUPO                                             03020019
         GBLC  &DYNP                                                    03030019
         AIF   ('&L1' EQ '').T2                                         03040019
         ST    R15,&DYNP.TUP+&DTUPO    STORE TEXT UNIT ADDRESS          03050019
         LA    R15,&L1.(R15)           BUMP TEXT UNIT PTR TO NEXT SLOT  03060019
&DTUPO   SETA  &DTUPO+4                                                 03070019
&DTUO    SETA  &DTUO+&L1                                                03080019
         MEXIT                                                          03090019
.T2      ST    R14,&DYNP.TUP+&DTUPO    STORE TEXT UNIT ADDRESS          03100019
&DTUPO   SETA  &DTUPO+4                                                 03110019
         MEND                                                           03120019
         MACRO  - BUILD TEXT UNIT FROM BUFFER                           03130019
         RCPTUBFR &KEY,                TEXT UNIT KEY                   X03140019
               &L,                     MAXIMUM LENGTH VALUE            X03150019
               &C,                     TEXT UNIT                       X03160019
               &N=1                    TEXT UNIT NUMBER                 03170019
         GBLC  &EXECNAM                                                 03180019
         LCLC  &C1,&C2                                                  03190019
         LCLA  &I,&K                                                    03200019
         MVI   S99TUKEY+1,&KEY         SET TEXT UNIT KEY                03210019
         AIF   ('&N' EQ '' OR '&N' EQ '1').N1                           03220019
         LA    R14,&N                  LOAD TEXT UNIT NUMBER            03230019
         STH   R14,S99TUNUM             AND STORE INTO TEXT UNIT        03240019
         AGO   .ENDN                                                    03250019
.N1      MVI   S99TUNUM+1,1            SET TEXT UNIT NUMBER             03260019
.ENDN    ANOP                                                           03270019
&K       SETA  K'&C                                                     03280019
&I       SETA  &K-1                                                     03290019
.LOOP1   ANOP                                                           03300019
&K       SETA  &K-1                                                     03310019
         AIF   (&K LE 0).STD                                            03320019
         AIF   ('&C'(&K,1) NE '/').LOOP1                                03330019
&C2      SETC  '&C'(&K+1,&I-&K)                                         03340019
&C1      SETC  '&C'(1,&K-1)                                             03350019
         AIF   ('&C1'(1,1) NE '(').TC2                                  03360019
&C1      SETC  '0&C1'                                                   03370019
.TC2     AIF   ('&C2' EQ '0000').V2B                                    03380019
         AIF   ('&C2' EQ '00').V1B                                      03390019
         AIF   ('&C2' EQ '0').V0B                                       03400019
         AIF   ('&C2'(1,1) EQ '(').RL                                   03410019
         MVI   S99TULNG+1,&C2          SET LENGTH FIELD                 03420019
         MVC   S99TUPAR(&C2.),&C1      MOVE IN TEXT UNIT                03430019
         RCPDINC &L                                                     03440019
         MEXIT                                                          03450019
.STD     ANOP                                                           03460019
&K       SETA  &L-6                                                     03470019
         MVI   S99TULNG+1,&K           SET TEXT UNIT LENGTH             03480019
&C1      SETC  '&C'(1,&I)              REMOVE TRAILING SLASH            03490019
         MVC   S99TUPAR(&K),&C1        MOVE IN TEXT UNIT                03500019
         RCPDINC &L                                                     03510019
         MEXIT                                                          03520019
.V2B     LH    R14,&C1                 LOAD TEXT UNIT LENGTH            03530019
         S     R14,=A(4)               EXCLUDE LENGTH OF HEADER         03540019
&C1      SETC  '4+&C1'                                                  03550019
         AGO   .MOVE                                                    03560019
.V1B     LH    R14,&C1                 LOAD TEXT UNIT LENGTH            03570019
&C1      SETC  '2+&C1'                                                  03580019
         AGO   .MOVE                                                    03590019
.V0B     SLR   R14,R14                 CLEAR FOR IC                     03600019
         IC    R14,&C1                 INSERT TEXT UNIT LENGTH          03610019
&C1      SETC  '1+&C1'                                                  03620019
         AGO   .MOVE                                                    03630019
.RL      ANOP                                                           03640019
&C2      SETC  '&C2'(2,K'&C2-2)                                         03650019
         LR    R14,&C2                 LOAD TEXT UNIT LENGTH            03660019
.MOVE    STH   R14,S99TULNG             AND STORE INTO LENGTH FIELD     03670019
         BCTR  R14,0                   GET MACHINE LENGTH               03680019
         EXECUTE ,MVC,S99TUPAR-S99TUNIT(0,R15),&C1                      03690019
         EX    R14,&EXECNAM            MOVE IN TEXT UNIT                03700019
         RCPDINC &L                                                     03710019
         MEND                                                           03720019
         MACRO                                                          03730019
         RCPBTU &KEY,&NUM,&PAR                                          03740019
         LCLA  &L                                                       03750019
.*                                                                      03760019
.*  INNER MACRO FOR ALLOC, TO GENERATE TEXT UNITS ENTERED               03770019
.*  IN QUOTES                                                           03780019
.*                                                                      03790019
&L       SETA  K'&PAR-2                GET LENGTH OF TEXT UNIT          03800019
         MVI   S99TUKEY+1,&KEY         SET TEXT UNIT KEY                03810019
         MVI   S99TUNUM+1,&NUM         SET NUMBER FIELD                 03820019
         MVI   S99TULNG+1,&L           MOVE IN LENGTH                   03830019
         MVC   S99TUPAR(&L.),=C&PAR    MOVE IN TEXT UNIT                03840019
&L       SETA  &L+6                                                     03850019
         AIF   (&L/2 EQ (&L+1)/2).LOK                                   03860019
&L       SETA  &L+1                                                     03870019
.LOK     RCPDINC &L                                                     03880019
         MEND                                                           03890019
         MACRO                                                          03900020
         RCPVCHAR &KEY,&LEN,&C,&N=1                                     03910020
         GBLC  &DYNP                                                    03920020
         AIF   ('&C'(K'&C,1) EQ '/').BM                                 03930020
         AIF   ('&C'(1,1) EQ '''').QM                                   03940020
         RCPSR2                                                         03950020
         AIF   ('&C'(1,1) EQ '(').RM                                    03960020
         LH    R2,&C+4                 LOAD LENGTH OF TEXT UNIT         03970020
         LTR   R2,R2                   TEST FOR ZERO                    03980020
         BZ    *+30                    IF NO TEXT UNIT, SKIP            03990020
         L     R14,&C                  LOAD ADDRESS OF TEXT UNIT        04000020
         AGO   .STHM                                                    04010020
.RM      LH    R2,4&C                  LOAD LENGTH OF TEXT UNIT         04020020
         LTR   R2,R2                   AND TEST FOR ZERO                04030020
         BZ    *+30                    IF NO TEXT UNIT, SKIP            04040020
         L     R14,0&C                 LOAD ADDRESS OF TEXT UNIT        04050020
.STHM    STH   R2,S99TULNG             STORE LENGTH OF TEXT UNIT        04060020
         BCTR  R2,0                    DECREMENT FOR EXECUTE            04070020
         EX    R2,&DYNP.MVC            MOVE IN TEXT UNIT                04080020
         MVI   S99TUKEY+1,&KEY         MOVE IN TEXT UNIT KEY            04090020
         AIF   ('&N' EQ '1' OR '&N' EQ '').N1                           04100020
         LA    R14,&N                  LOAD TEXT UNIT NUMBER            04110020
         STH   R14,S99TUNUM             AND STORE IT IN TEXT UNIT       04120020
         AGO   .ENDN                                                    04130020
.N1      MVI   S99TUNUM+1,1            SET NUMBER FIELD                 04140020
.ENDN    RCPDINC &LEN                                                   04150020
         MEXIT                                                          04160020
.BM      RCPTUBFR &KEY,&LEN,&C                                          04170020
         MEXIT                                                          04180020
.QM      RCPBTU &KEY,&N,&C                                              04190020
         MEND                                                           04200020
         MACRO                                                          04210020
         RCPFDDN &DDN                                                   04220020
         GBLC &DYNP                                                     04230020
         SPACE                                                          04240020
*********************************************************************** 04250020
**        FREE DDNAME TEXT UNIT                                      ** 04260020
*********************************************************************** 04270020
         AIF   ('&DDN'(1,1) EQ '''').Q                                  04280020
         AIF   ('&DDN'(K'&DDN,1) EQ '/').B                              04290020
         RCPSR2                                                         04300020
         AIF   ('&DDN'(1,1) EQ '(').R                                   04310020
         L     R14,&DDN                LOAD ADDRESS OF DDNAME           04320020
         LH    R2,&DDN+4               LOAD LENGTH OF DDNAME            04330020
         AGO   .STH                                                     04340020
.R       L     R14,0&DDN               LOAD ADDRESS OF DDNAME           04350020
         LH    R2,4&DDN                LOAD LENGTH OF DDNAME            04360020
.STH     STH   R2,S99TULNG             STORE DDNAME LENGTH              04370020
         BCTR  R2,0                    DECREMENT FOR EXECUTE            04380020
         EX    R2,&DYNP.MVC            MOVE DDNAME                      04390020
         MVI   S99TUKEY+1,DUNDDNAM     MOVE IN DDNAME KEY               04400020
         MVI   S99TUNUM+1,1            SET NUMBER FIELD                 04410020
         RCPDINC 14                                                     04420020
         MEXIT                                                          04430020
.Q       RCPBTU DUNDDNAM,1,&DDN                                         04440020
         MEXIT                                                          04450020
.B       RCPTUBFR DUNDDNAM,14,&DDN                                      04460020
         MEND                                                           04470020
*                                                                       04480019
*                                                                       04490019
* ENTER HERE AND PERFORM STANDARD REGISTER SAVE AREA HOUSEKEEPING.      04500019
         SPACE                                                          04510000
VTOCEXCP VTCENTER 12,8                 USE THE PROVIDED SAVEAREA   008G 04520016
         USING VTOCWORK,R13   SET ADDRESSABILITY FOR WORK AREA          04530000
         LR    R11,R1                  SAVE PARAMETER REGISTER          04540000
         USING VTOCOM,R11              SET ADDRESSABILITY               04550000
*                                                                       04560000
*        POINT TO THE DCB FOR LATER REFERENCES                          04570000
*                                                                       04580000
         LA    RDCB,VTOCDCB   POINT TO IT                               04590000
         USING IHADCB,RDCB    SET ADDRESSABILITY                        04600000
         SPACE                                                          04610000
* SELECT MODE FROM CONTENTS AT ADDRESS IN REGISTER 1.                   04620000
         SPACE                                                          04630000
         SR    RWA,RWA                 CLEAR THE REGISTER               04640000
         IC    RWA,VTCEFUNC            GET CALL MODE                    04650000
         SLL   RWA,2                   MODE TIMES 4                     04660000
         B     *+4(RWA)                BRANCH ON MODE                   04670000
         SPACE                                                          04680000
         B     GETDSB                  MODE 0, GET A DSCB               04690000
         B     OPEN                    MODE 1, OPEN A NEW VTOC          04700000
         B     CLOSE                   MODE 2, CLOSE                    04710000
         B     RETURN0                 MODE 3 NOT DEFINED, NO OP        04720000
         SPACE 3                                                        04730000
***********                                                             04740000
* RETURNS *                                                             04750000
***********                                                             04760000
         SPACE                                                          04770000
RETURN0  SR    R15,R15                 CLEAR THE RETURN CODE            04780000
RETURN   VTCLEAVE EQ                   EXIT W/THE CURRENT RET CODE.008G 04790015
         EJECT                                                          04800000
*********************                                                   04810000
* MODE 0 - GET DSCB *                                                   04820000
*********************                                                   04830000
         SPACE                                                          04840000
* IF END-OF-FILE WAS REACHED, RETURN AT ONCE.                           04850000
         SPACE                                                          04860000
GETDSB   LA    R15,4                   SET THE RETURN CODE, IN CASE     04870000
         TM    MODESW,EOFSW            TEST END-OF-FILE BIT             04880000
         BO    RETURN                  RETURN CODE 4 IF ON              04890000
         SPACE                                                          04900000
* IF CHANNEL PROGRAM HAS BEEN STARTED, GO TO CHECK IT.  OTHERWISE,      04910000
* ASSUME THERE IS AT LEAST ONE FULL BUFFER.                             04920000
         SPACE                                                          04930000
         TM    MODESW,XCPRUN           TEST IF EXCP ISSUED              04940000
         BO    XCPTEST                 BRANCH IF SO                     04950000
         SPACE                                                          04960000
* SET BUFFER ADDRESS TO NEXT DSCB AND TEST IF LAST ON TRACK.  IF NOT,   04970000
* EXIT WITH ITS ADDRESS IN R1.                                          04980000
         SPACE                                                          04990000
         L     RWA,DSCBADR             LOAD BUFFER POINTER              05000000
         LA    RWA,148(RWA)            ADVANCE TO NEXT DSCB             05010000
NDXSTORE ST    RWA,DSCBADR             STORE UPDATED POINTER            05020000
         C     RWA,DSCBLIM             TEST IF LAST DSCB IN BUFFER      05030000
         BNL   LASTDSCB                BRANCH IF SO                     05040000
         LR    R1,RWA                  PASS ADDRESS TO USER             05050000
GETOUT   ST    R1,DSCBADDR             STORE IT FOR THE CALLER          05060000
         TM    MODESW,RDERR            TEST IF ERROR ON THIS TRACK      05070000
         BZ    RETURN0                 RETURN CODE 0 IF NOT             05080000
         LA    R15,8                   SET THE RETURN CODE              05090000
         B     RETURN                  RETURN CODE 8 IF ERROR           05100000
         SPACE                                                          05110000
* IF THIS IS THE LAST DSCB, MOVE IT TO THE INTERNAL BUFFER AND START    05120000
* READING THE NEXT TRACK.                                               05130000
         SPACE                                                          05140000
LASTDSCB MVC   BUFF(148),0(RWA)        MOVE LAST DSCB                   05150000
         L     RWB,TTRN                LOAD RELATIVE TRACK NUMBER       05160000
         AL    RWB,=X'00010000'        INCREMENT TO NEXT TRACK          05170000
         ST    RWB,TTRN                                                 05180000
         BAL   RRET,EXCP               START CHANNEL PROGRAM            05190000
         LA    R1,BUFF                 LOAD DSCB ADDRESS FOR CALLER     05200000
         B     GETOUT                  TO RETURN                        05210000
         EJECT                                                          05220000
* WAIT FOR CHANNEL PROGRAM COMPLETION AND TEST THE OUTCOME.             05230000
         SPACE                                                          05240000
XCPTEST  WAIT  ECB=VTOCECB                                              05250000
         SPACE                                                          05260000
         NI    MODESW,X'FF'-XCPRUN     TURN EXCP STARTED BIT OFF        05270000
         CLI   VTOCECB,X'7F'           TEST COMPLETION CODE             05280000
         BNE   PERMERR                 BRANCH IF ERROR                  05290000
SETDSCBA L     RWA,DSCBSTRT            SET BUFFER POINTER TO 1ST DSCB   05300000
         B     NDXSTORE                                                 05310000
         SPACE                                                          05320000
* PERMANENT ERROR FOR THIS TRACK.  ZERO THE DSCB'S AND FILL IN THE      05330000
* CCHHR PORTIONS OF THE COUNT AREAS.                                    05340000
         SPACE                                                          05350000
PERMERR  OI    MODESW,RDERR            SIGNAL READ ERROR                05360000
         NI    IOBFLAG1,X'FB'          TURN OFF BIT 5 OF IOB FLAG       05370000
         NI    DCBIFLGS,X'3F'          TURN OFF BITS 0 AND 1            05380000
         L     RWA,DSCBSTRT            LOAD ADDRESS OF FIRST DSCB       05390000
         LA    RWB,1                   LOAD RECORD NUMBER               05400000
         SPACE                                                          05410000
DSCBELUP XC    0(148,RWA),0(RWA)       ZERO DSCB BUFFER                 05420000
         MVC   0(4,RWA),IOBSEEK+3      INSERT CCHH IN COUNT FIELD       05430000
         STC   RWB,4(RWA)              INSERT R IN COUNT FIELD          05440000
         LA    RWA,148(RWA)            POINT TO NEXT BUFFER             05450000
         LA    RWB,1(RWB)              INCREMENT RECORD NUMBER          05460000
         C     RWA,DSCBLIM             TEST FOR LAST BUFFER             05470000
         BNH   DSCBELUP                                                 05480000
         MVC   MSGTEXT1,TRACKERR                                   007G 05490014
         MVC   MSGTEXT1+15(6),VOLID     MOVE VOLSER.               007G 05500014
         VTOCMSG MSGTEXT1               ISSUE THE MESSAGE          007G 05510014
         B     SETDSCBA                BRANCH TO RESET BUFFER POINTER   05520000
         EJECT                                                          05530000
*****************                                                       05540000
* MODE 1 - OPEN *                                                       05550000
*****************                                                       05560000
         SPACE                                                          05570000
* ENTER WITH A DDNAME IN SECOND PARAMETER POSITION.  PERFORM CLOSE      05580000
* SUBROUTINE FIRST TO BE SURE EVERYTHING IS INITIALIZED.                05590000
         SPACE                                                          05600000
OPEN     DS    0H                                                       05610000
         BAL   RRET,CLOSESUB           CALL CLOSE SUBROUTINE            05620000
         SPACE                                                          05630000
*                                                                       05640000
*        INITIALIZE THE DATA AREAS                                      05650000
*                                                                       05660000
*        FIRST THE DCB                                                  05670000
         MVC   VTOCDCB(DCBLEN),VTOCDCBM  SET UP THE DCB                 05680000
*                                                                       05690000
*        SET UP THE JFCB LISTS                                          05700000
*                                                                       05710000
         LA    R1,JEXLST      POINT TO THE EXIT LIST                    05720000
         STCM  R1,B'0111',DCBEXLSA  PUT IT INTO THE DCB                 05730000
         LA    R1,JFCBAREA    POINT TO THE JFCB AREA                    05740000
         ST    R1,JEXLST      AND PUT THAT INTO THE EXIT LIST           05750000
         MVI   JEXLST,X'87'   END OF LIST, JFCB EXIT                    05760000
         MVI   OPENLIST,X'80' END OF THE OPEN LIST TOO                  05770000
*        INITIALIZE THE IOB                                             05780000
         MVC   VTOCIOB(IOBCONL),IOBCONST START IT OUT                   05790000
         LA    R1,VTOCECB     GET THE ECB ADDRESS                       05800000
         ST    R1,IOBECB      AND STORE IT INTO THE IOB                 05810000
         ST    RDCB,IOBDCB    STORE THE DCB ADDRESS INTO THE IOB        05820000
*        INITIALIZE THE CAMLST                                          05830000
         MVC   DSCBFMT4(4),DSCBCON SET UP THE FIRST WORD                05840000
         LA    R1,IOBSEEK+3   SEEK ADDRESS                              05850000
         ST    R1,DSCBFMT4+4  INTO THE CAMLST                           05860000
         LA    R1,VOLID       VOLUME SERIAL NUMBER                      05870000
         ST    R1,DSCBFMT4+8  INTO THE CAMLST                           05880000
         LA    R1,FMT4        DSCB AREA                                 05890000
         ST    R1,DSCBFMT4+12 INTO THE CAMLST                           05900000
*                                                                       05910000
*        ALLOCATE THE VTOC OF THE CHOSEN PACK                           05920000
*                                                                       05930000
         LA    R1,VOLID       POINT TO THE VOLUME SERIAL                05940000
         ST    R1,VOLADDR     SAVE THE ADDRESS                          05950000
         LA    R1,6           ALSO GET THE LENGTH                       05960000
         STH   R1,VOLLEN      AND SAVE IT FOR DYNAMIC ALLOCATION MACRO  05970000
         LA    R1,3           GET L(UNIT TYPE).                    006G 05980014
         MVC   MSGTEXT2+8(3),ADDR  MOVE IN THE UNIT ADDRESS.       006G 05990014
MOVEDDA  CLC   ADDR(3),=XL3'00'  WAS VOLUME MOUNTED?               005G 06000011
         BNE   ALLOVTOC          YES, USE IT'S ADDRESS.            006G 06010014
         LA    R1,5           GET L(UNIT TYPE).                    005G 06020012
         MVC   MSGTEXT2+8(5),=CL5'3330V'   NO, ASSUME VUA UNIT.    005G 06030012
ALLOVTOC STH   R1,MSGTEXT2+4     SAVE L(UNIT TYPE).                005G 06040013
         LA    R1,MSGTEXT2+8     GET A(UNIT TYPE).                 005G 06050012
         ST    R1,MSGTEXT2       SAVE A(UNIT TYPE).                005G 06060012
         VTCALLOC DSN=VTOCNM,VOL=VOLADDR,UNIT=MSGTEXT2,DISP=SHR,       X06070018
               DDNTO=DCBDDNAM,ERROR=S99FAIL                    005G008G 06080018
         OI    MODESW,ALLOCSW          SET ALLOCATE FLAG ON             06090000
         SPACE                                                          06100000
* OPEN THE VTOC.                                                        06110000
         SPACE                                                          06120000
*                                                                       06130000
*        FIRST READ THE JFCB TO SWITCH THE DSNAME TO HEX 04'S           06140000
*                                                                       06150000
         RDJFCB ((RDCB)),MF=(E,OPENLIST)  READ THE JFCB                 06160000
         LTR   R15,R15        TEST THE RETURN CODE                      06170000
         BNZ   ERRJFCB        BAD NEWS                                  06180000
         LA    R1,JFCBAREA    POINT TO THE JFCB                         06190000
         USING JFCB,R1        SET UP ADDRESSABILITY                     06200000
         MVI   JFCBDSNM,X'04' PUT IN THE FIRST ONE                      06210000
         MVC   JFCBDSNM+1(L'JFCBDSNM-1),JFCBDSNM  PROPAGATE IT          06220000
         OI    JFCBTSDM,JFCNWRIT  DON'T REWRITE IT                      06230000
         DROP  R1                                                       06240000
         OPEN  ((RDCB),(INPUT)),MF=(E,OPENLIST),TYPE=J  OPEN THE VTOC   06250000
         TM    DCBOFLGS,OPENBIT        TEST IF OPEN WORKED              06260000
         BZ    OPENERR                 ERROR IF OPEN FAILED             06270000
         SPACE                                                          06280000
* ISSUE AN OBTAIN FOR THE FIRST DSCB ON THE VTOC ( FORMAT 4 )           06290000
D3       STM   R2,R13,EXCPSAVE         SAVE OUR REGS                    06300000
         LA    R3,EXCPSAVE    POINT TO THE REGISTER SAVE AREA           06310000
         ICM   R0,B'1111',=X'00000100' FIRST DSCB                       06320000
         L     R1,DCBDEBAD             DEB ADDRESS                      06330000
         LA    R2,IOBSEEK              SAVE ADDRESS OF CCHHR            06340000
         L     R15,CVT                 GET ADDRESS OF CVT               06350000
         L     R15,CVTPCNVT(R15)       GET ADDRESS OF CONVERT ROUTINE   06360000
         BALR  R14,R15                 GO TO CONVERT ROUTINE            06370000
         LM    R2,R13,0(R3)            GET MY REGS BACK                 06380000
         OBTAIN DSCBFMT4               GET FORMAT 4 DSCB                06390000
         LTR   R15,R15                 DID WE GET IT                    06400000
         BNZ   OBTERR                  NO - THEN ERROR, KEEP R15        06410000
         CLI   DS4IDFMT,X'F4'          MAKE SURE WE HAVE FORMAT 4       06420000
         BNE   NOTFMT4                 NO - THEN ERROR                  06430000
         IC    R15,DS4DEVDT            GET NUMBER OF DSCBS PER TRACK    06440000
         ST    R15,NDSCBS              SAVE THE NUMBER OF DSCBS         06450000
         OC    NDSCBS,NDSCBS           MAKE SURE NOT ZERO               06460000
         BZ    DSCBNUM0                YES - GO TELL CALLER             06470000
*                                                                       06480000
* OBTAIN CORE FOR CHANNEL PROGRAM AND DSCB BUFFERS.                     06490000
         SPACE                                                          06500000
         LA    R0,156                  CORE FOR ONE DSCB AND ITS CCW    06510000
         MH    R0,NDSCBS+2             TIMES NUMBER PER TRACK           06520000
         AH    R0,=H'15'               PLUS 1 CCW AND ROUNDING          06530000
         N     R0,=X'FFFFFFF8'         ROUND TO DOUBLE-WORD MULTIPLE    06540000
         ST    R0,CBSIZE               SAVE SIZE OF GOTTEN CORE         06550000
         GETMAIN  R,LV=(0)             GET TRACK BUFFERS                06560000
         ST    R1,CBADDR               SAVE ADDRESS OF GOTTEN CORE      06570000
         OI    MODESW,CBGOT            INDICATE CORE GOTTEN             06580000
         SPACE                                                          06590000
* GENERATE CHANNEL PROGRAM.  IT CONSISTS OF A 'READ R0' ORDER WITH      06600000
* THE SKIP FLAG ON, FOLLOWED BY A 'READ COUNT-KEY-AND-DATA' ORDER FOR   06610000
* EACH DSCB.                                                            06620000
         SPACE                                                          06630000
         L     RWA,NDSCBS              NUMBER OF DSCB'S                 06640000
         SLL   RWA,3                   TIMES   8                        06650000
         LA    RWA,8(RWA,R1)           PLUS 8 AND BASE = 1ST BUFFER ADD 06660000
         ST    RWA,DSCBSTRT            SAVE ADDRESS OF FIRST BUFFER     06670000
         SPACE                                                          06680000
         ST    R1,IOBSTART             ADDRESS OF CHANNEL PROGRAM       06690000
         MVC   0(8,R1),INITCCW         INSERT FIRST CCW                 06700000
         LA    RWB,8(R1)               PLACE FOR NEXT CCW               06710000
         LA    RWC,1                   BUFFER COUNTER                   06720000
         SPACE                                                          06730000
CCWLOOP  MVC   0(8,RWB),READCCW        INSERT READ CCW FOR ONE DSCB     06740000
         ST    RWA,0(RWB)              SET ITS BUFFER ADDRESS           06750000
         MVI   0(RWB),READCKD          RESTORE COMMAND CODE             06760000
         C     RWC,NDSCBS              TEST BUFFER COUNTER              06770000
         BNL   LASTCCW                 BRANCH IF LAST BUFFER            06780000
         LA    RWB,8(RWB)              INCREMENT CCW ADDRESS            06790000
         LA    RWA,148(RWA)            INCREMENT BUFFER ADDRESS         06800000
         LA    RWC,1(RWC)              INCREMENT BUFFER COUNTER         06810000
         B     CCWLOOP                 DO NEXT BUFFER                   06820000
         SPACE                                                          06830000
LASTCCW  NI    4(RWB),X'FF'-CC         TURN OFF COMMAND CHAIN BIT       06840000
         ST    RWA,DSCBLIM             SAVE ADDRESS OF LAST DSCB BUFFER 06850000
         SPACE                                                          06860000
* SET OTHER THINGS AND START PROGRAM TO FILL BUFFER.                    06870000
         SPACE                                                          06880000
         SR    R0,R0                                                    06890000
         ST    R0,TTRN                 SET RELATIVE TRACK NUMBER TO 0   06900000
         NI    MODESW,X'FF'-XCPRUN-RDERR-EOFSW   SET FLAGS OFF          06910000
         BAL   RRET,EXCP               START CHANNEL PROGRAM            06920000
         B     RETURN0                 INDICATE SUCCESSFUL OPEN         06930000
         EJECT                                                          06940000
******************                                                      06950000
* MODE 2 - CLOSE *                                                      06960000
******************                                                      06970000
         SPACE                                                          06980000
CLOSE    BAL   RRET,CLOSESUB           CALL CLOSED CLOSE SUBROUTINE     06990000
         B     RETURN0                                                  07000000
         SPACE 2                                                        07010000
* IF THE CHANNEL PROGRAM IS RUNNING, WAIT FOR IT BEFORE TAKING FURTHER  07020000
* ACTION.                                                               07030000
         SPACE                                                          07040000
CLOSESUB DS    0H                                                       07050000
         TM    MODESW,XCPRUN           TEST IF CHANNEL PROGRAM RUNNING  07060000
         BZ    NOEXCP                  BRANCH IF NOT                    07070000
         WAIT  ECB=VTOCECB             WAIT UNTIL COMPLETE              07080000
         NI    MODESW,X'FF'-XCPRUN     TURN RUNNING SWITCH OFF          07090000
NOEXCP   DS    0H                                                       07100000
         SPACE                                                          07110000
* CLOSE THE DCB.                                                        07120000
         SPACE                                                          07130000
         TM    DCBOFLGS,OPENBIT        TEST IF DCB OPEN                 07140000
         BZ    NOCLOSE                 BRANCH IF NOT                    07150000
         CLOSE ((RDCB)),MF=(E,OPENLIST)   CLOSE THE VTOC                07160000
NOCLOSE  DS    0H                                                       07170000
         SPACE                                                          07180000
* FREE UP THE DDNAME AND VOLUME                                         07190000
         SPACE                                                          07200000
         TM    MODESW,ALLOCSW          DID WE ALLOCATE A DEVICE         07210000
         BNO   NOALLOC                 NO  - THEN NOTHING TO FREEUP     07220000
         LA    R1,DCBDDNAM   POINT TO THE DDNAME                        07230000
         ST    R1,DDNPDL     SAVE IT FOR FREE                           07240000
         LA    R1,8          GET THE DDNAME LENGTH                      07250000
         STH   R1,DDNPDL+4   SAVE IT FOR FREE                           07260000
         VTCFREE  UNALC,DDN=DDNPDL,ERROR=S99FAIL  FREE THE DDNAME 008G  07270018
         NI    MODESW,X'FF'-ALLOCSW    TURN OFF ALLOCATE SW             07280000
         SPACE                                                          07290000
NOALLOC  DS    0H                                                       07300000
         SPACE                                                          07310000
* RELEASE CORE OBTAINED FOR DSCB BUFFERS.                               07320000
         SPACE                                                          07330000
         TM    MODESW,CBGOT            TEST IF CORE GOTTEN              07340000
         BZ    NOFREE                  BRANCH IF NOT                    07350000
         LM    R0,R1,CBSIZE            LOAD SIZE AND LOCATION           07360000
         FREEMAIN  R,LV=(0),A=(1)      FREE CORE                        07370000
         NI    MODESW,X'FF'-CBGOT      SET CORE GOTTEN BIT OFF          07380000
NOFREE   DS    0H                                                       07390000
         SPACE                                                          07400000
         NI    MODESW,X'FF'-RDERR      CLEAR ERROR SWITCH               07410000
         BR    RRET                                                     07420000
         EJECT                                                          07430000
****************                                                        07440000
* EXCP ROUTINE *                                                        07450000
****************                                                        07460000
         SPACE                                                          07470000
* CONVERT RELATIVE TRACK ADDRESS IN 'TTRN' TO ABSOLUTE SEEK ADDRESS IN  07480000
* 'IOBSEEK', USING SUPERVISOR CONVERSION ROUTINE.                       07490000
         SPACE                                                          07500000
EXCP     DS    0H                                                       07510000
         STM   R2,R13,EXCPSAVE         SAVE IMPORTANT REGISTERS         07520000
         LA    R3,EXCPSAVE             SAVE REGS FOR RESTORING AFTER CL 07530000
         L     R0,TTRN                 LOAD RELATIVE TRACK NUMBER       07540000
         L     R1,DCBDEBAD             LOAD DEB ADDRESS                 07550000
         LA    R2,IOBSEEK              LOAD ADDR TO RECEIVE MBBCCHHR    07560000
         L     R15,CVT                 LOAD CVT ADDRESS                 07570000
         L     R15,CVTPCNVT(R15)       LOAD ADDR OF CONVERT ROUTINE     07580000
         BALR  R14,R15                 CONVERT TTRN TO MBBCCHHR         07590000
*                                      THAT CLOBBERED BASE REG          07600000
         LM    R2,R13,0(R3)            RESTORE REGISTERS                07610000
         LTR   R15,R15                 TEST IF EXTENT VIOLATED (RC=4)   07620000
         BNZ   SETEOF                  IF SO, MEANS END-OF-FILE         07630000
         CLC   DS4HPCHR,IOBSEEK+3      CHECK FOR THE LAST FMT1          07640000
         BL    SETEOF                  IF SO, PRETEND END-OF-FILE       07650000
         SPACE                                                          07660000
* ZERO ECB AND START CHANNEL PROGRAM.                                   07670000
         SPACE                                                          07680000
         SR    R0,R0                                                    07690000
         ST    R0,VTOCECB              CLEAR ECB                        07700000
         NI    MODESW,X'FF'-RDERR      RESET ERROR SWITCH               07710000
         EXCP  VTOCIOB                 START CHANNEL PROGRAM            07720000
         OI    MODESW,XCPRUN           SET 'RUNNING' FLAG               07730000
         BR    RRET                                                     07740000
         SPACE                                                          07750000
* WHEN EXTENT IS VIOLATED, SET END-FILE AND EXIT VIA CLOSE ROUTINE.     07760000
         SPACE                                                          07770000
SETEOF   OI    MODESW,EOFSW            SET END-OF-FILE BIT              07780000
         B     CLOSESUB                EXIT VIA CLOSE SUBROUTINE        07790000
         EJECT                                                          07800000
********************************                                        07810000
* DAIRFAIL ROUTINE             *                                        07820000
********************************                                        07830000
S99FAIL  LR    RRCODE,R15     SAVE THE RETURN CODE                 003G 07840003
         VTCS99NG MF=(E,S99FLIST,S99FLEN)  ISSUE THE APPROP. MSG   008G 07850018
         LR    R15,RRCODE     RELOAD THE RETURN CODE                    07860000
         B     RETURN         AND THEN EXIT                             07870000
         SPACE 3                                                        07880000
*                                                                       07890000
*        VARIOUS OTHER ERROR ROUTINES                                   07900000
*                                                                       07910000
OPENERR  MVC   MSGTEXT1,OPENERRM                                   004G 07920008
         MVC   MSGTEXT1+15(6),VOLID     MOVE VOLSER.               004G 07930009
         VTOCMSG MSGTEXT1               ISSUE THE MESSAGE          004G 07940008
         B     ERRET                     THEN RETURN                    07950006
OBTERR   MVC   MSGTEXT1,OBTERRM                                    004G 07960008
         MVC   MSGTEXT1+15(6),VOLID     MOVE VOLSER.               004G 07970009
         VTOCMSG MSGTEXT1               ISSUE THE MESSAGE          004G 07980008
         B     ERRET                     THEN RETURN                    07990006
NOTFMT4  MVC   MSGTEXT1,NOTFMT4M                                   004G 08000008
         MVC   MSGTEXT1+15(6),VOLID     MOVE VOLSER.               004G 08010009
         VTOCMSG MSGTEXT1               ISSUE THE MESSAGE          004G 08020008
         B     ERRET                     THEN RETURN                    08030006
DSCBNUM0 MVC   MSGTEXT1,DSCBNUM0                                   004G 08040008
         MVC   MSGTEXT1+15(6),VOLID     MOVE VOLSER.               004G 08050009
         VTOCMSG MSGTEXT1               ISSUE THE MESSAGE          004G 08060008
         B     ERRET                     THEN RETURN                    08070006
ERRJFCB  MVC   MSGTEXT1,ERRJFCBM                                   004G 08080008
         MVC   MSGTEXT1+15(6),VOLID     MOVE VOLSER.               004G 08090009
         VTOCMSG MSGTEXT1               ISSUE THE MESSAGE          004G 08100008
         B     ERRET                     THEN RETURN               004G 08110006
*                                                                       08120000
ERRET    LA    R15,8          SET AN ERROR RETURN CODE                  08130000
         B     RETURN         THEN EXIT                                 08140000
*                                                                       08150000
         EJECT                                                          08160000
********************************                                        08170000
* CONSTANTS, VARIABLES, ETC... *                                        08180000
********************************                                        08190000
         SPACE                                                          08200000
*        ERROR MESSAGES                                                 08210000
*                                                                       08220000
OPENERRM VTCMSG ' VTOCEXCP -VVVVVV- ERROR IN OPENING VTOC '   002G 004G 08230009
OBTERRM  VTCMSG ' VTOCEXCP -VVVVVV- ERROR IN OBTAIN '         002G 004G 08240009
NOTFMT4M VTCMSG ' VTOCEXCP -VVVVVV- FORMAT 4 DSCB WAS NOT FIRST'   004G 08250009
DSCBNUMM VTCMSG ' VTOCEXCP -VVVVVV- FORMAT 4 DSCB HAS DSCB S/TRK =0'    08260006
TRACKERR VTCMSG ' VTOCEXCP -VVVVVV- A READ ERROR OCCURRED ON VTOC' 004G 08270009
ERRJFCBM VTCMSG ' VTOCEXCP -VVVVVV- A RDJFCB ERROR OCCURRED ' 002G 004G 08280009
         SPACE                                                          08290000
INITCCW  CCW   READR0,0,CC+SLI+SKIP,8                                   08300000
READCCW  CCW   READCKD,0,CC,148                                         08310000
         SPACE                                                          08320000
DSCBCON  CAMLST SEEK,0,0,0   FILLED IN WITH IOBSEEK+3, VOLID, FMT4      08330000
         EJECT                                                          08340000
* DATA CONTROL BLOCK                                                    08350000
VTOCDCBM DCB   DDNAME=VTOCDD,MACRF=(E),EXLST=1                          08360000
DCBLEN   EQU   *-VTOCDCBM                                               08370000
         SPACE                                                          08380000
* IOB FOR CHANNEL PROGRAM                                               08390000
         SPACE                                                          08400000
IOBCONST DS    0D                                                       08410000
         DC    X'42000000'     COMMAND CHAIN, NOT RELATED               08420000
         DC    A(0)            ECB ADDRESS                              08430000
         DC    2F'0'                                                    08440000
         DC    A(0)            CHANNEL PROGRAM BEGINNING                08450000
         DC    A(0)            DCB ADDRESS                              08460000
         DC    X'03000000'                                              08470000
         DC    F'0'                                                     08480000
         DC    D'0'            INITIAL SEEK ADDRESS                     08490000
IOBCONL  EQU   *-IOBCONST                                               08500000
* VTOC NAME FOR ALLOCATION                                              08510000
VTOCNM   DC    A(VTOCNAME)                                              08520000
         DC    Y(12)                                                    08530000
VTOCNAME DC    CL12'FORMAT4.DSCB'   DATA SET NAME FOR VTOC              08540000
*                                                                       08550000
*                                                                       08560000
         LTORG                                                          08570000
         EJECT                                                          08580000
* SECTION DEFINITION AND REGISTER ASSIGNMENTS;                          08590000
         SPACE 2                                                        08600000
RWA      EQU   2                                                        08610000
RWB      EQU   3                                                        08620000
RWC      EQU   4                                                        08630000
RDCB     EQU   8              DCB POINTER                               08640000
RRCODE   EQU   10              RETURN CODE REGISTER                     08650000
RRET     EQU   9               LOCAL SUBROUTINE EXIT REGISTER           08660000
         SPACE 3                                                        08670000
* TAGS FOR CHANNEL COMMANDS AND FLAG BITS:                              08680000
         SPACE                                                          08690000
READR0   EQU   X'16'           READ RECORD 0                            08700000
READCKD  EQU   X'1E'           READ COUNT, KEY, AND DATA                08710000
         SPACE                                                          08720000
CC       EQU   X'40'           COMMAND CHAIN FLAG                       08730000
SLI      EQU   X'20'           SUPPRESS LENGTH INDICATION FLAG          08740000
SKIP     EQU   X'10'           SKIP DATA TRANSFER FLAG                  08750000
         SPACE 3                                                        08760000
* COMMUNICATION VECTOR TABLE (CVT) DEFINITIONS:                         08770000
         SPACE                                                          08780000
CVT      EQU   16              LOCATION OF CVT BASE ADDRESS             08790000
CVTPCNVT EQU   28              OFFSET TO CONVERT ROUTINE ADDRESS        08800000
         EJECT                                                          08810000
*                                                                       08820000
*        AREA USED BY VTOCREAD, PASSED VIA R13                          08830000
*                                                                       08840000
VTOCWORK DSECT                                                          08850000
         DS    18F             SAVE AREA                                08860000
         SPACE                                                          08870000
EXCPSAVE DS    18F             INTERNAL SAVE AREA                       08880000
CBSIZE   DS    2F              SIZE AND LOCATION OF GOTTEN CORE         08890000
CBADDR   EQU   CBSIZE+4                                                 08900000
NDSCBS   DS    F               NUMBER OF DSCB'S PER TRACK               08910000
DSCBSTRT DS    F               ADDRESS OF 1ST DSCB BUFFER               08920000
DSCBLIM  DS    F               ADDRESS OF LAST DSCB BUFFER              08930000
DSCBADR  DS    F               ADDRESS OF CURRENT DSCB                  08940000
TTRN     DS    F               RELATIVE TRACK NUMBER                    08950000
VOLADDR  DS    A               FAKE PDL FOR ALLOC MACRO - ADDRESS       08960000
VOLLEN   DS    H                       AND LENGTH OF VOLID              08970000
DDNPDL   DS    2F            SPACE FOR DDNAME PDL                       08980000
         SPACE                                                          08990000
* MODE SWITCH AND BIT DEFINITIONS                                       09000000
         SPACE                                                          09010000
MODESW   DC    X'00'                                                    09020000
CBGOT    EQU   X'80'           CORE GOTTEN FOR BUFFER                   09030000
XCPRUN   EQU   X'40'           CHANNEL PROGRAM STARTED BUT NOT CHECKED  09040000
RDERR    EQU   X'20'           PERMANENT I/O ERROR                      09050000
EOFSW    EQU   X'10'           END-OF-FILE SENSED                       09060000
ALLOCSW  EQU   X'08'           ALLOCATE VOLUME FLAG                     09070000
         SPACE                                                          09080000
VTOCDCB  DCB   DDNAME=VTOCDD,MACRF=(E),EXLST=1                          09090000
         SPACE                                                          09100000
OPENBIT  EQU   X'10'                                                    09110000
OPENLIST DS    2F                                                       09120000
         SPACE                                                          09130000
* IOB FOR CHANNEL PROGRAM                                               09140000
         SPACE                                                          09150000
VTOCIOB  DS    0D                                                       09160000
IOBFLAG1 DC    X'42000000'     COMMAND CHAIN, NOT RELATED               09170000
IOBECB   DC    A(VTOCECB)                                               09180000
         DC    2F'0'                                                    09190000
IOBSTART DC    A(0)            CHANNEL PROGRAM BEGINNING                09200000
IOBDCB   DC    A(VTOCDCB)                                               09210000
         DC    X'03000000'                                              09220000
         DC    F'0'                                                     09230000
IOBSEEK  DC    D'0'            INITIAL SEEK ADDRESS                     09240000
         SPACE                                                          09250000
* EVENT CONTROL BLOCK FOR CHANNEL PROGRAM:                              09260000
         SPACE                                                          09270000
VTOCECB  DC    F'0'            EVENT CONTROL BLOCK                      09280000
         SPACE 3                                                        09290000
* INTERNAL BUFFER FOR LAST DSCB                                         09300000
BUFF     DS    XL148                                                    09310000
         SPACE 2                                                        09320000
DSCBFMT4 CAMLST SEEK,IOBSEEK+3,VOLID,FMT4                               09330000
         SPACE                                                          09340000
*   WORK AREA FOR DYNAMIC ALLOCATION                                    09350000
*                 COMMENT COUDN'T BE PUT ON FOLLOWING VTCDYNSP     008G 09351022
         VTCDYNSP                                                       09360022
*                 COMMENT COUDN'T BE PUT ON PRECEEDING VTCDYNSP    008G 09360122
S99FLIST DS    XL(S99FLEN)                                              09370000
         SPACE                                                          09380000
*                                                                       09390000
*        JFCB EXIT LIST AND AREA                                        09400000
*                                                                       09410000
JEXLST   DS    F                                                        09420000
JFCBAREA DS    XL176                                                    09430000
         DS    0D                                                       09440000
VTOCWLEN EQU   *-VTOCWORK                                               09450000
         SPACE 2                                                        09460000
         VTCCOM                                                    008G 09470015
         SPACE 2                                                        09480000
         IEFZB4D0                                                       09490000
         SPACE 2                                                        09500000
         IEFZB4D2                                                       09510000
         SPACE 2                                                        09520000
         DCBD  DEVD=DA,DSORG=PS                                         09530000
         SPACE 2                                                        09540000
JFCB     DSECT                                                          09550000
         IEFJFCBN                                                       09560000
         END                                                            09570000
