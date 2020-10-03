say '----------------------------------------'
say 'File errorte.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("errortext(16)","\== 'Label not found'",1)
r=r+rtest("errortext(90)","\== ''",2)
/* From: Mark Hessling */
r=r+rtest("errortext(10)","\== 'Unexpected or unmatched END'",3)
r=r+rtest("errortext(40)","\== 'Incorrect call to routine'",4)
r=r+rtest("errortext( 1)","\== ''",5)
say 'Done errorte.rexx'
exit r
