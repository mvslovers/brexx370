/* REXX - integer, bit and fixed-string arrays stay in bounds (#171)   */
/* A bad array number, row or index must end in Error 40 instead of   */
/* reading or writing past the array; a full table must fail cleanly.  */
say '----------------------------------------'
say 'File arrays.rexx'
err = 0
/* --- integer arrays ------------------------------------------------ */
a = icreate(5, 'NULL')
call check 'ICREATE', a >= 0, 1
call e40 'ICREATE 0 rows',       'icreate(0)'
call e40 'IGET row past end',    'iget(' a ', 6)'
call e40 'ISET row past end',    'iset(' a ', 6, 1)'
call e40 'ISET append past end', 'iset(' a ',, 1)'
call e40 'IGET array 64',        'iget(64, 1)'
call e40 'IGET array 99',        'iget(99, 1)'
call e40 'IGET array not made',  'iget(63, 1)'
b = icreate(3)
call iset b, 1, 3
call iset b, 2, 1
call iset b, 3, 2
call isort b
call check 'ISORT ascending',  iget(b,1) iget(b,2) iget(b,3), '1 2 3'
call isort b, 'D'
call check 'ISORT descending', iget(b,1) iget(b,2) iget(b,3), '3 2 1'
call ifree b
call e40 'IGET after IFREE',     'iget(' b ', 1)'
call e40 'MFREE array 99',       'mfree(99, "INDEX")'
/* fill the table: the call after the last free slot returns -8      */
n = 0
do i = 1 to 70
   x = icreate(1)
   if x < 0 then leave
   n = n + 1
   made.n = x
end
call check 'ICREATE table full', x, -8
call check 'ICREATE slots', n < 64, 1
call check 'IAPPEND table full', iappend(a, a), -8
do i = 1 to n
   call ifree made.i
end
call ifree a
/* --- bit arrays ---------------------------------------------------- */
t = bitarray('CREATE', 10)
call bitarray 'SET', t, 10
call check 'BITARRAY bit 10', bitarray('GET', t, 10), 1
call check 'BITARRAY bit 9',  bitarray('GET', t, 9), 0
call e40 'BITARRAY bit 11',  'bitarray("GET",' t ', 11)'
call e40 'BITARRAY array 64', 'bitarray("GET", 64, 1)'
/* --- fixed-string arrays ------------------------------------------- */
s = sfcreate(3, 8)
call check 'SFGET unset row', sfget(s, 2), ''
call sfset s, 3, 'abc'
call check 'SFGET row 3',     sfget(s, 3), 'abc'
call e40 'SFGET row past end', 'sfget(' s ', 4)'
call e40 'SFSET array 16',     'sfset(16, 1, "x")'
call sffree s
call e40 'SFGET after SFFREE', 'sfget(' s ', 1)'
call e40 'SFFREE twice',       'sffree(' s ')'
say 'Done arrays.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('ARRAYS',8) '-' left(what,22) '.. PASS'
else do
   say left('ARRAYS',8) '-' left(what,22) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return

e40: procedure expose err
parse arg what, expr
signal on syntax name e40x
interpret 'x =' expr
say left('ARRAYS',8) '-' left(what,22) '.. *FAIL* no error'
err = err + 1
return
e40x:
if rc = 40 then say left('ARRAYS',8) '-' left(what,22) '.. PASS'
else do
   say left('ARRAYS',8) '-' left(what,22) '.. *FAIL* rc' rc
   err = err + 1
end
return
