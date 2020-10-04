say '----------------------------------------'
say 'File random.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("random()","< 0",1)
r=r+rtest("random(5,8)","< 5",2)
r=r+rtest("random(5,8)","> 8",3)
r=r+rtest("random(2)","< 2",4)
rando = "\==" random(,,1989)
r=r+rtest("random(,,1989)",rando,5)
say 'Done random.rexx'
exit r
