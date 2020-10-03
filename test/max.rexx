say '----------------------------------------'
say 'File max.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("max(12,6,7,9)","\= 12",1)
r=r+rtest("max(17.3,19,17.03)","\= 19",2)
r=r+rtest("max(-7,-3,-4.3)","\= -3",3)
/* From: Mark Hessling */
r=r+rtest("max( 10.1 )","\== '10.1'",4)
r=r+rtest("max( -10.1, 3.8 )","\== '3.8'",5)
r=r+rtest("max( 10.1, 10.2, 10.3 )","\== '10.3'",6)
r=r+rtest("max( 10.3, 10.2, 10.3 )","\== '10.3'",7)
r=r+rtest("max( 10.1, 10.2, 10.3 )","\== '10.3'",8)
r=r+rtest("max( 10.1, 10.4, 10.3 )","\== '10.4'",9)
r=r+rtest("max( 10.3, 10.2, 10.1 )","\== '10.3'",10)
r=r+rtest("max( 1, 2, 4, 5 )","\== '5'",11)
r=r+rtest("max( -0, 0 )","\== '0'",12)
r=r+rtest("max( 1,2,3,4,5,6,7,8,7,6,5,4,3,2 )","\== '8'",13)
say 'Done max.rexx'
exit r
