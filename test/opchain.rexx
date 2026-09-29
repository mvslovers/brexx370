say '----------------------------------------'
say 'File opchain.rexx'
/* comparisons of the same priority chain left to right:
   2=2=2 is (2=2)=2, i.e. 1=2 (vlachoudis/brexx PR 25) */
err = 0
call check '2=2=2', 2=2=2, 0
call check '1=1=1', 1=1=1, 1
call check '3>2>1', 3>2>1, 0
call check "'a'=='a'==1", 'a'=='a'==1, 1
a = 2=2=2
call check 'a=2=2=2', a, 0
say 'Done opchain.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('OPCHAIN',8) '-' left(what,14) '.. PASS'
else do
   say left('OPCHAIN',8) '-' left(what,14) '.. *FAIL* got "'got'"',
       'want "'want'"'
   err = err + 1
end
return
