/* ---------------------------------------------------------------------
 * Request Input from user via Formatted Screen in 3 Column Format
 * ---------------------------------------------------------------------
 */
FMTCOLUM: Procedure Expose _screen.
  parse arg columns,title
  call import FSSAPI
  ADDRESS FSS
  call colInit
  count=arg()-2
 /* ..... Copy Input Parms in Stem ..... */
  do i=1 to count
     iparm.i=arg(i+2)
  end
 /* ..... Create Title Line ..... */
  call fsstitle title
  call fsScreen columns,count   /* Create Input defs in req. columns  */
/* ---------------------------------------------------------------------
 * Display Screen in primitive Dialog Manager and handle User's Input
 * ---------------------------------------------------------------------
 */
  do forever
     fsreturn=usedkey(fssDisplay())    /* Display Screen  */
     if fsexit(fsreturn)=1 then leave  /* QUIT/CANCEL requested */
     if fssTitlemod=1 then do          /* title has Error MSG   */
        call FSSFSET 'ZTITLE',FSSFullTitle /* Reset Message */
        fssTitlemod=0
     end
     if fsreturn<>'ENTER' then iterate
     call fSSgetD()                    /* Read Input Data */
     if symbol('_screen.CallBack')<>'VAR' then leave
     interpret 'fieldinError='_Screen.CallBack'()' /* Back Call Caller*/
     if fieldinError=0 then leave      /* returns field num in error  */
     call FSSCURSOR '_SCREEN.INPUT.'fieldinError /* set to field error*/
                                       /* and re-Display Screen       */
  end
  call fssclose                       /* Terminate Screen Environment */
return fsreturn
/* ---------------------------------------------------------------------
 * Is RETURN/CANCEL requested?
 * ---------------------------------------------------------------------
 */
fsexit:
  if fsreturn='F03' then return 1
  if fsreturn='F04' then return 1
  if fsreturn='F15' then return 1
  if fsreturn='F16' then return 1
return 0
/* ---------------------------------------------------------------------
 * INIT FMTCOLUMN
 * ---------------------------------------------------------------------
 */
colInit:
  if columns<1 then columns=1
  if columns>9 then columns=9
  call fssINIT
  width=FSSWidth()
  height=FSSHeight()
return
