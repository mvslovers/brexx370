/* ---------------------------------------------------------------------
 *  DaysBetween Calulates days between 2 dates
 *  ............................. Created by PeterJ on 21. November 2018
 *  DAYSBETWEEN(date1,date2,<date-format1>,<date-format2>)
 *  date1 represents the from date (usually lower than date2)
 *  date2 represents the to   date (usually higher than date1)
 *  date1/date2 are formatted in date-format1/date-format2
 *  date-format1/date-format2 represents the date-formats
 *    they default to 'EUROPEAN'
 *     Base      is days since 01.01.0001
 *     JDN       is days since 24. November 4714 BC
 *     Julian    is yyyyddd    e.g. 2018257
 *     European  is dd/mm/yyyy e.g. 11/11/2018
 *     German    is dd.mm.yyyy e.g. 20.09.2018
 *     USA       is mm/dd/yyyy e.g. 12.31.2018
 *     STANDARD  is yyyymmdd   e.g. 20181219
 *     ORDERED   is yyyy/mm/dd e.g. 2018/12/19
 *
 * ---------------------------------------------------------------------
 */
DaysBetw:
 parse arg date1,date2,format1,format2
 if format1='' then format1='EUROPEAN'
 if format2='' then format2=format1
 if date2=''   then do
    date2=date('SORTED')  /* Take today */
    format2='STANDARD'
 end
 if date1=''   then do
    date1=date('SORTED')  /* Take today */
    format1='STANDARD'
 end
 jdn1=_DateI(date1,format1)
/* JDN date is numeric, else indate is in error */
 if datatype(jdn1)<>'NUM' then return date1' invalid date format'
 jdn2=_DateI(date2,format2)
/* JDN date is numeric, else indate is in error */
 if datatype(jdn2)<>'NUM' then return date2' invalid date format'
return jdn2-jdn1
