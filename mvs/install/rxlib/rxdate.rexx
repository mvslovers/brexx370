/* ---------------------------------------------------------------------
 *  RXDATE Transforms Dates in various types
 *  ............................. Created by PeterJ on 21. November 2018
 *  RXDATE(<output-format>,<date>,<input-format>)
 *  date is formatted as defined in input-format
 *    it defaults to today's date
 *  Input Format represents the input date format
 *    it defaults to 'EUROPEAN'
 *     Base      is days since 01.01.0001
 *     JDN       is days since 24. November 4714 BC
 *     Julian    is yyyyddd    e.g. 2018257
 *     European  is dd/mm/yyyy e.g. 11/11/2018
 *     German    is dd.mm.yyyy e.g. 20.09.2018
 *     USA       is mm/dd/yyyy e.g. 12.31.2018
 *     STANDARD  is yyyymmdd   e.g. 20181219
 *     ORDERED   is yyyy/mm/dd e.g. 2018/12/19
 *  Output Format represents the output date format
 *    it defaults to 'EUROPEAN'
 *     Base      is days since 01.01.0001
 *     JDN       is days since 24. November 4714 BC
 *     Julian    is yyyyddd    e.g. 2018257
 *     Days      is ddd days in this year e.g. 257
 *     Weekday   is weekday of day e.g. Monday
 *     Century   is dddd days in this century
 *     European  is dd/mm/yyyy e.g. 11/11/2018
 *     German    is dd.mm.yyyy e.g. 20.09.2018
 *     USA       is mm/dd/yyyy e.g. 12.31.2018
 *     SHEurope  is dd/mm/yy   e.g. 11/11/18
 *     SHGerman  is dd.mm.yy   e.g. 20.09.18
 *     SHUSA     is mm/dd/yy   e.g. 12.31.18
 *     STANDARD  is yyyymmdd        e.g. 20181219
 *     ORDERED   is yyyy/mm/dd e.g. 2018/12/19
 *     SHORT     is dd mon yyyy e.g. 28. OCT 2018
 *     LONG      is dd month yyyy e.g. 12. MARCH 2018
 * ----------------------------------------------------------
 */
RXDATE: Procedure
parse upper arg outform,idate,inform
  if outform='' then outform='EUROPEAN'
  if inform=''  then inform ='EUROPEAN'
  if idate=''   then do
     idate=date('SORTED')  /* Take today */
     inform='STANDARD'
  end
  jdn=_DateI(idate,inform)
/* JDN date is numeric, else indate is in error */
  if datatype(jdn)<>'NUM' then return idate' invalid date format'
return _DateO(jdn,outform)
/* ----------------------------------------------------------
 *  Julian Day Number Calculation, number of days since:
 *     Monday, January 1, 4713 BC Julian calendar which is
 *     November 24, 4714 BC Gregorian calendar
 * ----------------------------------------------------------
 */
_JULDAYNUM: Procedure
parse value translate(arg(1),"","./") with day month year
  if month='' then parse arg day,month,year
  a=(14-month)%12
  m=month+12*a-3
  y=year+4800-a
  jdn=day+(153*m+2)%5+365*y
  jdn=jdn+y%4-y%100+y%400-32045
return jdn
/* ----------------------------------------------------------
 *  Convert Julian Day Number into Gregorian Date
 *  Dates before 24. Februar 1582 (introduction of the calendar)
 *  reflect the date as it would be in Gregorian calendar, not
 *  in Julian calendar
 *  The formula was taken from the 1990 edition of the U.S.
 *  Naval Observatory's Almanac for Computers
 * ----------------------------------------------------------
 */
_DateO: procedure
parse arg JDN,format
  if format='' then format='GERMAN'
/* BASE is REXX Type Format, starting 01.01.0001  */
  if abbreV('BASE',format,1) then return JDN-1721426
/* JDN is Julian Day Number starting 24. Nov 4714 BC */
  if abbreV('JDN',format,1) then return JDN
/* Translate Julian Day Number in Gregorian Date */
  L=JDN+68569
  N=4*L%146097
  L=L-(146097*N+3)%4
  i=4000*(L+1)%1461001
  L=L-1461*i%4+31
  J=80*L%2447
  dd=L-2447*J%80
  L=J%11
  mm=J+2-12*L
  YY=100*(N-49)+I+L
