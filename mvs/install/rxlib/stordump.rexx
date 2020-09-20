/* -------------------------------------------------------------------
 * Output storage area in dump format
 * -------------------------------------------------------------------
 */
stordump: procedure
parse arg addr,storlen,hdr
 if storlen='' then storlen=4
 if storlen<=0 then storlen=4
 if datatype(storlen)<>'NUM' then storlen=4
 dumpline=storage(addr,storlen)
 call Dump dumpline,hdr,addr
return 0
