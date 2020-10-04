say '----------------------------------------'
say 'File transla.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("translate('abcdef')","\== 'ABCDEF'",1)
r=r+rtest("translate('abbc','&','b')","\== 'a&&c'",2)
r=r+rtest("translate('abcdef','12','ec')","\== 'ab2d1f'",3)
r=r+rtest("translate('abcdef','12','abcd','.')","\== '12..ef'",4)
r=r+rtest("translate('4123','abcd','1234')","\== 'dabc'",5)
/* From: Mark Hessling */
r=r+rtest("translate('Foo Bar')","\== 'FOO BAR'",6)
r=r+rtest("translate('Foo Bar',,'')","\== 'Foo Bar'",7)
r=r+rtest("translate('Foo Bar','',)","\== '       '",8)
r=r+rtest("translate('Foo Bar','',,'*')","\== '*******'",9)
r=r+rtest("translate('','klasjdf','woieruw')","\== ''",10)
r=r+rtest("translate('foobar','abcdef','fedcba')","\== 'aooefr'",11)
say 'Done transla.rexx'
exit r
