say '----------------------------------------'
say 'File arrsort.rexx'
/* Counts and ranges of the array and list functions (#386): ICREATE  */
/* PRIME counted one prime too few; ISORT returned count-1 and, like  */
/* SHSORT, left two entries unsorted; SQSORT/SHSORT 'D' and SREVERSE  */
/* returned what sreverse() left behind; FARRAY kept the highest row  */
/* of a freed matrix and gave it as a float; LLCOPY took a TO of 1 as */
/* no limit; LL2S compared FROM/TO with the index in the target array. */
err = 0
/* ICREATE PRIME */
p = icreate(5, 'PRIME')
call check 'ICREATE PRIME',   iarray(p) iget(p, 5), '5 11'
p1 = icreate(1, 'PRIME')
call check 'PRIME of 1',      iarray(p1) iget(p1, 1), '1 2'
/* ISORT */
i = icreate(2)
call iset i, 1, 9; call iset i, 2, 3
call check 'ISORT 2 items',   isort(i) iget(i, 1) iget(i, 2), '2 3 9'
call check 'ISORT D',         isort(i, 'D') iget(i, 1) iget(i, 2), '2 9 3'
e = icreate(5)
call check 'ISORT empty',     isort(e), 0
/* SHSORT, SQSORT, SREVERSE */
s = screate(5)
call sset s, , 'b'; call sset s, , 'a'
call check 'SHSORT 2',        shsort(s) sget(s, 1) sget(s, 2), '2 a b'
call sset s, , 'c'
call check 'SHSORT D',        shsort(s, 'D') sget(s, 1) sget(s, 3), '3 c a'
call check 'SQSORT D',        sqsort(s, 'D') sget(s, 1) sget(s, 3), '3 c a'
call check 'SREVERSE',        sreverse(s) sget(s, 1) sget(s, 3), '3 a c'
u = screate(5)
call sset u, , 'b'; call sset u, , 'a'
call sunify u
call check 'SUNIFY 2',        sarray(u) sget(u, 1) sget(u, 2), '2 a b'
/* FARRAY of a reused matrix number */
f = fcreate(10)
call fset f, 7, 1.5
call check 'FARRAY',          farray(f), 7
call ffree f
g = fcreate(10)
call fset g, 2, 1
call check 'FARRAY reused',   g farray(g), f 2
/* LLCOPY and LL2S ranges */
l = llcreate()
call lladd l, 'a'; call lladd l, 'b'; call lladd l, 'c'
call check 'LLCOPY to 1',     fwd(llcopy(l, , 1)), 'a'
call check 'LLCOPY 2 to 3',   fwd(llcopy(l, 2, 3)), 'b c'
t = ll2s(l, 2, 3)
call check 'LL2S 2 to 3',     sarray(t) sget(t, 1) sget(t, 2), '2 b c'
t = screate(5)
call sset t, , 'x'
call ll2s l, 1, 2, t
call check 'LL2S append',     sarray(t) sget(t, 2) sget(t, 3), '3 a b'
say 'Done arrsort.rexx'
exit err

fwd: procedure
parse arg ll
r = ''; e = llget(ll, 'FIRST')
do 20 while e \== '$$EMPTY$$'
   r = r e; e = llget(ll, 'NEXT')
end
return strip(r)

check:
parse arg what, got, want
if got == want then say left('ARRSORT',8) '-' left(what,16) '.. PASS'
else do
   say left('ARRSORT',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
