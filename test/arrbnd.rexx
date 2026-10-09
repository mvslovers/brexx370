say '----------------------------------------'
say 'File arrbnd.rexx'
/* SDIFFERENCE sized its result by the smaller array but could put    */
/* all of the first into it; MDELROW/MDELCOL counted a repeated number */
/* twice and copied past the smaller result, and took an omitted       */
/* argument as a number; ISEARCH/ISEARCHNN read element 0 for from 0   */
/* (#386).                                                             */
err = 0
a = screate(150)
do i = 1 to 150; call sset a, , 'a'right(i, 3, '0'); end
b = screate(100)
do i = 1 to 100; call sset b, , 'z'right(i, 3, '0'); end
d = sdifference(a, b)
call check 'SDIFFERENCE count',   sarray(d), 150
call check 'SDIFFERENCE last',    sget(d, 150), 'a150'
m = mcreate(3, 2)
do r = 1 to 3; do c = 1 to 2; call mset m, r, c, r * 10 + c; end; end
n = mdelrow(m, 1, 1)
call check 'MDELROW repeated',    mget(n, 1, 1) mget(n, 2, 2), '21 32'
n = mdelcol(m, 2, 2)
call check 'MDELCOL repeated',    mget(n, 3, 1), 31
n = mdelrow(m, 1, , 3)
call check 'MDELROW omitted',     mget(n, 1, 2), 22
i = icreate(3)
call iset i, 1, 7; call iset i, 2, 8; call iset i, 3, 9
call check 'ISEARCH from 0',      isearch(i, 8, 0), 2
call check 'ISEARCHNN from 0',    isearchnn(i, 0), 1
say 'Done arrbnd.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('ARRBND',8) '-' left(what,18) '.. PASS'
else do
   say left('ARRBND',8) '-' left(what,18) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
