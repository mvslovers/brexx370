/* REXX - the CLIST variable pool is removed (#366)                 */
/* VALUE(name,,'CLIST') must fail like any pool that never existed, */
/* reading and setting; the procedure pools stay.                   */
say '----------------------------------------'
say 'File noclist.rexx'
err = 0
ctl = valrc("'NOSUCHPL'")
say left('NOCLIST',8) '- control: unknown pool gives error' ctl
got = valrc("'CLIST'")
if got = ctl & ctl \= 0 then,
  say left('NOCLIST',8) '- VALUE(x,,CLIST) is gone (error' got') .. PASS'
else do
  say left('NOCLIST',8) '- VALUE(x,,CLIST) gave' got', control' ctl '.. *FAIL*'
  err = 1
end
got = valrc("'CLIST'", "'NEW'")
if got = ctl then,
  say left('NOCLIST',8) '- VALUE(x,new,CLIST) is gone (error' got') .. PASS'
else do
  say left('NOCLIST',8) '- VALUE(x,new,CLIST) gave' got '.. *FAIL*'
  err = 1
end
/* a numeric pool is the procedure level: still served */
v = 'kept'
if value('V', , 0) = 'kept' then,
  say left('NOCLIST',8) '- VALUE(x,,0) kept .. PASS'
else do
  say left('NOCLIST',8) '- VALUE(x,,0) broken .. *FAIL*'
  err = 1
end
say 'Done noclist.rexx'
exit err

/* the error number VALUE('V',[new],pool) raises, 0 if none */
valrc:
parse arg pool, new
signal on syntax name valerr
interpret 'x = value(''V'','new','pool')'
return 0
valerr:
return rc
