say copies('-',50)
say "Read External into Sarray, select Subset"
say copies('-',50)
dsnin=mvsvar("REXXDSN")
s1=sread("'"dsnin"(lldata)'")      /* Create Linked List */
call slist s1
i1=s2HASH(s1,25,,'INTERNAL')
say copies('-',50)
say 'Hashes from ARRAY'
say copies('-',50)
call ilist i1
call sfree s1
call ifree i1
EXIT 0
