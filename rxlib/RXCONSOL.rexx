/* -------------------------------------------------------------------
 * Perform Console command and return associated Master TT Entries
 * ................................. Created by PeterJ on 19. May 2021
 * -------------------------------------------------------------------
 */
rxConsol: procedure expose console.
  parse upper arg cmd,wait4
/* .....  Send operator command  ............................ */
  call console(cmd)
  if datatype(wait4)<>'NUM' then wait4=300
  call wait(wait4)
  jobnum=MVSvar('JOBNUMBER')
  if arg(3)='STEM' then return console_slow()
  return console_fast()
/* -------------------------------------------------------------------
 * Running Console in ARRAY mode is much faster
 * -------------------------------------------------------------------
 */
console_fast:
  jnum=substr(jobnum,4)+0
  if __sysvar('SYSTSO')=1 then jbn='TSU'
     else jbn='JOB'
  jobn=jbn||right(jnum,5)
  cnum=2
/* .....  Check Trace Table for result  ..................... */
  mtt_sarray=screate(2000)
  _lines=mttx(1,mtt_sarray)     /* 1: build new, array is: mtt_sarray  */
  ssi=ssearch(mtt_sarray,jobn)
  _line=sget(mtt_sarray,ssi)
  if pos(cmd,_line)==0 then return 8
  console.1=_line
  _line=sget(mtt_sarray,ssi-1)
  console.2=_line
  trnum=lastword(_line)
  do k=ssi-2 to 1 by -1
     _line=sget(mtt_sarray,k)
     if word(_line,1)<>trnum then iterate
     cnum=cnum+1
     console.cnum=_line
  end
  console.0=cnum
return 0
/* -------------------------------------------------------------------
 * Running Console in STEM mode is slower
 * -------------------------------------------------------------------
 */
console_slow:
  console.0=0
/* .....  Check Trace Table for result  ..................... */
  call mtt()
  if _findTTEntry()<0 then return 8
/* .....  Pick up all TT entries after entry ................ */
  console.1=_line._tti
  cnum=1
  do k=_tti+1 to _line.0
     if strip(_line.k)='' then iterate
     if cnum=1 then do
 /*  0000 10.54.40 TSU 4344
     0000 10.54.40
  */
        cnum=cnum+1
        console.cnum=_line.k
        trnum=lastword(_line.k)
        if datatype(trnum)<>'NUM' then trnum=-1
        iterate
     end
     if trnum>0 then if word(_line.k,1)<>trnum then iterate
     cnum=cnum+1
     console.cnum=_line.k
  end
  console.0=cnum
return 0
/* -------------------------------------------------------------------
 * Find TT Entry with the sent operator command
 * -------------------------------------------------------------------
 */
_findTTEntry:
/* ...  Find job-/tso number which requested the command  ... */
  do _tti=_line.0 to max(1,_line.0-100) by -1
     jobn=translate(substr(_line._tti,15,8),'0',' ')
     if jobn<>jobnum then iterate
     if substr(_line._tti,25)=cmd then leave
  end
  if jobn<>jobnum then return -8
return _tti
