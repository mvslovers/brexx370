call load ibmdate.rexx
WhenAreYouBorn:                                                              
SIGNAL ON SYNTAX NAME BadDate                                             

/* year, month day */                                                     
SAY "Would you tell me the year you were born? -- full year: e.g 1962"    

PARSE PULL y
SAY "Month?"
PARSE PULL m
m = right(m,2,'0')  /* provide reqs zeroes */
SAY "And day?"
PARSE PULL d
d = right(d,2,'0')
bday = y || m || d

SAY "Hence, you were born on a sunny" Date('W', bday, 'S') "of" Date('M', bday, 'S')
base = Date('B', bday, 'S');
SAY "That was" base "days after January 1st, Year 1, did you know?"
nowBase = Date('B');
SAY "and it was about " nowBase-base "days ago...  Not a big deal!"
hundredBase = Date('B', y+100 || m || d, 'S')
SAY "You have just" hundredBase-nowBase "left to get ready for your hundredt birthday."
EXIT
BadDate:
Say "I can't understand this date.  Please, re-enter the year (or say 'N' to exit)"
PULL answer
IF (answer = 'N') THEN EXIT
PUSH answer
SIGNAL HereAgain
