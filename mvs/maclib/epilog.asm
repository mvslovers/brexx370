         MACRO
&NAME    EPILOG &REG,&RC=,&RENT=,&SP=0,&SREG=13,&GPR=R,&LIST=
.*
.*       GLOBAL VARIABLES DESCRIPTION
.*
.*       &REGSNM   CHARACTER STRING THAT CONTAINS THE EQUATE NAME
.*                    PREFIX FOR THE GENERAL REGISTERS (SEE &RN
.*                    VALUE DESCRIPTION BELOW)
.*
         GBLC  &REGSNM
         LCLA  &A
         LCLC  &R,&RN,&T,&X
*  EPILOG  MACRO -- ASSEMBLY EPILOG  01/14/78 MARK GOTO
         AIF   ('&LIST' EQ 'YES').COMNT
*           (CODE LIST=YES FOR FURTHER DESCRIPTION)
*
         AGO   .NOCOMNT
.COMNT   ANOP
*    &REG      REGISTER SPECIFICATION INDICATING WHICH REGISTERS
*              ARE TO BE RESTORED
*
*        *NOTE* = THE REGS. NOS. MUST A DECIMAL CONSTANT OR AN
*                 EQUATE OF THE FORM  R"X"  WHERE "X" IS A
*                 DECIMAL REGISTER NUMBER
*
*
*    ,&RC=     RETURN CODE VALUE
*                OR
*    ,&RC=     RETURN CODE LOCATION
*                OR
*    ,&RC=     (REGISTER CONTAINING RETURN CODE)
*
*        OPERATION = LOAD RETURN CODE INTO REGISTER 15 AND PASS IT
*                    TO CALLER UPON EXIT
*
*           LA 15,"RETURN CODE VALUE"
*                OR
*           L  15,"RETURN CODE LOC."
*                OR
*           LR 15,"REGISTER"
*
*        *NOTE* = THE REGISTER MUST A DECIMAL CONSTANT OR AN
*                 EQUATE OF THE FORM  R"X"  WHERE "X" IS A
*                 DECIMAL REGISTER NUMBER
*
*
*    ,&RENT=   (DSECT ADDR LOC.  ,  DSECT SIZE)
*                OR
*    ,&RENT=   (DSECT ADDR REG.  ,  DSECT SIZE)
*
*        OPERATION = ISSUE FREEMAIN MACRO AS FOLLOWS:
*
*           L  1,"DSECT ADDR LOC."
*           FREEMAIN R,LV="DSECT SIZE",A=(1)
*                OR
*           LR 1,"DSECT ADDR REG."
*           FREEMAIN R,LV="DSECT SIZE",A=(1)
*
*        *NOTE* = THE DSECT REG. MUST A DECIMAL CONSTANT OR AN
*                 EQUATE OF THE FORM  R"X"  WHERE "X" IS A
*                 DECIMAL REGISTER NUMBER
*
*
*    ,&SP=     SUB-POOL NUMBER FOR RE-ENTRANT FREEMAIN
*
*        OPERATION = SPECIFY THE FREEMAIN SUB-POOL OPERAND:
*
*          FREEMAIN R,LV=...,SP=...
*
*        *NOTE* = THIS PARAMETER DEFAULTS TO "SP=0" (IE. SUB-POOL
*                 NUMBER ZERO)
*
*
*    ,&SREG=   SAVE REGISTER
*
*        OPERATION = GENERATE INSTRUCTIONS TO GET OLD SAVE ADDR:
*
*           L  13,4(&SREG)
*
*        *NOTE* = THE DSECT REG. MUST A DECIMAL CONSTANT OR AN
*                 EQUATE OF THE FORM  R"X"  WHERE "X" IS A
*                 DECIMAL REGISTER NUMBER
*
*
*    ,&GPR=    PREFIX FOR EQU NAMES OF THE GENERAL REGISTERS
*
*        OPERATION = SPECIFY PREFIX WHEN NO GLOBAL PREFIX EXISTS
*
*
.NOCOMNT ANOP
&RN      SETC  '&REGSNM'
         AIF   ('&RN' NE '').RTYPE
&RN      SETC  '&GPR'
         AIF   ('&RN' NE '').RTYPE
