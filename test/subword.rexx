say '----------------------------------------'
say 'File subword.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("subword('Now is the time',2,2)","\== 'is the'",1)
r=r+rtest("subword('Now is the time',3)","\== 'the time'",2)
r=r+rtest("subword('Now is the time',5)","\== ''",3)
/* From: Mark Hessling */
r=r+rtest("subword(' to be or not to be ',5)","\== 'to be'",4)
r=r+rtest("subword(' to be or not to be ',6)","\== 'be'",5)
r=r+rtest("subword(' to be or not to be ',7)","\== ''",6)
r=r+rtest("subword(' to be or not to be ',8,7)","\== ''",7)
r=r+rtest("subword(' to be or not to be ',3,2)","\== 'or not'",8)
r=r+rtest("subword(' to be or not to be ',1,2)","\== 'to be'",9)
r=r+rtest("subword(' to be or not to be ',4,2)","\== 'not to'",10)
r=r+rtest("subword('abc de f', 3)","\== 'f'",11)
say 'Done subword.rexx'
exit r
