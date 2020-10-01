say '----------------------------------------'
say 'File trace.rexx'
/* TRACE */
rc = 0
say "Look for TRACE OK"
/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/
say trace()
say trace('O')
/* say trace('?A') */
say "TRACE OK"
exit rc
