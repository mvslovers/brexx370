/* REXX - an abend with a later block above ours in the chain (#609)   */
/* MVSTEST TSO                                                         */
/* MVSTEST ABEND=S0C1                                                  */
/* MVSTEST SYSTSIN-BEFORE TSTXSENT SET                                 */
/* MVSTEST SYSTSIN TSTXSENT CHK                                        */
/* This exec starts a second BREXX (xcomabni) with a fake ENVBLOCK     */
/* that TSTXCOM allocated here, so that it outlives the inner exec.    */
/* The inner exec puts the fake block on top of its own and abends     */
/* S0C1. The chain is then ECTENVBK -> fake -> inner -> this exec.     */
/* BREXX's ESTAE takes the inner block out of the MIDDLE of the chain: */
/* the fake block must stay in ECTENVBK and its X'13C' must be this    */
/* exec's block. This exec checks that, takes the fake block out and   */
/* ends; TSTXSENT CHK then finds the value it set before BREXX ran.    */
say '----------------------------------------'
say 'File xcomabnd.rexx'
amode = 'ALOC'
pmode = 'POP '
bmode = 'BAD '
fk = ''
ascb = peeka(548)                      /* PSAAOLD                     */
asxb = peeka(ascb + 108)               /* ASCBASXB                    */
lwa  = peeka(asxb + 20)                /* ASXBLWA                     */
if lwa = 0 then do
   say 'XCOMABND - no ECT .. *FAIL*'
   exit 8
end
ect  = peeka(lwa + 32)                 /* LWAPECT                     */
env0 = peeka(ect + 48)                 /* ECTENVBK                    */
address LINKMVS 'TSTXCOM AMODE FK'
if rc \= 0 | length(fk) \= 4 then do
   say 'XCOMABND - TSTXCOM ALOC rc='rc 'length' length(fk) '.. *FAIL*'
   signal fail
end
fkh = c2x(fk)
fkd = x2d(fkh)
address TSO 'BREXX' userid()'.BREXX370.TESTS(XCOMABNI)' fkh
say 'XCOMABND - inner exec ended with rc='rc
env1 = peeka(ect + 48)
if env1 \= fkd then do
   say 'XCOMABND - after the inner exec ECTENVBK is' d2x(env1),
       'but should be the block on top,' fkh '.. *FAIL*'
   signal fail
end
if peeka(fkd + 316) \= env0 then do
   say 'XCOMABND - X''13C'' of the block on top is' d2x(peeka(fkd + 316)),
       'but should be this exec''s' d2x(env0) '.. *FAIL*'
   signal fail
end
address LINKMVS 'TSTXCOM PMODE'
if rc \= 0 | peeka(ect + 48) \= env0 then do
   say 'XCOMABND - TSTXCOM POP rc='rc' .. *FAIL*'
   signal fail
end
say 'XCOMABND - the inner block left the middle of the chain .. PASS'
exit 0

/* spoil ECTENVBK so that TSTXSENT CHK reports the failure too         */
fail:
address LINKMVS 'TSTXCOM BMODE'
exit 8
