/* ---------------------------------------------------------------------
 * Returns current JES 2 Queue in an array
 * ---------------------------------------------------------------------
 */
JESQUEUE: procedure
  call CONSOLE('$DA,ALL')
  call CONSOLE('$DN')
  SPOOL1=screate(4096)
  call wait(100)
  call mttx(1,SPOOL1)
  SPOOL2=scut(SPOOL1,"SPOOL UTILIZATION","$DA,ALL")
  call sfree(SPOOL1)
  if spool2<0 then signal spoolError1
  SPOOL1=Sselect(SPOOL2,"$HASP000")
  if spool1<0 then signal spoolError1
  call sfree(SPOOL2)
  call ssubstr(SPOOL1,15,,'INTERNAL')
  SPOOL2=screate(sarray(SPOOL1))
  do i=1 to sarray(SPOOL1)
     record=$joblist(sget(SPOOL1,i))
     if record='' then iterate
     call sset(SPOOL2,,record)
  end
  call sqsort(SPOOL2)
return spool2
$joblist:
   if pos('$HASP000 NO ACTIVE JOBS',arg(1))>0 then return ''
   parse value arg(1) with jobt' 'jobnum'  'hasp' 'jobname' 'q1' 'n
   jobt    =left(word(arg(1),1),3)
   jobnum  =strip(word(arg(1),2))
   jobt    =jobt||right(jobnum,5,'0')
   jobname =word(arg(1),4)
   jobqueue=word(arg(1),5)word(arg(1),7)
   jobhold =word(arg(1),11)
   if pos('AWAITING OUTPUT',arg(1))>0 then jobqueue='OUTPUT'
   else if pos('EXECUTING',arg(1))>0 then jobqueue='RUNNING'
   jline=left(jobname,10)' 'jobt'  'left(jobqueue,7)' 'jobhold
return jline
SpoolError1:
  say 'No Spool available'
return -8
