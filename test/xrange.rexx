say '----------------------------------------'
say 'File xrange.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("xrange('a','f')","\== 'abcdef'",1)
r=r+rtest("xrange('03'x,'07'x)","\== '0304050607'x",2)
r=r+rtest("xrange('FE'x,'02'x)","\== 'FEFF000102'x",3)
/* From: Mark Hessling */
r=r+rtest("xrange('7d'x,'83'x)","\== '7d7e7f80818283'x",4)
r=r+rtest("xrange('a','a')","\== 'a'",5)
say 'Done xrange.rexx'
exit r
