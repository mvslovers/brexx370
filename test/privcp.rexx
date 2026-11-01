/* REXX - CP commands keep PRIVILEGE('ON') (#544)                      */
/* MVSTEST TSO                                                         */
/* RXCPCMD ends with MODESET KEY=NZERO, which took the key 0 of a      */
/* PRIVILEGE('ON') of the exec away: ADDRESS COMMAND 'CP ...' and      */
/* SYSVAR('SYSCP') left the exec in the key of the job step. The CVT   */
/* is key 0 storage: a store into it works in key 0 and abends S0C4 in */
/* the key of the job step, and the ESTAE then ends BREXX with RC 8.   */
/* That RC 8 is the failure. If PRIVILEGE('ON') is refused, the test   */
/* cannot measure anything and ends with RC 3 (FAIL).                  */
say '----------------------------------------'
say 'File privcp.rexx'
p = privilege('ON')
say 'PRIVCP   - privilege(ON) rc' p
if p \= 0 then exit 3
cvt = c2x(storage(10, 4))
old = storage(cvt, 1)
call storage cvt, 1, old
say 'PRIVCP   - store into the CVT works under ON'

address command 'CP QUERY CPLEVEL'
say 'PRIVCP   - ADDRESS COMMAND CP rc' rc
call storage cvt, 1, old
say 'PRIVCP   - ADDRESS COMMAND CP kept PRIVILEGE(ON) .. PASS'

cp = sysvar('SYSCP')
say 'PRIVCP   - SYSVAR(SYSCP) ->' cp
call storage cvt, 1, old
say 'PRIVCP   - SYSVAR(SYSCP) kept PRIVILEGE(ON) .. PASS'

call privilege 'OFF'
say 'Done privcp.rexx'
exit 0
