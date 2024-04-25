         MACRO
&OPLB    OPER  &ON,&F,&EXIT=,&BLANK=,&MINLEN=,&KEYFLD=,&SUBFLD=,       X
               &SUBLIST=,&POSIT=,&ASIS=
         GBLC  &XPARM
         LCLA  &I,&L,&J
&OPLB    DS    0F                       FULLWORD BNDRY
         DC    &F                       FLAG LOC (SET IF OPER FOUND):
*                                       BYTE1=FLAG BIT,BYTE2=FLAG BYTE
         AIF   ('&EXIT&SUBFLD' EQ '').S1
&I       SETA  &I+8
.S1      AIF   ('&BLANK' EQ '').S2
&I       SETA  &I+4
.S2      AIF   ('&KEYFLD' EQ '').S2B
&I       SETA  &I+2
.S2B     AIF   ('&SUBFLD' EQ '').S2C
&I       SETA  &I+1
         AIF   ('&SUBLIST' EQ '').S2C
         MNOTE 'SUBFLD AND SUBLIST ARE MUTUALLY EXCLUSIVE'
.S2C     AIF   ('&POSIT' EQ '').S2D
&J       SETA  &J+8
.S2D     AIF   ('&SUBLIST' EQ '').S2E
&J       SETA  &J+4
.S2E     AIF   ('&ASIS' EQ '').SS
&J       SETA  &J+2
.SS      DC    AL1(&I*16+&J)   BYTE1= OPTIONS (80 = TAKE EXIT)
*              (40 = OVERLAY WITH BLANKS,20 = KEYWORD OPERAND)
*              (10 = SUBFIELD AREA OFFSET PROVIDED FOR SUBEX )
*              (08 = POSITIONAL OPER,04 = SUBLIST,02 = ASIS  )
         DC    AL1(0&MINLEN)     BYTE2= MINIMUM LENGTH OF OPER TO MATCH
         AIF   ('&EXIT' EQ '').S3A
         DC    A(&EXIT)                 EXIT ADDR
         AGO   .S4
.S3A     AIF   ('&SUBFLD' EQ '').S3
         DC    A(X&SYSNDX)              EXTERNAL EXIT TRANSFER
         AGO   .S4
.S3      AIF   ('&KEYFLD' EQ '').SL    NO EXIT
         DC    A(&KEYFLD)         ADDRESS OF KEYFLD ->
*        HFWD  FIELD LEN, HFWD DATA LEN, DATA FIELD
         AGO   .S4
.SL      AIF   ('&SUBLIST' EQ '').SN    NO EXIT
         DC    A(&SUBLIST)        ADDRESS OF SUBLIST ->
*        ANOTHER OPERLIST DESCRIBING SUBLIST ONLY OPERANDS
         AGO   .S4
.SN      DC    A(0)                     NO EXIT
.S4      ANOP
&L       SETA  K'&ON                    NAME LENGTH
         DC    H'&L'                    OPERAND LENGTH (SUBFLD EXCL)
         DC    C'&ON '                  OPERAND NAME
         SPACE
         AIF   ('&SUBFLD' EQ '').SX
X&SYSNDX DC    V(SUBEX)
         DC    A(&SUBFLD-&XPARM)
         SPACE
.SX      MEND
