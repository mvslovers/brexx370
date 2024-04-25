         MACRO
&LABEL   EQUREGS &L=R,&DO=(0,15,1),&SYM=
.*--> MACRO: EQUREGS    GENERATE SYMBOLIC REGISTER EQUATES  . . . . . .
.*                                 JOHN R. MASHEY/JULY'69/PSU 360/67  *
.*       MACRO FOR SETTING UP SETS OF REGISTER EQUATES.               *
.*       *** ARGUMENTS ***                                            *
.*       L=        SYMBOL USED TO BEGIN EQUATES, SUCH AS R, REG,ETC.  *
.*       DO=       (INITIAL,LIMIT,INCREMENT) WILL SET UP REGISTERS    *
.*             EQUATED TO THE VALUE AS CONTROLLED BY THE DO PARAMATER.*
.*             BEHAVES LIKE FORTRAN DO, INCLUDING ABILITY TO LEAVE OUT*
.*             INCREMENT.                                             *
.*       SYM=      LIST OF SYMBOLS TO BE CONCATENATED TO L PARM.      *
.*             LIST WILL SET UP EQUATES INCLUDING SYM VALUES, FOR     *
.*             FIRST SET OF EQUATES IN LIST, AND WILL THEN SET UP     *
.*             NUMERIC EQUATES IF DO VALUES EXCEED NUMBER OF ELEMENTS *
.*             IN SYM OPERAND.  MAY BE OMITTED ENTIRELY.              *
.*  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
         LCLA  &I,&J,&K            COUNTER,INCREMENT,SYM COUNTER
         AIF   (N'&DO LT 2).XERROR           NOT ENOUGH ARGUMENTS-ERR
&K       SETA  1                   INIT
&I       SETA  &DO(1)              SET TO INITIAL VALUE
&J       SETA  1                   SET TO DEFAULT VALUE
         AIF   (N'&DO LT 3).XLOOP            DEFAULT VALUE IS OK
&J       SETA  &DO(3)              USE VALUE PROVIDED
.XLOOP   AIF   ('&SYM(&K)' EQ '').XLOOP1     USE NUMBER IF NO SYM VAL
&L&SYM(&K) EQU &I
&K       SETA  &K+1      INCREMENT TO GET NEXT SYM OPERAND
         AGO   .XLOOP2             SKIP OVER NORMAL GENRATION
.XLOOP1  ANOP
&L&I     EQU   &I
.XLOOP2  ANOP
&I       SETA  &I+&J               ADD INCREMENT TO COUNTER
         AIF   (&I LE &DO(2)).XLOOP          CONTINUE UNTIL DONE
         MEXIT
.XERROR  MNOTE 0,'** ERROR - EQUREGS REQUIRES AT LEAST 2 VALUES IN DO'
         MEND
