say '----------------------------------------'
say 'File matrix.rexx'
/* The matrix functions moved from rxmvs.c to rxmatrix.c (#302):     */
/* MCREATE, MSET, MGET, MTRANSPOSE, MMULTIPLY, MINVERT and MFREE.    */
err = 0
a = mcreate(2, 3)
call check 'MCREATE',        a >= 0, 1
k = 0
do r = 1 to 2
   do c = 1 to 3
      k = k + 1
      call mset a, r, c, k
   end
end
call check 'MGET 2,3',       mget(a, 2, 3), 6
t = mtranspose(a)
call check 'MTRANSPOSE 3,2', mget(t, 3, 2), 6
call check 'MTRANSPOSE 1,2', mget(t, 1, 2), 4
p = mmultiply(a, t)
call check 'MMULTIPLY 1,1',  mget(p, 1, 1), 14
call check 'MMULTIPLY 2,1',  mget(p, 2, 1), 32
s = madd(a, a)
call check 'MADD 2,3',       mget(s, 2, 3), 12
s = msubtract(a, a)
call check 'MSUBTRACT 2,3',  mget(s, 2, 3), 0
s = mprod(a, a)
call check 'MPROD 2,3',      mget(s, 2, 3), 36
call check 'MADD 2x3+3x2',   madd(a, t), 8
d = mcreate(2, 2)
call mset d, 1, 1, 2; call mset d, 1, 2, 0
call mset d, 2, 1, 0; call mset d, 2, 2, 4
i = minvert(d)
call check 'MINVERT 1,1',    mget(i, 1, 1), 0.5
call check 'MINVERT 2,2',    mget(i, 2, 2), 0.25
/* a row or matrix number outside the matrix read and wrote beside it; */
/* both are error 40 now                                               */
call check 'MGET row 3',     refused("mget(a, 3, 1)"), 1
call check 'MSET col 4',     refused("mset(a, 1, 4, 9)"), 1
call check 'MGET matrix 128', refused("mget(128, 1, 1)"), 1
call mfree a, 'MATRIX'
call mfree
say 'Done matrix.rexx'
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
if got = want then say left('MATRIX',8) '-' left(what,16) '.. PASS'
else do
   say left('MATRIX',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
