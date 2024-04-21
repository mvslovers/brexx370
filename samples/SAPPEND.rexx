say copies('-',50)
say "Read External into Sarray"
say copies('-',50)
dsnin=mvsvar("REXXDSN")
s1=sread("'"dsnin"(lldata)'")
call sAPPEND(s1,s1,10,20)
say copies('-',50)
say 'Appended Array by itself from entry to 20'
say copies('-',50)
call slist s1
call sfree s1
EXIT 0
