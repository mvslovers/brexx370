/* -------------------------------------------------------------
 * JES2 Spool Queue and Viewer
 * -------------------------------------------------------------
 */
spool=JESQUEUE()
if spool<0 then return 8
   _screen.TopRow=2
   _screen.TopRow.proc='spoolhdr'
   _screen.footer='Linecmd S view, SJ create JCL, P purge,'||,
                  ' O send to class, XDC export to dsn'
   _screen.message=1
   _screen.lina2=1
   buffer.0='ARRAY 'spool
 xm=arg(1)
 call FMTLIST ,,'Job Name   Number    QUEUE   STATUS   LINES',,'SPOOL'
return 0
/* -------------------------------------------------------------
 * Creates header lines of FMTLIST
 * -------------------------------------------------------------
 */
spoolhdr:
   call fsstext('JES2 Spool Queue of 'MVSVAR('SYSNAME'),1,20,,#white)
return
/* -------------------------------------------------------------
 * JES2 empty Enter Key without    **** not yet used
 *  requires _screen.enter.proc='JESenter' prior to FMTLIST Call
 * -------------------------------------------------------------
 */
JESenter:
   parse value arg(1) with "'"scrbuffer"'"
   changedL=getg('__Lastl')
   if datatype(changedL)<>'NUM' then changedL=0
   changedL=changedl+1
   if changedL>sarray(scrbuffer) then return
   call setg('__Lastl',changedL)
   jesline=sget(scrbuffer,changedL)
   call spool_det jesline
   call sset(scrbuffer,changedL,newline)
return 0
/* -------------------------------------------------------------
 * JES2 REFRESH
 * -------------------------------------------------------------
 */
SPOOL_Primary:
  parse arg primary
  if primary='REFRESH' then do
     spool=JESQUEUE()
     call s2stem spool,'buffer.'
     return 6
  end
return 0
/* -------------------------------------------------------------
 * JES2 SPF Selection View Entry IN SPF Browse
 * -------------------------------------------------------------
 */
spool_s:
  importname='JES2.TEMP'
  if Spool2DSN(importname,arg(1))<0 then return 0
  ADDRESS TSO "REVIEW '"userid()"."importname".OUTLIST'"
return 0
/* -------------------------------------------------------------
 * JES2 DET Selection fetch Line Count
 * -------------------------------------------------------------
 */
spool_det:
  importname='JES2.TEMP'
  if Spool2DSN(importname,arg(1))<0 then return 0
  lines=LISTDSIQ(userid()"."importname".OUTLIST",'RECORDS')
  newline=strip(arg(1),'t')
  newline=overlay(right(sysrecords,6),newline,38)
  call remove("'"userid()"."importname".OUTLIST'")
return 4
/* -------------------------------------------------------------
 * JES2 SJ Selection to Edit JCL
 * -------------------------------------------------------------
 */
spool_sj:
  importname='JES2.TEMP'
  if Spool2DSN(importname,arg(1))<0 then return 0
  sout1=SREAD("'"userid()"."importname".OUTLIST'")
  call remove("'"userid()"."importname".OUTLIST'")
  jclError=ssearch(sout1,'IEF452I JOBFAIL')
  sstring=SearchFirst('STMT NO. MESSAGE','IEF236I','IEF373I')
  if sstring='' | pos('IEF373I',sstring)>0 then do
     call zError('not expandable',
                 'Incomplete JCL found, MSGLV might be too low')
     return 0
  end
  else sout2=SCUT(sout1,,sstring)
  call sfree sout1
  sout3=screate(sarray(sout2))
  jcl=0
  lnum=0
  do sj=1 to sarray(sout2)
     sjline=sget(sout2,sj)
     if jcl=0 then if pos('    1     //',sjline)=0 then iterate
     if jclError>0 &  pos('   2     //',sjline)>0 then inerrmsg=1
     sjline=substr(sjline,11,80)
     inline=substr(sjline,1,2)
     if inline='XX' then iterate
     if inline='X/' then iterate
     if inline='++' then iterate
     if inline='+/' then iterate
     if substr(sjline,1,3)='***' then sjline='//*'substr(sjline,4)
     lnum=lnum+1
     lpi=pos('PASSWORD= ',sjline)
     if lpi>1 then do
        if substr(sjline,lpi-1,1)=',' then lpi=lpi-1
        sjline=substr(sjline,1,lpi-1)
     end
     snum=substr(sjline,73,8)
     if datatype(snum)<>'NUM' then sjline=substr(sjline,1,72)right(lnum,8,'0')
     call sset(sout3,,sjline)
     if substr(sjline,1,2)='//' &,
          word(sjline,2)='DD' & word(sjline,3)='*' then do
        lnum=lnum+1
        call sset(sout3,,left('   *** INLINE Data cannot be extracted,'||,
                              ' inserted by SJ ***',72)right(lnum,8,'0'))
        lnum=lnum+1
        call sset(sout3,,left('/* *** INSERTED BY SJ',72)right(lnum,8,'0'))
     end
     if inerrmsg>0 then do
        inerrmsg=0
        lnum=lnum+1
        jclError=0
        call sset(sout3,,  ,
          left('//* *** JCL CONTAINS SYNTAX ERROR, CHECK LISTING,'||,
               ' inserted by SJ ***',72)right(lnum,8,'0'))
     end
     jcl=1
  end
  tdsn='Temp.SJCL'
  call create(tdsn,'RECFM=FB,LRECL=80,BLKSIZE=8000,UNIT=SYSDA,PRI=30,SEC=60')
  call swrite(sout3,"'"userid()"."tdsn"'")
  call sfree sout2
  call sfree sout3
  ADDRESS TSO "REVED "tdsn
  call remove(tdsn)
return 0
/* -------------------------------------------------------------
 * Find in JCL Output the best fitting JCL end string
 * -------------------------------------------------------------
 */
SearchFirst:
  rstr=''
  sy=9999999
  do sj=1 to arg()
     sx=ssearch(sout1,arg(sj))
     if sx<1 then iterate
     if sx<sy then do
        sy=sx
        rstr=arg(sj)
      end
  end
return rstr
/* -------------------------------------------------------------
 * JES2 OUT Selection Save Output to DSN
 * -------------------------------------------------------------
 */
spool_xdc:
  importname='JES2.'word(arg(1),1)'.'word(arg(1),2)
  if Spool2DSN(importname,arg(1))<0 then return 0
  call zError(jobname' exported',
              jobname' exported to 'userid()"."importname'.OUTLIST')
return 0
/* -------------------------------------------------------------
 * JES2 P(urge) Selection Save Output to DSN
 * -------------------------------------------------------------
 */
spool_p:
  jobname=word(arg(1),1)
  jobnum =word(arg(1),2)
  queue  =word(arg(1),3)
  if queue='RUNNING' then ADDRESS TSO "CANCEL "jobname"("jobnum")"
  else do
     call outtrap(smsgP.)
    ADDRESS TSO "OUTPUT "jobname"("jobnum") CLASS(H) DELETE"
     call outtrap('OFF')
     if symbol('smsgP.1')='VAR' then do
        call zError('not purged',smsgp.1)
        return 0
     end
  end
  newline=strip(arg(1),'T')'     *** purged'
  call zError(jobname' purged',jobname'('jobnum') has been purged')
return 4
/* -------------------------------------------------------------
 * JES2 M(ove) Selection Save Output to 1403 Printer
 * -------------------------------------------------------------
 */
spool_O:
  jobname=word(arg(1),1)
  jobnum =word(arg(1),2)
  queue  =word(arg(1),3)
  newc=upper(getg('_linecmd2'))
  newl=length(newc)
  if newl=0 | newl>1 | datatype(newc)='NUM' then do
     call zError('invalid Class',"invalid Class='"newc"'")
     return 0
  end
 call outtrap(smsge.)
  ADDRESS TSO "OUTPUT "jobname"("jobnum") NEWCLASS("newc")"
 call outtrap('OFF')
  if symbol('smsge.1')='VAR' then do
     call zError('not moved',smsge.1)
     return 0
  end
  call zError(jobname' in 'newc,jobname'('jobnum') moved to new Class 'newc)
return 4
/* -------------------------------------------------------------
 * JES2 Save Output to DSN
 * -------------------------------------------------------------
 */
Spool2DSN:
  parse arg intoDSN,jline
  jobname =word(jline,1)
  jobt    =word(jline,2)
  jobqueue=word(jline,3)
  jobhold =word(jline,4)
  jobname =jobname'('jobt')'
  call outtrap(smsg.)
 ADDRESS TSO
/* "OUTPUT "jobname" CLASS(H) PRINT("intoDSN") KEEP HOLD" */
   "OUTPUT "jobname" PRINT("intoDSN") KEEP HOLD"
  call outtrap('OFF')
  if symbol('smsg.1')='VAR' then do
     call zError('no Output',smsg.1)
     return -8
  end
return 0
/* -------------------------------------------------------------
 * JES2 Save Output to DSN
 * -------------------------------------------------------------
 */
zError:
  zerrsm=arg(1)
  zerrlm=arg(2)
return
