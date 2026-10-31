say '----------------------------------------'
say 'File njedereg.rexx'
/* __NJEDEREGISTER (#328): the user id is upper-cased as in            */
/* __NJEREGISTER, and a user that never called __NJERECEIVE has no     */
/* subtask to end (it ended in S102). NJERLY is not called, so neither */
/* authorization nor traffic is needed; the NJE38 started task is.     */
err = 0
signal on syntax name noNje
call __njeinit
signal off syntax

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
    '.. SKIPPED'
say 'Done njedereg.rexx'
exit 0

check:
parse arg what, got, want
if got == want then say left('NJEDEREG',8) '-' left(what,16) '.. PASS'
else do
   say left('NJEDEREG',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
