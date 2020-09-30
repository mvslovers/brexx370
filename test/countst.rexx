say '----------------------------------------'
say 'File countst.rexx'
/* COUNTSTR */
rc = 0
say "Look for COUNTSTR OK"
if countstr('bc','abcabcabc') \= 3 then do
  say 'failed in test 1 '
  rc = 8 
end
if countstr('aa','aaaa') \= 2 then do
  say 'failed in test 2 '
  rc = 8 
end
/* The following causes an endless loop */
if countstr('','a a') \= 0 then do
  say 'failed in test 3 '
  rc = 8 
end
if countstr('','def') \== 0 then do
  say 'failed in test 9 '
  rc = 8 
end
/* These from the Rexx book. */
/* These from Mark Hessling. */
if countstr('','') \== 0 then do
  say 'failed in test 4 '
  rc = 8 
end
if countstr('a','abcdef') \== 1 then do
  say 'failed in test 5 '
  rc = 8 
end
if countstr(0,0) \== 1 then do
  say 'failed in test 6 '
  rc = 8 
end
if countstr('a','def') \== 0 then do
  say 'failed in test 7 '
  rc = 8 
end
if countstr('a','') \== 0 then do
  say 'failed in test 8 '
  rc = 8 
end
if countstr('abc','abcdef') \== 1 then do
  say 'failed in test 10 '
  rc = 8 
end
if countstr('abcdefg','abcdef') \== 0 then do
  say 'failed in test 11 '
  rc = 8 
end
if countstr('abc','abcdefabccdabcd') \== 3 then do
  say 'failed in test 12 '
  rc = 8 
end
say "COUNTSTR OK"
exit rc
