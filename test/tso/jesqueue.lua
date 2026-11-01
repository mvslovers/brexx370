-- The spool list of JESQUEUE/JES2SPL and its S line command on a real 3270
-- (#487). FMTLIST drew no list rows (the menu stayed on the screen), and S
-- showed nothing when OUTPUT or REVIEW did not work, with no message. Two
-- jobs of the test user's own: one ran and holds its output in class X (held
-- on TK5 and on MVS/CE), one waits in the input queue and has none.

local function rowof(t, s)
  local n = 0
  for l in (t:text() .. "\n"):gmatch("([^\n]*)\n") do
    n = n + 1
    if l:find(s, 1, true) then return n end
  end
end

-- line command in the line area of the row that shows `text`; the list can
-- be longer than one screen
local function linecmd(t, text, cmd)
  for _ = 1, 30 do
    if t:text():find("Top of Data", 1, true) then break end
    t:pf(7)
  end
  local r = rowof(t, text)
  for _ = 1, 30 do
    if r then break end
    t:pf(8)
    r = rowof(t, text)
  end
  assert(r, "no row with " .. text .. " on the screen:\n" .. t:text())
  for _ = 1, 80 do
    if t:cursor() == r then break end
    t:tab()
  end
  t:type(cmd):enter()
end

return function(t)
  t:logon()
  t:type("ALLOC F(RXLIB) DA('" .. t.fixtures.RXLIB .. "') SHR REUSE"):enter()

  t:clear()
  t:type("BREXX '" .. t.fixtures.TSOTEST .. "(JESQSUB)'"):enter()
  t:expect("SUBMITTED")
  local job, id = t:text():match("JOB (%S+)%((%S+)%) SUBMITTED")
  assert(job, "no job number on the screen:\n" .. t:text())
  t:clear()
  t:type("BREXX '" .. t.fixtures.TSOTEST .. "(JESQSUB)' HOLD"):enter()
  t:expect("SUBMITTED")
  local hjob, hid = t:text():match("JOB (%S+)%((%S+)%) SUBMITTED")
  assert(hjob, "no job number on the screen:\n" .. t:text())

  -- wait for the first job to end: its output is on the queue
  for _ = 1, 30 do
    t:clear()
    t:type("STATUS " .. job .. "(" .. id .. ")"):enter()
    t:expect("READY")
    if t:text():find("OUTPUT", 1, true) then break end
  end

  t:clear()
  t:type("BREXX '" .. t.fixtures.TSOTEST .. "(JES2)'"):enter()
  t:expect("Top of Data", { timeout = 30 })

  -- S on the job that holds output shows it (REVIEW)
  linecmd(t, id, "S")
  t:expect("JESQ-MARKER", { timeout = 30 })
  t:pf(3)
  t:expect("SPOOL ==>")
  assert(not t:text():find("REVIEW failed", 1, true), t:text())

  -- S on the job without output says why on the screen
  linecmd(t, hid, "S")
  t:expect("no Output")
  t:pf(3)

  t:clear()
  t:type("CANCEL " .. hjob .. "(" .. hid .. ") PURGE"):enter()
  t:expect("READY")
  t:logoff()
end
