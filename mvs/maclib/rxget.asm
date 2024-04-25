         MACRO
&LABEL   RXGET &VAR=,&INTO=,&INADDR=,&FEX=
* .... PREPARE GET CALL ..............................................
         XC    IRXBLK,IRXBLK
         LA    R1,IRXBLK
         USING SHVBLOCK,R1
         MVI   SHVCODE,SHVFETCH       WANNA FETCH
* .... SET TO STANDARD INPUT FIELD OF 4K LENGTH ......................
         LA    RF,2048
         LA    RF,2048(RF)
         ST    RF,SHVBUFL         MAX LENGTH OF BUFFER IS 4096
         MVA   SHVVALA,VARDATA    SET ADDRESS OF VARIABLE VALUE
         RXPGNAME &VAR            SET VARIABLE NAME
         RXPGCALL &FEX
* .... POST PROCESSING OF GET ........................................
         LA    R1,IRXBLK          RE-ESTABLISH SHVBLOCK
         USING SHVBLOCK,R1        NEED TO BE OUTSIDE RXPGIF
         MVC   VARLEN,SHVBUFL
         XC    IRXRC,IRXRC        CLEAR RETURN CODE
         MVC   IRXRC+3(1),SHVRET  MOVE RC IN FULLWORD
         AIF   ('&INTO' EQ '').NOINTO
         MVC   &INTO,VARDATA
.NOINTO  ANOP
         AIF   ('&INADDR' EQ '').NOADDR
         MVC   &INADDR,SHVVALA
.NOADDR  ANOP
         MVC   VARLEN,SHVVALL
         DROP  R1
* .... END OF GET PROCESSING .........................................
         MEND
