say '----------------------------------------'
say 'File argkeep.rexx'
/* A built-in that upper-cases its argument in place (Lupper(ARGn))    */
/* changed what the caller passed (#305): a literal, shared by every   */
/* equal literal of the exec, and a variable passed to a function.     */
/* Each must keep its value; the built-ins here only read things.      */
err = 0
s = sysvar('sysenv')
call check 'literal, function', 'sysenv', 'sys'||'env'
call sysvar 'sysuid'
call check 'literal, CALL',     'sysuid', 'sys'||'uid'
v = 'sysenv'
s = sysvar(v)
call check 'variable, function', v, 'sys'||'env'
w = 'sysenv'
call sysvar w
call check 'variable, CALL',     w, 'sys'||'env'
m = 'sysname'
s = mvsvar(m)
call check 'MVSVAR variable',    m, 'sys'||'name'
s = exists("'brexx.no.such.dsn'")
call check 'EXISTS literal',     "'brexx.no.such.dsn'",,
                                 "'brexx.no.such"||".dsn'"
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
