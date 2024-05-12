/* -----------------------------------------------------------------
 * Part One  Sticky Note for User Info
 * -----------------------------------------------------------------
 */
  call setg('FMTMON_refreshCount',0)
  alias='TSO'   /* define alias (for stems) */
  call fssticky "TSO User",alias,,,5,12 /* Create FSS Screen defs */
  sticky.alias.__refresh=5   /* refresh every n seconds */
  /* rexx call to update sticky note */
  sticky.alias.__fetch="call StickyTSOuser "alias   
return 0
/* -----------------------------------------------------------------
 * Part Two  Procedure to create the sticky Content
 * -----------------------------------------------------------------
 */
StickyTSOuser:
  parse arg ##alias
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
     sticky.##alias.usri=peeks(ascbjbns,8)/* we is some happy camper! */
  end
  usri=usri+1
  sticky.##alias.usri=time()
/* remove old entries behind last line */
  do aix=usri+1 to sticky.##alias.0
     sticky.##alias.aix=''
  end
  sticky.##alias.0=usri
return 0
