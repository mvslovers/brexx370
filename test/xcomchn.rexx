/* REXX - the chain of ENVBLOCKs and the dispatcher in BRXEXCOM (#609) */
/* MVSTEST TSO                                                         */
/* MVSTEST SYSTSIN-BEFORE TSTXSENT SET                                 */
/* MVSTEST SYSTSIN TSTXSENT CHK                                        */
/* While this exec runs, TSTXCOM CHN builds fake ENVBLOCKs on top of   */
/* the exec's own, puts them in ECTENVBK and calls the variable        */
/* routine the way IKJCT441 does (R0 = ECTENVBK), scenario by          */
/* scenario (the list is in test/tstxcom.asm): foreign blocks above    */
/* the exec are skipped and the request reaches it; of two blocks with */
/* the mark of the exec the newest gets it; a cycle, a chain that ends,*/
/* ECTENVBK = 0 and a chain that reaches the exec only after 256 steps */
/* answer R15 = -1 and set nothing; the 256th step still finds it.     */
/* TSTXCOM RC 0 is the verdict of the registers; this exec checks the  */
/* variables. A failure spoils ECTENVBK (TSTXCOM BAD), which TSTXSENT  */
/* CHK reports: the RC of the step is the RC of the last command.      */
say '----------------------------------------'
say 'File xcomchn.rexx'
err = 0
cmode = 'CHN '
bmode = 'BAD '
address LINKMVS 'TSTXCOM CMODE'
call check 'TSTXCOM CHN', rc = 0, 'rc='rc
call check 'XCCHN1 set by the exec''s routine', xcchn1 = 'top', xcchn1
call check 'XCCHN2 set (256th step)', xcchn2 = 'top', xcchn2
call check 'XCCHN3 not set (-1)', symbol('XCCHN3') = 'LIT', symbol('XCCHN3')
call check 'XCCHN4 not set (fake)', symbol('XCCHN4') = 'LIT', symbol('XCCHN4')
say 'Done xcomchn.rexx'
if err > 0 then address LINKMVS 'TSTXCOM BMODE'
exit err

check:
parse arg what, ok, info
if ok then say left('XCOMCHN',8) '-' left(what,34) '.. PASS'
else do
   say left('XCOMCHN',8) '-' left(what,34) '.. *FAIL*' info
   err = err + 1
end
return
