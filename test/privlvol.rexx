/* REXX - LISTVOLS keeps PRIVILEGE('ON') (#544)                        */
/* MVSTEST TSO                                                         */
/* It once called PRIVILEGE('OFF') after its own PRIVILEGE('ON'), so a */
/* PRIVILEGE('ON') of the exec was over after the call. The CVT is key */
/* 0 storage: a store into it works in key 0 and abends S0C4 in the    */
/* key of the job step, and the ESTAE then ends BREXX with RC 8. That  */
/* RC 8 is the failure. If PRIVILEGE('ON') is refused, the test cannot */
/* measure anything and ends with RC 3 (FAIL). LISTVOLS needs a CPPL   */
/* for CP DEVLIST and OUTTRAP, hence TSO.                              */
say '----------------------------------------'
say 'File privlvol.rexx'
p = privilege('ON')
say 'PRIVLVOL - privilege(ON) rc' p
if p \= 0 then exit 3
cvt = c2x(storage(10, 4))
old = storage(cvt, 1)
call storage cvt, 1, old
say 'PRIVLVOL - store into the CVT works under ON'

call listvols 'LIST'
say 'PRIVLVOL - storing into the CVT after LISTVOLS'
call storage cvt, 1, old
say 'PRIVLVOL - LISTVOLS kept PRIVILEGE(ON) .. PASS'

call privilege 'OFF'
say 'Done privlvol.rexx'
exit 0
