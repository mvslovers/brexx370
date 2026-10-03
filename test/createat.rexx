say '----------------------------------------'
say 'File createat.rexx'
/* CREATE(dsn, allocation-information) (#299): JCC's fopen applied     */
/* DSORG, RECFM, LRECL, BLKSIZE, PRI, SEC and DIRBLKS; the cc370 build  */
/* dropped them all and created the data set with libc370's defaults.  */
err = 0
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
po = "'BREXX."||VER||".CRATPO'"
ps = "'BREXX."||VER||".CRATPS'"
call remove po                          /* left over from a broken run */
call remove ps
a = 'dsorg=po,recfm=fb,lrecl=80,blksize=3120,pri=1,sec=0,dirblks=2'
call check 'CREATE PO',          create(po, a), 0
call check 'LISTDSI PO',         listdsi(po), 0
call check 'PO dsorg',           sysdsorg, 'PO'
call check 'PO recfm',           sysrecfm, 'FB'
call check 'PO lrecl',           syslrecl, 80
call check 'PO blksize',         sysblksize, 3120
a = 'recfm=vb,lrecl=255,blksize=3120,pri=1,sec=0'
call check 'CREATE PS',          create(ps, a), 0
call check 'LISTDSI PS',         listdsi(ps), 0
call check 'PS dsorg',           sysdsorg, 'PS'
call check 'PS recfm',           sysrecfm, 'VB'
call check 'PS lrecl',           syslrecl, 255
do i = 1 to 10000
   w.i = 'CREATEAT record' right(i, 5, '0')
end
w.0 = 10000
"EXECIO * DISKW" ps "(STEM w."
call check 'one track fills up',  rc, 20
call check 'REMOVE PO',          remove(po), 0
call check 'REMOVE PS',          remove(ps), 0
say 'Done createat.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('CREATEAT',8) '-' left(what,24) '.. PASS'
else do
   say left('CREATEAT',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' got
   say '   want' want
   err = err + 1
end
return
