         MACRO
&LAB     KKSWA  &CSPL=ACSPL,&CSFW=CSFW,&CSOA=ACSOA,&DSECT
         MNOTE 'CSPL=&CSPL,CSFW=&CSFW,CSOA=&CSOA'
*
*                            CSPL IS A 6 FULLWORD AREA USED FOR
*                                 THE SCAN PARAMETER LIST.
*                            CSFW IS A FULLWORD FLAG PASSED TO SCAN
*                            CSOA IS 2 FULLWORDS WHERE SCAN RETURNS
*                                 THE RESULTS OF HIS SCANNING
*
         AIF   ('&DSECT' EQ 'DSECT').DL
         AGO   .L1
.DL      ANOP
&LAB     DSECT
.L1      ANOP
&CSPL    DS    6F
&CSFW    DS    F
&CSOA    DS    2F
*
         MEND
