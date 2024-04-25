         MACRO
&OPLB    OPER  &ON,&F,&EXIT=,&BLANK=,&MINLEN=,&KEYFLD=,&SUBFLD=
         GBLC  &XPARM
         LCLA  &I
         LCLA  &L
&OPLB    DS    0F                       FULLWORD BNDRY
         DC    &F                       FLAG LOC (SET IF OPER FOUND):
*                                       BYTE1=FLAG BIT,BYTE2=FLAG BYTE
         AIF   ('&EXIT&SUBFLD' EQ '').S1
&I       SETA  &I+8
.S1      AIF   ('&BLANK' EQ '').S2
&I       SETA  &I+4
.S2      AIF   ('&KEYFLD' EQ '').S2B
&I       SETA  &I+2
.S2B     AIF   ('&SUBFLD' EQ '').SS
&I       SETA  &I+1
.SS      DC    AL1(&I*16)        BYTE1= OPTIONS (80 = TAKE EXIT)
*              (40 = OVERLAY WITH BLANKS,20 = KEYWORD OPERAND)
*              (10 = SUBFIELD AREA OFFSET PROVIDED FOR SUBEX )
         DC    AL1(0&MINLEN)     BYTE2= MINIMUM LENGTH OF OPER TO MATCH
         AIF   ('&EXIT' EQ '').S3A
         DC    A(&EXIT)                 EXIT ADDR
         AGO   .S4
.S3A     AIF   ('&SUBFLD' EQ '').S3
         DC    A(X&SYSNDX)              EXTERNAL EXIT TRANSFER
         AGO   .S4
.S3      AIF   ('&KEYFLD' EQ '').SN    NO EXIT
         DC    A(&KEYFLD)         ADDRESS OF KEYFLD ->
*        HFWD  FIELD LEN, HFWD DATA LEN, DATA FIELD
         AGO   .S4
.SN      DC    A(0)                     NO EXIT
.S4      ANOP
&L       SETA  K'&ON                    NAME LENGTH
         DC    H'&L'                    OPERAND LENGTH (SUBFLD EXCL)
         DC    C'&ON'                   OPERAND NAME
         SPACE
         AIF   ('&SUBFLD' EQ '').SX
X&SYSNDX DC    V(SUBEX)
         DC    A(&SUBFLD-&XPARM)
         SPACE
.SX      MEND
