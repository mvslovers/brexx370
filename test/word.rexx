say '----------------------------------------'
say 'File word.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("word('Now is the time',3)","\== 'the'",1)
r=r+rtest("word('Now is the time',5)","\== ''",2)
/* From: Mark Hessling */
r=r+rtest("word('This is certainly a test',1)","\== 'This'",3)
r=r+rtest("word(' This is certainly a test',1)","\== 'This'",4)
r=r+rtest("word('This is certainly a test',1)","\== 'This'",5)
r=r+rtest("word('This is certainly a test',2)","\== 'is'",6)
r=r+rtest("word('This is certainly a test',2)","\== 'is'",7)
r=r+rtest("word('This is certainly a test',5)","\== 'test'",8)
r=r+rtest("word('This is certainly a test ',5)","\== 'test'",9)
r=r+rtest("word('This is certainly a test',6)","\== ''",10)
r=r+rtest("word('',1)","\== ''",11)
r=r+rtest("word('',10)","\== ''",12)
r=r+rtest("word('test ',2)","\== ''",13)
say 'Done word.rexx'
exit r
