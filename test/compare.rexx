say '----------------------------------------'
say 'File compare.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("compare('abc','abc')","\= 0",1)
r=r+rtest("compare('abc','ak')","\= 2",2)
r=r+rtest("compare('ab ','ab')","\= 0",3)
r=r+rtest("compare('ab ','ab',' ')","\= 0",4)
r=r+rtest("compare('ab ','ab','x')","\= 3",5)
r=r+rtest("compare('ab-- ','ab','-')","\= 5",6)
/* From: Mark Hessling */
r=r+rtest("compare('foo', 'bar')","\== 1",7)
r=r+rtest("compare('foo', 'foo')","\== 0",8)
r=r+rtest("compare(' ', '' )","\== 0",9)
r=r+rtest("compare('foo', 'f', 'o')","\== 0",10)
r=r+rtest("compare('foobar', 'foobag')","\== 6",11)
say 'Done compare.rexx'
exit r
