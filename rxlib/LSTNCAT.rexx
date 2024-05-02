/* ---------------------------------------------------------------------
 * LISTNCAT find not catalogued Datasets (by VTOCs)
 * ---------------------------------------------------------------------
 */
listncat: procedure
  parse upper arg fdsn
  say copies('-',73)
  say 'List all not catalogued Datasets 'arg(1)' by scanning VTOCs'
  say copies('-',73)
  nc=0
  call listvols
  do i=1 to volumes.0
     volname=word(volumes.i,1)
     call vtoc volname
     do j=1 to vtoc.0
        cdsn=word(vtoc.j,1)
        if cdsn=0 then iterate
        if strip(substr(vtoc.j,1,5))='' then iterate
        if arg(1)<>'' then if pos(fdsn,cdsn)=1 then nop
        else iterate
        xrc=ListDSIQ(cdsn)
        if xrc>0 then call __ncat(cdsn,volname,' ** not catlg')
        else if volname<>sysvolume then call __ncat(cdsn,volname,
            ' ** not catlg2, is on 'sysvolume)
     end
   end
   say copies('-',73)
   say 'not catalogued DSNs found 'nc
return
__ncat:
  say left(arg(1),44) left(arg(2),8)' 'arg(3)
  nc=nc+1
return
