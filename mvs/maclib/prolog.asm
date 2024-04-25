         MACRO
&NAME    PROLOG &REG,&CODE,&ID,&CLEAR=YES,&REGS=YES,&FPR=F,            X
               &GPR=R,&PARM=,&RENT=,&RREGS=(14,12),&SAVE=,&SP=0,       X
               &TYPE=,&USE=NO,&USING=12,&LIST=
.*
.*       GLOBAL VARIABLES DESCRIPTION
.*
.*       &REGSSW   BOOLEAN FLAG TO SIGNAL WHETHER REGISTER EQUATES
.*                    HAVE BEEN GENERATED IN A PREVIOUS EXPANSION
.*
.*       &REGSNM   CHARACTER STRING THAT CONTAINS THE EQUATE NAME
.*                    PREFIX FOR THE GENERAL REGISTERS (SEE &RN
.*                    VALUE DESCRIPTION BELOW)
.*
.*       &USNGSW   BOOLEAN FLAG TO SIGNAL WHETHER THE  XXUSE  MACRO
.*                    IS TO BE USED IN-PLACE OF THE USING STATEMENT
.*
         GBLB  &REGSSW,&USNGSW
         GBLC  &REGSNM
         LCLA  &A,&B,&C
         LCLC  &I,&N,&R,&RN,&X,&CSECT
*  PROLOG  MACRO -- ASSEMBLY PROLOG  01/14/78 MARK GOTO
         AIF   ('&LIST' EQ 'YES').COMNT
*          (CODE LIST=YES FOR FURTHER DESCRIPTION)
*
         AGO   .NOCOMNT
