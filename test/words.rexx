say '----------------------------------------'
say 'File words.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("words('Now is the time')","\= 4",1)
r=r+rtest("words(' ')","\= 0",2)
/* From: Mark Hessling */
r=r+rtest("words('This is certainly a test')","\== 5",3)
r=r+rtest("words(' This is certainly a test')","\== 5",4)
r=r+rtest("words('This is certainly a test')","\== 5",5)
r=r+rtest("words('This is certainly a test ')","\== 5",6)
r=r+rtest("words(' hepp ')","\== 1",7)
r=r+rtest("words(' hepp hepp ')","\== 2",8)
r=r+rtest("words('')","\== 0",9)
r=r+rtest("words(' ')","\== 0",10)
say 'Done words.rexx'
exit r
