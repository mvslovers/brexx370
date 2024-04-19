/* REXX */
/* ---------------------------------------------------------------------
 * Display NJE38 Spool Directory in FMT Buffer
 * ---------------------------------------------------------------------
 */
nje38Status=userid()
useispf=1
public='nje38Status useispf public' /* keep alive in FMTLIST et. al. */
if nje38LST('TSO')>0 then return 8
_screen.footer= ,
    'F1 Help F3/F4 End ',
    'F7/F8 Scroll - Line P(Purge) R(Receive) B(Browse) I(Info)'
_screen.Title1='NJE38 Spool Browser'
_screen.Message=1
public='nje38v.'
call FMTLIST 1,'.',hdr1,hdr2,'NJE38'
return
/* ---------------------------------------------------------------------
 * FMTLIST PRINT (s) Command also Browse (b)
 * ---------------------------------------------------------------------
 */
NJE38_b:
  signal off syntax
  signal on syntax name invcall
  if getnjeFile(arg(1))>0 then return 4
  tempFile='TEMP.NJE38REC'
  rrc=remove(tempfile)
  result=0   /* Clear Result for Receive command */
  rc=0
Address TSO
 'RECEIVE 'njefile' DA('tempfile') NOPURGE QUIET'
  srs=result
  if srs<> 0 then signal invCall
  if ReceiveResult(tempFile,'Temporary')>0 then return 4

  Origin=word(arg(1),2)'.'word(arg(1),3)
  if sysdsorg='PO' then call nje38pds(sysdsname,njefile,origin,sysrecfm)
  else call _showFile sysdsname,njefile,origin
signal return2Caller
/* ---------------------------------------------------------------------
 * FMTLIST Show details of Spool File  (s/i)
 * ---------------------------------------------------------------------
 */
NJE38_i:
NJE38_s:
  signal off syntax
  signal on syntax name invcall
  if getnjeFile(arg(1))>0  then signal invcall
  nrc=NJE38LLIB('INF','FSS')
  if nrc>0 then return nrc
  nje38date=cvtodclock(nje38date)
  parse value value('nje38msg_000001') with ,
        fno snode susr tnode tusr class recs otime
  buffer.0=0
  CALL PUSHBUF copies('-',72)
  CALL PUSHBUF 'Details of File Number 'fno' Created on 'nje38date
  CALL PUSHBUF copies('-',72)
  orgdsn=substr(word(value('nje38msg_000004'),2),5)
  orgdsn=strip(translate(orgdsn,' ','00'x))
  if orgdsn='' then orgdsn='unknown'
  CALL PUSHBUF 'Original DSN  'orgdsn
  line=value('nje38msg_000003')
  parse value word(line,2) with ,
        blksize'/'lrecl'/'recfm'/'dsorg
  CALL PUSHBUF '  DSORG       'dsorg
  CALL PUSHBUF '  RECFM       'recfm
  CALL PUSHBUF '  LRECL       'lrecl
  CALL PUSHBUF '  BLKSIZE     'blksize
  pi=pos('DIRBLKS:',line)
  if pi>0 then do
     dirb=word(substr(line,pi),2)
     CALL PUSHBUF '  DIRBLKS     'dirb
  end
  pi=pos('Size',line)
  if pi>0 then do
     line=substr(line,pi+6)
     CALL PUSHBUF '  SIZE        'line
  end
  CALL PUSHBUF 'Sender '
  CALL PUSHBUF '  Node        'snode
  CALL PUSHBUF '  Userid      'susr
  CALL PUSHBUF 'Receiver'
  CALL PUSHBUF '  Node        'tnode
  CALL PUSHBUF '  Userid      'tusr
  CALL PUSHBUF '  Class       'class
  CALL PUSHBUF 'Spool Records 'recs
  _screen.Title1='NJE38 File ('fno') ORIGIN 'snode
  call FMTLIST 1,'.'
signal return2Caller
/* ---------------------------------------------------------------------
 * FMTLIST RECEIVE (r) Command
 * ---------------------------------------------------------------------
 */
NJE38_r:
  signal off syntax
  signal on syntax name invcall
  if getnjeFile(arg(1))>0 then return 4
    /* arg(2) is line number of selected command*/
  tdsn=OfferInput(arg(2),'Enter Receiving Dataset Name',56)
  if #action<>'ENTER' then return 4
  _refresh=10
  if tdsn<>'' then rdsn='DATASET('tdsn')'
  else do
     zerrsm=njefileSTR' not received'
     zerrlm=njefileSTR' not received, target DSN missing'
     return 4
  end
  result=0   /* Clear Result for Receive command */
  rc=0
