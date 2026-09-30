say '----------------------------------------'
say 'File numcmp.rexx'
/* #223: a numeric comparison is (A-B) compared with 0 under NUMERIC
   DIGITS (TSO/E), not the double values with their binary noise */
err = 0
call check '100.5-50.6=49.9',   100.5 - 50.6 = 49.9,        1
call check '0.1+0.2=0.3',       0.1 + 0.2 = 0.3,            1
call check '1/3=0.33..(15)',    1/3 = 0.333333333333333,    1
call check '49.89<100.5-50.6',  49.89 < 100.5 - 50.6,       1
call check '49.9<100.5-50.6',   49.9 < 100.5 - 50.6,        0
call check '0.3>=0.1+0.2',      0.3 >= 0.1 + 0.2,           1
call check '-0.0=0',            -0.0 = 0,                   1
call check '2>1',               2 > 1,                      1
call check '-2<-1',             -2 < -1,                    1
call check '1E-20<>0',          1E-20 \= 0,                 1
numeric digits 9
call check 'D9 100.5-50.6',     100.5 - 50.6 = 49.9,        1
call check 'D9 1.0000001=1',    1.0000001 = 1,              0
call check 'D9 1.00000001=1',  1.00000001 = 1,             0
call check 'D9 1.000000001=1', 1.000000001 = 1,            1
numeric digits 5
call check 'D5 1.0000001=1',    1.0000001 = 1,              1
numeric digits
n = 0
do x=0 to 1 by 0.1; n = n + 1; end
call check 'DO by 0.1',         n,                          11
say 'Done numcmp.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('NUMCMP',8) '-' left(what,16) '.. PASS'
else do
   say left('NUMCMP',8) '-' left(what,16) '.. *FAIL* got "'got'"',
       'want "'want'"'
   err = err + 1
end
return
