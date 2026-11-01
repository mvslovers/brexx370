/* REXX - PRIVILEGE('ON') twice, then PRIVILEGE('OFF') (#542)          */
/* MVSTEST RC=8                                                        */
/* The second ON must change nothing. It once read the key 0 that the  */
/* first ON had set as the key to go back to, so OFF left the task in  */
/* key 0. The CVT is key 0 storage: a store into it works in key 0 and */
/* abends S0C4 in the key of the job step, and the ESTAE then ends     */
/* BREXX with RC 8. A store that still works after OFF is the failure, */
/* and RC 0 reads as FAIL. If PRIVILEGE('ON') is refused, RC 3 (FAIL). */
say '----------------------------------------'
say 'File privtwo.rexx'
p = privilege('ON')
say 'PRIVTWO  - privilege(ON) rc' p
if p \= 0 then exit 3
cvt = c2x(storage(10, 4))
old = storage(cvt, 1)
call storage cvt, 1, old
say 'PRIVTWO  - store into the CVT works under ON'
p = privilege('ON')
say 'PRIVTWO  - second privilege(ON) rc' p
if p \= 0 then exit 3
p = privilege('OFF')
say 'PRIVTWO  - privilege(OFF) rc' p
if p \= 0 then exit 3
say 'PRIVTWO  - storing into the CVT, S0C4 expected'
call storage cvt, 1, old
say 'PRIVTWO  - the store worked after OFF, key 0 left behind .. *FAIL*'
exit 0
