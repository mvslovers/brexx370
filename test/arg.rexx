say '----------------------------------------'
say 'File arg.rexx'
rc = 0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
func = left('ARG',8,' ')
call name
call namex 1,,2
/* These from Mark Hessling. */
call testarg2 1,,2
call testarg1
say 'Done arg.rexx'
exit rc

name:
if arg() \= 0 then do
  say func '- test 1 .. *FAIL* - function arg() expected \= 0 actual' arg()
  rc = 8
end
else say func "- test 1 ... PASS"

if arg(1) \== '' then do
  say func '- test 2 .. *FAIL* - function arg(1) expected \== '' actual' arg(1)
  rc = 8
end
else say func "- test 2 ... PASS"

if arg(2) \== '' then do
  say func '- test  .. *FAIL* - function arg(2) expected \== '' actual' arg(2)
  rc = 8
end
else say func "- test 3 ... PASS"
if arg(1,'e') then do
say func "- test 4 .. *FAIL* - function",
"arg(1,'e') expected 1 actual" arg(1,'e')
end
else say func "- test 4 ... PASS"
if arg(1,'O') \= 1 then do
say func "- test 5 .. *FAIL* - function arg(1,'O') \= 1 expected 1 actual",
 arg(1,'e')
  rc = 8
end
else say func "- test 5 ... PASS"
return

namex:

if arg() \= 3 then do
  say 'failed in test 6 '
  rc = 8
end
else say func "- test 6 ... PASS"
if arg(1) \== 1 then do
  say 'failed in test 7 '
  rc = 8
end
else say func "- test 7 ... PASS"
if arg(2) \== '' then do
  say 'failed in test 8 '
  rc = 8
end
else say func "- test 8 ... PASS"
if arg(3) \= 2 then do
  say 'failed in test 9 '
  rc = 8
end
else say func "- test 9 ... PASS"
if arg(99) \== '' then do
  say 'failed in test 10 '
  rc = 8
end
else say func "- test 10 ... PASS"
if arg(1,'e') \= 1 then do
  say 'failed in test 11 '
  rc = 8
end
else say func "- test 11 ... PASS"
if arg(2,'E') \= 0 then do
  say 'failed in test 12 '
  rc = 8
end
else say func "- test 12 ... PASS"
if arg(2,'O') \= 1 then do
  say 'failed in test 13 '
  rc = 8
end
else say func "- test 13 ... PASS"
if arg(3,'o') \= 0 then do
  say 'failed in test 14 '
  rc = 8
end
else say func "- test 14 ... PASS"
if arg(4,'o') \= 1 then do
  say 'failed in test 15 '
  rc = 8
end
else say func "- test 15 ... PASS"
return



testarg1:

if arg() \== "0" then do
  say 'failed in test 16 '
  rc = 8
end
else say func "- test 16 ... PASS"
if arg(1) \== "" then do
  say 'failed in test 17 '
  rc = 8
end
else say func "- test 17 ... PASS"
if arg(2) \== "" then do
  say 'failed in test 18 '
  rc = 8
end
else say func "- test 18 ... PASS"
if arg(1,"e") \== "0" then do
  say 'failed in test 19 '
  rc = 8
end
else say func "- test 19 ... PASS"
if arg(1,"O") \== "1" then do
  say 'failed in test 20 '
  rc = 8
end
else say func "- test 20 ... PASS"
return

testarg2:

if arg() \== "3" then do
  say 'failed in test 21 '
  rc = 8
end
else say func "- test 21 ... PASS"
if arg(1) \== "1" then do
  say 'failed in test 22 '
  rc = 8
end
else say func "- test 22 ... PASS"
if arg(2) \== "" then do
  say 'failed in test 23 '
  rc = 8
end
else say func "- test 23 ... PASS"
if arg(3) \== "2" then do
  say 'failed in test 24 '
  rc = 8
end
else say func "- test 24 ... PASS"
if arg(4) \== "" then do
  say 'failed in test 25 '
  rc = 8
end
else say func "- test 25 ... PASS"
if arg(1,"e") \== "1" then do
  say 'failed in test 26 '
  rc = 8
end
else say func "- test 26 ... PASS"
if arg(2,"E") \== "0" then do
  say 'failed in test 27 '
  rc = 8
end
else say func "- test 27 ... PASS"
if arg(2,"O") \== "1" then do
  say 'failed in test 28 '
  rc = 8
end
else say func "- test 28 ... PASS"
if arg(3,"o") \== "0" then do
  say 'failed in test 29 '
  rc = 8
end
else say func "- test 29 ... PASS"
if arg(4,"o") \== "1" then do
  say 'failed in test 30 '
  rc = 8
end
else say func "- test 30 ... PASS"

return

