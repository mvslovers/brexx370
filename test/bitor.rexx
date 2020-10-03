say '----------------------------------------'
say 'File bitor.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("bitor('15'x,'24'x)","\= '35'x",1)
r=r+rtest("bitor('15'x,'2456'x)","\= '3556'x",2)
r=r+rtest("bitor('15'x,'2456'x,'F0'x)","\= '35F6'x",3)
r=r+rtest("bitor('1111'x,,'4D'x)","\= '5D5d'x",4)
/* From: Mark Hessling */
r=r+rtest("bitor( '123456'x, '3456'x )","\== '367656'x",5)
r=r+rtest("bitor( '3456'x, '123456'x, '99'x )","\== '3676df'x",6)
r=r+rtest("bitor( '123456'x,, '55'x)","\== '577557'x",7)
r=r+rtest("bitor( 'foobar' )","\== 'foobar'",8)
say 'Done bitor.rexx'
exit r
