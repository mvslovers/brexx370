         MACRO
&LOCLBL  UNDERTSO &YES=,&NO=
.*                                                                   *.
.* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *.
.*                                                                   *.
.*  ISYES          IDENTIFY WHETHER OR NOT TSO     IS BEING USED     *.
.*                                                                   *.
.*                 TAKES A BRANCH DEPENDING ON WHICH PARMS ARE       *.
.*                 SPECIFIED                                         *.
.* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *.
         AIF   ('&YES' EQ '' AND '&NO' EQ '').ERR
&LOCLBL  DS    0H                      REG &R --> REAL CVT
         L     R14,X'224'              GET ASCB ADDRESS
         L     R14,60(R14)             GET ASCBTSB FIELD
         LTR   R14,R14                 IF ZERO, NOT UNDER TSO
         AIF   ('&YES' EQ '').GEN370
         BNZ   &YES
.GEN370  ANOP
         AIF   ('&NO' EQ '').EXIT
         BZ    &NO
         AGO   .EXIT
.EXIT    ANOP
         MEXIT
.ERR     MNOTE 8,'*** UNDERTSO ERROR, MUST SPECIFY YES OR NO '
         MEND
