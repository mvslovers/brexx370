say '----------------------------------------'
say 'File preload.rexx'
/* Functions written in REXX and carried in the load module (#386):   */
/* DEFINED tested the name for a number, not the value; DATETIME took */
/* the input format for the output format; SEC2TIME cut the hours to  */
/* two digits; WORDINS left a blank behind an appended word; MVSVAR   */
/* changed the caller's I and left JOB. behind; LL2STEM returned the  */
/* string __#STEM0, and 1 for an empty list.                          */
err = 0
/* DEFINED */
a = 'x'; b = 5; drop c
call check 'DEFINED',         defined('a') defined('b') defined('c'), '1 2 0'
/* DATETIME: 'B' as output; the day and the year do not depend on TZ */
r = datetime('B', '2020/12/09-11:41:13', 'O')
r = space(subword(r, 1, 3) word(r, 5))
call check 'DATETIME O to B', r, 'Wed Dec 9 2020'
call check 'DATETIME O to T', datetime('T', '2020/12/09-11:41:13', 'O'),,
     1607514073
/* SEC2TIME */
call check 'SEC2TIME',        sec2time(3725), '01:02:05'
call check 'SEC2TIME 100h',   sec2time(360000), '100:00:00'
call check 'SEC2TIME DAYS',   sec2time(1339432, 'D', 'Tage'),,
     '15 TAGE 12:03:52'
/* WORDINS */
s = 'I love BREXX'
call check 'WORDINS 0',       wordins('really', s, 0), 'really I love BREXX'
call check 'WORDINS 1',       wordins('really', s, 1), 'I really love BREXX'
call check 'WORDINS last',    wordins('really', s, 3), 'I love BREXX really'
call check 'WORDINS beyond',  wordins('really', s, 5), 'I love BREXX really'
/* MVSVAR keeps to itself */
i = 'mine'; drop job. rxlist. _result.
n = mvsvar('JOBNAME')
x = mvsvar('REXXDSN')
x = mvsvar('REXX')
call check 'MVSVAR JOBNAME',  n \== '', 1
call check 'MVSVAR leaves',   i symbol('JOB.NAME') symbol('RXLIST.1'),
     symbol('_RESULT.0'), 'mine LIT LIT LIT'
/* LL2STEM */
l = llcreate()
call lladd l, 'a'; call lladd l, 'b'; call lladd l, 'c'
n = ll2stem(l, 'st.')
call check 'LL2STEM',         n st.0 st.1 st.3 st.4, '3 3 a c $$EMPTY$$'
e = llcreate()
n = ll2stem(e, 'em.')
call check 'LL2STEM empty',   n em.0, '0 0'
/* LISTVOL outside TSO: a return code, not error 40 */
call check 'LISTVOL batch',   lv('MVSRES'), -16
say 'Done preload.rexx'
exit err

lv: procedure
signal on syntax name lvx
return listvol(arg(1))
lvx:
return 'error' rc

check:
parse arg what, got, want
if got == want then say left('PRELOAD',8) '-' left(what,16) '.. PASS'
else do
   say left('PRELOAD',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
