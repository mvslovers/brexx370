/* ---------------------------------------------------------------------
 * Sets certain Sticky content, must be a one liner
 * ---------------------------------------------------------------------
 */
SetDash:
  parse upper arg sttype,sttext,stcenter
  trace off  /* trace off to suspend FSS error messages */
  if stcenter='RIGHT'       then stcenter=1  /* right */
  else if stcenter='CENTER' then stcenter=2  /* center */
  else stcenter=0                            /* left */
 ADDRESS FSS
  'TEST'
  rc1=rc
  do sti=1 to sticky.0
     if sticky.__active.sti=0 then iterate
     _#name =sticky.__name.sti
     if translate(sticky.__title.sti)=sttype then nop
     else iterate
     _#name =sticky.__name.sti
     if rc1=0 then 'CHECK FIELD sticky.'_#name'.1'
     else rc=8
     if rc>0 | rc1>0 then do
        sticky._#NAME.__keep=arg(2)  /* not yet defined, will be done later */
        leave
     end
     poplen=sticky.__cols.sti
     if poplen<0 then poplen=#scrwidth
     if stcenter=0 then popi=left(arg(2),poplen)
     else if stcenter=1 then popi=right(arg(2),poplen)
     else if stcenter=2 then popi=center(arg(2),poplen)
    'SET FIELD STICKY.'_#name'.1 popi'
     sticky._#NAME.__lastupd=time('MS')
     sticky._#NAME.__keep=''
     leave   /* Sticky found and performed: leave  */
  end
  trace on     /* trace on to re-activate error messages */
return
