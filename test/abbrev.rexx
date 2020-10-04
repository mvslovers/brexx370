say '----------------------------------------'
say 'File abbrev.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("abbrev('Print','Pri')","\== 1",1)
r=r+rtest("abbrev('PRINT','Pri')","== 1",2)
r=r+rtest("abbrev('PRINT','PRI',4)","== 1",3)
r=r+rtest("abbrev('PRINT','PRY')","== 1",4)
r=r+rtest("abbrev('PRINT','')","\== 1",5)
r=r+rtest("abbrev('PRINT','',1)","== 1",6)
/* From: Mark Hessling */
r=r+rtest("abbrev('information','info',4)","\== 1",7)
r=r+rtest("abbrev('information','',0)","\== 1",8)
r=r+rtest("abbrev('information','Info',4)","== 1",9)
r=r+rtest("abbrev('information','info',5)","== 1",10)
r=r+rtest("abbrev('information','info ')","== 1",11)
r=r+rtest("abbrev('information','info',3)","\== 1",12)
r=r+rtest("abbrev('info','information',3)","== 1",13)
r=r+rtest("abbrev('info','info',5)","== 1",14)
say 'Done abbrev.rexx'
exit r
