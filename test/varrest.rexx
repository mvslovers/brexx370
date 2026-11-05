/* REXX - ECTENVBK is 0 again after the exec ended (#602)             */
/* MVSTEST TSO                                                         */
/* MVSTEST SYSTSIN TSTVPOOL CHKZERO                                    */
/* The TMP starts with ECTENVBK = 0. While the exec runs it has to be  */
/* the exec's ENVBLOCK; after BREXX returned, the next command of the  */
/* TMP (TSTVPOOL CHKZERO, the last command, so its RC is the RC of    */
/* the step) finds the previous value, 0, back. A failure here sets    */
/* ECTENVBK to a foreign value (TSTVPOOL STEAL), which makes CHKZERO   */
/* fail too, so the step RC cannot hide it.                            */
say '----------------------------------------'
say 'File varrest.rexx'
err = 0

address tso 'TSTVPOOL ENVADDR'
env = rc
call check 'ECTENVBK is set while the exec runs', env > 0
address tso 'TSTVPOOL ENV'
call check 'ENVBLOCK, IRXEXTE and IRXEXCOM are reachable, RC' rc, rc = 0

/* a second look must give the same block */
address tso 'TSTVPOOL ENVADDR'
call check 'ECTENVBK does not change during the exec', rc = env

if err then address tso 'TSTVPOOL STEAL'
say 'Done varrest.rexx'
exit err

check:
parse arg what, ok
if ok then say left('VARREST', 8) '-' what '.. PASS'
else do
  say left('VARREST', 8) '-' what '.. *FAIL*'
  err = 1
end
return
