say '----------------------------------------'
say 'File chars.rexx'
/* CHARS: characters left from the read position */
err = 0
nl = '15'x                       /* '\n' in the byte view (EBCDIC NL) */
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('ofile',"'BREXX."||VER||".TESTS(CHRTMP)'")
IF F >= 4 THEN return 8
file = OPEN('ofile',"W")
call lineout file, "Line 1"
call lineout file, "Line 2"
call lineout file
call check 'chars() 2 records', chars(file), 162
call charin file, 30
call check 'chars() after byte 30', chars(file), 132
call close file
say 'Done chars.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('CHARS',8) '-' left(what,24) '.. PASS'
else do
   say left('CHARS',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' c2x(got)
   say '   want' c2x(want)
   err = err + 1
end
return
