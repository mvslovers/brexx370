-- An attention (PA1) ends the exec like HALT does (#610). Under TSO the
-- attention terminated the command ("COMMAND TERMINATED"), so BREXX's end
-- never ran: ECTENVBK kept pointing at the ENVBLOCK of an unloaded copy and
-- the next dialog under ISPF abended. Needs a 3270: only a terminal can send
-- the attention. The BREXX called is the one deployed by `mbt deploy` (the
-- BREXX command of the stand is the installed one), and TSTXSENT of
-- `mbt test --mvs` puts a known value into ECTENVBK before and checks it
-- after ([tso.STAX] fixtures in mbt.toml). Not covered: an attention while
-- the exec waits in a host command (TSO command, ISPF DISPLAY).

local BREXX = "CALL 'BREXX370.DEV.LINKLIB(BREXX)' "

-- TSTXSENT writes one line, "TSTXSENT <op> ... RESULT=OK|FAIL"
local function ectenvbk(t, op)
  t:clear()
  t:type("CALL '" .. t.testlib .. "(TSTXSENT)' '" .. op .. "'"):enter()
  t:expect("TSTXSENT " .. op)
  return t:text():match("TSTXSENT " .. op .. ".-RESULT=(%a+)")
end

-- start the loop without waiting (it keeps the keyboard locked), wait until
-- it runs, press PA1, and wait for READY
local function attention(t, exec, running)
  t:clear()
  t:type(BREXX .. "'" .. t.fixtures.TSOTEST .. "(" .. exec .. ")'")
  t:enter{ wait = false }
  t:expect(running)
  t:pa(1, { wait = false })
end

return function(t)
  t:logon()
  assert(ectenvbk(t, "SET") == "OK", "SET failed:\n" .. t:text())

  -- (a) SIGNAL ON HALT: the handler runs and the exec ends itself
  attention(t, "STAXSIG", "STAXSIG RUNNING")
  t:expect("STAXSIG HANDLER")
  t:expect("READY")
  assert(not t:text():find("COMMAND TERMINATED", 1, true),
         "(a) BREXX was terminated:\n" .. t:text())
  assert(ectenvbk(t, "CHK") == "OK", "(a) ECTENVBK not restored:\n" .. t:text())

  -- (b) no handler: the HALT error, BREXX returns to READY
  attention(t, "STAXLOOP", "STAXLOOP RUNNING")
  t:expect("Program interrupted")
  t:expect("READY")
  assert(not t:text():find("COMMAND TERMINATED", 1, true),
         "(b) BREXX was terminated:\n" .. t:text())
  -- (c) ECTENVBK is what it was before the exec
  assert(ectenvbk(t, "CHK") == "OK", "(c) ECTENVBK not restored:\n" .. t:text())

  t:logoff()
end
