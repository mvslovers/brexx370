/** count lines **/
call load "files.r"
lines = 0
size = 0
file = "$$$fff$$$"
"ls" arg(1) "(stack"
/*"*dir /b" arg(1) ">" file*/
do queued()
    parse pull f
    l = lines(f)
    s = filesize(f)
    say format(l,5) format(s,6) f
    lines = lines + l
    size = size + s
end
say "total lines =" lines
say "total size  =" size
exit 0
