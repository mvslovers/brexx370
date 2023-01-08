Templates for ARG, PULL, and PARSE
==================================

The `PULL`, `ARG` and `PARSE` instructions use a template to parse a 
string.

The simplest template is a list of variables where each of them is 
assigned one word from the string, except the last variable in the list 
which will contain the rest of the string.

.. code-block:: rexx
   :linenos:
   
    PARSE VALUE "one two three four " WITH a b c
    now a="one"; b="two"; c="three four"
    PARSE VALUE "one two three four " WITH a b c d e
    now a="one"; b="two"; c="three"; d="four" and e="" 

A dot '.' can be in the place of one or more variables, it is used as a 
place-holder.

.. code-block:: rexx
   :linenos:
   
    PARSE VALUE "one two three four " WITH a . . d
    now a="one"; d="four" 

A more complex parsing is to use patterns for triggering:

- **number** which specifies an absolute position in string 1 - is the 
  first character in string
- **=(name)** as a position may be a variable enclosed in parenthesis 
  after an equal symbol
- **[+|-]number** signed numbers are used as a relative positioning

    .. code-block:: rexx
        :linenos:
    
        PARSE VALUE "one two three four " WITH 2 a 6 b
        now a="ne t"; b="wo three four " pos=6;
        PARSE VALUE "one two three four " WITH 2 a =(pos) b
        now a="ne t"; b="wo three four " PARSE VALUE "one two three four " WITH 2 a +2 b
        now a="ne"; b=" two three four " 

- **string** - may be used as a target position.

    .. code-block:: rexx
       :linenos:
       
        PARSE VALUE "marmita/bill/vivi' WITH a '/' b '/' c
        now a="marmita"; b="bill"; c="vivi" 

- **(name)** - also as a target may be used a variable encolsed in parenthesis

    .. code-block:: rexx
       :linenos:
       
        t = "%%"
        PARSE VALUE "aabbcc%%ddeeff%%gg%%" WITH . (t) middle (t) . now middle="ddeeff" 

A **comma** can be used as a "trigger" to move to the next string when 
there is more than one to be parsed (e.g. when there is more than one 
argument string to a routine).

.. code-block:: rexx
   :linenos:
   
    CALL MyProc 'Hi',3,4	
    EXIT	
    MyProc:	
    PARSE ARG first, second, third	/* now first="Hi" */
    ...		/* second=3 */
    /* third=4 */ 