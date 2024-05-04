Array functions
===============

The BREXX Array functions are an implementation outside the REXX standard. They 
allow more direct access to array's items than compound variables (stems). The 
definition overhead is also negligible, allowing larger arrays as with stems. 
For performance reasons, the internal checking of boundaries, limits and content
is kept at a basic level, if exceeded the REXX script will most likely end with 
a 0C4. 

String Array Functions
----------------------

Why String Arrays? There is a performance and storage overhead with stems, the
stem name must be in a binary tree before the contents can be read. The 
allocation for content also contains a reserve in case a new version is a bit 
longer to avoid reallocation of the memory.

String Arrays have a pointer array addressing each content directly, adding a 
new item is therefore 2 times faster than in a stem, reading about 5 times 
faster. Another benefit is that you can easily add low-level functions (written
in C) to work on the arrays directly. `SQSORT`, `SHSORT`, `SSEARCH`, `SSELECT` 
are some examples.  

Managing Source Arrays
~~~~~~~~~~~~~~~~~~~~~~

.. function:: SCREATE(size) 

    Creates a Source Array, returned is the Source Array Number, which must be 
    used in various Source Array functions. The size refers to the maximum 
    number of entries of the array. Exceeding the maximum might lead to an 0C4
    or other abends.

    Depending on virtual storage availability, you can have up to 32 different 
    arrays.

    For example, see SGET.

    :returns: the allocated array-number which can be used in subsequent array functions. 

.. function:: SSET(array-number,[item-index],string-value)

    Sets a particular element of the array with a string value. The item index 
    must not exceed the maximum size defined in the SCREATE function. If the 
    item-index is not specified, the entry is added at the end of the array. 

    The item index must not exceed the maximum size defined in the SCREATE 
    function. To minimise the overhead there is no checking of the limits in 
    place. Exceeding it will cause an 0C4. 

    For example, see SGET.

.. function:: SGET(array-number,item-index,[offset])
    
    Gets (returns) an element of the array as a string value. If an offset 
    is defined the returned value starts at it. 

    The item index must not exceed the maximum size defined in the SCREATE 
    function. To minimize the overhead there is no checking of the limits in
    place. Exceeding it will cause an 0C4. 

    .. code-block:: rexx
       :linenos:
    
       smax=15                                     
       s1=screate(smax)                            
       do i=1 to smax                              
          call sset(s1,i,right(i,3,'0')'. Record') 
       end                                         
       do i=1 to smax                              
          say sget(s1,i)                           
       end                                         

    Result::

        001. Record  
        002. Record  
        003. Record  
        004. Record  
        005. Record  
        006. Record  
        007. Record  
        008. Record  
        009. Record  
        010. Record  
        011. Record  
        012. Record  
        013. Record  
        014. Record  
        015. Record  

.. function:: SFREE(array-number,[KEEP]) 

    Removes the specified array and all its entries. All storage allocations
    are freed. If KEEP is specified all items are freed, but the array itself
    (array-number) remains allocated. 
    
    For example, see SWRITE.

Fast Compare and Swap Items 
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. function:: SSWAP(array-number,item-number-1, item-number-2)

    Swaps the position of 2 elements in the array. As only pointers are moved a
    very fast function.  

.. function:: SCLC(array-number,item-number-1, array-number-2, item-number-2)

    Compares 2 elements of the 2 arrays. SCLC is much faster than loading both 
    items and comparing it to the REXX level. To compare items within one array 
    just use for `array-number2` the value of `array-number-1`.


    :returns: 
        - <0 if item-1 < item-2 
        -  0 if item-1 < item-2 
        - >0 if item-1 > item-2 

    Example:

    .. code-block:: rexx
       :linenos:
    
       smax=15                                                   
       s1=screate(smax)                                          
       do i=1 to smax                                            
          call sset(s1,i,right(i,3,'0')'. Record')               
       end                                                       
       do i=1 to smax                                            
          say "Compare item "i" and 8, result: "sclc(s1,i,s1,8)     
       end  

    Results::

        Compare item 1 and 8, result: -7    
        Compare item 2 and 8, result: -6    
        Compare item 3 and 8, result: -5    
        Compare item 4 and 8, result: -4    
        Compare item 5 and 8, result: -3    
        Compare item 6 and 8, result: -2    
        Compare item 7 and 8, result: -1    
        Compare item 8 and 8, result: 0     
        Compare item 9 and 8, result: 1     
        Compare item 10 and 8, result: 1    
        Compare item 11 and 8, result: 1    
        Compare item 12 and 8, result: 1    
        Compare item 13 and 8, result: 1    
        Compare item 14 and 8, result: 1    
        Compare item 15 and 8, result: 1    

Sorting and Merging Arrays
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. function:: SQSORT(array-number,[ASCENDING/DESCENDING],[sort-offset])

    Sorts an array using the quick sort algorithm in ascending or descending 
    order, the default is ascending. The sort-offset defines the sorting scope
    up to the end of the item, any substrings before it are not treated. If you
    define for example 5, the array is sorted at offset 5 (up to the rest of 
    the item). The sort-offset defaults to 1. 

    This sort is 100-150 times faster than the BREXX quick sort running on 
    stems. 

    :returns: the number of sorted items. 

    Example:

    .. code-block:: rexx
       :linenos:
    
       max=25                                                                               
       s1=SREAD("'pej.songs2'")                                                             
       call slist s1                                                                        
       call sqsort(s1,'ASC',26)/* Sort Array S1 beginning column 26(song name) */ 
       call slist s1           /* display sorted array */                                                                     
       call sfree s1                                              

 Result, song names are in sorted order::

             Entries of Source Array: 0                                   
        Entry   Data                                                      
        -------------------------------------------------------           
        00001   LED ZEPPELIN                  STAIRWAY TO HEAVEN          
        00002   EAGLES                        HOTEL CALIFORNIA            
        00003   AC/DC                         BACK IN BLACK               
        00004   JOURNEY                       DON'T STOP BELIEVIN'        
        00005   PINK FLOYD                    ANOTHER BRICK IN THE WALL   
        00006   QUEEN                         BOHEMIAN RHAPSODY           
        00007   TOTO                          HOLD THE LINE               
        00008   KISS                          I WAS MADE FOR LOVIN' YOU   
        00009   BON JOVI                      LIVIN' ON A PRAYER          
        00010   NIRVANA                       SMELLS LIKE TEEN SPIRIT     
        00011   DEEP PURPLE                   SMOKE ON THE WATER          
        00012   METALLICA                     NOTHING ELSE MATTERS        
        00013   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION
        00014   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.          
        00015   QUEEN                         WE WILL ROCK YOU            
        00016   LYNYRD SKYNYRD                FREE BIRD                   
        00017   SURVIVOR                      EYE OF THE TIGER            
        00018   THE CLASH                     SHOULD I STAY OR SHOULD I GO
        00019   JIMI HENDRIX                  HEY JOE                     
        00020   FLEETWOOD MAC                 LITTLE LIES                 
        00021   AC/DC                         HIGHWAY TO HELL             
        00022   THE POLICE                    ROXANNE   
                          
             Entries of Source Array: 0                                   
        Entry   Data                                                         
        -------------------------------------------------------              
        00001   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION  
        00002   PINK FLOYD                    ANOTHER BRICK IN THE WALL      
        00003   AC/DC                         BACK IN BLACK                  
        00004   QUEEN                         BOHEMIAN RHAPSODY              
        00005   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.             
        00006   JOURNEY                       DON'T STOP BELIEVIN'           
        00007   SURVIVOR                      EYE OF THE TIGER               
        00008   LYNYRD SKYNYRD                FREE BIRD                      
        00009   JIMI HENDRIX                  HEY JOE                        
        00010   AC/DC                         HIGHWAY TO HELL                
        00011   TOTO                          HOLD THE LINE                  
        00012   EAGLES                        HOTEL CALIFORNIA               
        00013   KISS                          I WAS MADE FOR LOVIN' YOU      
        00014   FLEETWOOD MAC                 LITTLE LIES                    
        00015   BON JOVI                      LIVIN' ON A PRAYER             
        00016   METALLICA                     NOTHING ELSE MATTERS           
        00017   THE POLICE                    ROXANNE                        
        00018   THE CLASH                     SHOULD I STAY OR SHOULD I GO   
        00019   NIRVANA                       SMELLS LIKE TEEN SPIRIT        
        00020   DEEP PURPLE                   SMOKE ON THE WATER             
        00021   LED ZEPPELIN                  STAIRWAY TO HEAVEN             
        00022   QUEEN                         WE WILL ROCK YOU    

.. function:: SHSORT(array-number,[ASCENDING/DESCENDING],[sort-offset])

    Sorts an array using the shell sort algorithm in ascending or descending 
    order, default is ascending.

    The sort-offset defines the sorting scope up to the end of the item, any 
    substrings before it are not treated. If you define for example 5, the array
    is sorted at offset 5 (up to the rest of the item). The sort-offset defaults
    to 1.

    This sort is 100-150 times faster than the BREXX shell sort running on stems. 

.. function:: SMERGE(array-number-1,array-number-2)

    Merges 2 arrays into a new array, based on their sort order.

    :returns: the number of merged items. 

    Example:

    .. code-block:: rexx
       :linenos:
    
       max=10                                                                                              
       s1=SCREATE(max)       /* Create a String Array called S1 */                                         
       s2=SCREATE(max)       /* Create a String Array called S2 */                                         
       do i=1 to max                                                                                       
          call sset(s1,i,right((max-i+1),4,'0')' A Record') /* Add new Record in Array S1 at position i */ 
          call sset(s2,i,right((max-i+1),4,'0')' B Record') /* Add new Record in Array S1 at position i */ 
       end                                                                                                 
       say "Source Array S1"                                                                               
       say "---------------"                                                                               
       call slist s1                                                                                       
       say "Source Array S2"                                                                               
       say "---------------"                                                                               
       call slist s2                                                                                       
       s3=smerge(s1,s2)           /* Merge Array S1 and S2 into S3 */                                      
       say "Source Array S3"                                                                               
       say "---------------"                                                                               
       call slist s3                                                                                       
       return                                                                                              

    Result::

        Source Array S1              
        ---------------              
        00001   0010 A Record        
        00002   0009 A Record        
        00003   0008 A Record        
        00004   0007 A Record        
        00005   0006 A Record        
        00006   0005 A Record        
        00007   0004 A Record        
        00008   0003 A Record        
        00009   0002 A Record        
        00010   0001 A Record        
        Source Array S2              
        ---------------              
        00001   0010 B Record        
        00002   0009 B Record        
        00003   0008 B Record        
        00004   0007 B Record        
        00005   0006 B Record        
        00006   0005 B Record        
        00007   0004 B Record        
        00008   0003 B Record        
        00009   0002 B Record        
        00010   0001 B Record   
        Source Array S3              
        ---------------                  
        00001   0001 A Record  
        00002   0001 B Record  
        00003   0002 A Record  
        00004   0002 B Record  
        00005   0003 A Record  
        00006   0003 B Record  
        00007   0004 A Record  
        00008   0004 B Record  
        00009   0005 A Record  
        00010   0005 B Record  
        00011   0006 A Record  
        00012   0006 B Record  
        00013   0007 A Record  
        00014   0007 B Record  
        00015   0008 A Record  
        00016   0008 B Record  
        00017   0009 A Record  
        00018   0009 B Record  
        00019   0010 A Record  
        00020   0010 B Record  

Reporting and Manipulating entire Array 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. function:: SREVERSE(array-number)

    reverses the order of an array, the first item becomes the last item, the 
    last item the first item, etc. The reverse takes place in the specified 
    array. There is no new array created. The reverse process is very quick as
    just the string addresses are swapped, not the string content.  

    :returns: the number of elements of the array.

    Example:

    .. code-block:: rexx
       :linenos:
    
       smax=10                                       
       s1=screate(smax)                              
       do i=1 to smax                                
          call sset(s1,i,right(i,6,'0')". Record")   
       end                                           
       say "Original"                                
       say "--------"                                
       call slist s1                                 
       call sreverse(s1)                             
       say "Reversed"                                
       say "--------"                                
       call slist s1                                 
       call sfree(s1)                                
       EXIT 0                                        

    Result::

        Original                  
        --------                  
        00001   000001. Record    
        00002   000002. Record    
        00003   000003. Record    
        00004   000004. Record    
        00005   000005. Record    
        00006   000006. Record    
        00007   000007. Record    
        00008   000008. Record    
        00009   000009. Record    
        00010   000010. Record    
        Reversed                  
        --------                  
        00001   000010. Record    
        00002   000009. Record    
        00003   000008. Record    
        00004   000007. Record    
        00005   000006. Record    
        00006   000005. Record    
        00007   000004. Record    
        00008   000003. Record    
        00009   000002. Record    
        00010   000001. Record    

.. function:: SWRITE(array-number,dsn/ddname) 

    Writes all entries of the specified array into an external dataset.  

    The dataset can be either a fully qualified Dataset Name or a pre-allocated DD Name.

    :returns: the number of written entries. 
    
    For example, see SREAD.

