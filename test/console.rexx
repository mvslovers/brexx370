say '----------------------------------------'
say 'File console.rexx'
/* CONSOLE copied the command into cmd[128] from offset 4 without a   */
/* length check: more than 124 bytes overran the stack (#386). A      */
/* longer command is error 40 now. 'D T' is a harmless display.       */
err = 0
call check 'D T',           console('D T'), 0
call check '124 characters', console(left('D T', 124)), 0
signal on syntax name s1
r = console(copies('X', 200))
say left('CONSOLE',8) '-' left('200 characters',16) '.. *FAIL* no error'
err = err + 1
signal done
s1:
if rc = 40 then say left('CONSOLE',8) '-' left('200 characters',16) '.. PASS'
else do
   say left('CONSOLE',8) '-' left('200 characters',16) '.. *FAIL* rc' rc
   err = err + 1
end
done:
call check 'after',         'LIT', 'LIT'
say 'Done console.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('CONSOLE',8) '-' left(what,16) '.. PASS'
else do
   say left('CONSOLE',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
