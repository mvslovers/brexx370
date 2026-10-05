say '----------------------------------------'
say 'File strfunc.rexx'
/* The string functions registered by RxStrRegFunctions() (rxstr.c,  */
/* moved from rxmvs.c in #302). One call each, so a lost             */
/* registration shows up as a failed check, not as a missing test.   */
err = 0
call check 'UPPER',          upper('abc'), 'ABC'
call check 'LOWER',          lower('AbC'), 'abc'
call check 'LASTWORD',       lastword('one two three'), 'three'
call check 'LASTWORD 2',     lastword('one two three', 2), 'two'
call check 'LASTWORD none',  lastword('a b', 5), ''
call check 'JOIN',           join('abcdef', '12 4  '), '12c4ef'
n = split('a,b,,c', 'w.', ',')
call check 'SPLIT',          n w.0 w.1 w.3, '3 3 a c'
call check 'FPOS',           fpos('lo', 'hello world'), 4
call check 'FPOS start',     fpos('o', 'hello world', 6), 8
call check 'FPOS none',      fpos('x', 'hello'), 0
call check 'FCHANGESTR',     fchangestr('o', 'foo boo', '0'), 'f00 b00'
call check 'QUOTE',          quote('abc'), "'abc'"
call check 'CHAR',           char('hello', 2), 'e'
call check 'CHAR pad',       char('ab', 5, '*'), '*'
call check 'C2U',            c2u('0102'x), 258
call check 'C2U max',        c2u('FFFFFFFF'x), '4294967295'
call check 'E2A',            c2x(e2a('C1'x)), '41'
call check 'A2E',            c2x(a2e('41'x)), 'C1'
call check 'MASKBLK',        maskblk('a "b c" d', '"', '_'), 'a "b_c" d'
call check 'LCS',            lcs('ABCBDAB', 'BDCABA'), 'BCBA'
say 'Done strfunc.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('STRFUNC',8) '-' left(what,16) '.. PASS'
else do
   say left('STRFUNC',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
