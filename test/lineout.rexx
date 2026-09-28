say '----------------------------------------'
say 'File lineout.rexx'
/* LINEOUT: returns lines not written; no string, no write */
err = 0
nl = '15'x                       /* '\n' in the byte view (EBCDIC NL) */
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('ofile',"'BREXX."||VER||".TESTS(LOTMP)'")
IF F >= 4 THEN return 8
file = OPEN('ofile',"W")
call check 'lineout() rc', lineout(file, "Line 1"), 0
do n = 2 to 5
  call lineout file, "Line" n
end
/* LINEOUT(name) flushes and moves the write position to the end, */
/* it does not write an empty line                                  */
call check 'lineout(file) rc', lineout(file), 0
call check 'lines() still 5', lines(file), 5
do n = 1 to 5
  call check 'linein()' n, linein(file), pad('Line' n)
end
call check 'linein() at the end', linein(file), ''
call close file
say 'Done lineout.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('LINEOUT',8) '-' left(what,24) '.. PASS'
else do
   say left('LINEOUT',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' c2x(got)
   say '   want' c2x(want)
   err = err + 1
end
return

pad: return left(arg(1), 80)     /* an FB80 record as LINEIN sees it */