.. function:: SREAD(dsn/ddname<,size-of-array>) 

    Reads all entries of an external dataset into a new  String Array. The 
    dataset can be either a fully qualified Dataset Name or a pre-allocated 
    DD Name. The optional parameter size-of-array is recommended for large 
    datasets. If omitted the size of the array grows dynamically to accommodate
    the content. 

    :returns: the newly created Array number.

    Example: 

    .. code-block:: rexx
       :linenos:
    
       s1=sread("'pej.songs'")     /* import CSV formatted DSN */                   
       s2=screate(sarray(s1))      /* create formatted version */                   
       do i=1 to sarray(s1)                           
          parse value sget(s1,i) with band':'song     
          call sset(s2,i,left(band,25)song)           
       end                                            
       call slist s2                                  
       say swrite(s2,"'pej.songs2'")' Entries exported'

    The contents of pej.songs, list of 20 best rock songs (not rated by me)::

        LED ZEPPELIN:     STAIRWAY TO HEAVEN                    
        EAGLES:     HOTEL CALIFORNIA                            
        AC/DC:     BACK IN BLACK                                
        JOURNEY:     DON'T STOP BELIEVIN'                       
        PINK FLOYD:     ANOTHER BRICK IN THE WALL               
        QUEEN:     BOHEMIAN RHAPSODY                            
        TOTO:     HOLD THE LINE                                 
        KISS:     I WAS MADE FOR LOVIN' YOU                     
        BON JOVI:     LIVIN' ON A PRAYER                        
        NIRVANA:     SMELLS LIKE TEEN SPIRIT                    
        DEEP PURPLE:     SMOKE ON THE WATER                     
        METALLICA:     NOTHING ELSE MATTERS                     
        THE ROLLING STONES:     (I CAN'T GET NO) SATISFACTION   
        BRUCE SPRINGSTEEN:     BORN IN THE U.S.A.               
        QUEEN:     WE WILL ROCK YOU                             
        LYNYRD SKYNYRD:     FREE BIRD                           
        SURVIVOR:     EYE OF THE TIGER                          
        THE CLASH:     SHOULD I STAY OR SHOULD I GO             
        JIMI HENDRIX:     HEY JOE                               
        FLEETWOOD MAC:     LITTLE LIES                          
        AC/DC:     HIGHWAY TO HELL                              
        THE POLICE:     ROXANNE                                 
        Result of fetched DSN:
            Entries of Source Array: 1                                    
        Entry   Data                                                       
        -------------------------------------------------------            
        00001   LED ZEPPELIN                  STAIRWAY TO HEAVEN           
        00002   EAGLES                        HOTEL CALIFORNIA             
        00003   AC/DC                         BACK IN BLACK                
        00004   JOURNEY                       DON'T STOP BELIEVIN'         
        00005   PINK FLOYD                    ANOTHER BRICK IN THE WALL    
        00006   QUEEN                         BOHEMIAN RHAPSODY            
        00007   TOTO                          HOLD THE LINE                
        00008   KISS                          I WAS MADE FOR LOVIN' YOU    
        00009   BON JOVI                      LIVIN' ON A PRAYER           
        00010   NIRVANA                       SMELLS LIKE TEEN SPIRIT      
        00011   DEEP PURPLE                   SMOKE ON THE WATER           
        00012   METALLICA                     NOTHING ELSE MATTERS         
        00013   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION
        00014   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.           
        00015   QUEEN                         WE WILL ROCK YOU             
        00016   LYNYRD SKYNYRD                FREE BIRD                    
        00017   SURVIVOR                      EYE OF THE TIGER             
        00018   THE CLASH                     SHOULD I STAY OR SHOULD I GO 
        00019   JIMI HENDRIX                  HEY JOE                      
        00020   FLEETWOOD MAC                 LITTLE LIES                  
        00021   AC/DC                         HIGHWAY TO HELL              
        00022   THE POLICE                    ROXANNE                      
        22 Entries exported     

.. function:: SLIST(array-number,[from],[to],[heading]) 

    Prints the array content. With the optional from and to parameters, you can
    limit the range of entries to be printed. The optional heading parameter is 
    printed in the heading line.   
    
    For example, see SREAD and others

.. function:: SSEARCH(array-number,search-string, from,["option"]) 

    Searches in a String Array for a certain string and returns the index 
    number. For repeated searches, you can use the from parameter. 

    :param option:
        - `CASE` - means it is a case-sensitive search
        - `NOCASE` - search is case-insensitive
    :returns: index position if found, or zero. 

    Example:

    .. code-block:: rexx
       :linenos:
    
       s1=sread("'pej.songs2'")                           
       ssc="ON"                                           
       ssi=ssearch(s1,ssc) /* Search string ON in array */ 
       do while ssi>0                                     
          say "Found at "ssi": "sget(s1,ssi)              
          ssi=ssearch(s1,ssc,ssi+1)           
       end                                                   

    Result::

        Found at 4: JOURNEY                       DON'T STOP BELIEVIN'           
        Found at 9: BON JOVI                      LIVIN' ON A PRAYER             
        Found at 11: DEEP PURPLE                   SMOKE ON THE WATER            
        Found at 13: THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION

.. function:: SSEARCHI(array-number,search-string,from, [“CASE”/”NOCASE”]) 

    Searches in a String Array for a certain string and returns all occurrences
    in an internally created Integer Array. It is consecutively filled with the
    index referring to the String Array. 

    :param from: line number to start the search	
    :param option: 
        - `CASE` - means it is a case-sensitive search
        - `NOCASE` - search is case-insensitive
    :returns: the Integer Array number. Additionally, the variable `SCOUNT` is set with the number of entries found.

    It is recommended to free the Integer Array if not needed anymore.  

    Example:

    .. code-block:: rexx
       :linenos:
    
       imax=50                                 
       s1=Screate(imax)                          
       do i=1 to imax/2                          
          call sset(s1,,'abcde'i)                
          call sset(s1,,'xyz'i)                  
       end                                       
       i1=ssearchI(s1,'xyz')                     
       say 'found 'scount                        
       call ilist i1,20,25  
       call ifree i1                             
       
    Result::
    
        found 25                                                
         Entries of IARRAY: 0                               
        Entry   Data                                            
        --------------------------------------------------------
        00020           40                                      
        00021           42                                      
        00022           44                                      
        00023           46                                      
        00024           48                                      
        00025           50                                      
        25 Entries      

.. function:: SSELECT(array-number,search-1 ,[search-2,…,search-99])  

    Creates a subset of the array when an entry matches one of the specified
    search strings in a new array. There are up to 99 search strings allowed. 
    The search is case-sensitive.

    :returns: the newly created array. 

    Example:

    .. code-block:: rexx
       :linenos:
    
       s1=sread("'pej.songs2'")        
       call slist s1                   
       s2=sselect(s1,'ON','OF','EE')   /* Search ON, OF, EE in array */   
       say copies('-',32)              
       say 'Selected'                  
       say copies('-',32)              
       call slist s2                   
       call sfree(s1)                  
       call sfree(s2)                  
   
    Result::

            Entries of Source Array: 0                                       
        Entry   Data                                                          
        -------------------------------------------------------               
        00001   LED ZEPPELIN                  STAIRWAY TO HEAVEN              
        00002   EAGLES                        HOTEL CALIFORNIA                
        00003   AC/DC                         BACK IN BLACK                   
        00004   JOURNEY                       DON'T STOP BELIEVIN'            
        00005   PINK FLOYD                    ANOTHER BRICK IN THE WALL       
        00006   QUEEN                         BOHEMIAN RHAPSODY               
        00007   TOTO                          HOLD THE LINE                   
        00008   KISS                          I WAS MADE FOR LOVIN' YOU       
        00009   BON JOVI                      LIVIN' ON A PRAYER              
        00010   NIRVANA                       SMELLS LIKE TEEN SPIRIT         
        00011   DEEP PURPLE                   SMOKE ON THE WATER              
        00012   METALLICA                     NOTHING ELSE MATTERS            
        00013   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION   
        00014   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.              
        00015   QUEEN                         WE WILL ROCK YOU                
        00016   LYNYRD SKYNYRD                FREE BIRD                       
        00017   SURVIVOR                      EYE OF THE TIGER                
        00018   THE CLASH                     SHOULD I STAY OR SHOULD I GO    
        00019   JIMI HENDRIX                  HEY JOE                         
        00020   FLEETWOOD MAC                 LITTLE LIES                     
        00021   AC/DC                         HIGHWAY TO HELL                 
        00022   THE POLICE                    ROXANNE                         
        --------------------------------     
        Selected                                                            
        --------------------------------                                    
            Entries of Source Array: 1                                     
        Entry   Data                                                        
        -------------------------------------------------------             
        00001   JOURNEY                       DON'T STOP BELIEVIN'          
        00002   QUEEN                         BOHEMIAN RHAPSODY             
        00003   BON JOVI                      LIVIN' ON A PRAYER            
        00004   NIRVANA                       SMELLS LIKE TEEN SPIRIT       
        00005   DEEP PURPLE                   SMOKE ON THE WATER            
        00006   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION 
        00007   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.            
        00008   QUEEN                         WE WILL ROCK YOU              
        00009   LYNYRD SKYNYRD                FREE BIRD                     
        00010   SURVIVOR                      EYE OF THE TIGER              
        00011   FLEETWOOD MAC                 LITTLE LIES    

.. function:: SCHANGE(array-number,from-1,to-1[,from-2,to-2[,from-3,to-3]]) 

    Changes the content of the array (line by line), from-1 is replaced by to1, 
    from-2 by to-2, etc. If multiple change parameters are specified, a 
    subsequent change may re-change a previous change.
    
    :returns: the number of changes performed. 

    Example, input file is the same as in SSELECT:

    .. code-block:: rexx
       :linenos:
    
       SAY COPIES('-',50)                                  
       SAY "READ EXTERNAL INTO SARRAY, SELECT SUBSET"      
       SAY COPIES('-',50)                                  
       DSNIN=MVSVAR("REXXDSN")                             
       S1=SREAD("'"DSNIN"(LLDATA)'")      /* READ DATA */  
       SAY SCHANGE(S1,'IN','**','EE','+++','EY','')        
       SAY COPIES('-',50)                                  
       SAY 'CHANGED ARRAY '                                
       SAY COPIES('-',50)                                  
       CALL SLIST S1                                       
       CALL SFREE S1                                       
       EXIT 0  

    Result::

        --------------------------------------------------                
        CHANGED ARRAY                                                     
        --------------------------------------------------                
            Entries of Source Array: 0                                   
        Entry   Data                                                      
        -------------------------------------------------------           
        00001   LED ZEPPEL**                  STAIRWAY TO HEAVEN          
        00002   EAGLES                        HOTEL CALIFORNIA            
        00003   AC/DC                         BACK ** BLACK               
        00004   JOURN                       DON'T STOP BELIEV**'          
        00005   P**K FLOYD                    ANOTHER BRICK ** THE WALL   
        00006   QU+++N                         BOHEMIAN RHAPSODY          
        00007   TOTO                          HOLD THE L**E               
        00008   KISS                          I WAS MADE FOR LOV**' YOU   
        00009   BON JOVI                      LIV**' ON A PRAYER          
        00010   NIRVANA                       SMELLS LIKE T+++N SPIRIT    
        00011   D+++P PURPLE                   SMOKE ON THE WATER         
        00012   METALLICA                     NOTH**G ELSE MATTERS        
        00013   THE ROLL**G STONES            (I CAN'T GET NO) SATISFACTIO
        00014   BRUCE SPR**GST+++N             BORN ** THE U.S.A.         
        00015   QU+++N                         WE WILL ROCK YOU           
        00016   LYNYRD SKYNYRD                FR+++ BIRD                  
        00017   SURVIVOR                      E OF THE TIGER                   
        00018   THE CLASH                     SHOULD I STAY OR SHOULD I GO     
        00019   JIMI HENDRIX                  H JOE                            
        00020   FL+++TWOOD MAC                 LITTLE LIES                     
        00021   AC/DC                         HIGHWAY TO HELL                  
        00022   THE POLICE                    ROXANNE                          
        22 Entries                                                             

.. function:: SCOPY(source-array,[from-entry],[to-entry],[old-array-to append],[start-position(from-array)],[length of substring])

    Copies a source array into a new array, optionally you can append an 
    existing array if you specify an existing array as 4. Parameter. Appending
    can also be done by the `SAPPEND` function.

    :param from-entry: defines an item number where the copy should begin. It defaults to 1.
    :param to-entry: is the item number to stop the copy. It defaults to the last array item.
    :param start-position: defines the substring offset, of the record to be copied. It defaults to 1.
    :param Length-of substring: is the length of the substring offset. It defaults to the length of the record.
    :returns: the created array number

.. function:: SAPPEND(array-to-append,source-array,[from-entry],[to-entry],[start-position(from-array)],[length of substring])
    
    Appends the array-to-append by the source-array.

    :param from-entry: defines the item number of the source-array which is taken as the first record to append. It defaults to 1.
    :param to-entry: is the item number to stop the append. It defaults to the last array item.
    :param start-position: defines the substring offset, of the record to be copied. It defaults to 1.
    :param Length-of substring: is the length of the substring offset. It defaults to the length of the record.
    :returns: the appended array number. 

    Append the same array (items 10-20) to the array, input file is the same as in SSELECT:

    .. code-block:: rexx
       :linenos:
       :emphasize-lines: 6
    
       say copies('-',50)                                   
       say "Read External into Sarray"                      
       say copies('-',50)                                   
       dsnin=mvsvar("REXXDSN")                              
       s1=sread("'"dsnin"(lldata)'")                        
       call sAPPEND(s1,s1,10,20)                            
       say copies('-',50)                                   
       say 'Appended Array by itself from entry to 20'      
       say copies('-',50)                                   
       call slist s1                                        
       call sfree s1                                        
       EXIT 0                                            

    Result:

    .. code-block:: text
        :emphasize-lines: 29-39

        --------------------------------------------------                  
        Appended Array by itself from entry to 20                           
        --------------------------------------------------                  
            Entries of Source Array: 0                                     
        Entry   Data                                                        
        -------------------------------------------------------             
        00001   LED ZEPPELIN                  STAIRWAY TO HEAVEN            
        00002   EAGLES                        HOTEL CALIFORNIA              
        00003   AC/DC                         BACK IN BLACK                 
        00004   JOURNEY                       DON'T STOP BELIEVIN'          
        00005   PINK FLOYD                    ANOTHER BRICK IN THE WALL     
        00006   QUEEN                         BOHEMIAN RHAPSODY             
        00007   TOTO                          HOLD THE LINE                 
        00008   KISS                          I WAS MADE FOR LOVIN' YOU     
        00009   BON JOVI                      LIVIN' ON A PRAYER            
        00010   NIRVANA                       SMELLS LIKE TEEN SPIRIT       
        00011   DEEP PURPLE                   SMOKE ON THE WATER            
        00012   METALLICA                     NOTHING ELSE MATTERS          
        00013   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION 
        00014   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.            
        00015   QUEEN                         WE WILL ROCK YOU              
        00016   LYNYRD SKYNYRD                FREE BIRD                     
        00017   SURVIVOR                      EYE OF THE TIGER              
        00018   THE CLASH                     SHOULD I STAY OR SHOULD I GO   
        00019   JIMI HENDRIX                  HEY JOE                        
        00020   FLEETWOOD MAC                 LITTLE LIES                    
        00021   AC/DC                         HIGHWAY TO HELL                
        00022   THE POLICE                    ROXANNE                        
        00023   NIRVANA                       SMELLS LIKE TEEN SPIRIT        
        00024   DEEP PURPLE                   SMOKE ON THE WATER             
        00025   METALLICA                     NOTHING ELSE MATTERS           
        00026   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION  
        00027   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.             
        00028   QUEEN                         WE WILL ROCK YOU               
        00029   LYNYRD SKYNYRD                FREE BIRD                      
        00030   SURVIVOR                      EYE OF THE TIGER               
        00031   THE CLASH                     SHOULD I STAY OR SHOULD I GO   
        00032   JIMI HENDRIX                  HEY JOE                        
        00033   FLEETWOOD MAC                 LITTLE LIES                    
        33 Entries    
   
.. function:: SSUBSTR(array-number,from-column,[length],[INTERNAL/EXTERNAL]) 

    Creates an array with the substring of each line (according to the SUBSTR
    REXX function). EXTERNAL (default) creates a new array with the substring 
    results. INTERNAL works on the existing array.  

    :returns: the array number that has been created/used. 

    Example, the input file is the same as in SSELECT:

    .. code-block:: rexx
       :linenos:
    
       say copies('-',50)                                           
       say "Read External into Sarray, select Subset"               
       say copies('-',50)                                           
       dsnin=mvsvar("REXXDSN")                                      
       s1=sread("'"dsnin"(lldata)'")      /* Create Linked List */  
       /* call slist s1   */                                        
       call sSUBSTR(s1,25,,'INTERNAL')                              
       say copies('-',50)                                           
       say 'ARRAY from Column 25 '                                  
       say copies('-',50)                                           
       call slist s1                                                
       call sfree s1                                                
       EXIT 0 

    Result::
        
        --------------------------------------------------     
        ARRAY from Column 25                                   
        --------------------------------------------------     
            Entries of Source Array: 0                        
        Entry   Data                                           
        -------------------------------------------------------
        00001         STAIRWAY TO HEAVEN                       
        00002         HOTEL CALIFORNIA                         
        00003         BACK IN BLACK                            
        00004         DON'T STOP BELIEVIN'                     
        00005         ANOTHER BRICK IN THE WALL                
        00006         BOHEMIAN RHAPSODY                        
        00007         HOLD THE LINE                            
        00008         I WAS MADE FOR LOVIN' YOU                
        00009         LIVIN' ON A PRAYER                       
        00010         SMELLS LIKE TEEN SPIRIT                  
        00011         SMOKE ON THE WATER                       
        00012         NOTHING ELSE MATTERS                     
        00013         (I CAN'T GET NO) SATISFACTION            
        00014         BORN IN THE U.S.A.                       
        00015         WE WILL ROCK YOU                         
        00016         FREE BIRD                                
        00017         EYE OF THE TIGER                         
        00018         SHOULD I STAY OR SHOULD I GO   
        00019         HEY JOE                        
        00020         LITTLE LIES                    
        00021         HIGHWAY TO HELL                
        00022         ROXANNE                        
        22 Entries                                   

.. function:: SUPPER(array-number,[INTERNAL/EXTERNAL]) 

    Creates/updates an array with the upper case version of each entry. EXTERNAL
    (default) creates a new array with the substring results. INTERNAL works on 
    the existing array.  
    
    :returns: the array number that has been created/used. 


    .. code-block:: rexx
       :linenos:
    
       sm1=15                              
       s1=screate(sm1)                     
       do i=1 to sm1                       
          call sset(s1,,'abcdefghij 'i)    
       end                                 
       call slist s1                       
       call supper(s1,'INTERNAL')          
       call slist s1                        

    Result::

             Entries of Source Array: 0                        
        Entry   Data                                           
        -------------------------------------------------------
        00001   abcdefghij 1                                   
        00002   abcdefghij 2                                   
        00003   abcdefghij 3                                   
        00004   abcdefghij 4                                   
        00005   abcdefghij 5                                   
        00006   abcdefghij 6                                   
        00007   abcdefghij 7                                   
        00008   abcdefghij 8                                   
        00009   abcdefghij 9                                   
        00010   abcdefghij 10                                  
        00011   abcdefghij 11                                  
        00012   abcdefghij 12                                  
        00013   abcdefghij 13                                  
        00014   abcdefghij 14                                  
        00015   abcdefghij 15                                  
        15 Entries                                             
        
            Entries of Source Array: 0                          
        Entry   Data                                             
        -------------------------------------------------------  
        00001   ABCDEFGHIJ 1                                     
        00002   ABCDEFGHIJ 2                                     
        00003   ABCDEFGHIJ 3                                     
        00004   ABCDEFGHIJ 4                                     
        00005   ABCDEFGHIJ 5       
        00006   ABCDEFGHIJ 6       
        00007   ABCDEFGHIJ 7       
        00008   ABCDEFGHIJ 8       
        00009   ABCDEFGHIJ 9       
        00010   ABCDEFGHIJ 10      
        00011   ABCDEFGHIJ 11      
        00012   ABCDEFGHIJ 12      
        00013   ABCDEFGHIJ 13      
        00014   ABCDEFGHIJ 14      
        00015   ABCDEFGHIJ 15      
        15 Entries                 

.. function:: SCOUNT(array-number,search-string-1[,search-string-2[,search-string-3…]]) 

    Counts the lines containing the search strings. Multiple occurrences of a 
    search string in a line are not counted, but hits of additional search 
    strings on a line will be counted. 
    
    :returns: the number of lines containing the search strings

.. function:: SDROP(array-number,drop-string-1[,drop-string-2[,drop-string-3…]]) 

    Drops lines containing the drop strings at any position. 

    Alternatively, you can set the rexx -variable `sdrop.at.n=offset` to a 
    certain offset to enforce an exact match. n refers to drop-string-n for 
    which the search and drop should be performed. If for a certain position no
    sdrop.at variable is set, the search and drop is performed for any position
    in the line. 
    
    There can be up to 99 drop-strings.   

    An empty drop string is treated to drop empty lines.

    The function works in an existing array (array-number) and may reduce the maximum number of items. 

    :returns: the number of items containing the drop strings

    Example, the input file is the same as in SSELECT:

    .. code-block:: rexx
       :linenos:
    
       dsnin=mvsvar("REXXDSN")                                        
       s1=sread("'"dsnin"(lldata)'")      /* Create Linked List */    
       call sDROP(s1,'AC','IN')                                       
       say copies('-',50)                                             
       say 'Items not containing AC or IN'                            
       say copies('-',50)                                             
       call slist s1                                                  
       call sfree s1                                                  
       EXIT 0                                                         

    Result::

        --------------------------------------------------                 
        Items not containing AC or IN                                      
        --------------------------------------------------                 
            Entries of Source Array: 0                                    
        Entry   Data                                                       
        -------------------------------------------------------            
        00001   EAGLES                        HOTEL CALIFORNIA             
        00002   QUEEN                         BOHEMIAN RHAPSODY            
        00003   NIRVANA                       SMELLS LIKE TEEN SPIRIT      
        00004   DEEP PURPLE                   SMOKE ON THE WATER           
        00005   QUEEN                         WE WILL ROCK YOU             
        00006   LYNYRD SKYNYRD                FREE BIRD                    
        00007   SURVIVOR                      EYE OF THE TIGER             
        00008   THE CLASH                     SHOULD I STAY OR SHOULD I GO 
        00009   JIMI HENDRIX                  HEY JOE                      
        00010   THE POLICE                    ROXANNE     
        10 Entries                                                                            

.. function:: SKEEP(array-number,keep-string-1[,keep-string-2[,keep-string-3…]]) 

    Keeps lines containing one or more of the specified keep strings. 

    The function works in the existing array (array-number) and may reduce the maximum number of items. 

    :returns: the number of lines containing the search strings.

    Example, the input file is the same as in SSELECT:

    .. code-block:: rexx
       :linenos:
    
       dsnin=mvsvar("REXXDSN")           
       s1=sread("'"dsnin"(lldata)'")     
       call slist s1                     
       call sKEEP(s1,'AC','IN')          
       say copies('-',50)                
       say 'Items containing AC or IN'   
       say copies('-',50)                
       call slist s1                     
       call sfree s1                     
       EXIT 0                            
    
    Result::

        --------------------------------------------------                  
        Items containing AC or IN                                           
        --------------------------------------------------                  
            Entries of Source Array: 0                                     
        Entry   Data                                                        
        -------------------------------------------------------             
        00001   LED ZEPPELIN                  STAIRWAY TO HEAVEN            
        00002   AC/DC                         BACK IN BLACK                 
        00003   JOURNEY                       DON'T STOP BELIEVIN'          
        00004   PINK FLOYD                    ANOTHER BRICK IN THE WALL     
        00005   TOTO                          HOLD THE LINE                 
        00006   KISS                          I WAS MADE FOR LOVIN' YOU     
        00007   BON JOVI                      LIVIN' ON A PRAYER            
        00008   METALLICA                     NOTHING ELSE MATTERS          
        00009   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION 
        00010   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.            
        00011   FLEETWOOD MAC                 LITTLE LIES                   
        00012   AC/DC                         HIGHWAY TO HELL               
        12 Entries                                                          


.. function:: SKEEPAND(array-number,keep-string-1[,keep-string-2[,keep-string-3…]]) 

    Keeps lines containing all of the specified keep strings. 
    
    The function works in the existing array (array-number) and may reduce the 
    maximum number of items. 

    :returns: the number of lines containing the search strings.

    Example, the input file is the same as in SSELECT:

    .. code-block:: rexx
       :linenos:
    
       dsnin=mvsvar("REXXDSN")                                       
       s1=sread("'"dsnin"(lldata)'")      /* Create Linked List */   
       call slist s1                                                 
       call sKEEPAND(s1,'AC','IN')                                   
       say copies('-',50)                                            
       say 'Items containing AC AND IN'                              
       say copies('-',50)                                            
       call slist s1                                                 
       call sfree s1                                                 
       EXIT 0                                                        

    Result::

        --------------------------------------------------                  
        Items containing AC AND IN                                          
        --------------------------------------------------                  
            Entries of Source Array: 0                                     
        Entry   Data                                                        
        -------------------------------------------------------             
        00001   AC/DC                         BACK IN BLACK                 
        00002   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION 
        2 Entries                                       

.. function:: SINSERT(array-number,insert-after-line,number-of-lines) 

    Inserts empty lines in an array. insert-after-line identifies the index 
    after which the lines will be inserted. If you specify 0 they will be 
    inserted starting with the first line. Existing lines will be shifted down
    by the requested number of lines.

    :returns: the completion code. Zero means the insertion was successful. Return code 8 means the insertion failed, it is accompanied by an error message. 

.. function:: SDEL(array-number,delete-from,number-lines)  

    Deletes from the given line-number delete-from the specified number in 
    number-lines. 


.. function:: SNUMBER(source-array-number[,number-length]) 
    
    Adds a line number in front of each item of an existing array. The optional 
    number length can be specified as a seconds parameter, it defaults to 6. 


    .. code-block:: rexx
       :linenos:
    
       s1=screate(10)                  
       do i=1 to 10                    
          call sset(s1,,'record 'i)    
       end                             
       call slist s1                   
       call snumber(s1,4)              
       call slist s1

    Result::

            Entries of Source Array: 0                         
        Entry   Data                                            
        ------------------------------------------------------- 
        00001   record 1                                        
        00002   record 2                                        
        00003   record 3                                        
        00004   record 4                                        
        00005   record 5                                        
        00006   record 6                                        
        00007   record 7                                        
        00008   record 8                                        
        00009   record 9                                        
        00010   record 10                                       
        10 Entries                                              
            Entries of Source Array: 0                         
        Entry   Data                                            
        ------------------------------------------------------- 
        00001   0001 record 1                                   
        00002   0002 record 2                                   
        00003   0003 record 3                                   
        00004   0004 record 4                                   
        00005   0005 record 5                                   
        00006   0006 record 6                                   
        00007   0007 record 7                                   
        00008   0008 record 8                                   
        00009   0009 record 9  
        00010   0010 record 10                                   
                                 
.. function:: S2HASH(source-array-number) 

    Creates an integer array. The items contain a hash value of each item in 
    the source-array.  Integer comparisons are much faster than string 
    comparisons. 

    :returns: the integer array number. 

    Example, the input file is the same as in SSELECT:

    .. code-block:: rexx
       :linenos:
    
       dsnin=mvsvar("REXXDSN")                                       
       s1=sread("'"dsnin"(lldata)'")      /* Create Linked List */   
       call slist s1                                                 
       i1=s2HASH(s1,25,,'INTERNAL')                                  
       say copies('-',50)                                            
       say 'Hashes from ARRAY'                                       
       say copies('-',50)                                            
       call ilist i1                                                 
       call sfree s1                                                 
       call ifree i1                                                 
       EXIT 0  

    Result::
        
        --------------------------------------------------                    
        Hashes from ARRAY                                                     
        --------------------------------------------------                    
            Entries of IARRAY: 0                                             
        Entry   Data                                                          
        --------------------------------------------------------------------
        00001   1762230186                                                    
        00002    742146533                                                    
        00003     54160282                                                    
        00004    333486878                                                    
        00005   1063451074                                                    
        00006   1131679241                                                    
        00007   1557910634                                                    
        00008   -562308514                                                    
        00009   1574372382                                                    
        00010   1488490451                                                    
        00011   -254564903                                                    
        00012      8800208                                                    
        00013   1324062534                                                    
        00014   1821602997                                                    
        00015   2118017364                                                    
        00016   1965748661                                                    
        00017   1329580209                                                    
        00018   1871612546    
        00019   1881722666    
        00020   1061408928    
        00021   1598195414    
        00022   -238030808    
        22 Entries            
                                                      
.. function:: SSPLIT(string-to-split,delimiter-chars)  
    
    SPLIT splits a string into lines and stores them in a SARRAY. The optional 
    delimiter table defines the split character(s), which shall be used to 
    separate the lines. The delimiter string may consist of more than one 
    character. This function is useful if you have file content in one string 
    containing the line-feed character.  

    :returns: the array number created. 

.. function:: SEXTRACT(array-number,begin-lino,end-lino) 

    SEXTRACT extracts lines of a SARRAY. The first parameter is the line to 
    begin, second is the last line to be extracted, it is not the number of 
    lines. End-lino defaults to the last line of the source array.

.. function:: SCUT(array-number,begin-string,end-string,[from-line],[NO-DELIMITER/DELIMITER])   

    SCUT extracts lines of a SARRAY. If NO-DELIMITER is specified, the 
    extraction starts with the lines after the begin-string and ends with the 
    line before the end string is found. If DELIMITER is specified, the 
    delimiter lines are included. The default is NO-DELIMITER. 

    For example, we have the following SARRAY (s1)::

            Entries of Source Array: 0                        
        Entry   Data                                           
        -------------------------------------------------------
        00001   Record 1                                       
        00002   Record 2                                       
        00003   Record 3                                       
        00004   Record 4                                       
        00005   Record 5                                       
        00006   From Here                                      
        00007   Data 1                                         
        00008   Data 2                                         
        00009   Data 3                                         
        00010   End                                            
        00011   Record 6                                       
        00012   Record 7                                       
        00013   Record 8                                       
        00014   Record 9                                       
        00015   Record 10                                      
        15 Entries                                             
    
    And the following REXX:

    .. code-block:: rexx
       :linenos:
    
       s2=sextract(s1,"From Here","End")      
       call slist s2                          

    Result::

            Entries of Source Array: 1                        
        Entry   Data                                           
        -------------------------------------------------------
        00001   Data 1                                         
        00002   Data 2                                         
        00003   Data 3                                         
        3 Entries          

.. function:: SARRAY (array-number) 

    Returns information about the Source Array. The following BREXX variables 
    are set:

    - `sarrayhi` highest element number set in the array 
    - `sarraymax` maximum entries available
    - `sarrayADDR` address of the Source Array

    :returns: highest array entry.

Set Theory and Arrays 
~~~~~~~~~~~~~~~~~~~~~

*SET Set theory is the branch of mathematical logic that studies sets, which 
can be informally described as collections of objects. Although objects of any 
kind can be collected into a set, set theory — as a branch of mathematics — is 
mostly concerned with those that are relevant to mathematics as a whole.* 
Definition taken from Wikipedia

To utilize arrays with Set Theory operations, they must be unique and sorted. 
If an array does not follow these principles, its results may be unpredictable. 

.. function:: SUNIFY(array-number)

    Creates and sorts an array and just keeps unique elements.

    :returns: the number of removed elements.

    .. code-block:: rexx
       :linenos:
    
       s1=screate(10)                               
       do i=1 to 10                                 
          call sset(s1,,right(random(1,5),4,'0'))   
       end                                          
       call slist s1                                
       call sunify(s1)                                
       call slist s1                                

    Result::

            Entries of Source Array: 0                       
        Entry   Data                                          
        ------------------------------------------------------
        00001   0005                                          
        00002   0005                                          
        00003   0003                                          
        00004   0005                                          
        00005   0003                                          
        00006   0004                                          
        00007   0003                                          
        00008   0001                                          
        00009   0001                                          
        00010   0003                                          
        10 Entries                                            
            Entries of Source Array: 0                       
        Entry   Data                                          
        ------------------------------------------------------
        00001   0001                                          
        00002   0003                                          
        00003   0004                                          
        00004   0005                                          
        4 Entries                                             

.. function:: SUNION(array-1,array-2)

    Builds a new array consisting of elements of both arrays. Any duplicates 
    are removed in the new array. The new array is sorted. The set operation 
    is:  array1 ∪ array2  

    :returns: the created array number.

    .. code-block:: rexx
       :linenos:
    
       s1=screate(10)                               
       s2=screate(10)                               
       do i=1 to 10                                 
          call sset(s1,,right(random(1,5),4,'0'))   
          call sset(s2,,right(random(3,14),4,'0'))  
       end                                          
       call slist s1                                
       call slist s2                                
       call sunify(s1)                              
       call sunify(s2)                              
       call slist s1                                
       call slist s2                                
       s3=sunion(s1,s2)                             
       call slist s3  
           
    Result::

            Entries of Source Array: 0                        
        Entry   Data                                           
        -------------------------------------------------------
        00001   0003                                           
        00002   0002                                           
        00003   0004                                           
        00004   0003                                           
        00005   0004                                           
        00006   0002                                           
        00007   0002                                           
        00008   0001                                           
        00009   0005                                           
        00010   0005                                           
        10 Entries                                             
            Entries of Source Array: 1                        
        Entry   Data                                           
        -------------------------------------------------------
        00001   0008                                           
        00002   0012                                           
        00003   0009                                           
        00004   0006                                           
        00005   0013                                           
        00006   0009                                           
        00007   0007                                           
        00008   0003                                           
        00009   0005               
        00010   0006                                            
        10 Entries                                              
            Entries of Source Array: 0                         
        Entry   Data                                            
        ------------------------------------------------------- 
        00001   0001                                            
        00002   0002                                            
        00003   0003                                            
        00004   0004                                            
        00005   0005                                            
        5 Entries                                               
            Entries of Source Array: 1                         
        Entry   Data                                            
        ------------------------------------------------------- 
        00001   0003                                            
        00002   0005                                            
        00003   0006                                            
        00004   0007                                            
        00005   0008                                            
        00006   0009                                            
        00007   0012                                            
        00008   0013                                            
        8 Entries                                               
            Entries of Source Array: 2                         
        Entry   Data                                            
        00001   0001         
        00002   0002         
        00003   0003         
        00004   0004         
        00005   0005         
        00006   0006         
        00007   0007         
        00008   0008         
        00009   0009         
        00010   0012         
        00011   0013         
        11 Entries           

.. function:: SINTERSECT(array-1,array-2)

    Creates a new array by intersecting two existing arrays. It contains which 
    are in both arrays.  The set operation is:  array1 ∩ array2.
    
    :returns: the created array number.

    .. code-block:: rexx
       :linenos:
    
       s1=screate(8)                                  
       s2=screate(8)                                  
       do i=1 to 8                                    
          call sset(s1,,right(random(1,5),4,'0'))     
          call sset(s2,,right(random(3,14),4,'0'))    
       end                                            
       call slist s1                                  
       call slist s2                                  
       call sunify(s1)                                
       call sunify(s2)                                
       call slist s1                                  
       call slist s2                                  
       s3=sintersect(s1,s2)                           
       call slist s3              

    Result::
                    
            Entries of Source Array: 0                        
        Entry   Data                                           
        -------------------------------------------------------
        00001   0002                                           
        00002   0001                                           
        00003   0005                                           
        00004   0005                                           
        00005   0005                                           
        00006   0005                                           
        00007   0007                                           
        00008   0001                                           
        8 Entries                                              
            Entries of Source Array: 1                        
        Entry   Data                                           
        -------------------------------------------------------
        00001   0007                                           
        00002   0011                                           
        00003   0006                                           
        00004   0013                                           
        00005   0008                                           
        00006   0003                                           
        00007   0006                                           
        00008   0014                                           
        8 Entries                                              
            Entries of Source Array: 0                        
        Entry   Data                                           
        -------------------------------------------------------
        00001   0001                                           
        00002   0002                                           
        00003   0005               
        00004   0007                                           
                                    
        3 Entries                                              
            Entries of Source Array: 1                        
        Entry   Data                                           
        -------------------------------------------------------
        00001   0003                                           
        00002   0006                                           
        00003   0007                                           
        00004   0008                                           
        00005   0011                                           
        00006   0013                                           
        00007   0014                                           
        7 Entries                                              
            Entries of Source Array: 2                        
        Entry   Data                                           
        -------------------------------------------------------
        00001   0007                                           
        1 Entries                                              


.. function:: STDROP(array-1,array-2)
.. function:: SDIFFERENCE(array-1,array-2)  

    Creates a new array which is the difference between array-1 and array-2. 
    All elements contained in array-2 are dropped from array-1 (if 
    contained). The set operation is:  array1 - array2.

    :returns: the created array number.

    .. code-block:: rexx
       :linenos:
    
       s1=screate(8)                                
       s2=screate(8)                                
       do i=1 to 8                                  
          call sset(s1,,right(random(1,5),4,'0'))   
          call sset(s2,,right(random(3,14),4,'0'))  
       end                                          
       call slist s1                                
       call slist s2                                
       call sunify(s1)                              
       call sunify(s2)                              
       call slist s1                                
       call slist s2                                
       s3=sdifference(s1,s2)                        
       call slist s3                                


            Entries of Source Array: 0                        
        Entry   Data                                           
        -------------------------------------------------------
        00001   0001                                           
        00002   0002                                           
        00003   0004                                           
        00004   0004                                           
        00005   0001                                           
        00006   0004                                           
        00007   0001                                           
        00008   0004                                           
        8 Entries                                              
            Entries of Source Array: 1                        
        Entry   Data                                           
        -------------------------------------------------------
        00001   0009                                           
        00002   0003                                           
        00003   0008                                           
        00004   0004                                           
        00005   0014                                           
        00006   0011                                           
        00007   0005                                           
        00008   0006                                           
        8 Entries                                              
            Entries of Source Array: 0                        
        Entry   Data                                           
        -------------------------------------------------------
        00001   0001                                           
        00002   0002                                           
        00003   0004                                           
        3 Entries                                              
            Entries of Source Array: 1                        
        Entry   Data                                           
        -------------------------------------------------------
        00001   0003                                           
        00002   0004                                           
        00003   0005                                           
        00004   0006                                           
        00005   0008                                           
        00006   0009                                           
        00007   0011                                           
        00008   0014                                           
        8 Entries                                              
            Entries of Source Array: 2                        
        Entry   Data                                           
        -------------------------------------------------------
        00001   0001                                           
        00002   0002                                           
        2 Entries                                              

.. function:: SDIFFSYM(array-1,array-2)

    Creates a new array building the symmetrical difference of set1 and set2,
    operation:  set1 ∆ set2   

    .. code-block:: rexx
       :linenos:
    
       smax=25                                                         
       s1=screate(smax)     -- Create first Array                      
       s2=screate(smax)     -- Create second Array                     
       do i=1 to smax       -- Preset Arrays with randomised numbers  
          call sset(s1,,right(random(1,smax%2),4,'0'))                 
          call sset(s2,,right(random(3,smax%3),4,'0'))                 
       end                                                             
       call sunify(s1)       -- Unify first array                       
       call sunify(s2)       -- Unify second array                      
       s3=sdiffsym(s1,s2)    -- build symmetrical difference            
       call slist s1,,,'First Set'                                     
       call slist s2,,,'Second Set'                                    
       call slist s3,,,'Symmetrical Difference'                        

    Result::

            Entries of Source Array: 0                        
        Entry   First Set                                      
        -------------------------------------------------------
        00001   0002                                           
        00002   0003                                           
        00003   0004                                           
        00004   0005                                           
        00005   0006                                           
        00006   0007                                           
        00007   0008                                           
        00008   0009                                           
        00009   0010                                           
        00010   0012                                           
        10 Entries                                             
            Entries of Source Array: 1                        
        Entry   Second Set                                     
        -------------------------------------------------------
        00001   0003                                           
        00002   0004                                           
        00003   0005                                           
        00004   0006                                           
        00005   0007                                           
        00006   0008                                           
        6 Entries                                              
            Entries of Source Array: 4                        
        Entry   Symmetrical Difference                         
        -------------------------------------------------------
        00001   0002                                           
        00002   0009                                           
        00003   0010                                           
        00004   0012                                           
        4 Entries                                              

Integer Array Functions
-----------------------

.. function:: ICREATE(elements,mode)

    Creates an integer array with the size elements. Returned is the 
    array number to be used to address the array with ISET and IGET. You 
    can have up to 64 integer arrays. Depending on the virtual storage 
    they may contain 1 million elements and more. Accessing integer 
    arrays is very fast as there is no overhead compared to STEM variables.
    
    :param elements: Number entries available 
    :param mode: The initialization type. If mode is not set the array remains uninitialized.

    +-----------------+----------------------------------------+
    | Mode            | Description                            |
    +=================+========================================+
    | Element-Number  | index of element                       |
    +-----------------+----------------------------------------+
    | NULL            | elements are set to 0                  |
    +-----------------+----------------------------------------+
    | DESCENT         | index of the element in reverse order  |
    +-----------------+----------------------------------------+
    | SUNDARAM        | prime numbers (Sundaram algorithm)     |
    +-----------------+----------------------------------------+
    | PRIME           | prime numbers (sieve of Erasthones)    |
    +-----------------+----------------------------------------+

.. function:: ISET(array-number,element-number,integer-value) 
    
    Sets a certain element of an array with an integer value.

.. function:: IGET(array-number,element-number)
    
    Gets (returns) a certain element of an array with an integer value.

Integer Matrix
--------------

The integer matrix is based on an integer array, the rows and columns are 
internally translated into the position in the array. 

.. function:: IMCREATE(rows,columns)

    Creates an integer matrix containing the specified number of rows and 
    columns. The matrix is initialized with zeros. 

    :returns: allocated array-number which can be used in subsequent array functions. 

.. function:: IMSET(array-number,row,column,integer-value)

    Sets a certain element of the matrix to an integer value.

.. function:: IMGET(array-number,row,column)

    Gets (returns) a certain element of the matrix.

.. function:: IMADD(array-number,row,column,integer-value)

    Adds an integer value to a certain element of the matrix.

.. function:: IMSUB(array-number,row,column,integer-value)

    Subtracts an integer value from a certain element of the matrix.

.. function:: IARRAY(array-number,’ROW’/’COLUMN)`

    :returns: the number of rows or columns of the matrix.

.. function:: IFREE(array-number)

    Frees a defined integer array or matrix.

Float Array
-----------

.. function:: FCREATE(elements,mode)

    Creates an float array with the size elements. Returned is the array 
    number to be used to address the array with FSET and FGET. You can 
    have up to 64 integer arrays. 
    
    :returns: the allocated array-number which can be used in subsequent array functions. 

.. function:: FSET(array-number,element-number,float-value)

    Sets a certain element of an array with a float value.

.. function:: FGET(array-number,element-number)

    :returns: (gets) a certain element of the float array.

.. function:: FARRAY(array-number)

    :returns: the highest array index set in the float array 

.. function:: FLIST(array-number,[from],[to],[heading]) 

    Prints the array content. With the optional from and to parameters, you 
    can limit the range of entries to be printed. The optional heading 
    parameter is printed in the heading line.   

.. function:: FFREE(array-number)
        
    Frees a defined float array.

Linked List functions
---------------------

.. function:: LLCREATE() 

    Creates a Linked List, returned is the Linked List Number(llist-number) 
    which must be used in various Linked List operations. 

    The Linked List is bidirectional. You can have up to 32 different Linked 
    Lists, depending on the virtual storage availability.

    :returns: the allocated linked-list-number which can be used in subsequent linked list functions. 

.. function:: LLFREE(llist-number) 
    
    Removes the Linked List and all its entries. All storage allocations are freed.  

.. function:: LLCLEAR(llist-number) 
    
    Clears (removes) the Linked List entries, but the list header remains 
    intact. From there you can add new entries to it.   

.. function:: LLADD(llist-number,”entry-text”)

    Adds a new entry (llentry) at the end of the Linked List and links up the 
    previous entry with a forward and the new entry backward reference.  If 
    the operation is successful a pointer (llpointer) to the new entry is 
    returned. If the operation fails a return code < 0 is returned. 

    The internal current pointer (llcurrent) is set to the new entry and can 
    be used in subsequent Linked List operations. 

    Example see `LLINSERT`

.. function:: LLDEL(llist-number,[llist-pointer])

    Removes an entry, defined by the current entry or the specified llist-pointer 
    (llpointer. If the operation was successful the internal current pointer 
    (llcurrent) is set to the next entry, if there is no one, to the last 
    element. Returned will be the internal current pointer (llcurrent). If the 
    operation fails a return code < 0 is returned.

    Example:

    .. code-block:: rexx
       :linenos:
    
       ll1=llread("'pej.songs2'")           /* Create Linked List */    
       call lllist ll1                                                  
       call llset(ll1,"POSITION",3)         /* set to 3. Entry    */    
       call lldel(ll1)                      /* remove AC/DC       */    
       call lllist ll1                                                  
       call llfree ll1 

    Result::

             Entries of Linked List: 0 (0)                                                                      
        Entry Entry Address     Next    Previous      Data                                                      
        -------------------------------------------------------                                                 
            1     3061c8      306258           0   LED ZEPPELIN                  STAIRWAY TO HEAVEN             
            2     306258      3062e8      3061c8   EAGLES                        HOTEL CALIFORNIA               
            3     3062e8      306378      306258   AC/DC                         BACK IN BLACK                  
            4     306378      306408      3062e8   JOURNEY                       DON'T STOP BELIEVIN'           
            5     306408      306498      306378   PINK FLOYD                    ANOTHER BRICK IN THE WALL      
            6     306498      306528      306408   QUEEN                         BOHEMIAN RHAPSODY              
            7     306528      3065b8      306498   TOTO                          HOLD THE LINE                  
            8     3065b8      306648      306528   KISS                          I WAS MADE FOR LOVIN' YOU      
            9     306648      3066d8      3065b8   BON JOVI                      LIVIN' ON A PRAYER             
           10     3066d8      306768      306648   NIRVANA                       SMELLS LIKE TEEN SPIRIT        
           11     306768      3067f8      3066d8   DEEP PURPLE                   SMOKE ON THE WATER             
           12     3067f8      306888      306768   METALLICA                     NOTHING ELSE MATTERS           
           13     306888      306918      3067f8   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION  
           14     306918      3069a8      306888   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.             
           15     3069a8      305498      306918   QUEEN                         WE WILL ROCK YOU               
           16     305498      306a38      3069a8   LYNYRD SKYNYRD                FREE BIRD                      
           17     306a38      306ac8      305498   SURVIVOR                      EYE OF THE TIGER               
           18     306ac8      305458      306a38   THE CLASH                     SHOULD I STAY OR SHOULD I GO   
           19     305458      305658      306ac8   JIMI HENDRIX                  HEY JOE                        
           20     305658      306b58      305458   FLEETWOOD MAC                 LITTLE LIES                    
           21     306b58      305618      305658   AC/DC                         HIGHWAY TO HELL                
           22     305618           0      306b58   THE POLICE                    ROXANNE                        
        Linked List contains 22 Entries   
               List counter  22 Entries                                                                         
        Current active Entry 305618                                                                             
             Entries of Linked List: 0 (0)                                                                      
        Entry Entry Address     Next    Previous      Data                                                      
        -------------------------------------------------------                                                 
            1     3061c8      306258           0   LED ZEPPELIN                  STAIRWAY TO HEAVEN             
            2     306258      306378      3061c8   EAGLES                        HOTEL CALIFORNIA               
            3     306378      306408      306258   JOURNEY                       DON'T STOP BELIEVIN'           
            4     306408      306498      306378   PINK FLOYD                    ANOTHER BRICK IN THE WALL      
            5     306498      306528      306408   QUEEN                         BOHEMIAN RHAPSODY              
            6     306528      3065b8      306498   TOTO                          HOLD THE LINE                  
            7     3065b8      306648      306528   KISS                          I WAS MADE FOR LOVIN' YOU      
            8     306648      3066d8      3065b8   BON JOVI                      LIVIN' ON A PRAYER             
            9     3066d8      306768      306648   NIRVANA                       SMELLS LIKE TEEN SPIRIT        
           10     306768      3067f8      3066d8   DEEP PURPLE                   SMOKE ON THE WATER             
           11     3067f8      306888      306768   METALLICA                     NOTHING ELSE MATTERS           
           12     306888      306918      3067f8   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION  
           13     306918      3069a8      306888   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.             
           14     3069a8      305498      306918   QUEEN                         WE WILL ROCK YOU               
           15     305498      306a38      3069a8   LYNYRD SKYNYRD                FREE BIRD                      
           16     306a38      306ac8      305498   SURVIVOR                      EYE OF THE TIGER               
           17     306ac8      305458      306a38   THE CLASH                     SHOULD I STAY OR SHOULD I GO   
           18     305458      305658      306ac8   JIMI HENDRIX                  HEY JOE                        
           19     305658      306b58      305458   FLEETWOOD MAC                 LITTLE LIES                    
           20     306b58      305618      305658   AC/DC                         HIGHWAY TO HELL                
           21     305618           0      306b58   THE POLICE                    ROXANNE         
        Linked List contains 21 Entries   
               List counter  21 Entries   
        Current active Entry 306378   
                                                                                         
.. function:: LLINSERT(llist-number,”entry-text”[,llist-pointer])

    Inserts a new entry (llentry) before the current entry or the specified 
    llist-pointer. All link information from the predecessor and successor 
    entries is updated. 
    
    If the operation is successful a pointer (llpointer) to the inserted entry
    is returned. If the operation fails a return code < 0 is returned. 

    The internal current pointer (llcurrent) is set to the new entry and can be 
    used in subsequent Linked List operations. 

    Example:

    .. code-block:: rexx
       :linenos:
    
       ll1=llread("'pej.songs2'")           /* Create Linked List */    
       say copies('-',32)                                               
       say "Run Through Linked List"                                    
       say copies('-',32)                                               
       say llget(ll1,"FIRST")                                           
       do while llset(ll1,"NEXT")>0                                     
          say llget(ll1)                                                
       end                                                              
       call llset(ll1,"POSITION",2)       /* set to 1. Entry    */      
       call llinsert(ll1,"CREAM                         I AM SO GLAD")  
       call lllist ll1                                                  
       call llfree ll1                                                  

    Result::
        
        --------------------------------                              
        Run Through Linked List                                       
        --------------------------------                              
        LED ZEPPELIN                  STAIRWAY TO HEAVEN              
        EAGLES                        HOTEL CALIFORNIA                
        AC/DC                         BACK IN BLACK                   
        JOURNEY                       DON'T STOP BELIEVIN'            
        PINK FLOYD                    ANOTHER BRICK IN THE WALL       
        QUEEN                         BOHEMIAN RHAPSODY               
        TOTO                          HOLD THE LINE                   
        KISS                          I WAS MADE FOR LOVIN' YOU       
        BON JOVI                      LIVIN' ON A PRAYER              
        NIRVANA                       SMELLS LIKE TEEN SPIRIT         
        DEEP PURPLE                   SMOKE ON THE WATER              
        METALLICA                     NOTHING ELSE MATTERS            
        THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION   
        BRUCE SPRINGSTEEN             BORN IN THE U.S.A.              
        QUEEN                         WE WILL ROCK YOU                
        LYNYRD SKYNYRD                FREE BIRD                       
        SURVIVOR                      EYE OF THE TIGER                
        THE CLASH                     SHOULD I STAY OR SHOULD I GO    
        JIMI HENDRIX                  HEY JOE                         
        FLEETWOOD MAC                 LITTLE LIES                     
        AC/DC                         HIGHWAY TO HELL                 
        THE POLICE                    ROXANNE                         
             Entries of Linked List: 0 (0) 
        Entry Entry Address     Next    Previous      Data                                                      
        -------------------------------------------------------                                                 
            1     305258      305138           0   LED ZEPPELIN                  STAIRWAY TO HEAVEN             
            2     305138      3052e8      305258   CREAM                         I AM SO GLAD                   
            3     3052e8      305378      305258   EAGLES                        HOTEL CALIFORNIA               
            4     305378      305408      3052e8   AC/DC                         BACK IN BLACK                  
            5     305408      305498      305378   JOURNEY                       DON'T STOP BELIEVIN'           
            6     305498      305528      305408   PINK FLOYD                    ANOTHER BRICK IN THE WALL      
            7     305528      3055b8      305498   QUEEN                         BOHEMIAN RHAPSODY              
            8     3055b8      305648      305528   TOTO                          HOLD THE LINE                  
            9     305648      3056d8      3055b8   KISS                          I WAS MADE FOR LOVIN' YOU      
           10     3056d8      305768      305648   BON JOVI                      LIVIN' ON A PRAYER             
           11     305768      3057f8      3056d8   NIRVANA                       SMELLS LIKE TEEN SPIRIT        
           12     3057f8      305888      305768   DEEP PURPLE                   SMOKE ON THE WATER             
           13     305888      305918      3057f8   METALLICA                     NOTHING ELSE MATTERS           
           14     305918      3059a8      305888   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION  
           15     3059a8      305a38      305918   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.             
           16     305a38      304818      3059a8   QUEEN                         WE WILL ROCK YOU               
           17     304818      305ac8      305a38   LYNYRD SKYNYRD                FREE BIRD                      
           18     305ac8      305b58      304818   SURVIVOR                      EYE OF THE TIGER               
           19     305b58      3047d8      305ac8   THE CLASH                     SHOULD I STAY OR SHOULD I GO   
           20     3047d8      3049d8      305b58   JIMI HENDRIX                  HEY JOE                        
           21     3049d8      305be8      3047d8   FLEETWOOD MAC                 LITTLE LIES                    
           22     305be8      304998      3049d8   AC/DC                         HIGHWAY TO HELL                
           23     304998           0      305be8   THE POLICE                    ROXANNE                        
        Linked List contains 23 Entries          
               List counter  23 Entries    
        Current active Entry 305138  

.. function:: LLGET(llist-number[option/llist-pointer])
    
    :returns: the entry referred by the option or internal current pointer, or the specified llist-pointer.  The internal current pointer (llcurrent) is not changed. 
    :param option:
        - NEXT sets it to the next element after llcurrent in the Linked List chain. If llcurrent was the last element 0 is returned.   
        - PREVIOUS sets it to the previous element of llcurrent in the Linked List chain. If llcurrent was the first element 0 is returned.   
        - FIRST sets it to the first element in the Linked List. 
        - LAST sets it to the last element in the Linked List. 

    Example:
    
    .. code-block:: rexx
       :linenos:
    
       ll1=llread("'pej.songs2'")           /* Create Linked List */   
       say copies('-',32)                                              
       say "Run Through Linked List"                                   
       say copies('-',32)                                              
       say llget(ll1,"FIRST")                                          
       do while llset(ll1,"NEXT")>0                                    
          say llget(ll1)                                               
       end                                                             
       call llfree ll1                                                 

    Result::

        --------------------------------                             
        Run Through Linked List                                      
        --------------------------------                             
        LED ZEPPELIN                  STAIRWAY TO HEAVEN             
        EAGLES                        HOTEL CALIFORNIA               
        AC/DC                         BACK IN BLACK                  
        JOURNEY                       DON'T STOP BELIEVIN'           
        PINK FLOYD                    ANOTHER BRICK IN THE WALL      
        QUEEN                         BOHEMIAN RHAPSODY              
        TOTO                          HOLD THE LINE                  
        KISS                          I WAS MADE FOR LOVIN' YOU      
        BON JOVI                      LIVIN' ON A PRAYER             
        NIRVANA                       SMELLS LIKE TEEN SPIRIT        
        DEEP PURPLE                   SMOKE ON THE WATER             
        METALLICA                     NOTHING ELSE MATTERS           
        THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION  
        BRUCE SPRINGSTEEN             BORN IN THE U.S.A.             
        QUEEN                         WE WILL ROCK YOU               
        LYNYRD SKYNYRD                FREE BIRD                      
        SURVIVOR                      EYE OF THE TIGER               
        THE CLASH                     SHOULD I STAY OR SHOULD I GO   
        JIMI HENDRIX                  HEY JOE                        
        FLEETWOOD MAC                 LITTLE LIES                    
        AC/DC                         HIGHWAY TO HELL                
        THE POLICE                    ROXANNE                        

.. function:: LLSET(llist-number,option[,sub-option])

    Changes the internal current pointer according to the specified option and returns it as a pointer.

    :param option:
        - NEXT sets it to the next element after llcurrent in the Linked List chain. If llcurrent was the last element 0 is returned.   
        - PREVIOUS sets it to the previous element of llcurrent in the Linked List chain. If llcurrent was the first element 0 is returned.   
        - FIRST sets it to the first element in the Linked List. 
        - LAST sets it to the last element in the Linked List. 
        - POSITION sets it to n.th entry, as defined in sub-option. If the specified number is not available it is set to the last entry.  
        - CURRENT returns the current internal current pointer.
        - ADDRESS sets it according to the address defined in the sub-option. 

.. function:: LLCOPY(llist-number,[from],[to],[existing-list],[”list-name”]) 
    
    Creates a copy of the Linked List. If an existing linked-list is specified, 
    the entries are added after its existing entries.

    :param from: (optional) starts the copying process at from.th entry. 
    :param to:  (optional) ends the copying process with to.th entry.
    :param existing-list: (optional) appending an existing Source Array, else a new one will be created
    :param list-name: (optional) names the new/appended Link List

    :returns: the newly created or appended Linked List Number(llist-number)

    Example:

    .. code-block:: rexx
       :linenos:
    
       max=10                                                         
       ll1=llcreate()                       /* Create Linked List */  
       ll2=llcreate()                       /* Create Linked List */  
       call time('r')                                                 
       do i=1 to max                                                  
          adr=lladd(ll1,i". Record")                                  
       end                                                            
       call llList ll1                                                
       do i=1 to 5                                                  
          adr=lladd(ll2,i". Entry")                                   
       end                                                            
       call llList ll2                                                
       ll3=llcopy(ll1,,,ll2,"Copied")                                 
       call llList ll3


    Result::
        
              Entries of Linked List: 0 (UNNAMED)               
         Entry Entry Address     Next    Previous      Data     
         -------------------------------------------------------
             1     2e3258      2e3278           0   1. Record   
             2     2e3278      2e3298      2e3258   2. Record   
             3     2e3298      2e32b8      2e3278   3. Record   
             4     2e32b8      2e32d8      2e3298   4. Record   
             5     2e32d8      2e32f8      2e32b8   5. Record   
             6     2e32f8      2e3318      2e32d8   6. Record   
             7     2e3318      2e3338      2e32f8   7. Record   
             8     2e3338      2e3358      2e3318   8. Record   
             9     2e3358      2e3378      2e3338   9. Record   
            10     2e3378           0      2e3358   10. Record  
         Linked List contains 10 Entries                        
                List counter  10 Entries                        
         Current active Entry 2e3378                            

              Entries of Linked List: 1 (UNNAMED)               
         Entry Entry Address     Next    Previous      Data     
         -------------------------------------------------------
             1     2e3398      2e33b8           0   1. Entry    
             2     2e33b8      2e33d8      2e3398   2. Entry    
             3     2e33d8      2e33f8      2e33b8   3. Entry    
             4     2e33f8      2e3418      2e33d8   4. Entry    
             5     2e3418           0      2e33f8   5. Entry    
        Current active Entry 2e3418  
        Linked List contains 5 Entries                         
               List counter  5 Entries                         

             Entries of Linked List: 1 (Copied)               
        Entry Entry Address     Next    Previous      Data    
        ------------------------------------------------------
            1     2e3398      2e33b8           0   1. Entry   
            2     2e33b8      2e33d8      2e3398   2. Entry   
            3     2e33d8      2e33f8      2e33b8   3. Entry   
            4     2e33f8      2e3418      2e33d8   4. Entry   
            5     2e3418      2e3458      2e33f8   5. Entry   
            6     2e3458      2e3478      2e3418   1. Record  
            7     2e3478      2e3498      2e3458   2. Record  
            8     2e3498      2e34b8      2e3478   3. Record  
            9     2e34b8      2e34d8      2e3498   4. Record  
           10     2e34d8      2e34f8      2e34b8   5. Record  
           11     2e34f8      2e3518      2e34d8   6. Record  
           12     2e3518      2e3538      2e34f8   7. Record  
           13     2e3538      2e3558      2e3518   8. Record  
           14     2e3558      2e3578      2e3538   9. Record  
           15     2e3578           0      2e3558   10. Record 
        Linked List contains 15 Entries                       
               List counter  15 Entries                       
        Current active Entry 2e3578     

.. function:: LLENTRY(llist-number [,llist-pointer]))

    Dumps the details of an entry either defined by the internal current pointer
    (llcurrent) or the llist-pointer.  

    Example::

        ---------------------------------------------
        Linked List Entry                            
        ---------------------------------------------
        Address  326f18                              
        Data     42. Record                          
        Next     326f58                              
        Previous 326ed8 

.. function:: LLLIST(llist-number[,from],[to]) 

    Outputs a detailed list of all entries on a Linked list::  

             Entries of Linked List: 0                          
        Entry Entry Address     Next    Previous      Data      
        ------------------------------------------------------- 
            1     326458      326498           0   1. Record    
            2     326498      3264d8      326458   2. Record    
            3     3264d8      326518      326498   3. Record    
            4     326518      326558      3264d8   4. Record    
            5     326558      326598      326518   5. Record    
            6     326598      3265d8      326558   6. Record    
            7     3265d8      326618      326598   7. Record    
            8     326618      326658      3265d8   8. Record    
            9     326658      326698      326618   9. Record    
           10     326698      3266d8      326658   10. Record   
           11     3266d8      326718      326698   11. Record   
           12     326718      326758      3266d8   12. Record  
        ...

.. function:: LLDETAILS(llist-number,option) 

    Output statistics on the Linked List.

    :param option:
        - COUNT returns the number of current entries in the Linked List. 
        - ADDED returns the number of added/inserted entries in the Linked List. 
        - DELETED returns the number of deleted entries in the Linked List. 
        - LIST returns the listed number of current entries in the Linked List. For this reason, it runs through the entire Linked List and counts the entries.  LIST and COUNT should be equal, else there are inconsistencies in the Linked List.
        - FULL print all available information

    Example::

        CALL LLDETAILS(0,’FULL’)


        Attributes of Linked List 0                            
        -------------------------------------------------------
        Entry Count     9999                                     
            Listed     9999                                     
            Added     10000                                     
            Deleted     1                                      
        Current Pointer 326ed8  

.. function:: LLDELINK(llist-number[,llist-pointer]) 

    Similar to LLDEL an entry defined by the current entry or the specified 
    llist-pointer is removed from the Link List but is kept in storage as an 
    orphan, which might be later inserted in a different position in the same 
    or a different Linked List. This is a fast way of moving elements. 

    :returns: the address of the orphaned entry. 

    If the operation was successful the internal current pointer (llcurrent) is 
    set to the next entry, and if there is no one, to the last element.
    
    The example is contained in the `LLLINK` sample.

.. function:: LLLINK(llist-number,llist-pointer) 

    Links an orphaned entry to the Linked List prior to the current entry and 
    sets the pointers accordingly.
    
    If the operation was successful, the internal current pointer (llcurrent) is 
    set to the newly inserted entry. 

    Example:

    .. code-block:: rexx
       :linenos:
    
       max=10                                                           
       ll1=llcreate()                       /* Create Linked List */    
       ll2=llcreate()                       /* Create Linked List */    
       do i=1 to max                                                    
          adr=lladd(ll1,i". Record")        /* add new entry      */    
       end                                                              
       call llList ll1                                                  
       posadr=llset(ll1,"POSITION",7)       /* set to 7. Entry    */    
       deladr=lldelink(ll1,posadr)          /* DELINK it          */    
       say "is now de-linked,ADDR "d2x(deladr)                          
       call llList ll1                                                  
       say "Insert one entry to LL2 "d2x(llinsert(ll2,"1. Entry"))      
       call llList ll2                                                  
       say "LINK into new LList "d2x(llLink(ll2,deladr))                
       call llList ll2    

    Result::

             Entries of Linked List: 0 (UNNAMED)              
        Entry Entry Address     Next    Previous      Data    
        ------------------------------------------------------
            1     2db238      2db258           0   1. Record  
            2     2db258      2db278      2db238   2. Record  
            3     2db278      2db298      2db258   3. Record  
            4     2db298      2db2b8      2db278   4. Record  
            5     2db2b8      2db2d8      2db298   5. Record  
            6     2db2d8      2db2f8      2db2b8   6. Record  
            7     2db2f8      2db318      2db2d8   7. Record  
            8     2db318      2db338      2db2f8   8. Record  
            9     2db338      2db358      2db318   9. Record  
           10     2db358           0      2db338   10. Record 
        Linked List contains 10 Entries                       
               List counter  10 Entries                       
        is now de-linked,ADDR 2DB2F8                          
             Entries of Linked List: 0 (UNNAMED)              
        Entry Entry Address     Next    Previous      Data    
        ------------------------------------------------------
            1     2db238      2db258           0   1. Record  
            2     2db258      2db278      2db238   2. Record  
            3     2db278      2db298      2db258   3. Record  
            4     2db298      2db2b8      2db278   4. Record  
            5     2db2b8      2db2d8      2db298   5. Record  
            6     2db2d8      2db318      2db2b8   6. Record  
            7     2db318      2db338      2db2d8   8. Record  
            8     2db338      2db358      2db318   9. Record   
            9     2db358           0      2db338   10. Record  
        Linked List contains 9 Entries                         
               List counter  9 Entries                         
        Insert one entry to LL2 2DB3D8                         
             Entries of Linked List: 1 (UNNAMED)               
        Entry Entry Address     Next    Previous      Data     
        -------------------------------------------------------
            1     2db3d8           0           0   1. Entry    
        Linked List contains 1 Entries                         
               List counter  1 Entries                         
        LINK into new LList 2DB2F8                             
             Entries of Linked List: 1 (UNNAMED)               
        Entry Entry Address     Next    Previous      Data     
        -------------------------------------------------------
            1     2db2f8      2db3d8           0   7. Record   
            2     2db3d8           0           0   1. Entry    
        Linked List contains 2 Entries                         
               List counter  2 Entries                         

.. function:: LLSORT(llist--number,[ASCENDING/DESCENDING],[sort-offset])

    Sorts the Linked List using the quick sort algorithm in ascending or 
    descending order, default is ascending.
    
    The sort offset defines the sorting scope up to the end of the item, any
    substrings before it are not treated. If you define for example 5, the 
    array is sorted at offset 5 (up to the rest of the item). The sort-offset
    defaults to 1.  

    :returns: the Linked List Number(llist-number), it is the same as the entry list.

    Example:

    .. code-block:: rexx
       :linenos:
    
       ll1=llread("'pej.songs2'")   
       call llList ll1              
       call llsort ll1              
       call llList ll1    /* sort from column 1, band name */          
       call llfree ll1  
                                                                                       
    Result::

             Entries of Linked List: 0 (0)                                                                           
        Entry Entry Address     Next    Previous      Data                                                           
        -------------------------------------------------------                                                      
            1     3371c8      337258           0   LED ZEPPELIN                  STAIRWAY TO HEAVEN                  
            2     337258      3372e8      3371c8   EAGLES                        HOTEL CALIFORNIA                    
            3     3372e8      337378      337258   AC/DC                         BACK IN BLACK                       
            4     337378      337408      3372e8   JOURNEY                       DON'T STOP BELIEVIN'                
            5     337408      337498      337378   PINK FLOYD                    ANOTHER BRICK IN THE WALL           
            6     337498      337528      337408   QUEEN                         BOHEMIAN RHAPSODY                   
            7     337528      3375b8      337498   TOTO                          HOLD THE LINE                       
            8     3375b8      337648      337528   KISS                          I WAS MADE FOR LOVIN' YOU           
            9     337648      3376d8      3375b8   BON JOVI                      LIVIN' ON A PRAYER                  
           10     3376d8      337768      337648   NIRVANA                       SMELLS LIKE TEEN SPIRIT             
           11     337768      3377f8      3376d8   DEEP PURPLE                   SMOKE ON THE WATER                  
           12     3377f8      337888      337768   METALLICA                     NOTHING ELSE MATTERS                
           13     337888      337918      3377f8   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION       
           14     337918      3379a8      337888   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.                  
           15     3379a8      336258      337918   QUEEN                         WE WILL ROCK YOU                    
           16     336258      337a38      3379a8   LYNYRD SKYNYRD                FREE BIRD                           
           17     337a38      337ac8      336258   SURVIVOR                      EYE OF THE TIGER                    
           18     337ac8      336218      337a38   THE CLASH                     SHOULD I STAY OR SHOULD I GO        
           19     336218      336418      337ac8   JIMI HENDRIX                  HEY JOE                             
           20     336418      337b58      336218   FLEETWOOD MAC                 LITTLE LIES                         
           21     337b58      3363d8      336418   AC/DC                         HIGHWAY TO HELL                     
           22     3363d8           0      337b58   THE POLICE                    ROXANNE                             
        Linked List contains 22 Entries                                                                              
               List counter  22 Entries                                                                      
        Current active Entry 3363d8                                                                          
             Entries of Linked List: 0 (0)                                                                   
        Entry Entry Address     Next    Previous      Data                                                   
        -------------------------------------------------------                                              
            1     300a38      3009a8           0   AC/DC                         BACK IN BLACK               
            2     3009a8      300918      300a38   AC/DC                         HIGHWAY TO HELL             
            3     300918      300888      3009a8   BON JOVI                      LIVIN' ON A PRAYER          
            4     300888      3007f8      300918   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.          
            5     3007f8      300768      300888   DEEP PURPLE                   SMOKE ON THE WATER          
            6     300768      337b58      3007f8   JOURNEY                       DON'T STOP BELIEVIN'        
            7     337b58      337ac8      300768   KISS                          I WAS MADE FOR LOVIN' YOU   
            8     337ac8      337a38      337b58   NIRVANA                       SMELLS LIKE TEEN SPIRIT     
            9     337a38      3379a8      337ac8   PINK FLOYD                    ANOTHER BRICK IN THE WALL   
           10     3379a8      337918      337a38   QUEEN                         BOHEMIAN RHAPSODY           
           11     337918      337888      3379a8   TOTO                          HOLD THE LINE               
           12     337888      3363d8      337918   EAGLES                        HOTEL CALIFORNIA            
           13     3363d8      336418      337888   FLEETWOOD MAC                 LITTLE LIES                 
           14     336418      3377f8      3363d8   JIMI HENDRIX                  HEY JOE                     
           15     3377f8      336218      336418   LED ZEPPELIN                  STAIRWAY TO HEAVEN          
           16     336218      337768      3377f8   LYNYRD SKYNYRD                FREE BIRD                   
           17     337768      3376d8      336218   METALLICA                     NOTHING ELSE MATTERS        
           18     3376d8      337648      337768   QUEEN                         WE WILL ROCK YOU            
           19     337648      3375b8      3376d8   SURVIVOR                      EYE OF THE TIGER            
           20     3375b8      336258      337648   THE CLASH                     SHOULD I STAY OR SHOULD I GO
           21     336258      337528      3375b8   THE POLICE                    ROXANNE    
           22     337528           0      336258   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION   
        Linked List contains 22 Entries                                                                          
               List counter  22 Entries                                                                          
        Current active Entry 337528                                                                                                                                  

.. function:: LLWRITE(llist-number,dsn/ddname) 

    Writes all entries of a Linked List into an external dataset.  

    The dataset can be either a fully qualified Dataset Name or a pre-allocated
    DD Name.

    :returns: the number of written entries. 

    An example is contained in `LLREAD`

.. function:: LLREAD(dsn/ddname) 
    
    Reads all entries of an external dataset. The dataset can be either a fully 
    qualified Dataset Name or a pre-allocated DD Name.

    :returns: the newly created Linked List Number(llist-number).

    Example:

    .. code-block:: rexx
       :linenos:
    
       ll1=llread("'pej.songs2'")                           
       call lllist ll1                                    
       say "Records written: "llwrite(ll1,"'pej.temp'") 
    
    Result::

             Entries of Linked List: 0 (0)                                                                      
        Entry Entry Address     Next    Previous      Data                                                      
        -------------------------------------------------------                                                 
            1     3371c8      337258           0   LED ZEPPELIN                  STAIRWAY TO HEAVEN             
            2     337258      3372e8      3371c8   EAGLES                        HOTEL CALIFORNIA               
            3     3372e8      337378      337258   AC/DC                         BACK IN BLACK                  
            4     337378      337408      3372e8   JOURNEY                       DON'T STOP BELIEVIN'           
            5     337408      337498      337378   PINK FLOYD                    ANOTHER BRICK IN THE WALL      
            6     337498      337528      337408   QUEEN                         BOHEMIAN RHAPSODY              
            7     337528      3375b8      337498   TOTO                          HOLD THE LINE                  
            8     3375b8      337648      337528   KISS                          I WAS MADE FOR LOVIN' YOU      
            9     337648      3376d8      3375b8   BON JOVI                      LIVIN' ON A PRAYER             
           10     3376d8      337768      337648   NIRVANA                       SMELLS LIKE TEEN SPIRIT        
           11     337768      3377f8      3376d8   DEEP PURPLE                   SMOKE ON THE WATER             
           12     3377f8      337888      337768   METALLICA                     NOTHING ELSE MATTERS           
           13     337888      337918      3377f8   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION  
           14     337918      3379a8      337888   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.             
           15     3379a8      336358      337918   QUEEN                         WE WILL ROCK YOU               
           16     336358      337a38      3379a8   LYNYRD SKYNYRD                FREE BIRD                      
           17     337a38      337ac8      336358   SURVIVOR                      EYE OF THE TIGER               
           18     337ac8      336318      337a38   THE CLASH                     SHOULD I STAY OR SHOULD I GO   
           19     336318      336518      337ac8   JIMI HENDRIX                  HEY JOE                        
           20     336518      337b58      336318   FLEETWOOD MAC                 LITTLE LIES                    
           21     337b58      3364d8      336518   AC/DC                         HIGHWAY TO HELL                
           22     3364d8           0      337b58   THE POLICE                    ROXANNE                        
        Records written: 22                                              


.. function:: MCREATE(rows,columns)
    
    Creates a (Float) matrix with size `[rows x columns]`. Returned is the 
    Matrix number to be used in various matrix operations. You can have 
    up to 128 matrixes, depending on the virtual storage available. 
    Accessing a matrix is very fast as there is no overhead compared to 
    STEM variables.

.. function:: MSET(matrix-number,row,column,float-value)
    
    Sets a certain element of the matrix with a float value.

.. function:: MGET(matrix-number,row,column)
    
    Gets (returns) a certain element of the matrix.

.. function:: MMULTIPLY(matrix-number-1,matrix-number-2)
    
    Multiplies 2 matrices and creates a new matrix, which is returned. 
    Input matrices remain untouched. The format of matrix-1 is 
    `[rows x columns]`, therefore the format of matrix-2 must be 
    `[columns x rows]`. The format of the result matrix is rows x rows.

.. function:: MINVERT(matrix-number) 

    Inverts the given matrix and creates a new matrix, which is 
    returned. The input matrix must be squared and remains untouched. 
    The format of the result matrix remains the same as the input 
    matrix.

.. function:: MTRANSPOSE(matrix-number)
    
    Transposes the given matrix and creates a new matrix, which is 
    returned. The input matrix remains untouched. If the format of the 
    input matrix is [rows x columns] then the result matrix is 
    columns x rows.
    
.. function:: MCOPY(matrix-number)
    
    Copies the given matrix and creates a new matrix, which is returned. 
    The input matrix remains untouched. Formats of both matrices are equal.

.. function:: MNORMALISE(matrix-number,mode)
    
    Normalises the given matrix and creates a new matrix, which is 
    returned. The input matrix remains untouched. Formats of both 
    matrices are equal.

    +-----------+----------------------------------------------------------------+
    | Mode      | Description                                                    |
    +===========+================================================================+
    | STANDARD  | row is normalized to mean=0 variance=1                         |
    +-----------+----------------------------------------------------------------+
    | ROWS      | row value is divided by number of rows                         |
    +-----------+----------------------------------------------------------------+
    | MEAN      | row value is normalized to mean=0, variance remains unchanged  |
    +-----------+----------------------------------------------------------------+

.. function:: MDELROW(matrix-number,row-number[,row-number[,row-number...]])
    
    Copies the given matrix without the specified rows-to-delete as a 
    new matrix, which is returned. The input matrix remains untouched.

.. function:: MDELCOL(matrix-number,col-number[,col-number[,col-number...]])

    Copies the given matrix without the specified columns-to-delete as a 
    new matrix, which is returned. The input matrix remains untouched.

.. function:: MPROPERTY(matrix-number[,”FULL”/”BASIC”])
    
    Returns the properties of the given matrix in BREXX variables:

    +--------+------------------------------+
    | _rows  | number of rows of matrix     |
    +--------+------------------------------+
    | _cols  | number of columns of matrix  |
    +--------+------------------------------+

    If **FULL** is specified additionally the the following stem 
    variables are returned:

    +------------------------+---------------------------------------+
    | Stem                   | Description                           |
    +========================+=======================================+
    | _rowmean.column-i      | mean of rows of column-i              |
    +------------------------+---------------------------------------+
    | _rowvariance.column-i  | variance of rows of column-i          |
    +------------------------+---------------------------------------+
    | _rowlow.column-i       | lowest row value of column-i          |
    +------------------------+---------------------------------------+
    | _rowhigh.column-i      | highest row value of column-i         |
    +------------------------+---------------------------------------+
    | _rowsum.column-i       | sum of row value of column-i          |
    +------------------------+---------------------------------------+
    | _rowsqr.column-i       | sum of squared row value of column-i  |
    +------------------------+---------------------------------------+
    | _colsum.row-i          | sum of column values of row-i         |
    +------------------------+---------------------------------------+

.. function:: MSCALAR(matrix-number,number)
    
    Multiplies each element of a matrix with a number (float). The 
    result is stored in a new matrix, which is returned. The input 
    matrix remains untouched.

.. function:: MADD(matrix-number-1, matrix-number-2)
    
    Adds each element of a matrix-1 with the same element of matrix-2. 
    The result is stored in a new matrix, which is returned. The input 
    matrix remains untouched. Matrix-1 and matrix-2 must have the same 
    dimensions.

.. function:: MSUBTRACT(matrix-number-1, matrix-number-2)
    
    Subtracts each element of a matrix-2 from the same element of 
    matrix-1. The result is stored in a new matrix, which is returned. 
    The input matrix remains untouched. Matrix-1 and matrix-2 must have
    the same dimensions.

.. function:: MPROD(matrix-number-1, matrix-number-2)
    
    Multiplies each element of a matrix-1 with the same element of 
    matrix-2. The result is stored in a new matrix, which is returned. 
    The input matrix remains untouched. Matrix-1 and matrix-2 must have 
    the same dimensions.

.. function:: MSQR(matrix-number)
    
    Squares each element of the matrix. The result is stored in a new 
    matrix, which is returned. The input matrix remains untouched.

.. function:: MINSCOL(matrix-number,) 
    
    Inserts a new column as the first column. The initial first column 
    becomes the second column, etc. The result is stored in a new 
    matrix, which is returned. The input matrix remains untouched.

.. function:: MFREE([matrix-number/integer-array-number,“MATRIX”/”INTEGER-ARRAY”])
    
    Frees the storage of allocated matrices and/or integer arrays. If no 
    parameter is specified all allocations are freed. To release a 
    specific matrix or integer-array the matrix-number or 
    integer-array-number must be used as the first parameter, followed 
    by the type to release.

Conversions between String Arrays, Linked Lists, and STEMS
----------------------------------------------------------

.. function:: STEM2S(“stem-name.”) 

    Copies a stem variable into a Source Array, stem-name.0 must contain the 
    number of items. 

    The copy process takes stem-name.1, stem-name.2, … up stem-name.n (where n 
    is contained in stem-name.0) and copies it into a String Array. 

    :returns: the number of the String Array.

    Example:

    .. code-block:: rexx
       :linenos:
    
       xmax=1000                         
       do i=1 to xmax                    
          fred.i=i". record"             
       end                               
       FRED.0=xmax                       
       say "Set Time  "time('e')         
       call time('r')                    
       s1=stem2s("fred.")                
       say "Copy Time "time('e')         
       call slist s1,xmax-10,xmax        

    Result::

        Set Time  0.130996                                     
        Copy Time 0.066642                                     
            Entries of Source Array: 0                        
        Entry   Data                                           
        -------------------------------------------------------
        00990   990. record                                    
        00991   991. record                                    
        00992   992. record                                    
        00993   993. record                                    
        00994   994. record                                    
        00995   995. record                                    
        00996   996. record                                    
        00997   997. record                                    
        00998   998. record                                    
        00999   999. record                                    
        01000   1000. record 

.. function:: S2STEM(“array-number”,”stem-name.”) 
    
    Copies a SARRAY into a stem 

    :returns: the number of the items in the stem (String Array).

Example:

    .. code-block:: rexx
       :linenos:
    
       smax=1000                     
       s1=screate(smax)              
       do i=1 to smax                
          call sset(s1,,"Record "i)  
       end                           
       call slist s1,smax-10,smax    
       call time('r')                
       call s2stem(s1,"Fred.")       
       say "S2STEM "time('e')        
       do i=smax-10 to smax          
          say i fred.i               
       end                           

Result::

            Entries of Source Array: 0                        
        Entry   Data                                           
        -------------------------------------------------------
        00990   Record 990                                     
        00991   Record 991                                     
        00992   Record 992                                     
        00993   Record 993                                     
        00994   Record 994                                     
        00995   Record 995                                     
        00996   Record 996                                     
        00997   Record 997                                     
        00998   Record 998                                     
        00999   Record 999                                     
        01000   Record 1000                                    
        S2STEM 0.253646                                        
        990 Record 990                                         
        991 Record 991                                         
        992 Record 992                                         
        993 Record 993                                         
        994 Record 994                                         
        995 Record 995                                         
        996 Record 996                                         
        997 Record 997                                         
        998 Record 998                                         
        999 Record 999                                         
        1000 Record 1000   

.. function:: S2IARRAY
    
    Copies a SARRAY into an integer array. 

    :returns: the array number of the created array (Integer Array).

.. function:: S2FARRAY

    Copies a SARRAY into a float array. 

    :returns: the array number of the created array (Float Array).

.. function:: S2LL(array-number,[from],[to],[existing-linked-list],[“list-name”]) 

    Copy a String Array into Linked List.

    :param from: (optional) starts the copying process at from.th entry. 
    :param to: (optional) ends the copying process with to.th entry.
    :param existing-list: (optional) appending an existing Linked List, else a new one will be created
    :param list-name: (optional) name of the new/appended Linked List

    :returns: the Linked List Number(llist-number)

    Example:

    .. code-block:: rexx
       :linenos:
    
       s1=sread("'pej.songs2'")    
       call sList s1               
       ll2=s2ll(s1,,,,"LL Songs")  
       call llList(ll2)            
       call sfree(s1)              
       call llfree(ll2)            
    
    Result::
        
             Entries of Source Array: 0                                      
        Entry   Data                                                         
        -------------------------------------------------------              
        00001   LED ZEPPELIN                  STAIRWAY TO HEAVEN             
        00002   EAGLES                        HOTEL CALIFORNIA               
        00003   AC/DC                         BACK IN BLACK                  
        00004   JOURNEY                       DON'T STOP BELIEVIN'           
        00005   PINK FLOYD                    ANOTHER BRICK IN THE WALL      
        00006   QUEEN                         BOHEMIAN RHAPSODY              
        00007   TOTO                          HOLD THE LINE                  
        00008   KISS                          I WAS MADE FOR LOVIN' YOU      
        00009   BON JOVI                      LIVIN' ON A PRAYER             
        00010   NIRVANA                       SMELLS LIKE TEEN SPIRIT        
        00011   DEEP PURPLE                   SMOKE ON THE WATER             
        00012   METALLICA                     NOTHING ELSE MATTERS           
        00013   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION  
        00014   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.             
        00015   QUEEN                         WE WILL ROCK YOU               
        00016   LYNYRD SKYNYRD                FREE BIRD                      
        00017   SURVIVOR                      EYE OF THE TIGER               
        00018   THE CLASH                     SHOULD I STAY OR SHOULD I GO   
        00019   JIMI HENDRIX                  HEY JOE                        
        00020   FLEETWOOD MAC                 LITTLE LIES                    
        00021   AC/DC                         HIGHWAY TO HELL                
        00022   THE POLICE                    ROXANNE                        
             Entries of Linked List: 0 (LL Songs) 
        Entry Entry Address     Next    Previous      Data                                                    
        -------------------------------------------------------                                               
            1     337138      3371c8           0   LED ZEPPELIN                  STAIRWAY TO HEAVEN           
            2     3371c8      337258      337138   EAGLES                        HOTEL CALIFORNIA             
            3     337258      3372e8      3371c8   AC/DC                         BACK IN BLACK                
            4     3372e8      337378      337258   JOURNEY                       DON'T STOP BELIEVIN'         
            5     337378      337408      3372e8   PINK FLOYD                    ANOTHER BRICK IN THE WALL    
            6     337408      337498      337378   QUEEN                         BOHEMIAN RHAPSODY            
            7     337498      337528      337408   TOTO                          HOLD THE LINE                
            8     337528      3375b8      337498   KISS                          I WAS MADE FOR LOVIN' YOU    
            9     3375b8      337648      337528   BON JOVI                      LIVIN' ON A PRAYER           
           10     337648      3376d8      3375b8   NIRVANA                       SMELLS LIKE TEEN SPIRIT      
           11     3376d8      337768      337648   DEEP PURPLE                   SMOKE ON THE WATER           
           12     337768      3377f8      3376d8   METALLICA                     NOTHING ELSE MATTERS         
           13     3377f8      337888      337768   THE ROLLING STONES            (I CAN'T GET NO) SATISFACTION
           14     337888      337918      3377f8   BRUCE SPRINGSTEEN             BORN IN THE U.S.A.           
           15     337918      3362d8      337888   QUEEN                         WE WILL ROCK YOU             
           16     3362d8      3379a8      337918   LYNYRD SKYNYRD                FREE BIRD                    
           17     3379a8      337a38      3362d8   SURVIVOR                      EYE OF THE TIGER             
           18     337a38      336618      3379a8   THE CLASH                     SHOULD I STAY OR SHOULD I GO 
           19     336618      3365d8      337a38   JIMI HENDRIX                  HEY JOE                      
           20     3365d8      337ac8      336618   FLEETWOOD MAC                 LITTLE LIES                  
           21     337ac8      336598      3365d8   AC/DC                         HIGHWAY TO HELL              
           22     336598           0      337ac8   THE POLICE                    ROXANNE                      
        Linked List contains 22 Entries                                                                       
               List counter  22 Entries   
        Current active Entry 336598                                                                                                

.. function:: LL2S(llist-number,[from],[to],[existing-array]) 
    
    Copy a Linked List into a Source Array.

    :param from: (optional) starts the copying process at from.th entry. 
    :param to: (optional) ends the copying process with to.th entry.
    :param existing-array: (optional) appending an existing Source Array, else a new one will be created
    :returns: the Linked List Number(llist-number)

    Example:

    .. code-block:: rexx
       :linenos:
    
       max=8                                        
       ll1=llcreate()                               
       do i=1 to max                                
          adr=lladd(ll1,i". Record")                
       end                                          
       call llList ll1                              
       s1=ll2s(ll1)                                 
       say "Linked List copied into Source Array "s1
       call slist(s1)                               
       call llfree(ll1)                             
       call sfree(s1)                               

    Result::

             Entries of Linked List: 0 (UNNAMED)                
        Entry Entry Address     Next    Previous      Data      
        ------------------------------------------------------- 
            1     2e3218      2e3238           0   1. Record    
            2     2e3238      2e3258      2e3218   2. Record    
            3     2e3258      2e3278      2e3238   3. Record    
            4     2e3278      2e3298      2e3258   4. Record    
            5     2e3298      2e32b8      2e3278   5. Record    
            6     2e32b8      2e32d8      2e3298   6. Record    
            7     2e32d8      2e32f8      2e32b8   7. Record    
            8     2e32f8           0      2e32d8   8. Record    
        Linked List contains 8 Entries                          
               List counter  8 Entries                          
        Current active Entry 2e32f8                             
        Linked List copied into Source Array 0                  
             Entries of Source Array: 0                         
        Entry   Data                                            
        ------------------------------------------------------- 
        00001   1. Record                                       
        00002   2. Record                                       
        00003   3. Record                                       
        00004   4. Record                                       
        00005   5. Record                                       
        00006   6. Record                                       
        00007   7. Record                                       
        00008   8. Record                                       
.. function:: LL2STEM(“llist-number”) 

    Copies a Linked List into a stem 
    :returns: the number of the items in the stem (Linked List entries).

    Example:

    .. code-block:: rexx
       :linenos:
    
       max=1000                                      
       /* -------------------------------------------
        * Copy LLIST into STEM                       
        * -------------------------------------------
        */                                           
       LL1=LLCREATE("LLIST")                         
       do i=1 to max                                 
          call LLADD(LL1,'FRED 'i)                   
       end                                           
       call time('r')                                
       call ll2stem(LL1,'myStem.')                   
       say "LL2STEM "time('e')                       
       do i=mystem.0-10 to mystem.0                  
          say i mystem.i                             
       end   

    Result::

        LL2STEM 0.195885   
        990 FRED 990       
        991 FRED 991       
        992 FRED 992       
        993 FRED 993       
        994 FRED 994       
        995 FRED 995       
        996 FRED 996       
        997 FRED 997       
        998 FRED 998       
        999 FRED 999       
        1000 FRED 1000    

.. function:: STEM2LL(“stem-name.”) 
    
    Copies stem into a Linked List, stem-name.0 must contain the number of items. 
    
    The copy process takes stem-name.1, stem-name.2, … up stem-name.n (where n is
    contained in stem-name.0) and copies it into a Linked List. 

    :returns: the created Linked List number.

    Example:

    .. code-block:: rexx
       :linenos:
    
       max=1000                                      
       /* -------------------------------------------
        * Copy STEM into LLIST                       
        * -------------------------------------------
        */                                           
       do i=1 to max                                 
          myStem.i=i". Record"                       
       end                                           
       mystem.0=max                                  
       call time('r')                                
       ll1=stem2ll('myStem.')                        
       say "STEM2LL "time('e')                       
       call lllist ll1,max-10,max     

    Result::

        STEM2LL 0.080318                                        
             Entries of Linked List: 0 (UNNAMED)                
        Entry Entry Address     Next    Previous      Data      
        ------------------------------------------------------- 
          990     359498      3594d8      359458   990. Record  
          991     3594d8      359518      359498   991. Record  
          992     359518      359558      3594d8   992. Record  
          993     359558      359598      359518   993. Record  
          994     359598      3595d8      359558   994. Record  
          995     3595d8      359618      359598   995. Record  
          996     359618      359658      3595d8   996. Record  
          997     359658      359698      359618   997. Record  
          998     359698      3596d8      359658   998. Record  
          999     3596d8      359718      359698   999. Record  
         1000     359718           0      3596d8   1000. Record 
        Linked List address  34b218                             
        Linked List contains 1000 Entries                       
               List counter  1000 Entries                       
        Current active Entry 359718    