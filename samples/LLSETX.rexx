dsnin=mvsvar("REXXDSN")
ll1=llread("'"dsnin"(lldata)'")      /* Create Linked List */
say copies('-',32)
say "Run Through Linked List"
say copies('-',32)
say llget(ll1,"FIRST")
do while llset(ll1,"NEXT")>0
   say llget(ll1)
end
say copies('-',32)
say " Add CREAM before position 2 "
say copies('-',32)
call llset(ll1,"POSITION",2)         /* set to 2. Entry    */
call llinsert(ll1,"CREAM                         I AM SO GLAD")
call lllist ll1
call llfree ll1
