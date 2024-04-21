MATIN: Procedure expose mtitle.
RC1=ALLOCATE('PDS1',"'"arg(1)"'")
if rc1=0 then nop
else do
   say rc 'problems reading file(s)'
   exit 8
end
'EXECIO * DISKR' PDS1 '(STEM PDS1. '
/* -------------------------------------------- */
call time('r')
if arg(2)=='DELIM' then do
   do i=1 to pds1.0 until word(pds1.i,1)="$DATA"
   end
   j=i+1
   cols=words(pds1.j)
   rows=0
   do imax=j to pds1.0 while word(pds1.i,1)<>"$ENDDATA"
      rows=rows+1
   end
   if imax>pds1.0 then do
      imax=imax-1
      rows=rows-1
   end
   imax=imax-1
end
else do
  rows=pds1.0
  cols=words(pds1.1)
  imax=rows
  j=1  /* set to heading line */
end
rows=rows-1  /* title is saved separately */
m0=mcreate(rows,cols,"Input Matrix "arg(1))
do k=1 to cols
   mTitle.m0.k=word(pds1.j,k)
end
mTitle.m0.0=cols
row=0
do i=j+1 to imax
   row=row+1
   do k=1 to cols
      call mset(m0,row,k,word(pds1.i,k))
   end
end
/* -------------------------------------------- */
RC=FREE('PDS1')
return m0
