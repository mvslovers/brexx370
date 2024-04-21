/* ---------------------------------------------------------------------
 * Define Dash Sticky
 * ---------------------------------------------------------------------
 */
FSSDash:
  parse arg sttitle,stname,strow,stcol,strows,stcols,stcolor,stframe
  if datatype(sticky.0)<>'NUM' then sticky.0=0
  do __sti=1 to sticky.0
     if sticky.__name.__sti=stname then return 4
  end
  sticki=sticky.0+1
  sticky.0=sticki
  rc=0
  if strows='' | strows=0  then do
     say 'Number of Rows is mandatory'
     rc=8
  end
  if strow ='' | strow=0   then do
     say 'Row position is mandatory'
     rc=8
  end
  if stcol ='' | stcol=0   then do
     say 'Column position is mandatory'
     rc=8
  end
  if stcols='' | stcols=0  then do
     say 'Number of Columns is mandatory'
     rc=8
  end
  if rc=8 then exit
  if stcolor=''| stcolor=0 then do
    csticki=sticki//6
    if csticki=0 then stcolor=#pink
    else if csticki=1 then stcolor=#yellow
    else if csticki=2 then stcolor=#turq
    else if csticki=3 then stcolor=#white
    else if csticki=4 then stcolor=#green
    else if csticki=5 then stcolor=#blue
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
  sticky.__dash.sticki =1
  sticky.__frame.sticki=stframe
  sticky.__active.sticki=1
  sticky.stname.0=0     /* set number of entries */
  sticky.stname.=''     /* set number of entries */
  sticky.stname.__lastupd=0
  sticky.stname.__refresh=5
return sticki
