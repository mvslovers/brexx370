say '----------------------------------------'
say 'File reverse.rexx'
/* REVERSE */

rc = 0

say "Look for REVERSE OK"

/* These from the Rexx book. */

if reverse('ABc.') \== '.cBA' then do
  say 'failed in test 1 '
  rc = 8 
end

if reverse('XYZ ') \== ' ZYX' then do
  say 'failed in test 2 '
  rc = 8 
end

if reverse('Tranquility') \== 'ytiliuqnarT' then do
  say 'failed in test 3 '
  rc = 8 
end

/* These from Mark Hessling. */

if reverse("foobar") \== "raboof" then do
  say 'failed in test 4 '
  rc = 8 
end

if reverse("") \== "" then do
  say 'failed in test 5 '
  rc = 8 
end

if reverse("fubar") \== "rabuf" then do
  say 'failed in test 6 '
  rc = 8 
end

if reverse("f") \== "f" then do
  say 'failed in test 7 '
  rc = 8 
end

if reverse(" foobar ") \== " raboof " then do
  say 'failed in test 8 '
  rc = 8 
end

say "REVERSE OK"

exit rc
