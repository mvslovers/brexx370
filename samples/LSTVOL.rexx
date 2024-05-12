/* ------------------------------------------------------------
 * BREXX Application: start with Volume list, fetching
 *       DSN List, and have some line command e.g. EDIT
 * ------------------------------------------------------------
 */
call listvols 'STEM'
_sx=stem2s("Volumes.")
call sqsort(_sx)
buffer.0='ARRAY '_sx
_screen.footer='Line command S display datasets, X Details of Volume'
_screen.color.header1=#white
_screen.color.header2=#red
call fmtlist ,,copies(' ',20)'Volumes of your MVS3.8',
        'Volume  Unit Device','VOLUMES'
return 0
/* ------------------------------------------------------------
 * VOLUMES line command x for details of volume
 * ------------------------------------------------------------
 */
volumes_x:
  volname=word(arg(1),1)
  call listvol(volname)
 buffer.1="     Volume Name        "right(VOLNAME,8)
 buffer.2="            Type        "right(VOLTYPE,8)
 buffer.3="       Device Address   "right(VOLDEVICE,8)
 buffer.4="     Geometry"
 buffer.5="     --------"
 buffer.6="       Cylinders        "right(VOLCYLS,8)
 buffer.7="       Track Length     "right(VOLTRKLEN,8)
 buffer.8="       Tracks/Cylinder  "right(VOLTRKCYL,8)
 buffer.9="          Total Tracks  "right(VOLTRKS,8)
buffer.10="       Dir Blocks/Track "right(VOLDIRTRK,8)
buffer.11="           DSCBs/Track  "right(VOLDSCBTRK,8)
buffer.12="           DSCBS        "right(VOLDSCBS,8)
buffer.13="       Alternate Tracks "right(VOLALTTRK,8)
buffer.14='     Content'
buffer.15="     --------"
buffer.16="       Datasets         "right(VOLDSNS,8)
buffer.17="       Tracks allocated "right(VOLTRKALC,8)
buffer.18="       Tracks used      "right(VOLTRKUSED,8)
buffer.0=18
  _screen.color.header1=#white
  _screen.footer='F3 Return, F4 Quit'
  call fmtlist 0,,copies(' ',20)'Volume details of 'volname
return 0
/* ------------------------------------------------------------
 * VOLUMES line command s from volume list
 * ------------------------------------------------------------
 */
volumes_s:
  volname=word(arg(1),1)
  call vtoc(volname,'STEM')
  _sy=stem2s("Vtoc.")
  call sqsort(_sy)
  _sz=scopy(_sy,,,,2)
/*   Drop Catalog Check, is too slow!
  do si=1 to sarray(_sz)-1
     vtline=sget(_sz,si)
     dsn=word(vtline,1)
     trc=tstcat("'"dsn"'",volname)
     if trc=0 | trc=16 then call sconc(_sz,si,' CAT')
     else call sconc(_sz,si,' NCAT>'sysvolume)
  end
*/
  buffer.0='ARRAY '_sz
  _screen.color.header1=#white
  _screen.color.header2=#red
  _screen.footer='Line command S/E select DSN for editing, Z compressing DSN'
  call fmtlist ,,copies(' ',20)'Datasets of 'volname,vtoc.hdr,'UNIT'
return 0
/* ------------------------------------------------------------
 * VOLUME line command s from DSN list
 * ------------------------------------------------------------
 */
unit_e:
unit_s:
  dsn=word(arg(1),1)
  ADDRESS TSO "REVED '"dsn"'"
return 0
/* ------------------------------------------------------------
 * VOLUME line command z to compress DSN
 * ------------------------------------------------------------
 */
unit_z:
  dsn=word(arg(1),1)
  ADDRESS TSO "COMPRESSS '"dsn"'"
return 0
/* ------------------------------------------------------------
 * VOLUME line command x to show details of DSN
 * ------------------------------------------------------------
 */
unit_x:
  dsn=word(arg(1),1)

  call listdsix("'"dsn"'")
   buffer.1="    Dataset Name        "sysdsname
   buffer.2="       Volume           "sysvolume
   buffer.3="       Created          "date('European',syscreate+2000000,'Julian')
   buffer.4="       Last Referenced  "date('European',sysrefdate+2000000,'Julian')
   buffer.5="       DSORG            "sysdsorg
   buffer.6="       Record Format    "sysrecfm
   buffer.7="       Record Length    "syslrecl
   buffer.8="       Block Size       "sysblksize
   buffer.9="    Allocated Tracks    "systracks
  if type(sysntracks)<>'INTEGER' then sysntracks=0
  if type(systracks)<>'INTEGER'  then systracks=0
  buffer.10="       used Tracks      "systracks-sysntracks
  buffer.11="       Extents          "sysextents
  buffer.12="       DSN Size (KB)    "syssize%1024
  buffer.13="    Allocation Units    "sysunits
  buffer.14="    Directory Blocks    "sysdirblk
  buffer.15="       Member Count     "sysmembers
  buffer.16="       Records          "sysrecords
  buffer.0=16
  _screen.color.header1=#white
  _screen.footer='F3 Return, F4 Quit'
  call fmtlist 0,,copies(' ',20)'Datasets details of 'sysdsname
return 0
