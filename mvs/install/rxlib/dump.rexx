/* -------------------------------------------------------------------
 * translate input into dump format (just in case needed)
 *   1. line : character representation of byte (if possible)
 *   2. line : first half byte
 *   3. line : second half byte
 * Lines are split after 32 characters
 * -------------------------------------------------------------------
 */
DUMP: procedure
parse arg iline,hdr,storadr
 if hdr='' then hdr='Dump Output'
 xline=c2x(iline)         /* translate String into Hex format */
 dump1=dumpline(xline,1)  /* concatenate odd half bytes       */
 dump2=dumpline(xline,2)  /* concatenate even half bytes      */
 len=length(dump1)
 iline=translate(iline,'.','0'x)
 say hdr
 if storadr='' then do
    do i=1 to len by 32      /* Output lines in 32 byte portions */
       say rdech(i-1,4,'0')'  'formatd(substr(iline,i,32))
       say rdech(i-1,4,'0')'  'formatd(substr(dump1,i,32))
       say rdech(i-1,4,'0')'  'formatd(substr(dump2,i,32))
       say ' '
    end
 end
 else do
    do i=1 to len by 32      /* Output lines in 32 byte portions */
       haddr=right(d2x(storadr+i-1),8,'0')
       say haddr' +'rdech(i-1,4,'0')'  'formatd(substr(iline,i,32))
       say haddr' +'rdech(i-1,4,'0')'  'formatd(substr(dump1,i,32))
       say haddr' +'rdech(i-1,4,'0')'  'formatd(substr(dump2,i,32))
       say ' '
    end
 end
return 0
/* -------------------------------------------------------------------
 * Create Offset Decimal and Hex
 * -------------------------------------------------------------------
 */
rDech:
 rdec=right(arg(1),4,'0')
 rhex=right(d2x(rdec),4,'0')
return rdec'('rhex')'
/* -------------------------------------------------------------------
 * Split Line in 4 Byte portions
 * -------------------------------------------------------------------
 */
formatD: procedure
 fline=copies('    ',12)
 ovl=1
 do k=1 to 32 by 4
    fline=overlay(substr(arg(1),k,4),fline,ovl)
    ovl=ovl+5
    if k=13 then ovl=ovl+2
 end
 xline=translate(fline,'.','15'x)
return xline
/* -------------------------------------------------------------------
 * Return either odd or even String part
 *   odd (=1): byte1byte3byte5...
 *   even(=2): byte2byte4byte6...
 * -------------------------------------------------------------------
 */
dumpline: procedure
 pline=''
 len=length(arg(1))
 do i=arg(2) to len by 2
    pline=pline''substr(arg(1),i,1)
 end
return pline
