/* REXX */
/* ---------------------------------------------------------------------
 * Initial Insert of Student Records
 * ---------------------------------------------------------------------
 */
ADDRESS TSO
"ALLOC FILE(STUDENTM) DSN('BREXX.VSAM.STUDENTM') SHR"
say 'ALLOC 'rc
/* ---------------------------------------------------------------------
 * OPEN VSAM Mode Update
 *  KEY Length = 8
 * ---------------------------------------------------------------------
 */
keylen=8
"VSAMIO OPEN STUDENTM (UPDATE"
say 'OPENM 'rc' Extended RC 'rcx
/* ---------------------------------------------------------------------
 * INSERT Records from Sequential Dataset
 * ---------------------------------------------------------------------
 */
vsin=open("'BREXX."Version()".SAMPLES(@VSAMDAT)'",'RT')
reci=0
record=read(vsin)   /* Drop first record, it is a comment line */
do i=1 until eof(vsin)
   record=read(vsin)
   if strip(record)='' then iterate
   fname=substr(record,10,28)
   sname=word(fname,1)
   cname=word(fname,2)
   key=translate(left(sname';'cname,28,'_'))  /* Key is upper case */
   call insert key,record
end
/* ---------------------------------------------------------------------
 * CLOSE VSAM Dataset
 * ---------------------------------------------------------------------
 */
"VSAMIO CLOSE STUDENTM"
say 'CLOSEM 'rc' Extended RC 'rcx
ADDRESS TSO
"FREE FILE(STUDENTM)"
say 'FREE 'rc
say 'Records Inserted 'reci
return 0
/* ---------------------------------------------------------------------
 * Insert new Key
 * ---------------------------------------------------------------------
 */
insert:
parse arg inkey,inrec
 inrec=inkey''inrec
 "VSAMIO READ  STUDENTM (KEY "inkey" UPDATE VAR CURREC"
  if rc=0 then do
     say inkey' Record already defined'
     say "'"currec"'"
  end
  else say inkey' Record not available, RC 'rc' Extended RC 'rcx
 "VSAMIO WRITE STUDENTM (KEY "inkey" VAR INREC"
  if rc<>0 then say inkey' Error during Insert'
  else do
     reci=reci+1
     say inkey' Record inserted, Count 'reci', RC 'rc' Extended RC 'rcx
  end
return rc
