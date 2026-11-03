/* REXX - ECTENVBK is 0 again after an abort (#602)                    */
/* MVSTEST TSO                                                         */
/* MVSTEST SYSTSIN TSTVPOOL CHKZERO                                    */
/* The exec ends in an abend (S0C1 in the LINKed TSTVPOOL ABEND). The  */
/* ESTAE of BREXX ends the exec with BRX0003E and RC 8; the TMP goes   */
/* on with the next command, TSTVPOOL CHKZERO, which finds ECTENVBK    */
/* back at 0 or fails (RC 1). Reaching the line after the abend means  */
/* it did not happen; that sets ECTENVBK to a foreign value so that    */
/* CHKZERO fails as well.                                              */
say '----------------------------------------'
say 'File varabort.rexx'
address tso 'TSTVPOOL ENVADDR'
env = rc
say left('VARABORT', 8) '- ECTENVBK before the abend =' d2x(env)
if env = 0 then address tso 'TSTVPOOL STEAL'
address tso 'TSTVPOOL ABEND'
say left('VARABORT', 8) '- the abend did not happen .. *FAIL*'
address tso 'TSTVPOOL STEAL'
exit 1
