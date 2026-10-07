/* REXX - PULL under a TMP reads SYSTSIN through GETLINE             */
/* MVSTEST TSO                                                       */
/* MVSTEST SYSTSIN first line  with  blanks                          */
/* MVSTEST SYSTSIN Second Line                                       */
/* With an empty stack PULL and PARSE PULL read the next SYSTSIN     */
/* line in TSO background (z/OS TSO/E REXX Reference, PARSE PULL);   */
/* TSO does not run that line as a command. At the end of SYSTSIN    */
/* PULL returns a null string. The stack still comes first.          */
say '----------------------------------------'
say 'File pulltso.rexx'
err = 0

queue 'FROM THE STACK'
parse pull l
call check 'stack before SYSTSIN', l = 'FROM THE STACK', '<'l'>'

parse pull l
call check 'PARSE PULL reads SYSTSIN as is',,
     l = 'first line  with  blanks', '<'l'>'
pull l
call check 'PULL reads the next line, upper case',,
     l = 'SECOND LINE', '<'l'>'
parse pull l
call check 'end of SYSTSIN gives a null string', l = '', '<'l'>'

say 'Done pulltso.rexx'
exit err

check:
parse arg what, ok, detail
if ok then say left('PULLTSO',8) '-' what '.. PASS'
else do
  say left('PULLTSO',8) '-' what '.. *FAIL*' detail
  err = 1
end
return
