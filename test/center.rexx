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
/* CENTRE (RossPatterson/CMS-370-BREXX) */
r=r+rtest("centre(abc,8,'-')","\== '--ABC---'",14)
r=r+rtest("centre('The blue sky',8)","\== 'e blue s'",15)
r=r+rtest("centre('The blue sky',7)","\== 'e blue '",16)
r=r+rtest("centre('****',8,'-')","\=='--****--'",17)
r=r+rtest("centre('****',7,'-')","\=='-****--'",18)
r=r+rtest("centre('*****',8,'-')","\=='-*****--'",19)
r=r+rtest("centre('*****',7,'-')","\=='-*****-'",20)
r=r+rtest("centre('12345678',4,'-')","\=='3456'",21)
r=r+rtest("centre('12345678',5,'-')","\=='23456'",22)
r=r+rtest("centre('1234567',4,'-')","\=='2345'",23)
r=r+rtest("centre('1234567',5,'-')","\=='23456'",24)
say 'Done center.rexx'
exit r
