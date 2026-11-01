-- The JES2 primary option menu (JESQMENU, samples/JESQUEUE.rexx) on a model 2
-- screen, 80x24 (#514). Its description fields were 60 columns wide from
-- column 21, one more than the line holds, and the menu stopped with an FSS
-- definition error. [tso.JESQMENU] size pins the screen.

return function(t)
  t:logon()
  t:type("ALLOC F(RXLIB) DA('" .. t.fixtures.RXLIB .. "') SHR REUSE"):enter()

  t:clear()
  t:type("BREXX '" .. t.fixtures.TSOTEST .. "(JESQUEUE)'"):enter()
  t:expect("Display Available Volumes")
  assert(t:text():find("JES2 Primary Option Menu", 1, true), t:text())
  assert(not t:text():find("Definition Error", 1, true), t:text())

  t:pf(3)
  t:expect("READY")
  t:logoff()
end
