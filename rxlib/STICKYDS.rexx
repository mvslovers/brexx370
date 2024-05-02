/* ---------------------------------------------------------------------
 * Display Sticky Notes
 * ---------------------------------------------------------------------
 */
StickyDS:
  timems=time('ms')
  trace off    /* trace off to suspend FSS error messages */
  do sti=1 to sticky.0
     if sticky.__active.sti=0 then iterate
     _#title =sticky.__title.sti
     _#name  =sticky.__name.sti
     if sticky._#NAME.__fetch='' then iterate
     poplen=sticky.__cols.sti
     _#frame =sticky.__frame.sti
     _#refresh=sticky._#NAME.__refresh
     if symbol('STICKY.'_#NAME'.__FETCH')='VAR' then do
        if timems-sticky._#NAME.__lastupd>sticky._#NAME.__refresh then do
           signal on syntax name strxerror
           interpret sticky._#NAME.__fetch
           signal off syntax name strxerror
           sticky._#NAME.__lastupd=time('MS')
        end
     end
     if _#frame<>2 then frchr=''
     else do
        frchr='|'
        poplen=poplen-2
        popx='+'center(' '_#title' ',poplen,'-')'+'
       'SET FIELD STICKY.'_#NAME'.__title popx'
     end
     do ki=1 to sticky.__rows.sti
        if symbol('sticky._#NAME.ki')='VAR' then 
            popi=frchr||left(sticky._#NAME.ki,poplen)frchr
        else popi=frchr||copies(' ',poplen)frchr
       'SET FIELD STICKY.'_#name'.'ki' popi'
     end
  end
  trace on     /* trace on to re-activate error messages */
return
strxerror:
   signal off syntax name strxerror
   sticky._#NAME.1=time()' Rexx failure'
   sticky._#NAME.2=time()'Rexx terminated'
   sticky._#NAME.__fetch=''
return 0
