say '----------------------------------------'
say 'File argraw.rexx'
/* As a TSO command processor BREXX takes the exec's argument string   */
/* unchanged from the command buffer, as TSO/E does for an implicit    */
/* exec: without leading and trailing blanks, runs of blanks and quotes */
/* kept (#353; rules measured on z/OS, rexx370#331). It used to rejoin */
/* libc370's argv with single blanks and lost the double quotes.       */
/* Batch (PARM) and TSO CALL have no command buffer and keep argv.     */
/* The TSO step runs: BREXX '...(ARGRAW)'   a   b  'c  d' "e"   CHECK  */
parse arg all
if wordpos('CHECK', all) = 0 then do
   say 'ARGRAW   - not called with the test arguments .. PASS'
   exit 0
end
want = 'a   b  ''c  d'' "e"   CHECK'
if all == want then do
   say 'ARGRAW   - argument string .. PASS'
   exit 0
end
say 'ARGRAW   - argument string .. *FAIL* got <'all'> want <'want'>'
exit 8
