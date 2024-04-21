dsn=MVSVAR('REXXDSN')'(HOUSING)'
m0=matin(dsn,"DELIM")
call mprint m0,"data","Data Matrix"
m1=MCorel(m0,1)
call mprint m1,,"Correlation Matrix","DH"
say "Complete "time('L')
return
