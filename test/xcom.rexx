/* REXX - the variables of the running exec, through IRXEXTE (#602)    */
/* MVSTEST TSO                                                         */
/* MVSTEST SYSTSIN-BEFORE TSTXSENT SET                                 */
/* MVSTEST SYSTSIN TSTXSENT CHK                                        */
/* TSTXSENT puts a known value into ECTENVBK before BREXX starts and   */
/* checks after the exec that it is back. TSTXCOM (asm, LINKMVS) finds */
/* the ENVBLOCK through ECTENVBK while this exec waits in the command, */
/* takes IRXEXCOM from the IRXEXTE vector and sets, fetches, drops     */
/* variables of this exec, symbolic and direct, and walks them with N. */
/* It ends with RC 0 when the routine answered as expected. A failure  */
/* here leaves a bad value in ECTENVBK, which TSTXSENT CHK reports     */
/* (the RC of the step is the RC of the last command).                 */
say '----------------------------------------'
say 'File xcom.rexx'
err = 0
mode  = 'VARS'
bmode = 'BAD '
xc1 = 'one'
xc2 = 'two'
xci = 'A'
xcstem. = 'dflt'
xcstem.a = 'sa'
address LINKMVS 'TSTXCOM MODE'
call check 'TSTXCOM VARS', rc = 0, 'rc='rc
call check 'XCNEW dropped by asm', symbol('XCNEW') = 'LIT', symbol('XCNEW')
call check 'XC2 dropped by asm', symbol('XC2') = 'LIT', symbol('XC2')
call check 'XC1 kept', xc1 = 'one', xc1
call check 'chain 1st block', xcch1 = 'a', xcch1
call check 'chain 3rd block', xcch2 = 'c', xcch2
call check 'symbolic compound', xcst.a = 'v1', xcst.a
call check 'direct compound', xcst.xci = 'v1', xcst.xci
sa = xcstem.a xcstem.zz
call check 'stem assign', sa = 'newdflt newdflt', sa
list = xclist
say 'XCOM     - N walk:' list
have = 'XC1 XCI XCSTEM. XCSTEM.A XCST.A XCST.XCI XCCH1 XCCH2 MODE'
do i = 1 to words(have)
   w = word(have, i)
   call check 'N lists' w, wordpos(w, list) > 0, list
end
lack = 'XC2 XCNEW XCNONE XCBADV XCSTEM.ZZ XCSTEM.QQ'
do i = 1 to words(lack)
   w = word(lack, i)
   call check 'N omits' w, wordpos(w, list) = 0, list
end
say 'Done xcom.rexx'
if err > 0 then address LINKMVS 'TSTXCOM BMODE'
exit err

check:
parse arg what, ok, info
if ok then say left('XCOM',8) '-' left(what,24) '.. PASS'
else do
   say left('XCOM',8) '-' left(what,24) '.. *FAIL*' info
   err = err + 1
end
return
