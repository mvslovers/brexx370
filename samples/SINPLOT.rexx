do x=0 to 6.28 by 0.299
    y = trunc(35 * (sin(x) + 1.1)) + 1
    out = copies(" ",y) || "*"
    l = left(out,39," ")
    r = substr(out,41)
    say l || substr("|*",1+pos("*",substr(out,40,1)),1) || r
end
