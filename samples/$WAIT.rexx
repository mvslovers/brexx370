/* REXX ************************************************************** *
 *      LET THE BREXX/370 HAVE A BREAK                                 *
 * ******************************************************************* */
PARSE ARG seconds
say copies('-',60)
say "Wait a bit"
say copies('-',60)
  if seconds > 0 then call wait(seconds*1000)
  else do
    say time()
    call wait(42000)  /* wait 42s */
    say time()
  end
