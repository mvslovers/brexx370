/* BREXX */
/* -----------------------------------------------------------------------------
 * Example:  List Details of a Volume (first argument)
 *                                                                PEJ 27.12.2022
 * -----------------------------------------------------------------------------
 */
rc=listvol(arg(1))              /* Call VTOC to retrieve Volume information */
if rc<8 then call listit 'vol'  /* dump all variables prefix with VOL       */
   else say "Volume '"arg(1)"' not mounted/specified"
return rc
