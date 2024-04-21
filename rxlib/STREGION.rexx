/* -----------------------------------------------------------------
 * Part One  Sticky Note for REGION Info
 * -----------------------------------------------------------------
 */
  alias=gettoken() /* define alias (for stems) */
  call fssticky "MVS Region",alias,,,12,15    /* Create FSS Screen defs */
  sticky.alias.__refresh=30  /* refresh every n seconds */
  sticky.alias.__fetch="call StickyMVSRegion "alias  /* rexx call to update sticky note */
return 0
/* -----------------------------------------------------------------
 * Part Two  Procedure to create the sticky Content
 * -----------------------------------------------------------------
 */
StickyMVSRegion:
  parse upper arg ##alias
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
     ascbjbns=peeka(ascb+176)           /* get ascbjbns             */
     mvsregion=peeks(ascbjbns,8)
     if mvsregion='INIT    ' then iterate
     usri=usri+1
     sticky.##alias.usri=mvsregion           /* we is some happy camper! */
  end
  usri=usri+1
  sticky.##alias.usri=time('L')        /* we is some happy camper! */
return 0
