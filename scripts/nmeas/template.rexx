/* REXX - cost of a full N walk over the variables of the exec (MVS-1559) */
/* MVSTEST TSO */
/* Kind I = integer values, S = string values, L = 200-byte values,     */
/* V = simple variables with integer values. np = passes after the      */
/* build (0 = build only, -1 = BASE calls only). Memory comes from the  */
/* step's VIRT in the job log, not from memory(): it floods the log.    */
kind = '@KIND@'
n    = @N@
np   = @NP@
showb = 0
rcx = 0
say 'NMCFG kind='kind 'n='n 'np='np
call time 'R'
do i = 1 to n
   if kind = 'I' then s.i = i
   else if kind = 'S' then s.i = 'value'i
   else if kind = 'L' then s.i = copies('x', 200)i
   else call value 'V'i, i
end
tb = time('E')
say 'NMBUILD kind='kind 'n='n 'seconds='tb
if np \= 0 then do
   pm = 'BASE 5000'
   address LINKMVS 'TSTNMEAS' pm
   rcx = rc
   call show 'BASE'
end
do p = 1 to np
   pm = 'PASS 0'
   address LINKMVS 'TSTNMEAS' pm
   rcx = rc
   showb = (p = 1)
   call show 'PASS'p
end
say 'NMEND kind='kind 'n='n 'np='np
exit 0

show:
parse arg tag
sh_cnt = nmcnt
sh_tot = nmtot
sh_wall = nmwall
sh_max = nmmaxd
sh_last = nmlast
sh_nb = nmnb
say 'NMRES' tag 'kind='kind 'n='n 'rc='rcx 'calls='sh_cnt,
    'tot16='sh_tot 'wall16='sh_wall,
    'max16='sh_max 'last16='sh_last 'nb='sh_nb
if showb = 1 then do
   do bi = 1 to sh_nb
      say 'NMBKT' tag bi nmb.bi
   end
end
drop nmcnt nmtot nmwall nmmaxd nmlast nmnb nmb.
return
