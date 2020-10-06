say '----------------------------------------'
say 'File time.rexx'
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
say left('TIME',8,' ') '- test' right('1',3,' '),
 '.. PASS - time()' time()
say left('TIME',8,' ') '- test' right('2',3,' '),
 ".. PASS - time('C')" time('C')
say left('TIME',8,' ') '- test' right('3',3,' '),
 ".. PASS - time('E')" time('E')
say left('TIME',8,' ') '- test' right('4',3,' '),
 ".. PASS - time('H')" time('H')
say left('TIME',8,' ') '- test' right('5',3,' '),
 ".. PASS - time('L')" time('L')
say left('TIME',8,' ') '- test' right('6',3,' '),
 ".. PASS - time('M')" time('M')
say left('TIME',8,' ') '- test' right('7',3,' '),
 ".. PASS - time('n')" time('n')
say left('TIME',8,' ') '- test' right('8',3,' '),
 ".. PASS - time('R')"  time('R')
say left('TIME',8,' ') '- test' right('9',3,' '),
 ".. PASS - time('s')"  time('s')
/* There are also lots of conversions. */
/* say time('s',"16:54:22",'N') need to debug */
say 'Done time.rexx'
exit 0
