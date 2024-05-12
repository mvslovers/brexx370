REGRESSN: Procedure expose buffer. _Regression.
  parse arg data,y,debug
  datax=MINSCOL(data,1)
     if debug <>'' then call mprint(datax,'data+',"Data+ extended Matrix")
  call mproperty(datax)
  col=_cols.datax%1
  row=_rows.datax%1
  nv=col
  data0=Mnormalise(datax,'L')
  y0   =Mnormalise(y,'L')
     if debug <>'' then call mprint(data0,'data+',"Data+ normalised Matrix")
     if debug <>'' then call mprint(y0,'y+',"Y+ normalised Matrix")
  yrowf=_rowfactor.y0.1
  do i=1 to nv
     xrowf.i=_rowfactor.data0.i
  end
  call mfree(datax,'MATRIX')
  data0T=Mtranspose(data0)
  dconv=mmultiply(data0T,data0)
     if debug <>'' then call mprint(dconv,"INV","Extended Covariance Matrix")
  dcinv=minvert(dconv)
     if debug <>'' then 
         call mprint(dcinv,"COV INV","Inverted Covariance Matrix")
  yy=mmultiply(data0t,y0)
  call mfree(data0T,'MATRIX')
  call mfree(data0,'MATRIX')
  if debug<>'' then call mprint(yy,"D'*Y","D'*Y Results")
  m5=mmultiply(dcinv,yy)
  call mfree(y0,'MATRIX')
  call mfree(yy,'MATRIX')
  call mfree(dcinv,'MATRIX')
  call mfree(dconv,'MATRIX')
     do i=1 to nv
        _regression.i=yrowf*mget(m5,i,1)/xrowf.i
     end
     _regression.0=nv
  call mfree(m5,'MATRIX')
return 0
