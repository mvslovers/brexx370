say '----------------------------------------'
say 'File listdsi.rexx'
/* LISTDSI() (#170): a name that does not fit gave '' instead of 16, */
/* "dd FILE" checked the length of the whole argument (so any DD     */
/* name of 5+ characters failed), and an unquoted name without a     */
/* prefix (batch) became empty. RXLIB is a PDS DD of every step.     */
err = 0
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
tlib  = "'BREXX."||VER||".TESTS'"
tlibm = "'BREXX."||VER||".TESTS(LISTDSI)'"
n54 = "'"left('A.B',44,'C')"(MEMBER01)'"     /* 54 characters */
n55 = "'"left('A.B',45,'C')"(MEMBER01)'"     /* 55 characters */
call check 'existing',            listdsi(tlib), 0
call check 'existing member',     listdsi(tlibm), 0
call check 'missing',             listdsi("'BREXX.NO.SUCH.DSN'"), 16
call check 'partially quoted',    listdsi("'BREXX.HALF"), 16
call check 'DD, short name',      listdsi('RXLIB FILE'), 0
if sysvar('SYSPREF') == '' then
   call check 'unquoted, no prefix', listdsi(strip(tlib,,"'")), 0
call check '55 chars',            listdsi(n55), 16
call check '300 chars',           listdsi("'"copies('A',300)"'"), 16
/* DSORG and volume from the data set itself (#299): the JCC layer took */
/* DSORG from a member name in the call, so a PDS read as PS, and gave  */
/* no volume. TESTSEQ is a sequential data set of mvstest.py.           */
seq = "'BREXX."||VER||".TESTSEQ'"
drop sysdsorg sysvolume sysmembers
call check 'PDS rc',              listdsi(tlib), 0
call check 'PDS dsorg',           sysdsorg, 'PO'
call check 'PDS volume set',      datatype(sysvolume, 'A') & ,
                                  length(sysvolume) = 6, 1
call check 'PDS members > 100',   sysmembers > 100, 1
drop sysdsorg sysvolume
call check 'PS rc',               listdsi(seq), 0
call check 'PS dsorg',            sysdsorg, 'PS'
call check 'PS volume set',       length(sysvolume) = 6, 1
drop sysdsorg sysmember
call check 'member rc',           listdsi(tlibm), 0
call check 'member dsorg',        sysdsorg, 'PO'
call check 'member name',         sysmember, 'LISTDSI'
drop sysdsorg sysmembers
call check 'DD PDS rc',           listdsi('RXLIB FILE'), 0
call check 'DD PDS dsorg',        sysdsorg, 'PO'
call check 'DD PDS members',      sysmembers, 1
say 'Done listdsi.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('LISTDSI',8) '-' left(what,24) '.. PASS'
else do
   say left('LISTDSI',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' left(got,60)
   say '   want' left(want,60)
   err = err + 1
end
return
