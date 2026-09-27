/* REXX - logic errors (#132)                                          */
say '----------------------------------------'
say 'File logic132.rexx'
err = 0
/* LOCATE: "ARGN > 3 && ARGN < 2" never fired, a 4th argument was     */
/* silently ignored. It must be error 40 now.                          */
signal on syntax name locerr
x = locate('A', 'B', 'C', 'D')
call check 'LOCATE 4 args', 'no error', 'error 40'
signal locdone
locerr:
call check 'LOCATE 4 args', 'error' rc, 'error 40'
locdone:
/* DATE: the error path appended "/format" to the caller's argument    */
v = 'ABCDEF'
signal on syntax name daterr
x = date('S', v, 'T')
call check 'DATE bad input', 'no error', 'error 40'
signal datdone
daterr:
call check 'DATE bad input', 'error' rc, 'error 40'
datdone:
call check 'DATE argument kept', v, 'ABCDEF'
/* E2A / A2E: the result must be a string, also for a numeric source  */
call check 'E2A/A2E round trip', a2e(e2a('Hello 123')), 'Hello 123'
call check 'E2A numeric', c2x(e2a(123)), '313233'
call check 'A2E', a2e('414243'x), 'ABC'
say 'Done logic132.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('LOGIC132',8) '-' left(what,20) '.. PASS'
else do
   say left('LOGIC132',8) '-' left(what,20) '.. *FAIL*'
   say '   got  "'got'"'
   say '   want "'want'"'
   err = err + 1
end
return
