/* ---------------------------------------------------------------------
 *  WRITE entire or part of a STEM into FILE
 *  ................................. Created by PeterJ on 6. April 2019
 *  WRITEALL(file,source-var,file-type)
 *    file        dd-name or ds-name
 *    source-var  stem which should be written, variable must
 *                be coded with a trailing "."
 *    file-type   DDN or DD for files allocated via DD statement
 *                DSN if file is a fully qualified Dataset
 *                file-type defaults to DDN
 *  Return Code > 0 number of lines written
 *               -8 open of file failed
 *
 * ................ DSN OPEN ... Amended by PeterJ on 12. September 2019
 * ---------------------------------------------------------------------
 */
WriteAll:
parse upper arg _#file,_#var,_#mode,_#from,_#to
if _openWriteAll()<>0 then return -8
/* ........ Write STEM conten into File .............. */
if datatype(_#max)<>'NUM' then do
   call RXMSG 310,'E','STEM '_#var'0 does no contain a valid number'
   return -8
end
do _#i=_#from to _#to
   CALL write _#ftk,value(_#var''_#i),nl
end
call close _#ftk
return _#max
/* ---------------------------------------------------------------------
 *  Init Rexx and open File
 * ---------------------------------------------------------------------
 */
_openWriteAll:
if _#mode='DSN' then _#ftk=open("'"_#file"'",'WT')
   else _#ftk=open(_#file,'WT')
if _#ftk<0 then do
   if _#mode='DSN' then call RXMSG 300,'E','cannot open DSN '_#file
      else call RXMSG 300,'E','cannot open file '_#file
   return -8
end
_#max=value(_#var'0')
_#errc=0
if _#from='' then _#from=1
if _#to  ='' then _#to=_#max
if datatype(_#from)<>'NUM' then _#errc=1
if datatype(_#to)<>'NUM' then _#errc=1
if _errrc=1 then do
   call RXMSG 320,'E','Range Parameters not numeric, '_#from','_#to
   return -8
end
if _#from<=0  then _#from=1
if _#to  <=0  then _#to=_#max
if _#from>_#to then do
   call RXMSG 321,'E','Range Parameters not ascending: '_#from','_#to
   _#errc=1
end
if _#from>_#max then do
   call RXMSG 322,'E','Range Parameters outside STEM Range: '_#from','_#to', STEM range 1,'_#max
   _#errc=1
end
if _#errc=1 then return -8
if _#to>_#max then _#to=_#max
return 0
