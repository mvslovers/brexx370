say '----------------------------------------'
say 'File c2d.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("c2d('09'x)","\== 9",1)
r=r+rtest("c2d('81'x)","\== 129",2)
r=r+rtest("c2d('a'x)","\== 10",3)
r=r+rtest("c2d('FF81'x)","\== 65409",4)
r=r+rtest("c2d('')","\== 0",5)
r=r+rtest("c2d('81'x,1)","\== -127",6)
r=r+rtest("c2d('81'x,2)","\== 129",7)
r=r+rtest("c2d('FF81'x,2)","\== -127",8)
r=r+rtest("c2d('FF81'x,1)","\== -127",9)
r=r+rtest("c2d('FF7F'x,1)","\== 127",10)
r=r+rtest("c2d('F081'x,2)","\== -3967",11)
r=r+rtest("c2d('F081'x,1)","\== -127",12)
/* From: Mark Hessling */
r=r+rtest("c2d( 'ff80'x, 1)","\== '-128'",13)
r=r+rtest("c2d( '' )","\== '0'",14)
r=r+rtest("c2d( '101'x )","\== '257'",15)
r=r+rtest("c2d( 'ff'x )","\== '255'",16)
r=r+rtest("c2d( 'ffff'x)","\== '65535'",17)
r=r+rtest("c2d( 'ffff'x, 2)","\== '-1'",18)
r=r+rtest("c2d( 'ffff'x, 1)","\== '-1'",19)
r=r+rtest("c2d( 'fffe'x, 2)","\== '-2'",20)
r=r+rtest("c2d( 'fffe'x, 1)","\== '-2'",21)
r=r+rtest("c2d( 'ffff'x, 3)","\== '65535'",22)
r=r+rtest("c2d( 'ff7f'x, 1)","\== '127'",23)
r=r+rtest("c2d( 'ff7f'x, 2)","\== '-129'",24)
r=r+rtest("c2d( 'ff7f'x, 3)","\== '65407'",25)
r=r+rtest("c2d( 'ff80'x, 1)","\== '-128'",26)
r=r+rtest("c2d( 'ff80'x, 2)","\== '-128'",27)
r=r+rtest("c2d( 'ff80'x, 3)","\== '65408'",28)
r=r+rtest("c2d( 'ff81'x, 1)","\== '-127'",29)
r=r+rtest("c2d( 'ff81'x, 2)","\== '-127'",30)
r=r+rtest("c2d( 'ff81'x, 3)","\== '65409'",31)
r=r+rtest("c2d( 'ffffffffff'x, 5)","\== '-1'",32)
r=r+rtest("c2d('0031'x,0)","\== 0",33)
say 'Done c2d.rexx'
exit r
