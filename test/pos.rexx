say '----------------------------------------'
say 'File pos.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("pos('day','Saturday')","\= 6",1)
r=r+rtest("pos('x','abc def ghi')","\= 0",2)
r=r+rtest("pos(' ','abc def ghi')","\= 4",3)
r=r+rtest("pos(' ','abc def ghi',5)","\= 8",4)
/* From: Mark Hessling */
r=r+rtest("pos('foo','a foo foo b')","\== 3",5)
r=r+rtest("pos('foo','a foo foo',3)","\== 3",6)
r=r+rtest("pos('foo','a foo foo',4)","\== 7",7)
r=r+rtest("pos('foo','a foo foo b',30)","\== 0",8)
r=r+rtest("pos('foo','a foo foo b',1)","\== 3",9)
r=r+rtest("pos('','a foo foo b')","\== 0",10)
r=r+rtest("pos('foo','')","\== 0",11)
r=r+rtest("pos('','')","\== 0",12)
r=r+rtest("pos('b' , 'a')","\== 0",13)
r=r+rtest("pos('b','b')","\== 1",14)
r=r+rtest("pos('b','abc')","\== 2",15)
r=r+rtest("pos('b','def')","\== 0",16)
r=r+rtest("pos('foo','foo foo b')","\== 1",17)
say 'Done pos.rexx'
exit r
