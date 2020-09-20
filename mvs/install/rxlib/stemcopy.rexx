/* ---------------------------------------------------------------------
 * Copy stem into another stem
 *  STEMCOPY source-stem,target-stem
 *    both stems must be coded with a trailing '.'
 * .............................. Created by PeterJ on 15. December 2018
 * ---------------------------------------------------------------------
 */
stemcopy:
parse arg $sfrom,#sto
_smax=value($sfrom'0')
if datatype(_smax)<>'NUM' then do
   call RXMSG 310,'E','STEM '$SFROM'0 does no contain a valid number'
   return -8
end
Interpret 'DROP '#sto
do _i=0 for _smax+1
   interpret #sto''_i'='$sfrom''_i
end
return _smax
