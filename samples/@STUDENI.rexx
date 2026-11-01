/* REXX */
/* ---------------------------------------------------------------------
 * Initial Insert of Student Records
 * ---------------------------------------------------------------------
 */
/* ALLOCATE() works in a batch step without TSO; ADDRESS TSO "ALLOC"
 * would answer -3 there. It replaces a STUDENTM DD of the step. */
arc=allocate('STUDENTM',"'BREXX.VSAM.STUDENTM'")
say 'ALLOC 'arc
if arc<>0 then do
   say 'ALLOC of BREXX.VSAM.STUDENTM failed, RC 'arc
   return 8
end
/* ---------------------------------------------------------------------
 * OPEN VSAM Mode Update
 *  KEY Length = 8
 * ---------------------------------------------------------------------
 */
keylen=8
"VSAMIO OPEN STUDENTM (UPDATE"
say 'OPENM 'rc' Extended RC 'rcx
if rc<>0 then do
   orc=rc
   call free 'STUDENTM'
   return orc
end
/* ---------------------------------------------------------------------
 * INSERT Records from Sequential Dataset
 * ---------------------------------------------------------------------
 */
parse value version() with version'('dev')'
if dev<>'' then version=version'M0'
dsn=MVSVAR('REXXDSN')'(#VSAMDAT)'
vsin=open("'"dsn"'",'RT')
reci=0
record=read(vsin)   /* Drop first record, it is a comment line */
do i=1 until eof(vsin)
   record1=read(vsin)
   record2=read(vsin)
   /* the layout (DCL in @STUDENL) needs record1 at exactly 50 bytes */
   record = left(record1,50)||strip(record2,'T')
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
frc=free('STUDENTM')
say 'FREE 'frc
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
