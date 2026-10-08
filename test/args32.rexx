say '----------------------------------------'
say 'File args32.rexx'
/* A call with more than 32 arguments overwrote the first literal of  */
/* its clause: the bitmask of present arguments has 32 bits, MAXARGS  */
/* was 99 (#384). 32 arguments work; a 33rd is Error 40 now. The 33   */
/* argument calls run through INTERPRET: they no longer compile.      */
err = 0
a32 = copies('1,', 31)'1'
a33 = copies('1,', 32)'1'
interpret "r = 'LIT' a("a32")"
call check 'function, 32 arguments', r, 'LIT 32'
interpret "call a" a32
call check 'CALL, 32 arguments', result, 32
call e40 'function, 33 arguments', "r = 'LIT' a("a33")"
call e40 'CALL, 33 arguments', 'call a' a33
call e40 'omitted, 33rd given', "r = a("copies(',', 32)"1)"
call check 'literal after the calls', 'LIT', 'LIT'
say 'Done args32.rexx'
exit err

a: return arg()

check:
parse arg what, got, want
if got == want then say left('ARGS32',8) '-' left(what,26) '.. PASS'
else do
   say left('ARGS32',8) '-' left(what,26) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return

e40: procedure expose err
parse arg what, stmt
signal on syntax name e40x
interpret stmt
say left('ARGS32',8) '-' left(what,26) '.. *FAIL* no error'
err = err + 1
return
e40x:
if rc = 40 then say left('ARGS32',8) '-' left(what,26) '.. PASS'
else do
   say left('ARGS32',8) '-' left(what,26) '.. *FAIL* rc' rc
   err = err + 1
end
return
