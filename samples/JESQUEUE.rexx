/* -------------------------------------------------------------
 * JES2 Spool Queue and Viewer
 * -------------------------------------------------------------
 */
  call import fssapi
  ADDRESS FSS
  CALL FSSINIT
do forever
   ADDRESS FSS
  'RESET'
   CALL FSSTITLE 'JES2 Primary Option Menu',#WHITE
   nxt =JESFIELD("Option", "Option ===>",2,1,60)
   call fsstext('Type an Option and press Enter"',4,10,,#white)

   slino=6
   call JESMENU('LOG', 'Display the System Log',slino)
   call JESMENU('DA',  'Display Active Users of the System',slino+1)
   call JESMENU('I',   'Display Jobs in the JES2 Input Queue',slino+2)
   call JESMENU('A',   'Display Jobs Executing',slino+3)
   call JESMENU('O',   'Display Jobs in the JES2 Output Queue',slino+4)
   call JESMENU('H',   'Display Jobs in the JES2 Held Queue',slino+5)
   call JESMENU('SYS', 'Display System Details',slino+6)
   call JESMENU('DASD','Display Available Volumes',slino+7)

   call fssmessage FSSHeight()
   call fsscursor("OPTION")
   call fssdisplay()
  'GET AID AID'
   if aid=243 | aid=244 then return 4
   option=strip(FSSFGET('OPTION'),,'_')
   option=upper(word(option,1))
   if option='LOG'    then do
   /* MTT destructs FSS environment, therefore we need to re-establish it */
      call mttlog     
      ADDRESS FSS
      CALL FSSINIT
   end
   else if option='DA'   then call JES2TSO
   else if option='I'    then call JES2INPUT
   else if option='A'    then call JES2ACT
   else if option='O'    then call JES2
   else if option='H'    then call JES2
   else if option='SYS'  then call JES2SYS
   else if option='DASD' then call JES2DASD
   else if option='ISPF' then call ISPF
   else if option='SPF'  then call ISPF
end
return 0
/* ------------------------------------------------------------
 * JES2 SYS Option
 * ------------------------------------------------------------
 */
JES2SYS:
  BUFFER.1=LEFT("User",12)userid()
  BUFFER.2=LEFT("ISPF",12)sysvar('SYSISPF')
  BUFFER.3=LEFT("Host",12)sysvar('SYSCP')
  BUFFER.4=LEFT("System",12)mvsvar('SYSNAME')
  BUFFER.5=LEFT("CPU",12)mvsvar('CPU')
  BUFFER.6=LEFT("NetID",12)sysvar("SYSNODE")
  BUFFER.7=LEFT("NJE38",12)mvsvar("SYSNJVER")
  BUFFER.8=LEFT("MVS up",12)sec2time(mvsvar("MVSUP"))
  buffer.9=' '
  buffer.10='MVS JOBs/STCs/TSO Users'
  buffer.11='----------------------------------'
  buffer.0=11
/*
  0000  9.27.32 TSU 1339  D A,L
  0000  9.27.32           0000    09.27.32 23.365 ACTIVITY 449
   449    00007 JOBS    00006 INITIATORS
   449   CMD1     CMD1     CMD1      V=V
   449   BSPPILOT BSPPILOT C3PO      V=V  S
   449   JES2     JES2     IEFPROC   V=V
   449   NJE38    NJE38    NJEINIT   V=V
   449   MVSMF    MVSMF    MVSMF     V=V
   449   NET      NET      IEFPROC   V=V
   449   TSO      TSO      STEP1     V=V  S
   449    00002 TIME SHARING USERS
   449    00002 ACTIVE  00040 MAX VTAM TSO USERS
   449   PEJ       PEJ1    S
*/
  Call RUNandFetchConsole 'D A,L','D A,L','ACTIVITY'
  _fmtheader='System Information'
  call fmtlistc
return
/* ------------------------------------------------------------
 * JES2 DASD Option
 * ------------------------------------------------------------
 */
JES2DASD:
/*
0000 10.15.26 TSU 1339  D U,DASD,ONLINE
0000 10.15.26           IEE450I 10.15.26 UNIT STATUS 529

 529 UNIT TYPE STATUS  VOLSER VOLSTATE   UNIT TYPE STATUS  VOLSER VOLSTATE
 529 131  2314 O       SORT01  PUB/RSDNT 132  2314 O       SORT02  PUB/RSDNT
 529 133  2314 O       SORT03  PUB/RSDNT 134  2314 O       SORT04  PUB/RSDNT
*/
  buffer.1='Active DASDs'
  buffer.2='--------------------------------------------------'||,
           '---------------------'
  buffer.0=2
  Call RUNandFetchConsole 'D U,DASD,ONLINE','D U,DASD,ONLINE','UNIT STATUS'
  _fmtheader='MVS DASDs'
  call fmtlistc
return
/* ------------------------------------------------------------
 * JES2 A EXEUTING JOBS
 * ------------------------------------------------------------
 */
JES2ACT:
  buffer.1='Executing Batch Jobs'
  buffer.2='---------------------------------------------------'||,
           '--------------------'
  buffer.0=2
  Call RUNandFetchConsole '$DA,ALL','$DA,ALL',''
  _fmtheader='Executing Jobs'
  _fmtFooter='S displays current run time status of job'
  call fmtlistc 'Monitor'
return
/* ------------------------------------------------------------
 * Executing Batch Jobs
 * -----------------------------------------------------------------------
   17.17.49 JOB 4055  $HASP000 BRXXBTCH EXECUTING A PRIO  4 TK4-
   17.17.49 JOB 4057  $HASP000 BRXXBTCX EXECUTING A PRIO  4 TK4-
 */
MONITOR_S:
  if word(arg(1),6)<>'EXECUTING' then return
  call setg('EXECJOB',word(arg(1),3))
  call mttlog 'filter1'
return 0
filter1:
  parse arg ttarray
  jnum='JOB 'getg('EXECJOB')
  call skeep(ttarray,jnum)
  call sdrop(ttarray,'$HASP000')
return ttarray
/* ------------------------------------------------------------
 * JES2 A EXEUTING JOBS
 * ------------------------------------------------------------
 */
JES2INPUT:
  buffer.1='Input Queue'
  buffer.2='---------------------------------------------------'||,
           '--------------------------------'
  buffer.0=2
  Call RUNandFetchConsole '$DA,ALL','$DA,ALL',''
  Call RUNandFetchConsole '$DN','$DN','','AWAITING EXECUTION'
  _fmtheader='JES2 Input Queue'
  call fmtlistc
return
/* ------------------------------------------------------------
 * Determine active TSO Users
 * ------------------------------------------------------------
 */
JES2TSO:
  call tsousers 'BUFFER.'
  _fmtheader='ACTIVE TSO USERS'
  call FMTLISTC
return
/* ------------------------------------------------------------
 * Run Console Command an pick up the needed part
 * ------------------------------------------------------------
 */
RUNandFetchConsole:
  parse arg xconsole,cmdident,actionstr,mustcontain
  call CONSOLE(xconsole)
  cons1=screate(4096)
  call wait(100)
  call mttx('REFRESH',cons1)
  offset=ssearch(cons1,cmdident)
  newmax=buffer.0
  if mustcontain='' then mustx=0
     else mustx=1
  if actionstr='' then actx=0
     else actx=1
  do sj=offset to 1 by -1
     sline=sget(cons1,sj)
     if pos(cmdident,sline)>0 then iterate
     if actx=1 & pos(actionstr,sline)>0 then do
        actid=lastword(sline)
        iterate
     end
     if actx=1 & word(sline,1)<>actid then iterate
     if mustx=1 then if pos(mustcontain,sline)=0 then iterate
     newmax=newmax+1
     buffer.newmax=subword(sline,2)
  end
  buffer.0=newmax
  call sfree cons1
return
/* ------------------------------------------------------------
 * Define the Menue
 * ------------------------------------------------------------
 */
JESMENU:
  parse arg mselect,mlong,mlino
  nxt=FSSTEXT(mselect,mlino,10,10,#PROT+#HI+#white)
  nxt=FSSTEXT(mlong,mlino,nxt,60,#PROT+#HI+#green)
return
/* ------------------------------------------------------------
 * Define field for the Menue
 * ------------------------------------------------------------
 */
JESfield:
  parse arg var,txt,sgROW,sgcol,inlen,fieldattr,input
  tnxt=FSSTEXT(txt,sgrow,sgcol,,#PROT+#HI+#GREEN)
  if fieldattr='' then fieldattr=#red
  if input='' then 
    fnxt=FSSFIELD(var,sgrow,tnxt,inlen,fieldattr+#uscore,copies(' ',inlen))
  else fnxt=FSSFIELD(var,sgrow,tnxt,inlen,fieldattr+#uscore,input)
return fnxt
