say '----------------------------------------'
say 'File pwdopen.rexx'
/* A password protected data set in batch: the open asked for the    */
/* password, got none and abended S913-0C, ending the exec (#294).    */
/* Now every function that opens it fails the way it does for a       */
/* missing one, and SYSDSN says PROTECTED DATASET, as TSO/E does.     */
/* NJE38's spool is password protected on mvsdev; on a stand where it */
/* is not, there is nothing to measure and the checks pass.           */
err = 0
dsn = 'PUB001.NJE38.NETSPOOL.DATA'
qdsn = "'"dsn"'"
s = sysdsn(qdsn)
say left('PWDOPEN',8) '- SYSDSN' s
if s \= 'PROTECTED DATASET' then do
   say left('PWDOPEN',8) '-' dsn 'not password protected here .. PASS'
   exit 0
end
call check 'LISTDSIQ',        listdsiq(dsn), 16
call check 'LISTDSI',         listdsi(qdsn), 16
call check 'EXISTS',          exists(qdsn), 0
drop r.
"EXECIO 1 DISKR" qdsn "(STEM r."
call check 'EXECIO DISKR rc', rc, 8
call check 'OPEN read',       open(qdsn, 'R'), -1
say 'Done pwdopen.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('PWDOPEN',8) '-' left(what,16) '.. PASS'
else do
   say left('PWDOPEN',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
