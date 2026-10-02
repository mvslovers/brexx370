say '----------------------------------------'
say 'File sysdsn.rexx'
/* SYSDSN() (#170): the name went into sDSName[45] and the message    */
/* into sMessage[256] without a length check, and an unquoted name   */
/* without a prefix (batch) became empty. Controls first: the        */
/* overflow cases may abend the step on a build without the fix.     */
err = 0
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
tlib  = "'BREXX."||VER||".TESTS'"
tlibm = "'BREXX."||VER||".TESTS(SYSDSN)'"
inv   = 'INVALID DATASET NAME, '
nf    = 'DATASET NOT FOUND'
n54   = "'"left('A.B',44,'C')"(MEMBER01)'"   /* 54 characters */
n55   = "'"left('A.B',45,'C')"(MEMBER01)'"   /* 55 characters */
call check 'existing',            sysdsn(tlib), 'OK'
call check 'existing member',     sysdsn(tlibm), 'OK'
call check 'missing',             sysdsn("'BREXX.NO.SUCH.DSN'"), nf
call check 'empty',               sysdsn(''), 'MISSING DATASET NAME'
call check 'partially quoted',    sysdsn("'BREXX.HALF"), inv"'BREXX.HALF"
if sysvar('SYSPREF') == '' then
   call check 'unquoted, no prefix', sysdsn(strip(tlib,,"'")), 'OK'
call check '44 + member',         sysdsn(n54), nf
call check '55 chars',            left(sysdsn(n55),22), inv
call check '300, partially',      left(sysdsn("'"copies('A',300)),22), inv
call check '300 chars',           left(sysdsn("'"copies('A',300)"'"),22), inv
say 'Done sysdsn.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('SYSDSN',8) '-' left(what,24) '.. PASS'
else do
   say left('SYSDSN',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' left(got,60)
   say '   want' left(want,60)
   err = err + 1
end
return
