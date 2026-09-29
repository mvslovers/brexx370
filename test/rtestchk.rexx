say '----------------------------------------'
say 'File rtestchk.rexx'
/* #195: RTEST itself. A strict compare (\==) must fail on any
   difference; only \= may pass a numeric near hit as *WARN* */
err = 0
say 'RTESTCHK - the next line must be *FAIL*'
call check rtest("'1.0000E+00'","\== '1.0000'",1), 8, 'strict'
call check rtest("'1.0000'","\== '1.0000'",2), 0, 'strict equal'
call check rtest("'0.3'","\= 0.3000000000001",3), 0, 'near hit'
call check rtest("'0.3'","\= 0.31",4), 8, 'numeric off'
say 'Done rtestchk.rexx'
exit err

check:
  parse arg got, want, what
  if got = want then say 'RTESTCHK -' left(what,14) '.. PASS'
  else do
    say 'RTESTCHK -' left(what,14) '.. *FAIL* rtest returned' got,
        'expected' want
    err = 8
  end
  return
