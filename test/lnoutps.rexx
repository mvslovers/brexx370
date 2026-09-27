say '----------------------------------------'
say 'File lnoutps.rexx'
/* LINEOUT on a sequential data set: append, implicit open */
err = 0
nl = '15'x                       /* '\n' in the byte view (EBCDIC NL) */
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('psdd',"'BREXX."||VER||".TESTSEQ'")
IF F >= 4 THEN return 8
file = OPEN('psdd',"W")
do n = 1 to 3
  call lineout file, "Line" n
end
call check 'linein() 1', linein(file), pad('Line 1')
/* the write position stays at the end while reading */
call check 'append after read', lineout(file, "Line 4"), 0
call check 'lines() from 2', lines(file), 3
call check 'linein(,4)', linein(file,4), pad('Line 4')
call close file
/* no OPEN: LINEOUT opens the existing data set without truncating */
/* it and writes at its end                                         */
call check 'implicit lineout rc', lineout('psdd', "Line 5"), 0
call close 'psdd'
f = OPEN('psdd',"R")
call check 'lines() after implicit', lines(f), 5
call check 'linein(,1) kept', linein(f,1), pad('Line 1')
call check 'linein(,5) appended', linein(f,5), pad('Line 5')
call close f
say 'Done lnoutps.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('LNOUTPS',8) '-' left(what,24) '.. PASS'
else do
   say left('LNOUTPS',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' c2x(got)
   say '   want' c2x(want)
   err = err + 1
end
return

pad: return left(arg(1), 80)     /* an FB80 record as LINEIN sees it */
