dsnin=mvsvar("REXXDSN")
ll1=llread("'"dsnin"(lldata)'")      /* Create Linked List */
say copies('-',32)
say "Unsorted Song List "
say copies('-',32)
call llList ll1
call llsort ll1,,31                  /* sort song names    */
say copies('-',32)
say "Sorted Song List "
say copies('-',32)
call llList ll1
return