&RN      SETC  'R'
.RTYPE   ANOP
&T       SETC  'O'
         AIF   ('&RC' EQ '').LABEL
&T       SETC  'Z'
         AIF   ('&RC' EQ '0').LABEL
&T       SETC  'R'
         AIF   ('&RC'(1,1) EQ '(').RCREG
&T       SETC  'N'
         AIF   (T'&RC EQ 'N').LABEL
&T       SETC  'A'
         AGO   .LABEL
.RCREG   ANOP
&R       SETC  '&RC'(2,K'&RC-2)
         AIF   ('&R'(1,K'&RN) NE '&RN').LABEL
&R       SETC  '&R'(K'&RN+1,K'&R-K'&RN)
         AIF   ('&R' GE '0' AND '&R' LE '15').LABEL
         AGO   .E3
.LABEL   AIF   ('&NAME' EQ '').NOLABEL
&NAME    DS    0H                           DEFINE LABEL FOR RETURN
.NOLABEL AIF   ('&REG' EQ '').E1
         AIF   ('&T' NE 'A').RENT
         L     15,&RC                       LOAD RETURN CODE
&T       SETC  'R'
&R       SETC  '15'
.RENT    AIF   (N'&RENT NE 2).REGS
&X       SETC  '&RENT(1)'
         AIF   ('&X'(1,1) NE '(').RENTA
&X       SETC  '&X'(2,K'&X-2)
         AGO   .RENTB
.RENTA   AIF   ('&X'(1,K'&RN) NE '&RN').RENTB
&X       SETC  '&X'(K'&RN+1,K'&X-K'&RN)
         AIF   ('&X' GE '0' AND '&X' LE '15').RENTC
.RENTB   ANOP
&X       SETC  '13'
.RENTC   AIF   ('&X' EQ '1').RENTD
         LR    1,&X                         RESTORE DSECT ADDR
.RENTD   AIF   (T'&SREG EQ 'O').RENTE
         L     13,4(,&SREG)                 RESTORE OLD SAVE AREA ADDR
.RENTE   AIF   ('&T' NE 'R').RENTF
         ST    &R,16(,13)                   SAVE RETURN CODE
.RENTF   ANOP
         FREEMAIN R,LV=&RENT(2),A=(1),SP=&SP
         AGO   .REGSB
.REGS    AIF   (T'&SREG EQ 'O').REGSA
         L     13,4(,&SREG)                 RESTORE OLD SAVE AREA ADDR
.REGSA   AIF   ('&T' NE 'R').REGSB
         ST    &R,16(,13)                   SAVE RETURN CODE
.REGSB   ANOP
&X       SETC  '&REG(1)'
         AIF   (T'&REG(1) EQ 'N').REGSD
         AIF   ('&X'(1,K'&RN) NE '&RN').REGSC
&X       SETC  '&X'(K'&RN+1,K'&X-K'&RN)
         AIF   ('&X' GE '0' AND '&X' LE '15').REGSD
.REGSC   ANOP
&X       SETC  '14'
.REGSD   ANOP
&A       SETA  &X*4+20
         AIF   (&A LE 75).REGSE
&A       SETA  &A-64
.REGSE   AIF   (N'&REG NE 2).REGSF
         LM    &RN.&X,&REG(2),&A.(&RN.13)   RESTORE REGISTERS
         AGO   .RETC
.REGSF   AIF   (N'&REG NE 1).E2
         L     &RN.&X,&A.(,&RN.13)          RESTORE REGISTER
.RETC    AIF   ('&T' NE 'R' OR '&R' EQ '15').RETCA
         L     15,16(,13)                   PICK UP SAVED RETURN CODE
         AGO   .MEND
.RETCA   AIF   ('&T' NE 'N').RETCB
         LA    15,&RC                       SET RETURN CODE
         AGO   .MEND
.RETCB   AIF   ('&T' NE 'Z').MEND
         SLR   15,15                        SET RETURN CODE
.MEND    BR    14                           RETURN
         MEXIT
.E1      IHBERMAC 18,360                   .REG PARAMETER MISSING
         MEXIT
.E2      IHBERMAC 36,360,&REG              .INVALID REGS. SPECIFIED
         MEXIT
.E3      IHBERMAC 61,360,&RC               .INVALID RC SPECIFIED
         MEND
