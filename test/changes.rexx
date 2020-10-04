say '----------------------------------------'
say 'File changes.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("changestr('bc','abcabcabc','xy')","\== 'axyaxyaxy'",1)
r=r+rtest("changestr('bc','abcabcabc','')","\== 'aaa'",2)
r=r+rtest("changestr('','abcabcabc','xy')","\== 'abcabcabc'",3)
/* From: Mark Hessling */
r=r+rtest("changestr('a','fred','c')","\== 'fred'",4)
r=r+rtest("changestr('','','x')","\== ''",5)
r=r+rtest("changestr('a','abcdef','x')","\== 'xbcdef'",6)
r=r+rtest("changestr('0','0','1')","\== '1'",7)
r=r+rtest("changestr('a','def','xyz')","\== 'def'",8)
r=r+rtest("changestr('a','','x')","\== ''",9)
r=r+rtest("changestr('','def','xyz')","\== 'def'",10)
r=r+rtest("changestr('abc','abcdef','xyz')","\== 'xyzdef'",11)
r=r+rtest("changestr('abcdefg','abcdef','xyz')","\== 'abcdef'",12)
r=r+rtest("changestr('abc','abcdefabccdabcd','z')","\== 'zdefzcdzd'",13)
say 'Done changes.rexx'
exit r
