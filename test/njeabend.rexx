/* REXX - an abend gives the job step's authorization back (#505).      */
/* __NJESEND holds the SVC 244 authorization in a flag on its stack. If */
/* the NJE38 command abends, BREXX's ESTAE ends the call, its frame is  */
/* gone and nobody drops the flag; main() ends the exec with RxNoPriv() */
/* and that has to give the authorization back. The real command cannot */
/* be made to abend (bad arguments, a stopped NJE38, long texts all end */
/* with a return code), and a stand-in for it is not found: an          */
/* authorized LINK skips a STEPLIB without APF, and a copy in the job   */
/* pack area from there is passed over as well. So TSTAUTH does the     */
/* same with the code of privilege.c in a test module of its own: it    */
/* takes the authorization in a frame it leaves by longjmp, then calls  */
/* RxNoPriv(). TSTAUTH measures the authorization of the step (the     */
/* JSCBAUTH that SYSVAR('SYSAUTH') reads) right after RxNoPriv() and    */
/* ends with RC 0 if it is off; it gives back what it still holds, so   */
/* this exec checks the RC, and that it gets the step back as it was.   */
say '----------------------------------------'
say 'File njeabend.rexx'
err = 0
if sysvar('SYSAUTH') <> 0 then do
   say left('NJEABEND',8) '- the job step is authorized anyway .. SKIPPED'
   say 'Done njeabend.rexx'
   exit 0
end
a1 = ''; a2 = ''
address LINKMVS 'TSTAUTH A1 A2'
r = rc
call check 'TSTAUTH', r, 0
call check 'step after TSTAUTH', sysvar('SYSAUTH'), 0
say 'Done njeabend.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('NJEABEND',8) '-' left(what,20) '.. PASS'
else do
   say left('NJEABEND',8) '-' left(what,20) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
