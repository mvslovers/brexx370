say copies('-',32)
say "Read External in Sarray Sort Song List "
say copies('-',32)
dsnin=mvsvar("REXXDSN")
s1=sread("'"dsnin"(lldata)'")      /* Create Linked List */
call slist s1
call sqsort(s1,'ASC',31)         /* Sort Array S1 beginning column 25 (song name) */
say copies('-',32)
say "Sarray sorted by Song List "
say copies('-',32)
call slist s1
