/* -----------------------------------------------------------------
 * Part One  Sticky Dash for User Info
 * -----------------------------------------------------------------
 */
  parse arg row,col,rows,cols,color
  alias=gettoken() /* define alias (for stems) */
  /* Create FSS Screen defs */
  call fssDash 'User Info',alias,row,col,rows,cols,color 
  sticky.alias.__refresh=60  /* refresh every n seconds */
  /* rexx call to update sticky note */
  sticky.alias.__fetch="call StickyUser "alias 
return 0
/* -----------------------------------------------------------------
 * Part Two  Procedure to create the sticky Content
 * -----------------------------------------------------------------
 */
StickyUser:
  parse arg __alias
  sticky.__alias.1="User   "userid()
  sticky.__alias.2="ISPF   "sysvar('SYSISPF')
  sticky.__alias.3="Host   "sysvar('SYSCP')
  sticky.__alias.4="System "mvsvar('SYSNAME')
  sticky.__alias.5="CPU    "mvsvar('CPU')
  sticky.__alias.6="NetID  "sysvar("SYSNODE")
  sticky.__alias.7="NJE38  "mvsvar("SYSNJVER")
  sticky.__alias.8="MVS up "sec2time(mvsvar("MVSUP"))
return 0