.COMNT   ANOP
*    &REG,&CODE,&ID  CONSULT OPERANDS DESCRIPTION OF OS/VS2 SAVE MACRO
*                    (SUPERVISOR SERVICES AND MACRO INSTR. GC28-0683)
*
*        *NOTE* = SPECIFYING &CODE=T INSURES THAT THE CONTENTS OF
*                 R14 AND R15 ARE SAVED
*        *NOTE* = IF THE LENGTH OF &ID IS > 8, THEN CURRENT DATE
*                 AND TIME WILL BE APPENDED TO THE ID STRING
*        *NOTE* = IF &RENT= PARAMETER IS SPECIFIED, THEN THE &REG
*                 AND &CODE PARAMETERS ARE IGNORED
*
*
*    ,&CLEAR=  YES/NO OPTION TO GENERATE CODE TO ZERO GETMAINED AREA
*
*        OPERATION = GENERATE CODE TO ZERO GETMAINED WORK AREA:
*
*          ORG *-2                          RE-ORIGIN OVER SVC
*          LR  3,0                          SAVE DSECT LENGTH
*          SVC 10                           ISSUE GETMAIN SVC
*          LR  2,1                          COPY DSECT AREA ADDR
*          SLR 14,14                        ZERO SOURCE ADDR
*          LR  15,14                        ZERO SOURCE LENGTH
*          MVCL 2,14                        ZERO DSECT AREA
*
*
*    ,&REGS=   YES/NO OPTION TO GENERATE REGISTER REGISTER EQUATES
*
*        OPERATION = GENERATE/SUPPRESS REGISTER EQUATES
*
*
*    ,&FPR=    PREFIX FOR GENERATING FLOATING POINT REGISTER EQUATES
*
*        OPERATION = GENERATE REGISTER EQUATES FOR 0,2,4,6
*
*
*    ,&GPR=    PREFIX FOR GENERATING GENERAL REGISTER EQUATES
*
*        OPERATION = GENERATE REGISTER EQUATES FOR 0 THRU 15
*
*
*    ,&PARM=   PARM ADDR REG.
*                 OR
*              (PARM ADDR REG. , LABEL)
*
*        OPERATION = LOAD DESIGNATED PARM REG. AND PROVIDE USING
*                    STMT. AS FOLLOWS:
*
*          LR  "PARM REG.",1
*                 OR
*          LR  "PARM REG.",1
*          USING "LABEL","PARM REG."
*
*        *NOTE* = "PARM REG." MUST A DECIMAL CONSTANT OR AN
*                 EQUATE OF THE FORM  R"X"  WHERE "X" IS A
*                 DECIMAL REGISTER NUMBER
*
*
*    ,&RENT=   DSECT ADDR REG.
*                 OR
*              (DSECT ADDR REG. , DSECT NAME , DSECT SIZE)
*
*        OPERATION = ISSUE GETMAIN, CONNECT GETMAIN AREA AS NEW SAVE
*                    AREA, LOAD DESIGNATED DSECT ADDR REG. AND PROVIDE
*                    USING STMT. AS FOLLOWS:
*
*          GETMAIN R,LV=72,...
*              .
*          LR  "DSECT REG.",1
*                          OR
*          GETMAIN R,LV="DSECT SIZE",...
*              .
*          LR  "DSECT REG.",1
*          USING "DSECT NAME","DSECT REG."
*
*        *NOTE* = "DSECT REG." MUST A DECIMAL CONSTANT OR AN
*                 EQUATE OF THE FORM  R"X"  WHERE "X" IS A
*                 DECIMAL REGISTER NUMBER
*        *NOTE* = WHEN THIS PARAMETER IS SPECIFIED, &REG, &CODE AND
*                 &SAVE= PARAMETERS ARE IGNORED
*
*
*    ,&RREGS=  (FIRST REG. , LAST REG.)
*
*        OPERATION = SPECIFY REGS. TO BE SAVED AS FOLLOWS:
*
*          STM "FIRST REG.","LAST REG.",12(13)
*
*        *NOTE* = THIS PARAMETER IS IGNORED EXCEPT WHEN &RENT= IS
*                 SPECIFIED
*
*
*    ,&SAVE=   (TEMP REG. , SAVE AREA)
*                OR
*    ,&SAVE=   SAVE AREA
*
*        OPERATION = GENERATE CODE TO CONNECT SAVE AREAS AS FOLLOWS:
*
*          LA  "TEMP REG.","SAVE AREA"
*          ST  13,4(,"TEMP REG.")
*          ST  "TEMP REG.",8(,13)
*          LR  13,"TEMP REG."
*                OR
*          LR  15,13
*          LA  14,"SAVE AREA"
*          ST  13,4(,14)
*          ST  14,8(,13)
*          LR  13,14
*          LM  14,15,12(15)
*
*        *NOTE* = SPECIFYING THIS PARAMETER CAUSES THAT THE
*                 CONTENTS OF R14 AND R15 ARE SAVED
*        *NOTE* = "TEMP REG." MUST A DECIMAL CONSTANT OR AN
*                 EQUATE OF THE FORM  R"X"  WHERE "X" IS A
*                 DECIMAL REGISTER NUMBER
*        *NOTE* = IF &RENT= IS SPECIFIED, THEN THIS PARAMETER IS
*                 IGNORED
*
*
*    ,&SP=     SUB-POOL NUMBER FOR RE-ENTRANT GETMAIN
*
*        OPERATION = SPECIFY THE GETMAIN SUB-POOL OPERAND:
*
*          GETMAIN R,LV=...,SP=...
*
*        *NOTE* = THIS PARAMETER DEFAULTS TO "SP=0" (IE. SUB-POOL
*                 NUMBER ZERO)
*
*
*    ,&TYPE=   'CSECT'   OR   ALIGNMENT SPECIFICATION
*
*        OPERATION = GENERATE 'CSECT', OR 'DS' ALIGNMENT STATEMENT
*                    WITH &NAME (IF &NAME IS OMITTED, THEN &SYSECT)
*                    PARAMETER IN THE NAME FIELD.  EXAMPLE:
*
*                    "&NAME" CSECT
*                                      OR
*                    "&NAME" DS  "ANY VALID OPERAND"
*
*
*    ,&USE=    YES/NO OPTION TO GENERATE  XXUSE  MACROS IN PLACE OF
*              USING STATEMENTS
*
*        OPERATION = GENERATE  XXUSE  MACROS -- USING STATEMENTS WITH
*                    MEMORY (THE COMPLEMENTARY MACRO IS  XXDRP ;
*                    WHICH MAY BE USED WITH NO OPERAND TO DROP ALL
*                    ACTIVE BASE REGISTERS)
*
*
*    ,&USING=  BASE REG.   OR   ,&USING=  (BASE REG. , LABEL)
*
*        OPERATION = GENERATE THE FOLLOWING CODE:
*
*          LR  "BASE REG.",15
*          USING "&NAME / &SYSECT","BASE REG."
*                          OR
*          LR  "BASE REG.",15
*          USING "LABEL","BASE REG."
*
*        *NOTE* = "BASE REG." MUST A DECIMAL CONSTANT OR AN
*                 EQUATE OF THE FORM  R"X"  WHERE "X" IS A
*                 DECIMAL REGISTER NUMBER
*
*
.NOCOMNT AIF   ('&REGS' EQ 'NO').REGSSW
         AIF   (&REGSSW OR '&REGS' NE 'YES').NOREGS
