/* ---------------------------------------------------------------------
 * Convert SECs to HH:MM:SS time
 * .............................. Created by PeterJ on 17. February 2019
 *     if 2. parameter is "DAYS" then dd DAYS HH:MM:SS
 *        3. parameter (optional) is day string, it defaults to 'day(s)'
 * ---------------------------------------------------------------------
 */
sec2time: procedure
 parse upper arg intime,days,dds
 if arg(3)='' then dds='day(s)'
 if abbrev('DAYS',days,1)=1 then do
    timdd=intime%86400                          /* days               */
    timrr=INTIME//86400                         /* remainder          */
    timhh=timrr%3600                            /* hours              */
    timrr=INTIME//3600                          /* remainder          */
    timmm=timrr%60                              /* minutes            */
    timss=timrr//60                             /* seconds            */
    return timdd' 'dds' '_timeF(timhh)':'_timeF(timmm)':'_timeF(timss)
 end
 timhh=intime%3600                              /* hours              */
 timrr=intime//3600                             /* remainder          */
 timmm=timrr%60                                 /* minutes            */
 timss=timrr//60                                /* seconds            */
return _timeF(timhh)':'_timeF(timmm)':'_timeF(timss%1)
_timeF:
 return right(arg(1),2,'0')
