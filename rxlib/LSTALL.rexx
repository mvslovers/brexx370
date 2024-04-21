/* ---------------------------------------------------------------------
 * LISTALL  find all Datasets of the MVS Environment (by VTOCs)
 *                                         added by PEJ 29. January 2024
 * ---------------------------------------------------------------------
 */
listALL: procedure
  parse upper arg fdsn
  say copies('-',110)
  say 'List all Datasets 'arg(1)' by scanning VTOCs'
  say copies('-',110)
  lAll=screate(20000)
  call listvols
  do i=1 to volumes.0
     volname=word(volumes.i,1)
     call vtoc volname
     do j=1 to vtoc.0
        cdsn=word(vtoc.j,1)
        if cdsn=0 then iterate
        if strip(substr(vtoc.j,1,5))='' then iterate
        if arg(1)<>'' then if pos(fdsn,cdsn)>0 then nop
                           else iterate
        call sset(lAll,,vtoc.j)
     end
   end
   call sqsort lAll
   do i=1 to sarray(lAll)
      say sget(lAll,i)
   end
   say copies('-',73)
   say 'Datasets found 'sarray(lAll)
return
