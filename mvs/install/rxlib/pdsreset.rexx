/* ---------------------------------------------------------------------
 * Removes all Members of a PDS
 * ................................. Created by PeterJ on 20. March 2019
 *    PDSRESET(library-dsn)
 * Command requires a TSO Environment (Online/Batch)
 * ---------------------------------------------------------------------
 */
PDSreset:
parse arg lib
RXMSLV='E'                        /* Report Error Messages and above */
if InitPDSDir()>0 then return 8
entries=PDSDIR(lib,0)
RXMSLV='I'                        /* Report all   Messages and above */
rc=4
ok=0
nok=0
say 'RESET Partitioned Dataset: 'lib
say copies('-',72)
if entries<0 then return 8  /* error reported in PDSDIR */
if entries=0 then call RXMSG 202,'W',lib' Library contains no Members'
do i=1 to entries
   member=PDSList.Membername.i
   say "TSO command: DELETE '"lib"("member")'"
   ADDRESS TSO
    "DELETE '"lib"("member")'"
   xrc=rc
   if rc=0 then 
      call RXMSG 200,'I',"Delete of "lib"("member") successfully completed"
   else call RXMSG 201,'E',"Delete of "lib"("member") failed"
   if xrc=0 then ok=ok+1
      else nok=nok+1
end
say ' '
say 'Members deleted     'ok
say 'Members not deleted 'nok
if ok>0 then do
   rc=16
   ADDRESS TSO
     "COMPRESS "quote(lib)
   if rc=0 then say lib' has been successfully compressed'
      else say lib' compress failed, RC: 'rc
end
trace off
if nok>0 then return 4
say ' '
return 0
/* -----------------------------------------------------------------
 * Init PDSReset Test all prerequisites
 * -----------------------------------------------------------------
 */
initPDSDIR:
if lib='' then do
   call RXMSG 203,'E','Library is mandatory'
   return 8
end
if sysvar('SYSENV')='FORE' then nop
else if sysvar('SYSENV')='BACK' then nop
else do
   call RXMSG 204,'E','TSO Environment Required'
   return 8
end
return 0
