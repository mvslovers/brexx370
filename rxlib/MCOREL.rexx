Mcorel: Procedure expose buffer. expose mtitle.
 parse arg data,dbg
 if dbg=1 then call mprint data,'scal','Data Matrix'
 call mproperty(data)
 cols=_cols.data%1
 rows=_rows.data%1
 m1=mnormalise(data,'STANDARD')
 if dbg=1 then call mprint m1,'m1','Normalised'
 m2=mtranspose(m1)
 if dbg=1 then call mprint m2,'m2','Transposed'
 m3=mmultiply(m2,m1)
 call MFree(m1,'FLOAT')
 call MFree(m2,'FLOAT')
 if dbg=1 then call mprint m3,'mult','Trans x Org'
 m4=mscalar(m3,1/(rows-1))
 call MFree(m3,'FLOAT')
 if dbg=1 then call mprint m4,'scal','Correlation Matrix'
return m4
