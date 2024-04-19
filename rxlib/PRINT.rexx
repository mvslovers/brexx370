/* ---------------------------------------------------------------------
 * PRINT main procedure
 *  .............................. Created by PeterJ on 05. January 2022
 *  Manages print into SYSOUT class. Page size is 60 lines, line size 132
 *  if writing a line which exceeds page size a page break occurs and the
 *  title line is printed, if a label $PRINT_header: is defined it is called
 *  as call-back. Additional lines can be output (using the PRINT command)
 *  as heading lines (appearing after each page break)
 *
 *
 *  PRINT $ONTO,sysout-class       Define and open PRINT stream
 *  PRINT <action,>line-to-print   print line (according to print action)
 *  PRINT $TITLE,title-line        define title line, printed on new page
 *  PRINT $PAGE                    skip to next page, print page headers
 *  PRINT $BANNER,text             PRINT banner page
 *  PRINT $CLOSE                   close print stream
 *
 * action:                         print action of each line
 *  $SKIP                          add empty line and print
 *  $NOSKIP                        print on same line (no line feed)
 *  $BOLD                          print bold line (print it twice)
 * ---------------------------------------------------------------------
 */
print: procedure
  parse arg line,txt
  lrecl=123
  if substr(line,1,1)<>'$' then call print_line
  else do
     if line=='$ONTO' then do
        rc=PRINT_alloc(substr(txt,1,1))
        if rc<>0 then call stop 'PRINT allocation failed, rc='rc,8
     end
     else if line=='$CLOSE'  then call PRINT_close
     else if line=='$TITLE'  then call setg('1403_printer_title',txt)
     else if line=='$EJECT'  then call newPage
     else if line=='$PAGE'   then call newPage
     else if line=='$HEADER' then call header
     else if line=='$BANNER' then do
        banner=txt
        call print_native ' '
        call prtbannr banner
        call print_native ' '
     end
     else call print_line   /* print line it is $KIP, $BOLD, ...  */
  end
return
/* ---------------------------------------------------------------------
 * PRINT single line
 * ---------------------------------------------------------------------
 */
print_native:
  parse arg line,txt
print_line:
  sysprint=getg('1403_printer')
  if sysprint='' then call stop 'PRINT not initialised, use <PRINT $ONTO print-class>'
  if getg('1403_printer_page_number')=0 then call pagebreak 0   /* initial page break */
  ctl=' '
  bold=0
  pageoff=getg('1403_printer_page_lino')
  if datatype(pageoff)<>'NUM' then pageoff=0
  if line='$SKIP' then do
     ctl='0'
     pageoff=pageoff+1
  end
  else if line='$NOSKIP' then do
     ctl='+'
     pageoff=pageoff-1
  end
  else if line='$BOLD' then bold=1
  pageoff=pageoff+1
  if pageoff>60 then call pagebreak 1    /* subsequent page break */
  if ctl<>' ' | bold=1 then line=txt
  sysprint=getg('1403_printer')
  if length(line)>lrecl then line=left(line,lrecl)
  call write(sysprint,ctl||line,'nl')
  if bold=1 then call write(sysprint,'+'||line,'nl')
  call setg('1403_printer_page_lino',pageoff)
return
/* ---------------------------------------------------------------------
 * PRINT switch header call ON/OFF
 * ---------------------------------------------------------------------
 */
header:
  if translate(txt)=='OFF' then call setg('1403_printer_page_header',0)
  else if translate(txt)=='ON' then call setg('1403_printer_page_header',1)
return
/* ---------------------------------------------------------------------
 * PRINT page break occured
 * ---------------------------------------------------------------------
 */
newpage:
  sysprint=getg('1403_printer')
  call setg('1403_printer_page_lino',0)
pagebreak:
  title=getg('1403_printer_title')
  page=getg('1403_printer_page_number')
  page=page+1
  page=setg('1403_printer_page_number',page)
  title=changestr("&page",title,page)
  call write(sysprint,'1'title,'nl')      /* write top title line         */
  pageoff=0                               /* reset line in page           */
  call setg('1403_printer_page_lino',pageoff)
  callback=getg('1403_printer_callback')  /* is there a header call back? */
  if getg('1403_printer_page_header')=0 then callback=-1 /* suppress call */
  if callback=0 then call $PRINT_header   /* if yes, run it               */
  else if callback='' then do             /* not yet checked              */
     if tryheader('$PRINT_header')=64 then call setg('1403_printer_callback',-1)
     else call setg('1403_printer_callback',0)
  end
  ctl=' '                             /* reset control char after page break */
  pageoff=getg('1403_printer_page_lino')
  if arg(1)>0 then pageoff=pageoff+1  /* if not initial break it is +1 */
return
/* ---------------------------------------------------------------------
 * PRINT close print file
 * ---------------------------------------------------------------------
 */
PRINT_close:
  saddr=address()
  if saddr<>'TSO' then ADDRESS TSO
  sysprint=getg('1403_printer')
  if sysprint>0 then do
     call close(sysprint)
    'FREE ATTR(@SYSTMP)'
    'FREE DD(SYSOUT)'
  end
  call setg('1403_printer_page_lino',0)
  call setg('1403_printer',-1)
  if saddr<>address() then interpret 'ADDRESS 'saddr
return 0
/* ---------------------------------------------------------------------
 * PRINT allocate print sysout class and file
 * ---------------------------------------------------------------------
 */
PRINT_alloc:
  parse arg class
  call PRINT_close
  saddr=address()
  if saddr<>'TSO' then ADDRESS TSO
 'ATTR @SYSTMP RECFM(V B A) LRECL(123) BLKSIZE(4096) DSORG(PS)'
  if rc>0 then do   /* retry to de-allocate, maybe last call aborted */
    'FREE ATTR(@SYSTMP)'
    'FREE DD(SYSOUT)'
    'ATTR @SYSTMP RECFM(V B A) LRECL(123) BLKSIZE(4096) DSORG(PS)'
     if rc>0 then return 16
  end
 'ALLOC DD(SYSOUT) SYSOUT('class') USING(@SYSTMP)'
  if rc>0 then return 12
  sysprint=open('SYSOUT','WT')
  if sysprint<=0 then return 8
  call setg('1403_printer',sysprint)
  call setg('1403_printer_page_number',0)
  if saddr<>address() then interpret 'ADDRESS 'saddr
return 0
/* ---------------------------------------------------------------------
 * Try to run a call back rexx
 * ---------------------------------------------------------------------
 */
tryheader:
  signal on syntax name noheader
  interpret 'call 'arg(1)
  signal off syntax
return result
/* ---------------------------------------------------------------------
 * Error Exit, if called Rexx is not available
 * ---------------------------------------------------------------------
 */
noheader:
  signal off syntax
return 64
