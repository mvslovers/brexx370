say '----------------------------------------'
say 'File rotate.rexx'
/* ROTATE: a start that is a multiple of the length gave offset -1 and */
/* copied from the byte before the string; a length over the string's  */
/* set LLEN past the buffer (#386). The result runs on from the start  */
/* of the string as often as the length needs.                         */
err = 0
s = '1234567890ABCDEF'
call check 'docs 10,10',       rotate(s, 10, 10), '0ABCDEF123'
call check 'docs 1',           rotate(s, 1), s
call check 'docs 5',           rotate(s, 5), '567890ABCDEF1234'
call check 'start = length',   rotate('ABCD', 4), 'DABC'
call check 'start = 2*length', rotate('ABCD', 8), 'DABC'
call check 'start > length',   rotate('ABCD', 6), 'BCDA'
call check 'length > string',  rotate('ABCD', 2, 10), 'BCDABCDABC'
call check 'shorter length',   rotate('ABCD', 3, 2), 'CD'
call check 'empty string',     rotate('', 3), ''
say 'Done rotate.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('ROTATE',8) '-' left(what,16) '.. PASS'
else do
   say left('ROTATE',8) '-' left(what,16) '.. *FAIL* got' c2x(got),
       'want' c2x(want)
   err = err + 1
end
return
