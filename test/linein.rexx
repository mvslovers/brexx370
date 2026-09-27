say '----------------------------------------'
say 'File linein.rexx'
/* LINEIN: FB records keep their trailing blanks (#146) */
err = 0
nl = '15'x                       /* '\n' in the byte view (EBCDIC NL) */
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('ofile',"'BREXX."||VER||".TESTS(LITMP)'")
IF F >= 4 THEN return 8
file = OPEN('ofile',"W")
do n = 1 to 5
  call lineout file, "Line" n
end
call lineout file
do n = 1 to 5
  call check 'linein()' n, linein(file), pad('Line' n)
end
call check 'linein() at the end', linein(file), ''
call check 'linein(,3)', linein(file,3), pad('Line 3')
call check 'next after (,3)', linein(file), pad('Line 4')
call check 'length(linein(,1))', length(linein(file,1)), 80
call check 'linein(,1) = text', linein(file,1) = 'Line 1', 1
two = pad('Line 2')nl||pad('Line 3')    /* BREXX: count > 1 */
call check 'linein(,2,2)', linein(file,2,2), two
call check 'linein(,6) past end', linein(file,6), ''
call close file
say 'Done linein.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('LINEIN',8) '-' left(what,24) '.. PASS'
else do
   say left('LINEIN',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' c2x(got)
   say '   want' c2x(want)
   err = err + 1
end
return

pad: return left(arg(1), 80)     /* an FB80 record as LINEIN sees it */
