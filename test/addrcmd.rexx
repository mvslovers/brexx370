/* REXX - ADDRESS COMMAND 'CP ...' needs the authorisation (#368)   */
/* MVSTEST TSO                                                       */
/* RXCPCMD switches to supervisor state with MODESET, which abended  */
/* S047 in an unauthorised task. ADDRESS COMMAND now gets the        */
/* privilege for the call and gives it back, and leaves a            */
/* PRIVILEGE('ON') of the exec in effect. Where RAKF denies FACILITY */
/* SVC244, the command answers RC -5 instead of abending.            */
say '----------------------------------------'
say 'File addrcmd.rexx'
err = 0
auth0 = sysvar('SYSAUTH')
say left('ADDRCMD',8) '- SYSAUTH at start:' auth0
/* can this user get the privilege at all? */
canpriv = (privilege('ON') = 0)
call privilege 'OFF'
say left('ADDRCMD',8) '- PRIVILEGE available:' canpriv

address command 'CP QUERY CPLEVEL'
got = rc
if canpriv | auth0 = 1 then want = 0
else want = -5
call check 'CP command, RC' want, got = want, 'RC' got
call check 'SYSAUTH restored to' auth0, sysvar('SYSAUTH') = auth0,,
     'SYSAUTH' sysvar('SYSAUTH')

if canpriv then do
  call privilege 'ON'
  address command 'CP QUERY CPLEVEL'
  call check 'CP under PRIVILEGE(ON), RC 0', rc = 0, 'RC' rc
  call check 'PRIVILEGE(ON) still in effect', sysvar('SYSAUTH') = 1,,
       'SYSAUTH' sysvar('SYSAUTH')
  call privilege 'OFF'
end
say 'Done addrcmd.rexx'
exit err

check:
parse arg what, ok, detail
if ok then say left('ADDRCMD',8) '-' what '.. PASS'
else do
  say left('ADDRCMD',8) '-' what '.. *FAIL*' detail
  err = 1
end
return
