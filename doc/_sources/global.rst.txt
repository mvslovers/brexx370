GLOBAL Variables
================

You can define global variables which can be accessed from within the 
rexx whatever the current procedure variable scope is. STEMS are not 
supported.

.. function:: SETG('variable-name','content')
    
    SETG sets or updates a variable with the given content.

.. function:: GETG('variable-name')
    
    GETG returns the current content of the global variable.

    Example:
    
    .. code-block:: rexx
        :linenos:
    
        call setg('ctime',time('l'))
        call setg('city','Munich')
        call testproc
        exit 0
        
        testproc: procedure
          /* normal variable scope can't access variables from the calling rexx */
          say 'Global Variables from the calling REXX'
          say getg('ctime')
          say getg('city')
        return 0
    
    Result::
        
        GLOBAL VARIABLES FROM THE CALLING REXX
        19:45:12.538474                       
        MUNICH           