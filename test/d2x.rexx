say '----------------------------------------'
say 'File d2x.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("d2x(9)","\== '9'",1)
r=r+rtest("d2x(129)","\== '81'",2)
r=r+rtest("d2x(129,1)","\== '1'",3)
r=r+rtest("d2x(129,2)","\== '81'",4)
r=r+rtest("d2x(129,4)","\== '0081'",5)
r=r+rtest("d2x(257,2)","\== '01'",6)
r=r+rtest("d2x(-127,2)","\== '81'",7)
r=r+rtest("d2x(-127,4)","\== 'FF81'",8)
r=r+rtest("d2x(12,0)","\== ''",9)
/* From: Mark Hessling */
r=r+rtest("d2x(0)","\== '0'",10)
r=r+rtest("d2x(127)","\== '7F'",11)
r=r+rtest("d2x(128)","\== '80'",12)
r=r+rtest("d2x(129)","\== '81'",13)
r=r+rtest("d2x(1)","\== '1'",14)
r=r+rtest("d2x(-1,2)","\== 'FF'",15)
r=r+rtest("d2x(-127,2)","\== '81'",16)
r=r+rtest("d2x(-128,2)","\== '80'",17)
r=r+rtest("d2x(-129,2)","\== '7F'",18)
r=r+rtest("d2x(-1,3)","\== 'FFF'",19)
r=r+rtest("d2x(-127,3)","\== 'F81'",20)
r=r+rtest("d2x(-128,4)","\== 'FF80'",21)
r=r+rtest("d2x(-129,5)","\== 'FFF7F'",22)
r=r+rtest("d2x(129,0)","\== ''",23)
r=r+rtest("d2x(129,2)","\== '81'",24)
r=r+rtest("d2x(256+129,4)","\== '0181'",25)
r=r+rtest("d2x(256*256+256+129,6)","\== '010181'",26)
say 'Done d2x.rexx'
exit r
