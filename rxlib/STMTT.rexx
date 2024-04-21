/* -----------------------------------------------------------------
 * Part One  Sticky Note for Master Trace Table
 * -----------------------------------------------------------------
 */
  alias=gettoken() /* define alias (for stems) */
  call fssticky 'Trace Table',alias,,,10,50  /* Create FSS Screen defs */
  sticky.alias.__refresh=15  /* refresh every n seconds */
  sticky.alias.__fetch="call StickyMasterTT "alias",10" /* rexx call to update sticky note */
return 0
/* -----------------------------------------------------------------
 * Part Two  Procedure to create the sticky Content
 * -----------------------------------------------------------------
 */
StickyMasterTT:
  parse arg __alias,maxl
  if mtt('REFRESH')<0 then _line.0=0
  j=0
  maxl=max(_line.0-maxl+1,1)
  do i=maxl to _line.0
     j=j+1
     sticky.__alias.j=_line.i
  end
return 0
