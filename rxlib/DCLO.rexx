/* ---------------------------------------------------------------------
 * Create Structure for File Records
 *  n=DCL("$DEFINE",structure-name,<field-prefix>)
 *    $INIT          Initialise the structure
 *    structure-name Name of the structure, you may have more than one
 *    field-prefix   prefix which is put in from of any field-name
 *  n=DCL(fieldname,record-offset,field-length)
 *    field-name     name of REXX Variable
 *    record-offset  offset of field in Record (normally start with one)
 *                   defaults to next byte in Record, calculated by last
 *                   record-offset+last field-length
 *    field-length   length of field
 *  call splitRecord structure-name,record-to-split
 *    structure-name Name of the structure to be used for split
 *    structure-name all fields defined within the structure a receiving
 *                   the contents from the defined offset/length
 *    record-to-split record used to split
 *  call setRecord structure-name
 *    structure-name used to build a new record, all fields defined
 *                   within the structure are used to fill their content
 *                   to the appropriate position and length
 * This definition creates the split field statments, as well as the
 * combine to a new record statements.
 *
 *
 * Example:
 *  n=DCL('Name',1,32)
 *  n=DCL('FirstName',1,16)
 *  n=DCL('LastName',,16)
 *  n=DCL('Address',,32)
 * ............................. Created by PeterJ on 27. September 2019
 * ---------------------------------------------------------------------
 */
/* ---------------------------------------------------------------------
 * Create Structure for File Records
 * ---------------------------------------------------------------------
 */
dcl:
  parse upper arg _field,_off,_len,_ftype
  if _field='$DEFINE' then return _dclinit(_off,_len)
  if _field='$INIT'   then return _dclinit(_off,_len)
  if _off='' then _off=$dcldef.$actvedcl.offset
  if _len='' then _len=0
  if _ftype='' then _ftype='CHAR'
  _ftype=substr(_ftype,1,1)
  _nxt=_off+_len
  _ff=$actveprf''_field
  $dcldef.$actvedcl.$set=,
     $dcldef.$actvedcl.$set'_recrd=overlay('_ff',_recrd,'_off','_len');'
  $dcldef.$actvedcl.$parse= ,
     $dcldef.$actvedcl.$parse' '_off' '_ff' '_nxt' .'
  $dcldef.$actvedcl.offset=_nxt
  if _ftype='C' then return _nxt    /* Type = CHAR   */
  if _ftype='P' then do             /* Type = PACKED */
     $dcldef.$actvedcl.$pre= ,
  $dcldef.$actvedcl.$pre''_ff'=d2p('_ff');'
     $dcldef.$actvedcl.$post= ,
  $dcldef.$actvedcl.$post''_ff'=p2d('_ff');'
  end
  if _ftype='B' then do             /* Type = PACKED */
     $dcldef.$actvedcl.$pre= ,
  $dcldef.$actvedcl.$pre''_ff'=d2c('_ff','_len');'
     $dcldef.$actvedcl.$post= ,
  $dcldef.$actvedcl.$post''_ff'=c2d('_ff');'
  end
return _nxt
/* ---------------------------------------------------------------------
 * Init Structure
 * ---------------------------------------------------------------------
 */
_dclinit:
  parse upper arg _dclname,_prefx
  drop $dcldef._dclname.
  $actvedcl=_dclname
  $actveprf=_prefx
  $dcldef._dclname.offset=1
  $dcldef._dclname.$parse=''
  $dcldef._dclname.$set=''
  $dcldef._dclname.$pre='nop;'
  $dcldef._dclname.$post='nop;'
return 1
/* ---------------------------------------------------------------------
 * Split Record (read by READ) in defined fields
 * ---------------------------------------------------------------------
 */
splitRecord:
  parse arg __dcln,__recin
  __dcln=translate(__dcln)
  interpret 'parse Var __recin '$DCLDEF.__dcln.$parse
  interpret $DCLDEF.__dcln.$post
return
/* ---------------------------------------------------------------------
 * Create Record from Defined Variables
 * ---------------------------------------------------------------------
 */
setRecord:
  parse upper arg __dcln
  _recrd=copies('           ',15)
  interpret $DCLDEF.__dcln.$pre
  interpret $DCLDEF.__dcln.$set
return strip(_recrd,'T')
