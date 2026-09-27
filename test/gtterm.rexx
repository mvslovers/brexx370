/* REXX - SYSVAR('SYSTERMID'), TERMINAL(), SYSVAR('SYSNODE') (#129)    */
/* In batch there is no terminal: SYSTERMID is empty and TERMINAL()    */
/* returns '0 0'. SYSNODE must answer without touching a wild pointer. */
say '----------------------------------------'
say 'File gtterm.rexx'
err = 0
say 'SYSENV   ' sysvar('SYSENV') 'SYSTSO' sysvar('SYSTSO')
tid = sysvar('SYSTERMID')
say 'SYSTERMID "'tid'"'
if sysvar('SYSTSO') \= 1 & tid \== '' then call fail 'SYSTERMID not empty'
term = terminal()
say 'TERMINAL  "'term'"'
if words(term) \= 2 then call fail 'TERMINAL() not two words'
else if \datatype(word(term,1),'W') | \datatype(word(term,2),'W') then,
   call fail 'TERMINAL() not numeric'
else if sysvar('SYSTSO') \= 1 & term \= '0 0' then,
   call fail 'TERMINAL() not 0 0 in batch'
node = sysvar('SYSNODE')
say 'SYSNODE   "'node'"'
if length(node) > 14 then call fail 'SYSNODE too long'
say 'Done gtterm.rexx'
exit err

fail:
say left('GTTERM',8) '-' arg(1) '.. *FAIL*'
err = err + 1
return
