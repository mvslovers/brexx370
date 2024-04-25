         MACRO
&LBL     ISPCALL &LIST,        CALL PARAMETERS                         X
               &DELETED=,   EP PARAMETER DELETED               01/17/84X
               &LISTLBL=,      LABEL FOR PARAMETER LIST (NON-REENT)    X
               &WKAREA=,       TO BUILD CALL LIST (REENTERANT CODE)    X
               &WKREG=,        WORK REGISTER (DEFAULT 1)               X
               &TRACE=         'OFF' OR BIT FOR TRACE MODE
.*                                     RON MURA, TECHNICAL SERVICES
.*  ONCE WKAREA, WKREG, AND TRACE ARE SPECIFIED, THEY ARE USED IN ALL
.*  SUBSEQUENT OCCURRENCES OF THIS MACRO, UNLESS THE PARAMETER IS
.*  EXPLICITLY CODED.
.*  NOTE: FIRST 4 BYTES OF WKAREA ARE USED TO STORE NUMERIC VALUES,
.*  WHICH ARE PRIMARILY LENGTH FIELDS.
.* 01/17/84 MURA - SUPPORT "CALL ISPEXEC" FORMAT FOR ISPF VER2 01/17/84
         LCLA  &S,&T,&U,&TRCEMSK
         LCLB  &NUMSW
         LCLC  &NDX,&WKAR,&WKRG
         LCLC  &EP             ISPLINK OR ISPEXEC              01/17/84
         GBLC  &ISPRREG,&ISPRAR,&ISPTRC1
         GBLA  &ISPTRC2
