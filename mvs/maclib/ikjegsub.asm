         MACRO
         IKJEGSUB &CSECT=IBM
         LCLA  &A,&B,&C,&D,&E,&F,&G
         LCLC  &CSNAM,&SUBCMD,&ABBR,&LDNAM,&LABEL,&LABEL1,&LABEL2,&NMBR
         LCLC  &LABEL0,&INDEX
&F       SETA  1              INDICATE FIRST SUBCOMMAND ID.
         AIF   ('&CSECT' NE 'IBM').CONT0
&CSNAM   SETC  'IKJEGSCD'     DEFINE CSECT NAME FOR IBM TABLE.
IKJEGSCD CSECT
         ENTRY IKJEGAID
         ENTRY IKJEGEID
         ENTRY IKJEGPID
         AGO   .CONT1         BRANCH TO GENERATE COMMENTS.
.CONT0   ANOP
         AIF   ('&CSECT' NE 'USER').ERROR2
&CSNAM   SETC  'IKJEGSCU'     DEFINE CSECT NAME FOR USER TABLE.
IKJEGSCU CSECT
&F       SETA  &F+128         INDICATE USER SUBCOMMAND ID.
.CONT1   ANOP
         SPACE 2
***********************************************************************
*                                                                     *
*        THE IKJEGSUB MACRO IS USED TO GENERATE THE TABLE OF IBM      *
*        SUPPLIED SUBCOMMAND PROCESSORS AND/OR THE TABLE OF USER      *
*        WRITTEN SUBCOMMAND PROCESSORS.  BOTH TABLES, EVEN THOUGH     *
*        THE USER TABLE MAY BE EMPTY, MUST BE LINKAGE EDITED WITH     *
*        IKJEGMNL.                                                    *
*                                                                     *
*        THE FORMAT OF A TABLE ENTRY IS AS FOLLOWS--                  *
*                                                                     *
*        .......................................................      *
*        .        .        .        .        .        .        .      *
*        .  NAME  . SUBCMD .  ABBR  .  ABBR  . LDMOD  . SUBCMD .      *
*        . LENGTH .  NAME  . LENGTH .  NAME  .  NAME  .   ID   .      *
*        .        .        .        .        .        .        .      *
*        .......................................................      *
*        +0       +1       +(M+1)   +(M+2)   +(M+N+2) +(M+N+10)       *
*                                                                     *
         AIF   ('&CSNAM' EQ 'IKJEGSCU').CONT2
*        STATUS -- VERSION NO. 01 - OS/VS2 RELEASE NO. 01             *
*                                                                     *
*        CHANGE LEVEL -- 04 - DATE 04/25/72                           *
*                                                                     *
.CONT2   ANOP
***********************************************************************
&A       SETA  N'&SYSLIST     DETERMINE NUMBER OF SUBCOMMANDS.
         AIF   (&A EQ 0).CONT6 IF NO SUBCOMMANDS, BRANCH TO
.*                            GENERATE END OF TABLE INDICATOR.
&B       SETA  1              SUBLIST INDEX.
.CONT3   ANOP
&C       SETA  N'&SYSLIST(&B)
         AIF   (&C NE 3).ERROR1 VERIFY THAT SUBCMD
.*                            NAME AND LOAD NAME SPECIFIED.
         AIF   ('&CSNAM' EQ 'IKJEGSCD').CONT33
&INDEX   SETC  '&F'
&LABEL0  SETC  '&CSNAM'(6,3).'&INDEX'.'00'
&LABEL1  SETC  '&CSNAM'(6,3).'&INDEX'.'01'
&LABEL2  SETC  '&CSNAM'(6,3).'&INDEX'.'02'
         AGO   .CONT37
.CONT33  ANOP
&E       SETA  K'&SYSLIST(&B,&C)
&D       SETA  &E-2
&G       SETA  3
         AIF   (&E EQ 8).CONT35
