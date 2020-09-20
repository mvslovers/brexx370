/* ---------------------------------------------------------------------
 * DYNALLOC ALLOC/FREE/DELETE Datasets
 * .............................. Created by PeterJ on 26. February 2019
 * ---------------------------------------------------------------------
 */
rxDYNALC: Procedure expose RXDYNMSG RXMSLV mslv mstx msln msno maxrc
 parse upper arg inparm
 call initDYNALC inparm
 if func='FREE' then func='UNALLOC'
 if abbrev('DELETE',func,2)=1 then rxrc=_rxDEL(p0)
 else rxrc=_rxStandard()
 rxdynmsg=rxdmsg(rxrc)
return ccod                  /* set in RXDYNMSG */
/* ---------------------------------------------------------------------
 * ALL Standard DYNAM Calls
 * ---------------------------------------------------------------------
 */
_rxStandard:
  if noprint='PRINT' then say '>>> RXDYNAMA,'dynparm
  ADDRESS SYSTEM
  "RXDYNAMA "dynparm
return rc
/* ---------------------------------------------------------------------
 * Delete FILE
 * ---------------------------------------------------------------------
 */
_rxDel:
  parse arg dsn
  ddname='RXD'right(random(1,99999),2,'0')
  if noprint='PRINT' then ,
     say '>>> RXDYNAMA 'noprint',ALLOC,DD='ddname',DSN='dsn',OLD '
 ADDRESS SYSTEM
 "RXDYNAMA "NOPRINT',ALLOC,DSN='dsn',OLD ,DD='ddname
 if rc>0 then return 132
 IF noprint='PRINT' THEN say '>>> UNALLOC,DSN='dsn' DELETE'
 ADDRESS SYSTEM
 "RXDYNAMA "NOPRINT',UNALLOC,DSN='dsn' DELETE'
 if rc=0 then return 140
return 136
/* ---------------------------------------------------------------------
 * Conc all parms
 * ---------------------------------------------------------------------
 */
 conc:
 if arg(2)='FREE' then dynparm=arg(1)',UNALLOC'
    else dynparm=arg(1)','arg(2)
 ddn=''
 dsn=''
 DDC='DD='
 DSC='DSN='
 maxct=arg()
 do ci=3 to maxct
    iparm=arg(ci)
    if iparm='' then iterate
    if pos(dsc,iparm)>0 then dsn=iparm
    else if pos(ddc,iparm)>0 then ddn=iparm
    dynparm=dynparm','arg(ci)
 end
 dynparm=dynparm'  '
 return
/* ---------------------------------------------------------------------
 * Init Procedure
 * ---------------------------------------------------------------------
 */
initdynalc:
 parse upper arg fnc
 parse var fnc func','p0','p1','p2','p3','p4',
                     'p5','p6','p7','p8','p9','p10
/* ... Check if PRINT/NOPRINT option is requested ... */
 noprint=''
 if abbrev('NOPRINT',func,3)=1 then noprint='NOPRINT'
 else if abbrev('XPRINT',func,3)=1 then noprint='XPRINT'
 else if abbrev('PRINT',func,3)=1 then noprint='PRINT'
/* ... re-evaluate parms, if 1. parm is print/noprint */
 if noprint='' then noprint='PRINT'
 else parse var fnc prefx','func','p0','p1','p2','p3','p4',
                                 'p5','p6','p7','p8','p9','p10
/* ... Perform requested Dynalloc Function  ... */
    call conc noprint,func,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9
return
/* ---------------------------------------------------------------------
 * Test Dynalloc Return Code
 * ---------------------------------------------------------------------
 */
rxdmsg:
 parse arg num
 SELECT
  when num=0 then 
     RC=RXMSG(0,'I',func' SUCCESSFULL COMPLETION: 'ddn', 'dsn)
  when num=4 then 
     RC=RXMSG(8,'E',func' FAILED: 'DDN', 'dsn)
  when num=8 then 
     RC=RXMSG(12,'E','REQUEST DENIED BY MVS VALIDATION ROUTINE')
  when num=12 then RC=RXMSG(13,'E','INVALID PARAMETER LIST')
  when num=16 then RC=RXMSG(16,'E',func' INVALID VERB')
  when num=20 then RC=RXMSG(20,'E','INVALID KEYWORD')
  when num=24 then RC=RXMSG(24,'E','WORK AREA OVERFLOW')
  when num=28 then 
     RC=RXMSG(28,'E','VALUE NOT FOUND IN SUBTABLE: INVALID VALUE')
  when num=124 then 
     RC=RXMSG(124,'E','EITHER DSN OR FILE KEYWORD MUST BEDEFINED')
  when num=128 then 
     RC=RXMSG(128,'E','PARAMETER CONTAIN INVALID VALUES')
  when num=132 then 
     RC=RXMSG(132,'E','CAN NOT ACQUIRE ALLOCATION WITH DISP=OLD')
  when num=136 then RC=RXMSG(136,'E',dsn' DATASET NOT DELETED')
  when num=140 then RC=RXMSG(140,'I',dsn' DATASET DELETED')
  when num=150 then 
     RC=RXMSG(150,'W','FILE ALREADY ALLOCATED, ALLOCATION DENIED ',dd', 'dsn)
  when num=500 then RC=RXMSG(500,'E','INVALID DYNALLOC REQUEST')
  otherwise   RC=RXMSG(512,'E','UNKNOWN ERROR: 'num)
 END
 ccod=msrc    /* Returned from RXMSG */
return msln   /* Returned from RXMSG */
/* ---------------------------------------------------------------------
 * Address some MVS Control Blocks
 * ---------------------------------------------------------------------
 */
_tcb: return _adr(540)          /* TCB address at 540 = '21C'X of PSA */
_Tiot: return _adr(_tcb()+12)   /* TIOT address at TCB + 12   */
_adr: return c2d(storage(arg(1),4))       /* return pointer (decimal) */
