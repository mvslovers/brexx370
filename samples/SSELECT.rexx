say copies('-',50)
say "Read External into Sarray, select Subset"
say copies('-',50)
dsnin=mvsvar("REXXDSN")
s1=sread("'"dsnin"(lldata)'")      /* Create Linked List */
call slist s1
s2=sselect(s1,'ON','OF','EE')
say copies('-',50)
say 'Selected for lines containing ON, OF, EE'
say copies('-',50)
call slist s2
call sfree(s1)
call sfree(s2)
EXIT 0
