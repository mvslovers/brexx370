/* ---------------------------------------------------------------------
 * Copy stem into SORTIN. stem
 * .............................. Created by PeterJ on 15. December 2018
 * ---------------------------------------------------------------------
 */
sortcopy:
parse arg $sfrom
_smax=value($sfrom'0')
do _i=0 for _smax+1
   sortin._i=value($sfrom''_i)
end
return _smax
