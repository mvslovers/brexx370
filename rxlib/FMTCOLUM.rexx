/* ---------------------------------------------------------------------
 * Create FSS Menu
 * .................................. Created by PeterJ on 31. July 2019
 * ............................... Amended by PeterJ on 05. January 2020
 * ---------------------------------------------------------------------
 */
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
  botline=GetScrIni('footer')
  actionExit=GetScrIni('ActionKey')
 /* ..... Create Title Line ..... */
  call fsstitle title
  call fsScreen columns,count   /* Create Input defs in req. columns  */
  call fssmessage fssscrheight-1
  call fssfooter botline
/* ---------------------------------------------------------------------
 * Display Screen in primitive Dialog Manager and handle User's Input
 * ---------------------------------------------------------------------
 */
  if _screen.Ftrace=1 then call fssftrace 'Entering FMTCOLUM'
  do forever
     fsreturn=FSSusedkey(fssDisplay())    /* Display Screen  */
     if fsexit(fsreturn)=1 then leave  /* QUIT/CANCEL requested */
     if fssTitlemod=1 then do          /* title has Error MSG   */
        call FSSFSET 'ZTITLE',FSSFullTitle /* Reset Message */
        fssTitlemod=0
     end
     if fssLongmsg=1 then do           /* Long Error MSG set  */
        call FSSFSET '#zerrlm',''
        fssLongmsg=0
     end
/*   if fsreturn<>'ENTER' then iterate */
     call fSSgetD()                    /* Read Input Data */
     result=''
     if actionExit=''  then leave
     else do
        interpret 'Call 'actionExit' fsreturn'            /*call Exit */
        if Result=128 then iterate  /* something else done re-display */
        if Result=256 then leave    /* something else done leave      */
        if Result=' ' then leave    /* returns field number in error  */
        if Result=0 then leave      /* returns field number in error  */
        call FSSCURSOR '_SCREEN.INPUT.'result    /* set to field error*/
                                             /* and re-Display Screen */
        iterate
     end
     if fsreturn='ENTER' then leave
  end
  ADDRESS FSS
  'RESET'                             /* Terminate Screen Environment */
  if result=256 then return 'Termination by Exit'
  if _screen.Ftrace=1 then call fssFtrace 'Leaving FMTCOLUM',100
return fsreturn
/* ---------------------------------------------------------------------
 * Is RETURN/CANCEL requested?
 * ---------------------------------------------------------------------
 */
fsexit:
  if fsreturn='PF03' then return 1
  if fsreturn='PF04' then return 1
  if fsreturn='PF15' then return 1
  if fsreturn='PF16' then return 1
return 0
/* ---------------------------------------------------------------------
 * INIT FMTCOLUMN
 * ---------------------------------------------------------------------
 */
colInit:
  if columns<1 then columns=1
  if columns>9 then columns=9
  call fssINIT 'FMTCOLUMN'
  width=FSSWidth()
  height=FSSHeight()
return
