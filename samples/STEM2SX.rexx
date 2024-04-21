xmax=1000
do i=1 to xmax
   fred.i=i". record"
end
FRED.0=xmax
say "Set Time  "time('e')
call time('r')
s1=stem2s("fred.")
say "Copy Time "time('e')
call slist s1,xmax-10,xmax
