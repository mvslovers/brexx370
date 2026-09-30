say '----------------------------------------'
say 'File intover.rexx'
/* #110: integer arithmetic beyond 32 bits goes on as a real instead
   of wrapping around */
err = 0
call check '2147483647+1',   2147483647 + 1,        2147483648
call check '-2147483648-1',  -2147483647 - 2,       -2147483649
call check '2147480001+10000', 2147480001 + 10000,  2147490001
x = 2147483646
do 3; x = x + 1; end
call check 'x+1 three times', x,                    2147483649
n = 0
do i = 2147483646 to 2147483648; n = n + 1; end
call check 'DO over INT32',  n i,                   '3 2147483649'
n = 0
do i = -2147483647 to -2147483650 by -1; n = n + 1; end
call check 'DO BY -1',       n i,                   '4 -2147483651'
m = -2147483647 - 1
call check '-(INT32_MIN)',   -m,                    2147483648
call check 'ABS(INT32_MIN)', abs(m),                2147483648
call check '1E12 % 7',       1E12 % 7,              142857142857
call check 'in range',       2147483646 + 1,        2147483647
say 'Done intover.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('INTOVER',8) '-' left(what,16) '.. PASS'
else do
   say left('INTOVER',8) '-' left(what,16) '.. *FAIL* got "'got'"',
       'want "'want'"'
   err = err + 1
end
return
