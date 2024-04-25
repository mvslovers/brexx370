         MACRO
&L1      DSPTU  &N,&MF=L
         LCLC  &TUN,&HS
         AIF   ('&N' NE 'OLD').T2
&HS      SETC  '01'
.T2      AIF   ('&N' NE 'MOD').T4
&HS      SETC  '02'
.T4      AIF   ('&N' NE 'NEW').T8
&HS      SETC  '04'
.T8      AIF   ('&N' NE 'SHR').TO
&HS      SETC  '08'
.TO      AIF   ('&MF' NE 'L').ET
&L1      DC    X'00040001',X'0001',X'&HS'
         AGO   .X
.ET      AIF   (N'&MF LE 1).X
         AIF   ('&MF(1)' NE 'E').X
&TUN     SETC  '&MF(2)'
&L1      MVC   &TUN.(6),=X'000400010001'
         MVI   &TUN+6,X'&HS'
.X       MEND
