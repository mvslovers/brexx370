/* ---------------------------------------------------------------------
 * Perform all Members of a PDS against a REXX
 *   count=PERFORM(pds-name,rexx-to-process)
 * ................................. Created by PeterJ on 17. April 2019
 *
 *   pds-name         fully qualified PDS DSName
 *   rexx-to-process  REXX script to be called for each Member
 *
 *   The call will be performed as:
 *       CALL rexx-name pds-name,member-name
 *   the called rexx can fetch the input parameters either by
 *       PARSE ARG ...
 *       or by ARG(1) and ARG(2)
 * ---------------------------------------------------------------------
 */
Perform:
parse arg _#pds,_#rxexec,p0,p1,p2,p3
call dir("'"_#pds"'")
_#num=direntry.0
if _#num<0 then return -8
do _#perfi=1 to _#num
/* call wto 'Perform 'PDSList.Membername._#perfi' with '_#rxexec  */
   call _PerfExec _#rxexec,_#pds,DirEntry._#perfi.name,p0,p1,p2,p3
/* call wto 'Perform 'PDSList.Membername._#perfi' completed'  */
end
return _#num
/* run the Call in a procedure to preserve the variables  */
_PerfExec: Procedure expose global.
 parse arg exec,pds,member,p0,p1,p2,p3
 interpret 'call 'exec "'"pds"','"Member"',"p0","p1","p2","p3",EOL"
return
