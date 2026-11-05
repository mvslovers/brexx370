/* REXX - an abend while PRIVILEGE('ON') is set (#191, as P4)          */
/* MVSTEST RC=8                                                        */
/* MVSTEST ABEND=S306                                                  */
/* As lnkabnd.rexx, but privileged: PRIVILEGE('ON') is set and         */
/* TSTABND is loaded from the TESTLIB, which is not authorized. The    */
/* task is refused with S306 (IEA703I 306-C), the ESTAE catches it,    */
/* prints BRX0003E and BREXX must end with RC 8. TSTABND never runs;   */
/* the S0C1 case is #639. If PRIVILEGE('ON') is refused: RC 3.         */
say '----------------------------------------'
say 'File privabnd.rexx'
p = privilege('ON')
say 'PRIVABND - privilege(ON) rc' p
if p \= 0 then exit 3
a1 = 'ABND'; a2 = ''
address LINKMVS 'TSTABND A1 A2'
say 'PRIVABND - TSTABND did not abend .. *FAIL*'
exit 0
