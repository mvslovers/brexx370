/* ---------------------------------------------------------------------
 * Cleans STEM, removes empty and un-set places
 *  STEMCLEN source-stem
 *    stem must be coded with a trailing '.'
 * .................................. Created by PeterJ on 6. April 2019
 * ---------------------------------------------------------------------
 */
stemreor:
parse arg $sfrom
_smax=value($sfrom'0')
if datatype(_smax)<>'NUM' then do
   call RXMSG 310,'E','STEM '$SFROM'0 does no contain a valid number'
   return -8
end
_#j=0
do _#i=1 to _smax
   if value($sfrom''_#i)='' then iterate
   if symbol($sfrom''_#i)<>'VAR' then iterate
   _#j=_#j+1
   interpret $sfrom''_#j'='$sfrom''_#i
end
do _#i=_#j+1 to _smax
   interpret 'DROP '$sfrom''_#i
end
return _#j
