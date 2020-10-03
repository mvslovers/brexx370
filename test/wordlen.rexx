say '----------------------------------------'
say 'File wordlen.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("wordlength('Now is the time',2)","\=2",1)
r=r+rtest("wordlength('Now comes the time',2)","\=5",2)
r=r+rtest("wordlength('Now is the time',6)","\=0",3)
/* From: Mark Hessling */
r=r+rtest("wordlength('This is certainly a test',1)","\== '4'",4)
r=r+rtest("wordlength('This is certainly a test',2)","\== '2'",5)
r=r+rtest("wordlength('This is certainly a test',5)","\== '4'",6)
r=r+rtest("wordlength('This is certainly a test ',5)","\== '4'",7)
r=r+rtest("wordlength('This is certainly a test',6)","\== '0'",8)
r=r+rtest("wordlength('',1)","\== '0'",9)
r=r+rtest("wordlength('',10)","\== '0'",10)
say 'Done wordlen.rexx'
exit r
