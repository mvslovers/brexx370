/* -----------------------------------------------------------------
 * Part One  Sticky Note for User Info
 * -----------------------------------------------------------------
 */
  alias=gettoken() /* define alias (for stems) */
  call fssticky 'User Info',alias,,,8,24  /* Create FSS Screen defs */
  sticky.alias.__refresh=60  /* refresh every n seconds */
  /* rexx call to update sticky note */
  sticky.alias.__fetch="call StickyUser "alias 
return 0
/* -----------------------------------------------------------------
 * Part Two  Procedure to create the sticky Content
 * -----------------------------------------------------------------
 */
StickyUser:
  parse arg alias
  sticky.alias.1="User   "userid()
  sticky.alias.2="ISPF   "sysvar('SYSISPF')
  sticky.alias.3="Host   "sysvar('SYSCP')
  sticky.alias.4="System "mvsvar('SYSNAME')
  sticky.alias.5="CPU    "mvsvar('CPU')
  sticky.alias.6="NetID  "sysvar("SYSNODE")
  sticky.alias.7="NJE38  "mvsvar("SYSNJVER")
  sticky.alias.8="MVS up "sec2time(mvsvar("MVSUP"))
return 0
