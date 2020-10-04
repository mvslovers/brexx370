say '----------------------------------------'
say 'File space.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("space('abc def ')","\== 'abc def'",1)
r=r+rtest("space(' abc def',3)","\== 'abc   def'",2)
r=r+rtest("space('abc def ',1)","\== 'abc def'",3)
r=r+rtest("space('abc def ',0)","\== 'abcdef'",4)
r=r+rtest("space('abc def ',2,'+')","\== 'abc++def'",5)
/* From: Mark Hessling */
r=r+rtest("space(' foo ')","\== 'foo'",6)
r=r+rtest("space(' foo')","\== 'foo'",7)
r=r+rtest("space('foo ')","\== 'foo'",8)
r=r+rtest("space(' foo ')","\== 'foo'",9)
r=r+rtest("space(' foo bar ')","\== 'foo bar'",10)
r=r+rtest("space(' foo bar ')","\== 'foo bar'",11)
r=r+rtest("space(' foo bar ' , 2)","\== 'foo  bar'",12)
r=r+rtest("space(' foo bar ',,'-')","\== 'foo-bar'",13)
r=r+rtest("space(' foo bar ',2,'-')","\== 'foo--bar'",14)
r=r+rtest("space(' f-- b-- ',2,'-')","\== 'f----b--'",15)
r=r+rtest("space(' f o o b a r ',0)","\== 'foobar'",16)
say 'Done space.rexx'
exit r
