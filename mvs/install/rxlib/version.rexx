/* ---------------------------------------------------------------------
 * Return BREXX Version Information.
 * ................................. Created by PeterJ on 25. March 2019
 * VERSION()        : returns Version Number  e.g. V2R1M0
 * VERSION('FULL')  : returns Version Number  and Build Date
 *                       e.g. Version V2R1M0 Build Date 25.Mar.2019
 * ---------------------------------------------------------------------
 */
Version: Procedure
parse upper arg mode
parse version lang vers ptf '('datef')'
if abbrev('FULL',mode,1)=0 then return vers
parse var datef mm dd yy
return 'Version 'vers' Build Date 'dd'. 'mm' 'yy
