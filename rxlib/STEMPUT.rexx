/* ---------------------------------------------------------------------
 * STEMPUT    save one or several stems to a dataset
 *   rc=STEMPUT(dataset-name,stem1[,stem2][...][,stemn]
 *     dataset-name   must be fully qualified
 *     stemi          stem-name must have trailing period sign
 *     rc             0    stem has been successfuly exported to dsn
 *                   -4    no stem entry has been exported
 *                   -8    dataset is not available, or cannot be opened
 * ................................. Created by PeterJ on 10. April 2019
 * ................ DSN OPEN ... Amended by PeterJ on 12. September 2019
 * ---------------------------------------------------------------------
 */
stemput:
parse arg dsn,vars2dump
_t=time('e')
_numsc=0
/* ...... Open Dataset ............................................. */
_stmfl=open("'"dsn"'",'WT')
if _stmfl<=0 then do
   call RXMSG 500,'E','cannot open Dataset: 'dsn
   return -8
end
/* ...... Write Statistical Information ............................ */
rc=write(_stmfl,'; CREATED: 'date()' 'time('l'),nl);
do _#i=2 to arg()
   rc=write(_stmfl,'; STEM: 'arg(_#i),nl);
end
/* ...... Dump Stem Variable in Dataset ............................ */
do _#i=2 to arg()
   stemv=arg(_#i)
   if substr(stemv,length(stemv),1)<>'.' then do
      call RXMSG 510,'E','invalid STEM: 'stemv', must end with period sign'
      iterate
   end
   _numsc=max(write(_stmfl,vardump(arg(_#i))),_numsc)
end
/* ...... Cleanup and Close Procedure .............................. */
_t=trunc(time('e')-_t,2)
execTime=_t
rc=write(_stmfl,'; Completed: 'date()' 'time('l')' in '_t' seconds',nl);
call close _stmfl
if _numsc>0 then return 0
return -4
