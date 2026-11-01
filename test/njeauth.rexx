say '----------------------------------------'
say 'File njeauth.rexx'
/* The NJE38 functions get their authorization from SVC 244 (#505), for */
/* the duration of a call, and do not need an APF authorized BREXX.     */
/* Without READ on FACILITY SVC244 (and without APF) __NJEREGISTER and  */
/* __NJESEND return -5 and print a message instead of ending in S047;   */
/* with it, a receive that waits in the subtask leaves the job step as  */
/* it found it. Needs the NJE38 started task, which is why it skips.    */
/* MVSTEST TSO                                                          */
err = 0
me = userid()
signal on syntax name noNje
call __njeinit
signal off syntax

before = sysvar('SYSAUTH')
r = __njeregister(me)
if r = -5 then do
   /* a user without READ: refused, nothing registered, no abend */
   call check 'send refused',     __njesend('MVSA', me, 'X'),  -5
   call check 'dereg unknown',    __njederegister(me),         28
   call check 'auth unchanged',   sysvar('SYSAUTH'),           before
   say left('NJEAUTH',8) '- no READ on FACILITY SVC244 .. rest SKIPPED'
   say 'Done njeauth.rexx'
   exit err
end
call check 'register',         r,                           0
call check 'auth registered',  sysvar('SYSAUTH'),           before
call check 'receive 1',        __njereceive(300),           3
call check 'auth receive 1',   sysvar('SYSAUTH'),           before
call check 'receive 2',        __njereceive(300),           3
call check 'auth receive 2',   sysvar('SYSAUTH'),           before
/* a message to oneself needs the receive to be authorized: it only */
/* runs under a TMP, in plain batch the NJE38 command is not found  */
s = __njesend(sysvar('SYSNODE'), me, 'LOOP BACK')
if s = -3 then say left('NJEAUTH',8) '- loopback .. SKIPPED (no TMP)'
else do
   call check 'loopback send',    s,                           0
   call check 'loopback receive', __njereceive(5000),          1
   call check 'loopback data',    pos('LOOP BACK', _data) > 0, 1
   call check 'auth loopback',    sysvar('SYSAUTH'),           before
end
call check 'dereg',            __njederegister(me),         0
call check 'auth dereg',       sysvar('SYSAUTH'),           before
call check 'receive stopped',  __njereceive(300),           2
call check 'auth stopped',     sysvar('SYSAUTH'),           before
say 'Done njeauth.rexx'
exit err

noNje:
signal off syntax
say left('NJEAUTH',8) '- NJE38 is not active or NJERLY is missing' ,
    '.. SKIPPED (rest)'
say 'Done njeauth.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('NJEAUTH',8) '-' left(what,16) '.. PASS'
else do
   say left('NJEAUTH',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
