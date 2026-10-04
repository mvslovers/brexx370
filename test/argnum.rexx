say '----------------------------------------'
say 'File argnum.rexx'
/* Built-ins must not convert what the caller passed (#305): a number  */
/* written '1.50' stays '1.50' after ABS(), SIGN(), SQRT(), POW(),     */
/* ROUND() and D2P(); ARGIN() and ARRAYGEN() wrote into their first    */
/* argument too.                                                       */
err = 0
v = '1.50'
call abs v;        call check 'ABS variable',   v, '1.5'||'0'
call sign v;       call check 'SIGN variable',  v, '1.5'||'0'
call sqrt v;       call check 'SQRT variable',  v, '1.5'||'0'
call pow v, 2;     call check 'POW variable',   v, '1.5'||'0'
call round v, 1;   call check 'ROUND variable', v, '1.5'||'0'
call d2p v;        call check 'D2P variable',   v, '1.5'||'0'
x = sqrt('2.25')
call check 'SQRT literal',    '2.25', '2.2'||'5'
s = 'abc'
call stemhi s
call check 'STEMHI variable', s, 'ab'||'c'
say 'Done argnum.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('ARGNUM',8) '-' left(what,16) '.. PASS'
else do
   say left('ARGNUM',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
