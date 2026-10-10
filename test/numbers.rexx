say '----------------------------------------'
say 'File numbers.rexx'
/* Numeric results (#386): ROUND rounded twice, 3.141 to 3.15;        */
/* DATE('GERMAN') printed the two-digit year in four places; C2D of   */
/* more than four bytes dropped the left ones and gave 0; RANDOM took */
/* one rand() of 15 bits for any range; PRIVILEGE('OFF') returned 8.  */
err = 0
/* ROUND */
call check 'ROUND 3.141',     round(3.141, 2), '3.14'
call check 'ROUND 2.675',     round(2.675, 2), '2.68'
call check 'ROUND 9.995',     round(9.995, 2), '10.00'
call check 'ROUND -2.5',      round(-2.5, 0) round(2.5, 0), '-3 3'
call check 'ROUND -0.001',    round(-0.001, 2), '0.00'
call check 'ROUND 1.234,0',   round(1.234, 0), '1'
/* DATE('GERMAN') */
x = date('XGERMAN')
call check 'DATE GERMAN',     date('GERMAN'), left(x, 6)right(x, 2)
/* C2D */
call check 'C2D 5 bytes 0',   c2d('0000000001'x), 1
call check 'C2D 5 bytes -1',  c2d('FFFFFFFFFF'x, 5), -1
call check 'C2D FF',          c2d('FF'x), 255
call e40 'C2D too large',     "c2d('0100000000'x)"
/* RANDOM over a range wider than 32768 */
hi = 0
do 200
   hi = max(hi, random(0, 99999))
end
call check 'RANDOM wide',     hi > 32767, 1
r = random(1, 6, 7)
call check 'RANDOM small',    r >= 1 & r <= 6, 1
/* PRIVILEGE('OFF') */
p = privilege('ON')
if p = 0 then call check 'PRIVILEGE OFF', privilege('OFF'), 0
else say left('NUMBERS',8) '- PRIVILEGE OFF    .. skipped, ON rc' p
say 'Done numbers.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('NUMBERS',8) '-' left(what,16) '.. PASS'
else do
   say left('NUMBERS',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return

e40: procedure expose err
parse arg what, expr
signal on syntax name e40x
interpret 'x =' expr
say left('NUMBERS',8) '-' left(what,16) '.. *FAIL* no error, got' x
err = err + 1
return
e40x:
if rc = 40 then say left('NUMBERS',8) '-' left(what,16) '.. PASS'
else do
   say left('NUMBERS',8) '-' left(what,16) '.. *FAIL* rc' rc
   err = err + 1
end
return
