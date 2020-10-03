say '----------------------------------------'
say 'File delstr.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("delstr('abcd',3)","\== 'ab'",1)
r=r+rtest("delstr('abcde',3,2)","\== 'abe'",2)
r=r+rtest("delstr('abcde',6)","\== 'abcde'",3)
/* From: Mark Hessling */
r=r+rtest("delstr('Med lov skal land bygges', 6)","\== 'Med l'",4)
r=r+rtest("delstr('Med lov skal land bygges', 6,10)","\== 'Med lnd bygges'",5)
r=r+rtest("delstr('Med lov skal land bygges', 1)","\== ''",6)
r=r+rtest("delstr('Med lov skal', 30)","\== 'Med lov skal'",7)
r=r+rtest("delstr('Med lov skal', 8 , 8)","\== 'Med lov'",8)
r=r+rtest("delstr('Med lov skal', 12)","\== 'Med lov ska'",9)
r=r+rtest("delstr('Med lov skal', 13)","\== 'Med lov skal'",10)
r=r+rtest("delstr('Med lov skal', 14)","\== 'Med lov skal'",11)
r=r+rtest("delstr('', 30)","\== ''",12)
say 'Done delstr.rexx'
exit r
