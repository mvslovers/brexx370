/* REXX - an abend in a LINKed program is caught by BREXX's ESTAE      */
/* MVSTEST RC=8                                                        */
/* Control for privabnd.rexx (#191): TSTABND abends S0C1, the ESTAE    */
/* catches it, prints BRX0003E and BREXX ends the step with RC 8.      */
say '----------------------------------------'
say 'File lnkabnd.rexx'
a1 = 'ABND'; a2 = ''
address LINKMVS 'TSTABND A1 A2'
say 'LNKABND  - TSTABND did not abend .. *FAIL*'
exit 0
