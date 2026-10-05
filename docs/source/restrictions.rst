Implementation Restrictions
===========================

The name of a variable or label, and the length of a literal string may 
not exceed 250 bytes. More characters than 250 will be truncated. (Can 
be changed from rexx.h)

Numbers follows C restrictions, thus integers are long and real numbers 
are held as double.

NUMERIC DIGITS does not round arithmetic. ANSI REXX rounds the operands
and the result of every operation to NUMERIC DIGITS significant digits;
BREXX computes in C (long and double) and applies DIGITS only to
comparisons and to the formatting of a result. Results can therefore
differ from other REXX implementations once more than DIGITS digits
are involved, usually by being more precise (default DIGITS 9):

==========================================  ===============  ===================
Expression                                  BREXX            ANSI REXX
==========================================  ===============  ===================
``1000000000-1``                            ``999999999``    ``1.00000000E+9``
``1e9-6``                                   ``999999994``    ``999999990``
``123456789 * 0.00005 * 3333.333 * 21.43``  ``440946454``    ``440946453``
==========================================  ===============  ===================

This is a design limit of BREXX, not planned to change (issue #249).

The FOR and simple counts on a DO instruction, and the right-hand term 
of an exponentiation may not exceed maximum long number.

The control stack (for DO, IF, CALL, etc.) is limited to a nesting level
of 256 and from the internal stack of the Operating system. 
 

Functions and subroutines cannot be called with more than 15 arguments 
(Can be changed from rexx.h).

``OPEN`` with a third parameter ``VIO`` (a memory file) ends with
error 40.

Input and Output cannot be redirected for commands executed through 
INT2E.

Code pages
----------

A data set holds the bytes a 3270 emulator sent, and which byte a key
sends depends on the host code page set in the emulator. BREXX accepts
the REXX syntax characters under these three code pages:

=====================  =========  ==========================  ==========
Character              CP037      x3270 "bracket"             IBM-1047
=====================  =========  ==========================  ==========
``¬`` (NOT)            X'5F'      X'5F'                       X'B0'
``^`` (NOT)            X'B0'      X'B0'                       X'5F'
``\`` (NOT)            X'E0'      X'E0'                       X'E0'
``|``                  X'4F'      X'4F'                       X'4F'
``[`` (MATCH pattern)  X'BA'      X'AD'                       X'AD'
``]`` (MATCH pattern)  X'BB'      X'BD'                       X'BD'
=====================  =========  ==========================  ==========

``¬``, ``^`` and ``\`` are all NOT, so ``¬=`` works whichever of the
three is set. National code pages such as CP273 (German) or CP500 place
``|`` at X'BB' and ``¬`` at X'BA': there ``||`` is not a concatenation
and ``¬`` is not NOT (``^`` and ``\`` still are).

A file transfer converts the characters with its own table, which may
not match the emulator's. Check ``¬`` and ``|`` after uploading an exec.

Variables
---------

Variables are held in a binary tree, where the tree is balanced when one
branch starts to become very big. Even though the variables are stored 
as a bintree there is an internal cache system for the faster access.

Each variable in rexx is a length prefix string, and it is kept in 
memory in 3 different types, long, real, string according the last 
operation that affect that variable.

.. code-block:: rexx
   :linenos:

    ie.	a = 2	/* will be kept as string (Length-prefixed) */
     	a = 2 + 1/* will be kept as integer (long) */
     	a = 2 + 0.1/* will be kept as real (double) */

The advantage of the above scheme is that numerical operations are 
performed much faster than the other algorithms. Integers are 32-bit
longs and hold about 2 billion, but a result that does not fit is not
lost (fixed with #110). A loop like this

.. code-block:: rexx
   :linenos:

	factorial = 1
	do i = 1 to 50
		factorial = factorial * i
	end

gives 3.04140932017133E+64, the factorial of 50 within the precision
of a double; it used to give 0.

You can easilly translate a variable to any format you like with the 
following instructions

.. code-block:: rexx
   :linenos:

	a = a + 0.0   /* will translate a to real */
	a = trunc(a)  /* will translate a to integer */
	a = a || ''   /* will translate a to string */

Sometimes it is very important to know how a variable is kept in memory
(usually for the INTR function) so there is an extra option in DATATYPE
function "TYPE" that returns the way one variable is hold.

.. code-block:: rexx
   :linenos:

	DATATYPE(2,"TYPE")     -> "INTEGER"
	DATATYPE(2+0.0,"TYPE") -> "REAL"
	DATATYPE(2+0,"TYPE")   -> "INTEGER"

A blank between the sign and the digits is allowed: '- 2' is a
number to DATATYPE and evaluates to -2.

Stems
-----
substitution to stems may be anything including strings with any 
character. No translation to uppercase is done to subscripts

.. code-block:: rexx
   :linenos:

	lower = 'ma'  
	stem.lower   -> 'STEM.ma'
	upper = 'MA'  
	stem.upper   -> 'STEM.MA'

Stems can be initialized with a command like stem. = 'Initial value'

Functions
---------

TRANSLATE sometimes wont work properly for strings with characters 
above ASCII 127. Works OK for Greek character set.

VARTREE wont work properly with variables with non-printable characters 