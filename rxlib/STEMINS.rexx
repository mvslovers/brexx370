/* ---------------------------------------------------------------------
 * STEM Insert inserts a stem into another stem at a certain index
 *  STEMINS stem-to-insert target stem
 *    stems must be coded with a trailing '.'
 *    index  defaults to 1
 *    if index = -1 the stem to insert is appending the target stem
 * ................................. Created by PeterJ on 15. April 2019
 * ................................  Amended by PeterJ on 6. August 2022
 *                                            Speed improvement factor 4
 * ---------------------------------------------------------------------
 */
stemins:
parse arg $sfrom,$sto,_#indx
  if substr($sfrom,length($sfrom),1)<>'.' then $sfrom=$sfrom'.'
  if substr($sto,length($sto),1)<>'.' then $sto=$sto'.'
  if _#indx='' then _#indx=1
  _#smax=value($sfrom'0')
  _#tmax=value($sto'0')
  if _#indx=-1 then _#indx=_#tmax+1
  if datatype(_#smax)<>'NUM' then ,
     call STOP 'STEM '$SFROM'0 does not contain a valid number'
  if datatype(_#tmax)<>'NUM' then ,
     call STOP 'STEM '$Sto'0 does not contain a valid number'
/* step 1, expand target stem */
  l1="do _#i=_#tmax to _#indx by -1;_$t="||,
      $Sto"_#i;_#h=_#i+_#smax;"$sto"_#h=_$t;end"
/* step 2, Insert new stem */
  l2="do _#i=1 to _#smax;_$t="$sfrom"_#i;_#h=_#i+_#indx;"$sto||,
     "_#indx=_$t;_#indx=_#indx+1;end;"$sto"0=_#smax+_#tmax"
  __token=filter(time('L'),'.:')
  call setg('__str'__token,l1';'l2)
  interpret 'call __str'__token
return _#smax+_#tmax
