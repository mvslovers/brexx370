/* ---------------------------------------------------------------------
 * Determine Netspool DSN
 * ---------------------------------------------------------------------
 */
RXNJE38DSN:
  parse arg mode
  if mode='ALLOC' then do
     isSet=0
     dsn=getg('NETSPOOL')
     if dsn='' then dsn=mvsvar('NJEDSN')
        else isSet=1
     if dsn='' then do
        zerrsm='NJE38 Application not active'
        zerrlm='NJE38 Application not active or Allocation failed'
        return 8
     end
     alc=allocate('NETSPOOL',"'"dsn"'")
     if alc<0 | alc>4 then do
        zerrsm='NJE38 NETSpool allocation error'
        zerrlm='NJE38 NETSpool allocation error'
        return 8
     end
     if isSet=0 then call setg('NETSPOOL',dsn)
     return alc
  end
  if mode='FREE' then do
     frc=free('NETSPOOL')
     return frc
  end
  say mode' unknown mode'
return 8
