say copies('-',50)
say "Read External into Sarray, select Subset"
say copies('-',50)
dsnin=mvsvar("REXXDSN")
s1=sread("'"dsnin"(lldata)'")      /* Create Linked List */
/* call slist s1   */
call sSUBSTR(s1,25,,'INTERNAL')
say copies('-',50)
say 'ARRAY from Column 25 '
say copies('-',50)
call slist s1
call sfree s1
EXIT 0
