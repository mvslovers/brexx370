say '----------------------------------------'
say 'File sign.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("sign('12.3')","\= 1",1)
r=r+rtest("sign(0.0)","\= 0",2)
r=r+rtest("sign(' -0.307')","\= -1",3)
/* From: Mark Hessling */
r=r+rtest("sign('0')","\== 0",4)
r=r+rtest("sign('-0')","\== 0",5)
r=r+rtest("sign('0.4')","\== 1",6)
r=r+rtest("sign('-10')","\== -1",7)
r=r+rtest("sign('15')","\== 1",8)
say 'Done sign.rexx'
exit r
