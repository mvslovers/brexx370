say '----------------------------------------'
say 'File openat.rexx'
/* OPEN(dsn, 'W', allocation-information) (#299): a data set that does */
/* not exist is created with the given attributes first; one that does */
/* keeps its own. The allocation information was never applied before. */
err = 0
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
ps  = "'BREXX."||VER||".OPENATPS'"
po  = "'BREXX."||VER||".OPENATPO'"
pom = "'BREXX."||VER||".OPENATPO(MEMBER1)'"
call remove ps                          /* left over from a broken run */
call remove po
f = open(ps, 'W', 'recfm=fb,lrecl=80,blksize=800,pri=1,sec=1')
call check 'OPEN new PS',        f >= 0, 1
call lineout f, 'OPENAT line 1'
call close f
call check 'LISTDSI PS',         listdsi(ps), 0
call check 'PS recfm',           sysrecfm, 'FB'
call check 'PS lrecl',           syslrecl, 80
call check 'PS blksize',         sysblksize, 800
f = open(ps, 'W', 'recfm=vb,lrecl=255,blksize=3120')
call check 'OPEN existing',      f >= 0, 1
call close f
call listdsi ps
call check 'existing kept FB',   sysrecfm, 'FB'
f = open(pom, 'W', 'recfm=fb,lrecl=80,blksize=3120')
call check 'OPEN new member',    f >= 0, 1
call lineout f, 'OPENAT member'
call close f
call check 'LISTDSI PO',         listdsi(po), 0
call check 'PO dsorg',           sysdsorg, 'PO'
call check 'PO members',         sysmembers, 1
call check 'bad allocation',     open("'BREXX.OPENAT.BAD'", 'W', 'xyz=1'), -1
call check 'REMOVE PS',          remove(ps), 0
call check 'REMOVE PO',          remove(po), 0
say 'Done openat.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('OPENAT',8) '-' left(what,24) '.. PASS'
else do
   say left('OPENAT',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' got
   say '   want' want
   err = err + 1
end
return
