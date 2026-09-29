say '----------------------------------------'
say 'File lines.rexx'
/* LINES: lines left from the read position */
err = 0
nl = '15'x                       /* '\n' in the byte view (EBCDIC NL) */
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('ofile',"'BREXX."||VER||".TESTS(LNSTMP)'")
IF F >= 4 THEN return 8
file = OPEN('ofile',"W")
do n = 1 to 5
  call lineout file, "Line" n
end
call lineout file
call check 'lines() 5', lines(file), 5
do n = 4 to 0 by -1
  call linein file
  call check 'lines()' n, lines(file), n
end
call linein file
call check 'lines() past the end', lines(file), 0
call close file
say 'Done lines.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('LINES',8) '-' left(what,24) '.. PASS'
else do
   say left('LINES',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' c2x(got)
   say '   want' c2x(want)
   err = err + 1
end
return
