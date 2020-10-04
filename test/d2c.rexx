say '----------------------------------------'
say 'File d2c.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("d2c(9)","\== '09'x",1)
r=r+rtest("d2c(129)","\== '81'x",2)
r=r+rtest("d2c(129,1)","\== '81'x",3)
r=r+rtest("d2c(129,2)","\== '0081'x",4)
r=r+rtest("d2c(257,1)","\== '01'x",5)
r=r+rtest("d2c(-127,1)","\== '81'x",6)
r=r+rtest("d2c(-127,2)","\== 'FF81'x",7)
r=r+rtest("d2c(-1,4)","\== 'FFFFFFFF'x",8)
r=r+rtest("d2c(12,0)","\== ''",9)
/* From: Mark Hessling */
r=r+rtest("d2c(127)","\== '7f'x",10)
r=r+rtest("d2c(128)","\== '80'x",11)
r=r+rtest("d2c(129)","\== '81'x",12)
r=r+rtest("d2c(1)","\== '01'x",13)
r=r+rtest("d2c(-1,1)","\== 'FF'x",14)
r=r+rtest("d2c(-127,1)","\== '81'x",15)
r=r+rtest("d2c(-128,1)","\== '80'x",16)
r=r+rtest("d2c(-129,1)","\== '7F'x",17)
r=r+rtest("d2c(-1,2)","\== 'FFFF'x",18)
r=r+rtest("d2c(-127,2)","\== 'FF81'x",19)
r=r+rtest("d2c(-128,2)","\== 'FF80'x",20)
r=r+rtest("d2c(-129,2)","\== 'FF7F'x",21)
r=r+rtest("d2c(129,0)","\== ''",22)
r=r+rtest("d2c(129,1)","\== '81'x",23)
r=r+rtest("d2c(256+129,2)","\== '0181'x",24)
r=r+rtest("d2c(256*256+256+129,3)","\== '010181'x",25)
say 'Done d2c.rexx'
exit r
