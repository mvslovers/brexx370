Compound Variable Names
=======================

**name** may be "compound" in that it may be composed of several parts 
(separated by periods) some of which may have variable values. The parts
are then substituted independently, to generate a fully resolved name.
In general,

.. code-block:: rexx
    :linenos:

    s0.s1.s2.---.sn	/* is substituted to form */
    d0.v1.v2.---.vn	/* where d0 is uppercase of s0, and
    	v1-vn are values of s1-sn */

This facility may be used for traditional arrays, content-addressable 
arrays, and other indirect addressing modes. As an example, the 
sequence:

.. code-block:: rexx
    :linenos:

    J = 5; a.j = "fred"; 

would assign fred to the variable A.5.

The stem of name (i.e. that part up to and including the first ".") may 
be specified on the `DROP` and `PROCEDURE` `EXPOSE` instructions and 
affect all variables starting with that stem. An assignment to a stem 
assigns the new value to all possible variables with that stem. 