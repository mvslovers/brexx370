say '----------------------------------------'
say 'File symbol.rexx'
r=0

/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
drop A.3; j=3
r=r+rtest("symbol('J')","\== 'VAR'",1)
r=r+rtest("symbol(J)","\== 'LIT'",2)
r=r+rtest("symbol('a.j')","\== 'LIT'",3)
r=r+rtest("symbol(2)","\== 'LIT'",4)
r=r+rtest("symbol('*')","\== 'BAD'",5)
/* From: Mark Hessling */
parse value 'foobar' with alpha 1 beta 1 omega 1 gamma.foobar
omega = 'FOOBAR'
r=r+rtest("symbol('HEPP')","\== 'LIT'",6)
r=r+rtest("symbol('ALPHA')","\== 'VAR'",7)
r=r+rtest("symbol('Un*x')","\== 'BAD'",8)
r=r+rtest("symbol('gamma.delta')","\== 'LIT'",9)
r=r+rtest("symbol('gamma.FOOBAR')","\== 'VAR'",10)
r=r+rtest("symbol('gamma.alpha')","\== 'LIT'",11)
r=r+rtest("symbol('gamma.omega')","\== 'VAR'",12)
r=r+rtest("symbol('Un*x.gamma')","\== 'BAD'",13)
r=r+rtest("symbol('!!')","\== 'LIT'",14)
r=r+rtest("symbol('')","\== 'BAD'",15)
r=r+rtest("symbol('00'x)","\== 'BAD'",16)
r=r+rtest("symbol('foo-bar')","\== 'BAD'",17)
say 'Done symbol.rexx'
exit r