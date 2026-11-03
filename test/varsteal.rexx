/* REXX - a foreign ECTENVBK is left alone (#602)                      */
/* MVSTEST TSO                                                         */
/* MVSTEST SYSTSIN TSTVPOOL CHKSENT                                    */
/* While the exec runs, another program takes ECTENVBK (TSTVPOOL STEAL */
/* stores the address of the CVT as a marker). At its end the exec     */
/* restores the previous value only if ECTENVBK is still its own       */
/* block, so the marker has to stay. CHKSENT, the last command, ends   */
/* with RC 0 if it does. A failure here sets ECTENVBK to 0, which     */
/* makes CHKSENT fail as well.                                         */
say '----------------------------------------'
say 'File varsteal.rexx'
err = 0
address tso 'TSTVPOOL ENVADDR'
env = rc
call check 'ECTENVBK is set while the exec runs', env > 0
address tso 'TSTVPOOL STEAL'
call check 'the marker was stored, RC' rc, rc = 0
address tso 'TSTVPOOL ENVADDR'
call check 'ECTENVBK is the marker', rc \= env & rc > 0
if err then address tso 'TSTVPOOL ZAP'
say 'Done varsteal.rexx'
exit err

check:
parse arg what, ok
if ok then say left('VARSTEAL', 8) '-' what '.. PASS'
else do
  say left('VARSTEAL', 8) '-' what '.. *FAIL*'
  err = 1
end
return
