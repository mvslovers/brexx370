say '----------------------------------------'
say 'File x2b.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("x2b('C3')","\== '11000011'",1)
r=r+rtest("x2b('7')","\== '0111'",2)
r=r+rtest("x2b('1 C1')","\== '000111000001'",3)
r=r+rtest("x2b(c2x('C3'x))","\== '11000011'",4)
r=r+rtest("x2b(d2x('129'))","\== '10000001'",5)
r=r+rtest("x2b(d2x('12'))","\== '1100'",6)
/* From: Mark Hessling */
r=r+rtest("x2b('416263')","\== '010000010110001001100011'",7)
r=r+rtest("x2b('DeadBeef')","\== '11011110101011011011111011101111'",8)
r=r+rtest("x2b('1 02 03')","\== '00010000001000000011'",9)
r=r+rtest("x2b('102 03')","\== '00010000001000000011'",10)
r=r+rtest("x2b('102')","\== '000100000010'",11)
r=r+rtest("x2b('11 2F')","\== '0001000100101111'",12)
r=r+rtest("x2b('')","\== ''",13)
say 'Done x2b.rexx'
exit r
