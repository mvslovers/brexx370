/* REXX */
/* ---------------------------------------------------------------------
 * RXStack
 *   Creates named Stack
 * ..................................  Created by PeterJ on 5. June 2019
 * x=RXCREATE QUEUE-NAME
 *   Creates a named STACK
 *            x  = 0 STACK create was successfull
 * x=LLADD    QUEUE-NAME element-value-to-save
 *   Adds a new list entry
 *            x  > 0 Element number of the added element
 *            x  =-8 Element not added, error in linking occurred
 * x=RXPUSH   QUEUE-NAME element-value-to-save (same as LLADD)
 *   Adds a new list entry
 *            x  > 0 Element number of the added element
 *            x  =-8 Element not added, error in linking occurred
 * x=RXPULL   QUEUE-NAME   (LIFO Stack)
 *   Returns the last added element and deletes it from STACK
 *            x  = Content of last element
 * x=RXQUEUE  QUEUE-NAME   (FIFO Stack)
 *   Returns the first added element and deletes it from STACK
 *            x  = Content of first element
 * RXLIST     QUEUE-NAME
 *   Reports all entries of the the STACK
 * ---------------------------------------------------------------------
 */
/* ---------------------------------------------------------------------
 * Create Named STACK
 * ---------------------------------------------------------------------
 */
RXCREATE:
  parse upper arg @name
  drop #RXSTACK.@NAME.
  #RXSTACK.@NAME.$HIGH=0               /* Highest Pointer Number      */
  #RXSTACK.@NAME.$LOW=0                /* Lowest Pointer Number QUEUE */
  return 0
/* ---------------------------------------------------------------------
 * Push Element into named Stack
 * ---------------------------------------------------------------------
 */
RXPUSH:
  parse arg @name,@val
  @name=translate(@name)
  _n=#RXSTACK.@NAME.$HIGH+1            /* current highes element no.  */
/* ... General STACK Information ... */
  #RXSTACK.@NAME.$HIGH=_n              /* Highest Pointer Number      */
/* ... Entry Information ... */
  #RXSTACK.@NAME._n.$value=@val        /* Add entry value             */
return _n
/* ---------------------------------------------------------------------
 * PULL last Element from STACK
 * ---------------------------------------------------------------------
 */
RXPULL:
  _n=#RXSTACK.@NAME.$HIGH              /* current highes element no.  */
  #RXSTACK.@NAME.$HIGH=_n-1            /* current highes element no.  */
  return #RXSTACK.@NAME._n.$value      /* Return Stack element        */
return @value
/* ---------------------------------------------------------------------
 * PULL First Element from STACK and delete it
 * ---------------------------------------------------------------------
 */
RXQUEUE:
  _n=#RXSTACK.@NAME.$LOW+1             /* current highes element no.  */
  #RXSTACK.@NAME.$LOW=_n               /* current highes element no.  */
  return #RXSTACK.@NAME._n.$value      /* Return Stack element        */
/* ---------------------------------------------------------------------
 * Output STACK
 * ---------------------------------------------------------------------
 */
RXLIST:
  parse upper arg @name
  say copies('-',72)
  say 'Report STACK '@name
  say copies('-',72)
  w=max(7, #RXSTACK.@NAME.MWIDTH ) /*use the max width of nums or 7. */
  _ci=right('item',6)
  _cp=right('ptr',6)
  _cv=right('value',w)
  say _ci _cp _cv
  say copies('-',72)
  do j=0 for l _p<=0      /*show all entries of STACK*/
     _v=right(#RXSTACK.@NAME._p.$value,w)
     say  right(j,6) _v
  end
say 'Last Stack Element Number '#RXSTACK.@NAME.$last
say 'Number of Stack Entries   '#RXSTACK.@NAME.$high
return
