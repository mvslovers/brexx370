/* REXX - BREXX does not overwrite a foreign ECTENVBK (#602)           */
/* MVSTEST TSO                                                         */
/* MVSTEST SYSTSIN-BEFORE TSTXSENT SET                                 */
/* MVSTEST SYSTSIN TSTXSENT CHKF                                       */
/* While the exec runs, TSTXCOM puts X'00F0F000' into ECTENVBK, as     */
/* another environment would. At the end BREXX restores its saved value */
/* only when ECTENVBK still points to its own block: TSTXSENT CHKF     */
/* expects the foreign value to be still there.                        */
say '----------------------------------------'
say 'File xcomfrgn.rexx'
mode  = 'VARS'
fmode = 'FRGN'
xc1 = 'one'
xc2 = 'two'
xci = 'A'
xcstem. = 'dflt'
xcstem.a = 'sa'
address LINKMVS 'TSTXCOM MODE'
if rc \= 0 then do
   say 'XCOMFRGN - TSTXCOM VARS rc='rc' .. *FAIL*'
   exit 8                    /* ECTENVBK stays as it is: CHKF fails */
end
address LINKMVS 'TSTXCOM FMODE'
if rc \= 0 then say 'XCOMFRGN - TSTXCOM FRGN rc='rc' .. *FAIL*'
say 'Done xcomfrgn.rexx'
exit 0
