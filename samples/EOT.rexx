/* BREXX/370 */
parse version lang ver
start:
say "### "lang" "ver" ###"
SAY "BREXX Interactive Mode"
signal on error
signal on syntax
loop:
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
