Building TSO Commands
=====================

A BREXX function can be converted to work as a TSO command by creating a
clist and call the BREXX script. To perform the new clist, it must be
stored in one of the pre-allocated clists libraries which are active in
your TSO session; alternatively, you can use `SYS2.CMDPROC`. Once this 
is done, you can call it from TSO directly.

LA List all allocated Libraries
-------------------------------

The clist calls the BREXX LISTALC script with a BREXX CALL statement. A minus sign immediately following the
REXX command tells BREXX to interpret a BREXX statement. The statement(s) must be coded in one line. To
place more than one BREXX statement in a line, separate them by using a semicolon ‘;’.

.. code-block:: clist
    :linenos:
    
    REXX -               
    CALL LISTALC('PRINT')

WHOAMI Display current User Id
--------------------------------
This one-liner outputs the `userid()` function by a say statement.

.. code-block:: clist
    :linenos:

    REXX -
    SAY USERID()

TODAY
-----

Display today's Date

.. code-block:: clist
    :linenos:

    REXX -
    SAY DATE(); SAY TIME()

USERS
-----

List active Users. The clist calls the BREXX WHO script directly, 
therefore no minus sign is necessary:

.. code-block:: clist
    :linenos:

    REXX WHO

REPL
----

Interactive REXX Processor.

The clist calls the BREXX REPL which opens the interactive REXX 
processor. It allows you to enter and execute rexx statements.

.. code-block:: clist
    :linenos:

    RX REPL NOSTAE