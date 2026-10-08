say '----------------------------------------'
say 'File join.rexx'
/* JOIN read both strings up to the longer length, past the end of    */
/* the shorter one (#386). Past the string's end a join character of  */
/* the target stays; past the target's end the string is appended, as */
/* the docs say.                                                       */
err = 0
t = 'NAME=        CITY=          '
r = join('     PETER        MUNICH', t)
call check 'docs example',    r, left('NAME=PETER   CITY=MUNICH', length(t))
call check 'string longer',   join('ABCDEFGH', 'x  '), 'xBCDEFGH'
call check 'target longer',   join('AB', '    '), 'AB  '
call check 'same length',     join('ABC', 'x z'), 'xBz'
call check 'join table',      join('ABC', 'x-z', '-'), 'xBz'
call check 'empty string',    join('', 'abc'), 'abc'
say 'Done join.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('JOIN',8) '-' left(what,16) '.. PASS'
else do
   say left('JOIN',8) '-' left(what,16) '.. *FAIL* got' c2x(got),
       'want' c2x(want)
   err = err + 1
end
return
