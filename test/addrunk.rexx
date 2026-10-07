/* REXX - ADDRESS to an environment BREXX does not have (#371)      */
/* gives RC -3, as in TSO/E; it was -42 with "please report this".  */
say '----------------------------------------'
say 'File addrunk.rexx'
err = 0
address NOSUCHEV 'ANY COMMAND'
got = rc
if got = -3 then,
  say left('ADDRUNK',8) '- unknown environment, RC -3 .. PASS'
else do
  say left('ADDRUNK',8) '- unknown environment gave RC' got '.. *FAIL*'
  err = 1
end
/* a negative RC is FAILURE: the trap still fires */
trapped = 0
call on failure name onfail
address NOSUCHEV 'ANY COMMAND'
call off failure
if trapped then,
  say left('ADDRUNK',8) '- FAILURE raised .. PASS'
else do
  say left('ADDRUNK',8) '- FAILURE not raised .. *FAIL*'
  err = 1
end
say 'Done addrunk.rexx'
exit err

onfail:
trapped = 1
return
