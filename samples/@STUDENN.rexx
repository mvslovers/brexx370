/* REXX */
/* ---------------------------------------------------------------------
 * READ all Records of a VSAM File
 * ---------------------------------------------------------------------
 */
/* ALLOCATE() works in a batch step without TSO; ADDRESS TSO "ALLOC"
 * would answer -3 there. It replaces a STUDENTM DD of the step. */
arc=allocate('STUDENTM',"'BREXX.VSAM.STUDENTM'")
say 'ALLOC 'arc
if arc<>0 then do
   say 'ALLOC of BREXX.VSAM.STUDENTM failed, RC 'arc
   return 8
end
/* ---------------------------------------------------------------------
 * OPEN VSAM Mode Update
 * ---------------------------------------------------------------------
 */
"VSAMIO OPEN STUDENTM (READ"
say 'OPENM 'rc' Extended RC 'rcx
if rc<>0 then do
   orc=rc
   call free 'STUDENTM'
   return orc
end
/* ---------------------------------------------------------------------
 * Read Student Records via Locate and NEXT
 * ---------------------------------------------------------------------
 */
  prefix='STE'     /* Locate Students who start with STE */
 "VSAMIO LOCATE STUDENTM (KEY "prefix
  say 'Locate 'rc' Extended RC 'rcx
  do forever
     "VSAMIO READ STUDENTM (NEXT UPDATE VAR Student"
      if rc<>0 then leave
      say 'Read Next 'rc' Extended RC 'rcx
      if abbrev(student,prefix)=0 then leave
      say '>>> 'substr(student,29)   /* drop key part */
  end
/* ---------------------------------------------------------------------
 * CLOSE VSAM Dataset
 * ---------------------------------------------------------------------
 */
"VSAMIO CLOSE STUDENTM"
say 'CLOSEM 'rc' Extended RC 'rcx
frc=free('STUDENTM')
say 'FREE 'frc
return 0
