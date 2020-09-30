say '----------------------------------------'
say 'File testdat.rexx'
say 'Look for DATE OK'
/* rexx Set of Date() tests */
rc = 0
date = '20070922'
format = 'S'
say date()
/*
assertEQ(date('N', date, format, ''), "22Sep2007")
assertEQ(date('N', date, format,'-'), "22-Sep-2007")
assertEQ(date('O', date, format), "07/09/22")
assertEQ(date('O', date, format, ''), "070922")
assertEQ(date('O', date, format, '-'), "07-09-22")
assertEQ(date('S', date, format), "20070922")
assertEQ(date('S', date, format, ''), "20070922")
assertEQ(date('S', date, format, '-'), "2007-09-22")
assertEQ(date('U', date, format), "09/22/07")
assertEQ(date('U', date, format, ''), "092207")
assertEQ(date('U', date, format, '-'), "09-22-07")
assertEQ(date('W', date, format), "Saturday")
*/
say 'DATE OK'
exit rc
