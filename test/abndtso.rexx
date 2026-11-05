/* REXX - an abend caught by a nested BREXX under TSO (#607)           */
/* MVSTEST TSO                                                         */
/* MVSTEST ABEND=S0C4                                                  */
/* The first run starts a second BREXX with the argument ABEND. That   */
/* one writes into the PSA, which abends S0C4; its ESTAE catches it,   */
/* prints BRX0003E and ends the inner exec with RC 8. This exec then   */
/* ends with RC 0, and so does the TMP step: the step RC alone cannot  */
/* tell that a program abended.                                        */
parse arg mode
say '----------------------------------------'
say 'File abndtso.rexx'
if mode = 'ABEND' then do
   call storage 0,,'X'
   say 'ABNDTSO  - STORAGE() did not abend .. *FAIL*'
   exit 0
end
address tso 'BREXX' userid()'.BREXX370.TESTS(ABNDTSO) ABEND'
if rc \= 8 then do
   say 'ABNDTSO  - inner exec ended with rc='rc 'but should be 8 .. *FAIL*'
   exit 1
end
say 'ABNDTSO  - inner exec abended and ended with rc=8 .. PASS'
exit 0
