         MACRO
&LAB1    WTP   &TXT,&LEN,&MF=I
         LCLC  &GT,&T,&CL,&P
         LCLA  &TL
&P       SETC  '()'(1,1)
&T       SETC  T'&TXT
.*       MNOTE 'MESSAGE TYPE IS &T'
         AIF   (T'&TXT EQ 'U').MP
         AIF   (T'&TXT EQ 'N').MP
.* NO MESSAGE PRESENT
&GT      SETC  (125)' '
&TL      SETA  125
         AGO   .NQL
.* MESSAGE PRESENT
.MP      ANOP
&GT      SETC  '&TXT'
         AIF   ('&TXT'(1,1) NE '''').NQL
&GT      SETC  '&TXT'(2,K'&TXT-2)
.* CHECK LENGTH:
.NQL     ANOP
&T       SETC  T'&LEN
.*       MNOTE 'LENGTH TYPE IS &T'
         AIF   (T'&LEN NE 'O').NLC
.* NO LENGTH PRESENT
         AIF   (T'&TXT EQ 'O').DL
         AIF   (T'&TXT EQ 'U').UL
&TL      SETA  L'&TXT
         AGO   .LOK
.UL      ANOP
&TL      SETA  K'&GT
         AGO   .NLL
.* NO LENGTH AND NO MESSAGE: DEFAULT LEN = 125
.DL      ANOP
&TL      SETA  125
         AGO   .NLL
.* LENGTH PRESENT
.NLC     AIF   (T'&LEN EQ 'N').SDL
         AIF   (T'&LEN EQ 'U').NLL
.* LENGTH NOT SELF DEFINING
&TL      SETA  L'&LEN
         AGO   .LOK
.* LENGTH SELF DEFINING
.SDL     ANOP
         AIF   ('&LEN'(1,1) EQ '&P').NLL
&TL      SETA  &LEN
.LOK     ANOP
.* FORCE MESSAGE LENGTH:
&GT      SETC  '&GT'.(125)' '
&GT      SETC  '&GT'(1,&TL)
.NLL     ANOP
         AIF   ('&MF(1)' EQ 'L').WTPL
         AIF   ('&MF(1)' EQ 'E').WTPE
&LAB1    WTO   &TXT,ROUTCDE=(11)
         MEXIT
.WTPL    ANOP
&LAB1    WTO   '&GT',ROUTCDE=(11),MF=L
         MEXIT
.WTPE    ANOP
         AIF   (T'&TXT NE 'O').YM
         AIF   (N'&MF EQ 2).MFOK
         MNOTE 8,'WTP MF TYPE INVALID'
         MEXIT
.MFOK    ANOP
&LAB1    WTO   MF=&MF
         MEXIT
.YM      ANOP
&LAB1    DS    0H
         LH    1,&MF(2)
         SH    1,=H'6'
         MVI   &MF(2).+4,C' '
C&SYSNDX MVC   &MF(2).+5(0),&MF(2).+4   CLEAR WTO BUFF
         EX    1,C&SYSNDX
         AIF   (T'&LEN EQ 'U').UL2
         AIF   (T'&LEN EQ 'O').AIL
         AIF   ('&LEN'(1,1) NE '&P').AIL
&P       SETC  '&LEN'(2,K'&LEN-2)
&CL      SETC  '0'
         BCTR  &P,0
         EX    &P,M&SYSNDX
         LA    &P,1(&P)
         AGO   .CT
.AIL     ANOP
&CL      SETC  '&TL'
         AGO   .CT
.UL2     ANOP
&CL      SETC  '&LEN'
.CT      AIF   (T'&TXT EQ 'C').CC
M&SYSNDX MVC   &MF(2).+4(&CL),=C'&GT'
         AGO   .EWTO
.CC      ANOP
M&SYSNDX MVC   &MF(2).+4(&CL),&TXT
.EWTO    ANOP
         WTO   MF=&MF
         MEND
