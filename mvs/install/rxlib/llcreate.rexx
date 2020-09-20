/* REXX */
/* ---------------------------------------------------------------------
 * Linked List
 *   Creates named Linked-List
 * ..................................  Created by PeterJ on 1. June 2019
 * x=LLCREATE list-name
 *   Creates a named Linked List
 *            x  = 0 Linked List create was successfull
 * x=LLADD    list-name element-value-to-save
 *   Adds a new list entry
 *            x  > 0 Element number of the added element
 *            x  =-8 Element not added, error in linking occurred
 * x=LLPUSH   list-name element-value-to-save (same as LLADD)
 *   Adds a new list entry
 *            x  > 0 Element number of the added element
 *            x  =-8 Element not added, error in linking occurred
 * x=LLINSERT list-name insert-number element-value-to-insert
 *   Inserts a new list entry after/between existing entries
 *            x  = 0 Element number successfully inserted
 *            x  = 4 insert number not present, element not inserted
 *            x  =-8 Element not inserted, error in linking occurred
 * x=LLDELETE list-name delete-number
 *   Deletes a list entry
 *            x  = 0 Element number successfully deleted
 *            x  = 4 insert number not present, element not inserted
 * x=LLNEXT   list-name <item-number>
 *   Finds the next element after item-number
 *            item-number defaults to the current element number
 *            x  = 0 next Element found
 *            x  = 8 no/no more next element present (end of List)
 * x=LLPREVIOUS list-name <item-number>
 *   Finds the previos element preceeding item-number
 *            item-number defaults to the current element number
 *            x  = 0 next Element found
 *            x  = 8 no/no more next element present (end of List)
 * x=LLPULL   list-name    (LIFO Stack)
 *   Returns the last added element and deletes it from linked list
 *            x  = Content of last element
 * x=LLFPUSH  list-name    (FIFO Stack)
 *   Returns the first added element and deletes it from linked list
 *            x  = Content of first element
 * LLList     list-name
 *   Reports all entries of the the Linked List
 * LLDIAGNOSE list-name
 *   Diagnosis of the Linked List (in case if broken chains)
 * ---------------------------------------------------------------------
 * + internally maintained variables
 * +   llcurrent  current list entry number (is n.th element in List)
 * +   llnext     next element after current entry
 * +   llprevious previous entry preceeding current entry
 * +   llValue    content of current entry
 * ---------------------------------------------------------------------
 */
/* ---------------------------------------------------------------------
 * Create Named Linked List
 * ---------------------------------------------------------------------
 */
llcreate:
  parse upper arg @name
  drop #LLIST.@NAME.
  #LLIST.@NAME.0.$next=1               /* next  pointer value.        */
  #LLIST.@NAME.0.$value='Anchor'       /* Add entry value             */
  #LLIST.@NAME.0.$prev=0               /* Set previous pointer        */
  #LLIST.@NAME.$HIGH=0                 /* Highest Pointer Number      */
  #LLIST.@NAME.$Last=0                 /* Last Entry Pointer in List  */
  #LLIST.@NAME.$CURRENT=0
  #LLIST.@NAME.MWIDTh=0
  #LLIST.@NAME.DISORDER=0
  return 0
/* ---------------------------------------------------------------------
 * Attach Element Linked List Element and link it
 * ---------------------------------------------------------------------
 */
