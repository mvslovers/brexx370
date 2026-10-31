/* REXX - IRXVTOC through VTOC(), LISTDSIX() and LISTVOL() in TSO      */
/* MVSTEST TSO                                                         */
/* IRXVTOC reads a volume's VTOC; BREXX calls it from the preloaded    */
/* REXX functions VTOC, LISTDSIX and LISTVOL (src/preload.c), and only */
/* under TSO. The data set is looked up with LISTDSI, so that the test */
/* does not depend on a volume name.                                   */
say '----------------------------------------'
say 'File vtoc.rexx'
err = 0
dsn = 'SYS1.LINKLIB'
call listdsi "'"dsn"'"
call check 'LISTDSI',          result, 0
vol = sysvolume

/* VTOC: one line per data set in the stem, header text in VTOC.HDR */
call vtoc vol
call check 'VTOC lines',       datatype(vtoc.0, 'W') & vtoc.0 > 0, 1
call check 'VTOC.HDR',         word(vtoc.hdr, 1), 'DSNAME'
/* the data set lines, then the totals line and an empty line */
nds = vtoc.0 - 2
tot = vtoc.0 - 1
call check 'totals line',      word(vtoc.tot, 2), 'TOTALS'
call check 'totals count',     word(vtoc.tot, 4), nds
found = 0
bad = 0
do i = 1 to nds
   if word(vtoc.i, 2) \== vol then bad = bad + 1
   if word(vtoc.i, 1) == dsn then do
      found = i
      valloc = word(vtoc.i, 3)
      vused  = word(vtoc.i, 4)
      vdsorg = word(vtoc.i, 5)
   end
end
call check 'all on the volume', bad, 0
call check 'data set listed',  found > 0, 1
call check 'ALLOC numeric',    datatype(valloc, 'W'), 1
call check 'USED <= ALLOC',    vused <= valloc, 1
call check 'DSORG',            vdsorg, sysdsorg

/* LISTDSIX: LISTDSI plus what only the VTOC knows */
call listdsix "'"dsn"'"
call check 'LISTDSIX rc',      result, 0
call check 'SYSTRACKS',        systracks, valloc
call check 'SYSDSORGX',        sysdsorgx, sysdsorg
call check 'SYSEXTENTS',       datatype(sysextents, 'W') & sysextents > 0, 1
call check 'SYSBLKSIZEX',      datatype(sysblksizex, 'W'), 1
call check 'SYSLRECLX',        datatype(syslreclx, 'W'), 1
ok = wordpos(sysunits, 'CYLINDERS TRACKS BLOCKS') > 0
call check 'SYSUNITS',          ok, 1
call listdsix "'NO.SUCH.DATA.SET'"
call check 'no such data set', result, 8

/* the raw output: summary line first, BREXX line last, range limits */
sx = __exvtoc(vol, 'BEGINNING('dsn') ENDING('dsn') NOHEADING')
n = sarray(sx)
call check 'range lines',      n, 3
call check 'range data set',   word(sget(sx, 1), 11), dsn
call check 'range totals',     word(sget(sx, 2), 4), 1
call check 'range tail',       word(sget(sx, n), 1), '>>BREXX'
call check 'range volume',     word(sget(sx, n), 2), vol
call sfree sx
call check 'no volume',        __exvtoc('', 'NOHEADING NOPRINT'), -8

/* LISTVOL */
call check 'LISTVOL',          listvol(vol), 0
call check 'VOLVOLUME',        volvolume, vol
call check 'VOLDEVICE',        voldevice > 0, 1
call check 'VOLTRKS',          datatype(voltrks, 'W') & voltrks > 0, 1

/* a volume that is not mounted: an empty VTOC */
call vtoc 'ZZZZZ9'
call check 'not mounted lines', vtoc.0 <= 2, 1
call check 'not mounted LISTVOL', lv('ZZZZZ9'), 12

say 'Done vtoc.rexx'
exit err

lv:
signal on syntax name lvx
return listvol(arg(1))
lvx:
return 'error' rc

check:
parse arg what, got, want
if got == want then say left('VTOC',8) '-' left(what,20) '.. PASS'
else do
   say left('VTOC',8) '-' left(what,20) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
