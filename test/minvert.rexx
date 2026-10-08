say '----------------------------------------'
say 'File minvert.rexx'
/* MINVERT took the first pivot from the element one column past the  */
/* row (i after a loop), compared fabs(a > max) instead of fabs(a),    */
/* searched rows already reduced, and kept 1000-entry work tables on   */
/* the stack (#386). Each case checks A x MINVERT(A) = I.              */
err = 0
call try 'needs a row swap', 2, '0 1 1 0'
call try 'general 2x2',      2, '4 7 2 6'
call try 'negative pivots',  2, '-3 1 1 -2'
call try 'larger below',     2, '1 2 3 4'
call try '3x3',              3, '2 -1 0 -1 2 -1 0 -1 2'
call try '3x3 swaps',        3, '0 2 1 1 0 0 0 1 3'
signal on syntax name sing
m = mk(2, '1 2 2 4')
x = minvert(m)
say left('MINVERT',8) '-' left('singular',18) '.. *FAIL* no error'
err = err + 1
signal done
sing: say left('MINVERT',8) '-' left('singular',18) '.. PASS rc' rc
done:
say 'Done minvert.rexx'
exit err

mk: procedure
parse arg n, v
m = mcreate(n, n)
k = 0
do r = 1 to n
   do c = 1 to n
      k = k + 1
      call mset m, r, c, word(v, k)
   end
end
return m

try: procedure expose err
parse arg what, n, v
a = mk(n, v)
i = minvert(a)
p = mmultiply(a, i)
bad = ''
do r = 1 to n
   do c = 1 to n
      want = (r = c)
      if abs(mget(p, r, c) - want) > 0.000001 then,
         bad = bad r','c'='mget(p, r, c)
   end
end
if bad = '' then say left('MINVERT',8) '-' left(what,18) '.. PASS'
else do
   say left('MINVERT',8) '-' left(what,18) '.. *FAIL* A x inv:' bad
   err = err + 1
end
return
