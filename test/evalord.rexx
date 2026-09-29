say '----------------------------------------'
say 'File evalord.rexx'
/* #203: a term keeps the value it had when it was evaluated, even if
   a function called later in the clause changes the variable */
err = 0
$ = ''
do j=0 to 7
  $ = $ fff(j)
end
call check 'Schildberger loop', $, ' 12 12 12 12 12 12 12 12'
call check 'loop ended', j, 8
a = 1; b = 2
call check 'a+(b*f())', a + (b * setab()), 3
x = 1
call check 'x+f()', x + setx(), 1
x = 1
call check 'f(x,g())', args(x, setx()), '1 0'
x = 1
call args x, setx()
call check 'CALL f x,g()', result, '1 0'
x = 1
call check 'x+VALUE()', x + value('x', 5), 2
call check 'VALUE() set', x, 5
call check 'f(a)+g(b)', twice(3) + twice(4), 14
/* must not break: assignment target, DO control, DO BY */
x = 'a'
x = x || setxs()
call check 'x=x||f()', x, 'ab'
s = ''
do i=1 to 3; s = s || i || one(); end
call check 'DO with f()', s i, '112131 4'
n = 0
do k=1 to 5 by 2; n = n + one(); end
call check 'DO BY with f()', n k, '3 7'
say 'Done evalord.rexx'
exit err

fff:   $ = 12
       return $
setab: a = 100; b = 200
       return 1
setx:  x = 10
       return 0
setxs: x = 'z'
       return 'b'
args:  return arg(1) arg(2)
twice: return arg(1)*2
one:   return 1

check:
parse arg what, got, want
if got == want then say left('EVALORD',8) '-' left(what,18) '.. PASS'
else do
   say left('EVALORD',8) '-' left(what,18) '.. *FAIL* got "'got'"',
       'want "'want'"'
   err = err + 1
end
return
