/* REXX - ECTENVBK holds BREXX's ENVBLOCK while the exec runs (#602)   */
/* MVSTEST TSO                                                         */
/* MVSTEST SYSTSIN-BEFORE TSTXSENT SET                                 */
/* MVSTEST SYSTSIN TSTXSENT CHK                                        */
/* BREXX stores its ENVBLOCK in ECTENVBK (ECT+X'30') for the length of */
/* the run, so that a host command or a program that it LINKs finds    */
/* the IRXEXTE vector (and IRXEXCOM in it), and puts the previous      */
/* value back at the end (#353 had it leave ECTENVBK alone). The check */
/* after the exec is TSTXSENT CHK. Needs an ECT: MVSTEST TSO.          */
say '----------------------------------------'
say 'File ectenvbk.rexx'
bmode = 'BAD '
ascb = peeka(548)                      /* PSAAOLD                     */
asxb = peeka(ascb + 108)               /* ASCBASXB                    */
lwa  = peeka(asxb + 20)                /* ASXBLWA                     */
if lwa = 0 then do
   say 'ECTENVBK - no ECT .. *FAIL*'
   signal fail
end
ect  = peeka(lwa + 32)                 /* LWAPECT                     */
env  = peeka(ect + 48)                 /* ECTENVBK                    */
if env = 0 then do
   say 'ECTENVBK - ECTENVBK is 0 .. *FAIL*'
   signal fail
end
if storage(d2x(env), 8) \= 'ENVBLOCK' then do
   say 'ECTENVBK - ECTENVBK is' d2x(env) 'and no ENVBLOCK .. *FAIL*'
   signal fail
end
irxexte = peeka(env + 28)              /* ENVBLOCK_IRXEXTE            */
excom   = peeka(irxexte + 16)          /* the 4th entry               */
if irxexte = 0 | excom = 0 then do
   say 'ECTENVBK - IRXEXTE' d2x(irxexte) 'IRXEXCOM entry' d2x(excom) '.. *FAIL*'
   signal fail
end
say 'ECTENVBK - ENVBLOCK' d2x(env) 'with IRXEXCOM entry' d2x(excom) '.. PASS'
exit 0

/* the RC of the step is that of TSTXSENT CHK: spoil ECTENVBK so that   */
/* the check after the exec reports the failure                         */
fail:
address LINKMVS 'TSTXCOM BMODE'
exit 8
