say '----------------------------------------'
say 'File arg.rexx'
/* ARG */

rc = 0

say "Look for ARG OK"

/* These from the Rexx book. */

call name;call namex 1,,2

/* These from Mark Hessling. */

call testarg2 1,,2

call testarg1

say "ARG OK"

exit rc

name:

if arg() \= 0 then do
  say 'failed in test 1 '
  rc = 8 
end

if arg(1) \== '' then do
  say 'failed in test 2 '
  rc = 8 
end

if arg(2) \== '' then do
  say 'failed in test 3 '
  rc = 8 
end

if arg(1,'e') then do
  say 'failed in test 4 '
  rc = 8 
end

if arg(1,'O') \= 1 then do
  say 'failed in test 5 '
  rc = 8 
end

return

namex:

if arg() \= 3 then do
  say 'failed in test 6 '
  rc = 8 
end

if arg(1) \== 1 then do
  say 'failed in test 7 '
  rc = 8 
end

if arg(2) \== '' then do
  say 'failed in test 8 '
  rc = 8 
end

if arg(3) \= 2 then do
  say 'failed in test 9 '
  rc = 8 
end

if arg(999) \== '' then do
  say 'failed in test 10 '
  rc = 8 
end

if arg(1,'e') \= 1 then do
  say 'failed in test 11 '
  rc = 8 
end

if arg(2,'E') \= 0 then do
  say 'failed in test 12 '
  rc = 8 
end

if arg(2,'O') \= 1 then do
  say 'failed in test 13 '
  rc = 8 
end

if arg(3,'o') \= 0 then do
  say 'failed in test 14 '
  rc = 8 
end

if arg(4,'o') \= 1 then do
  say 'failed in test 15 '
  rc = 8 
end

return



testarg1:

if arg() \== "0" then do
  say 'failed in test 16 '
  rc = 8 
end

if arg(1) \== "" then do
  say 'failed in test 17 '
  rc = 8 
end

if arg(2) \== "" then do
  say 'failed in test 18 '
  rc = 8 
end

if arg(1,"e") \== "0" then do
  say 'failed in test 19 '
  rc = 8 
end

if arg(1,"O") \== "1" then do
  say 'failed in test 20 '
  rc = 8 
end

return



testarg2:

if arg() \== "3" then do
  say 'failed in test 21 '
  rc = 8 
end

if arg(1) \== "1" then do
  say 'failed in test 22 '
  rc = 8 
end

if arg(2) \== "" then do
  say 'failed in test 23 '
  rc = 8 
end

if arg(3) \== "2" then do
  say 'failed in test 24 '
  rc = 8 
end

if arg(4) \== "" then do
  say 'failed in test 25 '
  rc = 8 
end

if arg(1,"e") \== "1" then do
  say 'failed in test 26 '
  rc = 8 
end

if arg(2,"E") \== "0" then do
  say 'failed in test 27 '
  rc = 8 
end

if arg(2,"O") \== "1" then do
  say 'failed in test 28 '
  rc = 8 
end

if arg(3,"o") \== "0" then do
  say 'failed in test 29 '
  rc = 8 
end

if arg(4,"o") \== "1" then do
  say 'failed in test 30 '
  rc = 8 
end

return


