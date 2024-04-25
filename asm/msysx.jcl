//BRXMSYS JOB   (SYS),'INSTALL MS CMD',CLASS=S,MSGCLASS=X
//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//* INSTALLS TSO COMMAND 'MS' IN SYS2.LINKLIB (HELP IN SYS2.HELP)      *
//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//MSASM  PROC  MOD=
//ASM    EXEC  PGM=IFOX00,PARM='OBJECT',REGION=256K
//SYSLIB   DD  DSN=SYS1.MACLIB,DISP=SHR
//         DD  DSN=SYS1.AMODGEN,DISP=SHR
//         DD  DSN=&MSMACLIB,DISP=(OLD,PASS)
//SYSUT1   DD  UNIT=SYSDA,SPACE=(CYL,(3,1)),DSN=&SYSUT1
//SYSUT2   DD  UNIT=SYSDA,SPACE=(CYL,(3,1)),DSN=&SYSUT2
//SYSUT3   DD  UNIT=SYSDA,SPACE=(CYL,(3,1)),DSN=&SYSUT3
//SYSPUNCH DD  DUMMY,DCB=(BLKSIZE=800)
//SYSPRINT DD  SYSOUT=*
//SYSGO    DD  DSN=&MSOBJECT(&MOD),DISP=(MOD,PASS),
//             UNIT=SYSDA,SPACE=(CYL,(3,1,2))
//MSASM  PEND
//*
//MAC    EXEC  PGM=IEBUPDTE,PARM=NEW
//SYSPRINT DD  DUMMY
//SYSUT2   DD  DSN=&MSMACLIB,DISP=(NEW,PASS),
//             UNIT=SYSDA,SPACE=(CYL,(1,0,1))
//SYSIN    DD  *
./ ADD NAME=REGS
         MACRO                                                          00000010
         REGS                                                           00000020
*********************************************************************** 00000030
*                                                                     * 00000040
*        REGISTER EQUATES                                             * 00000050
*                                                                     * 00000060
*********************************************************************** 00000070
         SPACE 1                                                        00000080
*********************************************************************** 00000090
*                                                                     * 00000100
*        FIXED POINT REGISTERS                                        * 00000110
*                                                                     * 00000120
*********************************************************************** 00000130
         SPACE 1                                                        00000140
R0       EQU   0        *USED BY O.S.                                   00000150
R1       EQU   1        *USED BY O.S. // ADDRESS OF PARAMETER LIST      00000160
R2       EQU   2                                                        00000170
R3       EQU   3                                                        00000180
R4       EQU   4                                                        00000190
R5       EQU   5                                                        00000200
R6       EQU   6                                                        00000210
R7       EQU   7                                                        00000220
R8       EQU   8                                                        00000230
R9       EQU   9                                                        00000240
R10      EQU   10                                                       00000250
R11      EQU   11                                                       00000260
R12      EQU   12                                                       00000270
R13      EQU   13       *USED BY O.S. // SAVE-AREA ADDRESS              00000280
R14      EQU   14       *USED BY O.S. // RETURN ADDRESS                 00000290
R15      EQU   15       *USED BY O.S. // ENTRY-PT ADDR, RETURN CODE     00000300
         SPACE 1                                                        00000310
*********************************************************************** 00000320
*                                                                     * 00000330
*        FLOATING POINT REGISTERS                                     * 00000340
*                                                                     * 00000350
*********************************************************************** 00000360
         SPACE 1                                                        00000370
F0       EQU   0                                                        00000380
F2       EQU   2                                                        00000390
F4       EQU   4                                                        00000400
F6       EQU   6                                                        00000410
         MEND                                                           00000420
