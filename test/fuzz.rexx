say '----------------------------------------'
say 'File fuzz.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("fuzz()","\= 0",1)
say 'Done fuzz.rexx'
exit r
