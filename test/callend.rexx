say '----------------------------------------'
say 'File callend.rexx'
/* CALL ON (#239): a command in the last clause of the program. The
   program ends without an OP_NEWCLAUSE after it, so the trap is called
   from OP_EXIT. The trap routine ends the program with RC 5; RC 0 means
   it was never called.   MVSTEST RC=5 */
signal start
trapped:
say 'Done callend.rexx'
exit 5
start:
say 'Testing CALL ON at the end of the program ...'
call on error name trapped
address linkmvs 'IEBGENER'
