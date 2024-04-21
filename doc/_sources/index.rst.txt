.. BREXX/370 documentation master file, created by
   sphinx-quickstart on Thu Dec 15 12:31:57 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

BREXX/370 User's Guide
======================

.. toctree::
   :maxdepth: 3
   :numbered:

   installation
   tokens_and_terms
   expressions
   instructions
   templates
   compound
   special
   debugging
   builtin
   calling
   mvs
   added
   global
   dataset
   tcpip
   tso
   array
   rxlib
   tso_commands
   external_function
   vsam
   key_value
   fss
   application
   restrictions
   migration
   readme


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

This user's guide documents the BREXX standard functions from 
https://ftp.gwdg.de/pub/languages/rexx/brexx/html/rx.html as well as the
changes and amendments to BREXX to be used on MVS 3.8j.

Credits
-------

- BREXX has been developed by Vasilis Vlachoudis, who made it publicly 
  available as freeware for non-commercial purposes.
- Jason Winter's JCC Compiler for compiled BREXX
- JCC and the JCC-Library are owned and maintained by him. While not
  being freeware, Jason allows non-commercial usage and distribution 
  of Software created using JCC through a relaxed license, as long as
  the complete source code always accompanies those distributions.
- Vasilis and Jason explicitly consented to make the JCC based version
  of BREXX available on TK4-. Thanks to both for their significant 
  valuable contribution to the TK4- MVS 3.8j Tur(n)key system.
- The VSAM Interface is based on Steve Scott's VSAM API.
- The FSS Part is based on Tommy sprinkle's FSS - TSO Full-Screen 
  Services
- Daniel Gaeta contributed his EXECIO implementation.
- The NJE38DIR load module was extracted out of Bob Polmanter's NJE38 
  V2 modules

We wish to thank the following persons for patiently answering our 
questions and for their support and advice:

- Vasilis Vlachoudis
- Jürgen Winkelmann
- Jason Winter
- Wally Mclaughlin
- Greg Price
- Bob Polmanter
- Steve Scott 

and many others!

BREXX/370 Source Code
---------------------

The BREXX/370 Source Code can be found and downloaded at:
https://github.com/mvslovers/brexx370/

Some Notes on BREXX Arithmetic Operations
-----------------------------------------

BREXX stores numeric values in the appropriate type format. The benefit 
compared to save it as strings is a significant performance improvement
during calculations. As the expensive string to numeric conversion
before and vice versa after arithmetic operations is omitted; this
allows speedy calculations without the required conversion overhead.

BREXX supports two numeric types:

- **Integer** Integers are stored in 4-bytes a full word (LONG), this 
  means their range is from -2,147,483,648 to +2,147,483,647

- **Decimal Numbers** Decimal Numbers (decimal numbers with a fractional
  part) are represented in the double-precision floating-point format
  (doubleword), the length is 8-bytes consisting of an exponent and the 
  significand (fraction). It consists of 56 bits for the fraction part, 
  7-bit exponent and one-bit for the sign. This representation is IBM 
  specific and differs slightly from the IIEE 754 floating-point
  standard. 
  
  The precision of floating-point numbers is not as good as 
  decimal packed numbers which are not supported in BREXX (nor in REXX).
  This means, for example, 2.0 might be stored as 19999999999999999e-17,
  or for 5.0 you will is stored as 50000000000000003e-17; this is not an
  error, but the usual behaviour for floating-point numbers. It is
  caused by the conversion between the numbers of base 10 to base two a 
  bit-exact reversibility is not always given. This effect may build up 
  during arithmetic calculations.


