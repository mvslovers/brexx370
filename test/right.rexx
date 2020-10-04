say '----------------------------------------'
say 'File right.rexx'
r=0
r=r+rtest("right('abc d',8)","\== '   abc d'",1)
r=r+rtest("right('abc def',5)","\== 'c def'",2)
r=r+rtest("right('12',5,'0')","\== '00012'",3)
/* From: Mark Hessling */
r=r+rtest("right('',4)","\== '    '",4)
r=r+rtest("right('foobar',0)","\== ''",5)
r=r+rtest("right('foobar',3)","\== 'bar'",6)
r=r+rtest("right('foobar',6)","\== 'foobar'",7)
r=r+rtest("right('foobar',8)","\== '  foobar'",8)
r=r+rtest("right('foobar',8,'*')","\== '**foobar'",9)
r=r+rtest("right('foobar',4,'*')","\== 'obar'",10)
say 'Done right.rexx'
exit r
