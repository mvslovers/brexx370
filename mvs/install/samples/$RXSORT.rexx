smax=500     /* Number of random entries */
/* ---------------------------------------------------------------------
 * QuickSORT
 * ---------------------------------------------------------------------
 */
call setupArray 'QuickSort'
elp=time('e')
call RXSORT "QUICKSORT"
elp=Trunc(time('e')-elp,3)
say "quicksort  time "elp" seconds, items: "smax
/* ---------------------------------------------------------------------
 * ShellSORT
 * ---------------------------------------------------------------------
 */
call setupArray 'ShellSort'
elp=time('e')
call RXSORT "SHELLSORT"
elp=Trunc(time('e')-elp,3)
say "shellsort  time "elp" seconds, items: "smax
/* ---------------------------------------------------------------------
 * HeapSORT
 * ---------------------------------------------------------------------
 */
call setupArray 'HeapSort'
elp=time('e')
call RXSORT "HEAPSORT"
elp=Trunc(time('e')-elp,3)
say "heapsort   time "elp" seconds, items: "smax
/* ---------------------------------------------------------------------
 * BubbleSORT
 * ---------------------------------------------------------------------
 */
if smax>1500 then do
   say "Bubble Sort is not recommended for items > 250, requested are "s
   exit
end
call setupArray 'BubbleSort'
elp=time('e')
call RXSORT "BUBBLESORT"
elp=Trunc(time('e')-elp,3)
say "bubblesort time "elp" seconds, items: "smax
exit
/* ---------------------------------------------------------------------
 * Some Subroutines
 * ---------------------------------------------------------------------
 */
setupArray:
parse arg stype
do i=1 to smax
   sortin.i=right(RANDOM(0,10000),6,'0')' 'stype
end
sortin.0=smax
return
