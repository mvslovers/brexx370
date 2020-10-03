say '----------------------------------------'
say 'File bitand.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("bitand('73'x,'27'x)","\== '23'x",1)
r=r+rtest("bitand('13'x,'5555'x)","\== '1155'x",2)
r=r+rtest("bitand('13'x,'5555'x,'74'x)","\== '1154'x",3)
/* From: Mark Hessling */
r=r+rtest("bitand( '123456'x, '3456'x )","\== '101456'x",4)
r=r+rtest("bitand( '3456'x, '123456'x, '99'x )","\== '101410'x",5)
r=r+rtest("bitand( '123456'x,, '55'x)","\== '101454'x",6)
r=r+rtest("bitand( 'foobar' )","\== 'foobar'",7)
say 'Done bitand.rexx'
exit r
