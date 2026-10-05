say '----------------------------------------'
say 'File tsoenv.rexx'
/* The SYSVAR values src/tsoenv.c reads from the control blocks (it was */
/* the module RXINIT until #353). Under TSO, SYSUID is the user id in   */
/* the background too: RXINIT read a TCB field as ACEE there and        */
/* SYSUID was empty. Batch has no TSO values.                           */
err = 0
if sysvar('SYSTSO') \= 1 then do
   call check 'batch SYSENV',  sysvar('SYSENV'), ''
   call check 'batch SYSUID',  sysvar('SYSUID'), ''
end
else do
   call check 'SYSUID',        sysvar('SYSUID'), userid()
   call check 'SYSENV',        wordpos(sysvar('SYSENV'), 'FORE BACK') > 0, 1
   i = sysvar('SYSISPF')
   call check 'SYSISPF',       i = 'ACTIVE' | i = 'NOT ACTIVE', 1
end
say 'Done tsoenv.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('TSOENV',8) '-' left(what,16) '.. PASS'
else do
   say left('TSOENV',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = 8
end
return
