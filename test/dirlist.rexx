say '----------------------------------------'
say 'File dirlist.rexx'
/* The directory of a PDS (#144): DIR(), LOCATE() and LISTDSI read it  */
/* with JCC fopen options libc370 never saw, and got 0 entries for a   */
/* load library and some thousand for an FB PDS. mvstest.py fills in  */
/* the step's libraries: the RXLIB holds exactly RTEST, the LINKLIB    */
/* the six modules plus BREXX's aliases REXX and RX.                   */
err = 0
rxlib = "'BREXX.RXLIB'"
lnk   = "'BREXX.LINKLIB'"
call check 'DIR RXLIB rc',       dir(rxlib), 0
call check 'DIR RXLIB count',    direntry.0, 1
call check 'DIR RXLIB name',     direntry.1.name, 'RTEST'
call check 'DIR LINKLIB rc',     dir(lnk), 0
call check 'DIR LINKLIB count',  direntry.0, 7
names = ''
do i = 1 to direntry.0
   names = names direntry.i.name
end
call check 'DIR LINKLIB names',  space(names), ,
           'BREXX IRXVSMIO IRXVSMTR IRXVTOC MVSDUMP REXX RX'
call check 'DIR missing',        dir("'BREXX.NO.SUCH.PDS'"), 8
call check 'LOCATE found',       locate(rxlib, 'RTEST'), 0
call check 'LOCATE missing',     locate(rxlib, 'NOSUCH'), 8
call check 'LOCATE alias',       locate(lnk, 'RX'), 0
call check 'LOCATE DD',          locate('RXLIB', 'RTEST', 'FILE'), 0
call check 'LOCATE no PDS',      locate("'BREXX.NO.SUCH.PDS'", 'X'), 12
call check 'LISTDSI RXLIB',      listdsi(rxlib), 0
call check 'LISTDSI members',    sysmembers, 1
say 'Done dirlist.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('DIRLIST',8) '-' left(what,24) '.. PASS'
else do
   say left('DIRLIST',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' got
   say '   want' want
   err = err + 1
end
return
