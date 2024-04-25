         MACRO
&LABEL   BITSW   &BIT0,&BIT1,&BIT2,&BIT3,&BIT4,&BIT5,&BIT6,&BIT7,&DSECT
         LCLC  &#
&#       SETC  '#'
         AIF   ('&BIT0' EQ '').A
&BIT0    EQU   *  .          BIT 0.
&BIT0&#  EQU   128  .        1... ....      BIT POSITION
.A       AIF   ('&BIT1' EQ '').B
&BIT1    EQU   *  .          BIT 1.
&BIT1&#  EQU   64  .         .1.. ....      BIT POSITION
.B       AIF   ('&BIT2' EQ '').C
&BIT2    EQU   *  .          BIT 2.
&BIT2&#  EQU   32  .         ..1. ....      BIT POSITION
.C       AIF   ('&BIT3' EQ '').D
&BIT3    EQU   *  .          BIT 3.
&BIT3&#  EQU   16  .         ...1 ....      BIT POSITION
.D       AIF   ('&BIT4' EQ '').E
&BIT4    EQU   *  .          BIT 4.
&BIT4&#  EQU   8  .          .... 1...      BIT POSITION
.E       AIF   ('&BIT5' EQ '').F
&BIT5    EQU   *  .          BIT 5.
&BIT5&#  EQU   4  .          .... .1..      BIT POSITION
.F       AIF   ('&BIT6' EQ '').G
&BIT6    EQU   *  .          BIT 6.
&BIT6&#  EQU   2  .          .... ..1.      BIT POSITION
.G       AIF   ('&BIT7' EQ '').H
&BIT7    EQU   *  .          BIT 7.
&BIT7&#  EQU   1  .          .... ...1      BIT POSITION
.H       ANOP
         AIF   ('&DSECT' EQ '').I
&LABEL   DS    XL1  .        BIT BYTE.
         SPACE
         MEXIT
.I       ANOP
&LABEL   DC    XL1'0' .      BIT BYTE.
         SPACE
         MEND