Address TSO
 'RECEIVE 'njefile rdsn' NOPURGE QUIET'
  srs=result
  if srs<> 0 then signal invCall
  if ReceiveResult(tdsn)>0 then return 4
  zerrsm=njefileSTR' received'
  zerrlm=njefileSTR' successfully received'
  Origin=word(arg(1),2)'.'word(arg(1),3)
  call listdsi(tdsn)
  if sysdsorg='PO' then call nje38pds(sysdsname,njefile,origin,sysrecfm)
  else call _showFile sysdsname,njefile,origin
  _refresh=1
signal return2caller
/* ---------------------------------------------------------------------
 * FMTLIST Message Command
 * ---------------------------------------------------------------------
 */
NJE38_m:
  signal off syntax
  signal on syntax name invcall
  mnode=word(arg(1),2)
  muser=word(arg(1),3)
    /* arg(2) is line number of selected command*/
  tmsg=OfferInput(arg(2),'Enter Message to send',76)
  if #action<>'ENTER' then return 4
  _refresh=10
  if tmsg='' then do
     zerrsm='no Message text'
     zerrlm='no Message text supplied'
     return 4
  end
  result=0   /* Clear Result for NJE38 command */
  rc=0
Address TSO
 'NJE38 M 'mnode' 'muser' 'tmsg
 if rc>4 then signal invCall
 zerrsm='Message sent'
 zerrlm='Message sent to 'mnode' 'muser
signal return2caller
/* ---------------------------------------------------------------------
 * FMTLIST PURGE (r) Command
 * ---------------------------------------------------------------------
 */
NJE38_p:
  signal off syntax
  signal on syntax name invcall
  if getnjeFile(arg(1))>0  then return 4
  nrc=NJE38LLIB('CAN','FSS')
  if nrc>0 then return nrc
  do i=1 to maxc
     j=right(i,6,'0')
     zerrsm=value('nje38msg_'j)
     zerrlm=value('nje38msg_'j)
  end
  if nrc=0 then do
     newline='-- purged --'
     signal return2caller
  end
return 0
/* ---------------------------------------------------------------------
 * Just a Dummy Selection to test Line Command is working
 * ---------------------------------------------------------------------
 */
NJE38_t:
  signal off syntax
  if getnjeFile(arg(1))>0  then return 4
  zerrsm=njefileSTR' tested'
  zerrlm=njefileSTR' successfully tested'
  newline='-- tested --'
signal return2caller
/* ---------------------------------------------------------------------
 * Test created File after RECEIVE
 * ---------------------------------------------------------------------
 */
ReceiveResult:
  rfile=arg(1)
  rtype=arg(2)
  if rtype<>'' then rtype=rtype' '
  rc=listdsi(rfile)
  if rc>0 then do
     njefile=njefile%1
     nrc=NJE38LLIB('INF','FSS')
     line=value('nje38msg_000003')
     parse value word(line,2) with ,
           blksize'/'lrecl'/'recfm'/'dsorg
     zerrsm=rfile' not available'
     if lrecl>133 then ,
     zerrlm=rtype'DSN 'rfile' exceeds maximum LRECL of 133, is: 'Lrecl
     else zerrlm=rtype'DSN 'rfile' not available'
     return 4
  end
return 0
/* ---------------------------------------------------------------------
 * NJE38 Call return success/failed
 * ---------------------------------------------------------------------
 */
return2Caller:
  signal off syntax
  setcolor1=62720
  setcolor2=62976
return 0
invCall:
  signal off syntax
  zerrsm=njefileSTR' action failed'
  zerrlm=njefileSTR' was not processed due to errors'
  setcolor1=62720
  setcolor2=62976
return 4
/* ---------------------------------------------------------------------
 * NJE38 HELP
 * ---------------------------------------------------------------------
 */
