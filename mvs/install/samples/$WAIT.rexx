/* REXX ************************************************************** *
 *      LET THE BREXX/370 HAVE A BREAK                                 *
 * ******************************************************************* */
PARSE ARG seconds
IF seconds > 0 THEN CALL WAIT(seconds*100)
ELSE DO
  SAY TIME()
  CALL WAIT(4200)  /* WAIT 42s */
  SAY TIME()
END
