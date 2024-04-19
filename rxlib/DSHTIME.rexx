/* -----------------------------------------------------------------
 * Part One  Sticky Dash for User Info
 * -----------------------------------------------------------------
 */
  parse arg row,col,rows,cols,color
  alias=gettoken() /* define alias (for stems) */
  call fssDash 'Time',alias,row,col,rows,cols,color,'PLAIN' /* Create FSS Screen defs */
  sticky.alias.__refresh=10  /* refresh every n seconds */
  sticky.alias.__fetch="call StickyTime "alias /* rexx call to update sticky note */
return 0
/* -----------------------------------------------------------------
 * Part Two  Procedure to create the sticky Content
 * -----------------------------------------------------------------
 */
StickyTime:
  parse arg __alias
  sticky.__alias.1=Time()
return 0
