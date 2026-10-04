# Tokens and Terms

REXX expressions and instructions may contain the following items:

## comment

> A comment is a sequence of characters (on one or more lines)
> delimited by /\* and \*/. Nested comments are also valid, as
> /\* hello /\* joe \*/ \*/

## string

> A string is a sequence of characters delimited by a single quote or
> double quote. Use two quotes to obtain one quote inside a string. A
> string may be specified in binary or hexadecimal if the final quote
> is followed by a B or X. If it followed by an H then is treated as a
> hexadecimal number. Some valid strings are:

> ```rexx
> "Marmita"
> '0100 0001'b
> 'He''s here'
> '2ed3'x
> '10'h (=16)
> ```

## number

> A number is a string of decimal digits with or without a decimal
> point. A number may be prefixed with a plus or minus sign, and/or
> written in exponential notation. Some valid numbers are:

> ```rexx
> 23
> 12.07
> 141
> 12.2e6
> +5
> '-3.14'
> ```

## symbol

> A symbol refers to any group of characters from the following
> selection: A-Z, a-z, 0-9, @ # $ \_ . ? !

> Symbols are always translated to uppercase. Variables are symbols
> but the first character must not be a digit 0-9 or a dot ‘.’.
> Each symbol may consist of up to 250 characters.

## function-call

> A function-call invokes an internal, external, or built-in routine
> with 0 to 10 argument strings. The called routine returns a
> character string. A function-call has the format:

> function-name( [expr][,[expr]…)

> function-name must be adjacent to the left parenthesis, and may be a
> symbol or a string.

> All procedures can be called as functions or procedures. If a
> function is called as a procedure CALL left ‘Hello’,4 then the
> return string will be returned in the variable RESULT (where in this
> example will contain the string ‘Hell’)

> copies(‘ab’,3)     /\* will return ‘ababab’ \*/
