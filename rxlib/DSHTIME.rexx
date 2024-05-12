/* -----------------------------------------------------------------
 * Part One  Sticky Dash for User Info
 * -----------------------------------------------------------------
 */
  parse arg row,col,rows,cols,color
  alias=gettoken() /* define alias (for stems) */
   /* Create FSS Screen defs */
  call fssDash 'Time',alias,row,col,rows,cols,color,'PLAIN'
  sticky.alias.__refresh=10  /* refresh every n seconds */
   /* rexx call to update sticky note */
  sticky.alias.__fetch="call StickyTime "alias
return 0
/* -----------------------------------------------------------------
 * Part Two  Procedure to create the sticky Content
 * -----------------------------------------------------------------
 */
StickyTime:
  parse arg __alias
  sticky.__alias.1=Time()
return 0
