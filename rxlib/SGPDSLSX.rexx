sgpdslst: procedure
  parse arg level,pds,local
  liblst=screate(1500)
  call dir("'"pds"'")
  today=date('jdn')-60
  today=date('Standard',today,'JDN')
  __yy=substr(today,3,2)
  __mm=substr(today,5,2)
  __dd=substr(today,7,2)
  today=__yy'-'__mm'-'__dd'*'
  do i=1 to direntry.0
     if symbol('direntry.i.udate')='VAR' then ddate=direntry.i.udate
     else ddate=today
     if symbol('direntry.i.utime')='VAR' then dtime=direntry.i.utime
     else dtime='00:00:00'
     call sset(LIBLST,,dirEntry.i.name';'ddate';'dtime)
  end
return liblst
