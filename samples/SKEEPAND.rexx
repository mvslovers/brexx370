say copies('-',50)
say "Read External into Sarray, select Subset"
say copies('-',50)
dsnin=mvsvar("REXXDSN")
s1=sread("'"dsnin"(lldata)'")      /* Create Linked List */
call slist s1
call sKEEPAND(s1,'AC','IN')
say copies('-',50)
say 'Items containing AC AND IN'
say copies('-',50)
call slist s1
call sfree s1
EXIT 0
