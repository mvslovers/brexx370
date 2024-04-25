         MACRO
         BRKELEM
***********************************************************************
*                                                                     *
*        MAPPING DSECT FOR BREAK ELEMENTS AND ASSOCIATED FLAGS.       *
*                                                                     *
*        STATUS -- VERSION NO. 01 -  RELEASE NO. 01 - OS/VS2          *
*                                                                     *
*        CHANGE LEVEL -- 00 - DATE 03/09/72                           *
*                                                                     *
***********************************************************************
BRKELEM  DSECT
BRKLINK  DS    F -                POINTER TO NEXT BREAK ELEMENT.
BRKADDR  DS    F -                PROBLEM PROGRAM INSTRUCTION ADDRESS.
BRKINST  DS    2F -               ORIGINAL INSTRUCTION AND 2 BYTE SVC.
BRKFLGS  DS    1X -               ONE BYTE FOR FLAGS.
BALSW    EQU   B'10000000' -      BAL OR BALR IN ORIGINAL INSTRUCTION.
BRKRANGE EQU   B'01000000' -      THIS BREAK ELEMENT IS ONE OF A RANGE.
BRKLIST  EQU   B'00100000' -      THIS BREAK ELEMENT IS ONE OF A LIST.
BRKNONOT EQU   B'00010000' -      USER IS NOT TO BE NOTIFIED IF THIS
*                                 BREAKPOINT IS ENCOUNTERED.
         DS    X -                RESERVED.
BRKDISP  DS    H -                DISPLACEMENT FROM FIRST ADDRESS OF
*                                 A RANGE.
BRKNAME  DS    F -                POINTER TO THE ADDRESS STRING.
BRKCHAIN DS    F -                POINTER TO THE SUB-COMMAND CHAIN.
BRKCOUNT DS    F -                COUNT INFORMATION.
BRKRB    DS    F -                POINTER TO PROBLEM PROGRAM RB.
         DS    0D -               FORCE LENGTH EQUATE TO DOUBLE WORD.
BRKLEN   EQU   *-BRKELEM -        BREAK ELEMENT LENGTH.
         MEND
