/* REXX - an abend while PRIVILEGE('ON') is set (#191, as P4)          */
/* MVSTEST RC=8                                                        */
/* The ESTAE catches the user abend and BREXX ends with RC 8. With the */
/* privilege still set, the cleanup after it abended (S378 in the      */
/* samples). If PRIVILEGE('ON') is refused, RC 3 (FAIL).               */
say '----------------------------------------'
say 'File privabnd.rexx'
p = privilege('ON')
say 'PRIVABND - privilege(ON) rc' p
if p \= 0 then exit 3
call abend 123
say 'PRIVABND - ABEND() did not abend .. *FAIL*'
exit 0
