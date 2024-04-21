/* ------------------------------------------------------------
 * Standard FMTLIST with header and message line
 * ------------------------------------------------------------
 */
fmtlistc:
  parse upper arg caller
  if caller='' then do
     caller=rxname(-1)
     if caller='N/A' then caller=''
  end
  if symbol('_fmtheader') <> 'VAR' then _fmtheader=''
  if symbol('_fmtheader2')<> 'VAR' then _fmtheader2=''
  if symbol('_fmtfooter') <> 'VAR' then _fmtfooter=''
  _screen.TopRow=2
  _screen.footer=_fmtFooter
  _screen.message=1
return FMTLIST(,,_fmtHeader,_fmtheader2,caller)