./ ENDUP
/*
//*
//ASM1   EXEC  MSASM,MOD=MSYS
//SYSIN    DD  *
MSYS     TITLE 'MS - TSO MASTER SUMMARY COMMAND'                        00010000
         MACRO                                                          00020000
&NAME    TSDERASE &N                                                    00030000
&NAME    BCR   0,0                      NOP                             00040000
         MEND                                                           00050000
         SPACE 1                                                        00060000
         PRINT NOGEN                                                    00070000
MSYS     CSECT                                                          00080000
         SAVE  (14,12),T,MS_TSO_COMMAND                                 00090000
         USING MSYS,R15                                                 00100000
         LA    R11,SAVEAREA                                             00110000
         ST    R13,SAVEAREA+4                                           00120000
         ST    R11,8(,R13)                                              00130000
         LR    R13,R11                                                  00140000
         B     START                                                    00150000
         DROP  R15                                                      00160000
         SPACE 2                                                        00170000
SAVEAREA DC    18F'0'                                                   00180000
         SPACE 2                                                        00190000
START    DS    0H                                                       00200000
         USING SAVEAREA,R13                                             00210000
         SPACE 2                                                        00220000
         MVC  INPUT(80),=CL80' '        BLANK INPUT                     00230000
         MVC  INPUT(2),=C'J '           SET UP DEFAULT                  00240000
         MVC  OLDINPUT,INPUT            SAVE FOR REPEAT                 00250000
         B    CMDJ                      GO DO 1ST TIME                  00260000
         SPACE 2                                                        00270000
MAINLOOP TSDERASE                       ERASE THE SCREEN                00280000
         L     R1,16                    FIND CVT                        00290000
         L     R1,X'22C'(,R1)           FIND ASVT                       00300000
         LA    R3,X'210'(,R1)           FIND FIRST ENTRY                00310000
         LA    R4,4                     BXLE INCREMENT                  00320000
         L     R5,X'204'(,R1)           MAX ADDR SPEC                   00330000
         SLA   R5,2                     MULT BY FOUR                    00340000
         LA    R5,0(R3,R5)              POINT TO END                    00350000
         BCTR  R5,0                     BACK UP ONE                     00360000
         SPACE                                                          00370000
         CLC   =C'SS',PROMPT            STATS COMMAND?                  00380000
         BE    DOSS                     YES, GO DO IT                   00390000
         SPACE                                                          00400000
         TPUT  HEADER,L'HEADER                                          00410000
         SPACE 2                                                        00420000
LOOP     TM    0(R3),X'FF'              CHECK BITS ON                   00430000
         BNZ   LOOPBXLE                 SKIP IF ONE ON                  00440000
         L     R2,0(,R3)                PICK UP POINTER TO ASCB         00450000
         MVC   LINE(80),=CL80' '        BLANK LINE                      00460000
         ICM   R1,15,172(R2)            JOB NAME FOR INIT PGMS          00470000
         BZ    *+10                                                     00480000
         MVC   LINE+15(8),0(R1)                                         00490000
         ICM   R1,15,176(R2)            JOBNAME FOR START MOUNT ETC     00500000
         BZ    *+10                                                     00510000
         MVC   LINE+5(8),0(R1)                                          00520000
         SPACE                                                          00530000
         ICM   R1,15,56(R2)             FIND CSCB POINTER               00540000
         BZ    TESTSYS                  NO POINTER, MUST BE SYSTASK     00550000
         TM    28(R1),B'00000011'       CHECK FOR SYSTEM TASKS          00560000
         BZ    TESTSYS                  BOTH OFF MEANS STARTED TASK     00570000
         BO    TESTINIT                 BOTH ON MEANS A JOB             00580000
         CLC   =C'INIT',LINE+5          INIT OR TSU IS LEFT             00590000
         BE    TESTINIT                 IF BIT ON, OK                   00600000
         TM    28(R1),B'00000001'       CHECK FOR TSU                   00610000
         BZ    TESTSYS                  NO, MUST BE STC                 00620000
         SPACE                                                          00630000
TESTTSU  CLI   PROMPT,C'T'              ASKING FOR TSU                  00640000
         BNE   LOOPBXLE                                                 00650000
         B     LIKEIT                   ELSE REJECT                     00660000
         MVC   LINE+15(8),16(R1)        COPY IN PROCNAME                00670000
         SPACE                                                          00680000
TESTINIT CLI   PROMPT,C'I'              ASKING FOR INIT?                00690000
         BE    LIKEIT                                                   00700000
         B     LOOPBXLE                 ELSE REJECT                     00710000
         SPACE                                                          00720000
TESTSYS  CLI   PROMPT,C'S'              WANT SYS TASKS?                 00730000
         BNE   LOOPBXLE                 IF NOT, WE NO LIKE              00740000
         LTR   R1,R1                    CSCB PRESENT?                   00750000
         BZ    LIKEIT                   NO, SKIP THE FOLLOWING          00760000
         MVC   LINE+22(3),24(R1)        MOVE IN UNIT ID                 00770000
         MVC   LINE+5(8),8(R1)          MOVE IN ID                      00780000
         MVC   LINE+14(8),16(R1)        MOVE IN PROCNAME                00790000
         SPACE                                                          00800000
LIKEIT   LH    R1,36(,R2)               PICK UP ASID                    00810000
         CVD   R1,DOUBLE                                                00820000
         UNPK  LINE(3),DOUBLE                                           00830000
         OI    LINE+2,C'0'              MAKE IT PRINTABLE               00840000
         SPACE                                                          00850000
         LH    R1,120(,R2)              ALLOC AUX SLOTS (VAM)           00860000
         SLA   R1,2                     MULT BY 4 TO GET IT IN 'K'      00870000
         CVD   R1,DOUBLE                                                00880000
         MVC   LINE+25(7),=X'4020206B202120'  EDIT MASK                 00890000
         ED    LINE+25(7),DOUBLE+5      DO THE EDIT                     00900000
         MVI   LINE+32,C'K'                                             00910000
         LH    R1,122(,R2)              ALLOC AUX SLOTS (NON-VAM)       00920000
         SLA   R1,2                     MULT BY 4 TO GET IT IN 'K'      00930000
         CVD   R1,DOUBLE                                                00940000
         MVC   LINE+35(7),=X'4020206B202120'  EDIT MASK                 00950000
         ED    LINE+35(7),DOUBLE+5      DO THE EDIT                     00960000
         MVI   LINE+42,C'K'                                             00970000
         LH    R1,152(,R2)              REAL STORAGE IN USE             00980000
         SLA   R1,2                     MULT BY 4 TO GET IT IN 'K'      00990000
         CVD   R1,DOUBLE                                                01000000
         MVC   LINE+45(7),=X'4020206B202120'  EDIT MASK                 01010000
         ED    LINE+45(7),DOUBLE+5      DO THE EDIT                     01020000
         MVI   LINE+52,C'K'                                             01030000
         LM    R0,R1,64(R2)             PICK UP CPU TIME                01040000
         SRDL  R0,24                    MOVE TO ODD REG                 01050000
         M     R0,=A(1048576)           COMPUTE IN SECONDS              01060000
         D     R0,=A(10000*256)                                         01070000
         CVD   R1,DOUBLE                                                01080000
         MVC   LINE+55(10),=X'4020206B2021204B2020'                     01090000
         ED    LINE+55(10),DOUBLE+4      DO THE EDIT                    01100000
         MVI   LINE+65,C'S'                                             01110000
         LM    R0,R1,200(R2)            PICK UP SRB TIME                01120000
         SRDL  R0,24                    MOVE TO ODD REG                 01130000
         M     R0,=A(1048576)           COMPUTE IN SECONDS              01140000
         D     R0,=A(10000*256)                                         01150000
         CVD   R1,DOUBLE                                                01160000
         MVC   LINE+66(10),=X'4020206B2021204B2020'                     01170000
         ED    LINE+66(10),DOUBLE+4      DO THE EDIT                    01180000
         MVI   LINE+76,C'S'                                             01190000
         UNPK  DOUBLE(3),43(2,R2)       CONVERT DPRTY TO HEX            01200000
         TR    DOUBLE(2),HEXTAB                                         01210000
         MVC   LINE+78(2),DOUBLE        MOVE FOR PRNTING                01220000
         SPACE                                                          01230000
         TPUT  LINE,L'LINE                                              01240000
LOOPBXLE BXLE  R3,R4,LOOP                                               01250000
         SPACE 2                                                        01260000
ASKAGAIN TPUT  PROMPT,L'PROMPT,ASIS                                     01270000
         TGET  INPUT,L'INPUT            GET COMMAND                     01280000
         SPACE                                                          01290000
         OC    INPUT(2),=C'  '          SHIFT TO UPPER CASE             01300000
         CLI   INPUT,C' '               NULL LINE?                      01310000
         BNE   NOTNULL                  NO,SKIP THE FOLLOWING           01320000
         MVC   INPUT,OLDINPUT           SET COMMAND TO SAME AS LASTTIME 01330000
NOTNULL  MVC   OLDINPUT,INPUT           SAVE OLD INPUT                  01340000
         CLC   =C'SS',INPUT             SYSTEM STATS                    01350000
         BE    CMDSS                                                    01360000
         CLC   =C'LP',INPUT             SYSTEM STATS                    01370000
         BE    CMDLP                                                    01380000
         CLC   =C'TS',INPUT             TSO    STATS                    01390000
         BE    CMDTS                                                    01400000
         CLI   INPUT,C'I'               INIT COMMAND?                   01410000
         BE    CMDI                                                     01420000
         CLI   INPUT,C'J'               JOBS COMMAND?                   01430000
         BE    CMDJ                                                     01440000
         CLI   INPUT,C'S'               TSC?                            01450000
         BE    CMDS                                                     01460000
         CLI   INPUT,C'T'               TSU                             01470000
         BE    CMDT                                                     01480000
         CLI   INPUT,C'E'               EXIT?                           01490000
         BE    EXIT                                                     01500000
         CLI   INPUT,C'?'                                               01510000
         BE    OPTIONS                                                  01520000
         CLI   INPUT,C'H'                                               01530000
         BE    OPTIONS                                                  01540000
         B     MAINLOOP                                                 01550000
         SPACE                                                          01560000
CMDI     MVC   PROMPT(2),=C'IN'                                         01570000
         MVC   HEADER+15(9),=CL9'JOB'                                   01580000
         B     MAINLOOP                                                 01590000
         SPACE                                                          01600000
CMDTS    MVC   PROMPT(2),=C'TS'                                         01610000
         MVC   HEADER+15(9),=CL80' '                                    01620000
         B     MAINLOOP                                                 01630000
         SPACE                                                          01640000
CMDT     MVC   PROMPT(2),=C'T '                                         01650000
         CALL  USERS                    CALL USERS COMMAND              01660000
         B     ASKAGAIN                                                 01670000
         SPACE                                                          01680000
CMDJ     MVC   PROMPT(2),=C'J '                                         01690000
         CALL  JOBS                     CALL JOBS COMMAND               01700000
         B     ASKAGAIN                                                 01710000
         SPACE                                                          01720000
CMDS     MVC   PROMPT(2),=C'S '                                         01730000
         MVC   HEADER+15(9),=CL9'PROC/UNIT'                             01740000
         B     MAINLOOP                                                 01750000
         SPACE                                                          01760000
CMDSS    MVC   PROMPT(2),=C'SS'                                         01770000
         BE    MAINLOOP                                                 01780000
         SPACE                                                          01790000
CMDLP    MVC   PROMPT(2),=C'LP'                                         01800000
* LPA LISTER                                                            01810000
         TSDERASE                                                       01820000
         L     R2,16                    FIND CVT                        01830000
LPAFIRST L     R2,X'0BC'(,R2)           FIND 1ST LPDE                   01840000
         ICM   R2,15,0(R2)              SKIP DUMMY                      01850000
         BZ    ASKAGAIN                 IF NULL                         01860000
LPALOOP  MVC   LINE(80),=CL80' '        BLANK LINE                      01870000
         LA    R3,LINE                                                  01880000
         LA    R4,26                    BXLE SETUP                      01890000
         LA    R5,LINE+80-25                                            01900000
LPALOOP1 MVC   7(8,R3),8(R2)            MOVE IN MODULE NAME             01910000
         ST    R2,FWORK                 CONVERT LPDE ADDR TO HEX        01920000
         UNPK  DOUBLE(7),FWORK+1(4)                                     01930000
         TR    DOUBLE(6),HEXTAB                                         01940000
         MVC   0(6,R3),DOUBLE                                           01950000
         UNPK  DOUBLE(7),17(4,R2)       CONVERT EPA                     01960000
         TR    DOUBLE(6),HEXTAB                                         01970000
         MVC   17(6,R3),DOUBLE                                          01980000
         ICM   R2,15,0(R2)              FOLLOW PNTR                     01990000
         BZ    LPATPUT                                                  02000000
         BXLE  R3,R4,LPALOOP1                                           02010000
LPATPUT  TPUT  LINE,L'LINE                                              02020000
         LTR   R2,R2                                                    02030000
         BNZ   LPALOOP                                                  02040000
         B     ASKAGAIN                                                 02050000
         SPACE                                                          02060000
OPTIONS  TSDERASE                                                       02070000
         MVC   PROMPT(2),=C'H '                                         02080000
         TPUT  OP1,L'OP1                                                02090000
         TPUT  OP2,OPLEN                                                02100000
         B     ASKAGAIN                                                 02110000
         SPACE                                                          02120000
DOSS     SR    R7,R7                    VIO SLOTS USED COUNTER          02130000
         SR    R8,R8                    REG SLOTS IN USE COUNTER        02140000
         SR    R9,R9                    WORKING SET ACCUM               02150000
SSLOOP   TM    0(R3),X'FF'              ENTRY IN USE                    02160000
         BNZ   SSBXLE                   NO, SKIP                        02170000
         L     R2,0(,R3)                PICK UP ASCB POINTER            02180000
         AH    R7,120(,R2)              PICK UP VIO PAGES               02190000
         AH    R8,122(,R2)              PICK UP AUX PAGES               02200000
         AH    R9,152(,R2)              PICK UP REAL PAGES              02210000
SSBXLE   BXLE  R3,R4,SSLOOP                                             02220000
         SPACE 1                                                        02230000
         MVC   LINE(80),=CL80' '                                        02240000
         MVC   LINE+29(21),=C'* SYSTEM STATISTICS *'                    02250000
         TPUT  LINE,L'LINE                                              02260000
         SPACE                                                          02270000
         L     R2,16                    FIND CVT                        02280000
         L     R3,X'C4'(,R2)            FIND SMCA                       02290000
         MVC   LINE(80),=CL80' '                                        02300000
         MVC   LINE(7),=C'SYSTEM-'                                      02310000
         MVC   LINE+7(4),16(R3)         MOVE IN SYSTEM ID               02320000
         S     R2,=F'6'                 BACK UP TO CVT PREFIX           02330000
         MVC   LINE+15(8),=C'RELEASE-'                                  02340000
         MVC   LINE+23(2),2(R2)         FIRST HALF OF REL NO            02350000
         MVI   LINE+25,C'.'                                             02360000
         MVC   LINE+26(2),4(R2)         SECOND HALF OF REL NO           02370000
         UNPK  DOUBLE(5),0(3,R2)        MODEL NUM                       02380000
         TR    DOUBLE+1(3),HEXTAB                                       02390000
         MVC   LINE+30(10),=C'CPU MODEL-'                               02400000
         MVC   LINE+40(3),DOUBLE+1                                      02410000
         MVC   LINE+45(9),=C'CPU SIZE-'                                 02420000
         L     R3,312+6(,R2)                                            02430000
         LA    R3,1(,R3)                BUMP BY ONE                     02440000
         SRL   R3,10                    CONVERT TO K                    02450000
         CVD   R3,DOUBLE                                                02460000
         MVC   LINE+54(7),=X'4020206B202120'  EDIT MASK                 02470000
         ED    LINE+54(7),DOUBLE+5      DO THE EDIT                     02480000
         MVI   LINE+61,C'K'                                             02490000
         TPUT  LINE,L'LINE                                              02500000
         SPACE                                                          02510000
         MVC   LINE(80),=CL80' '                                        02520000
         MVC   LINE(16),=C'VIO SLOTS IN USE'                            02530000
         SLA   R7,2                     MULT BY 4 TO MAKE K             02540000
         CVD   R7,DOUBLE                                                02550000
         MVC   LINE+20(10),=X'40206B2020206B202120'                     02560000
         ED    LINE+20(10),DOUBLE+4                                     02570000
         MVI   LINE+30,C'K'                                             02580000
         MVC   LINE+40(17),=C'A.S. SLOTS IN USE'                        02590000
         SLA   R8,2                     MULT BY 4 TO MAKE K             02600000
         CVD   R8,DOUBLE                                                02610000
         MVC   LINE+60(10),=X'40206B2020206B202120'                     02620000
         ED    LINE+60(10),DOUBLE+4                                     02630000
         MVI   LINE+70,C'K'                                             02640000
         TPUT  LINE,L'LINE                                              02650000
         SPACE                                                          02660000
         MVC   LINE(80),=CL80' '                                        02670000
         MVC   LINE(17),=C'SLOT SPACE IN USE'                           02680000
         AR    R7,R8                    SUM UP                          02690000
         CVD   R7,DOUBLE                                                02700000
         MVC   LINE+20(10),=X'40206B2020206B202120'                     02710000
         ED    LINE+20(10),DOUBLE+4                                     02720000
         MVI   LINE+30,C'K'                                             02730000
         MVC   LINE+40(17),=C'REAL SPACE IN USE'                        02740000
         SLL   R9,2                     MULT BY 4 TO GET K              02750000
         CVD   R9,DOUBLE                                                02760000
         MVC   LINE+60(10),=X'40206B2020206B202120'                     02770000
         ED    LINE+60(10),DOUBLE+4                                     02780000
         MVI   LINE+70,C'K'                                             02790000
         TPUT  LINE,L'LINE                                              02800000
         SPACE                                                          02810000
         MVC   LINE(80),=CL80' '                                        02820000
         MVC   LINE(17),=C'AVAIL FRAME SPACE'                           02830000
         L     R1,16                    FIND CVT                        02840000
         L     R7,X'164'(,R1)           FIND PVT                        02850000
         LH    R8,2(,R7)                LOAD AVAIL COUNT                02860000
         SLA   R8,2                     MULT BY 4 TO GET K              02870000
         CVD   R8,DOUBLE                                                02880000
         MVC   LINE+20(10),=X'40206B2020206B202120'                     02890000
         ED    LINE+20(10),DOUBLE+4                                     02900000
         MVI   LINE+30,C'K'                                             02910000
         MVC   LINE+40(18),=C'USABLE FRAME SPACE'                       02920000
         LH    R8,8(,R7)                USABLE FRAME COUNT              02930000
         SLL   R8,2                     MULT BY 4 TO GET K              02940000
         CVD   R8,DOUBLE                                                02950000
         MVC   LINE+60(10),=X'40206B2020206B202120'                     02960000
         ED    LINE+60(10),DOUBLE+4                                     02970000
         MVI   LINE+70,C'K'                                             02980000
         TPUT  LINE,L'LINE                                              02990000
         SPACE                                                          03000000
         MVC   LINE(80),=CL80' '                                        03010000
         MVC   LINE(19),=C'CSA/LPA FRAME SPACE'                         03020000
         LH    R8,292(,R7)                                              03030000
         SLA   R8,2                     MULT BY 4 TO GET K              03040000
         CVD   R8,DOUBLE                                                03050000
         MVC   LINE+20(10),=X'40206B2020206B202120'                     03060000
         ED    LINE+20(10),DOUBLE+4                                     03070000
         MVI   LINE+30,C'K'                                             03080000
         MVC   LINE+40(12),=C'NUCLEUS SIZE'                             03090000
         L     R3,16                    FIND CVT                        03100000
         L     R2,128(,R3)              PICK UP END OF NUC+1            03110000
         SRL   R2,10                    CONVERT TO K                    03120000
         CVD   R2,DOUBLE                                                03130000
         MVC   LINE+60(10),=X'40206B2020206B202120'                     03140000
         ED    LINE+60(10),DOUBLE+4                                     03150000
         MVI   LINE+70,C'K'                                             03160000
         TPUT  LINE,L'LINE                                              03170000
         SPACE                                                          03180000
         B     ASKAGAIN                                                 03190000
         SPACE                                                          03200000
EXIT     TSDERASE                                                       03210000
         L     R13,SAVEAREA+4                                           03220000
         RETURN (14,12),RC=0                                            03230000
         SPACE 2                                                        03240000
DOUBLE   DC    D'0'                                                     03250000
FWORK    DC    F'0'                                                     03260000
LINE     DC    CL80' '                                                  03270000
INPUT    DC    CL80' '                                                  03280000
OLDINPUT DC    CL80' '                                                  03290000
PROMPT   DC    CL2'IN'                                                  03300000
HEADER   DC    CL80'ASID NAME                 --VIO--   -SLOTS-   WKG S*03310000
               ET     CPU TIME   SRB TIME PR'                           03320000
OP1      DC    CL40'* * OPTIONS CURRENTLY SUPPORTED * *'                03330000
OP2      DC    CL40'E  - END THIS PROCESSOR'                            03340000
OP3      DC    CL40'H  - THIS DISPLAY (''?'' IS AN ALIAS)'              03350000
OP4      DC    CL40'I  - INITIATOR DISPLAY'                             03360000
OP5      DC    CL40'J  - RUNNING JOBS DISPLAY'                          03370000
OP6      DC    CL40'LP - DISPLAY OF MODULES IN LPA'                     03380000
OP7      DC    CL40'S  - STARTED TASK DISPLAY'                          03390000
OP8      DC    CL40'SS - SYSTEM PERFORMANCE STATISTICS'                 03400000
OP9      DC    CL40'T  - TSO USER DISPLAY'                              03410000
OP10     DC    CL40'TS - TSO USER DISPLAY W/STATISTICS'                 03420000
OPLEN    EQU   *-OP2                                                    03430000
         SPACE                                                          03440000
         LTORG                                                          03450000
         SPACE                                                          03460000
HEXTAB   EQU   *-C'0'                                                   03470000
         DC    C'0123456789ABCDEF'                                      03480000
         SPACE 2                                                        03490000
         REGS                                                           03500000
         END   MSYS                                                     03510000
//*
//ASM2   EXEC  MSASM,MOD=MSJOBS
//SYSIN    DD  *
JOBS     TITLE 'JOBS - TSO DISPLAY JOBS COMMAND'                        00010000
         MACRO                                                          00020000
&NAME    TSDERASE &N                                                    00030000
&NAME    BCR   0,0                      NOP                             00040000
         MEND                                                           00050000
         SPACE 1                                                        00060000
         PRINT NOGEN                                                    00070000
JOBS    CSECT                                                           00080000
         SAVE  (14,12),T,JOBS_TSO_COMMAND                               00090000
         USING JOBS,R15                                                 00100000
         LA    R11,SAVEAREA                                             00110000
         ST    R13,SAVEAREA+4                                           00120000
         ST    R11,8(,R13)                                              00130000
         LR    R13,R11                                                  00140000
         B     START                                                    00150000
         DROP  R15                                                      00160000
         SPACE 2                                                        00170000
SAVEAREA DC    18F'0'                                                   00180000
         SPACE 2                                                        00190000
START    DS    0H                                                       00200000
         USING SAVEAREA,R13                                             00210000
         SPACE 2                                                        00220000
         LM    R6,R9,CLEARREG           INITIALIZE TABLE                00230000
         MVCL  R6,R8                                                    00240000
         SPACE 1                                                        00250000
         TSDERASE                       ERASE THE SCREEN                00260000
         L     R1,16                    FIND CVT                        00270000
         L     R2,X'94'(,R1)            FIND BASEA (M.S.RES.DATA)       00280000
         LA    R3,TABLE                 NAME TABLE                      00290000
         LA    R4,80                    BXLE INCREMENT                  00300000
         L     R5,=A(TABLE+49*80)       TABLE END                       00310000
         SR    R6,R6                    COUNT OF JOBS                   00320000
CSCBLOOP ICM   R2,15,0(R2)                                              00330000
         BZ    CSCBEND                  WHEN DONE                       00340000
         CLI   28(R2),2                 TSO USER ID?                    00350000
         BNE   CSCBLOOP                                                 00360000
         SPACE 1                                                        00370000
* FIND THE ASSOCIATED ASCB                                              00380000
         SPACE 1                                                        00390000
         L     R1,16                    GET CVT                         00400000
         L     R1,X'22C'(,R1)           FIND ASVT                       00410000
         LA    R1,X'20C'(,R1)           FIND ENTRY ZERO                 00420000
         LH    R0,30(,R2)               GET ASID                        00430000
         SLA   R0,2                     MULT BY FOUR                    00440000
         AR    R1,R0                    R1 NOW POINTS TO ASVT ENTRY     00450000
GOTASVE  L     R1,0(,R1)                GET ASCB ADDRESS                00460000
         SPACE 1                                                        00470000
GOTASCB  ICM   R7,15,176(R1)            PICK UP STC NAME                00480000
         BZ    CSCBLOOP                 NONE, SKIP                      00490000
         CLC   =CL8'INIT',0(R7)         CHECK FOR INIT                  00500000
         BNE   CSCBLOOP                 SKIP IF NOT                     00510000
         SPACE 2                                                        00520000
         LA    R6,1(,R6)                BUMP USER COUNT                 00530000
         MVC   1(8,R3),8(R2)            MOVE JOBNAME TO TABLE           00540000
         SPACE                                                          00550000
         L     R15,X'90'(,R1)           FIND OUCB                       00560000
         TM    17(R15),X'80'            NON SWAPPABLE?                  00570000
         BZ    *+8                                                      00580000
         MVI   0(R3),C'^'                                               00590000
         CLI   32(R2),C' '              CHECK FOR PRINTABLE             00600000
         BNH   *+10                                                     00610000
         MVC   10(8,R3),32(R2)          MOVE IN PROCSTEP                00620000
         CLI   64(R2),C' '              CHECK FOR PRINTABLE             00630000
         BNH   *+10                                                     00640000
         MVC   19(8,R3),64(R2)          MOVE IN STEPNAME                00650000
         SPACE                                                          00660000
         LH    R0,120(,R1)              ALLOC AUX SLOTS (VAM)           00670000
         SLA   R0,2                     MULT BY 4 TO GET IT IN 'K'      00680000
         CVD   R0,DOUBLE                                                00690000
         MVC   27(7,R3),=X'4020206B202120'  EDIT MASK                   00700000
         ED    27(7,R3),DOUBLE+5      DO THE EDIT                       00710000
         MVI   34(R3),C'K'                                              00720000
         LH    R0,122(,R1)              ALLOC AUX SLOTS (NON-VAM)       00730000
         SLA   R0,2                     MULT BY 4 TO GET IT IN 'K'      00740000
         CVD   R0,DOUBLE                                                00750000
         MVC   35(7,R3),=X'4020206B202120'  EDIT MASK                   00760000
         ED    35(7,R3),DOUBLE+5      DO THE EDIT                       00770000
         MVI   42(R3),C'K'                                              00780000
         LH    R0,152(,R1)              REAL STORAGE IN USE             00790000
         ICM   R15,15,48(R2)            CHECK FOR V=R                   00800000
         BZ    VIRTJOB                                                  00810000
         LR    R0,R15                   DISPLAY V=R SIZE                00820000
         MVI   0(R3),C'='               SHOW V=R                        00830000
VIRTJOB  SLA   R0,2                     MULT BY 4 TO GET IT IN 'K'      00840000
         CVD   R0,DOUBLE                                                00850000
         MVC   45(7,R3),=X'4020206B202120'  EDIT MASK                   00860000
         ED    45(7,R3),DOUBLE+5      DO THE EDIT                       00870000
         MVI   52(R3),C'K'                                              00880000
         LM    R14,R15,64(R1)           PICK UP CPU TIME                00890000
         SRDL  R14,24                   MOVE TO ODD REG                 00900000
         M     R14,=A(1048576)          COMPUTE IN SECONDS              00910000
         D     R14,=A(10000*256)                                        00920000
         CVD   R15,DOUBLE                                               00930000
         MVC   55(10,R3),=X'4020206B2021204B2020'                       00940000
         ED    55(10,R3),DOUBLE+4      DO THE EDIT                      00950000
         MVI   65(R3),C'S'                                              00960000
         LM    R14,R15,200(R1)          PICK UP SRB TIME                00970000
         SRDL  R14,24                   MOVE TO ODD REG                 00980000
         M     R14,=A(1048576)          COMPUTE IN SECONDS              00990000
         D     R14,=A(10000*256)                                        01000000
         CVD   R15,DOUBLE                                               01010000
         MVC   66(10,R3),=X'4020206B2021204B2020'                       01020000
         ED    66(10,R3),DOUBLE+4      DO THE EDIT                      01030000
         MVI   76(R3),C'S'                                              01040000
         UNPK  DOUBLE(3),43(2,R1)       CONVERT DPRTY TO HEX            01050000
         TR    DOUBLE(2),HEXTAB                                         01060000
         MVC   78(2,R3),DOUBLE          MOVE FOR PRNTING                01070000
         SPACE                                                          01080000
         BXLE  R3,R4,CSCBLOOP                                           01090000
         TPUT  MSGOV,L'MSGOV                                            01100000
         SPACE 2                                                        01110000
CSCBEND  CVD   R6,DOUBLE                NUM JOBS MSG                    01120000
         MVC   NUMJOBS(4),=X'40202120'                                  01130000
         ED    NUMJOBS(4),DOUBLE+6                                      01140000
         TPUT  NUMJOBS,LMSG                                             01150000
         SPACE 2                                                        01160000
         LR    R5,R3                    SET END OF TABLE                01170000
         LA    R2,TABLE                 SET START OF TABLE              01180000
         LR    R6,R4                    FOR SORT                        01190000
         LR    R7,R5                                                    01200000
         SR    R7,R6                    BACK UP ONE ENTRY               01210000
         SR    R7,R6                                                    01220000
         LR    R8,R2                    SAVE FIRST ADDRESS              01230000
SORTLOOP CLC   0(8,R2),80(R2)           COMPARE TWO                     01240000
         BNH   SORTBXLE                                                 01250000
         LR    R8,R2                    LAST SWAP                       01260000
         XC    0(80,R2),80(R2)                                          01270000
         XC    80(80,R2),0(R2)                                          01280000
         XC    0(80,R2),80(R2)                                          01290000
SORTBXLE BXLE  R2,R6,SORTLOOP                                           01300000
         LR    R7,R8                    SAVE LAST SWAP                  01310000
         LA    R2,TABLE                 REINIT                          01320000
         LR    R8,R2                    REINIT LAST SWAP                01330000
COMPARE  CR    R2,R7                    DONE?                           01340000
         BL    SORTLOOP                                                 01350000
* OUTPUT THE DATA                                                       01360000
         SPACE 1                                                        01370000
BLNKLOOP CLC   =CL10' ',0(R2)           BLANK ENTRY?                    01380000
         BE    PRNTBXLE                                                 01390000
PRNTTPUT TPUT  (2),(4),R                                                01400000
PRNTBXLE BXLE  R2,R4,BLNKLOOP                                           01410000
         SPACE 1                                                        01420000
         L     R13,SAVEAREA+4                                           01430000
         RETURN (14,12),RC=0                                            01440000
         SPACE 1                                                        01450000
NUMJOBS DC    X'40202120',C' ACTIVE JOBS            --VIO--'            01460000
        DC    C' -SLOTS-   WKG SET     CPU TIME   SRB TIME PR'          01470000
LMSG     EQU   *-NUMJOBS                                                01480000
MSGOV    DC    C'* TABLE OVERFLOW *'                                    01490000
DOUBLE   DC    D'0'                                                     01500000
         SPACE                                                          01510000
HEXTAB   EQU   *-C'0'                                                   01520000
         DC    C'0123456789ABCDEF'                                      01530000
         SPACE 2                                                        01540000
         REGS                                                           01550000
         SPACE 1                                                        01560000
         LTORG                                                          01570000
         SPACE 1                                                        01580000
CLEARREG DC    A(TABLE,4000),A(0),X'40000000'                           01590000
TABLE    DC    50CL80' '                                                01600000
         END   JOBS                                                     01610000
//*
//ASM3   EXEC  MSASM,MOD=MSUSERS
//SYSIN    DD  *
USERS    TITLE 'USERS - TSO DISPLAY LOGGED ON USERS COMMAND'            00010000
         MACRO                                                          00020000
&NAME    TSDERASE &N                                                    00030000
&NAME    BCR   0,0                      NOP                             00040000
         MEND                                                           00050000
         SPACE 1                                                        00060000
         PRINT NOGEN                                                    00070000
USERS    CSECT                                                          00080000
         SAVE  (14,12),T,USERS_TSO_COMMAND                              00090000
         USING USERS,R15                                                00100000
         LA    R11,SAVEAREA                                             00110000
         ST    R13,SAVEAREA+4                                           00120000
         ST    R11,8(,R13)                                              00130000
         LR    R13,R11                                                  00140000
         B     START                                                    00150000
         DROP  R15                                                      00160000
         SPACE 2                                                        00170000
SAVEAREA DC    18F'0'                                                   00180000
         SPACE 2                                                        00190000
START    DS    0H                                                       00200000
         USING SAVEAREA,R13                                             00210000
         SPACE 2                                                        00220000
         LM    R6,R9,CLEARREG                                           00230000
         MVCL  R6,R8                    CLEAR TABLE                     00240000
         SPACE                                                          00250000
         TSDERASE                       ERASE THE SCREEN                00260000
         L     R1,16                    FIND CVT                        00270000
         L     R2,X'94'(,R1)            FIND BASEA (M.S.RES.DATA)       00280000
         LA    R3,TABLE                 NAME TABLE                      00290000
         LA    R4,10                    BXLE INCREMENT                  00300000
         LA    R5,TABLE+199*10          TABLE END                       00310000
         SR    R6,R6                    COUNT OF USERS                  00320000
CSCBLOOP ICM   R2,15,0(R2)                                              00330000
         BZ    CSCBEND                  WHEN DONE                       00340000
         CLI   28(R2),1                 TSO USER ID?                    00350000
         BNE   CSCBLOOP                                                 00360000
         LA    R6,1(,R6)                BUMP USER COUNT                 00370000
         MVC   0(8,R3),8(R2)            MOVE USERID TO TABLE            00380000
         BXLE  R3,R4,CSCBLOOP                                           00390000
         TPUT  MSGOV,L'MSGOV                                            00400000
         SPACE 2                                                        00410000
CSCBEND  CVD   R6,DOUBLE                NUM USERS MSG                   00420000
         MVC   NUMUSERS(4),=X'40202020'                                 00430000
         ED    NUMUSERS(4),DOUBLE+6                                     00440000
         TPUT  NUMUSERS,LMSG                                            00450000
         SPACE 2                                                        00460000
         LR    R5,R3                    SET END OF TABLE                00470000
         LA    R2,TABLE                 SET START OF TABLE              00480000
         LR    R6,R4                    FOR SORT                        00490000
         LR    R7,R5                                                    00500000
         SH    R7,=H'20'                BACK UP ONE ENTRY               00510000
         LR    R8,R2                    SAVE FIRST ADDRESS              00520000
SORTLOOP CLC   0(8,R2),10(R2)           COMPARE TWO                     00530000
         BNH   SORTBXLE                                                 00540000
         LR    R8,R2                    LAST SWAP                       00550000
         XC    0(8,R2),10(R2)                                           00560000
         XC    10(8,R2),0(R2)                                           00570000
         XC    0(8,R2),10(R2)                                           00580000
SORTBXLE BXLE  R2,R6,SORTLOOP                                           00590000
         LR    R7,R8                    SAVE LAST SWAP                  00600000
         LA    R2,TABLE                 REINIT                          00610000
         LR    R8,R2                    REINIT LAST SWAP                00620000
COMPARE  CR    R2,R7                    DONE?                           00630000
         BL    SORTLOOP                                                 00640000
         SPACE 2                                                        00650000
* SKIP FOR NON BLANK NAME                                               00660000
         SPACE 1                                                        00670000
BLNKLOOP CLI   0(R2),C' '                                               00680000
         BNE   PRNTLOOP                                                 00690000
         BXLE  R2,R4,BLNKLOOP                                           00700000
         SPACE 1                                                        00710000
* OUTPUT NAMES                                                          00720000
         SPACE 1                                                        00730000
PRNTLOOP LR    R3,R5                    COMPUTE LENGTH                  00740000
         SR    R3,R2                                                    00750000
         TPUT  (2),(3),R                                                00760000
         SPACE 1                                                        00770000
         L     R13,SAVEAREA+4                                           00780000
         RETURN (14,12),RC=0                                            00790000
         SPACE 1                                                        00800000
NUMUSERS DC    X'40202020',C' USERS LOGGED ON'                          00810000
LMSG     EQU   *-NUMUSERS                                               00820000
MSGOV    DC    C'* TABLE OVERFLOW *'                                    00830000
DOUBLE   DC    D'0'                                                     00840000
         SPACE 2                                                        00850000
         REGS                                                           00860000
         SPACE 1                                                        00870000
         LTORG                                                          00880000
         SPACE 1                                                        00890000
CLEARREG DC    A(TABLE,2000),A(0),X'40000000'                           00900000
TABLE    DC    200CL10' '                                               00910000
         END   USERS                                                    00920000
//*
//LKED   EXEC  PGM=IEWL,PARM='MAP,LIST,XREF',REGION=256K,COND=(0,NE)
//SYSLIN   DD  *
  INCLUDE OBJLIB(MSYS)
  INCLUDE OBJLIB(MSJOBS)
  INCLUDE OBJLIB(MSUSERS)
  ENTRY MSYS
  NAME MSYS(R)
//SYSLMOD  DD  DSN=SYS2.LINKLIB,DISP=OLD       <== TARGET LOAD LIBRARY
//OBJLIB   DD  DSN=&MSOBJECT,DISP=(OLD,PASS)
//SYSUT1   DD  UNIT=SYSDA,SPACE=(CYL,(3,1)),DSN=&SYSUT1
//SYSPRINT DD  SYSOUT=*
//*
//HELP   EXEC  PGM=IEFBR14,PARM=NEW,COND=(0,NE)  DO NOT INSTALL
//SYSPRINT DD  SYSOUT=*
//SYSUT2   DD  DISP=OLD,DSN=SYS2.HELP         <== TARGET HELP LIBRARY
//SYSIN    DD  *
./ ADD NAME=MS
)S SUBCOMMANDS -                                                        00000010
     SS,LP,TS,I,J,S,T,E                                                 00000020
)F FUNCTION -                                                           00000030
     THE MS COMMAND DISPLAYS MVS SYSTEM INFORMATION                     00000040
)X SYNTAX -                                                             00000050
     MS                                                                 00000060
)O OPERANDS -                                                           00000070
     THERE ARE NO OPERANDS FOR THE MS COMMAND.                          00000080
                                                                        00000090
 SUBCOMMANDS                                                            00000100
   SS -                                                                 00000110
     THE SS SUBCOMMAND DISPLAYS SYSTEM STATISTICS.                      00000120
                                                                        00000130
   LP -                                                                 00000140
     THE LP SUBCOMMAND DISPLAYS LINK PACK INFORMATION.                  00000150
                                                                        00000160
   TS -                                                                 00000170
     THE TS COMMAND DISPLAYS TSO STATISTICS.                            00000180
                                                                        00000190
   I  -                                                                 00000200
     THE I SUBCOMMAND DISPLAYS INITIATORS.                              00000210
                                                                        00000220
   J  -                                                                 00000230
     THE J SUBCOMMAND DISPLAYS JOBS.                                    00000240
                                                                        00000250
   S  -                                                                 00000260
     THE S COMMAND DISPLAYS STARTED TASKS.                              00000270
                                                                        00000280
   T  -                                                                 00000290
     THE T SUBCOMMAND DISPLAYS A COUNT OF THE NUMBER OF TSO USERS.      00000300
                                                                        00000310
   E  -                                                                 00000320
     THE E COMMAND EXITS FROM MS.                                       00000330
./ ENDUP
/*
//
