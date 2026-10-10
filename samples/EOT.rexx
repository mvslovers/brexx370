/* BREXX/370 */
parse version lang ver
start:
say "### "lang" "ver" ###"
SAY "BREXX Interactive Mode"
loop:
/* a trap that fired is off: arm both again on every return here, */
/* or the second error ended EOT (#386)                           */
signal on error
signal on syntax
do forever
   var  = ''
   rc   = 0
   say ">> BREXX, enter valid BREXX statement, or EXIT to leave"
   parse external cmd
   interpret cmd
end
error:
   say 'unknown command: 'cmd
signal loop
syntax:
   say 'Syntax Error: 'cmd
signal loop
