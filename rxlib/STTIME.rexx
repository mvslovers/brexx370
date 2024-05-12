/* -----------------------------------------------------------------
 * Part One  Sticky Note for DATE/TIME
 * -----------------------------------------------------------------
 */
  alias=gettoken() /* define and use unique alias (for stems)                */
 /*               x ---------------------------- Sticky note title           */
 /*               |         x --------------------- short alias              */
 /*               |         |    x ----------------- row position            */
 /*               |         |    |x --------------- column position          */
 /*               |         |    || x -------------- height (number of rows) */
 /*               |         |    || | x ----------- width  (number of cols   */
 /*               |         |    || | | x -------- color of sticky note      */
 /*               |         |    || | | |  x -- FRAME/NOFRAME                */
 /*               |         |    || | | |  |                                 */
  call fssticky 'Date/Time',alias,,,4,19,,'FRAME'  /* Create FSS Screen defs */
  /* rexx call to update sticky note */
  sticky.alias.__fetch="call StickyDateTime "alias 
  sticky.alias.__refresh=1   /* refresh every n seconds */
return 0
/* -----------------------------------------------------------------
 * Part Two  Procedure to create the sticky Content
 * -----------------------------------------------------------------
 */
StickyDateTime:
  parse arg alias
  if symbol('sticky.alias.start')='LIT' then sticky.alias.start=time('cpu')
  sticky.alias.1="Date     "date('E')
  sticky.alias.2="Time     "time()
  sticky.alias.3="CPU Time "format(TIME('CPU')-sticky.alias.start,,3)
  sticky.alias.4="Elapsed  "sec2time(time('e'))
return 0
