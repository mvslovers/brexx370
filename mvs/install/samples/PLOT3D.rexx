f.1 = '30 * exp(-z*z/100)'
f.2 = 'sqrt(900.01-z*z)*.9-2'
f.3 = '30*cos(z/16)-2'
f.4 = '30-30*sin(z/18)'
f.5 = '30*exp(-cos(z/16))-30'
f.6 = '30*sin(z/10)'

arg f .
if datatype(f)^='NUM' then f = 1

say
do x=-30 to 30 by 1.5
    line = ''
    l = 0
    y1 = 5 * trunc(sqrt(900 - x*x) / 5 )
    do y=y1 to -y1 by -5
        z = trunc(25+ fn(sqrt(x*x+y*y)) - 0.7*y)
        if z<=l then iterate
        l = z
        line = overlay('*',line,z)
    end
    say line
end
exit

fn: procedure expose f. f
arg z
interpret 'r=' f.f
return r
