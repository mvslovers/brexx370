say '----------------------------------------'
say 'File matovfl.rexx'
/* #459: the matrix functions computed with plain doubles, so a result
   beyond the S/370 float range (about 7.2E+75) abended BREXX with S0CC.
   They check the range as the operators do (#267) and give error 42,
   which SIGNAL ON SYNTAX catches. The result matrix of a failed call
   is freed again. The cases in range must stay results. A number from
   1E75 on is not read from a literal or a string (#266), so the big
   elements are results of MSCALAR, and results are scaled down before
   REXX reads them. */
err = 0
a = mcreate(1, 1)
call mset a, 1, 1, 1E70
b = mcreate(2, 2)
call mset b, 1, 1, 1E40; call mset b, 1, 2, 1E40
call mset b, 2, 1, 1E40; call mset b, 2, 2, 1E40
c = mcreate(2, 2)
call mset c, 1, 1, 8E37; call mset c, 1, 2, 8E37
call mset c, 2, 1, 8E37; call mset c, 2, 2, 8E37
d = mcreate(2, 2)
call mset d, 1, 1, 1E-40; call mset d, 1, 2, 1E40
call mset d, 2, 1, 0;     call mset d, 2, 2, 1
p = mcreate(2, 2)
call mset p, 1, 1, 1E70; call mset p, 1, 2, 1E70
call mset p, 2, 1, 1E70; call mset p, 2, 2, 1E70
e = mscalar(p, 6E5)
n = mscalar(p, -6E5)
h = mscalar(p, 1E5)
f = mcreate(1, 1)
call mset f, 1, 1, 1E-77
g = mcreate(2, 2)
call mset g, 1, 1, 1E37; call mset g, 1, 2, 1E37
call mset g, 2, 1, 1E37; call mset g, 2, 2, 1E37
k = mcreate(2, 2)
call mset k, 1, 1, 1E-77; call mset k, 1, 2, 1E-77
call mset k, 2, 1, 1E-77; call mset k, 2, 2, 1E-77

call over "x = mscalar(a, 1E70)"
call over "x = mscalar(a, -1E70)"
call over "x = mmultiply(b, b)"
call over "x = mmultiply(c, c)"
call over "x = minvert(d)"
call over "x = minvert(f)"
call over "x = mprod(b, b)"
call over "x = madd(e, e)"
call over "x = msubtract(e, n)"
call over "x = msqr(b)"

/* in range: the same functions stay results */
call ok "x = mget(mscalar(a, 2), 1, 1) / 1E70",        2
call ok "x = mget(mscalar(a, 1E-70), 1, 1)",           1
call ok "x = mget(mscalar(mmultiply(c, g), 1E-70), 1, 1)", 160000
call ok "x = mget(mscalar(madd(e, h), 1E-70), 1, 1)",   700000
call ok "x = mget(mscalar(msubtract(n, h), 1E-70), 1, 1)", -700000
call ok "x = mget(mprod(b, k), 1, 1) / 1E-37",         1
d2 = mcreate(2, 2)
call mset d2, 1, 1, 1E-30; call mset d2, 1, 2, 1E30
call mset d2, 2, 1, 0;     call mset d2, 2, 2, 1
call ok "x = mget(minvert(d2), 1, 2) / 1E60",         -1
say 'Done matovfl.rexx'
exit err

over:
parse arg clause
free = mcreate(1, 1)
call mfree free, 'MATRIX'
signal on syntax name bad
interpret clause
signal off syntax
say left('MATOVFL',8) '-' left(clause,30) '.. *FAIL* no error, x' x
err = err + 1
return
bad:
if rc \= 42 then do
   say left('MATOVFL',8) '-' left(clause,30) '.. *FAIL* error' rc
   err = err + 1
   return
end
again = mcreate(1, 1)
call mfree again, 'MATRIX'
if again = free then say left('MATOVFL',8) '-' left(clause,30) '.. PASS'
else do
   say left('MATOVFL',8) '-' left(clause,30) '.. *FAIL* matrix' free,
       'taken, next is' again
   err = err + 1
end
return

ok:
parse arg clause, want
signal on syntax name badok
interpret clause
signal off syntax
if abs(x-want) <= abs(want) * 1E-9 then
   say left('MATOVFL',8) '-' left(clause,30) '.. PASS'
else do
   say left('MATOVFL',8) '-' left(clause,30) '.. *FAIL* got' x 'want' want
   err = err + 1
end
return
badok:
say left('MATOVFL',8) '-' left(clause,30) '.. *FAIL* error' rc
err = err + 1
return
