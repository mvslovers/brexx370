/* REXX - submit a job for test/tso/jesqueue.lua (#487).               */
/* The job name is the userid plus one letter, so the job is the       */
/* caller's own (RAKF). Without an argument the job runs and keeps its */
/* output in class X, the only class held on both TK5 and MVS/CE. With */
/* HOLD the job stays in the input queue and has no output at all.     */
parse upper arg mode
if mode = 'HOLD' then do
  jn = userid() || 'H'
  parm = ',TYPRUN=HOLD'
end
else do
  jn = userid() || 'Z'
  parm = ''
end
s = screate(20)
call sset(s,, '//'jn" JOB (1),'JESQ',CLASS=A,MSGCLASS=X"parm)
call sset(s,, '//* JESQ-MARKER-LOG')
call sset(s,, '//STEP1 EXEC PGM=IEBGENER')
call sset(s,, '//SYSPRINT DD DUMMY')
call sset(s,, '//SYSIN DD DUMMY')
call sset(s,, '//SYSUT1 DD *')
call sset(s,, 'JESQ-MARKER-DATA')
call sset(s,, '/*')
call sset(s,, '//SYSUT2 DD SYSOUT=X')
tdsn = 'JESQ.JCL'
dsn = userid() || '.' || tdsn
call remove("'"dsn"'")
call create(tdsn, 'RECFM=FB,LRECL=80,BLKSIZE=8000,UNIT=SYSDA,PRI=1,SEC=1')
call swrite(s, "'"dsn"'")
call sfree s
address tso "SUBMIT '"dsn"'"
exit rc
