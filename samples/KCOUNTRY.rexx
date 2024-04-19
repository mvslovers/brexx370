call import KeyValue
call dbmsglv 'N'
call dbopen
call dbroom('World')
public='ddprof.'
s1=screate(5000)
call setg('useArray',s1)
ddprof.outexit='outexit'
recno=0
ddprof.outlv=1
ddprof.sarray=s1
call dbmsglv 'E'
call dblist 'Qualifier','Country'
ddprof.outexit=''
buffer.0='ARRAY 's1
_fmtheader='Countries of the World'
_fmtFooter='LNK show links / PRI print / UPD update'
 call fmtlistc 'Country'
call dbclose
call sfree s1
exit
/* ------------------------------------------------------------------
 * LNK line command to select Country
 * ------------------------------------------------------------------
 */
COUNTRY_lnk:
  ddprof.outexit=''
  s2=screate(500)
  call setg('dbOutArray',s2)
  cnt1=substr(arg(1),1,33)
  call DBHood 'Country.'cnt1
  buffer.0='ARRAY 's2
  _fmtheader='Links from/to 'word(arg(1),1)
  _fmtFooter='LNK show links / PRI print / UPD update'
  call fmtlistc 'Links'
  call sfree s2
return 0
/* ------------------------------------------------------------------
 * UPD update for a country requested
 * ------------------------------------------------------------------
 */
COUNTRY_upd:
  _entry=strip(substr(arg(1),1,32))
  country='country.'_entry
return updEntry(country)
/* ------------------------------------------------------------------
 * UPD update an existing entry
 * ------------------------------------------------------------------
 */
updEntry:
  parse arg updentry
  s4=screate(1000)
  call setg('dbOutArray',s4)
  call dbprint(UPDENTRY,'DETAILS')
  call setg('dbOutArray','')
  xdsn='pej.temp'
  call swrite(s4,"'"xdsn"'")
  ADDRESS TSO "REVED '"xdsn"'"
  s5=sread("'"xdsn"'")
  if sarray(s4)<>sarray(s5) then signal updChanged
  do __i=1 to sarray(s4)
     if strip(sget(s4,__i),'T')<>strip(sget(s5,__i),'T') then signal updChanged
  end
  xrc=0
  zerrsm='nothing changed'
  zerrlm='Nothing has beed changed in '_entry
  signal kvclean
updChanged:
  fmtcurrent=fmtstack('current') /* save current fmt stack entry */
  xrc=4
  s6=screate(250)
  call setg('dbOutArray',s6)
  call DBEncode s5
  call setg('dbOutArray','')
  call dbget(UPDENTRY,'details')   /* re-read the record with detail attributes */
  buffer.0='ARRAY 's6
  call fmtlist
  newline=left(_entry,34)||value(_entry'.'#acronym)'  'value(_entry'.'#capital)
  setcolor2=61952
  buffer.0='ARRAY 'getg('useArray')
  zerrsm='Entry changed'
  zerrlm='Entry has beed changed 'UPDENTRY
/* attach the messages to the fmtlist to which it belongs */
  call fmtstack(fmtcurrent,zerrsm,zerrlm)
  call sfree(s6)
 kvclean:
  call sfree(s4)
  call sfree(s5)
return xrc
/* ------------------------------------------------------------------
 * PRI Print selected Country or City
 * ------------------------------------------------------------------
 */
COUNTRY_pri:
  _entry=strip(substr(arg(1),1,32))
  _entry='country.'_entry
  signal priall
/* ------------------------------------------------------------------
 * PRI Print Country or City from a link report
 * ------------------------------------------------------------------
 */
links_pri:
  _entry=_getEntry(arg(1))
  priall:
  s4=screate(250)
  call setg('dbOutArray',s4)
  call dbprint(_entry,'Details')
  buffer.0='ARRAY 's4
  call fmtlist
  call setg('dbOutArray','')
  call sfree(s4)
return 0
/* ------------------------------------------------------------------
 * Link/Usage Country or City
 * ------------------------------------------------------------------
 */
links_lnk:
  _entry=_getEntry(arg(1))
  s3=screate(100)
  call setg('dbOutArray',s3)
  buffer.0='ARRAY 's3
  call DBUsage _entry,1,'details-only'
  call dbsay '   V   Refers to '_entry
  call dbsay '+'copies('-',45)'+'
  call dbsay '| 'left(_entry,44)'|'
  call dbsay '+'copies('-',45)'+'
  call dbsay '   V   References from '_entry
  call DBReference cnt,1,'details-only'
  buffer.0='ARRAY 's3
  hdr1='Links from/to '_entry
  call fmtlist ,,hdr1,,'REFS'
  call sfree s3
return 0
_getEntry:
  line=translate(arg(1),,'|-')
  do xi=words(line) to 1 by -1
     wrd=word(line,xi)
     if pos('.',wrd)>0 then leave
  end
return strip(wrd)
/* ------------------------------------------------------------------
 * Output Exit (call-back of DBLIST), prepare listing
 * ------------------------------------------------------------------
 */
outexit:
  parse arg _inline
  S1N=getg('useArray')
  if reci=0 then hdr='Country                       Acronym  Capital City'
  else do
    _country=left(_inline,42)
    parse var _country drop'.'_country
    ppi=pos(';;',_inline)
    if ppi=0 then return 0
    parse value substr(_inline,ppi-3) with short';;'_capital';;'rem
    short=left(strip(short),3)
    call sset(S1N,,_country' 'short'  'strip(_capital))
  end
return 0
