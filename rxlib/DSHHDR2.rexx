/* -----------------------------------------------------------------
 * Part One  Sticky Note for Writing Headerline(s)
 * -----------------------------------------------------------------
 */
  parse arg row,col,rows,cols,color
  alias=gettoken()      /* define alias (for stems) */
   /* Create FSS Screen defs */
  call fssDash  'Header2',alias,row,col,rows,cols,color,'PLAIN'    
  /* refresh every n seconds */
  sticky.alias.__refresh=60                               
  sticky.alias.__fetch=""
return 0
/* -----------------------------------------------------------------
 * Part Two  not needed for Header, will be set by SETHDR2
 * -----------------------------------------------------------------
 */
