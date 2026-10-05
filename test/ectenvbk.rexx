say '----------------------------------------'
say 'File ectenvbk.rexx'
/* BREXX leaves ECTENVBK (ECT+X'30') alone (#353). It used to store   */
/* its own ENVBLOCK there and set it to 0 at the end, which lost the  */
/* environment of a REXX/370 TMP running side by side. Batch has no   */
/* ECT (LWA 0) and passes. Under TSO the check assumes a stand        */
/* without a REXX/370 TMP (ZMG0002/ZMG0003), whose ECTENVBK is 0.      */
ascb = peeka(548)                      /* PSAAOLD                     */
asxb = peeka(ascb + 108)               /* ASCBASXB                    */
lwa  = peeka(asxb + 20)                /* ASXBLWA                     */
if lwa = 0 then do
   say 'ECTENVBK - no ECT (batch) .. PASS'
   exit 0
end
ect  = peeka(lwa + 32)                 /* LWAPECT                     */
env  = peeka(ect + 48)                 /* ECTENVBK                    */
if env = 0 then do
   say 'ECTENVBK - ECTENVBK is 0 .. PASS'
   exit 0
end
say 'ECTENVBK - ECTENVBK is' d2x(env) storage(d2x(env), 8) '.. *FAIL*'
exit 8
