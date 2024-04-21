/* encode and decode a file */
parse arg seed filei fileo .

if seed == "" then do
    say "Encode/Decode a file"
    call write ,"Code: "
    parse pull seed
    call write ,"Input  File: "
    parse pull filei
    call write ,"Output File: "
    parse pull fileo
end

if filei='' | fileo='' | ¬datatype(seed,"NUM") then do
    say "syntax: code password filein fileout"
    say "password must be a integer number"
    exit 1
end
r = random(,,seed)
filein = open(filei,"rb")
fileout = open(fileo,"wb")
if filein=-1 then do
    say "Error opening file '"filei"'"
    exit 2
end
if fileout=-1 then do
    say "Error opening file '"fileo"'"
    exit 2
end
i = 0
do forever
    b = read(filein,1)
    if length(b) = 0 then leave
    call write fileout,bitxor(b,d2c(random(0,255)))
    i = i+1
end
call close filein
call close fileout
