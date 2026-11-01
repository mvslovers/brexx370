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
/* Receives that end at once, one after the other. The subtask looks at  */
/* its flag every 25 ms; if that falls into the moment a receive is on,   */
/* it authorizes the step although the receive is over before the take is */
/* done, and nobody posts it. SYSAUTH is read as soon as each call        */
/* returns. A probe: a failure shows the race, a pass is a statement      */
/* about this many calls only.                                            */
bad = 0
n   = 0
t0  = time('E')
do while time('E') - t0 < 8
   if __njereceive(1) <> 3 then bad = bad + 1
   if sysvar('SYSAUTH') <> before then bad = bad + 1
   n = n + 1
end
say left('NJEAUTH',8) '-' n 'receives of 1 ms in 8 s, bad' bad
call check 'tight receives',   bad,                         0
call check 'auth tight',       sysvar('SYSAUTH'),           before
/* a message to oneself needs the receive to be authorized: it only */
/* runs under a TMP, in plain batch the NJE38 command is not found  */
s = __njesend(sysvar('SYSNODE'), me, 'LOOP BACK')
if s = -3 then say left('NJEAUTH',8) '- loopback .. SKIPPED (no TMP)'
else do
   call check 'loopback send',    s,                           0
   call check 'loopback receive', __njereceive(5000),          1
   call check 'loopback data',    pos('LOOP BACK', _data) > 0, 1
   call check 'auth loopback',    sysvar('SYSAUTH'),           before
   /* receives that end just as the subtask turns to the next wait:    */
   /* alternately with a message at once and a timeout; the step must  */
   /* be as it was after every one, also a moment later                */
   bad = 0
   what = ''
   do i = 1 to 30
      if i // 2 = 0 then do
         if __njesend(sysvar('SYSNODE'), me, 'ROUND' i) <> 0 then do
            bad = bad + 1; what = what 'S'i
         end
         want = 1
         t = 3000
      end
      else do
         want = 3
         t = 100
      end
      got = __njereceive(t)
      if got <> want then do
         bad = bad + 1; what = what 'R'i':'got'/'want
      end
      if sysvar('SYSAUTH') <> before then do
         bad = bad + 1; what = what 'A'i
      end
      call wait 30
      if sysvar('SYSAUTH') <> before then do
         bad = bad + 1; what = what 'B'i
      end
   end
   if bad > 0 then say left('NJEAUTH',8) '- rounds:' what
   call check 'receive rounds',   bad,                         0
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
