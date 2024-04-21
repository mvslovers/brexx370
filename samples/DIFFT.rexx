dsn1=MVSVAR('REXXDSN')'(HOUSING)'
dsn2=MVSVAR('REXXDSN')'(HOUSING2)'

rarray=RXDIFF(dsn1,dsn2,'ALL','DETAILS')
 say 'New    Old     'file1'<-'file2
 say 'Lino   Lino    Lines'
do i=1 to sarray(rarray)
   say sget(rarray,i)
end
