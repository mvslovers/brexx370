say '----------------------------------------'
say 'File interr.rexx'
/* #225: compile errors inside INTERPRET, caught by SIGNAL ON SYNTAX,
   left the clauses compiled before the error in the clause table; they
   point into the freed interpreted string, and the next run-time error
   in an INTERPRET abended S0C4. The order below reproduced it. */
l.1 = "numeric digits"
l.2 = "numeric form"
l.3 = "numeric form engineering"
l.4 = "numeric form valux 'engineering'"
l.5 = "t1v='scientific'; numeric form valux t1v"
l.6 = "numeric form valux 'enormous'"
l.7 = "numeric form valux 'e'"
l.8 = "numeric fuzz"
l.9 = "numeric digits 0"
l.10 = "numeric fuzz 2"
got = ''
do i=1 to 10
  call p l.i
end
want = '0 0 0 25 25 25 25 0 26 0'
if strip(got) == want then say left('INTERR',8) '- error sequence  .. PASS'
else do
  say left('INTERR',8) '- error sequence  .. *FAIL* got "'strip(got)'"'
  exit 8
end
say 'Done interr.rexx'
exit 0
/* this routine as it was when the abend was found: the layout of the
   storage it leaves decides whether the stale clauses are read */
p: parse arg c
   signal on syntax name bad
   x = '-'
   interpret c
   say left(c,42) 'ok' x form()
   got = got 0
   return
bad: say left(c,42) 'error' rc errortext(rc)
   got = got rc
   return
