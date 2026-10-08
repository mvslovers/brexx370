say '----------------------------------------'
say 'File extfun.rexx'
/* An external function (a load module, TSTEFUN of the TESTLIB) got  */
/* an omitted argument as strlen(NULL), and more than 15 arguments   */
/* ran past args[] and the argument table (#386). TSTEFUN returns    */
/* the number of table entries and N/E/V for each: address 0, length */
/* 0, a value. An omitted argument is now length 0 at an address.    */
err = 0
call check 'no arguments',   tstefun(), '000'
call check 'three',          tstefun('a', 'bb', 'c'), '003VVV'
call check 'empty one',      tstefun('a', '', 'c'), '003VEV'
call check 'omitted one',    tstefun('a', , 'c'), '003VEV'
call check 'omitted last',   tstefun('a', ), '001V'
a16 = copies("'x',", 15)"'x'"
interpret 'r = tstefun('a16')'
call check '16 arguments',   r, '016'copies('V', 16)
a32 = copies("'x',", 31)"'x'"
interpret 'r = tstefun('a32')'
call check '32 arguments',   r, '032'copies('V', 32)
call check 'literal after',  'LIT', 'LIT'
say 'Done extfun.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('EXTFUN',8) '-' left(what,16) '.. PASS'
else do
   say left('EXTFUN',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
