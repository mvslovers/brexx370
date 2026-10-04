say '----------------------------------------'
say 'File sarrays.rexx'
/* The string array functions moved from rxmvs.c to rxsarray.c       */
/* (#302): SCREATE, SSET, SGET, SARRAY, SSWAP, SQSORT, SREVERSE,     */
/* SCOPY, SUPPER, SCOUNT, SINTERSECT, SDIFFERENCE, SMERGE, SINSERT,  */
/* SDEL, SEXTRACT and SDROP.                                         */
err = 0
s = screate(10)
call sset s, 1, 'pear'
call sset s, 2, 'apple'
call sset s, 3, 'fig'
call sset s, 4, 'apple pie'
call check 'SARRAY',         sarray(s), 4
call sswap s, 1, 2
call check 'SSWAP',          sget(s, 1), 'apple'
call sqsort s
call check 'SQSORT first',   sget(s, 1), 'apple'
call check 'SQSORT last',    sget(s, 4), 'pear'
call sreverse s
call check 'SREVERSE',       sget(s, 1), 'pear'
c = scopy(s)
call check 'SCOPY',          sget(c, 1) sarray(c), 'pear 4'
u = supper(c)
call check 'SUPPER',         sget(u, 1), 'PEAR'
call check 'SCOUNT',         scount(c, 'apple'), 2
x = screate(5)
call sset x, 1, 'a'; call sset x, 2, 'b'; call sset x, 3, 'c'
y = screate(5)
call sset y, 1, 'b'; call sset y, 2, 'c'; call sset y, 3, 'd'
i = sintersect(x, y)
call check 'SINTERSECT',     sarray(i) sget(i, 1), '2 b'
d = sdifference(x, y)
call check 'SDIFFERENCE',    sarray(d) sget(d, 1), '1 a'
m = smerge(x, y)
call check 'SMERGE',         sarray(m) sget(m, 1) sget(m, 6), '6 a d'
call sinsert c, 1, 2
call check 'SINSERT',        sarray(c) sget(c, 4), '6 fig'
call sdel c, 2, 2
call check 'SDEL',           sarray(c) sget(c, 2), '4 fig'
e = sextract(c, 2, 3)
call check 'SEXTRACT',       sarray(e) sget(e, 1), '2 fig'
call sdrop c, 'apple'
call check 'SDROP',          sarray(c), 2
/* an array number outside the table or never created indexed       */
/* sarray[] beside it; error 40 now, SARRAY answers -1 as documented */
call check 'SGET 999',       refused('sget(999, 1)'), 1
call check 'SSET 127',       refused('sset(127, 1, "x")'), 1
call check 'SARRAY 128',     sarray(128), -1
say 'Done sarrays.rexx'
exit err

refused:
parse arg expr
signal on syntax name refusedyes
interpret 'x =' expr
signal off syntax
return 0
refusedyes:
signal off syntax
return 1

check:
parse arg what, got, want
if got == want then say left('SARRAYS',8) '-' left(what,16) '.. PASS'
else do
   say left('SARRAYS',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
