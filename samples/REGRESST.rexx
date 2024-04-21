m0=mcreate(10,3)
call mcol m0,1,156.3,158.9,160.8,179.6,156.6,165.1,165.9,156.7,167.8,160.8
call mcol m0,2,62,52,83,69,74,52,77,65,79,51
call mcol m0,3,24,34,26,51,43,33,22,21,19,34
call mprint(m0,"Data","Original Data Matrix")
y0=mcreate(10,1)
call mcol y0,1,47.1,46.8,49.3,53.2,47.7,49.0,50.6,47.1,51.7,47.8
call mprint(y0,"Y","Result Vector")
rgr=regressn(m0,y0,1)
say copies('-',72)
say 'Regression factors'
say copies('-',72)
say 'const  '_regression.1
do i=2 to _regression.0
   say 'x('i-1')   '_regression.i
end
return
mcol:
parse arg mx,col
do j=3 to arg()
   i=j-2
   call mset(mx,i,col,arg(j))
end
return