lladd:
  parse arg @name,@val
  @name=translate(@name)
  @enum=llEntry(@name,@val)
  rc=llLink('FRED',#LLIST.@NAME.$LAST,@enum)
  rc=llLink('FRED',@enum,0)
  if rc>0 then return -8
  #LLIST.@NAME.$LAST=@enum
return _n
/* ---------------------------------------------------------------------
 * ADD Element on Linked LIST (Alias for LADD)
 * ---------------------------------------------------------------------
 */
llPUSH:
return Ladd arg(1) arg(2)
/* ---------------------------------------------------------------------
 * PULL last Element from Linked LIST and delete it
 * ---------------------------------------------------------------------
 */
llLPULL:   /* PULL Last, Alias of llPULL  */
llPULL:
rc=LLLast(arg(1))
_rc=llremove(arg(1),llCurrent)
return @value
/* ---------------------------------------------------------------------
 * PULL First Element from Linked LIST and delete it
 * ---------------------------------------------------------------------
 */
llFPULL:
rc=LLFirst(arg(1))
return @value
/* ---------------------------------------------------------------------
 * Create Linked List Item
 * ---------------------------------------------------------------------
 */
llEntry:
  parse arg @name,@val
  @name=translate(@name)
  _n=#LLIST.@NAME.$HIGH+1              /* current highes element no.  */
/* ... General Linked List Information ... */
  #LLIST.@NAME.$HIGH=_n                /* Highest Pointer Number      */
  #LLIST.@NAME.$CURRENT=_n
  #LLIST.@NAME._n.$next=-1           /* Set Link Attribute to not set */
  #LLIST.@NAME._n.$prev=-1           /* Set Link Attribute to not set */
  #LLIST.@NAME.MWIDTH=max(#LLIST.@NAME.MWIDTH,length(@val))
/* ... Entry Information ... */
  #LLIST.@NAME._n.$value=@val          /* Add entry value             */
return _n
/* ---------------------------------------------------------------------
 * Link Item to Last and Next Item
 * ---------------------------------------------------------------------
 */
llLink:
  parse arg @name,@from,@to
/* Test if Source exists, else abort link */
  if symbol('#LLIST.'@NAME'.'@from'.$value')<>'VAR' then return 8
/* Test if target exists, else abort link */
  if symbol('#LLIST.'@NAME'.'@to'.$value')<>'VAR' then return 8
  #LLIST.@NAME.@from.$next=@to
  #LLIST.@NAME.@to.$prev=@from
return 0
/* ---------------------------------------------------------------------
 * Insert Item within the Linked List
 * ---------------------------------------------------------------------
 */
llInsert: procedure expose #LLIST.
  parse arg @name,@indx,@val
  @name=translate(@name)
  if @indx>=#LLIST.@NAME.$High then return llADD(@name,@val)
  #LLIST.@NAME.DISORDER=1
  enum=llEntry(@name,@val)
  @indx=llLocate(@name,@indx)
  if @indx<0 then return 4
  oldnxt=#LLIST.@NAME.@INDX.$next     /* save old next ptr to rechain */
  rc=llLink(@name,@indx,enum)
  if rc>0 then return 8
  rc=llLink(@name,enum,oldnxt)
  if rc>0 then return 8
return 0
/* ---------------------------------------------------------------------
 * Delete Item in Linked List (relative entry number)
 * ---------------------------------------------------------------------
 */
llDelete: procedure expose #LLIST.
  parse upper arg @name,@indx
  @indx=llLocate(@name,@indx)
  if @indx<0 then return 4
  #LLIST.@NAME.DISORDER=1
  nxtptr=#LLIST.@NAME.@INDX.$next     /* save next ptr to rechain     */
  prvptr=#LLIST.@NAME.@INDX.$prev     /* save previous ptr to rechain */
  Drop #LLIST.@NAME.@INDX.
  #LLIST.@NAME.prvptr.$next=nxtptr    /* re-chain last element        */
  #LLIST.@NAME.nxtptr.$prev=prvptr    /* re-chain previous element    */
  #LLIST.@NAME.$CURRENT=nxtptr
return 0
/* ---------------------------------------------------------------------
 * Delete Item in Linked List (absolute entry number)
 * ---------------------------------------------------------------------
 */
llRemove:
  parse upper arg @name,@indx
  nxtptr=#LLIST.@NAME.@INDX.$next     /* save next ptr to rechain     */
  prvptr=#LLIST.@NAME.@INDX.$prev     /* save previous ptr to rechain */
  Drop #LLIST.@NAME.@INDX.
  #LLIST.@NAME.DISORDER=1
  #LLIST.@NAME.prvptr.$next=nxtptr    /* re-chain last element        */
  #LLIST.@NAME.nxtptr.$prev=prvptr    /* re-chain previous element    */
  #LLIST.@NAME.$CURRENT=nxtptr
return 0
/* ---------------------------------------------------------------------
 * Locate n.th Element in Linked List
 * ---------------------------------------------------------------------
 */
llLocate:
  parse arg @name,@indx
  if @indx=0 then return 0
  if #LLIST.@NAME.DISORDER=1 then return @indx
  _pl=#LLIST.@NAME.0.$next
  do q=1 for @indx-1 until _pl==0
     _pl=#LLIST.@NAME._pl.$next
  end
  if _pl=0 then return -1
return _pl
/* ---------------------------------------------------------------------
 * Get Next Element in Linked List
 * ---------------------------------------------------------------------
 */
llNext:
  parse upper arg @name,@next
  if llNxprv(1)>0 then return 8
return 0
/* ---------------------------------------------------------------------
 * Get previous Element in Linked List
 * ---------------------------------------------------------------------
 */
llPrevious:
  parse upper arg @name,@next
  if llNxprv(2)>0 then return 8
return 0
/* ---------------------------------------------------------------------
 * Get First Element in Linked List (Fast)
 * ---------------------------------------------------------------------
 */
llFirst:
  parse upper arg @name
  @next=#LLIST.@NAME.0.$next
  return llFast()
return 0
/* ---------------------------------------------------------------------
 * Get Last Element in Linked List (Fast)
 * ---------------------------------------------------------------------
 */
llLast:
  parse upper arg @name
  @next=#LLIST.@NAME.$Last
  return llFast()
return 0
/* ---------------------------------------------------------------------
 * Get Next/Previous Element in Linked List
 * ---------------------------------------------------------------------
 */
llNxprv:
  parse arg mode
  @rel=1
  if @next='' then do
     @next=#LLIST.@NAME.$CURRENT
     if mode=1 then @next=#LLIST.@NAME.@next.$next
        else @next=#LLIST.@NAME.@next.$PREV
     @rel=0   /* is already known offset */
  end
  else if left(@next,1)='L' then do
       @next=#LLIST.@NAME.$Last
       @rel=0
  end
  else if left(@next,1)='F' then do
       @next=#LLIST.@NAME.0.$next
       @rel=0
  end
  if @next>=1 & @next<=#LLIST.@NAME.$HIGH then nop
  else do
     llvalue=''
     llcurrent=-1
     return 8
  end
  if @rel=1 then do
     @next=llLocate(@name,@next) /* is relative */
     if @next<0 then return 8
  end
llFast:
  #LLIST.@NAME.$CURRENT=@next
  llnext=#LLIST.@NAME.@next.$next
  llprevious=#LLIST.@NAME.@next.$prev
  llcurrent=@next
  llValue=#LLIST.@NAME.@next.$value
return 0
/* ---------------------------------------------------------------------
 * Output Linked List
 * ---------------------------------------------------------------------
 */
llList:
  parse upper arg @name
  say copies('-',72)
  say 'Report Linked List '@name
  say copies('-',72)
  w=max(7, #LLIST.@NAME.MWIDTH ) /*use the max width of nums or 7. */
  _ci=right('item',6)
  _cp=right('ptr',6)
  _cv=right('value',w)
  _cn=right('next',6)
  _cr=right('prev',6)
  say _ci _cp _cv _cn _cr
  say copies('-',72)
  _p=#LLIST.@NAME.0.$next
  _p=0
  do j=0 until _p<=0      /*show all entries of linked list*/
     _v=right(#LLIST.@NAME._p.$value,w)
     _n=right(#LLIST.@NAME._p.$next,6)
     _q=right(#LLIST.@NAME._p.$prev,6)
     say  right(j,6) right(_p,6) _v _n _q
     _p=#LLIST.@NAME._p.$next
  end
if _p<0 then say 'Linked List chain broken, run llDiagnose'
say 'Last Stack Element Number '#LLIST.@NAME.$last
say 'Number of Stack Entries   '#LLIST.@NAME.$high
return
/* ---------------------------------------------------------------------
 * Diagnose Linked List
 * ---------------------------------------------------------------------
 */
llDiagnose:
  parse upper arg @name
  say copies('-',72)
  say 'Diagnose Linked List '@name
  say copies('-',72)
  w=max(7, #LLIST.@NAME.MWIDTH ) /*use the max width of nums or 7. */
  _ci=right('item',6)
  _cp=right('ptr',6)
  _cv=right('value',w)
  _cn=right('next',6)
  _cr=right('prev',6)
  say _ci _cp _cv _cn _cr
  say copies('-',72)
  do j=0 to #LLIST.@NAME.$high
     _v=right(#LLIST.@NAME.j.$value,w)
     _n=right(#LLIST.@NAME.j.$next,6)
     _q=right(#LLIST.@NAME.j.$prev,6)
     say  right(j,6) right(j,6) _v _n _q
  end
say 'Last Stack Element Number '#LLIST.@NAME.$last
say 'Number of Stack Entries   '#LLIST.@NAME.$high
return
