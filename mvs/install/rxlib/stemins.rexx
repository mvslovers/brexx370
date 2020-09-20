/* ---------------------------------------------------------------------
 * STEM Insert inserts a stem into another stem at a certain index
 *  STEMINS stem-to-insert target stem
 *    stems must be coded with a trailing '.'
 *    index  defaults to 1
 *    if index = -1 the stem to insert is appending the target string
 * ................................. Created by PeterJ on 15. April 2019
 * ---------------------------------------------------------------------
 */
stemins:
parse arg $sfrom,$sto,_#indx
if _#indx='' then _#indx=1
_#smax=value($sfrom'0')
_#tmax=value($sto'0')
if _#indx=-1 then _#indx=_#tmax+1
if datatype(_#smax)<>'NUM' then do
   call RXMSG 310,'E','STEM '$SFROM'0 does no contain a valid number'
   return -8
end
if datatype(_#tmax)<>'NUM' then do
   call RXMSG 310,'E','STEM '$Sto'0 does no contain a valid number'
   return -8
end
/* step 1, expand target stem */
do _#i=_#tmax to _#indx by -1
   _$t=value($Sto''_#i)
   _#h=_#i+_#smax
   interpret $sto''_#h'="'_$t'"'
end
/* step 2, Insert new stem */
do _#i=1 to _#smax
   _$t=value($sfrom''_#i)
   _#h=_#i+_#indx
   interpret $sto''_#indx'="'_$t'"'
   _#indx=_#indx+1
end
interpret $sto''0'='_#smax+_#tmax
return $sto''0
