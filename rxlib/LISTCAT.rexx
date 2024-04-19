/* ---------------------------------------------------------------------
 * LISTCAT Return LISTCAT Output in STEM variable LISTCAT.
 * .............................. Created by PeterJ on 17. February 2021
 * ---------------------------------------------------------------------
 */
LISTCAT: procedure expose listcat.
  parse upper arg lparm,filter
  rc=lcatini()
  if rc=4 then signal noCreate
  if rc=8 then signal noAlloc
ADDRESS TSO
 "LISTCAT "lparm" OUTFILE("ddn")"
  if rc<>0 then signal nocat
  _lccat=open(ddn,'RT')
  if filter='DETAILS' then call listDetails
  else call listFilter
  call close _lccat
  call free ddn
  call remove(dsn)
return lrc
/* ---------------------------------------------------------------------
 * LISTCAT Details return output as is from LISTCAT
 * ---------------------------------------------------------------------
 */
listDetails:
  i=0
  do until eof(_LCCAT)
     line=strip(substr(read(_lccat),2))
     if line='' then iterate
     if pos('IDCAMS  SYSTEM SERVICES',line)>0 then iterate
     i=i+1
     listcat.i=line
  end
return
/* ---------------------------------------------------------------------
 * LISTCAT filtered by certain information type
 * ---------------------------------------------------------------------
 */
listFilter:
  i=0
  do until eof(_LCCAT)
     line=substr(read(_lccat),2)
     if strip(line)='' then iterate
     if pos('IDCAMS  SYSTEM SERVICES',line)>0 then iterate
     if pos(word(line,1),filter)=0 then iterate
     i=i+1
     listcat.i=word(line,3)
  end
  listcat.0=i
return
/* ---------------------------------------------------------------------
 * Error Exits
 * ---------------------------------------------------------------------
 */
noAlloc:
  say 'Temporary DSN cannot be allocated'
return 8
noCreate:
  say 'Temporary DSN cannot be created'
return 8
noCat:
  say 'LISTCAT function failed'
return 8
/* ---------------------------------------------------------------------
 * INIT LISTCAT
 * ---------------------------------------------------------------------
 */
lcatini:
  if lparm='' then lparm=userid()
  if filter<>'DETAILS' & substr(lparm,1,3)<>'LV(' then lparm='LV('lparm')'
  if filter='' then filter='NONVSAM'
     else if filter='DSN' then filter='NONVSAM CLUSTER DATA INDEX'
  drop listcat.
  listcat.0=0
  ddn='T'right(time('MS')*1000,7)
  dsn='temp.$listc.'ddn
  rc=create(dsn,'recfm=vb,lrecl=133,blksize=6650,unit=sysda,pri=5')
  if rc=-1 then return 4
  if allocate(ddn,dsn)<>0 then return 8
return 0
