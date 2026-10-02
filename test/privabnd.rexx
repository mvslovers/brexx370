/* REXX - an abend while PRIVILEGE('ON') is set (#191, as P4)          */
/* MVSTEST RC=8                                                        */
/* As lnkabnd.rexx, but privileged: the ESTAE catches the S0C1 of      */
/* TSTABND and BREXX must end with RC 8. With the privilege still set, */
/* the cleanup after it abended (S378 in the samples LISTALL and       */
/* LISTNCAT). If PRIVILEGE('ON') is refused, RC 3 (FAIL).              */
say '----------------------------------------'
say 'File privabnd.rexx'
p = privilege('ON')
say 'PRIVABND - privilege(ON) rc' p
if p \= 0 then exit 3
address LINKMVS 'TSTABND'
say 'PRIVABND - TSTABND did not abend .. *FAIL*'
exit 0
