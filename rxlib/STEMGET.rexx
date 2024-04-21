/* ...... Write Statistical Information ............................ */
/* ...... Cleanup and Close Procedure .............................. */
/* ---------------------------------------------------------------------
 * STEMGET    Imports a saved STEM Variable
 *   count=STEMGET(dataset-name)
 *     dataset-name   must be fully qualified
 *     count          returns number of stem entries imported
 *                    if count <0 open of dsn failed
 * ................................. Created by PeterJ on 10. April 2019
 * ................ DSN OPEN ... Amended by PeterJ on 12. September 2019
 * ---------------------------------------------------------------------
 */
stemget:
parse arg dsn
_t=time('e')
/* ...... Open Dataset ............................................. */
_STMFL=open("'"dsn"'",'RT','DSN')
if _STMFL<=0 then do
   call RXMSG 500,'E','cannot open Dataset: 'dsn
   return -8
end
#i=0
/* ...... Read store STEM(s) and re-apply them ..................... */
do until eof(_stmfl)
   _#line=read(_stmfl)
   _ls=substr(_#line,1,1)
   if _ls=';' then iterate
   if _ls=' ' then iterate
   interpret _#line
   #i=#i+1
end
/* ...... Cleanup and Close Procedure .............................. */
call close _STMFL
execTime=trunc(time('e')-_t,2)
return #i
