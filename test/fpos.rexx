say '----------------------------------------'
say 'File fpos.rexx'
/* FPOS searched from a start past the end of the string, i.e. in the  */
/* storage behind it (#386); such a start is "not found" now.          */
err = 0
call check 'start 3',        fpos('c', 'abc', 3), 3
call check 'start = end+1',  fpos('c', 'abc', 4), 0
call check 'start past',     fpos('b', 'abc', 10), 0
call check 'start 0',        fpos('a', 'abc', 0), 1
call check 'no start',       fpos('bc', 'abcbc'), 2
say 'Done fpos.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('FPOS',8) '-' left(what,16) '.. PASS'
else do
   say left('FPOS',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
