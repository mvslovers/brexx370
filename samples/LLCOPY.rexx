max=20
ll1=llcreate()                       /* Create Linked List */
ll2=llcreate()                       /* Create Linked List */
call time('r')
do i=1 to max
   adr=lladd(ll1,i". Record")
end
call llList ll1
do i=1 to 10
   adr=lladd(ll2,i". Entry")
end
call llList ll2
ll3=llcopy(ll1,,,ll2,"Copied")
call llList ll3
