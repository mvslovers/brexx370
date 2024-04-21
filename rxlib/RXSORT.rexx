/* ---------------------------------------------------------------------
 * SORT    various Sort algorithms
 * ..................Adapted to BREXX by Peter Jacob   15. December 2018
 *
 *   CALL RXSort sort-type
 *     Stem to sort must be provided in SORTIN.
 *     sort-type:  QUICKSORT      *** best performance
 *                 SHELLSORT      *** good performance
 *                 HEAPSORT       *** satisfying performance
 *                 BUBBLESORT     *** worst performance
 * ---------------------------------------------------------------------
 */
RXSort: procedure expose sortin. execTime
  parse upper arg sort,asc
  _t=time('e')
  stemmax=sortin.0
  if datatype(sortin.0)='NUM' & sortin.0>0 then nop
  else do
     say 'SORTIN.0 has invalid content'
     return 8
  end
  if sort='' then sort='QUICKSORT'
  if      abbrev('QUICKSORT',sort,1)  then call _qsort 1,stemmax
  else if abbrev('SHELLSORT',sort,1)  then call _shsort
  else if abbrev('HEAPSORT',sort,1)   then call _hpsort
  else if abbrev('BUBBLESORT',sort,1) then call _bbsort
  if abbrev('DESCENDING',asc,3)  then call sortDescending
  execTime=trunc(time('e')-_t,2)
return 0
/* ---------------------------------------------------------------------
 * QUICKSORT
 * Adapted to BREXX by Peter Jacob   15. December 2018
 *
 *   CALL QuickSort           Stem to sort must be provided in SORTIN.
 * ---------------------------------------------------------------------
 */
_qsort: procedure expose sortin.
  arg $FROM,$TO
/* start Quick Sorting */
  $i=$FROM
  #j=$TO
  k=($FROM + $TO)%2
  _m=SORTIN.k
  do until $i > #j
     do while SORTIN.$i << _m ; $i=$i+1; end
     do while SORTIN.#j >> _m ; #j=#j-1; end
     if $i <= #j then do
        #sw=SORTIN.$i
        SORTIN.$i=SORTIN.#j
        SORTIN.#j=#sw
        $i=$i+1; #j=#j-1
     end
  end
  if #j-$FROM>11 then call _qsort $FROM, #j
     else             call _bsort $FROM, #j
  if $to-$i>11   then call _qsort $i, $TO
     else             call _bsort $i, $TO
return
/* for small portions, use bubble sort style, faster than recursion */
_bsort: procedure expose sortin.
  arg $FROM,$TO
  do $FROM=$FROM to $TO -1
     $sm=$FROM
     do j=$FROM+1 to $TO; if SORTIN.j<<SORTIN.$sm then $sm=j; end
     #sw=SORTIN.$sm; SORTIN.$sm=SORTIN.$FROM; SORTIN.$FROM=#sw
  end
return
/* ---------------------------------------------------------------------
 * SHELLSORT
 * Adapted to BREXX by Peter Jacob   15. December 2018
 *
 *   CALL ShellSort           Stem to sort must be provided in SORTIN.
 * ---------------------------------------------------------------------
 */
_shsort: procedure expose sortin.
  #d=sortin.0 % 2
  do while #d>0
     do until ?complete
        ?complete=1
        do $i=1 for sortin.0-#d
           _j=$i+#d
           if sortin.$i >> sortin._j then do
              temp=sortin.$i
              sortin.$i=sortin._j
              sortin._j=temp
              ?complete=0
           end
        end
     end
     #d=#d%2
  end
return
/* ---------------------------------------------------------------------
 * HEAPSORT
 * Adapted to BREXX by Peter Jacob   15. December 2018
 *
 *   CALL HeapSort            Stem to sort must be provided in SORTIN.
 * ---------------------------------------------------------------------
 */
_hpsort: procedure expose SORTIN.
  m = SORTIN.0
  n = m
  do k=m % 2 to 1 by -1
     call heapsub k n
  end /* do */
  do while n>1
     t = sortin.1
     sortin.1 = sortin.n
     sortin.n = t
     n = n-1
     call heapsub 1 n
  end /* do */
return
heapsub: procedure expose sortin.
  parse arg k n
  v = sortin.k
  do while k <= n%2
     j = k+k
     if j < n then do
        i = j+1
        if sortin.j << sortin.i then j=j+1
    end  /* do */
    if v >>= sortin.j then signal label                      /* v2.80 */
    sortin.k = sortin.j
    k = j
  end /* do */
label:
  SORTIN.k = v
return
/* ---------------------------------------------------------------------
 * BUBBLESORT
 * Adapted to BREXX by Peter Jacob   15. December 2018
 *
 *   CALL BubbleSort          Stem to sort must be provided in SORTIN.
 * ---------------------------------------------------------------------
 */
_bbsort: procedure expose sortin.
#complete=0
recs=sortin.0
do while #complete=0
   #complete=1
   do i=1 for recs-1
      j=i+1
      if sortin.i >> sortin.j then do
         #complete=0
         temp=sortin.j
         sortin.j=sortin.i
         sortin.i=temp
      end
   end
   recs=recs-1
end
return
/* ---------------------------------------------------------------------
 * re-order into DESCENDING sequence
 * ---------------------------------------------------------------------
 */
sortDescending:
#h=sortin.0
_m=#h%2
do #i=1 for _m
   $t=sortin.#h
   sortin.#h=sortin.#i
   sortin.#i=$t
   #h=#h-1
end
return
