say '----------------------------------------'
say 'File njedereg.rexx'
/* __NJEDEREGISTER (#328): the user id is upper-cased as in            */
/* __NJEREGISTER, and a user that never called __NJERECEIVE has no     */
/* subtask to end (it ended in S102). NJERLY is not called, so neither */
/* authorization nor traffic is needed; the NJE38 started task is.     */
/* A user id of more than 8 characters is Error 40 (#477): it ran      */
/* past the 8 byte buffers. That test needs no NJE38, the length is    */
/* checked before the state of the started task.                       */
err = 0
call syn 'register 9 chars',   "r = __njeregister('ABCDEFGHI')",   40
call syn 'register 12 chars',  "r = __njeregister('ABCDEFGHIJKL')", 40
call syn 'dereg 9 chars',      "r = __njederegister('ABCDEFGHI')", 40
call syn 'dereg 12 chars',     "r = __njederegister('abcdefghijkl')", 40
signal on syntax name noNje
call __njeinit
signal off syntax

call syn 'register 12 active', "r = __njeregister('ABCDEFGHIJKL')", 40
call syn 'dereg 12 active',    "r = __njederegister('ABCDEFGHIJKL')", 40
call syn 'receive no user',    "r = __njereceive()",               68
call check 'dereg unknown',   __njederegister('NOBODY'),  28
call check 'register lower',  __njeregister('njetst1'),   0
call check 'dereg lower',     __njederegister('njetst1'), 0
call check 'register again',  __njeregister('NJETST1'),   24
call check 'register 2',      __njeregister('NJETST2'),   0
call check 'dereg no recv',   __njederegister('NJETST2'), 0
call check 'dereg twice',     __njederegister('NJETST2'), 0
say 'Done njedereg.rexx'
exit err

noNje:
signal off syntax
say left('NJEDEREG',8) '- NJE38 is not active or NJERLY is missing' ,
    '.. SKIPPED (rest)'
say 'Done njedereg.rexx'
exit err

syn: procedure expose err
parse arg what, stmt, want
signal on syntax name synx
interpret stmt
say left('NJEDEREG',8) '-' left(what,16) '.. *FAIL* no error'
err = err + 1
return
synx:
if rc = want then say left('NJEDEREG',8) '-' left(what,16) '.. PASS'
else do
   say left('NJEDEREG',8) '-' left(what,16) '.. *FAIL* rc' rc 'want' want
   err = err + 1
end
return

check:
parse arg what, got, want
if got == want then say left('NJEDEREG',8) '-' left(what,16) '.. PASS'
else do
   say left('NJEDEREG',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
