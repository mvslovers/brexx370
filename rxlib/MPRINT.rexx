mprint: procedure expose buffer. mtitle.
 parse arg tk,cmt,desc,half
 if datatype(tk)<>'NUM' then return 4
 if SYSVAR('SYSENV')='BATCH' then batch=1
    else batch=0
 tk=tk%1
 before=5
 after=5
 call mproperty(tk)
 col=_cols.tk%1
 row=_rows.tk%1
 if batch=1 & col>8 then after=2
 if half<>""& col=row then half=1
    else half=0
 if half=1 then do
    before=2
    after=4
 end
 nwidth=before+after+1
 if datatype(buffer.0) <> 'NUM' then buffer.0=0
 bi=buffer.0
 CALL _PUSHB copies('-',72)
 CALL _PUSHB 'Matrix 'cmt'('tk') Dimension rows x columns 'row' x 'col': 'desc
 CALL _PUSHB copies('-',72)
 header=''
 if symbol("mtitle."tk.1)='VAR' then do
    do j=1 to min(col,15)
       header=header||center(mtitle.tk.j,nwidth)' '
    end
 end
 else do
    do j=1 to min(col,15)
       header=header||center("("j")",nwidth)' '
    end
 end
 if row>100 then do
    call _printM 1,50,row
    CALL _PUSHB '...'
    CALL _PUSHB '...'
    call _printM row-100,row,row
 end
 else call _printM 1,row,row
 buffer.0=bi
 return
 _printM:
  nlen=1+log10(arg(3))%1
  mlen=0
  if mtitle.tk.0>0 then do i=1 to mtitle.tk.0
     mlen=max(mlen,length(mtitle.tk.i))
  end
  if mlen>0 &cmt='' then hlen=nlen+mlen
     else hlen=nlen+length(cmt)
  CALL _PUSHB copies(' ',hlen+3)header
  do i=arg(1) to arg(2)
     line=left(i,nlen)
     if cmt=''& mlen>0 then line=line' 'left(mtitle.tk.i,mlen)'|'
        else line=line' 'cmt'|'
     do j=1 to min(col,250)
       if half=1 then if j>i then leave
       fval=round(mget(tk,i,j),6)
     /* line=line||format(fval,10,10)' '  */
       if abs(fval)<100000 then line=line||format(fval,before,after)' '
       else line=line||right(format(fval,2,before+after-5,2),before+after+1)' '
     end
     CALL _PUSHB line
  end
return
_PushB:
 if batch=1 then do
    if length(arg(1))>117 then say left(arg(1),117)
       else say arg(1)
    return
 end
 bi=bi+1
 buffer.bi=arg(1)
return
