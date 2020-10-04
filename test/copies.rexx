say '----------------------------------------'
say 'File copies.rexx'
r=0
r=r+rtest("copies('abc',3)","\== 'abcabcabc'",1)
r=r+rtest("copies('abc',0)","\== ''",2)
/* From: Mark Hessling */
r=r+rtest("copies('foo',3)","\== 'foofoofoo'",3)
r=r+rtest("copies('x', 10)","\== 'xxxxxxxxxx'",4)
r=r+rtest("copies('', 50)","\== ''",5)
r=r+rtest("copies('', 0)","\== ''",6)
r=r+rtest("copies('foobar',0 )","\== ''",7)
say 'Done copies.rexx'
exit r
