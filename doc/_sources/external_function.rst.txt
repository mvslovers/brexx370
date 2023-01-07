Callable External Functions
===========================

With the new External Function feature, you can call compiled programs
written in conventional language, as PL1, Assembler, and maybe more.

We closely adapted IBM's TSO/E REXX programming services:
https://www.ibm.com/support/knowledgecenter/SSLTBW_2.2.0/com.ibm.zos.v2r2.ikja300/progsrv.htm

How it works:

BREXX Call an external Program
------------------------------

To call an external program, you call it in the same way as a normal 
BREXX function::

    say load-module(argument-1,argument-2,...,argument-15)

you can pass up to 15 arguments to the external function. The size of
the return value can be up to 1024 bytes.

Example::

    Say RXPI()

RXPI is a load module that must be accessible within the link list 
chain. It does not have any arguments.

BREXX Programming Services
--------------------------

BREXX provides control blocks containing the arguments and a 1024 bytes return buffer.

Called Program
--------------

The program needs to match the BREXX calling conventions to manage the 
argument and return value handling. To ease it, we have isolated 
communication control blocks and internal functions in a copybook. Once
included, it will transparently provide the functionality to the 
program.

Example, PI calculation::

    RXPI:  PROCEDURE(EFPL_PTR) OPTIONS(MAIN);
      %INCLUDE RXCOMM;
    ...

Benefits
--------

The performance of a compiled program is much higher than in BREXX. So
if you have complex mathematical calculations, they will be 
significantly faster than code implemented in BREXX. In our testing, we 
implemented an algorithm for calculating PI with 500 digits. In 
comparison, it was over 600 times faster than the same algorithm 
implemented in BREXX.