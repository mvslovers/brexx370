/* REXX */
/* ---------------------------------------------------------------------
 * READ all Records of a VSAM File
 * ---------------------------------------------------------------------
 */
ADDRESS TSO
"ALLOC FILE(STUDENTM) DSN('BREXX.VSAM.STUDENTM') SHR"
say 'ALLOC 'rc
/* ---------------------------------------------------------------------
 * OPEN VSAM Mode Update
 * ---------------------------------------------------------------------
 */
"VSAMIO OPEN STUDENTM (READ"
say 'OPENM 'rc' Extended RC 'rcx
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
ADDRESS TSO
"FREE FILE(STUDENTM)"
say 'FREE 'rc
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
