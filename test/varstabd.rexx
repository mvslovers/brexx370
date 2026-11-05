/* REXX - a foreign ECTENVBK is left alone also after an abort (#602)  */
/* MVSTEST TSO                                                         */
/* MVSTEST ABEND=S0C1                                                  */
/* MVSTEST SYSTSIN TSTVPOOL CHKSENT                                    */
/* As varsteal.rexx, but the exec does not end normally: after the     */
/* marker is stored, TSTVPOOL ABEND abends S0C1 and the ESTAE ends the */
/* exec with RC 8. The cleanup of the abort path must not overwrite    */
/* a foreign ECTENVBK either. The test counts only if ECTENVBK was set */
/* when the exec started; else ECTENVBK is set to 0 and CHKSENT fails. */
say '----------------------------------------'
say 'File varstabd.rexx'
address tso 'TSTVPOOL ENVADDR'
env = rc
say left('VARSTABD', 8) '- ECTENVBK before the abend =' d2x(env)
address tso 'TSTVPOOL STEAL'
if rc \= 0 | env = 0 then address tso 'TSTVPOOL ZAP'
address tso 'TSTVPOOL ABEND'
say left('VARSTABD', 8) '- the abend did not happen .. *FAIL*'
address tso 'TSTVPOOL ZAP'
exit 1
