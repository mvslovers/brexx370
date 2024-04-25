         MACRO
&NAME    TPT   &A,&B
         LCLC  &X
&X       SETC  'L'''
&NAME    LA    1,&A
         AIF   ('&B' NE '').GENB
         LA    0,&X&A
         AGO   .TPT
.GENB    LA    0,&B
.TPT     TPUT  (1),(0),R
         MEND
