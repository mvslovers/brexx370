/* ---------------------------------------------------------------------
 * Reorders STEM, Element 1 becomes highest Element, 2 the highest
 *  STEMREOR source-stem
 *    stem must be coded with a trailing '.'
 * .................................. Created by PeterJ on 6. April 2019
 * ---------------------------------------------------------------------
 */
stemreor:
parse arg $sfrom
_#smax=value($sfrom'0')
if datatype(_#smax)<>'NUM' then do
   call RXMSG 310,'E','STEM '$SFROM'0 does no contain a valid number'
   return -8
end
_#m=_#smax%2
_#h=_#smax
do _#i=1 for _#m
   _$t=value($SFROM''_#h)
   interpret $SFROM''_#h'='$SFROM''_#i
   interpret $SFROM''_#i'=_$t'
   _#h=_#h-1
end
return _#smax
