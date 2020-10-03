say '----------------------------------------'
say 'File x2c.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("x2c('F')","\== '0F'x",1)
/* From: Mark Hessling */
r=r+rtest("x2c('C18283')","\== 'Abc'",2)
r=r+rtest("x2c('DeadBeef')","\== 'deadbeef'x",3)
r=r+rtest("x2c('1 02 03')","\== '010203'x",4)
r=r+rtest("x2c('11 0222 3333 044444')","\== '1102223333044444'x",5)
r=r+rtest("x2c('')","\== ''",6)
r=r+rtest("x2c('2')","\== '02'x",7)
r=r+rtest("x2c('1 02 03')","\== '010203'x",8)
say 'Done x2c.rexx'
exit r
