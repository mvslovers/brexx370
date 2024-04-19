/* -----------------------------------------------------------------
 * Displaying a predefined Sticky Note
 * -----------------------------------------------------------------
 */
stickysh:
  parse upper arg exec
  callError=0
  if substr(exec,1,2)<>'ST' then rexec='ST'exec
  else rexec=exec
  lrc=load(rexec)
  if lrc>0 then do
     call setg('STICKY_'rxec,-1)
     zerrlm='*** 'exec' Error'
     zerrsm='*** 'exec' Error'
     callError=1
     return 8
  end
  interpret 'rc='rexec'()'
  sticky.errormsg=exec' started'
return 0
