/* ---------------------------------------------------------------------
 * Define Menu Line
 * ---------------------------------------------------------------------
 */
FSSMENU:
 PARSE ARG NUM,SHORT,LONG,action
 if translate(arg(1))='$DISPLAY' then return FSSMENUDIALOG(arg(2))
 if datatype(fssparms.menuoption.0)<>'NUM' then do
    fssparms.menuoption.0=0
    fssparms.menurow=12
 end
 ctr=fssparms.menuoption.0+1
 fssparms.menurow=fssparms.menurow+1
 fssparms.menuoption.0=ctr
 fssparms.menuoption.ctr=num
 action.ctr=action
 call fsstext num  ,fssparms.menurow, 6,,#prot+#white
 call fsstext short,fssparms.menurow, 9,,#prot+#turq
 call fsstext long ,fssparms.menurow,20,,#prot+#green
RETURN
/* ---------------------------------------------------------------------
 * Menu Dialog Handler
 * ---------------------------------------------------------------------
 */
FSSMENUDIALOG:
_callback=arg(1)
DO FOREVER
   /* UPDATE FIELD VALUES */
   if _callback<>'' then interpret 'call '_callback
   /* REFRESH / SHOW SCREEN */
   _pfkey=fssrefresh()
   if _pfkey==#pfk03 | _pfkey==#pfk15 then return _pfkey
   if _pfkey==#pfk04 | _pfkey==#pfk16 then return _pfkey
   sel = translate(fssfget('zcmd'))
   if sel='X' | sel='=X' then return '=X'
   call fssfSet 'ZERRSM',''
   call fssfSet 'ZCMD',''
   if sel='' then iterate
   do ki=1 to fssparms.menuoption.0
      if sel<>fssparms.menuoption.ki then iterate
      sel=''  /* Reset option to signal it was found */
      _w1=word(action.ki,1)
      if _w1='CALL' then interpret 'CALL 'substr(action.ki,5)
      else if _w1<>'TSO' then interpret action.ki
      else do
         _exc=strip(substr(action.ki,4))
         Address TSO
          _exc
         ADDRESS FSS
      end
   end
   if _w1='CALL' then nop
   if sel<>'' then call fssfSet 'ZERRSM','Invalid Option 'sel,'NOTEST'
end
CALL FSSCLOSE
return _PFKEY
