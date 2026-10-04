say '----------------------------------------'
say 'File argnum.rexx'
/* Built-ins must not convert what the caller passed (#305): a number  */
/* written '1.50' stays '1.50' after ABS(), SIGN(), SQRT(), POW(),     */
/* ROUND() and D2P(); ARGIN() and ARRAYGEN() wrote into their first    */
/* argument too.                                                       */
err = 0
v1 = '1.50'; call abs v1;      call check 'ABS variable',   v1, '1.5'||'0'
v2 = '1.50'; call sign v2;     call check 'SIGN variable',  v2, '1.5'||'0'
v3 = '1.50'; call sqrt v3;     call check 'SQRT variable',  v3, '1.5'||'0'
v4 = '1.50'; call pow v4, 2;   call check 'POW variable',   v4, '1.5'||'0'
v5 = '2.50'; call pow 2, v5;   call check 'POW 2nd arg',    v5, '2.5'||'0'
v6 = '1.50'; call round v6, 1; call check 'ROUND variable', v6, '1.5'||'0'
v7 = '1.50'; call d2p v7;      call check 'D2P variable',   v7, '1.5'||'0'
x = sqrt('2.250')
call check 'SQRT literal',    '2.250', '2.25'||'0'
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
