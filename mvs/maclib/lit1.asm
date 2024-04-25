         MACRO
         LIT1  &NAME
&NAME    CSECT .
***********************************************************************
* PROGRAM TO COPY A LITERAL DEFINED IN THIS PROGRAM INTO A LOCATION
* DEFINED BY THE CALLING PROGRAM.  IT WAS WRITTEN TO ENABLE COBOL AND
* FORTRAN PROGRAMS TO DEFINE FULL-SCREEN 3270 MENUS.  IT CONSISTS OF
* TWO MACROS, WITH SOME USER-DEFINED CONSTANTS BETWEEN.
*
* SAMPLE CODING SEQUENCE:
*        LIT1  MENU1
*        DC    X'C3'              WCC
*        DC    X'114040'          SBA AT START OF SCREEN
*        DC    X'3C4C6000'        CLEAR THROUGH LINE 10
*        DC    X'114040'          LINE 1: TITLE
*        DC    X'1DF8',C'ADD COMMUNICATIONS LINE'
*        LIT2
*
* SAMPLE CALLING SEQUENCE:
*    CALL 'MENU1' USING MENU.
* WHERE MENU IS THE LOCATION IN THE CALLING PROGRAM WHERE THE LITERAL
* IS TO BE COPIED.
*
* KEITH NEWSOM, WDPSC, 12-77
***********************************************************************
BEGIN    B     14(0,15) .         BRANCH AROUND ID
         DC    AL1(8) .
         DC    CL8'&NAME.       ' . IDENTIFIER
         STM   14,12,12(13) .     SAVE REGISTERS
         BALR  12,0 .
         USING *,12 .
         LA    4,LIT .            SET UP "FROM" ADDRESS AND LENGTH
         L     5,LENLIT .
         L     6,0(1) .           SET UP "TO" ADDRESS AND LENGTH
         L     7,LENLIT .
         MVCL  6,4 .              MOVE LITERAL
         LM    14,12,12(13) .     RESTORE REGISTERS
         LA    15,0(0,0) .        LOAD RETURN CODE
         BR    14 .               RETURN
LIT      EQU   * .
*----------------------------------------------------------------------
* DEFINE YOUR LITERAL BETWEEN HERE . . .
*----------------------------------------------------------------------
         MEND
