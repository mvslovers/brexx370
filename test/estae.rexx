/* REXX - an abend in BREXX is caught by its ESTAE (#167)              */
/* MVSTEST RC=8                                                        */
/* Writing into the PSA abends S0C4 (protection). The ESTAE has to     */
/* catch it, print BRX0003E, clean up and end the step with RC 8,      */
/* without a second abend. Reaching the EXIT below would give RC 0.    */
say '----------------------------------------'
say 'File estae.rexx'
call storage 0,,'X'
say 'ESTAE    - STORAGE() did not abend .. *FAIL*'
exit 0
