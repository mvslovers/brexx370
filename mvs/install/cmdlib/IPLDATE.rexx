tickfactor=1.024                /* RMCT time ticks a bit slower       */
rmcttod=_adr(rmct()+124)        /* pick start time                    */
iplsec=RMCTTOD%1000*tickfactor  /* Convert into secs and mult. factor */
ipldays=iplsec%86400            /* days MVS is running                */
iplrem=iplsec//86400%1          /* remaining seconds                  */
days1900=Rxdate('b')-ipldays    /* calculate days since 1.1.1900      */
ipldate=Rxdate(,days1900,'B')   /* convert it back normal date        */
iplwday=Rxdate('WEEKDAY',days1900,'B') /* convert it back normal date */
cursec=time('s')-iplsec
do while cursec<0
   cursec=cursec+86400
end
say 'Current Time 'time('L')
say 'IPL on       'iplwday' 'ipldate' at 'sec2time(cursec)
say 'MVS up for   'ipldays' days 'sec2time(iplrem)' hours'
exit
/* ---------------------------------------------------------------------
 * address some mvs control blocks
 * ---------------------------------------------------------------------
 */
cvt:  return _adr(16)
rmct: return _adr(cvt()+604)
_adr: return c2d(storage(d2x(arg(1)),4))  /* return pointer (decimal) */
