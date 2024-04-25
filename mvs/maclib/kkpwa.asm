         MACRO
&LAB     KKPWA  &ANS=ANS,&ECB=ECB,&PPLA=PPLA
         MNOTE 'ANS=&ANS,ECB=&ECB,PPLA=&PPLA'
*                            ANS  IS A FULLWORD WHERE PARSE RETURNS
*                                 THE POINTER TO HIS ANSWER (IKJPARMD).
*                            ECB  IS A FULLWORD.
*
*                            PPLA IS A 7 FULLWORD AREA USED FOR
*                                 THE PARSE PARAMETER LIST.
*
&ANS     DS    F
&ECB     DS    F
&PPLA    DS    7F
*
         MEND
