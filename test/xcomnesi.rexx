/* REXX - the inner exec of xcomnest.rexx (#602, #609)                */
/* Argument: the outer ENVBLOCK (decimal). Returns 7 when ECTENVBK holds*/
/* an ENVBLOCK with the input stack word whose X'13C' is the outer     */
/* block, and the outer block's X'13C' is the ECT address (the value    */
/* TSTXSENT SET left in ECTENVBK before BREXX started); 8, 9, 10        */
/* otherwise. In a batch step without an ECT there is nothing to look  */
/* at: RC 0.                                                           */
parse arg outer .
ascb = peeka(548)
asxb = peeka(ascb + 108)
lwa  = peeka(asxb + 20)
if lwa = 0 then exit 0
ect  = peeka(lwa + 32)
env  = peeka(ect + 48)
if env = 0 then exit 8
if storage(d2x(env), 8) \= 'ENVBLOCK' then exit 8
if peeka(env + 304) = 0 then exit 8
if peeka(env + 316) \= outer then exit 9
if peeka(outer + 316) \= ect then exit 10
exit 7
