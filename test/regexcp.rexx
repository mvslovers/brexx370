say '----------------------------------------'
say 'File regexcp.rexx'
/* MATCH patterns typed under the three 3270 code pages (#187). '[',   */
/* ']' and '^' are X'BA' X'BB' X'B0' in CP037, X'AD' X'BD' X'B0' in    */
/* the x3270 "bracket" page and X'AD' X'BD' X'5F' in IBM-1047. The     */
/* upload changes such characters, so the tests build them with x2c.   */
r = 0
call check 'CP037 class',    match(x2c('BA')'0-9'x2c('BB')'+', 'ab12'), 2
call check 'CP037 anchor',   match(x2c('B0')'ab', 'xab'), -1
call check 'CP037 anchor 2', match(x2c('B0')'ab', 'abc'), 0
call check 'bracket class',  match(x2c('AD')'0-9'x2c('BD')'+', 'ab12'), 2
call check '1047 anchor',    match(x2c('5F')'ab', 'xab'), -1
call check '1047 anchor 2',  match(x2c('5F')'ab', 'abc'), 0
say 'Done regexcp.rexx'
exit r

check:
parse arg what, got, want
if got == want then say left('REGEXCP',8) '-' left(what,16) '.. PASS'
else do
   say left('REGEXCP',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   r = 8
end
return
