say '----------------------------------------'
say 'File execdsn.rexx'
/* EXECIO with a data set name instead of a DD (#299: its open moved   */
/* from jcc_fopen() to dsio). Quoted, and unquoted without a prefix    */
/* (batch), which EXECIO first tries as a DD name.                     */
err = 0
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
mem = "'BREXX."||VER||".TESTS(EXECTMP)'"
w.1 = 'EXECDSN 1'; w.2 = 'EXECDSN 2'; w.3 = 'EXECDSN 3'; w.0 = 3
"EXECIO * DISKW" mem "(STEM w."
call check 'DISKW quoted', rc, 0
drop r.
"EXECIO * DISKR" mem "(STEM r."
call check 'DISKR quoted', rc, 0
call check 'count', r.0, 3
call check 'last', strip(r.3), 'EXECDSN 3'
a.1 = 'EXECDSN 4'; a.0 = 1
"EXECIO * DISKA" mem "(STEM a."
call check 'DISKA quoted', rc, 0
if sysvar('SYSPREF') == '' then do
   drop r.
   "EXECIO * DISKR" strip(mem,,"'") "(STEM r."
   call check 'DISKR unquoted', rc, 0
   call check 'count after DISKA', r.0, 4
   call check 'appended', strip(r.4), 'EXECDSN 4'
end
drop r.
"EXECIO * DISKR 'BREXX.NO.SUCH.DSN' (STEM r."
call check 'missing data set', rc, 8
say 'Done execdsn.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('EXECDSN',8) '-' left(what,24) '.. PASS'
else do
   say left('EXECDSN',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' got
   say '   want' want
   err = err + 1
end
return
