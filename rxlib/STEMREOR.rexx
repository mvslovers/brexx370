/* -----------------------------------------------------------------------
 * Reorders STEM, Element 1 becomes highest Element, 2 the 2. highest. ...
 *  STEMREOR source-stem
 *    stem must be coded with a trailing '.'
 * .................................... Created by PeterJ on 6. April 2019
 * ..................................  Amended by PeterJ on 6. August 2022
 *                                             Speed improvement factor 10
 * -----------------------------------------------------------------------
 */
stemreor:
parse arg $sfrom
  if substr($sfrom,length($sfrom),1)<>'.' then $sfrom=$sfrom'.'
  _#smax=value($sfrom'0')
  if datatype(_#smax)<>'NUM' then ,
     call STOP 'STEM '$SFROM'0 does not contain a valid number'
  _#m=_#smax%2
  _#h=_#smax
  l1="do _#i=1 for _#m; _$t="$SFROM"_#h;"$SFROM"_#h="$SFROM"_#i"
  l2=$SFROM"_#i=_$t;_#h=_#h-1; end;return"
  __token=filter(time('L'),'.:')
  call setg('__str'__token,l1';'l2)
  interpret 'call __str'__token
return _#smax
