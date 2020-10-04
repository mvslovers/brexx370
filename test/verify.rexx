say '----------------------------------------'
say 'File verify.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("verify('123','1234567890')","\= 0",1)
r=r+rtest("verify('1Z3','1234567890')","\= 2",2)
r=r+rtest("verify('AB4T','1234567890','M')","\= 3",3)
r=r+rtest("verify('1P3Q4','1234567890',,3)","\= 4",4)
r=r+rtest("verify('ABCDE','',,3)","\= 3",5)
r=r+rtest("verify('AB3CD5','1234567890','M',4)","\= 6",6)
/* From: Mark Hessling */
r=r+rtest("verify('foobar', 'barfo', N, 1)","\== 0",7)
r=r+rtest("verify('foobar', 'barfo', M, 1)","\== 1",8)
r=r+rtest("verify('', 'barfo')","\== 0",9)
r=r+rtest("verify('foobar', '')","\== 1",10)
r=r+rtest("verify('foobar', 'barf', N, 3)","\== 3",11)
r=r+rtest("verify('foobar', 'barf', N, 4)","\== 0",12)
r=r+rtest("verify('', '')","\== 0",13)
say 'Done verify.rexx'
exit r
