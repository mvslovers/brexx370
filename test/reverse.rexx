say '----------------------------------------'
say 'File reverse.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("reverse('ABc.')","\== '.cBA'",1)
r=r+rtest("reverse('XYZ ')","\== ' ZYX'",2)
r=r+rtest("reverse('Tranquility')","\== 'ytiliuqnarT'",3)
/* From: Mark Hessling */
r=r+rtest("reverse('foobar')","\== 'raboof'",4)
r=r+rtest("reverse('')","\== ''",5)
r=r+rtest("reverse('fubar')","\== 'rabuf'",6)
r=r+rtest("reverse('f')","\== 'f'",7)
r=r+rtest("reverse(' foobar ')","\== ' raboof '",8)
say 'Done reverse.rexx'
exit r
