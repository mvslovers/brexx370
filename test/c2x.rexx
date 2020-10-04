say '----------------------------------------'
say 'File c2x.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("c2x('72s')","\== 'F7F2A2'",1)
r=r+rtest("c2x('0123'x)","\== '0123'",2)
/* From: Mark Hessling */
r=r+rtest("c2x( 'foobar')","\== '869696828199'",3)
r=r+rtest("c2x( '' )","\== ''",4)
r=r+rtest("c2x( '101'x )","\== '0101'",5)
r=r+rtest("c2x( '0123456789abcdef'x )","\== '0123456789ABCDEF'",6)
r=r+rtest("c2x( 'ffff'x )","\== 'FFFF'",7)
r=r+rtest("c2x( 'ffffffff'x )","\== 'FFFFFFFF'",8)
say 'Done c2x.rexx'
exit r
