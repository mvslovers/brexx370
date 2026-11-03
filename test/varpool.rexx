/* REXX - variable access through ECTENVBK and IRXEXCOM (#602)         */
/* MVSTEST TSO                                                         */
/* The test module TSTVPOOL plays the part of IKJCT441 or ISPF: it     */
/* finds the ENVBLOCK in ECTENVBK, takes the routine out of the        */
/* IRXEXTE vector and calls it with SHVBLOCKs. The exec sets up the    */
/* variables before each call and looks at them afterwards, so the     */
/* routine does not judge itself. The module ends with RC = the number */
/* of its own checks that failed; each failed check is a WTO line      */
/* "TSTVPOOL mode FAIL nnn text RC= RET= VALL= VAL=" in the job log.   */
/* Observations that the contract leaves open are INFO lines there.    */
say '----------------------------------------'
say 'File varpool.rexx'
err = 0

/* ECTENVBK -> ENVBLOCK -> IRXEXTE -> IRXEXCOM, four pointers */
call mod 'ENV'

/* F and f: a set, an empty, an unset and a long variable */
a = 'alpha'; e = ''; long = copies('x', 3000)
drop unsetx
call mod 'FETCH'
call check 'FETCH: A is unchanged', a == 'alpha'
call check 'FETCH: UNSETX stays unset', symbol('UNSETX') == 'LIT'

/* S and s: new, overwritten, empty, blanks, long, binary */
drop b c d2 long2 bin lowset
a = 'old'
call mod 'STORE'
call check 'STORE: B is new', b == 'two'
call check 'STORE: A is overwritten', a == 'new'
call check 'STORE: C is empty and set', symbol('C') == 'VAR' & c == ''
call check 'STORE: D2 keeps its blanks', d2 == '  lead  trail ' ,
         & length(d2) = 15
call check 'STORE: LONG2 has 3000 bytes', length(long2) = 3000 ,
         & long2 == copies('y', 3000)
call check 'STORE: BIN is binary', bin == 'ab'||'00'x||'cd'||'FF'x
call check 'STORE: symbolic set of LOWSET', lowset == 'two'

/* D and d: the variable is gone and reads as its own name */
a = 'x'; ds = 'q'
drop unsetd
call mod 'DROP'
call check 'DROP: A is dropped', symbol('A') == 'LIT'
call check 'DROP: DS is dropped', symbol('DS') == 'LIT'

/* stems and compound variables, direct and symbolic */
st.1 = 'x'; st.2 = 'y'; i = 2
drop j newst.
call mod 'STEM'
call check 'STEM: ST.2 set through the symbolic name', st.2 == 'Y2'
call check 'STEM: ST. dropped as a whole', symbol('ST.1') == 'LIT' ,
         & symbol('ST.2') == 'LIT'
call check 'STEM: NEWST. default is set', newst.1 == 'dflt' ,
         & newst.zz == 'dflt'
drop newst. i

/* N: the walk visits all variables once and ends with SHVLVAR */
w1 = 'one'; w2 = 'two'; w3.a = 'tri'; w3.b = 'quad'
call mod 'NEXT'

/* several blocks in one call; a bad one does not stop the others */
x1 = 'a'; drop q1 unsetc
call mod 'CHAIN'
call check 'CHAIN: Q1 is set by block 1', q1 == 'two'

/* P: private information of the exec */
call mod 'PRIV'

/* invalid codes and names leave the pool alone */
a = 'alpha'
call mod 'BAD'
call check 'BAD: the valid store afterwards works', a == 'two'

/* the forms of the parameter list, R0 */
a = 'alpha'
call mod 'CONV'
call check 'CONV: A is unchanged', a == 'alpha'

say 'Done varpool.rexx'
exit err

mod:
parse arg mode
address tso 'TSTVPOOL' mode
call check 'TSTVPOOL' left(mode, 5) 'no failed check, RC' rc, rc = 0
return

check:
parse arg what, ok
if ok then say left('VARPOOL', 8) '-' what '.. PASS'
else do
  say left('VARPOOL', 8) '-' what '.. *FAIL*'
  err = 1
end
return
