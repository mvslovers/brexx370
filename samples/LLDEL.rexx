dsnin=mvsvar("REXXDSN")
ll1=llread("'"dsnin"(lldata)'")      /* Create Linked List */
call lllist ll1
say copies('-',32)
say " Delete AC/DC song "
say copies('-',32)
call llset(ll1,"POSITION",3)         /* set to 3. Entry    */
call lldel(ll1)                      /* remove AC/DC       */
call lllist ll1
call llfree ll1
