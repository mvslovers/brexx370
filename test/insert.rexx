say '----------------------------------------'
say 'File insert.rexx'
/* These from TRL */

rc = 0

say "Look for INSERT OK"

if insert(' ','abcdef',3) \== 'abc def' then do
  exit
  rc = 8 
end

if insert('123','abc',5,6) \== 'abc 123 ' then do
  exit
  rc = 8 
end

if insert('123','abc',5,6,'+') \== 'abc++123+++' then do
  exit
  rc = 8 
end

if insert('123','abc') \== '123abc' then do
  exit
  rc = 8 
end

if insert('123','abc',,5,'-') \== '123--abc' then do
  exit
  rc = 8 
end

/* These from Mark Hessling. */

if insert("abc","def") \== "abcdef" then do
  exit
  rc = 8 
end

if insert("abc","def",2) \== "deabcf" then do
  exit
  rc = 8 
end

if insert("abc","def",3) \== "defabc" then do
  exit
  rc = 8 
end

if insert("abc","def",5) \== "def abc" then do
  exit
  rc = 8 
end

if insert("abc","def",5,,'*') \== "def**abc" then do
  exit
  rc = 8 
end

if insert("abc" ,"def",5,4,'*') \== "def**abc*" then do
  exit
  rc = 8 
end

if insert("abc","def",,0) \== "def" then do
  exit
  rc = 8 
end

if insert("abc","def",2,1) \== "deaf" then do
  exit
  rc = 8 
end

say "INSERT OK"

exit rc
