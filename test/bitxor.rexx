say '----------------------------------------'
say 'File bitxor.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("bitxor('12'x,'22'x)","\== '30'x",1)
r=r+rtest("bitxor('1211'x,'22'x)","\== '3011'x",2)
r=r+rtest("bitxor('C711'x,'222222'x,' ')","\== 'E53362'x",3)
r=r+rtest("bitxor('1111'x,'444444'x,'40'x)","\== '555504'x",4)
r=r+rtest("bitxor('1111'x,,'4D'x)","\== '5C5C'x",5)
/* From: Mark Hessling */
r=r+rtest("bitxor( '123456'x, '3456'x )","\== '266256'x",6)
r=r+rtest("bitxor( '3456'x, '123456'x, '99'x )","\== '2662cf'x",7)
r=r+rtest("bitxor( '123456'x,, '55'x)","\== '476103'x",8)
r=r+rtest("bitxor( 'foobar' )","\== 'foobar'",9)
say 'Done bitxor.rexx'
exit r
