say '----------------------------------------'
say 'File iarrays.rexx'
/* The integer array functions moved from rxmvs.c to rxiarray.c       */
/* (#302) that arrays.rexx does not cover: IADD, ISUB, ICMP, ISORT,   */
/* ISEARCH, I2S, the integer matrices IM*, IARRAY, PRIME, S2IARRAY    */
/* and S2HASH.                                                        */
err = 0
iv = icreate(5)
call iset iv, 1, 30
call iset iv, 2, 10
call iset iv, 3, 20
call check 'IADD',           iadd(iv, 1, 5), 35
call check 'ISUB',           isub(iv, 2, 3), 7
call check 'ICMP 35:20',     icmp(iv, 1, iv, 3), 1
call isort iv
call check 'ISORT first',    iget(iv, 1), 7
call check 'ISORT last',     iget(iv, 3), 35
call check 'ISEARCH 20',     isearch(iv, 20), 2
s = i2s(iv)
call check 'I2S item 3',     sget(s, 3), 35
m = imcreate(2, 3)
call imset m, 2, 3, 9
call check 'IMADD',          imadd(m, 2, 3, 1), 10
call check 'IMGET',          imget(m, 2, 3), 10
call check 'IARRAY columns', iarray(m, 'C'), 3
call check 'IARRAY rows',    iarray(m, 'R'), 2
call check 'PRIME 1',        prime(1), 2
call check 'PRIME 10',       prime(10), 29
sa = screate(3)
call sset sa, 1, '12'
call sset sa, 2, 'X'
call sset sa, 3, '12'
n = s2iarray(sa)
call check 'S2IARRAY',       iget(n, 3), 12
h = s2hash(sa)
call check 'S2HASH equal',   iget(h, 1) = iget(h, 3), 1
call check 'S2HASH differ',  iget(h, 1) = iget(h, 2), 0
call check 'S2IARRAY 999',   refused('s2iarray(999)'), 1
call sfree sa
call sfree s
say 'Done iarrays.rexx'
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
if got == want then say left('IARRAYS',8) '-' left(what,16) '.. PASS'
else do
   say left('IARRAYS',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
