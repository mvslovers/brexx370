say '----------------------------------------'
say 'File strip.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("strip(' ab c ')","\== 'ab c'",1)
r=r+rtest("strip(' ab c ','L')","\== 'ab c '",2)
r=r+rtest("strip(' ab c ','t')","\== ' ab c'",3)
r=r+rtest("strip('12.7000',,0)","\== '12.7'",4)
r=r+rtest("strip('0012.7000',,0)","\== '12.7'",5)
/* From: Mark Hessling */
r=r+rtest("strip(' foo bar ')","\== 'foo bar'",6)
r=r+rtest("strip(' foo bar ','L')","\== 'foo bar '",7)
r=r+rtest("strip(' foo bar ','T')","\== ' foo bar'",8)
r=r+rtest("strip(' foo bar ','B')","\== 'foo bar'",9)
r=r+rtest("strip(' foo bar ','B','*')","\== ' foo bar '",10)
r=r+rtest("strip(' foo bar',,'r')","\== ' foo ba'",11)
say 'Done strip.rexx'
exit r
