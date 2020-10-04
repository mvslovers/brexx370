say '----------------------------------------'
say 'File insert.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("insert(' ','abcdef',3)","\== 'abc def'",1)
r=r+rtest("insert('123','abc',5,6)","\== 'abc  123   '",2)
r=r+rtest("insert('123','abc',5,6,'+')","\== 'abc++123+++'",3)
r=r+rtest("insert('123','abc')","\== '123abc'",4)
r=r+rtest("insert('123','abc',,5,'-')","\== '123--abc'",5)
/* From: Mark Hessling */
r=r+rtest("insert('abc','def')","\== 'abcdef'",6)
r=r+rtest("insert('abc','def',2)","\== 'deabcf'",7)
r=r+rtest("insert('abc','def',3)","\== 'defabc'",8)
r=r+rtest("insert('abc','def',5)","\== 'def  abc'",9)
r=r+rtest("insert('abc','def',5,,'*')","\== 'def**abc'",10)
r=r+rtest("insert('abc' ,'def',5,4,'*')","\== 'def**abc*'",11)
r=r+rtest("insert('abc','def',,0)","\== 'def'",12)
r=r+rtest("insert('abc','def',2,1)","\== 'deaf'",13)
say 'Done insert.rexx'
exit r
