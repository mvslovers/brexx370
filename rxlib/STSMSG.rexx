/* -----------------------------------------------------------------
 * Part One  Sticky Note for User Info
 * -----------------------------------------------------------------
 */
  alias=gettoken() /* define alias (for stems) */
  /* Create FSS Screen defs */
  call fssticky 'SMSG',alias,1,,1,16,#turq'+'#uscore,'PLAIN'    
  sticky.alias.__refresh=1   /* refresh every n seconds */
  sticky.alias.__fetch=""
return 0
/* -----------------------------------------------------------------
 * Part Two  not needed
 * -----------------------------------------------------------------
 */
