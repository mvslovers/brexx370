/* REXX - running out of memory ends the step once and cleanly (#504)  */
/* MVSTEST RC=60                                                       */
/* The private area is too small for 100000 stem entries. The         */
/* interpreter has to report "Memory allocation failed" once and end   */
/* with RC 60: no second allocation in the error path (it looped about */
/* 1200 times and ended S0C4), no abend. Reaching the EXIT below would */
/* give RC 0.                                                          */
say '----------------------------------------'
say 'File oomstem.rexx'
do i = 0 to 99999
   k = (i * 7919) // 100003   /* all different, in no order: a flat tree */
   s.k = 1
end
say 'OOMSTEM  - 100000 stem entries fit .. *FAIL*'
exit 0