nje38_help:
  buffer.0=0
  CALL PUSHBUF copies('-',72)
  CALL PUSHBUF 'NJE38DIR HELP'
  CALL PUSHBUF copies('-',72)
  CALL PUSHBUF 'Primary Commands'
  CALL PUSHBUF '  STATUS  <*/userid>'
  CALL PUSHBUF '          *      displays full content of the NJE38 Spool'
  CALL PUSHBUF '          userid displays user related content'
  CALL PUSHBUF '          the default option is user related'
  CALL PUSHBUF '  REFRESH refresh directory List'
  CALL PUSHBUF '  RESET   reset colors to default'
  CALL PUSHBUF '  HELP    display this help screen'
  CALL PUSHBUF 'Line Commands'
  CALL PUSHBUF '  B  View File content'
  CALL PUSHBUF '  S  View File details'
  CALL PUSHBUF '  R  Receive File'
  CALL PUSHBUF '  P  Purge File'
  CALL PUSHBUF '  M  send a reply to the sender of a file'
  _screen.footer='F3/F4 End '
  call FMTLIST 1,'.'
return 0
/* ---------------------------------------------------------------------
 * Call NJE38, Request Spool Directory and push Output to FMT Buffer
 * ---------------------------------------------------------------------
 */
nje38lst:
  if sysvar('SYSAUTH')=0 then do
     say center('  ERROR  ',32,'+')
     say 'NJE38DIR must run in PRIVILEGED Mode'
     say 'Current MODE is not PRIVILEGED!'
     say center('  ABORTED  ',32,'+')
     return 8
  end
  nrc=NJE38LLIB('DIR',arg(1))
  if nrc>0 then return nrc
  hdr1=value('nje38msg_000001')
  hdr2=value('nje38msg_000002')
  if nje38Status='NJE38STATUS' then nje38Status=userid()
  do i=3 to maxc
     j=right(i,6,'0')
     line=value('nje38msg_'j)
     if nje38status<>'*' then ,
       if word(line,5)<>nje38status then iterate
     call pushbuf line
  end
  /*
  if userid()='PEJ' then do i=1 to 60
     call pushbuf 'Line 'i
  end
  */
  _refresh=101   /* _refresh=1 signals calling FMTLIST, new buffer */
return 0
/* ---------------------------------------------------------------------
 * For received PDS files display its directory
 * ---------------------------------------------------------------------
 */
nje38pds:
  parse upper arg pdsdsn,__node,__origin,__recfm
  if useispf=1 then do
     if bldl('REVED') then do
       ADDRESS TSO
       "REVED '"pdsdsn"'"
        if rc=0 then return 0
     end
  end
  prc=dir("'"pdsdsn"'")
  buffer.0=0
  do i=1 to direntry.0
     call pushbuf direntry.i.line
  end
  _screen.Title1='NJE38 File ('__node') ORIGIN '__origin
  _screen.Message=1
 _screen.footer= ,
   'F3/F4 End ',
   'F7/F8 Scroll -- Line cmds S/B for browsing the Member'
  hdr1='Directory of 'unquote(pdsdsn)
  if __recfm='U' then hdr2=" NAME       TTR    SIZE  ALIAS-OF"
  else ,
 hdr2=" NAME       TTR   VV.MM  CREATED      CHANGED       INIT  SIZE   MOD  ID"
  public='pdsdsn __node __origin public' /* keep it for line commands */
  call FMTLIST 1,'.',hdr1,hdr2,'NJEPDS'
return 0
/* ---------------------------------------------------------------------
 * NJE38LLIB Call NJE38 Load Module
 * ---------------------------------------------------------------------
 */
nje38llib:
  if nje38DSN('ALLOC')<>0 then do
     if arg(2)='TSO' then say zerrlm  /* FSS not yet active */
     return 8
  end
  njemode=arg(1)
  nje38rc=806
ADDRESS TSO
 'IRXNJE38'       /* Call NJE38DIR Program */
  call nje38DSN 'FREE'  /* Free Spool DSN after ending spool viewer */
/* ..... Check errors in nje38 ...... */
  if nje38rc>4  then do       /* 4: spool empty, TSO: FSS not yet active */
     if arg(2)='TSO' then say 'NJE38 Application error in RXNJE38'
     else do
       zerrsm='Error in RXNJE38'
       zerrlm='NJE38 Application error in RXNJE38'
       _refresh=10
     end
     return 8
  end
/* ..... Prepare Output of NJE38 ...... */
  buffer.0=0
  maxc=nje38msg_000000
  if filter(maxc,'0123456789')='' then maxc=maxc+0  /* make int */
  else do
     hdr1=''
     hdr2=''
     call pushbuf 'RXNJE38 Error in RXNJE38, NO Buffer returned'
     call pushbuf 'Check if NJE38 Application has been started'
     call pushbuf 'Check NJE38 Spool Dataset'
     _refresh=1
     return 4
  end