***********************************************************************
*                                                                     *
*        REGISTER EQUATES                                             *
*                                                                     *
***********************************************************************
&GPR.0   EQU   0
&GPR.1   EQU   1
&GPR.2   EQU   2
&GPR.3   EQU   3
&GPR.4   EQU   4
&GPR.5   EQU   5
&GPR.6   EQU   6
&GPR.7   EQU   7
&GPR.8   EQU   8
&GPR.9   EQU   9
&GPR.10  EQU   10
&GPR.11  EQU   11
&GPR.12  EQU   12
&GPR.13  EQU   13
&GPR.14  EQU   14
&GPR.15  EQU   15
&FPR.0   EQU   0
&FPR.2   EQU   2
&FPR.4   EQU   4
&FPR.6   EQU   6
         SPACE 1
.REGSSW  ANOP
&REGSNM  SETC  '&GPR'                      .SAVE GPR PREFIX
&REGSSW  SETB  1                           .SET FLAG TO AVOID
         AGO   .START                      . DUPLICATES IF RE-INVOKED
.NOREGS  MNOTE *,'REGS SUPRESSED'
.START   ANOP
&RN      SETC  '&REGSNM'
&USNGSW  SETB  (&USNGSW OR '&USE' EQ 'YES')
&N       SETC  '&NAME'                     .SAVE LABEL NAME ON MACRO
&CSECT   SETC  '&SYSECT'                   .SAVE CSECT NAME
         AIF   ('&TYPE' EQ '').NOTYPE      .SKIP IF TYPE OMITTED
&N       SETC  ''                          .SET NAME FIELD TO NULL
         AIF   ('&TYPE' NE 'CSECT').DSTYPE .MUST BE DS ALIGNMENT OPRND
&CSECT   SETC  '&NAME'                     .SET CSECT NAME
&NAME    CSECT
         AGO   .NOTYPE
