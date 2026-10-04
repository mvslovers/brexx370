say '----------------------------------------'
say 'File libcgap.rexx'
/* WAIT(), USERID() and TIME('E') (#298): compat's Sleep(), getlogin() */
/* and gettimeofday() became BREXX's sleepMs(), rac_user() and a local */
/* time-of-day in lstring/time.c.                                      */
err = 0
call check 'USERID set',      userid() \= '', 1
/* SYSUID is empty in batch; in TSO both name the logged-on user     */
if sysvar('SYSUID') \= '' then,
   call check 'USERID SYSUID',   userid(), sysvar('SYSUID')
call time 'R'
call wait 300
e = time('E')
call check 'WAIT 300 >= 0.3', e >= 0.3, 1
call check 'WAIT 300 < 5',    e < 5, 1
say left('LIBCGAP',8) '- elapsed' e
say 'Done libcgap.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('LIBCGAP',8) '-' left(what,16) '.. PASS'
else do
   say left('LIBCGAP',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
