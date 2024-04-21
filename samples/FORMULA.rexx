/* REXX */
/* --------------------------------------------------------------------
 * Formula Editor based on Moshe's Calculator       pej 8. January 2023
 * --------------------------------------------------------------------
 */
 call import fssapi
 call forminit
 ADDRESS FSS
 retry:       /* this is the retry label, in case an error occurred */
 do forever
    signal off syntax
    RCKEY=FSSREFRESH()
    if rckey=#PFK03 then leave
    call fetchvars                  /* fetch & check input variables */
    signal on syntax name calcerror /* error exit for formula line   */
    if formula='' then do
       call dumpinput 'Formula is a mandatory field'
       iterate
    end
    interpret 'result='formula         /* try to run it              */
    CALL FSSFSET  'RESULT',result   /* was successful, set result    */
    CALL FSSCOLOR 'RESULT',#YELLOW
    CALL FSSCURSOR 'RESULT'
 end
 call fssclose
exit 0
/* --------------------------------------------------------------------
 * Fetch input variables
 * --------------------------------------------------------------------
 */
fetchvars:
    signal on syntax name varerror
    formula=strip(fssfget('FORMULA'))  /* fetch it                   */
    do i=0 to 9
       variable.i=strip(FSSFGET('VAR'i))
    end
    do i=0 to 9
       if variable.i='' then iterate
       if pos('=',variable.i)=0  then signal varerror
       if variable.i<>'' then interpret variable.i
    end
return
/* --------------------------------------------------------------------
 * Input Variables are in error
 * --------------------------------------------------------------------
 */
varerror:
  xi=i+1
  signal off syntax
  call dumpinput "Variable "xi" in error, required format vname=..."
  signal retry
return
/* --------------------------------------------------------------------
 * Formula is in error
 * --------------------------------------------------------------------
 */
calcerror:
  signal off syntax
  call dumpinput 'Calulation in error, check Formula and Variables: '
  signal retry
return
/* --------------------------------------------------------------------
 * Dump input in case of any error
 * --------------------------------------------------------------------
 */
dumpinput:
  buffer.1=arg(1)
  buffer.2="Formula "formula
  j=2
  do i=0 to 9
     if variable.i='' then iterate
     j=j+1
     buffer.j="Variable "i+1" = '"variable.i"'"
  end
  buffer.0=j
  call fmtlist 0     /* call fmtlist to show error lines  */
  call forminit 1    /* re-init formula FSS fields        */
  call FSSFSET('Formula',formula)
  do i=0 to 9
     if variable.i='' then iterate
     call FSSFSET('VAR'i,variable.i)
  end
return
/* --------------------------------------------------------------------
 * Init Formula Editor
 * --------------------------------------------------------------------
 */
forminit:
  BCIN = " "
  BCOUT = " "
  RESULT = " "
 ADDRESS FSS
/* 3. ENABLE FULL SCREEN MODE */
  CALL FSSINIT
  RESULTS=''
  CALL FSSTITLE   'Formular Editor',#WHITE
  slino=4
  CALL FSSTEXT  "Variable(s)",slino,19,  ,#PROT+#TURQ
  do i=0 to 9
     CALL FSSTEXT  "="right(i+1,2,"=")"=>"     ,slino+i,28,  ,#PROT+#HI+#GREEN
     CALL FSSFIELD 'VAR'i     ,slino+i,34,40,''
  end
  CALL FSSTEXT  "Formula  ",slino+11,19,  ,#PROT+#TURQ
  CALL FSSTEXT  "====>"     ,slino+11,28,  ,#PROT+#HI+#GREEN
  CALL FSSFIELD 'Formula'  ,slino+11,34,40                   ,''
  CALL FSSTEXT  "Result   ",slino+13,19,  ,#PROT+#TURQ
  CALL FSSTEXT  "====>"     ,slino+13,28,  ,#PROT+#HI+#GREEN
  CALL FSSFIELD 'Result'   ,slino+13,34,40,''
  CALL FSSTEXT( "PF3=TERMINATE" ,FSSHEIGHT(), 1,  ,#PROT+#HI)
  CALL FSSCURSOR 'VAR0'
  if arg(1) =1 then return  /* do not refresh variable fields  */
  do i=0 to 9
     variable.i=''
  end
return
