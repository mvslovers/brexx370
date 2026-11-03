/* REXX - the inner exec of xcomnest.rexx (#602)                       */
/* Returns 7 when ECTENVBK holds an ENVBLOCK with the input stack word, */
/* 8 otherwise. In a batch step without an ECT there is nothing to    */
/* look at: RC 0.                                                      */
ascb = peeka(548)
asxb = peeka(ascb + 108)
lwa  = peeka(asxb + 20)
if lwa = 0 then exit 0
ect  = peeka(lwa + 32)
env  = peeka(ect + 48)
if env = 0 then exit 8
if storage(d2x(env), 8) \= 'ENVBLOCK' then exit 8
if peeka(env + 304) = 0 then exit 8
exit 7
