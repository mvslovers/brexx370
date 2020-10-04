say '----------------------------------------'
say 'File countst.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("countstr('bc','abcabcabc')","\= 3",1)
r=r+rtest("countstr('aa','aaaa')","\= 2",2)
r=r+rtest("countstr('','a a')","\= 0",3)
r=r+rtest("countstr('','def')","\== 0",4)
/* From: Mark Hessling */
r=r+rtest("countstr('','')","\== 0",5)
r=r+rtest("countstr('a','abcdef')","\== 1",6)
r=r+rtest("countstr(0,0)","\== 1",7)
r=r+rtest("countstr('a','def')","\== 0",8)
r=r+rtest("countstr('a','')","\== 0",9)
r=r+rtest("countstr('abc','abcdef')","\== 1",10)
r=r+rtest("countstr('abcdefg','abcdef')","\== 0",11)
r=r+rtest("countstr('abc','abcdefabccdabcd')","\== 3",12)
say 'Done countst.rexx'
exit r
