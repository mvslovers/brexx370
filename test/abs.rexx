say '----------------------------------------'
say 'File abs.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("abs('12.3')","\= 12.3",1)
r=r+rtest("abs(' -0.307')","\= 0.307",2)
/* From: Mark Hessling */
r=r+rtest("abs(-12.345)","\== 12.345",3)
r=r+rtest("abs(12.345)","\== 12.345",4)
r=r+rtest("abs(-0.0)","\== 0",5)
r=r+rtest("abs(0.0)","\== 0",6)
say 'Done abs.rexx'
exit r
