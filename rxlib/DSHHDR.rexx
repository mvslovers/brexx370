/* -----------------------------------------------------------------
 * Part One  Sticky Note for Writing Headerline(s)
 * -----------------------------------------------------------------
 */
  parse arg row,col,rows,cols,color
  alias=gettoken()      /* define alias (for stems) */
  /* Create FSS Screen defs */
  call fssDash  'Header',alias,row,col,rows,cols,color,'PLAIN'     
  sticky.alias.__refresh=60   /* refresh every n seconds */
  sticky.alias.__fetch=""
return 0
/* -----------------------------------------------------------------
 * Part Two  not needed for Header, will be set by SETHDR
 * -----------------------------------------------------------------
 */
