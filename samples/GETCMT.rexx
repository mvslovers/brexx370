say copies('-',60)
say "Select Data Sections out of REXX comment"
say copies('-',60)

/* DATA STEM mystem.
Line 1
Line 2
Line 3
Line 4
Line 5
Line 6
Line 7
*/

/* DATA SARRAY sname
Record 1
Record 2
Record 3
Record 4
Record 5
*/

/* fetch data from DATA comments */
call getdata('GETCMT')
/* print content                 */
call slist sname,,,"Content of first Data Comment block"
call stemlist 'mystem',,,"Content of second Data Comment block"
return
