/* ---------------------------------------------------------------------
 * Open VSAM KEY Value and Reference VSAM dsn
 * ---------------------------------------------------------------------
 */
dbopen:
  parse arg profile_name
/* ...............  Select Profile  .................................... */
  if profile_name='' then profile_name=dbprof
  if getg(ddprof._open.profile_name)=1 then return 1  /* already open */
  interpret 'prc='profile_name'()'
  tmpmslv=dbopeninit()          /* some init settings */
  call _dbmsg 100,0,'Open Key/Value DB, Profile 'profile_name
  if prc<>0 then call stop('Cannot find Profile 'arg(1))
/* ...............  Alloc and Open DB Datasets  ........................ */
  call AlcOpen
/* ...............  Select Standard Room  .............................. */
  _#rid='RID'
  _#rms='RMS'
  _#rim='RIM'
  call dbctlchk
  ddprof.mslvthreshold=tmpmslv
  call setg(ddprof._open.profile_name,1)
  call _dbmsg 110,0,'Key/Value Source Dataset opened'
  call _dbmsg 110,0,'Key/Value Reference Dataset opened'
  call dbroom "Hilbert's Lobby",'INIT'
  call _dbmsg 120,100,'Key/Value DB successfully opened'
return rc
/* ---------------------------------------------------------------------
 * Reads a VSAM KEY Value Record
 * ---------------------------------------------------------------------
 */
DBGET:
parse arg dbkey,__details
  DBFUNC='DBGET'
  call dbinit
  DBRC=8   /* preset rc */
  Address MVS "VSAMIO READ "DDPROF.DDKEY" (KEY "DBFKEY" VAR dbrecord"
  DBRC =rc
  if dbrc<>0 then call _dbmsg 800,4,dbkey' not present, RCX='rcx
  else do
     call _dbmsg 170,0,dbkey' read'
/* ..... set Return information .................. */
    DBRECSTAT=substr(dbrecord,ddprof.allklen+1,1)
    DBRESULT =substr(dbrecord,ddprof.allklen+2)
  end
  if __details<>'' then do
     __dbresult=dbresult
     do __i=1 until __dbresult=''
        parse var __dbresult __attr';;'__dbresult
        __aname=dbkvIMATTR(dbprj,__i)
        if strip(__aname)='' then iterate
        interpret dbkey'.#'__aname'=strip(__attr)'
     end
  end
return dbrc
/* ---------------------------------------------------------------------
 * Prints VSAM KEY Value Record including created References
 * ---------------------------------------------------------------------
 */
