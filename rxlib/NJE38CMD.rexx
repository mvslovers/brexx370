/* ---------------------------------------------------------------------
 * Sends NJE38 Message command and picks up all received messages
 *   Output is collected in stem _nje38.n
 *   rc=NJE38CMD("NJE38 M nnn INFO /STATS",request-timeout,last-timeout)
 * ---------------------------------------------------------------------
 */
NJE38CMD: procedure expose nje38.
  parse upper arg njecmd
  if word(njecmd,1)='NJE38' then cmd='F NJE38,'subword(njecmd,2)
     else cmd='F NJE38,'njecmd
  if rxConsol(cmd)>0 then return 8
  do i=2 to console.0
     if substr(console.i,25,3)='NJE' then leave
  end
  if substr(console.i,25,3)<>'NJE' then return 12
  task=substr(console.i,15,8)
  nje38.1=substr(console.i,25)
  cnum=1
  do k=i+1 to console.0
     if substr(console.k,15,8)<>task then iterate
     cnum=cnum+1
     nje38.cnum=substr(console.k,25)
  end
  nje38.0=cnum
return 0
