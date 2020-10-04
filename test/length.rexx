say '----------------------------------------'
say 'File length.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("length('abcdefgh')","\= 8",1)
r=r+rtest("length('')","\= 0",2)
/* From: Mark Hessling */
r=r+rtest("length('')","\== 0",3)
r=r+rtest("length('a')","\== 1",4)
r=r+rtest("length('abc')","\== 3",5)
r=r+rtest("length('abcdefghij')","\== 10",6)
say 'Done length.rexx'
exit r
