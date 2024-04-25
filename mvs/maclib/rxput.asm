         MACRO
&LABEL   RXPUT &VAR=,&VALUE=,&VALLEN=,&VALADDR=,&VALFLD=,&VALREG=,     X
               &INDEX=,&FEX=
         LCLA  &VALLNN
         AIF   ('&VALLEN' NE '').LENSET
         AIF   ('&VALUE' EQ '').LENSET
&VALLNN  SETA  K'&VALUE-2
.LENSET  ANOP
* .... PREPARE PUT CALL ..............................................
         XC    IRXBLK,IRXBLK
         LA    R1,IRXBLK
         USING SHVBLOCK,R1
         MVI   SHVCODE,SHVSTORE       WANNA STORE
         MVI   SHVRET,SHVCLEAN        CLEAR RETURN CODE
         RXPGNAME &VAR,&INDEX         SET VARIABLE NAME
* .... SET VARIABLE CONTENTS POINTERS ................................
         AIF   ('&VALLEN' NE '' ).LENSET0
         AIF   ('&VALLNN' EQ '' ).ALLSET
.LENSET0 ANOP
         AIF   ('&VALREG' EQ '').NOREG
         ST    &VALREG,VARREG
         LA    R0,VARREG              SET NEW ADDRESS OF VARIABLE VALUE
         AGO   .SETADR
.NOREG   AIF   ('&VALADDR' EQ '').NOVAL0
         L     R0,&VALADDR            SET NEW ADDRESS OF VARIABLE VALUE
         AGO   .SETADR
.NOVAL0  AIF   ('&VALUE' EQ '').TSTFLD
         MVC   VARDATA,=C&VALUE
         LA    R0,VARDATA             SET NEW ADDRESS OF VARIABLE VALUE
         AGO   .SETADR
.TSTFLD  AIF   ('&VALFLD' EQ '').ALLSET
         LA    R0,&VALFLD             USE NORMAL FIELD
.SETADR  ANOP
         ST    R0,SHVVALA             STORE IT
.SETLEN  ANOP
         AIF   ('&VALLEN' NE '').SETLEN1
         MVA   SHVVALL,&VALLNN        SET NEW LENGTH OF VARIABLE VALUE
         AGO   .ALLSET
.SETLEN1 ANOP
         MVA   SHVVALL,&VALLEN        SET NEW LENGTH OF VARIABLE VALUE
.ALLSET  ANOP
         DROP  R1
&LABEL   RXPGCALL &FEX
* .... POST PROCESSING OF PUT ........................................
         LA    R1,IRXBLK          RE-ESTABLISH SHVBLOCK
         XC    IRXRC,IRXRC        CLEAR RETURN CODE
         MVC   IRXRC+3(1),SHVRET-SHVBLOCK(R1) MOVE RC IN FULLWORD
* .... END OF PUT PROCESSING .........................................
         MEND
