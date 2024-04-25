         MACRO
&LABEL   $PROLOG &LV=0,&GM=Y
.**********************************************************************
.*
.*       THIS MACRO WILL PROVIDE ENTRY LINKAGE AND OPTIONALLY
.*       MULTIPLE BASE REGISTERS.  ALSO, VIA THE 'LV=' KEYWORD
.*       PROVIDE ADDITIONAL USER STORAGE (APPENDED TO THE
.*       SAVE AREA) ADDRESSABLE FROM REG 13.  IF NO OPERANDS
.*       ARE CODED, REG 12 IS ASSUMED THE BASE. EXAMPLE:
.*              SECTNAME $PROLOG          = STANDARD REG 12 BASE
.*              SECTNAME $PROLOG 5        = STANDARD, REG 5 BASE
.*              SECTNAME $PROLOG 10,LV=20 = ADD 20 BYTES TO SAVE AREA
.*                                             REG 10 IS BASE
.*              SECTNAME $PROLOG R10,R11  = REGS 10 AND 11 ARE BASES
.*
.**********************************************************************
         LCLA  &AA,&AB,&AC
         GBLB  &PRORG
         GBLC  &PROGM
&AC      SETA  4096
&LABEL   CSECT
         B     32(R15)             BRANCH AROUND
         DC    AL1(26)
         DC    CL8'&LABEL'         CSECT NAME
         DC    C'-'
         DC    CL8'&SYSDATE'       COMPILE DATE
         DC    C'-'
         DC    CL8'&SYSTIME'       COMPILE TIME
         CNOP  0,4                 ALIGNMENT
         STM   R14,R12,12(R13)     SAVE REGISTERS
         LR    R12,R15             LOAD BASE REG
         USING &LABEL,R12          INFORM ASSEMBLER
         AIF   (&LV GT 4023).MERR
         AIF   ('&GM' EQ 'N').NOGM
&PROGM   SETC  'GETMAIN'
         LA    R0,&LV+72           LOAD REG 0 WITH LENGTH VARIABLE
         GETMAIN R,LV=(0)          GET CORE FOR SAVEAREA AND USER
         AIF   (&LV+72 LE 256).XC2
         AIF   (&LV+72 LE 512).XC1
         MVI   0(R1),X'00'         MOVE X'00' TO FIRST BYTE
         LR    R2,R1               SAVE POINTER IN EVEN REG
         LA    R4,1(R1)            SET RECEIVING POINTER
         LR    R5,R0               SET RECEIVING LENGTH
         BCTR  R5,R0               DECREMENT LENGTH
         LA    R5,0(R5)            CLEAR HIGH ORDER BYTE
         LA    R3,1                SET SENDING LENGTH
         MVCL  R4,R2               INSTRUCTION PADS WITH X'00'
         AGO   .STORE
.XC1     ANOP
         XC    256(&LV-184,R1),256(R1)  CLEAR SAVE AREA
         XC    0(256,R1),0(R1)          CLEAR SAVE AREA
         AGO   .STORE
.XC2     ANOP
         XC    0(&LV+72,R1),0(R1)       CLEAR SAVE AREA
         AGO   .STORE
.NOGM    ANOP
         CNOP  0,4
         LA    R1,SAVE&SYSNDX
         B     *+76
SAVE&SYSNDX DC 18F'0'
.STORE   ANOP
         ST    R13,4(R1)           SAVE BACK CHAIN
         ST    R1,8(R13)           SET FORWARD CHAIN
         LR    R11,R1              SAVE NEW SAVEAREA ADDRESS
         L     R15,16(R13)         RESTORE REG 15
         ST    R0,16(R13)          SAVE SAVEAREA LENGTH
         LM    R0,R1,20(R13)       RESTORE REGS USED IN GETMAIN
         LR    R13,R11             SET SAVEAREA POINTER
         AIF   (N'&SYSLIST EQ 0).MEND
         AIF   ('&SYSLIST(1)' EQ 'R12').SKIPIT
         AIF   ('&SYSLIST(1)' EQ '12').SKIPIT
         LA    &SYSLIST(1),&LABEL  LOAD REQUESTED BASE REG
         DROP  R12                 DROP ASSUMED BASE REG
         USING &LABEL,&SYSLIST(1)  INFORM ASSEMBLER
.SKIPIT  ANOP
&AA      SETA  2
.LOOP    ANOP
         AIF   (&AA GT N'&SYSLIST).MEXIT
&AB      SETA  &AA-1
         LA    &SYSLIST(&AA),2048(&SYSLIST(&AB))  LOAD NEXT BASE REG
         LA    &SYSLIST(&AA),2048(&SYSLIST(&AA))  LOAD NEXT BASE REG
         USING &LABEL+&AC,&SYSLIST(&AA) INFORM ASSEMBLER
&AC      SETA  &AC+4096
&AA      SETA  &AA+1
         AGO   .LOOP
.MEXIT   ANOP
         AIF   (&PRORG).MEX2
         SPACE
         $REGS
         SPACE
.MEX2    ANOP
&AA      SETA  &LV+72
         MNOTE *,'TOTAL STORAGE AREA RECEIVED = &AA'
         MEXIT
.MEND    ANOP
         MNOTE *,'NO REGISTER SPECIFIED - R12 ASSUMED'
         AGO   .MEXIT
.MERR    ANOP
         MNOTE 12,'LV > 4023 - REQUEST IGNORED'
         AGO   .MEXIT
         MEND
