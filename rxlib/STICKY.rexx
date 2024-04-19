/* ---------------------------------------------------------------------
 * STICKY Command to switch on/off sticky notes (used in FSS)
 * ---------------------------------------------------------------------
 */
Sticky: procedure expose sticky. zerrsm zerrlm
  parse upper arg stin
  w1=word(stin,1)
  if abbrev('SHOW',w1,2)>0 then return stickysh(subword(stin,2))
  else do
     trace results
     result=0
     stin=translate(stin,,',')
     stnr=word(stin,1)
     mode=word(stin,2)
     if stnr='OFF' then do _sti=1 to sticky.0
        sticky.__active._sti=0
     end
     else if stnr='ON' then do _sti=1 to sticky.0
        sticky.__active._sti=1
     end
     else do
        if datatype(stnr)<>'NUM' then return 8
        if mode='OFF' then sticky.__active.stnr=0
           else sticky.__active.stnr=1
     end
  end
return result
