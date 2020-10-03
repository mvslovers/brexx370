say '----------------------------------------'
say 'File substr.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("substr('abc',2)","\== 'bc'",1)
r=r+rtest("substr('abc',2,4)","\== 'bc  '",2)
r=r+rtest("substr('abc',2,6,'.')","\== 'bc....'",3)
/* From: Mark Hessling */
r=r+rtest("substr('foobar',2,3)","\== 'oob'",4)
r=r+rtest("substr('foobar',3)","\== 'obar'",5)
r=r+rtest("substr('foobar',3,6)","\== 'obar  '",6)
r=r+rtest("substr('foobar',3,6,'*')","\== 'obar**'",7)
r=r+rtest("substr('foobar',6,3)","\== 'r  '",8)
r=r+rtest("substr('foobar',8,3)","\== '   '",9)
say 'Done substr.rexx'
exit r
