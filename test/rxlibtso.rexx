/* REXX - RXLIB routines that need TSO (#386)                        */
/* MVSTEST TSO                                                       */
/* MVSTEST RXLIB MPRINT LISTCAT RXMSG                                */
/* MPRINT printed the last 101 rows of a big matrix, not 50; LISTCAT */
/* returned the unset LRC and left LISTCAT.0 at 0 with DETAILS.      */
say '----------------------------------------'
say 'File rxlibtso.rexx'
err = 0
/* MPRINT of 120 rows: 3 title lines, then header and 50 rows twice, */
/* and two lines of dots in between                                  */
m = mcreate(120, 2)
do r = 1 to 120; call mset m, r, 1, r; call mset m, r, 2, -r; end
buffer.0 = 0
call mprint m
call check 'MPRINT lines',    buffer.0, 3 + 51 + 2 + 51
call check 'MPRINT last',     word(buffer.107, 1), 120
call check 'MPRINT 2nd part', word(buffer.58, 1), 71
/* LISTCAT */
n = listcat(userid())
call check 'LISTCAT rc',      n, 0
call check 'LISTCAT count',   listcat.0 > 0, 1
n = listcat('LV('userid()')', 'DETAILS')
call check 'LISTCAT DETAILS', listcat.0 > 0, 1
say 'Done rxlibtso.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('RXLIBTSO',8) '-' left(what,16) '.. PASS'
else do
   say left('RXLIBTSO',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
