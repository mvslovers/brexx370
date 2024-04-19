TSOuser:
  parse arg stem
  if stem='' then stem='tsouser.'
  usri=0
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
     usri=usri+1
     interpret stem'usri=peeks(ascbjbns,8)'   /* we is some happy camper! */
  end
  interpret stem'0=usri'
return 0
