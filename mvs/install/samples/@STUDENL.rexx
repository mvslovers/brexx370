/* REXX */
offs=DCL('$INIT','student')
offs=DCL('ID',29,9)
offs=DCL('FName',,14)
offs=DCL('Sname',,14)
offs=DCL('Sex',,1)
offs=DCL('Birth',,12)
offs=DCL('Study',79,22)
offs=DCL('City',104,20)
offs=DCL('Street',124,25)
/*     */
offs=DCL('$INIT','StudentO')
offs=DCL('SName',1,14)
offs=DCL('Fname',,14)
offs=DCL('Sex',30,3)
offs=DCL('Birth',33,11)
offs=DCL('Study',44,22)
offs=DCL('City',67,20)
offs=DCL('Street',88,25)
 call open
 _screen.preset='_ '
 /*
   %T  Plain text in Column position
   %F  Plain text in Column position
   /N  Switch to new Line
   /C  Switch to next Column
  */
 do forever
    frc=FMTCOLUM(2,'Student Information System',
                  ,'Last Name / Prefix ===>',
                  ,'First Name         ===>',
             ,'/C','Birth Date         ===>',
             ,'/N','Study              ===>',
        ,'/N','/N','City               ===>')
    if frc='F03' then leave
    if frc='F04' then leave
    if frc='F15' then leave
    if frc='F16' then leave
 
    sname=strip(translate(_screen.input.1,,'_'))
    fname=strip(translate(_screen.input.2,,'_'))
    birthd=strip(translate(_screen.input.3,,'_'))
    study=strip(translate(_screen.input.4,,'_'))
    city=strip(translate(_screen.input.5,,'_'))
 
    call readN sname,fname,birthd,study,city
    call fmtlist ,,hdr,copies('-',150)
 end
 call close
 return
/* ---------------------------------------------------------------------
 * READ all Records of a VSAM File
 * ---------------------------------------------------------------------
 */
open:
  ADDRESS TSO
 "ALLOC FILE(STUDENTM) DSN('BREXX.VSAM.STUDENTM') SHR"
 "VSAMIO OPEN STUDENTM (READ"
return
/* ---------------------------------------------------------------------
 * Read Student Records via Locate and NEXT
 * ---------------------------------------------------------------------
 */
ReadN:
parse upper arg prefix,firstn,birthi,studyi,cityi
 "VSAMIO LOCATE STUDENTM (KEY "prefix
  i=0
  Hdr=LEFT('First Name',14)
  Hdr=hdr''LEFT('Surname',14)
  Hdr=hdr''LEFT('Sex',4)
  Hdr=hdr''LEFT('Birth Date',11)
  Hdr=hdr''LEFT('Study',23)
  Hdr=hdr''LEFT('City',21)
  Hdr=hdr''LEFT('Address',25)
  do forever
    "VSAMIO READ STUDENTM (NEXT UPDATE VAR Student"
     if rc<>0 then leave
     call splitRecord 'Student',Student
     if prefix<>'' & abbrev(student,prefix)=0 then leave
     if firstN<>'' & abbrev(translate(sname),firstN)=0 then iterate
     if strip(fname)='' then iterate
     if birthd<>'' & pos(birthd,birth)=0 then iterate
     if studyi<>'' & pos(studyi,translate(study))=0 then iterate
     if cityi <>'' & pos(cityi,translate(city))=0 then iterate
     i=i+1
     buffer.i=setRecord(StudentO)
  end
  buffer.0=i
return
/* ---------------------------------------------------------------------
 * CLOSE VSAM Dataset
 * ---------------------------------------------------------------------
 */
close:
 "VSAMIO CLOSE STUDENTM"
 ADDRESS TSO
 "FREE FILE(STUDENTM)"
return 0
