/* REXX - MTT() and MTTX(), the Master Trace Table (#157)              */
/* A WTO with a unique marker has to show up in both, the newest       */
/* entry of MTT() (last _LINE.) and MTTX() (first array item) agree,   */
/* a second call without 'R' returns -1 while nothing new was logged,  */
/* and the MTTX() filter selects only matching entries.                */
say '----------------------------------------'
say 'File mtt.rexx'
err = 0
marker = 'BRX157T' right(time('S'),5,'0') || right(random(0,99999),5,'0')

n = mtt('R')
say 'MTT(R)      ' n
if n <= 0 then call fail 'MTT(R) returned' n
else do
   if _line.0 \= n then call fail '_LINE.0' _line.0 '\=' n
   /* the oldest entry is the one cmtt may drop: compare old and new */
   say 'LINE.1' length(_line.1) '"'_line.1'"'
   do i = n - 2 to n
      if i < 2 then iterate
      say 'LINE.'i length(_line.i) '"'_line.i'"'
   end
end

/* nothing logged in between: MTT() without 'R' returns -1 */
got = 0
do try = 1 to 5 until got
   call mtt 'R'
   if mtt() = -1 then got = 1
end
if \got then call fail 'MTT() never -1 without new entries'

/* a WTO appears as a new entry */
call wto marker
found = 0
do try = 1 to 20 until found
   call wait 100
   n = mtt()
   if n > 0 then do i = 1 to n
      if pos(marker, _line.i) > 0 then found = 1
   end
end
say 'MARKER found' found 'after' try 'polls'
if \found then call fail 'WTO marker not in MTT()'

/* newest entry: last _LINE. equals first MTTX() item */
sa = screate(8192)
same = 0
do try = 1 to 5 until same
   n  = mtt('R')
   nx = mttx('R', sa, 1)
   if n > 0 & nx > 0 then same = (_line.n == sget(sa, 1))
end
say 'MTTX(R,,1)  ' nx '"'sget(sa, 1)'"'
if nx \= 1 then call fail 'MTTX(R,,1) returned' nx
if \same then call fail 'newest MTT/MTTX entries differ'

/* MTTX() without max: whole table, newest first */
nx = mttx('R', sa)
say 'MTTX(R)     ' nx
if nx <= 0 then call fail 'MTTX(R) returned' nx
else if nx < n - 5 then call fail 'MTTX(R)' nx 'far below MTT(R)' n

/* filter: only the marker entry */
nx = mttx('R', sa, , marker)
say 'MTTX(filter)' nx
if nx < 1 then call fail 'MTTX filter found' nx 'entries'
else do i = 1 to nx
   if pos(marker, sget(sa, i)) = 0 then,
      call fail 'MTTX filter item' i 'no match'
end
call sfree sa

say 'Done mtt.rexx'
exit err

fail:
say left('MTT',8) '-' arg(1) '.. *FAIL*'
err = err + 1
return
