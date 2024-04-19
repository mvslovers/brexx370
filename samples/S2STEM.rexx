smax=1000
s1=screate(smax)
do i=1 to smax
   call sset(s1,,"Record "i)
end
call slist s1,smax-10,smax
call time('r')
call s2stem(s1,"Fred.")
say "S2STEM "time('e')
do i=smax-10 to smax
   say i fred.i
end
