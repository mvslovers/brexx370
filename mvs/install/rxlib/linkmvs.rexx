/* ---------------------------------------------------------------------
 * Link to external Program with Parameters.
 * ............................... Created by PeterJ on 21. January 2019
 * BREXX has the ability to call external load members according to
 * the MVS call conventions. The parameters are passed in the same way
 * as called with the JCL PARM parameter.
 * e.g.
 * rc=LINKMVS('IEFBR14','NOPARM')
 *    calls IEFBR14, passing NOPARM (IEFBR14 does not support parms ...)
 * returned is the return code of the program
 * ---------------------------------------------------------------------
 */
Linkmvs: Procedure
parm=''
do pi=2 to arg()
   parm=parm''arg(pi)','
end
if arg()>1 then do
   parm=substr(parm,1,length(parm)-1)
  ADDRESS SYSTEM
   interpret arg(1) "'"parm"'"
end
else do
  ADDRESS SYSTEM
   interpret arg(1)
end
return rc