return 0
/* ---------------------------------------------------------------------
 * Offer Alternative Export Name Field
 * ---------------------------------------------------------------------
 */
offerinput:
  zerrlm=arg(2)
  rmsg=translate(LineEdit(arg(3))) /* Overlay n bytes of editing mask */
  if #action='ENTER' then return rmsg
return ''
/* ---------------------------------------------------------------------
 * Display PDS Member
 * ---------------------------------------------------------------------
 */
njepds_b:
njepds_s:
  parse arg njefile
  njefile=word(njefile,1)
  if length(njefile)>8 then do
     njefile=strip(substr(word(njefile,1),1,8))
     zerrsm='('njefile') invalid'
     zerrlm='('njefile') invalid file for line command'
     return 4
  end
  call _showFile pdsdsn'('njefile')',__node,__origin
return 0
/* ---------------------------------------------------------------------
 * Convert Dates of PDS Directory
 * ---------------------------------------------------------------------
 */
cvtDate:
  if datatype(arg(1))='NUM' then return rxdate(,arg(1),'JULIAN')
return right(' ',10)
/* ---------------------------------------------------------------------
 * Convert TOD Clock Creation Time
 * ---------------------------------------------------------------------
 */
cvtodclock:
  if datatype(arg(1))<>'NUM' then return 'unknown'
  ttime = arg(1)+0
  days  = ttime%86400
  ttime = ttime//86400%1
  hh    = right(ttime%3600,2,'0')
  ttime = ttime//3600%1
  mm    = right( ttime%60,2,'0')
  ss    = right(ttime//60%1,2,'0')
  year  = 1970
  do while days > 0
     current = 365 + (year = 4 * (year%4))
     If days > current Then year = year + 1
     days = days - current
  End
  days = right(days+current,3,'0')
  year=rxdate(,year''days,'julian')
return year' at 'hh':'mm':'ss
/* ---------------------------------------------------------------------
 * Push Lines into Output Buffer
 * ---------------------------------------------------------------------
 */
pushBuf:
  blc=Buffer.0+1
  buffer.blc=arg(1)
  Buffer.0=blc
return
/* ---------------------------------------------------------------------
 * Call NJE38, Request Spool Directory and push Output to FMT Buffer
 * ---------------------------------------------------------------------
 */
getNJEFile:
  newline=''   /* reset new line to display */
  njefile=word(arg(1),1)       /* %1: force convert string to number */
  if length(njefile)>6 then njefile=left(njefile,6)
  njefileStr='('njeFile')'
  if datatype(njefile)='NUM' then njefile=njefile%1 /* force to number*/
  else do
     zerrsm='('njefile') invalid'
     zerrlm='('njefile') invalid file for line command'
     return 4
  end
return 0
/* ---------------------------------------------------------------------
 * Display File in FMTLIST
 * ---------------------------------------------------------------------
 */
_showFile:
  fkt=open("'"arg(1)"'",'RT')
  if fkt<=0 then do
     zerrsm=arg(1)' cannot open File'
     zerlsm=arg(1)' cannot open Temporary File'
     return 4
  end
  i=0
  do until eof(fkt)
     line=read(fkt)
     if eof(fkt) & length(line)=0 then leave
     i=i+1
     buffer.i=line
  end
  call close(fkt)
  buffer.0=i
  _screen.Title1='NJE38 File ('arg(2)') ORIGIN 'arg(3)
  _screen.Message=1
 _screen.footer= ,
   'F3/F4 End F7/F8 Scroll '
  call FMTLIST 5
return
/* ---------------------------------------------------------------------
 * NJE38 Primary Commands
 *   handles all primary commands from the NJE38 Spool Viewer
 * .................................. Created by PeterJ on 30. June 2020
 * ---------------------------------------------------------------------
 */
NJE38_primary:
  parse upper arg mode,status
  if abbrev('REFRESH',mode,3)=1  then do
     call ColorReset
     call NJE38Lst 'FSS'   /* Re-Create Buffer */
     _rebuild=1
  end
  else if abbrev('STATUS',mode,2)=1 then  do
     NJE38Status=status
     call nje38lst 'FSS'
     _rebuild=1
  end
  else return 8 /* unknown command */
return 0
/* Colors
  #BLUE=    61696
  #RED=     61952
  #PINK=    62208
  #GREEN=   62464
  #TURQ=    62720
  #YELLOW=  62976
  #WHITE=   63232
*/
