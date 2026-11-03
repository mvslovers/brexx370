/* REXX - a nested exec restores the previous ENVBLOCK (#602)         */
/* MVSTEST TSO                                                         */
/* MVSTEST SYSTSIN TSTVPOOL CHKZERO                                    */
/* The outer exec starts a second BREXX with the TSO command BREXX.   */
/* While that one runs, ECTENVBK may be another block; when it ended,  */
/* ECTENVBK is the outer exec's block again, which is not 0, so this   */
/* is the case "previous value not 0". The inner exec ends with RC 7   */
/* (8 if one of its checks failed), so a BREXX that did not run at all */
/* cannot pass for one that did. Then the outer exec ends and CHKZERO  */
/* finds 0. A failure sets ECTENVBK to a foreign value so that CHKZERO */
/* fails as well.                                                      */
err = 0
parse arg inner .
parse source . . dsn .
dsn = strip(dsn, 'B', "'")
if inner = 'INNER' then do
  address tso 'TSTVPOOL ENVADDR'
  say left('VARNEST', 8) '- inner exec: ECTENVBK =' d2x(rc)
  address tso 'TSTVPOOL ENV'
  call check 'inner exec reaches IRXEXCOM, RC' rc, rc = 0
  exit 7 + err
end
say '----------------------------------------'
say 'File varnest.rexx'

address tso 'TSTVPOOL ENVADDR'
outer = rc
call check 'ECTENVBK is set while the outer exec runs', outer > 0
say left('VARNEST', 8) '- outer exec: ECTENVBK =' d2x(outer) 'source' dsn

address tso "BREXX '"dsn"' INNER"
call check 'the nested BREXX ended with its own RC 7, RC' rc, rc = 7

address tso 'TSTVPOOL ENVADDR'
call check 'ECTENVBK is the outer block again', rc = outer
address tso 'TSTVPOOL ENV'
call check 'IRXEXCOM of the outer block still works, RC' rc, rc = 0

if err then address tso 'TSTVPOOL STEAL'
say 'Done varnest.rexx'
exit err

check:
parse arg what, ok
if ok then say left('VARNEST', 8) '-' what '.. PASS'
else do
  say left('VARNEST', 8) '-' what '.. *FAIL*'
  err = 1
end
return
