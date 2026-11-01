say '----------------------------------------'
say 'File min.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("min(12,6,7,9)","\= 6",1)
r=r+rtest("min(17.3,19,17.03)","\= 17.03",2)
r=r+rtest("min(-7,-3,-4.3)","\= -7",3)
/* From: Mark Hessling */
r=r+rtest("min( 10.1 )","\== '10.1'",4)
r=r+rtest("min( -10.1, 3.8 )","\== '-10.1'",5)
r=r+rtest("min( 10.1, 10.2, 10.3 )","\== '10.1'",6)
r=r+rtest("min( 10.1, 10.2, 10.1 )","\== '10.1'",7)
r=r+rtest("min( 10.1, 10.2, 10.3 )","\== '10.1'",8)
r=r+rtest("min( 10.4, 10.1, 10.3 )","\== '10.1'",9)
r=r+rtest("min( 10.3, 10.2, 10.1 )","\== '10.1'",10)
r=r+rtest("min( 5, 2, 4, 1 )","\== '1'",11)
r=r+rtest("min( -0, 0 )","\== '0'",12)
r=r+rtest("min( 8,2,3,4,5,6,7,1,7,6,5,4,3,2 )","\== '1'",13)
/* whole numbers beyond 32 bits (#481): a real, not error 26 */
r=r+rtest("min( 3E10, 2E10 )","\= 2E10",14)
r=r+rtest("min( 2E10, 3E10 )","\= 2E10",15)
r=r+rtest("min( -4294967296, 1 )","\= -4294967296",16)
r=r+rtest("min( 9E74, 8E74 )","\= 8E74",17)
r=r+rtest("min( -9E74, -8E74 )","\= -9E74",18)
r=r+rtest("min( 5, -3E10, 7 )","\= -3E10",19)
r=r+rtest("min( -2147483648, 5 )","\== '-2147483648'",20)
say 'Done min.rexx'
exit r
