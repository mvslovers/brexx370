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
 * Read Student Records via Key
 * ---------------------------------------------------------------------
 */
say ReadStudent('Ben','Anderson')
say ReadStudent('Gabriel','Anderson')
say ReadStudent('Arlene','Baldwin')
say ReadStudent('Patricia','Stephenson')
/* ---------------------------------------------------------------------
 * CLOSE VSAM Dataset
 * ---------------------------------------------------------------------
 */
"VSAMIO CLOSE STUDENTM"
say 'CLOSEM 'rc' Extended RC 'rcx
frc=free('STUDENTM')
say 'FREE 'frc
return 0
/* ---------------------------------------------------------------------
 * Read Record via Key
 * ---------------------------------------------------------------------
 */
ReadStudent:
parse arg cname,fname
  inkey=translate(left(fname';'cname,28,'_')) /* Key is upper case */
 "VSAMIO READ  STUDENTM (KEY "inkey" UPDATE VAR Student"
  if rc>0 then return fname','cname' Record not found'
return substr(student,29)   /* drop key part */
