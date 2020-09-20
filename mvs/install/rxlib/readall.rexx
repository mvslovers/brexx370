/* ---------------------------------------------------------------------
 *  Read entire File into Stem
 *  ................................. Created by PeterJ on 6. April 2019
 *  READALL(file,target-var,file-type)
 *    file    dd-name or ds-name
 *    target-var  stem which receives the file content, variable must
 *                be coded with a trailing "."
 *                defaults to READALL.
 *    file-type   DDN or DD for files allocated via DD statement
 *                DSN if file is a fully qualified Dataset
 *                file-type defaults to DDN
 *  Return Code > 0 number of lines read
 *               -8 open of file failed
 *  target-var.0  contains number of lines
 *
 * ................ DSN OPEN ... Amended by PeterJ on 12. September 2019
 * ---------------------------------------------------------------------
 */
ReadAll:
parse upper arg _#file,_#var,_#mode,_#maxrec,_#hdr
if _openREADall()<>0 then return -8
/* ........ Read all lines into STEM ................. */
readall.1=read(_#ftk)
/* check if first line contains required header (if any) */
if _#hdr<>'' then do
   if abbrev(readall.1,_#hdr)=0 then do
      readall.0=0
      call close _#ftk
      return -4
   end
end
/* read line 2 and remaining lines  */
do _#i=2 until eof(_#ftk)
   if _#i>_#maxrec then leave
   readall._#i=read(_#ftk)
end
/* ........ Set counter of STEM and close file ........*/
if readall._#i='' then _#i=_#i-1
readall.0=_#i
call close _#ftk
/* ........ Copy STEM if requested ....................*/
if _#var<>'' then return StemCopy('readall.',_#var)
return _#i
/* ---------------------------------------------------------------------
 *  Init Rexx and open File
 * ---------------------------------------------------------------------
 */
_openREADall:
drop readall.
if _#maxrec='' then _#maxrec=99999
if _#var<>'' then interpret 'DROP '_#var
readall.0=0
rdsn=pos('.',_#file)
if _#mode='' & rdsn>0 then _#mode='DSN'
dsfile="'"_#file"'"
/* if _#mode='DSN' then _#ftk=open(dsfile,'rt') */
if _#mode='DSN' then _#ftk=open("'"_#file"'",'rt')
   else _#ftk=open(_#file,'RT')
if _#ftk<0 then do
   if _#mode='DSN' then call RXMSG 300,'E','cannot open DSN '_#file
      else call RXMSG 300,'E','cannot open file '_#file
   return -8
end
return 0
