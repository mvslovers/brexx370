/* REXX - ENVBLOCK+X'130' holds the top input stack element (#602)     */
/* MVSTEST TSO                                                         */
/* The contract word for IKJCT441: while the exec runs, the word at    */
/* ENVBLOCK+X'130' (304) is the top element of the input stack        */
/* (ECT -> ECTIOWA -> IOSRL, IOSTELM at +0). The other three reserved  */
/* words at the end of the ENVBLOCK (+308 .. +319) stay 0. The restore */
/* at the end of the exec cannot be seen from outside: the ENVBLOCK    */
/* is freed right after. Needs an ECT: MVSTEST TSO.                    */
say '----------------------------------------'
say 'File envstk.rexx'
ascb = peeka(548)                      /* PSAAOLD                     */
asxb = peeka(ascb + 108)               /* ASCBASXB                    */
lwa  = peeka(asxb + 20)                /* ASXBLWA                     */
if lwa = 0 then do
   say 'ENVSTK - no ECT .. *FAIL*'
   exit 8
end
ect  = peeka(lwa + 32)                 /* LWAPECT                     */
iosrl = peeka(ect + 4)                 /* ECTIOWA                     */
top   = peeka(iosrl)                   /* IOSTELM                     */
env   = peeka(ect + 48)                /* ECTENVBK                    */
if storage(d2x(env), 8) \= 'ENVBLOCK' then do
   say 'ENVSTK - ECTENVBK is' d2x(env) 'and no ENVBLOCK .. *FAIL*'
   exit 8
end
word = peeka(env + 304)
if top = 0 then do
   say 'ENVSTK - IOSTELM is 0, nothing to compare .. *FAIL*'
   exit 8
end
if word \= top then do
   say 'ENVSTK - ENVBLOCK+X130' d2x(word) 'but IOSTELM' d2x(top),
       '.. *FAIL*'
   exit 8
end
do i = 308 to 316 by 4
   if peeka(env + i) \= 0 then do
      say 'ENVSTK - ENVBLOCK+' || d2x(i) 'is' d2x(peeka(env + i)),
          'not 0 .. *FAIL*'
      exit 8
   end
end
say 'ENVSTK - ENVBLOCK+X130 =' d2x(word) '= IOSTELM, X134..X13F 0',
       '.. PASS'
exit 0
