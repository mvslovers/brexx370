/* ------------------------------------------------------------------
 * RXDIFF Compare 2 datasets to find the changes
 *        RXDIFF new-file,old-file,[display-type],[DETAILS]
 *    display-type : ALL     show all lines (changed/deleted/unchanged
 *                 : CHANGES show just changed/deleted lines
 *    DETAILS      : show progress of comparison
 * ------------------------------------------------------------------
 */
rxdiff:
  parse upper arg file1,file2,prmode,details
  if details='DETAILS' then details=1
  else details=0
  s6=Screate(100)                  /* create output area (will be extended) */
  call DIFSAYMSG 1,'Compare 'file1' with 'file2
  s1=sread("'"file1"'")                /* s1  contains new source file */
   if s1<0 then call error file1' not present'
   call DIFSAYMSG 2,'Dataset 'file1' read, 'sarray(s1)' lines read'
  s2=sread("'"file2"'")                /* s2  contains old source file */
  if s2<0 then call error file2' not present'
   call DIFSAYMSG 2,'Dataset 'file2' read, 'sarray(s2)' lines read'
  call setupArrays                   /* Create all subsequent arrays */
   call DIFSAYMSG 2,'Start Compare process'
  call diff(i11,i12,s3,i31)    /* determine differences of new and old file */
   call DIFSAYMSG 2,'Compare process ended, differences determined'
  call ProcessSequences        /* process all sequences, the largest first  */
   call DIFSAYMSG 2,'Sequences analysed'
   call sdrop(s5,'')         /* Cleanup old buffer copy, just deleted remain */
  call generateSummary prmode          /* Generate Compare Output */
   call DIFSAYMSG 2,'Summary produced'
  call cleanupArrays                   /* cleanup Arrays          */
   call DIFSAYMSG 2,'Cleanup completed'
  call DIFSAYMSG 1,'Compare completed 'file1' with 'file2
return s6
/* ------------------------------------------------------------------
 * Find changed lines update largest common sequence
 * ------------------------------------------------------------------
 */
diff: procedure expose details s6 otime.
  parse arg new,old,rule,rulei
  do idf=1 while idf<iarray(NEW)
     soff=0
     do until soff=0
     /* find line(i) new in old and count next identical lines */
        soff=findandCount(idf,soff)      
        /* set in findandCount, if large amounts found, just take them */
        if foundlct<6  then iterate      
        call DIFSAYMSG 3,'Large overlap found 'foundlct' lines'
        idf=idf-1+foundlct               /* set to next inspection line */
        leave
     end
  end
return
/* ------------------------------------------------------------------
 * Find line in old file, and continue if subsequent lines match
 * ------------------------------------------------------------------
 */
findandCount:
  parse arg is,nssi
  isc=is
  lct=0
  foundlct=0
  line1=iget(NEW,isc)
  ssi=isearch(OLD,line1,nssi+1) /* search line(new) in old */
  if ssi=0 then return 0     /* if not found, return 0, no subsequent search */
  lct=lct+1                     /* +1 for equal line counter */
  /* now, continue with subsequent lines anc check if they are equal */
  do j=ssi+1 to iarray(OLD)     
     isc=isc+1
     if icmp(new,isc,old,j)=0  then do /* Does next line match      */
        tto=j                           /* if yes, set new to range  */
        lct=lct+1                       /* +1 for equal line counter */
     end
     else do               /* no, set counters to last matching line */
        isc=isc-1
        j=j-1
        leave              /* and leave  */
     end
   end
   if j>iarray(OLD) then j=j-1
   ssold=sget(rule,is)
   call maintCounter /* update counters if greater than */
   foundlct=lct
return ssi
/* ------------------------------------------------------------------
 * Maintain counters in Rule array
 * ------------------------------------------------------------------
 */
maintCounter:
  if ssold='' then call setrule
  else do
     olct=Iget(rulei,is)
     if lct>olct then call setRule
     else if olct=1 then call setRule
     /* if there are more than one match, only the first one is needed
      * as it is the "closest" occurrence
      * else say 'added 'ssold';; 'is'>'isc':'lct'+found'ssi'<='j
      */
  end
return
setrule:
  call sset(rule,is,is'>'isc':'lct'+'ssi'<='j)
  call Iset(rulei,is,lct)
return
/* ------------------------------------------------------------------
 * Process the sequences as built Rule array
 * ------------------------------------------------------------------
 */
processSequences:
  do while findLargestSequence()>0
     call Second_Pointer_etc
  end
return
/* ------------------------------------------------------------------
 * Find largest common sequence
 * ------------------------------------------------------------------
 */
