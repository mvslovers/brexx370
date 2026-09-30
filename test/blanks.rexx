say '----------------------------------------'
say 'File blanks.rexx'
/* REXX separates words by blanks only (TSO/E, #212). TAB '05'x and
   NL '15'x are ordinary characters in words, comparisons and numbers */
err = 0
tab = '05'x; nl = '15'x
call check 'WORDS tab',     words('a'tab'b c'),            2
call check 'WORD nl',       word('a b'nl'c', 2),           'b'nl'c'
call check 'WORDPOS',       wordpos('b'tab'c', 'a b'tab'c'), 2
call check 'SPACE',         space(' a'tab'b  c '),         'a'tab'b c'
call check 'blank = ',      'abc  ' = 'abc',               1
call check 'tab = ',        'abc'tab = 'abc',              0
call check 'DATATYPE blank', datatype(' 12 '),             'NUM'
call check 'DATATYPE nl',   datatype('12'nl),              'CHAR'
call check 'X2C blanks',    x2c('C1 C2'),                  'AB'
call check 'PARSE tab',     ptab('x'tab'y z'),             'x'tab'y/z'
say 'Done blanks.rexx'
exit err

ptab: parse arg p1 p2
      return p1'/'p2

check:
parse arg what, got, want
if got == want then say left('BLANKS',8) '-' left(what,14) '.. PASS'
else do
   say left('BLANKS',8) '-' left(what,14) '.. *FAIL* got "'c2x(got)'"',
       'want "'c2x(want)'"'
   err = err + 1
end
return
