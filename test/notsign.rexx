say '----------------------------------------'
say 'File notsign.rexx'
/* The EBCDIC not sign X'5F' is REXX's NOT, like the backslash.      */
/* JCC compiled the '^' in nextsymb.c as X'5F'; cc370 (CP037) makes   */
/* it X'B0', and X'5F' became an invalid character (Error 13).        */
/* The upload maps the not sign to X'E0', so the tests build it with  */
/* x2c and run it through the tokenizer with INTERPRET.               */
/* Under IBM-1047 the not sign is X'B0', CP037's '^' (#187): NOT too. */
r=0
n = x2c('5F')
call try '(1 'n'= 2)',          '1', 1
call try '(1 'n'== 1)',         '0', 2
call try n'(1 = 1)',            '0', 3
call try n"datatype('x','N')",  '1', 4
call try '(2 'n'> 1)',          '0', 5
call try '(1 'n'< 2)',          '0', 6
n = x2c('B0')
call try '(1 'n'= 2)',          '1', 7
call try n'(1 = 1)',            '0', 8
say 'Done notsign.rexx'
exit r
try:
  parse arg expr, want, tno
  signal on syntax name bad
  interpret 'got =' expr
  signal off syntax
  if got == want then say 'NOTSIGN  - test' right(tno,3) '.. PASS'
  else do
    say 'NOTSIGN  - test' right(tno,3) '.. *FAIL* - expected "'want'"',
        'actual "'got'"'
    r = max(r,8)
  end
  return
bad:
  say 'NOTSIGN  - test' right(tno,3) '.. *FAIL* - Error' rc errortext(rc)
  r = max(r,8)
  return