&G       SETA  2
&D       SETA  &E-1
.CONT35  ANOP
&LABEL0  SETC  '&CSNAM'(6,3).'&SYSLIST(&B,&C)'(&D,&G).'00'
&LABEL1  SETC  '&CSNAM'(6,3).'&SYSLIST(&B,&C)'(&D,&G).'01'
&LABEL2  SETC  '&CSNAM'(6,3).'&SYSLIST(&B,&C)'(&D,&G).'02'
.CONT37  ANOP
&SUBCMD  SETC  '&SYSLIST(&B,1)'
         SPACE 2
&LABEL0  EQU   *
         DC    AL1(&LABEL1-*-1) - LENGTH OF SUBCOMMAND NAME.
         DC    C'&SUBCMD' -   SUBCOMMAND NAME.
&LABEL1  EQU   *
         DC    AL1(&LABEL2-*-1) - LENGTH OF ABBREVIATION.
         AIF   (K'&SYSLIST(&B,2) EQ 0).CONT4
&ABBR    SETC  '&SYSLIST(&B,2)'
         DC    C'&ABBR' -     ABBREVIATION FOR SUBCOMMAND NAME.
.CONT4   ANOP
&LABEL2  EQU   *
&LDNAM   SETC  '&SYSLIST(&B,3)'
         DC    CL8'&LDNAM' -  LOAD MODULE NAME.
         DC    AL1(&F) -      MODULE IDENTIFICATION BYTE.
         AIF   (&B EQ &A).CONT6
&B       SETA  &B+1
&F       SETA  &F+1           INCREMENT IDENTIFICATION NUMBER.
         AGO   .CONT3
.CONT6   ANOP
         SPACE 2
         DC    AL1(255) -     END OF TABLE INDICATOR.
         AIF   ('&CSNAM' EQ 'IKJEGSCU').CONT7
         SPACE 5
SCDNXTNM EQU   10 -           LENGTH OF ABBREVIATION LENGTH FIELD,
*                             LOAD MODULE NAME LENGTH AND ID
*                             LENGTH.
SCDNXTAB EQU   1 -            LENGTH OF NAME LENGTH FIELD.
SCDTBEND EQU   255 -          END OF TABLE INDICATOR.
SCDABBRL EQU   1 -            LENGTH OF ABBREVIATION LENGTH FIELD
SCDABBR  EQU   0 -            OFFSET TO ABBREVIATION LENGTH FIELD
*                             FROM POINTER TO ABBREVIATION
*                             SUBFIELD.
SCDNAME  EQU   0 -            OFFSET TO SUBCOMMAND NAME LENGTH
*                             FIELD FROM POINTER TO SUBCOMMAND
*                             ENTRY.
SCDSCPPN EQU   1 -            OFFSET FROM BEGINNING OF ENTRY TO
*                             COMMON NAME OF SUBCOMMAND PROCESSOR.
IKJEGAID EQU   SCDAT00 -      ENTRY NAME FOR AT SUBCOMMAND.
IKJEGEID EQU   SCDEND00 -     ENTRY NAME FOR END SUBCOMMAND.
IKJEGPID EQU   SCDPCH00 -     ENTRY NAME FOR ASSIGN SUBCOMMAND.
SCDATLD  EQU   SCDAT02-SCDAT00 OFFSET TO LOAD MODULE NAME FOR
*                             AT SUBCOMMAND.
SCDENDLD EQU   SCDEND02-SCDEND00 OFFSET TO LOAD MODULE NAME FOR
*                             END SUBCOMMAND.
SCDPCHLD EQU   SCDPCH02-SCDPCH00 OFFSET TO LOAD MODULE NAME FOR
*                             ASSIGN SUBCOMMAND.
.CONT7   ANOP
         MEXIT
.ERROR1  MNOTE 12,'INVALID TABLE ENTRY'
         MEXIT
.ERROR2  MNOTE 12,'INVALID KEYWORD VALUE'
         MEXIT
         MEND
