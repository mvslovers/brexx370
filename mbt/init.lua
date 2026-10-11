-- brexx370's MVS tools, run as mbt commands: mbt run NAME [-- ARGS].
--
-- The tools are Python (scripts/, tso/). mbt owns the connection: each
-- command hands its tool the target and the token of mbt's mvsMF session
-- in the environment, which scripts/mvsmf.py reads. The token ends with
-- the command, so a tool cannot outlive it or log on again.

local function tool_env(ctx)
  local tg = ctx.target()
  local p = ctx.project
  return {
    MVSTEST_TARGET   = tg.name or "",
    MVSTEST_URL      = tg.mvsmf.url,
    MVSTEST_USER     = tg.mvsmf.user or "",
    MVSTEST_TOKEN    = ctx.mvs.token(),
    MVSTEST_HLQ      = tg.hlq or "",
    MVSTEST_VOLUME   = tg.volume or "",
    MVSTEST_JOBCLASS = tg.jobclass or "",
    MVSTEST_MSGCLASS = tg.msgclass or "",
    MVSTEST_LINKLIB  = p.deploy_target or "",
    MVSTEST_TESTS    = table.concat(p.tests or {}, ","),
  }
end

local function python(ctx, script)
  local argv = { "python3", script }
  for _, a in ipairs(ctx.args) do argv[#argv + 1] = a end
  argv.env = tool_env(ctx)
  ctx.exec(argv)
end

mbt.command { name = "mvstest",
  description = "the smoke test and the REXX suite test/*.rexx on MVS",
  run = function(ctx) python(ctx, "scripts/mvstest.py") end }

mbt.command { name = "lmodlink",
  description = "tso/lmod_link.py: link EXEC the way SMP does (reference | testlib)",
  run = function(ctx) python(ctx, "tso/lmod_link.py") end }

mbt.command { name = "rxdrv",
  description = "tso/rxdrv_test.py: install RXDRV, run the classifier cases",
  run = function(ctx) python(ctx, "tso/rxdrv_test.py") end }

mbt.command { name = "zmginstall",
  description = "tso/lab/zmg_install.py: install ZMG0001 step by step",
  run = function(ctx) python(ctx, "tso/lab/zmg_install.py") end }

mbt.command { name = "exectest",
  description = "tso/lab/exec_test.py: the ZMG0001 EXEC test",
  run = function(ctx) python(ctx, "tso/lab/exec_test.py") end }
