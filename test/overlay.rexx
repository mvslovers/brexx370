say '----------------------------------------'
say 'File overlay.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("overlay('.','abcdef',3,2)","\== 'ab. ef'",1)
r=r+rtest("overlay(' ','abcdef',3)","\== 'ab def'",2)
r=r+rtest("overlay('.','abcdef',3,2)","\== 'ab. ef'",3)
r=r+rtest("overlay('qq','abcd')","\== 'qqcd'",4)
r=r+rtest("overlay('qq','abcd',4)","\== 'abcqq'",5)
r=r+rtest("overlay('123','abc',5,6,'+')","\== 'abc+123+++'",6)
/* From: Mark Hessling */
r=r+rtest("overlay('foo', 'abcdefghi',3,4,'*')","\== 'abfoo*ghi'",7)
r=r+rtest("overlay('foo', 'abcdefghi',3,2,'*')","\== 'abfoefghi'",8)
r=r+rtest("overlay('foo', 'abcdefghi',3,4,)","\== 'abfoo ghi'",9)
r=r+rtest("overlay('foo', 'abcdefghi',3)","\== 'abfoofghi'",10)
r=r+rtest("overlay('foo', 'abcdefghi',,4,'*')","\== 'foo*efghi'",11)
r=r+rtest("overlay('foo', 'abcdefghi',9,4,'*')","\== 'abcdefghfoo*'",12)
r=r+rtest("overlay('foo', 'abcdefghi',10,4,'*')","\== 'abcdefghifoo*'",13)
r=r+rtest("overlay('foo', 'abcdefghi',11,4,'*')","\== 'abcdefghi*foo*'",14)
r=r+rtest("overlay('', 'abcdefghi',3)","\== 'abcdefghi'",15)
r=r+rtest("overlay('foo', '',3)","\== '  foo'",16)
r=r+rtest("overlay('', '',3,4,'*')","\== '******'",17)
r=r+rtest("overlay('', '')","\== ''",18)
say 'Done overlay.rexx'
exit r