/* YEAR= yy ; Month=mm ; Day=dd */
  if abbreV('JULIAN',format,1) then do
     daysofyear=JDN-_JULDAYNUM(1,1,YY)+1
     return right(YY,4,'0')right(daysofyear,3,'0')
  end
  if abbreV('DAYS',format,1) then do
     daysofyear=JDN-_JULDAYNUM(1,1,YY)+1
     return right(daysofyear,3,'0')
  end
  if abbreV('WEEKDAY',format,1) then do
     jdn=trunc(jdn//7)
     SELECT
       WHEN jdn=0 THEN return 'Monday'
       WHEN jdn=1 THEN return 'Tuesday'
       WHEN jdn=2 THEN return 'Wednesday'
       WHEN jdn=3 THEN return 'Thursday'
       WHEN jdn=4 THEN return 'Friday'
       WHEN jdn=5 THEN return 'Saturday'
       WHEN jdn=6 THEN return 'Sunday'
     end
  end
  if abbreV('CENTURY',format,1) then do
     dayscentury=jdn-_JULDAYNUM(1,1,YY%100*100)+1
     return dayscentury
  end
  if abbreV('EUROPEAN',format,1) then  ,
     return right(dd,2,'0')'/'right(mm,2,'0')'/'right(YY,4,'0')
  if abbreV('SHEUROPE',format,1) then  ,
     return right(dd,2,'0')'/'right(mm,2,'0')'/'right(YY,2,'0')
  if abbreV('GERMAN',format,1) then  ,
     return right(dd,2,'0')'.'right(mm,2,'0')'.'right(YY,4,'0')
  if abbreV('SHGERMAN',format,1) then  ,
     return right(dd,2,'0')'.'right(mm,2,'0')'.'right(YY,2,'0')
  if abbreV('USA',format,1) then  ,
     return right(mm,2,'0')'/'right(dd,2,'0')'/'right(YY,4,'0')
  if abbreV('SHUSA',format,1) then  ,
     return right(mm,2,'0')'/'right(dd,2,'0')'/'right(YY,2,'0')
  if abbreV('STANDARD',format,1) then  ,
     return right(YY,4,'0')right(mm,2,'0')right(dd,2,'0')
  if abbreV('ORDERED',format,1) then  ,
     return right(YY,4,'0')'/'right(mm,2,'0')'/'right(dd,2,'0')
  if abbreV('SHORT',format,1) then do
     list='JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC'
     ms=word(list,mm)
     return right(dd,2,'0')' 'ms' 'right(YY,4,'0')
  end
  if abbreV('LONG',format,1) then do
     list='JANUARY FEBRUARY MARCH APRIL MAY JUNE JULY AUGUST',
          '  SEPTEMBER OCTOBER NOVEMBER DECEMBER'
     ms=word(list,mm)
     return right(dd,2,'0')' 'ms' 'right(YY,4,'0')
  end
return right(dd,2,'0')'.'right(mm,2,'0')'.'right(YY,4,'0')
/* ----------------------------------------------------------
 *  Converts given Date in Julian Day Number
 * ----------------------------------------------------------
 */
_DateI: procedure
parse arg IDATE,format
  testtype=translate(idate,'000',' ./')
  if datatype(testtype)<>'NUM' then return idate' invalid date format'
  if format='' then format='GERMAN'
  if abbreV('BASE',format,1) then return IDATE+1721426
  if abbreV('JDN',format,1) then return IDATE
  if abbreV('JULIAN',format,1) then do
     idate=right(idate,7,'0')
     YY=substr(idate,1,4)
     daysofyear=substr(idate,5,3)
     return _JULDAYNUM(1,1,YY)+daysofyear-1
  end
  if abbreV('DAYS',format,1) then ,
     return 'DAYS not allowed as input format'
  if abbreV('CENTURY',format,1) then ,
     return 'CENTURY not allowed as input format'
  if abbreV('EUROPEAN',format,1) then do
     parse  value translate(idate,"","/.") with dd mm YY
     return _JULDAYNUM(dd,mm,YY)
  end
  if abbreV('GERMAN',format,1) then do
     parse  value translate(idate,"","/.") with dd mm YY
     return _JULDAYNUM(dd,mm,YY)
  end
  if abbreV('USA',format,1) then do
     parse  value translate(idate,"","/.") with mm dd YY
     return _JULDAYNUM(dd,mm,YY)
  end
  if abbreV('STANDARD',format,1) then do
     idate=right(idate,8,'0')
     YY=substr(idate,1,4)
     mm=substr(idate,5,2)
     dd=substr(idate,7,2)
     return _JULDAYNUM(dd,mm,YY)
  end
  if abbreV('ORDERED',format,1) then do
     idate=right(idate,10,'0')
     YY=substr(idate,1,4)
     mm=substr(idate,6,2)
     dd=substr(idate,9,2)
     return _JULDAYNUM(dd,mm,YY)
  end
return format' invalid input format'
