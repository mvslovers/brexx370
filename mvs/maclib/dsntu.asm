         MACRO
&L1      DSNTU  &N,&NLP,&MF=L
         LCLA  &NL
         AIF   (T'&NLP EQ 'O').O
         AIF   (T'&NLP EQ 'N').N
&NL      SETA  L'&NLP
         AGO   .NO
.N       ANOP
&NL      SETA  &NLP
         AGO   .NO
.O       ANOP
&NL      SETA  K'&N
.NO      AIF   ('&MF' NE 'L').ET
&L1      DC    X'00020001',H'&NL',CL&NL'&N'
         AGO   .X
.ET      AIF   (N'&MF LE 1).X
         AIF   ('&MF(1)' NE 'E').X
&TUN     SETC  '&MF(2)'
&L1      MVC   &TUN.(4),=X'00020001'
         AIF   (T'&NLP EQ 'O').NH
         AIF   (T'&NLP EQ 'N').NH
         MVC   &TUN+4(2),&NLP
         LH    R1,&NLP
         BCTR  R1,R0
M&SYSNDX MVC   &TUN+6(0),&N
         EX    R1,M&SYSNDX
         AGO   .X
.NH      ANOP
         MVC   &TUN+4(2),=H'&NL'
         MVC   &TUN+6(&NL),=C'&N'
.X       MEND
