/* ---------------------------------------------------------------------
 * Define Sticky Screens
 * ---------------------------------------------------------------------
 */
fssticky:
  parse arg sttitle,stname,strow,stcol,strows,stcols,stcolor,stframe
  if datatype(sticky.0)<>'NUM' then sticky.0=0
  stname=translate(stname)
  do __sti=1 to sticky.0
     if sticky.__name.__sti=stname then return 4
  end
  sticki=sticky.0+1
  sticky.0=sticki
  if stcols='' | stcols=0  then stcols=25
  if strows='' | strows=0  then strows=10
  if stcol ='' | stcol=0   then stcol=0
  if datatype(sticky.__nrow)<>'NUM' then sticky.__nrow=3
  if strow ='' | strow=0   then strow=sticky.__nrow
  if stcolor=''| stcolor=0 then do
    csticki=sticki//7
    if csticki=0 then stcolor=#pink
    else if csticki=1 then stcolor=#yellow
    else if csticki=2 then stcolor=#turq
    else if csticki=3 then stcolor=#white
    else if csticki=4 then stcolor=#green
    else if csticki=5 then stcolor=#blue
    else if csticki=6 then stcolor=#red
  end
  if stframe='' then stframe=2
  else if abbrev('NOFRAME',stframe,3)=1 then stframe=0
  else if abbrev('PLAIN',stframe,3)=1 then stframe=1
  else stframe=2
  sticky.__title.sticki=sttitle
  sticky.__name.sticki =stname
  sticky.__cols.sticki =stcols
  sticky.__col.sticki  =stcol
  sticky.__rows.sticki =strows
  sticky.__row.sticki  =strow
  sticky.__color.sticki=stcolor
  sticky.__frame.sticki=stframe
  sticky.__active.sticki=1
  if strow+strows+1>sticky.__nrow then sticky.__nrow=strow+strows+1
  sticky.stname.0=0     /* set number of entries */
  sticky.stname.__lastupd=0
  sticky.stname.__refresh=5
return sticki
