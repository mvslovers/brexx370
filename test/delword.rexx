say '----------------------------------------'
say 'File delword.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("delword('Now is the time',2,2)","\== 'Now time'",1)
r=r+rtest("delword('Now is the time ',3)","\== 'Now is '",2)
r=r+rtest("delword('Now time',5)","\== 'Now time'",3)
/* From: Mark Hessling */
r=r+rtest("delword('Med lov skal land bygges', 3)","\== 'Med lov '",4)
r=r+rtest("delword('Med lov skal land bygges', 1)","\== ''",5)
r=r+rtest("delword('Med lov skal land bygges', 1,1)",,
"\== 'lov skal land bygges'",6)
r=r+rtest("delword('Med lov skal land bygges', 2,3)","\== 'Med bygges'",7)
r=r+rtest("delword('Med lov skal land bygges', 2,10)","\== 'Med '",8)
r=r+rtest("delword('Med lov skal land bygges', 3,2)","\== 'Med lov bygges'",9)
r=r+rtest("delword('Med lov skal land bygges', 3,2)","\== 'Med lov bygges'",10)
r=r+rtest("delword('Med lov skal land bygges', 3,2)","\== 'Med lov bygges'",11)
r=r+rtest("delword(' Med lov skal', 1,0)","\== ' Med lov skal'",12)
r=r+rtest("delword(' Med lov skal ', 4)","\== ' Med lov skal '",13)
r=r+rtest("delword('', 1)","\== ''",14)
r=r+rtest("delword('Med lov skal land bygges', 3,0)",,
"\== 'Med lov skal land bygges'",15)
r=r+rtest("delword('Med lov skal land bygges', 10)",,
"\== 'Med lov skal land bygges'",16)
r=r+rtest("delword('Med lov skal land bygges', 9,9)",,
"\== 'Med lov skal land bygges'", 17)
r=r+rtest("delword('Med lov skal land bygges', 1,0)",,
"\== 'Med lov skal land bygges'",18)
say 'Done delword.rexx'
exit r
