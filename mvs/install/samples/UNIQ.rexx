parse arg in out .
signal on halt
if in = "" then in = "<STDIN>"
if out = "" then out = "<STDOUT>"
prevline = ""
do forever
    line = read(in)
    if eof(in) then leave
    if line ^= prevline then call write out,line,nl
    prevline = line
end
halt:
exit
