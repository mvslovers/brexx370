# Expressions

Most REXX instructions permit the use of expressions, following normal
algebraic style. Expressions can consists of strings, symbols, or
functions calls. Expressions are evaluated from left to right, modified
by parentheses and the priority of the operators (as ordered below).
Parentheses may be used to change the order of evaluation.

All operations (except prefix operations) act on two items and result in
a character string.

## Prefix + - ^ \\

> Prefix operations: Plus; Minus; and Not. (For + and -, the item
> must evaluate to a number; for ^ and \\, the item must evaluate
> to “1” or “0”.)

> > -4     /\* -4 \*/

## \*\*

> Exponentiate. (Both items must evaluate to numbers, and the
> right-hand item must be a whole number.)

> ```rexx
>  2 ** 3  /* 8 */
>  2 ** -3         /* 0.125 */
> ```

## \* / % //

> Multiply; Divide; Integer Divide; Divide and return the remainder.
> (Both items must evaluate to numbers.)

> ```rexx
>  4 * 3   /* 12 */
>  4 / 3   /* 1.333.. */
>  5 % 3   /* 1 */
>  5 // 3  /* 2 */
> ```

## + -

> Add; Subtract. (Both items must evaluate to numbers.)

> ```rexx
>  2 + 3.02        /* 5.02 */
> ```

## (blank) ||

> Concatenate: with or without a blank. Abuttal of items causes direct concatenation.

> ```rexx
>  a = 'One'
>  a 'two'         /* "One two" */
>  a || 'two'      /* "Onetwo" */
>  a'two'  /* "Onetwo" */
> ```

## = > < >= <= ^= /= = ^> ^< >< <> == >> << >>= <<= ^== /== == ^>> ^<<

> Comparisons (arithmetic compare if both items evaluate to a number.)
> The ==, >>, << etc. operators checks for an exact match.

> ```default
>  'marmita' = ' marmita '         /* 1 (spaces are striped) */
>  'marmita' == ' marmita '        /* 0 */
>  'marmita' ^= ' marmita '        /* 0 (spaces are striped) */
>  'marmita' ^==' marmita '        /* 1 */
>  '2' = ' 2 '     /* 1 (arithmetic comparison) */
>  '2' == ' 2 '    /* 0 (string comparison) */
>  '2' >> ' 2 '    /* 1 (string comparison) */
> ```

## &

> Logical And. (Both items must evaluate to “0” or “1”.)

> ```rexx
>  'a'='b' & 'c'='c'       /* 0 */
> ```

## / &&

> Logical Or; Logical Exclusive Or. (Both items must evaluate to “0”
> or “1”.)

> ```rexx
>  'a'='b' | 'c'='c'       /* 1 */
>  'A'='b' && 'c'='c'      /* 1 */
> ```

In Ansi REXX the results of arithmetic operations are rounded according
the setting to NUMERIC DIGITS (default is 9). Here all arithmetic
operations follow C arithmetics. For a more detail description look at
the Implementation Restrictions document.
