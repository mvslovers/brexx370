/* ---------------------------------------------------------------------
 * Returns Information of the running JOB
 * ............................... Created by PeterJ on 04. January 2019
 * ---------------------------------------------------------------------
 */
JobInfo:
  jobname=strip(STORAGE(d2x(__TIOT()),8))   /* Jobname in TIOT + 0 */
/* ....... Fetch Job Number via JCB ........*/
  _ssib=__ADR(__JSCB()+316)          /* ssib address at JSCB + 316 */
  _jobn=storage(d2x(_ssib+12),8)     /* job number at ssib + 12    */
  _jobn=translate(_jobn,'0',' ')     /* fix leading zeros for tso  */
  jobNumber=strip(_jobn)
/* ....... Fetch Step Name from TIOT via TCB .......*/
  _proc=strip(STORAGE(d2x(__TIOT()+8),8))  /* STEP/PROCNAME          */
  _step=strip(STORAGE(d2x(__TIOT()+16),8)) /* STEP Name(if PROCNAME )*/
  if _step='' then stepname=_proc
     else stepname=_proc'.'_step
/* ....... Fetch Program Name from the EXEC Statement ..... */
  programName=STORAGE(d2x(__JSCB()+360),8)
return 0
/* ---------------------------------------------------------------------
 * Address some MVS Control Blocks
 * ---------------------------------------------------------------------
 */
__TCB: return __ADR(540)        /* TCB address at 540 = '21C'X of PSA*/
__TIOT: return __ADR(__TCB()+12) /* __TIOT address at TCB+12 */
__JSCB: return __ADR(__TCB()+180)
__ADR: return c2d(STORAGE(d2x(arg(1)),4)) /* return decimal pointer */
