/* REXX - running out of memory under PRIVILEGE('ON') ends with RC 60 (#566) */
/* MVSTEST RC=60                                                       */
/* MVSTEST OWNJOB                                                      */
/* As oomstem.rexx, but with PRIVILEGE('ON') in effect. The step ended */
/* S40D without a return code and the initiator was drained. It has to */
/* end with RC 60 and the error message, like an unprivileged exec. If */
/* PRIVILEGE('ON') is refused, the test measures nothing and ends with */
/* RC 3 (FAIL). Reaching the EXIT below would give RC 0.              */
say '----------------------------------------'
say 'File oompriv.rexx'
p = privilege('ON')
say 'OOMPRIV  - privilege(ON) rc' p
if p \= 0 then exit 3
do i = 0 to 399999
   k = (i * 7919) // 400009   /* all different, in no order: a flat tree */
   s.k = 1
end
say 'OOMPRIV  - 400000 stem entries fit .. *FAIL*'
exit 0
