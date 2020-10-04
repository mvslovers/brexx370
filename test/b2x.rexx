say '----------------------------------------'
say 'File b2x.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("b2x('11000011')","\== 'C3'",1)
r=r+rtest("b2x('10111')","\== '17'",2)
r=r+rtest("b2x('101')","\== '5'",3)
r=r+rtest("b2x('1 1111 0000')","\== '1F0'",4)
r=r+rtest("x2d(b2x('10111'))","\== '23'",5)
/* From: Mark Hessling */
r=r+rtest("b2x('')","\== ''",6)
r=r+rtest("b2x('0')","\== '0'",7)
r=r+rtest("b2x('1')","\== '1'",8)
r=r+rtest("b2x('10')","\== '2'",9)
r=r+rtest("b2x('010')","\== '2'",10)
r=r+rtest("b2x('1010')","\== 'A'",11)
r=r+rtest("b2x('1 0101')","\== '15'",12)
r=r+rtest("b2x('1 01010101')","\== '155'",13)
r=r+rtest("b2x('1 0101 0101')","\== '155'",14)
r=r+rtest("b2x('10101 0101')","\== '155'",15)
r=r+rtest("b2x('0000 00000000 0000')","\== '0000'",16)
r=r+rtest("b2x('11111111 11111111')","\== 'FFFF'",17)
say 'Done b2x.rexx'
exit r
