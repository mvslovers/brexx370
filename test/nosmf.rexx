/* REXX - the SMF feature is removed (#152)                        */
/* PUTSMF must fail like a function that never existed.            */
say '----------------------------------------'
say 'File nosmf.rexx'
err = 0
ctl = callrc('NOSUCHFN')
say left('NOSMF',8) '- control: unknown function gives error' ctl
got = callrc('PUTSMF')
if got = ctl & ctl \= 0 then,
  say left('NOSMF',8) '- PUTSMF is gone (error' got') .. PASS'
else do
  say left('NOSMF',8) '- PUTSMF gave' got', control' ctl '.. *FAIL*'
  err = 1
end
/* MVSVAR('SYSSMFID') stays: it reads the SMCA, not smf/ */
if length(mvsvar('SYSSMFID')) = 4 then,
  say left('NOSMF',8) '- MVSVAR(SYSSMFID) kept .. PASS'
else do
  say left('NOSMF',8) '- MVSVAR(SYSSMFID) broken .. *FAIL*'
  err = 1
end
say 'Done nosmf.rexx'
exit err

/* the error number a call of function fn raises, 0 if none */
callrc:
parse arg fn
signal on syntax name callerr
interpret 'x =' fn"(242, 'BREXX TEST')"
return 0
callerr:
return rc
