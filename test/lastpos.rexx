say '----------------------------------------'
say 'File lastpos.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("lastpos(' ','abc def ghi')","\= 8",1)
r=r+rtest("lastpos(' ','abcdefghi')","\= 0",2)
r=r+rtest("lastpos(' ','abc def ghi',7)","\= 4",3)
/* From: Mark Hessling */
r=r+rtest("lastpos('b', 'abc abc')","\== 6",4)
r=r+rtest("lastpos('b', 'abc abc',5)","\== 2",5)
r=r+rtest("lastpos('b', 'abc abc',6)","\== 6",6)
r=r+rtest("lastpos('b', 'abc abc',7)","\== 6",7)
r=r+rtest("lastpos('x', 'abc abc')","\== 0",8)
r=r+rtest("lastpos('b', 'abc abc',20)","\== 6",9)
r=r+rtest("lastpos('b', '')","\== 0",10)
r=r+rtest("lastpos('', 'c')","\== 0",11)
r=r+rtest("lastpos('', '')","\== 0",12)
r=r+rtest("lastpos('b', 'abc abc',20)","\== 6",13)
r=r+rtest("lastpos('bc', 'abc abc')","\== 6",14)
r=r+rtest("lastpos('bc ', 'abc abc',20)","\== 2",15)
r=r+rtest("lastpos('abc', 'abc abc',6)","\== 1",16)
r=r+rtest("lastpos('abc', 'abc abc')","\== 5",17)
r=r+rtest("lastpos('abc', 'abc abc',7)","\== 5",18)
r=r+rtest("pos('abc','abcdefabccdabcd',4)","\== 7",19)
say 'Done lastpos.rexx'
exit r
