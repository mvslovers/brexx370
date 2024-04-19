/* --------------------------------------------------------------------
 * Returns the estimated IPLDATE
 * --------------------------------------------------------------------
 */
 IPLDate:
   say 'IPL Monitor'
   say '-----------'
   $iplsec=mvsvar('MVSUP')         /* MVS up time in seconds          */
   $ipldays=$iplsec%86400          /* days MVS is running             */
   $iplrem=$iplsec//86400%1        /* remaining seconds               */
   days1900=date('b')-$ipldays     /* calculate days since 1.1.1900   */
   $iplsec=time('s')-$iplrem
   do while $iplsec<0
      $iplsec=$iplsec+86400
      days1900=days1900-1
   end
   $ipldate=date(,days1900,'B')  /* convert it back normal date     */
   $iplwday=date('WEEKDAY',days1900,'B')   /* convert it normal date*/
   $iplsec=sec2time($iplsec)
   $iplrem=sec2time($iplrem)
   $Time=time('l')
   say ' Current Time '$TIME
   say ' IPL on  '$iplwday $ipldate' at '$iplsec
   say ' MVS up  for '$ipldays' days '$iplrem' hours'
return
