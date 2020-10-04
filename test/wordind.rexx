say '----------------------------------------'
say 'File wordind.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("wordindex('Now is the time',3)","\=8",1)
r=r+rtest("wordindex('Now is the time',6)","\=0",2)
/* From: Mark Hessling */
r=r+rtest("wordindex('This is certainly a test',1)","\==  '1' ",3)
r=r+rtest("wordindex('  This is certainly a test',1)","\==  '3' ",4)
r=r+rtest("wordindex('This   is certainly a test',1)","\==  '1' ",5)
r=r+rtest("wordindex('  This   is certainly a test',1)","\==  '3' ",6)
r=r+rtest("wordindex('This is certainly a test',2)","\==  '6' ",7)
r=r+rtest("wordindex('This   is certainly a test',2)","\==  '8' ",8)
r=r+rtest("wordindex('This is   certainly a test',2)","\==  '6' ",9)
r=r+rtest("wordindex('This   is   certainly a test',2)","\==  '8' ",10)
r=r+rtest("wordindex('This is certainly a test',5)","\==  '21'  ",11)
r=r+rtest("wordindex('This is certainly a   test',5)","\==  '23' ",12)
r=r+rtest("wordindex('This is certainly a test  ',5)","\==  '21' ",13)
r=r+rtest("wordindex('This is certainly a test  ',6)","\==  '0'  ",14)
r=r+rtest("wordindex('This is certainly a test',6)","\==  '0'    ",15)
r=r+rtest("wordindex('This is certainly a test',7)","\==  '0'    ",16)
r=r+rtest("wordindex('This is certainly a test  ',7)","\==  '0'   ",17)
say 'Done wordind.rexx'
exit r
