say '----------------------------------------'
say 'File center.rexx'
r=0
r=r+rtest("centre(abc,7)","\== '  ABC  '",1)
r=r+rtest("center(abc,7)","\== '  ABC  '",2)
r=r+rtest("center(abc,8,'-')","\== '--ABC---'",3)
r=r+rtest("center('The blue sky',8)","\== 'e blue s'",4)
r=r+rtest("center('The blue sky',7)","\== 'e blue '",5)
/* From: Mark Hessling */
r=r+rtest("center('****',8,'-')","\=='--****--'",6)
r=r+rtest("center('****',7,'-')","\=='-****--'",7)
r=r+rtest("center('*****',8,'-')","\=='-*****--'",8)
r=r+rtest("center('*****',7,'-')","\=='-*****-'",9)
r=r+rtest("center('12345678',4,'-')","\=='3456'",10)
r=r+rtest("center('12345678',5,'-')","\=='23456'",11)
r=r+rtest("center('1234567',4,'-')","\=='2345'",12)
r=r+rtest("center('1234567',5,'-')","\=='23456'",13)
say 'Done center.rexx'
exit r
