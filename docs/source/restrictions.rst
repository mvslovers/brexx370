Implementation Restrictions
===========================

The name of a variable or label, and the length of a literal string may 
not exceed 250 bytes. More characters than 250 will be truncated. (Can 
be changed from rexx.h)

Numbers follows C restrictions, thus integers are long and real numbers 
are held as double.

The FOR and simple counts on a DO instruction, and the right-hand term 
of an exponentiation may not exceed maximum long number.

The control stack (for DO, IF, CALL, etc.) is limited to a nesting level
of 256 and from the internal stack of the Operating system. 
 

Functions and subroutines cannot be called with more than 15 arguments 
(Can be changed from rexx.h).

Input and Output cannot be redirected for commands executed through 
INT2E.

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
performed much faster than the other algorithms. The main disadvantage 
is on the integer operations. 32 bit integers have a maximum of 
2billion, so if you try something like this

.. code-block:: rexx
   :linenos:

	factorial = 1
	do i = 1 to 50
		factorial = factorial * i
	end

will result to 0 instead of the factorial of 50! To find the correct 
result you have to fool the interpreter to think that factorial is real
and not integer, this can be done if you write factorial = 1.0 ....

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

	DATATYPE(2,"TYPE")     -> "STRING"
	DATATYPE(2+0.0,"TYPE") -> "REAL"
	DATATYPE(2+0,"TYPE)    -> "INT"

C routines are used for the translation of string to number, so a 
string like '- 2' will be reported by DATATYPE as a NUMber when rexx 
tries to evaluate it as a number it will return a value of 0 instead of 
-2, because of the spaces between the sign and the number.

Stems
-----
substitution to stems may be anything including strings with any 
character. No translation to uppercase is done to subscripts

.. code-block:: rexx
   :linenos:

	lower = 'ma'  ; stem.lower   -> 'STEM.ma'
	upper = 'MA'  ; stem.upper   -> 'STEM.MA'

Stems can be initialized with a command like stem. = 'Initial value'

Functions
---------

TRANSLATE sometimes wont work properly for strings with characters 
above ASCII 127. Works OK for Greek character set.

VARTREE wont work properly with variables with non-printable characters 