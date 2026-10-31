say '----------------------------------------'
say 'File hfpovfl.rexx'
/* #267: a result beyond the S/370 float range (about 7.2E+75) abended
   BREXX with S0CC, a program check that no mask suppresses. Each
   operator checks first and gives error 42 now, which SIGNAL ON SYNTAX
   catches. The cases in range must stay results. */
err = 0
call over "x = 1E50 * 1E50"
call over "x = -1E50 * 1E50"
call over "x = 1; do 80; x = x * 10; end"
call over "a = 9E74; x = a+a+a+a+a+a+a+a+a"
call over "a = -9E74; x = a-9E74-9E74-9E74-9E74-9E74-9E74-9E74-9E74"
call over "x = 1E70 / 1E-10"
call over "x = -1E70 / 1E-10"
call over "x = 1E70 % 1E-10"
call over "x = 1E70 // 1E-10"
call over "x = 10 ** 80"
call over "x = 10 ** 76"
call over "x = -10 ** 77"
call over "x = 2 ** 300"
call over "x = 10 ** -80"
call over "x = 1E-70 ** -2"
call over "x = 0 ** -1"
call ok   "x = (1E37 * 7E37) / 1E70",        70000
call ok   "x = (8E37 * 8E37) / 1E70",        640000
call ok   "x = (-8E37 * 8E37) / 1E70",      -640000
call ok   "x = (9E74 * 5 + 9E74) / 1E70",    540000
call ok   "a = 9E74; x = (a+a+a+a+a+a+a) / 1E70",   630000
call ok   "a = -9E74; x = (a-9E74-9E74-9E74-9E74-9E74-9E74) / 1E70", -630000
call ok   "x = (1E70 / 1E-5) / 1E70",        100000
call ok   "x = (1E-70 / 1E-5) / 1E-65",      1
call ok   "x = 1E-50 * 1E50",                1
call ok   "x = (10 ** 75) / 1E70",           100000
call ok   "x = (10 ** -70) / 1E-70",         1
call ok   "x = 2 ** 100",                    1.267650600228229E30
call ok   "x = 1 ** 1000000",                1
call ok   "x = (1E70 % 1E-5) / 1E70",        100000
/* the math functions answer beyond the range with error 42, too; what
   libc370 does there depends on its version (S0CC before 2.23) */
call over "x = exp(200)"
call over "x = cosh(200)"
call over "x = cosh(-200)"
call over "x = sinh(200)"
call over "x = pow10(80)"
call over "x = pow(10,80)"
call over "x = pow(1E-10,-8)"
call over "x = pow(10,1E30)"
call over "x = pow(2,252)"
call over "x = pow(0.5,-252)"
call over "x = exp(174.6731)"
call ok   "x = exp(0)",                      1
call ok   "x = pow10(2)",                    100
call ok   "x = pow(2,10)",                   1024
call ok   "x = pow(2,251.99) / 1E70",        718701.5928
call ok   "x = exp(174) / 1E70",             369181.4330
say 'Done hfpovfl.rexx'
exit err

over:
parse arg clause
signal on syntax name bad
interpret clause
signal off syntax
say left('HFPOVFL',8) '-' left(clause,30) '.. *FAIL* no error, x' x
err = err + 1
return
bad:
if rc == 42 then say left('HFPOVFL',8) '-' left(clause,30) '.. PASS'
else do
   say left('HFPOVFL',8) '-' left(clause,30) '.. *FAIL* error' rc
   err = err + 1
end
return

ok:
parse arg clause, want
signal on syntax name badok
interpret clause
signal off syntax
if abs(x-want) <= abs(want) * 1E-9 then
   say left('HFPOVFL',8) '-' left(clause,30) '.. PASS'
else do
   say left('HFPOVFL',8) '-' left(clause,30) '.. *FAIL* got' x 'want' want
   err = err + 1
end
return
badok:
say left('HFPOVFL',8) '-' left(clause,30) '.. *FAIL* error' rc
err = err + 1
return
