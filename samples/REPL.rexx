/* BREXX/370 */
PARSE VERSION LANG VER
START:
SAY "### "LANG" "VER" ###"
SAY "                      "
SAY "TYPE EXIT TO EXIT.    "
SAY "BREXX"
LOOP:
VAR  = ''
RC   = 0
PARSE UPPER EXTERNAL CMD
SIGNAL ON ERROR
SIGNAL ON SYNTAX
INTERPRET CMD
SAY 'BREXX'
SIGNAL LOOP
ERROR:
SYNTAX:
SAY 'UNKNOWN COMMAND'
SIGNAL LOOP