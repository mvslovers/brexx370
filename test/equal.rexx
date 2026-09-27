/* REXX - non-strict comparison ignores trailing blanks (#147)      */
say '----------------------------------------'
say 'File equal.rexx'
err = 0
call check "'abc  ' = 'abc'",     'abc  ' = 'abc',     1
call check "'abc' = 'abc  '",     'abc' = 'abc  ',     1
call check "'  abc  ' = 'abc'",   '  abc  ' = 'abc',   1
call check "'abc  ' \= 'abc'",    'abc  ' \= 'abc',    0
call check "'abc  ' == 'abc'",    'abc  ' == 'abc',    0
call check "'abc ' > 'abc'",      'abc ' > 'abc',      0
call check "'abc ' >= 'abc'",     'abc ' >= 'abc',     1
call check "'abc ' < 'abd'",      'abc ' < 'abd',      1
call check "'ab  c' > 'ab'",      'ab  c' > 'ab',      1
call check "'a b' = 'a  b'",      'a b' = 'a  b',      0
call check "'ab x' < 'abcx'",     'ab x' < 'abcx',     1
call check "'ab' < 'ab  c'",      'ab' < 'ab  c',      1
call check "left('END',80) = 'END'", left('END',80) = 'END', 1
call check "' ' = ''",            ' ' = '',            1
call check "'1 ' = 1",            '1 ' = 1,            1
say 'Done equal.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('EQUAL',8) '-' left(what,28) '.. PASS'
else do
   say left('EQUAL',8) '-' left(what,28) '.. *FAIL* got' got
   err = err + 1
end
return
