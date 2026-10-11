-- FSSMENU on a real 3270 (#413, #422): FSS needs a terminal, so neither
-- a batch step nor a batch TMP can run it. The BREXX command is the one
-- installed on the stand; the RXLIB and the execs are the repository's
-- ([tso.FSSMENU] fixtures in mbt.toml).

-- select option 2 in a menu, end it with PF3, and read what the exec says
local function menu(t, exec)
  t:type("BREXX '" .. t.fixtures.TSOTEST .. "(" .. exec .. ")'"):enter()
  t:expect("Second option")
  t:type("2"):enter()
  t:expect("Second option")             -- the menu again, no error
  t:pf(3)
  t:expect("FSSMENU RETURNED PF03 SELECTED two")
end

return function(t)
  t:logon()
  t:type("ALLOC F(RXLIB) DA('" .. t.fixtures.RXLIB .. "') SHR REUSE"):enter()
  menu(t, "MENUTST")
  t:clear()
  menu(t, "MENUOPT")
  t:logoff()
end
