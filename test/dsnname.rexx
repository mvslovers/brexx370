say '----------------------------------------'
say 'File dsnname.rexx'
/* getDatasetName() (#283): EXISTS() builds the data set name into a  */
/* 55-byte buffer. A name that does not fit, or a lone quote, must be */
/* rejected (-1, like a partially quoted name) instead of overflowing */
/* the caller's stack. The controls first: the overflow cases may     */
/* abend the step on a build without the length check.                */
err = 0
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
say 'DSNNAME  - SYSPREF "'sysvar('SYSPREF')'"'
tlib = "'BREXX."||VER||".TESTS'"
call check 'existing, quoted',    exists(tlib), 1
call check 'missing, quoted',     exists("'BREXX.NO.SUCH.DSN'"), 0
call check 'partially quoted',    exists("'BREXX.HALF"), -1
call check '54 chars, quoted',    exists("'"left('A.B',44,'C')"(MEMBER01)'"), 0
call check '55 chars, quoted',    exists("'"left('A.B',45,'C')"(MEMBER01)'"), -1
call check '300 chars, quoted',   exists("'"copies('A',300)"'"), -1
call check 'lone quote',          exists("'"), -1
/* Unquoted without a prefix (batch: SYSPREF is empty): the name as   */
/* it stands, as TSO/E and EXECIO do; it gave an empty name (#283).    */
if sysvar('SYSPREF') == '' then do
   call check 'unquoted, no prefix', exists(strip(tlib,,"'")), 1
   call check 'unquoted, missing',   exists('BREXX.NO.SUCH.DSN'), 0
   call check 'unquoted, 55 chars',  exists(left('A.B',45,'C')'(MEMBER01)'), -1
end
say 'Done dsnname.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('DSNNAME',8) '-' left(what,24) '.. PASS'
else do
   say left('DSNNAME',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' got
   say '   want' want
   err = err + 1
end
return