DBPRINT:
  parse arg __member,__all
  if dbget(__member)<>0 then return 8
  if DBRECSTAT='S' then __status='Source available'
  else if DBRECSTAT='D' then __status='Dummy created by DBLINK to this Records'
  do i=1 until dbresult=''
     parse var DBresult attr';;'dbresult
     if i=1 then do
        call _dbsay(__member)
        call _dbsay('// ------------------------------------------')
        call _dbsay('// '__status)
        call _dbsay('//            Attributes                     ')
        call _dbsay('// ------------------------------------------')
     end
     call _dbsay(' *'left(dbkvIMATTR(dbprj,i),17)' 'strip(attr))
  end
  if __all<>'' then do forever
     _#i=_#i+1
     nextattr=dbkvIMATTR(dbprj,_#i)
     if nextattr='UNDEFINED' then leave
     call _dbsay(' *'left(nextattr,17)' ?_')
  end
  call _dbsay('// ------------------------------------------')
  call _dbsay('//            Links to other Records         ')
  call _dbsay('// ------------------------------------------')
  call DBReference __member,1,'DETAILS'
return 0
/* ---------------------------------------------------------------------
 * Encode a given record definition (+ references) and re-apply
 * ---------------------------------------------------------------------
 */
DBEncode:
  parse arg inarray
  call sdrop(INARRAY,'// ','?_')
  parse value sget(INARRAY,1) with smtp'.'sname
  call sset(inarray,1,'')
  smtp=lower(smtp)
  kbrim=getg(_$_dbrim)
  __ATTR=''
  do i=1 to sarray(kbrim)
     parse value sget(kbrim,i) with mtp'('mtind')='mtATTR
     if lower(mtp)<>smtp then iterate
     ssi=ssearch(INARRAY,'*'mtattr,,'NOCASE')
     if ssi=0 then __ATTR=__ATTR';;'
     else do
        __line=sget(inarray,ssi)
        if substr(word(__line,1),1,1)='*' then __ATTR=__ATTR';;'subword(__line,2)
        call sset(INARRAY,ssi,'')
     end
  end
  __attr=substr(__attr,3)
  call sdrop inarray,''
  tmpmslv=ddprof.mslvthreshold
  ddprof.mslvthreshold=0
  call _dbmsg 250,0,'Encoding of 'smtp'.'sname
  call DBSET(smtp'.'sname,__attr)
  call _dbmsg 251,0,'Cleanup of existing References'
  call DBDELREFALL smtp'.'sname
  call _dbmsg 252,0,'Create new References'
  tmpenDummy=DDPROF.EnableDummy
  DDPROF.EnableDummy=1
  do i=1 to sarray(inarray)
     __line=sget(inarray,i)
     call dblink(smtp'.'sname,subword(__line,2),substr(word(__line,1),2))
  end
  call _dbmsg 253,0,'Encoding of 'smtp'.'sname' completed'
  DDPROF.EnableDummy=tmpenDummy
  ddprof.mslvthreshold=tmpmslv
return
/* ---------------------------------------------------------------------
 * Prints Neighbourhood (References) of a Record
 * ---------------------------------------------------------------------
 */
DBHood:
  parse arg __member
  call DBUsage(__MEMBER,1,'REFS')
  if dbrefcount=0 then call dbsay '  NOTHING'
  call dbsay '   |  Refer(s) to '__MEMBER
  call dbsay '   V   '
  call dbsay '+'copies('-',50)'+'
  call dbsay '| 'left(__MEMBER,49)'|'
  call dbsay '+'copies('-',50)'+'
  call dbsay '   |  Reference(s) from '__MEMBER
  call dbsay '   V   '
  call DBReference __MEMBER,1,'REFS'
  if dbrefcount=0 then call dbsay 'NOTHING'
return
/* ---------------------------------------------------------------------
 * Set a VSAM KEY Value Record
 * ---------------------------------------------------------------------
 */
DBSET:
parse arg DBKEY,vsInput,dummy
  DBFUNC='DBSET'
  if dummy='' then Dummy='S'
  else dummy='D'
  call DBinit
  _inrec=DBFKEY||Dummy||vsInput
  Address MVS "VSAMIO READ "DDPROF.DDKEY" (KEY "DBFKEY" UPDATE VAR DBOLDREC"
  Address MVS "VSAMIO WRITE "DDPROF.DDKEY" (KEY "DBFKEY" VAR _INREC"
/* ..... set Return information .................. */
  if rc>0 then call _dbmsg 810,8,dbkey' Record cannot be written'
  else do
     DBRESULT=_inrec
     call _dbmsg 180,0,dbkey' Record successfully written'
  end
  DBRC    =rc
RETURN RC
/* ---------------------------------------------------------------------
 * LOCATE VSAM KEY Value Record
 * ---------------------------------------------------------------------
 */
DBLOCATE:
parse arg DBKEY,allroom
  DBFUNC='DBLOCATE'
  if allroom='' then call dbinit  /* list over all records in a room */
  else vsprefix=allroom
  Address MVS "VSAMIO LOCATE "DDPROF.DDKEY" (KEY "vsPrefix
/* ..... set Return information .................. */
  if rc>0 then call _dbmsg 820,4,dbkey' Locate failed'
  else call _dbmsg 190,0,dbkey' Record located'
  DBRC=rc
return rc
/* ---------------------------------------------------------------------
 * GET NEXT KEY Value Record
 * ---------------------------------------------------------------------
 */
DBNEXT:
parse arg DBKEY
  DBFUNC='DBNEXT'
/* call DBinit   call not needed  */
  Address MVS "VSAMIO READ "DDPROF.DDKEY" (NEXT VAR record"
  DBRC    =rc
  if rc>0 then return 8
  if substr(record,1,ddprof.allklen)=ddprof.vsmeof then signal _#eof
  if abbrev(record,vsprefix)>0 then signal _#record
  else signal _#eof
/* ..... set Return information .................. */
 _#record:
  call _dbmsg 200,0,dbkey' next Record read'
  dbQualifier=_#cleanseSub(record,ddprof.qualoffs,ddprof.quallen)
  dbkey=_#cleanseSub(record,ddprof.roomlen+ddprof.quallen+1,ddprof.keylen)
  dbFKey=substr(record,1,ddprof.allklen)
  DBRESULT=substr(record,ddprof.allklen+1)
  dbRC=0
  return 0
 _#eof:
/* End of data reached */
  call _dbmsg 210,0,'Last Record reached'
  dbrc=4
  dbKey=''
  dbFKey=''
  DBRESULT=''
return 4
/* ---------------------------------------------------------------------
 * Delete a VSAM KEY Value Record
 * ---------------------------------------------------------------------
 */
DBDEL:
parse arg DBKEY
  DBFUNC='DBDEL'
  call dbinit
  if __delrec(DDPROF.DDKEY,DBKEY)>0 then return 8
/* ..... set Return information .................. */
  call _dbmsg 220,0,dbkey' successfully deleted'
  DBRESULT=_oldrec
  DBRC    =0
return rc
/* --------------------------------------------------------------------
 * Link to existing Records, both must exist
 * DBLINK ust it to its standard length, eliminate blanks
 * --------------------------------------------------------------------
 */
DBLINK:
parse arg _lhs,_rhs,vsType,linktxt
  vstype=lower(vstype)
  DBFUNC='DBLNK'
  lhs=_#parsekey(_lhs)
  rhs=_#parsekey(_rhs)
  vstype=_#fmt1(vstype,ddprof.typelen)                   /* Build Reference Key */

/* 1. Check if source and target Record exist  */
  Address MVS "VSAMIO READ "DDPROF.DDKEY" (KEY "lhs" UPDATE VAR _OLDREC"
  if rc>0 then do
     if DDPROF.EnableDummy=1 then call DBSET(_lhs,'DUMMY','D')
     else do
        call _dbmsg 850,8,_lhs' not present'
        signal lnkex
     end
  end
  Address MVS "VSAMIO READ "DDPROF.DDKEY" (KEY "rhs" UPDATE VAR _OLDREC"
  if rc>0 then do
     if DDPROF.EnableDummy=1 then call DBSET(_rhs,'DUMMY','D')
     else do
        call _dbmsg 860,8,_rhs' not present'
        signal lnkex
     end
  end

/* 2. Add Link Record source to target  */
  dbkey='F'lhs||rhs||vstype
  _inrec=dbkey||linktxt
  Address MVS "VSAMIO READ "DDPROF.DDREF"  (KEY "dbKEY" UPDATE VAR _OLDREC"
  Address MVS "VSAMIO WRITE "DDPROF.DDREF" (KEY "dbKEY" VAR _INREC"

/* 3. Add Link Record target to source  */
  dbkey='B'rhs||lhs||vstype
  _inrec=dbkey||linktxt
  Address MVS "VSAMIO READ  "DDPROF.DDREF" (KEY "dbKEY" UPDATE VAR _OLDREC"
  Address MVS "VSAMIO WRITE "DDPROF.DDREF" (KEY "dbKEY" VAR _INREC"
  call _dbmsg 230,0,_lhs' and '_rhs' successfully linked'

/* ..... set Return information .................. */
lnkex:
  DBRC    =rc
  DBLHS   =lhs
  DBRHS   =rhs
return rc
/* --------------------------------------------------------------------
 * Deletes a Reference between existing Records
 * --------------------------------------------------------------------
 */
DBDELREF:
parse arg _lhs,_rhs,vsType
  vstype=lower(vstype)
  DBFUNC='DBLNK'
  lhs=_#parsekey(_lhs)
  rhs=_#parsekey(_rhs)
  vstype=_#fmt1(vstype,ddprof.typelen)    /* Build Reference Key */

/* 1. Delete Link Record source to target  */
  if __delrec(DDPROF.DDREF,'F'lhs||rhs||vstype)>0 then return 8
/* 2. Delete Link Record target to source  */
  if __delrec(DDPROF.DDREF,'B'rhs||lhs||vstype)>0 then return 8
  call _dbmsg 330,0,'Link between '_lhs' and '_rhs' successfully removed'

/* ..... set Return information .................. */
lnkex:
  DBRC    =0
  DBLHS   =lhs
  DBRHS   =rhs
return rc
/* --------------------------------------------------------------------
 * Delete all links from a Record
 * it does not remove links from others to this record (passive links)
 * --------------------------------------------------------------------
 */
DBDELREFALL:
  parse arg vsKey
  direction=left(direction,1)
  vskey=translate(vskey,'_',' ')
  vsFunc='VSDELREF'
  keyv=_#parsekey(vskey)
  lhs='F'ref2key(keyv)
  say 'to del 'lhs
  do forever
   /* LOCATE must be inside the loop as DELETE may change position */
     Address MVS "VSAMIO LOCATE "DDPROF.DDREF" (KEY "lhs
     if rc>0 then return 0
     Address MVS "VSAMIO READ "DDPROF.DDREF" (NEXT VAR record"
     if rc>0 then leave           /* EOF reached   */
     if refkey(record)<>lhs then leave
     __reff=substr(record,1,ddprof.allrklen)
     call __delrec DDPROF.DDREF,__reff
     call __delrec DDPROF.DDREF,'B'refkey2(record)refkey1(record)refref(record)
  end
return 0
ref2key:        /* formats into key for a reference record (w.o F/B)     */
  return left(arg(1),ddprof.allklen,'_')
refKey:         /* returns the  key out of a reference record (with F/B) */
  return substr(arg(1),1,ddprof.allklen+1)
refKey1:        /* returns keypart 1 of a reference record (w.o. F/B)    */
  return substr(arg(1),2,ddprof.allklen)
refKey2:        /* returns keypart 2 of a reference record (w.o. F/B)    */
  return substr(arg(1),ddprof.allklen+2,ddprof.allklen)
refref:        /* returns ref type of  a reference record (w.o. F/B)    */
  return substr(arg(1),2*ddprof.allklen+2)
/* --------------------------------------------------------------------
 * Delete Record sub procedure
 * --------------------------------------------------------------------
 */
__delrec:
  parse arg vsfile,__dbkey
  Address MVS "VSAMIO READ   "vsfile" (KEY "__dbKEY" UPDATE VAR _OLDREC"
  if rc>0 then do
     call _dbmsg 830,4,__dbkey' Record not available'
     return 8
  end
  Address MVS "VSAMIO DELETE "vsfile" (KEY "__dbKEY
  if rc>0 then do
     call _dbmsg 840,8,__dbkey' Deleting Record failed, rcx='rcx
     return 8
  end
  if vsfile=ddprof.ddREF then do
     __key1=substr(refkey1(__dbkey),ddprof.qualoffs)
     __key2=substr(refkey2(__dbkey),ddprof.qualoffs)
     call _dbmsg 340,0,_#fmt2(__key2)' delinked from '_#fmt2(__key1)
  end
  else call _dbmsg 340,0,__dbkey' Record deleted'
return 0
/* --------------------------------------------------------------------
 * LIST List records of a project or project.key-prefix combination
 * --------------------------------------------------------------------
 */
DBLIST:
  parse arg KEYw,keyvalue
  keyw=upper(substr(keyw,1,2))
  reci=0
  lrc=_ListLocate('List',keyw,keyvalue)
  do forever
     rc=dbnext(nxtparm)
     if rc>0 then leave
     crc=_chkrecord(keyw)
     if crc=4 then iterate
     if crc=8 then leave
     if substr(dbresult,1,1)='D' then mtp='Dummy '
     else  mtp='Source'
     reci=reci+1
     call _dbsay(' 'left(dbqualifier'.'dbkey,ddprof.allklen2)' 'mtp' 'substr(dbresult,2))
  end
  call _dbsay('List contains 'reci' records')
  call _dbsay(' ')
return rc
/* --------------------------------------------------------------------
 * LOCATE prior to first record based on input parms
 * --------------------------------------------------------------------
 */
_ListLocate:
  parse arg ltype,keyw,keyvalue
  roomstr=getg(_$_dbroomName)'('getg(_$_dbroom)')'
  if keyw='AL' | keyw='' then do  /* ALL */
     lrc=dblocate(,getg(_$_dbroom))
     call _dbsay(ltype' all records of room 'roomstr)
  end
  if keyw='QU' then do                 /* QUALIFIER */
     keyvalue=lower(keyvalue)
     lrc=dblocate(,getg(_$_dbroom)||keyvalue)
     call _dbsay(ltype' all records of room 'roomstr' with Qualifier 'keyvalue)
  end
  else if keyw='ON' then do            /* ONLY */
     lrc=dblocate(,getg(_$_dbroom))
     call _dbsay(ltype' records of room 'roomstr' with starting key 'keyvalue)
  end
  else if keyw='AN' then do             /* ANY */
     lrc=dblocate(,getg(_$_dbroom))
     call _dbsay(ltype' records of room 'roomstr' containing 'keyvalue' in key')
  end
  else if keyw='CO' then do             /* ANY */
     lrc=dblocate(,getg(_$_dbroom))
     call _dbsay(ltype' records of room 'roomstr' containing 'keyvalue)
  end
  call _dbsay(copies('-',72))
return lrc
/* --------------------------------------------------------------------
 * Check Record if it matches the criteria
 * --------------------------------------------------------------------
 */
 _chkrecord:
  parse arg keyword
  if keyword='QU' then do      /* QUALIFIER */
     if dbqualifier>keyvalue then return 8
     if abbrev(keyvalue,dbqualifier)=0 then return 4 /* QUALIFIER  */
  end
  else if keyword='ON' then do  /* ONLY (only the key, any qualifier) */
     if keyvalue='' then return 0
     if pos(keyvalue,dbkey)=1 then return 0
     else return 4
  end
  else if keyword='AN' then do  /* ANY (any part of the string in the key) */
     if pos(keyvalue,dbkey)=0 then return 4
  end
  else if keyword='CO' then do  /* CONTAINS (string only in the key) */
     if pos(keyvalue,dbresult)=0 then return 4
  end
return 0
/* --------------------------------------------------------------------
 * COUNT count References/usages of Key
 * --------------------------------------------------------------------
 */
DBRCOUNT:
  parse arg vsKey,direction
  direction=left(direction,1)
  vskey=translate(vskey,'_',' ')
  vsFunc='VSCOUNT'
  refcount=0
  lhs=_#parsekey(vskey)
  lhs=direction''left(lhs,ddprof.allklen,'_')
  Address MVS "VSAMIO LOCATE "DDPROF.DDREF" (KEY "lhs
  if rc>0 then return 0
  do forever
     Address MVS "VSAMIO READ "DDPROF.DDREF" (NEXT VAR record"
     if rc>0 then leave           /* EOF reached   */
     if substr(record,1,ddprof.allklen+1)<>substr(lhs,1,ddprof.allklen+1) then leave
     refcount=refcount+1
  end
return refcount
/* --------------------------------------------------------------------
 * Output result either on stdout or in an array
 * --------------------------------------------------------------------
 */
dbsay:
_dbsay:
  if ddprof.mslvthreshold=100 then return
  parse arg __line
  signal _dbmsg1
_dbmsg:
  parse arg __msno,__mslv,__line
  if __mslv<ddprof.mslvthreshold then return
  __line='KV'__msno||ddprof.$$mslv.__mslv'    '__line
_dbmsg1:
  __outarray=getg('dbOutArray')
  if __outarray<>'' then call sset(__outarray,,__line)
  else if symbol('ddprof.outexit')='VAR' & ddprof.outexit <>'' then interpret 'orc='ddprof.outexit'(__line)'
  else say __line
return
/* --------------------------------------------------------------------
 * KEEP keeps records of a project or project.key-prefix combination
 * --------------------------------------------------------------------
 */
DBKEEP:
  parse arg KEYw,keyvalue
  __s1=SCREATE(5000)
  keyw=upper(substr(keyw,1,2))
  reci=0
  lrc=_ListLocate('Keep',keyw,keyvalue)
  do forever
     rc=dbnext(nxtparm)
     if rc>0 then leave
     if _chkrecord(keyw)>0 then iterate
     call sset(__s1,,dbfkey' active')
     reci=reci+1
  end
  call _dbmsg 240,0,'Records kept 'reci
return __s1
/* --------------------------------------------------------------------
 * REMOVE records of a project or project.key-prefix combination
 * --------------------------------------------------------------------
 */
DBREMOVE:
  parse arg KEYw,keyvalue
  if keyw='' then do
     call _dbmsg 850,8,'Remove requires Keyword'
     return 8
  end
  keyw=upper(substr(keyw,1,2))
  reci=0
  lrc=_ListLocate('Remove',keyw,keyvalue)
  do forever
     rc=dbnext(nxtparm)
     if rc>0 then leave
     crc=_chkrecord(keyw)
     if crc=4 then iterate
     if crc=8 then leave
     Address MVS "VSAMIO DELETE "DDPROF.DDKEY" (KEY "DBFKEY
     if rc>0 then iterate
     reci=reci+1
     call _dbsay _#fmt2(dbfkey)' removed'
  end
  call _dbsay 'Number of records removed 'reci
return rc
/* ---------------------------------------------------------------------
 * Close DB
 * ---------------------------------------------------------------------
 */
dbclose:
  parse arg profile_name
  if profile_name='' then profile_name=dbprof
   Address MVS "VSAMIO CLOSE "DDPROF.DDKEY
   Address MVS "VSAMIO CLOSE "DDPROF.DDREF
  CALL FREE(DDPROF.DDKEY)
  CALL FREE(DDPROF.DDREF)
  call setg(ddprof._open.profile_name,0)
  call _dbmsg 140,0,'Key/Value DB closed'
return 0
/* ---------------------------------------------------------------------
 * List all rooms
 * ---------------------------------------------------------------------
 */
dbrooms:
  currRoom=getg(_$_dbroom)
  call setg(_$_dbroom,'$$')
  _#rlen=length(_#rid)
  call dblocate 'CONTROL.'_#rid
  if rc>0 then return 4
  sr1=screate(4000)
  do until rc>0
     call dbnext
     if substr(dbkey,1,_#rlen)<>_#RID then leave
     room=translate(substr(dbkey,_#rlen+1),,'_')
     call sset(sr1,,dbresult room)
  end
  call _dbsay('List all defined rooms')
  do i=1 to sarray(sr1)
     rid=word(sget(sr1,i),1)
     room=subword(sget(sr1,i),2)
     call _dbsay '  'left(room,22) rid||dbroomMember(substr(rid,2))
  end
  call sfree(sr1)
  call setg(_$_dbroom,currRoom)
return
/* ---------------------------------------------------------------------
 * Count Members of a room
 * ---------------------------------------------------------------------
 */
dbRoomMember:
parse arg rid
  Address MVS "VSAMIO LOCATE "DDPROF.DDKEY" (KEY "rid
  if rc>0 then return 0
  members=0
  do forever
     Address MVS "VSAMIO READ "DDPROF.DDkey" (NEXT VAR record"
     if rc>0 then leave           /* EOF reached   */
     if substr(record,1,ddprof.roomlen)<>rid then leave
     members=members+1
  end
 return right(members,6)
/* ---------------------------------------------------------------------
 * Set ROOM to distinguish different areas
 * ---------------------------------------------------------------------
 */
dbroom:
  parse arg room
  call setg(_$_dbroom,'$$')
  uroom=upper(room)
  call _dbmsg 150,0,"Check-in "room" started"
  if dbget('CONTROL.'_#RID||uroom)=0 then roomid=dbresult
  else do
     if dbget('CONTROL.'_#RMS)>0 then do
        rrow=1
        rcol=0
     end
     else do
        rrow=substr(dbresult,1,3)
        rcol=substr(dbresult,4,3)
     end
     if rcol<ROOMClen then rcol=rcol+1
     else do
        rcol=1
        rrow=rrow+1
        if rrow>ROOMClen then do
           call dbclose
           call _dbmsg 900,8,"Check-in "room" ("rrow"."rcol") failed, fully booked"
           call stop("this isn't Hilbert's Hotel")
        end
     end
     roomid=substr(ROOMCHARS,rrow,1)substr(ROOMCHARS,rcol,1)
     call dbset('CONTROL.'_#RMS,right(rrow,3,'0')right(rcol,3,'0'))
     call dbset('CONTROL.'_#RID||uroom,roomid)
  end
  if arg(2)='INIT' then call _dbmsg 160,100,"Check-in Standard Room  ("roomid")"
  else call _dbmsg 160,0,"Check-in "room" ("roomid") completed"
  call setg(_$_dbroom,roomid)     /* set roomid */
  call setg(_$_dbroomName,uroom)  /* set room name */
  call dbKVIM
return 0
/* ---------------------------------------------------------------------
 * Load Information Model, if there is any
 * ---------------------------------------------------------------------
 */
dbKVIM:
  uRoom=getg('_$_dbroom')      /* save current room */
  call setg('_$_dbroom','$$')
  kbrim=getg(_$_dbrim)
  if kbrim<>'' then call SFREE(kbrim,"KEEP")
  else do
     kbrim=screate(500)
     call setg(_$_dbrim,kbrim)
  end
  call _dbmsg 150,0,"Load KV Information Model"
  if dbget('CONTROL.'_#RIM||uroom)<>0 then call _dbmsg 150,4,"no KV Information Model present"
  else do _#i=1 to words(dbresult)
     __attr=word(dbresult,_#i)
     __len=length(__attr)
     if pos(':',__attr)=__len then do
        __j=0
        __mt=substr(__attr,1,__len-1)
     end
     else do
        __j=__j+1
        call sset(kbrim,,__mt'('__j')='__attr)
     end
  end
  call setg('_$_dbroom',uroom) /* switch back to original room */
return 0
/* ---------------------------------------------------------------------
 * Add Entries to Information Model
 * ---------------------------------------------------------------------
 */
dbKVIMBuild:
  uroom=getg(_$_dbroom)
  call setg('_$_dbroom','$$')
  call dbset('CONTROL.'_#RIM||uroom,_#rimdata)
  call setg('_$_dbroom',uroom) /* switch back to original room */
  _#rimdata=''
return 0
/* ---------------------------------------------------------------------
 * Add one Entry to Information Model
 * ---------------------------------------------------------------------
 */
dbKVIMAdd:
  parse upper arg _#rimparm
  if symbol('_#rimdata')='VAR' & _#rimdata<>'' then _#rimdata=_#rimdata' '_#rimparm
  else _#rimdata=_#rimparm
return 0
/* ---------------------------------------------------------------------
 * Return Attribute Name according to Model
 * ---------------------------------------------------------------------
 */
dbKVIMATTR:
  parse arg __mtype,__position
  __kbrim=getg(_$_dbrim)
  __ssi=ssearch(__kbrim,upper(__mtype)'('__position')')
  if __ssi=0 then return 'UNDEFINED'
  parse value sget(__kbrim,__ssi) with __mtp'='__attribute
return __attribute
/* ---------------------------------------------------------------------
 * Show KV Information Model
 * ---------------------------------------------------------------------
 */
dbKVIMShow:
  __kbrim=getg(_$_dbrim)
  call dbsay 'Information Model of 'getg(_$_dbroomName)'('getg(_$_dbroom)')'
  call dbsay left('Type',ddprof.quallen+1)'Attribute'
  call dbsay copies('-',32)
  do __j=1 to sarray(__kbrim)
     parse value sget(__kbrim,__j) with __mtp'('__num')='__attr
     if __mtp='' then leave
     if oldmtp=__mtp then call dbsay copies(' ',ddprof.quallen+1)__attr
     else call dbsay left(__mtp,ddprof.quallen+1)__attr
     oldmtp=__mtp
   end
return 0
/* ---------------------------------------------------------------------
 * check Control Record, add one if not there
 * ---------------------------------------------------------------------
 */
dbctlchk:
  call _dbmsg 130,0,'Read K/V Control Records'
  call setg(_$_dbroom,'$')
  if dbget('CONTROL.'_#RMS)>0 then do
     call dbset('CONTROL.'_#RMS,'001001')
  end
  call setg(_$_dbroom,'_')   /* reset it to default value */
return
/* ---------------------------------------------------------------------
 * Navigate the forward path
 * ---------------------------------------------------------------------
 */
DBReference:
  parse arg node,maxlevel,detonly
  done=screate(500)
  if maxlevel='' then maxlevel=999
  if detonly='' then do
     call _dbsay "References of "node
     call _dbsay copies('-',72)
  end
  call _#XREF arg(1),1,maxlevel,'F',detonly
  if detOnly='' then call DBSAY '    -># references have been reported previously'
  call DBSAY 'Elements found 'sarray(done)
  done=sfree(done)
return 0
/* ---------------------------------------------------------------------
 * Navigate the backward path
 * ---------------------------------------------------------------------
 */
DBUsage:
  parse arg node,maxlevel,detonly
  done=screate(500)
  if maxlevel='' then maxlevel=999
  if detonly='' then do
     call _dbsay "Usage of "node
     call _dbsay copies('-',72)
  end
  call _#XREF arg(1),1,maxlevel,'B',detonly
  if detOnly='' then call DBSAY '    <-# usages have been reported previously'
  call DBSAY 'Elements found 'sarray(done)
  done=sfree(done)
return 0
/* ---------------------------------------------------------------------
 * Report all refered Links of a given record
 * ---------------------------------------------------------------------
 */
_#XREF: Procedure expose done ddprof. dbrefcount
  parse arg vsKey,level,mlevel,direction,detailsOnly
  vskey=translate(vskey,'_',' ')
  vsFunc='VSREFS'
  if direction='B' then lnktp='<-'
     else lnktp='->'
  lhs=_#parsekey(vskey)
  lhs=direction''left(lhs,ddprof.allklen,'_')
 ADDRESS MVS "VSAMIO LOCATE "DDPROF.DDREF" (KEY "lhs
  if rc>0 then return 8
  if detailsOnly<>'' & level=1 then call _dbsay vsshkey
  dbrefcount=0
  do forever
    ADDRESS MVS "VSAMIO READ "DDPROF.DDREF" (NEXT VAR record"
     if rc>0 then leave           /* EOF reached   */
  /* Check later if record really contains the key */
     if substr(record,1,ddprof.allklen+1)<>lhs then leave
     dbrefcount=dbrefcount+1
     pkey=substr(record,1,ddprof.allklen+1) /* source reference (dir-type-key) */
     ssrc=substr(record,ddprof.allklen+4,ddprof.quallen)  /* +2+2 target type  */
     skey=substr(record,ddprof.rkeyoff2,ddprof.keylen)    /* target record     */
     styp=substr(record,ddprof.allrlen+1,ddprof.typelen)  /* link type         */
     if ssearch(done,record)>0 then do            /* already reported? */
        if detailsOnly='' then call _refsay level,1,"|- "_#cleanse(styp,14)" "lnktp"# "_#cleanse2(ssrc,skey)
        iterate                                     /* drop further navigation */
     end
     fullkey=substr(record,1,ddprof.allrlen)
     if detailsOnly='REFS' then call _dbsay "  "left(upper(_#cleanse(styp,14)),17)" "_#cleanse2(ssrc,skey)
     else if detailsOnly<>'' then call _dbsay " >"left(upper(_#cleanse(styp,14)),17)" "_#cleanse2(ssrc,skey)
     else do
        if DBREFCOUNT=1 then do
           call _refsay level,0,vskey
           call _refsay level,1,"+- "_#cleanse(styp,14)" "lnktp"  "_#cleanse2(ssrc,skey)
        end
        else call _refsay level,1,"|- "_#cleanse(styp,14)" "lnktp"  "_#cleanse2(ssrc,skey)
     end
     call sset(done,,record)      /* set immediately in processed table*/
     if level<mlevel then do
        call _#xref(_#cleanse(ssrc)'.'_#cleanse(skey),level+1,mlevel,direction,detailsOnly)
  /* we must reset record position, from where we initially started  */
       ADDRESS MVS "VSAMIO LOCATE "DDPROF.DDREF" (KEY "fullkey
       ADDRESS MVS "VSAMIO READ   "DDPROF.DDREF" (NEXT VAR record" /* we processed this record already */
     end
  end
return 0
_refsay:
   parse arg level,lrmode
   pref=copies(' ',(level-1)*3)
   plen=length(pref)
   if level>1 then do pi=1 to length(pref) by 3
      if substr(pref,pi,1)=' ' then pref=overlay('|',pref,pi)
   end
   call _dbsay right(level,2)' 'pref||arg(3)
return
/* --------------------------------------------------------------------
 * Set Threshold for Messages
 * --------------------------------------------------------------------
 */
DBMSGLV:
  parse upper arg inmslv
  if inmslv='I' then ddprof.mslvthreshold=0
  else if inmslv='W' then ddprof.mslvthreshold=4
  else if inmslv='E' then ddprof.mslvthreshold=8
  else if inmslv='C' then ddprof.mslvthreshold=12
  else if inmslv='N' then ddprof.mslvthreshold=101
  else if inmslv='A' then ddprof.mslvthreshold=100
return
/* --------------------------------------------------------------
 * Workbench Processing of Key/Value DB
 * --------------------------------------------------------------
 */
dbWorkBench:
  parse upper arg mode,p1,p2
  cRoom=getg('_$_dbroom')      /* save current room */
  call DBRoom 'Workbench'      /* switch to Workbench room */
  if MODE='SSTEM'       | MODE='SAVESTEM'  then wrc=__wbsave(p1)
  else if MODE='LSTEM'  | MODE='LOADSTEM'  then wrc=__wbload(p1,p2)
  else if MODE='SARRAY' | MODE='SAVEARRAY' then wrc=__wbsarray(p1,p2)
  else if MODE='LARRAY' | MODE='LOADARRAY' then wrc=__wblarray(p1)
  else return 8
  call setg('_$_dbroom',croom) /* switch back to original room */
return wrc
/* --------------------------------------------------------------
 * Save Stem in Workbench Areay of Key/Value DB
 * --------------------------------------------------------------
 */
__wbsave:
  do _#i=0 to value(arg(1)'0')   /* save entire STEM */
     call dbset('stem.'arg(1)_#i,value(arg(1)_#i))
  end
  call _dbsay 'Store STEM 'arg(1)' in the K/V Database'
  call _dbsay ' '_#i-1' entries stored'
return 0
/* --------------------------------------------------------------
 * Save Stem in Workbench Areay of Key/Value DB
 * --------------------------------------------------------------
 */
__wbload:
  call dbget('stem.'arg(1)0)
  __max=dbresult
  if arg(2)='' then __target=arg(1)
  else __target=arg(2)
  Interpret __target'0=__max'
  do _#i=1 to __max
     call dbget('stem.'arg(1)_#i)
     Interpret __target'_#i=dbresult'
  end
  call _dbsay 'Load STEM 'arg(1)' as '__target' from the K/V Database'
  call _dbsay ' '_#i-1' entries restored'
return 0
/* --------------------------------------------------------------
 * Save ARRAY in Workbench Areay of Key/Value DB
 * --------------------------------------------------------------
 */
__wbsarray:
  parse arg arrnum,arrname
  if arrname='' then call stop('an Array-name is mandatory')
  call dbset('ARRAY.'arrname'0',sarray(arrnum))
  do _#i=1 to sarray(arrnum)       /* save entire SARRAY */
     call dbset('ARRAY.'arrname||_#i,sget(arrnum,_#i))
  end
  call _dbsay 'Store ARRAY 'arrnum' as 'arrname' in the K/V Database'
  call _dbsay ' '_#i-1' entries stored'
return 0
/* --------------------------------------------------------------
 * Save Stem in Workbench Areay of Key/Value DB
 * --------------------------------------------------------------
 */
__wblarray:
  parse arg arrname
  call dbget('ARRAY.'arrname'0')
  __max=dbresult
  starget=screate(__max)
  do _#i=1 to __max
     call dbget('ARRAY.'arrname||_#i)
     call sset(starget,,dbresult)
  end
  call _dbsay 'Load ARRAY 'arrname' from the K/V Database into ARRAY 'starget
  call _dbsay ' '_#i-1' entries restored'
return starget
/* ---------------------------------------------------------------------
 * Cleanse some chars from parameter
 * ---------------------------------------------------------------------
 */
_#cleanse:
if arg(2)='' then return strip(translate(arg(1),' ','_'))
else return left(strip(translate(arg(1),' ','_')),arg(2))
_#cleanse2:
return strip(translate(arg(1),' ','_'))'.'strip(translate(arg(2),' ','_'))
_#cleanseSub:
return strip(translate(substr(arg(1),arg(2),arg(3)),' ','_'))
/* ---------------------------------------------------------------------
 * Init some KEY Value information
 * ---------------------------------------------------------------------
 */
dbinit:
  dbresult=''
  dbfkey=_#parseKey(dbkey)
return
/* --------------------------------------------------------------------
 * Parse incoming bucket.key-value information
 * and adjust it to its standard length, eliminate blanks,etc
 * --------------------------------------------------------------------
 */
_#parseKEY:
  if ddprof.keyupper=1 then parse upper arg ikey,xlevel
     else parse arg ikey,xlevel
  parse var ikey with dbprj'.'dbkey
  isRoom=getg(_$_dbroom)
  if dbkey='' then do
     if right(ikey,1)='.' then DBPRJ=left(ikey,length(ikey)-1)
     else do
        dbkey=DBPRJ
        DBPRJ='any'
     end
  end
  DBPRJ=lower(DBPRJ)               /* bucket is lower case*/
  vsproj=_#fmt1(dbprj,ddprof.quallen)  /* project             */
  vsshkey=dbprj'.'_#cleanse(dbkey)     /* extended key version w.o. _*/
  vsprefix=isroom||_#fmt1(dbprj,ddprof.quallen)dbkey /* project + part of key (if it is partial) */
return isroom||vsProj||_#fmt1(dbkey,ddprof.keylen)   /* build reference key */
/* --------------------------------------------------------------------
 * Format key, type, etc with '_' abd length
 * --------------------------------------------------------------------
 */
_#fmt1:
return translate(left(arg(1),arg(2),'_'),'_',' ')  /* Build Reference Key */
/* --------------------------------------------------------------------
 * Re-translate full key in readable key
 * --------------------------------------------------------------------
 */
_#fmt2: parse arg _fkey
/*
  _fproj=strip(substr(_fkey,ddprof.qualoffs,ddprof.quallen),'t','_')
  _fkey  =strip(substr(_fkey,ddprof.keyoffs,ddprof.keylen),'t','_')
 */
  _fproj=strip(substr(_fkey,1,ddprof.quallen),'t','_')
  _fkey  =strip(substr(_fkey,ddprof.quallen+1,ddprof.keylen),'t','_')
return _fproj'.'_fkey
/* --------------------------------------------------------------------
 * Alloc and Open DB Datasets
 * --------------------------------------------------------------------
 */
AlcOpen:
/* ...............  allocate the datasets  ...............................*/
  if allocate(ddprof.ddkey,"'"ddprof.DSNKEY"'")>4 then call stop('Key Value Dataset not available')
  if allocate(ddprof.ddREF,"'"ddprof.DSNREF"'")>4 then call stop('Key Reference Dataset not available')
/* ...............  open the datasets  ................................. */
ADDRESS MVS "VSAMIO OPEN "DDPROF.DDKEY" (UPDATE"
  if rc<>0 then call stop('Key Value Dataset cannot be opened 'rcx)
ADDRESS MVS "VSAMIO OPEN "DDPROF.DDREF" (UPDATE"
  if rc>0 then call stop('Key Reference Dataset cannot be opened 'rcx)
return
/* --------------------------------------------------------------------
 * Set some init Values while DBOPEN
 * --------------------------------------------------------------------
 */
dbopeninit:
/* calculate the remaining profile variables */
  ROOMCHARS='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  ROOMClen =length(roomchars)
  ddprof.allklen=ddprof.roomlen+ddprof.quallen+ddprof.keylen
  ddprof.allklen2=ddprof.quallen+ddprof.keylen
  ddprof.allrlen=1+2*ddprof.allklen
  ddprof.allrklen=ddprof.typelen+ddprof.allrlen
  ddprof.qualoffs=ddprof.roomlen+1
  ddprof.keyoffs=ddprof.qualoffs+ddprof.quallen
  ddprof.vsmeof=copies('9',ddprof.allklen)
  ddprof.rkeyoff2=ddprof.allklen+1+ddprof.keyoffs
  ddprof.$$mslv.0='I'
  ddprof.$$mslv.4='W'
  ddprof.$$mslv.8='E'
  ddprof.$$mslv.12='C'
  ddprof.$$mslv.100='I'
  if symbol('ddprof.mslvthreshold')='LIT' then ddprof.mslvthreshold=8     /* print errors or higher */
  tmpmslv=ddprof.mslvthreshold
  if tmpmslv=101 then nop      /* if it is 101 (NOPRINT) don't change it */
  else call dbmsglv 'W'        /* show only W, E, and C Messages */
return tmpmslv
