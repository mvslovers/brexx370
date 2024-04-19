/* ---------------------------------------------------------------------
 * Define Popups if any. Will be called from within FMTLIST etc.
 * ---------------------------------------------------------------------
 */
stickyDef:
  if symbol('#scrwidth')<>'VAR' then #scrWidth=FSSWidth()-1
 /* if symbol('#scrheight')<>'VAR' then #scrheight=fssheight() */
  #scrheight=fssheight()
  do __sti=1 to sticky.0
     ##name=sticky.__name.__sti
     stcols=sticky.__cols.__STI
     if stcols<0 then do
        stcols=#scrWidth
        sticky.__cols.__STI=stcols
     end
     stcol =sticky.__col.__STI
     if stcol <0 then do
        stcol=#scrWidth-stcols+1
        sticky.__col.__STI=stcol
     end
     strows=sticky.__rows.__STI
     strow =sticky.__row.__STI
     if strow <0 then do
        strow=#scrHeight
        sticky.__row.__STI=strow
     end
     stcolor =value(sticky.__color.__STI)
     if datatype(stcolor)<>'NUM' then interpret 'stcolor='stcolor
     stcols=min(stcols,#scrwidth-stcol+1)
     if sticky.__dash.__sti=1 then nop
        else strows=min(strows,#scrheight-1-strow)
     if stcol=0 | stcol+stcols>#scrwidth then stcol=#scrwidth-stcols+1
     if strow=0 then strow=3
     if sticky.__dash.__sti=1 then nop
        else if strow>#scrheight then strow=#scrheight-1
     if sticky.__dash.__sti=1 then nop
        else if strow+strows>#scrheight then strows=#scrheight-1-strow+1
     sticky.__rows.__STI=strows
     if sticky.__frame.__STI=2 then   ,
       'field  'strow stcol stcolor+#prot 'STICKY.'##name'.__title' stcols
     else strow=strow-1
     sticky.__row.__STI=strow
     if sticky.__frame.__STI=1 then strows=strows+1
     do __STJ=1 to strows-1
       'field  'strow+__stj stcol stcolor+#prot 'STICKY.'##name'.'__stj stcols
     end
     if sticky.__frame.__STI<>1 then  ,
       'field  '__stj+strow stcol stcolor+#prot+#uscore 'sticky.'##name'.'__stj stcols
     if sticky.##NAME.__keep<>'' then do
       'SET FIELD STICKY.'##name'.1 sticky.##NAME.__keep'
        sticky._#NAME.__keep=''
     end
  end
return
