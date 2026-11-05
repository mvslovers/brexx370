/* REXX - ECTENVBK after an abend in a LINKed program (#602)          */
/* MVSTEST TSO                                                         */
/* MVSTEST ABEND=S0C1                                                  */
/* MVSTEST SYSTSIN-BEFORE TSTXSENT SET                                 */
/* MVSTEST SYSTSIN TSTXSENT CHK                                        */
/* The exec publishes its environment (TSTXCOM finds it), then TSTABND */
/* abends S0C1. BREXX's ESTAE catches it and BREXX ends without going  */
/* through the end of the exec: ECTENVBK must still have the value     */
/* TSTXSENT SET put there. The step ends with the RC of TSTXSENT CHK.  */
say '----------------------------------------'
say 'File xcomabnt.rexx'
mode  = 'VARS'
bmode = 'BAD '
xc1 = 'one'
xc2 = 'two'
xci = 'A'
xcstem. = 'dflt'
xcstem.a = 'sa'
address LINKMVS 'TSTXCOM MODE'
if rc \= 0 then do
   say 'XCOMABNT - TSTXCOM VARS rc='rc' .. *FAIL*'
   address LINKMVS 'TSTXCOM BMODE'
end
a1 = 'ABND'; a2 = ''
address LINKMVS 'TSTABND A1 A2'
say 'XCOMABNT - TSTABND did not abend .. *FAIL*'
address LINKMVS 'TSTXCOM BMODE'
exit 0
