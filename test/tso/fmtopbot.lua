-- The FMTOPBOT sample on a real 3270 (#513). Its top-line call back
-- ended the first CENTER argument with a comma and the next line did not
-- start with one, so CENTER received one argument and the sample stopped
-- with "Incorrect call to routine" before the list was shown.

return function(t)
  t:logon()
  t:type("ALLOC F(RXLIB) DA('" .. t.fixtures.RXLIB .. "') SHR REUSE"):enter()

  t:clear()
  t:type("BREXX '" .. t.fixtures.TSOTEST .. "(FMTOPBOT)'"):enter()
  t:expect("List Screen to Show Student Entries", { timeout = 30 })

  local text = t:text()
  assert(text:find("Update Date of Database", 1, true),
         "second top line missing:\n" .. text)
  assert(text:find("The following Commands are allowed", 1, true),
         "footer line missing:\n" .. text)

  t:pf(3)
  t:clear()
  t:logoff()
end
