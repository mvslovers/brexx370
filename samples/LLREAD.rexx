dsnin=mvsvar("REXXDSN")
ll1=llread("'"dsnin"(lldata)'")      /* Create Linked List */
say copies('-',32)
say "Read External Linked List"
say copies('-',32)
call lllist ll1
say copies('-',32)
say "Write External Linked List"
say copies('-',32)
say "Records written: "llwrite(ll1,"'"dsnin"(lltemp)'")      /* Save Linked List */
