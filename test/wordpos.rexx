say '----------------------------------------'
say 'File wordpos.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("wordpos('the','Now is the time')","\= 3",1)
r=r+rtest("wordpos('The','Now is the time')","\= 0",2)
r=r+rtest("wordpos('is the','Now is the time')","\= 2",3)
r=r+rtest("wordpos('is the','Now is the time')","\= 2",4)
r=r+rtest("wordpos('be','To be or not to be')","\= 2",5)
r=r+rtest("wordpos('be','To be or not to be',3)","\= 6",6)
/* From: Mark Hessling */
r=r+rtest("wordpos('This','This is a small test')","\== 1",7)
r=r+rtest("wordpos('test','This is a small test')","\== 5",8)
r=r+rtest("wordpos('foo','This is a small test')","\== 0",9)
r=r+rtest("wordpos(' This ','This is a small test')","\== 1",10)
r=r+rtest("wordpos('This',' This is a small test')","\== 1",11)
r=r+rtest("wordpos('This','This is a small test')","\== 1",12)
r=r+rtest("wordpos('This','this is a small This')","\== 5",13)
r=r+rtest("wordpos('This','This is a small This')","\== 1",14)
r=r+rtest("wordpos('This','This is a small This', 2)","\== 5",15)
r=r+rtest("wordpos('is a ','This is a small test')","\== 2",16)
r=r+rtest("wordpos('is a ','This is a small test')","\== 2",17)
r=r+rtest("wordpos(' is a ','This is a small test')","\== 2",18)
r=r+rtest("wordpos('is a ','This is a small test', 2)","\== 2",19)
r=r+rtest("wordpos('is a ','This is a small test',3)","\== 0",20)
r=r+rtest("wordpos('is a ','This is a small test',4)","\== 0",21)
r=r+rtest("wordpos('test ','This is a small test')","\== 5",22)
r=r+rtest("wordpos('test ','This is a small test',5)","\== 5",23)
r=r+rtest("wordpos('test ','This is a small test',6)","\== 0",24)
r=r+rtest("wordpos('test ','This is a small test ')","\== 5",25)
r=r+rtest("wordpos(' test','This is a small test ',6)","\== 0",26)
r=r+rtest("wordpos('test ','This is a small test ',5)","\== 5",27)
r=r+rtest("wordpos(' ','This is a small test')","\== 0",28)
r=r+rtest("wordpos(' ','This is a small test',3)","\== 0",29)
r=r+rtest("wordpos('','This is a small test',4)","\== 0",30)
r=r+rtest("wordpos('test ','')","\== 0",31)
r=r+rtest("wordpos('','')","\== 0",32)
r=r+rtest("wordpos('',' ')","\== 0",33)
r=r+rtest("wordpos(' ','')","\== 0",34)
r=r+rtest("wordpos(' ','', 3)","\== 0",35)
r=r+rtest("wordpos(' a ','')","\== 0",36)
r=r+rtest("wordpos(' a ','a')","\== 1",37)
say 'Done wordpos.rexx'
exit r
