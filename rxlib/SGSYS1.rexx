sgsys: Procedure
  s1=screate(1000)
  call sset(s1,,'System Information')
  call sset(s1,,'------------------')
  call sset(s1,,"Server UserId   "userid())
  call sset(s1,,"ISPF            "sysvar('SYSISPF'))
  call sset(s1,,"Host            "sysvar('SYSCP'))
  call sset(s1,,"System          "mvsvar('SYSNAME'))
  call sset(s1,,"CPU             "mvsvar('CPU'))
  call sset(s1,,"NetID           "sysvar("SYSNODE"))
  call sset(s1,,"NJE38           "mvsvar("SYSNJVER"))
  call sset(s1,,"MVS up          "sec2time(mvsvar("MVSUP")))
  call sset(s1,,'Active TSO User(s)')
  call sset(s1,,'------------------')
  call sgtsouser
  call sset(s1,,'Active MVS Regions')
  call sset(s1,,'------------------')
  call sgtregion
  s2=screate(5000)
  call mttx('REFRESH',s2)
  call sset(s1,,'Last Trace Table Entries')
  call sset(s1,,'------------------------')
  s3=scopy(s2,1,100,s1)
  call sfree s2
return s1
sgtsouser:
  cvt=peeka(16)
  asvt=peeka(cvt+556)+512               /* get asvt                 */
  asvtmaxu=peeka(asvt+4)                /* get max asvt entries     */
  do aix = 0 to asvtmaxu - 1
     ascb=peeks(asvt+16+aix*4,4)        /* get ptr to ascb (skip */
     if bitand(ascb,'80000000'x)<>'00000000'x then iterate
     ascb=c2d(ascb)                     /* get ascb address         */
     cscb=peeka(ascb+56)                /* get cscb address         */
     chtrkid=peeks(cscb+28,1)           /* check addr space type    */
     if chtrkid<>'01'x then iterate     /* 01x is tso user          */
     ascbjbns=peeka(ascb+176)           /* get ascbjbns             */
     call sset(s1,,'  'peeks(ascbjbns,8))
  end
return
sgtRegion:
  cvt=peeka(16)
  asvt=peeka(cvt+556)+512               /* get asvt                 */
  asvtmaxu=peeka(asvt+4)                /* get max asvt entries     */
  do aix = 0 to asvtmaxu - 1
     ascb=peeks(asvt+16+aix*4,4)        /* get ptr to ascb (skip */
     if bitand(ascb,'80000000'x)<>'00000000'x then iterate
     ascb=c2d(ascb)                     /* get ascb address         */
     cscb=peeka(ascb+56)                /* get cscb address         */
     chtrkid=peeks(cscb+28,1)           /* check addr space type    */
     ascbjbns=peeka(ascb+176)           /* get ascbjbns             */
     mvsregion=peeks(ascbjbns,8)
     if mvsregion='INIT    ' then iterate
     call sset(s1,,'  'mvsregion)
  end
return
