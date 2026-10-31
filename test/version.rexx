say '----------------------------------------'
say 'File version.rexx'
/* PARSE VERSION shows the version of mbt.toml as V3R0M0, the form of the
   2.x releases (#438); mvstest.py puts it in for @VRM@ */
err = 0
want = '@VRM@'
parse version lang vers date
if lang \== 'BREXX/370' then call fail 'language', lang
if vers \== want then call fail 'version', vers
if left(date, 1) \== '(' | right(date, 1) \== ')' then call fail 'date', date
if words(date) \== 3 then call fail 'date words', date
if version() \== vers then call fail 'VERSION()', version()
parse value version('FULL') with 'Version' fv 'Build Date' .
if strip(fv) \== vers then call fail "VERSION('FULL')", version('FULL')
say 'Done version.rexx'
exit err

fail: procedure expose err
  parse arg what, got
  say 'FAIL' what': got "'got'"'
  err = err + 1
  return
