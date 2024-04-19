/* ---------------------------------------------------------------------
 * Retrieve Member List of a PDS Directory
 * The Directory resides at the beginning of the Partitioned Dataset
 * ............................... Created by PeterJ on 2. February 2019
 * Call
 * entries=PDSLIST(dsname,details)
 *   entries   :  Number of Members found in PDS
 *   dsname    :  Partitioned Dataset Name
 *   details   :  0 just return Member Name
 *             :  1 return Member statistics (if available)
 *             :  DETAILS  return Member statistics (if available)
 *             :  REPORT  Print detailed Member/statistics
 *   Additionally the following Variables are returned:
 *      PDSList.Membername.0 number of Members found in the PDS
 *      PDSList.Membername.n contains the member name of (element n)
 *    if details=1
 *      PDSLIST.CreateDate.n   Create Date of Member (element n)
 *      PDSLIST.ChangeDate.n   last Change Date of Member (element n)
 *      PDSLIST.Userid.n       User who changed Member (element n)
 * ---------------------------------------------------------------------
 */
PDSDIR:
 parse upper arg file,details
 if details='' then details=0
 if details='DETAILS' then details=1
 if details<>'REPORT' then report=0
 else do
    details=1
    report =1
    say Copies('-',72)
    say 'Directory List of 'file
    say 'Member    Create-Date  Change-Date  UserId'
    say Copies('-',72)
 end
 if _initdir()>0 then return -8
 do until eof(_PDSF)
    token=Read(_PDSF,2)
    record=Read(_PDSF,256)
    blockCount=c2D(substr(record,1,2))
    blockCount=min(256,Blockcount)
    if _AnalyseRecord(Blockcount)=4 then leave
 end
 call _cleanupDIR
 if report=0 then return PDSLIST.Membername.0
 else do i=1 to PDSLIST.Membername.0
    crdate=ConvertDate(PDSList.CreateDate.i)
    chdate=ConvertDate(PDSList.ChangeDate.i)
    puser=PDSList.UserID.i
    if puser='?' then puser=' '
    dinfo=left(PDSList.Membername.i,8)'   'crdate'   'chdate'  'puser
    say dinfo
 end
 say '>>> End of Directory List'
return PDSLIST.Membername.0
/* ---------------------------------------------------------------------
 * Analyse one Record of the PDS Directory
 * ---------------------------------------------------------------------
 */
_AnalyseRecord:
 parse arg bcount
 k=3
 do until k>= bcount
    subset=SUBSTR(record,k,72)
    mcount=mcount+1
    k=k+_MemberRec(SUBSTR(record,k,42),mCount,details)
    if eodir=1 then return 4
 end
return 0
/* ---------------------------------------------------------------------
 * Analyse Member Entry in PDS
 *   Length is defined by the UserDat length in byte position 12
 *   if there are no statistics, it is 0 the entry length is 12
 * ---------------------------------------------------------------------
 */
_MemberRec:
 parse arg mentry,_memberCount,details
 pdsname=substr(mentry,1,8)
 if c2x(pdsname)='FFFFFFFFFFFFFFFF' then Do
    eodir=1
    Return 99999
 end
 PDSList.MemberName._MemberCount=strip(pdsname)
 PDSList.MemberName.0=_memberCount
 ttr=substr(mentry,9,3)
 statsbyte=substr(mentry,12,1)         /* Number halfwords User area */
 statsbyte=BitAnd(statsbyte,'0F'x)
 statsbyte=c2d(statsbyte)*2
 nextentry=statsbyte+12
 if details=0 then return nextentry
 if statsbyte=0 then do
    PDSList.CreateDate._MemberCount='?'
    PDSList.ChangeDate._MemberCount='?'
    PDSList.UserID._MemberCount='?'
    return nextentry
 end
 STATS=SUBSTR(mentry,13,statsbyte)            /* MEMBER STATISTICS */
 call stats stats,ttr
return nextentry
/* ---------------------------------------------------------------------
 * Read Statistics of PDS entry
 * ---------------------------------------------------------------------
 */
stats:
parse arg userstats,ttr
Parse Var userstats,
    vv 2 mm 3 flags 4 ss 5,
    CY2KFLAG 6 ADDDATE 9,
    MY2KFLAG 10 moddate 13 hh 14,
    tm 15 LINCT 17 ilinct 19 mod 21,
    userx 28 .
  cy2kFlag=c2x(cy2kflag)
  if cy2kFlag='' then cy2kflag=0
  Parse Value c2x(ADDDATE) with YEAR 3 DAYSOFYEAR 6 .
  if strip(adddate)='' then adddate='??'
     else ADDDATE=19+CY2KFLAG''YEAR''DAYSOFYEAR /* Create date   */
  PDSList.CreateDate._MemberCount=ADDDATE
  Parse Value c2x(moddate)  with YEAR 3 DAYSOFYEAR 6 .
  my2kFlag=c2x(my2kflag)
  if my2kFlag='' then my2kflag=0
  if strip(moddate)='' then chdate='??'
     else ChDate=19+MY2KFLAG''YEAR''DAYSOFYEAR    /* Change date   */
  PDSList.ChangeDate._MemberCount=chdate
  PDSList.UserID._MemberCount=userx
  return
/* ---------------------------------------------------------------------
 * Convert Dirextory Date (if there is any)
 * ---------------------------------------------------------------------
 */
 convertDate:
  indate=arg(1)
  if datatype(indate)='NUM' then indate=rxdate(,indate,'JULIAN')
     else indate=right(' ',10)
  return indate
/* ---------------------------------------------------------------------
 * Cleanup Procedure, Free dataset
 * ---------------------------------------------------------------------
 */
_cleanupDIR:
 rc=close(_PDSF)
_freeDIR:
 rc=rxDYNALC('NOPRINT,FREE,DD='ddn)
return rc
/* ---------------------------------------------------------------------
 * INITDIR Procedure, Alloc dataset
 * ---------------------------------------------------------------------
 */
_INITDIR:
 if defined('RXMSLV')=1 & rxmslv<>'' then lcl_rxmslv=rxmslv
    else lcl_rxmslv='E'
 if pos('(',file)>0 then do
    call rxmsg 123,"E",file' Member Clause no allowed'
    return 8
 end
 RXMSLV='N'                   /* Report no Messages at all      */
 ddn='PDS'right(random(0,9999),4,'0')
 dynparm='NOPRINT,ALLOC,DD='ddn',DSN='file',SHR,RECFM=U LRECL=256 '
 alc=RXDYNALC(dynparm)
 RXMSLV=lcl_rxmslv            /* Report only Error Messages     */
 if alc>0 then do
    call rxmsg 120,"E",file' not available'
    return 8
 end
 _PDSF=OPEN(ddn,"RB")
 if _PDSF<0 then do
    call rxmsg 121,"E",file' Can not be opened,DDN='ddn
    call _freeDir
    return 8
 end
 sysdsorg=''
 lrc=LISTDSI("'"file"'")
 if sysdsorg<>'PO' then do
    call rxMSG 122,'E',file' is not a Partitioned Dataset'
    call _cleanupDir
    return 8
 end
 eodir=0
 mcount=0
 Drop PDSLIST.
 PDSLIST.Membername.0=0
return 0
