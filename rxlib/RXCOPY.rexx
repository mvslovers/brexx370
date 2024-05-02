/* --------------------------------------------------------------------
 * RXCOPY copy a dataset via IEBCOPY or REPRO
 *     RXCOPY source-dsn, target-dsn,[volume-name]
 *                                               PEJ.....  22. DEC 2022
 * --------------------------------------------------------------------
 */
RXCOPY: Procedure
parse upper arg idsn,odsn,volser,repl
  if odsn='' then parse upper arg idsn','odsn','volser','repl
  idsn=strip(idsn)
  odsn=strip(odsn)
  repl=strip(repl)
  volser=strip(volser)
  say copies('-',72)
  if volser='' then say 'RXCOPY 'idsn' INTO 'odsn repl
     else say 'RXCOPY 'idsn' INTO 'odsn' ON 'volser repl
  say copies('-',72)
  if abbrev('REPLACE',repl,3)>0 then repl=1
     else repl=0
  if idsn='' then signal pidsn
  if odsn='' then signal podsn
  if exists("'"idsn"'")= 0 then signal eidsn
  call listdsix("'"idsn"'")
  if sysntracks='' then sysntracks=0
  if sysdsorg='PO' then rc=__PARTITIONED()
  else if sysdsorg='PS' then rc=__SEQUENTIAL()
  else signal navailable
return rc
/* --------------------------------------------------------------------
 * SEQUENTIAL Copy
 * --------------------------------------------------------------------
 */
__SEQUENTIAL:
  say 'DSN 'idsn' is sequential, invoke REPRO'
  rc=__TARGETPS()
  if rc=0 then ADDRESS TSO "REPRO IDS('"idsn"') ODS('"odsn"')"
return rc
/* --------------------------------------------------------------------
 * PARTITIONED Copy
 * --------------------------------------------------------------------
 */
__PARTITIONED:
  say 'DSN 'idsn' is partitioned, invoke IEBCOPY'
  if __DSNCHECK()<>0 then return 8
  rc=__TARGETPO()
  if rc<>0 then return 8
  call __RXIEBCOPY
  s1=Sread("'"tdsn"'")
  xrc=REMOVE("'"tdsn"'")
  do i=1 to sarray(s1)
     say sget(s1,i)
  end
return xrc
/* --------------------------------------------------------------------
 * Check and Allocate Input DSN and SYSPRINT DSN
 * --------------------------------------------------------------------
 */
__DSNCHECK:
  if allocate('SYSUT1',"'"idsn"'") then signal aidsn
  tdsn=userid()".TEMP.RXCOPY.SYSPRINT"
  call remove("'"tdsn"'")
  if create("'"tdsn"'",'DSORG=PS,RECFM=FB,LRECL=121,'||,
            'BLKSIZE=6050,UNIT=SYSDA,PRI=30,SEC=15')<>0 then return ctdsn(tdsn)
  if allocate('SYSPRINT',"'"tdsn"'")<>0 then return atdsn(tdsn)
return 0
/* --------------------------------------------------------------------
 * Check and Allocate Targer DSN
 * --------------------------------------------------------------------
 */
__TARGETPO:
  tracks=(systracks-sysntracks)*1.5%1
  stracks=1+tracks%10
  dirblks=sysdirblk*1.5%1
  dsdef='DSORG=PO,RECFM='sysrecfm',UNIT=SYSDA,LRECL='||,
    syslrecl',BLKSIZE='sysblksize
  if volser<>"" then 
       dsdef=dsdef',PRI='tracks',SEC='stracks',DIRBLKS='dirblks',VOLSER='volser
     else dsdef=dsdef',PRI='tracks',SEC='stracks',DIRBLKS='dirblks
return __CREATEODSN("'"odsn"'",dsdef)
/* --------------------------------------------------------------------
 * Check and Allocate Target DSN
 * --------------------------------------------------------------------
 */
__TARGETPS:
  tracks=(systracks-sysntracks)*1.5%1
  stracks=1+tracks%10
  dsdef='DSORG=PS,RECFM='sysrecfm',UNIT=SYSDA,LRECL='||,
    syslrecl',BLKSIZE='sysblksize
  if volser<>"" then dsdef=dsdef',PRI='tracks',SEC='stracks',VOLSER='volser
     else dsdef=dsdef',PRI='tracks',SEC='stracks
return __CREATEODSN("'"odsn"'",dsdef)
/* --------------------------------------------------------------------
 * Create Target DSN
 * --------------------------------------------------------------------
 */
__CREATEODSN:
  parse arg codsn,odsndef
  if exists(codsn)>0 then do
     if repl=0 then return noreplace(codsn)
     if remove(codsn)<>0 then return noremove(codsn)
     call isremove(codsn)
  end
  say 'Create 'codsn' with 'odsndef
  rc=CREATE(codsn,odsndef)
  if rc=0 then say codsn' successfully created'
     else say 'failed to create 'codsn', reason: 'rc
return rc
/* --------------------------------------------------------------------
 * Run IEBCOPY
 * --------------------------------------------------------------------
 */
__RXIEBCOPY:
  say "Prepare IEBCOPY "
  rc=allocate('SYSIN',"DUMMY")
  if rc<>0 then return iebmsg('SYSIN')
  rc=allocate('SYSUT2',"'"odsn"'")
  if rc<>0 then return iebmsg('SYSUT2')
  ADDRESS TSO "IEBCOPY"
  say "IEBCOPY completed, RC="rc result
  call free('SYSIN')
  call free('SYSUT2')
  call free('SYSPRINT')
return rc
/* --------------------------------------------------------------------
 * Error Messages
 * --------------------------------------------------------------------
 */
ctdsn: say "Cannot Create temp dataset "arg(1);   return 8
atdsn: say "Cannot Allocate temp dataset "arg(1); return 8
ridsn: say "Cannot Allocate Source dataset: "idsn ; return 8
eidsn: say "Source dataset does not exist: "idsn ; return 8
pidsn: say "Source dataset is mandatory"; return 8
podsn: say "Target dataset is mandatory"; return 8
eodsn: say "Target dataset is missing"; return 8
navailable: say "Dataset Organisation of "idsn" not supported: "sysdsorg ; 
  return 8
noreplace:  say "Target Dataset "arg(1)||,
    " already exists, REPLACE is not specified"; return 8
noremove:   say "Target Dataset "arg(1)" cannot be removed"; return 8
iebmsg:     say "Prepare IEBCOPY failed, "arg(1)" not allocated"; return 8
isremove:   say "Target Dataset "arg(1)||,
    " has been removed, due to remove option "; return 0