&NDX     SETC  '&SYSNDX'
&EP      SETC  'ISPLINK'       DEFAULT IS CALL TO ISPLINK      01/17/84
&S       SETA  1               SUBSCRIPT FOR GOING THRU &LIST
***********************************************************************
         AIF   (T'&LBL NE 'O').L1
*                  ISPCALL  -  INVOKE ISPF DIALOG SERVICES      ISPCALL
         AGO   .L2
.L1      ANOP
&LBL     DS    0H  ISPCALL  -  INVOKE ISPF DIALOG SERVICES      ISPCALL
.L2      ANOP
         AIF   (T'&LIST NE 'O').A1
         MNOTE 12,'*** ISPCALL PARAMETERS MUST BE PROVIDED ***'
         AGO   .EXIT
.A1      AIF   ('&LIST'(1,1) EQ '(').CHKTRCE
         MNOTE *,'*** ISPCALL "CALL ISPEXEC" FORMAT USED ***'  01/17/84
&EP      SETC  'ISPEXEC'       CALL ISPEXEC                    01/17/84
.*               LINE DELETED                                  01/17/84
.****************** ANALYZE "TRACE" PARAMETER *************************
.CHKTRCE AIF   (T'&TRACE EQ 'O' AND '&ISPTRC1' NE '').TRCE4
         AIF   (T'&TRACE EQ 'O' AND '&ISPTRC1' EQ '').TRCEOFF
         AIF   ('&TRACE'(1,1) EQ '(').TRCEON
         AIF   ('&TRACE' EQ 'OFF').TRCEOFF
         MNOTE 12,'*** INVALID TRACE PARAMETERS ***'
         AGO   .EXIT
.TRCEON  AIF   (T'&TRACE(2) EQ 'N').TRCE2
.TRCE8   MNOTE 12,'*** TRACE BIT (2ND PARAMETER) MUST BE 0 - 7 ***'
         AGO   .EXIT
.TRCE2   AIF   (&TRACE(2) GE 0 OR &TRACE(2) LE 7).TRCE3
         AGO   .TRCE8
.TRCE3   ANOP
&ISPTRC1 SETC  '&TRACE(1)'     SET GLOBAL VARIABLE
&ISPTRC2 SETA  &TRACE(2)       SET GLOBAL VARIABLE
.TRCE4   ANOP
&U       SETA  0
&TRCEMSK SETA  255
&T       SETA  128
.TRCE5   AIF   (&U GT 7).CHKREG
         AIF   (&ISPTRC2 NE &U).TRCE7
.TRCE6   ANOP
&U       SETA  &U+1
&T       SETA  &T/2
         AGO   .TRCE5
.TRCE7   ANOP
&TRCEMSK SETA  &TRCEMSK-&T
         AGO   .TRCE6
.TRCEOFF ANOP
&ISPTRC1 SETC  ''              SET GLOBAL VARIABLE
.****************** ANALYZE "WKREG" PARAMETER *************************
.CHKREG  AIF   (T'&WKREG EQ 'O').A2
&ISPRREG SETC  '&WKREG'        SET GLOBAL VARIABLE
.A2      AIF   ('&ISPRREG' EQ '').A3
&WKRG    SETC  '&ISPRREG'
         AGO   .CHKAREA
.A3      ANOP
&ISPRREG SETC  '1'             SET GLOBAL VARIABLE
         AGO   .A2
.****************** SEE IF USING PROVIDED WORKAREA ********************
.CHKAREA AIF   (T'&WKAREA NE 'O' OR '&ISPRAR' NE '').RENT
         AIF   (T'&LISTLBL EQ 'O').B1
&WKAR    SETC  '&LISTLBL'
         AGO   .B2
.B1      ANOP
&WKAR    SETC  'ISPC&NDX'      LABEL FOR MACRO WORKAREA
.B2      ANOP
&T       SETA  4*(N'&LIST+1)   LENGTH OF MACRO WORKAREA
         B     &WKAR.+&T             BRANCH AROUND DATA         ISPCALL
&T       SETA  N'&LIST+1
&WKAR    DC    &T.F'0'               PARAMETER LIST             ISPCALL
.******************** BUILD PARAMETER LIST ****************************
.CHKTYPE AIF   ('&EP' EQ 'ISPEXEC').ISPEXEC                    01/17/84
.LOOP    AIF   (&S GT N'&LIST).ENDLOOP
         AIF   ('&LIST(&S)'(1,1) EQ '''').C1 TEST FOR LITERAL
         AIF   (T'&LIST(&S) EQ 'N').NUM      TEST FOR NUMERIC
         AIF   ('&LIST(&S)'(1,1) EQ '(').REG TEST FOR REG NOTATION
         LA    &WKRG,&LIST(&S)       LOAD DATA ADDR             ISPCALL
.ST      ANOP
&T       SETA  4*&S
         ST    &WKRG,&WKAR.+&T       STORE IN PARAM LIST        ISPCALL
         AIF   ('&ISPTRC1' EQ '' OR &S GT 1).C3           TRACE
         TM    &ISPTRC1,&TRCEMSK     IS TRACE BIT ON?     TRACE ISPCALL
         BZ    ISPT&NDX                                   TRACE ISPCALL
         AIF   ('&WKRG' EQ '1' OR '&WKRG' EQ 'R1').C4     TRACE
         LR    1,&WKRG               LOAD SRVC NAME ADDR  TRACE ISPCALL
.C4      AIF   ('&LIST(&S)'(1,1) EQ '''').C5 LITERAL?     TRACE
         LA    0,8                   LOAD LENGTH          TRACE ISPCALL
         AGO   .C6                                        TRACE
.C5      ANOP                                             TRACE
&U       SETA  K'&LIST(&S)-2   LENGTH OF SERVICE NAME     TRACE
         LA    0,&U                  LOAD LENGTH          TRACE ISPCALL
.C6      ANOP                                             TRACE
         SVC   93                    ISSUE TPUT SVC       TRACE ISPCALL
ISPT&NDX EQU   *                                          TRACE ISPCALL
.C3      ANOP
&S       SETA  &S+1
         AGO   .LOOP
.C1      AIF   (&S EQ 1).C2    SPF SERVICE NAME - LENGTH IS OK
&T       SETA  K'&LIST(&S)-2
         AIF   (&T GT 7).C2    LENGTH 8 OR GREATER IS OK
&T       SETA  &T+1            ADD FOR ONE BLANK
         LA    &WKRG,=CL&T.&LIST(&S) LOAD DATA ADDR             ISPCALL
         AGO   .ST
.C2      ANOP
         LA    &WKRG,=C&LIST(&S)     LOAD DATA ADDR             ISPCALL
         AGO   .ST
.NUM     AIF   (&NUMSW).NUM2
.*  NOTE: SPF WILL MODIFY LENGTH FIELDS, SO THEY CANNOT BE IN
.*  REENTERANT CODE.
         MVC   &WKAR.(4),=F'&LIST(&S)'                                 X
                                     MOVE NUMERIC VALUE         ISPCALL
&NUMSW   SETB  1
         AGO   .LA
.NUM2    MNOTE 12,'*** ONLY ONE NUMERIC ALLOWED PER ISPCALL MACRO - LISX
               T ITEM &S --&LIST(&S)-- IS SECOND OCCURRENCE ***'
         AGO   .EXIT
.LA      ANOP
         LA    &WKRG,&WKAR           LOAD DATA ADDR             ISPCALL
         AGO   .ST
.REG     ANOP
&T       SETA  4*&S
         ST    &LIST(&S),&WKAR.+&T                              ISPCALL
         AGO   .C3
.******************** USING PROVIDED WORKAREA *************************
.RENT    AIF   (T'&WKAREA EQ 'O').RENT2
&ISPRAR  SETC  '&WKAREA'       SET GLOBAL VARIABLE
.RENT2   ANOP
&WKAR    SETC  '&ISPRAR'
         AGO   .CHKTYPE                                        01/17/84
.*************** BUILD PARAMETER LIST FOR CALL TO ISPEXEC *****01/17/84
.ISPEXEC ANOP  ,   FIRST FIND ALL DOUBLE QUOTE AND AMPERSAND   01/17/84
&S       SETA  2                     SEARCH START LOC.         01/17/84
&T       SETA  K'&LIST-2             SEARCH END LOC.           01/17/84
&U       SETA  K'&LIST-2             LENGTH OF BUFFER          01/17/84
.ISPEXLP AIF   (&S GT &T).ISPEXCD                              01/17/84
         AIF   ('&LIST'(&S,2) EQ '''').DOUBLE                  01/17/84
         AIF   ('&LIST'(&S,2) EQ '&&').DOUBLE                  01/17/84
&S       SETA  &S+1                                            01/17/84
         AGO   .ISPEXLP                                        01/17/84
.DOUBLE  ANOP ,                                                01/17/84
&S       SETA  &S+2                  SKIP DOUBLED CHAR.        01/17/84
&U       SETA  &U-1                  DEDUCT ONE FOR DOUBLE CHR 01/17/84
         AGO   .ISPEXLP                                        01/17/84
.ISPEXCD ANOP ,                                                01/17/84
         MVC   &WKAR.(4),=F'&U'      LENGTH OF BUFFER  01/17/84 ISPCALL
         LA    &WKRG,&WKAR           ADDR./ BUFF. LNTH 01/17/84 ISPCALL
         ST    &WKRG,&WKAR+4         STORE BUFF. LNTH  01/17/84 ISPCALL
         LA    &WKRG,=C&LIST         ADDR./ BUFFER     01/17/84 ISPCALL
         ST    &WKRG,&WKAR+8         STORE BUFF. ADDR. 01/17/84 ISPCALL
&T       SETA  8                     SET TO VL BIT LOC.        01/17/84
.****************** GENERATE STATEMENTS FOR CALL **********************
.ENDLOOP ANOP
         OI    &WKAR.+&T,X'80'       TURN ON VL BIT             ISPCALL
         LA    1,&WKAR.+4                                       ISPCALL
         L     15,=V(&EP)                                       ISPCALL
         BALR  14,15                                            ISPCALL
.EXIT    ANOP
***********************************************************************
         SPACE 2
         MEND
