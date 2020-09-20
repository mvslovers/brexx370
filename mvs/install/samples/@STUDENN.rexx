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
ADDRESS TSO
"FREE FILE(STUDENTM)"
say 'FREE 'rc
return 0