.DSTYPE  ANOP
&NAME    DS    &TYPE
.NOTYPE  AIF   ('&ID' EQ '').NULLID        .SKIP IF ID OMITTED
&I       SETC  '&ID'
         AIF   ('&ID' EQ '*').NAMEID       .IF ID REQUESTED, GO BUILD
         AIF   (K'&I LE 8).SPLITID         .IF SIMPLE PGM NAME, GO USE
         AGO   .EXPANID                    .OTHERWISE, GO EXPAND
.NAMEID  AIF   ('&NAME' EQ '').CSECTID     .IF NO NAME, TRY CSECT ID
&I       SETC  '&NAME'
         AGO   .EXPANID                    .GO EXPAND NAME ID
.CSECTID AIF   ('&CSECT' EQ '').E4         .IF NO CSECT NAME, ERROR
&I       SETC  '&CSECT'
.EXPANID ANOP                              .APPEND ID INFORMATION
&I       SETC  '&I_&SYSDATE_'.'&SYSTIME'(1,2).':'.'&SYSTIME'(4,2)
.SPLITID ANOP
&A       SETA  ((K'&I+2)/2)*2+4            .COMPUTE BRANCH LENGTH
&N       B     &A.(0,15)                    BRANCH AROUND ID
&A       SETA  K'&I                        .SET IDENTIFIER LENGTH
         DC    AL1(&A)                      LENGTH OF IDENTIFIER
.SPLITLP AIF   (&A GT 24).SPLITUP
&X       SETC  '&I'(&B+1,&A)               .ISOLATE REMAINDER OF ID
         DC    CL&A'&X'                          IDENTIFIER
         AGO   .REGS
.SPLITUP ANOP
&X       SETC  '&I'(&B+1,24)               .SUBSTRING IDENTIFIER
         DC    CL24'&X'                          IDENTIFIER
&B       SETA  &B+24                       .INCREMENT POSITION
&A       SETA  &A-24                       .DECREMENT LENGTH
         AGO   .SPLITLP                    .GO SPLIT ID FURTHER
.NULLID  ANOP
&N       DS    0H
.REGS    AIF   ('&RENT' EQ '').REGSB       .SKIP IF NOT RE-ENTRANT
&A       SETA  &RREGS(1)                   .SET FIRST RENT REG. NO.
         AIF   (&A EQ 14).REGSA            .SKIP IF VALID
         MNOTE *,'RENT. REG(1) SET TO 14'
&A       SETA  14                          .CORRECT ERROR
.REGSA   ANOP
&B       SETA  &RREGS(2)                   .SET LAST RENT REG. NO.
         AIF   (&B GE 3 AND &B LE 12).REGSI     .SKIP IF VALID
         MNOTE *,'RENT. REG(2) SET TO 3'
&B       SETA  3                           .CORRECT ERROR
         AGO   .REGSI
.REGSB   AIF   ('&REG' EQ '').E1           .ERROR IF REGS OMITTED
         AIF   ('&CODE' NE '' AND '&CODE' NE 'T').E2 .INVALID CODE
&R       SETC  '&REG(1)'                   .GET REG. EXPRESSION
         AIF   (T'&REG(1) EQ 'N').REGSC    .SKIP IF VALID REG. NO.
         AIF   ('&R'(1,K'&RN) NE '&RN').E3 .SKIP IF NOT REG. EQU
&R       SETC  '&R'(K'&RN+1,K'&R-K'&RN)    .GET REG. NO.
         AIF   ('&R' LT '0' OR '&R' GT '15').E3 .ERROR IF INVALID
.REGSC   ANOP
&A       SETA  &R                          .SET FIRST SAVE REG. NO.
         AIF   (&A LT 0 OR &A GT 15).E3    .ERROR IF BAD REG. NO.
&B       SETA  &A                          .ASSUME LAST = FIRST
         AIF   (N'&REG EQ 1).REGSF         .SKIP IF ONLY ONE REG.
&R       SETC  '&REG(2)'                   .GET REG. EXPRESSION
         AIF   (T'&REG(2) EQ 'N').REGSE    .SKIP IF VALID REG. NO.
         AIF   ('&R'(1,K'&RN) NE '&RN').E3 .ERROR IF NOT REG. EQU
&R       SETC  '&R'(K'&RN+1,K'&R-K'&RN)    .GET REG. NO.
         AIF   ('&R' LT '0' OR '&R' GT '15').E3 .ERROR IF INVALID
.REGSE   ANOP
&B       SETA  &R                          .SET LAST SAVE REG. NO.
         AIF   (&B LT 0 OR &B GT 15).E3    .ERROR IF BAD REG. NO.
.REGSF   AIF   ('&SAVE' NE '').REGSG       .TREAT AS CODE 'T' IF SAVE
         AIF   ('&CODE' NE 'T').REGSI      .SKIP IF NOT CODE 'T'
.REGSG   AIF   (&A GE 14 OR &A LE 2).REGSH .SKIP IF R14 THRU R2
         STM   14,15,12(13)                 SAVE LINKAGE REGS
         AGO   .REGSI
.REGSH   ANOP
&A       SETA  14                          .SET FIRST SAVE REG. NO.
         AIF   (&B NE 14).REGSI            .INSURE THAT R15 IS SAVED
&B       SETA  15                          .SET LAST SAVE REG. NO.
.REGSI   ANOP
&C       SETA  &A*4+20                     .COMPUTE DISPLACEMENT
         AIF   (&C LE 75).REGSJ            .SKIP IF NOT TOO LARGE
&C       SETA  &C-64                       .READJUST
.REGSJ   AIF   (&A EQ &B).REGSK            .SKIP IF SAME REG. NO.
         STM   &A,&B,&C.(13)                SAVE REGISTERS
         AGO   .USING
.REGSK   ST    &A,&C.(,13)                  SAVE A REGISTER
.USING   AIF   ('&USING' EQ '').RENT       .ERROR IF OMITTED
&R       SETC  '&USING(1)'                 .GET REG. EXPRESSION
         AIF   ('&R' EQ '').USINGA         .SKIP IF NULL REG. NO.
         AIF   (T'&USING(1) EQ 'N').USINGB .SKIP IF VALID REG. NO.
         AIF   ('&R'(1,K'&RN) NE '&RN').USINGA       .ERROR IF NOT EQU
&R       SETC  '&R'(K'&RN+1,K'&R-K'&RN)    .GET REG. NO.
         AIF   ('&R' GE '0' AND '&R' LE '15').USINGB .SKIP IF VALID
.USINGA  ANOP
&R       SETC  '15'                        .SET DEFAULT REG.
.USINGB  AIF   (N'&USING EQ 1).USINGC      .SKIP IF NO SECOND OPERAND
&N       SETC  '&USING(2)'                 .GET ADDRESSIBILITY NAME
         AIF   ('&N' EQ '*').USINGH        .SKIP IF USING *,R
         AIF   ('&N' NE '').USINGE         .SKIP IF NON-BLANK LABEL
.USINGC  AIF   ('&NAME' EQ '').USINGD      .SKIP IF NO LABEL ON MACRO
&N       SETC  '&NAME'                     .SET ADDRESSIBILITY NAME
         AGO   .USINGE                     .GO GENERATE USING
.USINGD  AIF   ('&CSECT' EQ '').USINGH     .SKIP IF NO CSECT NAME
&N       SETC  '&CSECT'                    .SET ADDRESSIBILITY NAME
.USINGE  AIF   ('&R' EQ '15').USINGF       .SKIP IF DEFAULT REG.
         LR    &R,15                        LOAD BASE REGISTER
.USINGF  AIF   (&USNGSW).USINGG            .GENERATE SPECIAL USING
         USING &N,&RN.&R                    DEFINE ADDRESSIBILITY
         AGO   .RENT
.USINGG  ANOP
         XXUSE &N,&RN.&R                    DEFINE ADDRESSIBILITY
         AGO   .RENT
.USINGH  ANOP
         BALR  &R,0                         GET BASE ADDRESS
         AIF   (&USNGSW).USINGI            .GENERATE SPECIAL USING
         USING *,&RN.&R                     DEFINE ADDRESSIBILITY
         AGO   .RENT
.USINGI  ANOP
         XXUSE *,&RN.&R                     DEFINE ADDRESSIBILITY
.RENT    AIF   ('&RENT' EQ '').SAVE        .SKIP IF NOT RE-ENTRANT
&R       SETC  '&RENT(1)'                  .GET REG. EXPRESSION
&N       SETC  ''                          .SET NULL DSECT NAME
&X       SETC  '72'                        .SET DEFAULT DSECT SIZE
&A       SETA  0                           .INDICATE NO LENGTH FOUND
         AIF   ('&R' EQ '').RENTB          .SKIP IF NULL REG. NO.
.*REPLCD AIF   (T'&RENT(1) EQ 'N').RENTC   .SKIP IF VALID REG. NO.
         AIF   (T'&R EQ 'N').RENTC         .SKIP IF VALID REG. NO.
         AIF   ('&R'(1,1) NE '(').RENTA    .SKIP IF NOT PARENTHESIS
         AIF   (N'&RENT NE 2).RENTB        .SKIP IF WRONG NO. OF OPRNDS
&R       SETC  '&R'(2,K'&R-2)              .GET REG. NO.
&X       SETC  '&RENT(2)'
&A       SETA  2                           .SET POS. WHERE LEN. FOUND
         AGO   .GETMAIN
.RENTA   AIF   ('&R'(1,K'&RN) NE '&RN').RENTB   .SKIP IF NOT REG. EQU
&R       SETC  '&R'(K'&RN+1,K'&R-K'&RN)    .GET REG. NO.
         AIF   ('&R' GE '0' AND '&R' LE '15').RENTC  .SKIP IF VALID
.RENTB   ANOP
&R       SETC  '13'                        .SET DEFAULT DSECT REG.
.RENTC   AIF   (N'&RENT LT 2).GETMAIN      .SKIP IF NO DESCT NAME
&N       SETC  '&RENT(2)'                  .SAVE DSECT NAME
.RENTD   AIF   (N'&RENT LT 3).GETMAIN      .SKIP IF NO DSECT SIZE
&X       SETC  '&RENT(3)'                  .SET DSECT LENGTH
&A       SETA  3                           .SET POS. WHERE LEN. FOUND
.GETMAIN GETMAIN R,LV=&X,SP=&SP
         AIF   ('&CLEAR' NE 'YES').CONNECT .SKIP IF NO CLEAR
         AIF   ('&X' EQ '72' OR &A EQ 0).XC     .GO USE XC
         AIF   (T'&RENT(&A) NE 'N').MVCL   .GO USE MVCL
         AIF   (&RENT(&A) LE 256).MVCL     .GO USE MVCL
.XC      XC    0(&X,1),0(1)                 ZERO SAVE AREA
         AGO   .CONNECT                    .GO CONNECT SAVE AREAS
.MVCL    ORG   *-2                          RE-ORIGIN OVER SVC
         LR    3,0                          SAVE DSECT LENGTH
         SVC   10                           ISSUE GETMAIN SVC
         LR    2,1                          COPY DSECT AREA ADDR
         SLR   14,14                        ZERO SOURCE ADDR
         LR    15,14                        ZERO COUNT
         MVCL  2,14                         ZERO DSECT AREA
.CONNECT ST    13,4(,1)                     SET OLD SAVE AREA ADDR
         ST    1,8(,13)                     SET NEW SAVE AREA ADDR
         LR    2,13                         COPY OLD SAVE AREA ADDR
         LR    13,1                         RESET SAVE AREA PTR
         LM    14,3,12(2)                   RESTORE DESTROYED REGS.
         AIF   ('&R' EQ '13').RENTE        .SKIP IF DEFAULT REG.
         LR    &R,13                        SET UP DSECT BASE
.RENTE   AIF   ('&N' EQ '').PARM           .SKIP IF NO DSECT NAME
         AIF   (&USNGSW).RENTF             .GENERATE SPECIAL USING
         USING &N,&RN.&R                    DEFINE ADDRESSIBILITY
         AGO   .PARM
.RENTF   ANOP
         XXUSE &N,&RN.&R                    DEFINE ADDRESSIBILITY
         AGO   .PARM
.SAVE    AIF   ('&SAVE' EQ '').PARM        .SKIP IF SAVE AREA OMITTED
&X       SETC  ''                          .SET FLAG FOR SAVE RESTORE
&A       SETA  1                           .SET POS. OF SAVE LABEL
         AIF   (N'&SAVE LT 2).SAVEA        .SKIP IF REG. OMITTED
&R       SETC  '&SAVE(1)'                  .GET REG. EXPRESSION
&A       SETA  2                           .SET POS. OF SAVE LABEL
         AIF   ('&R' EQ '').SAVEA          .SKIP IF NULL REG. NO.
         AIF   (T'&SAVE(1) EQ 'N').SAVEB   .SKIP IF VALID REG. NO.
         AIF   ('&R'(1,K'&RN) NE '&RN').SAVEA   .SKIP IF NOT EQU
&R       SETC  '&R'(K'&RN+1,K'&R-K'&RN)    .GET REG. NO.
         AIF   ('&R' GE '0' AND '&R' LE '15').SAVEB  .SKIP IF VALID
.SAVEA   ANOP
&R       SETC  '14'
         LR    15,13                        SAVE OLD SAVE AREA ADDR
&X       SETC  '15'                        .INDICATE REGS. RESTORE
.SAVEB   ANOP
&N       SETC  '&SAVE(&A)'                 .GET SAVE AREA LABEL
         LA    &R,&N                        GET NEW SAVE AREA ADDR
         ST    13,4(,&R)                    SET OLD SAVE AREA ADDR
         ST    &R,8(,13)                    SET NEW SAVE AREA ADDR
         LR    13,&R                        RESET SAVE AREA PTR
         AIF   ('&X' EQ '').PARM           .SKIP REGS. RESTORE
         LM    &R,&X,12(&X)                 RESTORE DESTROYED REGISTERS
.PARM    AIF   ('&PARM' EQ '').MEND        .SKIP IF PARM OMITTED
&R       SETC  '&PARM(1)'                  .GET REG. EXPRESSION
&N       SETC  ''                          .SET DEFAULT PARM NAME
         AIF   ('&R' EQ '').PARMA          .SKIP IF NULL REG. NO.
         AIF   (T'&PARM(1) EQ 'N').PARMB   .SKIP IF VALID REG. NO.
         AIF   ('&R'(1,K'&RN) NE '&RN').PARMA   .SKIP IF NOT EQU
&R       SETC  '&R'(K'&RN+1,K'&R-K'&RN)    .GET REG. NO.
         AIF   ('&R' GE '0' AND '&R' LE '15').PARMB  .SKIP IF VALID
.PARMA   ANOP
&R       SETC  '1'                         .SET DEFAULT REG.
.PARMB   AIF   (N'&PARM EQ 1).PARMC        .SKIP IF NO SECOND OPERAND
&N       SETC  '&PARM(2)'                  .GET PARM DSECT NAME
.PARMC   AIF   ('&R' EQ '1').PARMD         .SKIP IF DEFAULT REG.
         LR    &R,1                         LOAD PARM REGISTER
.PARMD   AIF   ('&N' EQ '').MEND           .SKIP IF NO PARM DSECT NAME
         AIF   (&USNGSW).PARME             .GENERATE SPECIAL USING
         USING &N,&RN.&R                    DEFINE ADDRESSIBILITY
         AGO   .MEND
.PARME   ANOP
         XXUSE &N,&RN.&R                    DEFINE ADDRESSIBILITY
.MEND    MEXIT
.E1      IHBERMAC 18,360                   .REG PARAMETER MISSING
         MEXIT
.E2      IHBERMAC 37,360,&CODE             .INVALID CODE SPECIFIED
         MEXIT
.E3      IHBERMAC 36,360,&REG              .INVALID REGS. SPECIFIED
         MEXIT
.E4      IHBERMAC 78,360                   .CSECT NAME NULL
         AGO   .REGS
         MEND
