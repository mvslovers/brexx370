say '----------------------------------------'
say 'File trace.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("trace()","== 'N'",1)
r=r+rtest("trace('O')","== 'N'",2)
/* r=r+rtest("trace('?A')","== O",3) */
say 'Done trace.rexx'
exit r