findLargestSequence:
  mcount=0
  i=0
  do forever
      /* find next non null entry in the rules count array */
     i=isearchnn(i31,i+1)          
     if i=0 then leave
     count=Iget(i31,i)             /* read rule count  */
     if count<=mcount then iterate /* if LE then current highest, loop */
     rule=sget(s3,i)               /* read rule */
     if rule='' then iterate
     parse var rule from1'>'tto1':'count'+'from2'<='tto2
     if count<mcount then iterate
     mcount=count
     mfrom1=from1
     mfrom2=from2
     mfrom2s=from2
     mtto1 =tto1
     mtto2 =tto2
  end
return mcount
/* ------------------------------------------------------------------
 * Generate Change Summary of new/old FILE
 * ------------------------------------------------------------------
 */
generateSummary:
  parse upper arg smode
  id=0
  inserted=0
  deleted =0
  moved   =0
  call sset(s6,,'Differences of 'file1'(new) with 'file2'(old)')
  call getnextDel
  do i=1 to sarray(s1)
     line=sget(s1,i)
     onum=sget(s4,i)
     if onum='' then do
        call sset(s6,,right(i,5,'0')'  **ins   'line)
        inserted=inserted+1
     end
     else if smode='ALL' then do
          call sset(s6,,right(i,5,'0')'  'right(onum,5,'0')'   'line)
          if i<>onum then moved=moved+1
     end
     if datatype(onum)<>'NUM' then iterate
     do while onum+1=delnum
        call sset(s6,,'**del  'right(delnum,5,'0')'   'delstr)
        deleted=deleted+1
        if getnextDel()>0 then leave
        onum=onum+1
     end
  end
  call sset(s6,,'deleted  lines 'deleted)
  call sset(s6,,'inserted lines 'inserted)
  call sset(s6,,'moved    lines 'moved)
return
/* ------------------------------------------------------------------
 * Clear second/third largest sequences if comprised by first!
 * set Pointer new to old file
 * ... and some cleanup
 * ------------------------------------------------------------------
 */
Second_Pointer_etc:
  do j=mfrom1+1 to mtto1  /* clear second, third largest */
     call sset(s3,j,'')
  end
  do j=mfrom1 to mtto1    /* set pointer to old file */
     call sset(s4,j,mfrom2)
     mfrom2=mfrom2+1
  end
  call sset(s3,mfrom1,'') /* reset, all done */
  do j=mfrom2s to mtto2   /* clear lines from old, if in new */
     call sset(s5,j,'')
  end
return
/* ------------------------------------------------------------------
 * Retrieve next deleted line of old file
 * ------------------------------------------------------------------
 */
getnextDel:
  id=id+1
  delline=sget(s5,id)
  delnum=word(delline,1)
  if delnum='' then return 4
  delstr=subword(delline,2)
return 0
/* ------------------------------------------------------------------
 * Cleanup Arrays
 * ------------------------------------------------------------------
 */
cleanupArrays:
  call sfree(s1)
  call sfree(s2)
  call sfree(s3)
  call sfree(s4)
  call ifree(i11)
  call ifree(i12)
  call ifree(i31)
return
/* ------------------------------------------------------------------
 * Setup all subsequent Arrays
 * ------------------------------------------------------------------
 */
difsayMSG:
  parse arg level,rxmsg
  if details<>1 then return
  if datatype(otime.level)<>'NUM' then do
     lv=level-1
     if lv>0 & datatype(otime.lv)='NUM' then 
         otime.level=round(time('ms')-otime.lv,3)
     else otime.level=0
  end
  else otime.level=round(time('ms')-otime.level,3)
  otime.level=format(otime.level,3,3)
  call sset(s6,,left(time('L'),12)' 'right(otime.level,7)'  'rxmsg)
  otime.level=time('ms')     /* keep old 'start time' */
return
/* ------------------------------------------------------------------
 * Setup all subsequent Arrays
 * ------------------------------------------------------------------
 */
setupArrays:
   /* s6  Result array to be displayed with fmtlist  */
  s6a=screate(sarray(s1)+sarray(s2))      
  do s6i=1 to sarray(s6)
     call sset(s6a,,sget(s6,s6i))
  end
  call sfree s6
  s6=s6a
  call SSUBSTR(s1,1,72,'INTERNAL')
  call SSUBSTR(s2,1,72,'INTERNAL')
  i11=s2Hash(s1)                    /* i11 contains the hash values of new */
  i12=s2Hash(s2)                    /* i12 contains the hash values of old */
  call DIFSAYMSG 2,'Datasets Hashes created'
 /* s3 (rules) reference of new to old line, including number of equal lines */
  s3=screate(max(sarray(s1),sarray(2))) 
  /* i31 the count part of the s3 rules, performs better    */
  i31=icreate(max(sarray(s1),sarray(2)))
  /* s4  refers old to new line, to determine deleted lines */
  s4=screate(max(sarray(s1),sarray(2))) 
  /* s5  is s2, including line number as prefix             */
  s5=scopy(s2)                          
  call snumber(s5,5)                    /*     attach line numbers  */
  call DIFSAYMSG 2,'Temporary Arrays created'
return
