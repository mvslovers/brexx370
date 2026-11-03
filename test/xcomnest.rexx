/* REXX - an exec started from an exec: ECTENVBK and the variables (#602) */
/* MVSTEST TSO                                                         */
/* MVSTEST SYSTSIN-BEFORE TSTXSENT SET                                 */
/* MVSTEST SYSTSIN TSTXSENT CHK                                        */
/* The exec starts a second BREXX through the TSO command (xcomnesi).  */
/* That one publishes its own ENVBLOCK and, when it ends, puts back the */
/* outer one: ECTENVBK and the input stack word (ENVBLOCK+X'130') must */
/* be what they were, the variables of this exec reachable through    */
/* IRXEXTE, and TSTXSENT CHK finds the value it set before BREXX ran.  */
say '----------------------------------------'
say 'File xcomnest.rexx'
mode = 'VARS'
bmode = 'BAD '
xc1 = 'one'
xc2 = 'two'
xci = 'A'
xcstem. = 'dflt'
xcstem.a = 'sa'
ascb = peeka(548)                      /* PSAAOLD                     */
asxb = peeka(ascb + 108)               /* ASCBASXB                    */
lwa  = peeka(asxb + 20)                /* ASXBLWA                     */
if lwa = 0 then do
   say 'XCOMNEST - no ECT .. *FAIL*'
   exit 8
end
ect  = peeka(lwa + 32)                 /* LWAPECT                     */
env0 = peeka(ect + 48)                 /* ECTENVBK                    */
stk0 = peeka(env0 + 304)               /* ENVBLOCK+X'130'             */
if storage(d2x(env0), 8) \= 'ENVBLOCK' | stk0 = 0 then do
   say 'XCOMNEST - outer ENVBLOCK' d2x(env0) 'word' d2x(stk0) '.. *FAIL*'
   signal fail
end
address TSO 'BREXX' userid()'.BREXX370.TESTS(XCOMNESI)'
if rc \= 7 then do
   say 'XCOMNEST - inner exec rc='rc', expected 7 .. *FAIL*'
   signal fail
end
env1 = peeka(ect + 48)
stk1 = peeka(env1 + 304)
if env1 \= env0 | stk1 \= stk0 then do
   say 'XCOMNEST - after inner exec: ECTENVBK' d2x(env1) 'word' d2x(stk1),
       'but was' d2x(env0) 'word' d2x(stk0) '.. *FAIL*'
   signal fail
end
address LINKMVS 'TSTXCOM MODE'
if rc \= 0 then do
   say 'XCOMNEST - TSTXCOM VARS after inner exec rc='rc' .. *FAIL*'
   signal fail
end
say 'XCOMNEST - ENVBLOCK' d2x(env0) 'back after the inner exec .. PASS'
exit 0

/* spoil ECTENVBK so that TSTXSENT CHK reports the failure too         */
fail:
address LINKMVS 'TSTXCOM BMODE'
exit 8
