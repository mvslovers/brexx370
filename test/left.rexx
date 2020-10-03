say '----------------------------------------'
say 'File left.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("left('abc d',8)","\== 'abc d   '",1)
r=r+rtest("left('abc d',8,'.')","\== 'abc d...'",2)
r=r+rtest("left('abc  def',7)","\== 'abc  de'",3)
/* From: Mark Hessling */
r=r+rtest("left('foobar',1)","\== 'f'",4)
r=r+rtest("left('foobar',0)","\== ''",5)
r=r+rtest("left('foobar',6)","\== 'foobar'",6)
r=r+rtest("left('foobar',8)","\==      'foobar  '",7)
r=r+rtest("left('foobar',8,'*')","\== 'foobar**'",8)
r=r+rtest("left('foobar',1,'*')","\== 'f'",9)
say 'Done left.rexx'
exit r
