         MACRO
         GETPCPPL &GETR1
         AIF   ('&GETR1' NE 'RESTORE').NOREST
* .... RESTORE R1 OF CALLING PROGRAM FROM SAVE AREA .................
         L     R1,4(RD)
         L     R1,24(R1)
.NOREST  ANOP
* .... ANALYZE CPPL .................................................
         L     R1,0(R1)        GET CPPL COMMAND BUFFER
         LH    RF,0(R1)        GET BUFFER LENGTH (INCCLUDING HEADER)
         LH    RE,2(R1)        GET OFFSET OF PARM STRING
         LA    R1,4(RE,R1)     GET ADRESS OF PARM STRING
         SR    RF,RE           SUBTRACT COMMAND NAME LENGTH
         SH    RF,=H'4'        SUBTRACT HEADER LENGTH
         LTR   RF,RF           NO PARMS - NO FUN
         BZ    Z&SYSNDX        NO PARMS
         CLI   0(R1),X'7D'     ENCLOSED IN QUOTES?
         BE    S&SYSNDX        YES, STRIP THEM OFF
         CLI   0(R1),C'"'      ENCLOSED IN DOUBLE QUOTES?
         BE    S&SYSNDX        YES, STRIP THEM OFF
         B     Z&SYSNDX        LEAVE MACRO
S&SYSNDX BCTR  RF,0            -1 FOR FIRST QUOTE
         BCTR  RF,0            -1 FOR LAST QUOTE
         LA    R1,1(R1)        SET POINTER TO FIRST REAL BYTE
Z&SYSNDX DS    0H
         MEND
