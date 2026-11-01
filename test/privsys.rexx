/* REXX - SYSVAR('SYSNODE') keeps PRIVILEGE('ON') (#544)                */
/* It once ended with an unconditional privilege(0), so a              */
/* PRIVILEGE('ON') of the exec was over after the call. The CVT is key */
/* 0 storage: a store into it works in key 0 and abends S0C4 in the    */
/* key of the job step, and the ESTAE then ends BREXX with RC 8. That  */
/* RC 8 is the failure. If PRIVILEGE('ON') is refused, or SYSVAR says  */
/* "not authorized" (it then never touches the privilege), the test    */
/* cannot measure anything and ends with RC 3 (FAIL).                  */
say '----------------------------------------'
say 'File privsys.rexx'
p = privilege('ON')
say 'PRIVSYS  - privilege(ON) rc' p
if p \= 0 then exit 3
cvt = c2x(storage(10, 4))
old = storage(cvt, 1)
call storage cvt, 1, old
say 'PRIVSYS  - store into the CVT works under ON'

node = sysvar('SYSNODE')
say 'PRIVSYS  - SYSVAR(SYSNODE) ->' node
if node == 'not authorized' then exit 3
say 'PRIVSYS  - storing into the CVT after SYSNODE'
call storage cvt, 1, old
say 'PRIVSYS  - SYSNODE kept PRIVILEGE(ON) .. PASS'

call privilege 'OFF'
say 'Done privsys.rexx'
exit 0
