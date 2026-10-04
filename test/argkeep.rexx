say '----------------------------------------'
say 'File argkeep.rexx'
/* A built-in that upper-cases its argument in place (Lupper(ARGn))    */
/* changed what the caller passed (#305): a literal, shared by every   */
/* equal literal of the exec, and possibly a variable passed to a      */
/* function. EXISTS() and SYSDSN() upper-case their argument and only  */
/* read the catalog; what was passed must keep its value.              */
err = 0
e = exists("'brexx.no.such.dsn1'")
call check 'literal, function', "'brexx.no.such.dsn1'",,
                                "'brexx.no.such"||".dsn1'"
call exists "'brexx.no.such.dsn2'"
call check 'literal, CALL',     "'brexx.no.such.dsn2'",,
                                "'brexx.no.such"||".dsn2'"
v = "'brexx.no.such.dsn3'"
e = exists(v)
call check 'variable, function', v, "'brexx.no.such"||".dsn3'"
w = "'brexx.no.such.dsn4'"
call exists w
call check 'variable, CALL',     w, "'brexx.no.such"||".dsn4'"
s = sysdsn("'brexx.no.such.dsn5'")
call check 'SYSDSN literal',    "'brexx.no.such.dsn5'",,
                                "'brexx.no.such"||".dsn5'"
x = "'brexx.no.such.dsn6'"
s = sysdsn(x)
call check 'SYSDSN variable',    x, "'brexx.no.such"||".dsn6'"
say 'Done argkeep.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('ARGKEEP',8) '-' left(what,18) '.. PASS'
else do
   say left('ARGKEEP',8) '-' left(what,18) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
