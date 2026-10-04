say '----------------------------------------'
say 'File authwto.rexx'
/* SYSVAR('SYSAUTH'), PRIVILEGE() and WTO() (#298): they went through */
/* compat's _testauth(), _modeset() and _write2op(), now libc370's    */
/* __isauth(), __super()/__prob() and wto() directly.                 */
err = 0
native = sysvar('SYSAUTH')
call check 'SYSAUTH native', native = 0 | native = 1, 1
p = privilege('ON')
if p \= 0 then do
   say left('AUTHWTO',8) '- privilege(ON) refused, rc' p '.. *FAIL*'
   exit 3
end
call check 'SYSAUTH on',      sysvar('SYSAUTH'), 1
call privilege 'OFF'           /* answers 8 even when it worked */
call check 'SYSAUTH off',     sysvar('SYSAUTH'), native
call check 'WTO',             wto('BRX0000I AUTHWTO TEST MESSAGE'), 0
say 'Done authwto.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('AUTHWTO',8) '-' left(what,16) '.. PASS'
else do
   say left('AUTHWTO',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
