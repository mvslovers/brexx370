say '----------------------------------------'
say 'File testdat.rexx'
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
say left('DATE',8,' ') 'test' right('1',3,' '),
 '.. PASS - date()' date()
/*
say left('DATE',8,' ') 'test' right('2',3,' '),
 '.. PASS -' date('B')
*/
say left('DATE',8,' ') 'test' right('2',3,' '),
 ".. PASS - date('D')" date('D')
say left('DATE',8,' ') 'test' right('3',3,' '),
 ".. PASS - date('E')" date('E')
say left('DATE',8,' ') 'test' right('4',3,' '),
 ".. PASS - date('M')" date('M')
say left('DATE',8,' ') 'test' right('5',3,' '),
 ".. PASS - date('N')" date('N')
say left('DATE',8,' ') 'test' right('6',3,' '),
 ".. PASS - date('O')" date('O')
say left('DATE',8,' ') 'test' right('7',3,' '),
 ".. PASS - date('S')" date('S')
say left('DATE',8,' ') 'test' right('8',3,' '),
 ".. PASS - date('U')" date('U')
say left('DATE',8,' ') 'test' right('9',3,' '),
 ".. PASS - date('W')" date('W')
say 'Done testdat.rexx'
exit 0
