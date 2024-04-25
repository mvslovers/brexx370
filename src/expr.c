/*
 * $Id: expr.c,v 1.8 2008/07/15 07:40:25 bnv Exp $
 * $Log: expr.c,v $
 * Revision 1.8  2008/07/15 07:40:25  bnv
 * #include changed from <> to ""
 *
 * Revision 1.7  2004/08/16 15:28:54  bnv
 * Changed: name of mnemonic operands from xxx_mn to O_XXX
 *
 * Revision 1.6  2004/03/27 08:34:07  bnv
 * Nothing
 *
 * Revision 1.5  2003/10/30 13:16:28  bnv
 * Variable name change
 *
 * Revision 1.4  2002/06/11 12:37:38  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:51:48  bnv
 * Header -> Id
 *
 * Revision 1.2  1999/11/26 13:13:47  bnv
 * Some spaces changed to tabs.
 *
 * Revision 1.1  1998/07/02 17:34:50  bnv
 * Initial revision
 *
 */

#include "lerror.h"
#include "lstring.h"

#include "rexx.h"
#include "trace.h"
#include "compile.h"

/*-----------------* local function prototypes *------------ */
static void __CDECL Exp0( void );
static void __CDECL Exp1( void );
static void __CDECL Exp2( void );
static void __CDECL Exp3( void );
static void __CDECL Exp4( void );
static void __CDECL Exp5( void );
static void __CDECL Exp6( void );
static void __CDECL Exp7( void );
static void __CDECL Exp8( void );
static void __CDECL C_function( void );

/* ----------- local variables ----------- */
static    int    exp_ct;
static    size_t    exp_pos;

/* ========================= C_expr ========================== */
/* return if it had exited with another code than OP_COPY */
/* so something is left in stack */
int __CDECL
C_expr( int calltype )
{
    exp_ct  = calltype;
    exp_pos = CompileCodeLen;
    Exp0();

    /* If nothing was processed in the expr then push a Null string */
    if (exp_pos == CompileCodeLen) {
        _CodeAddByte(OP_PUSH);
            _CodeAddPtr(&(nullStr->key));
            TraceByte( nothing_middle );
    }
    switch (exp_ct) {
        case exp_assign:
            _CodeAddByte(OP_COPY);
            return FALSE;

        case exp_tmp:
            _CodeAddByte(OP_COPY2TMP);
            break;

        case exp_normal:
            /* do nothing */
            break;

        default:
            Lerror(ERR_INTERPRETER_FAILURE,0);
    }
    return TRUE;
} /* C_expr */

/* ---------------- InsTmp ---------------- */
static int __CDECL
InsTmp( size_t pos, int pushtmp)
{
    /* do we need to push a tmp value */
    if ((exp_ct==exp_assign) && (exp_pos==pos)) {
        /* because we have return the value in a temporary var    */
        /* change the type to exp_normal            */
        if (pushtmp)
            exp_ct = exp_normal;
    } else {
        if (pushtmp)
            _CodeInsByte(pos,OP_PUSHTMP);
        else
            return TRUE;
    }
    return FALSE;
} /* InsTmp */

/* ----------------- Exp0 ----------------- */
static void __CDECL
Exp0( void )
{
    enum mnemonic_type orxor;
    CTYPE    pos, pos2;

    pos = CompileCodeLen;
    Exp1();
    orxor = (symbol==xor_sy)? OP_XOR : OP_OR;
    while ((symbol==or_sy) || (symbol==xor_sy)) {  /* Logical OR; XOR */
        if (CompileCodeLen==pos) Lerror(ERR_INVALID_EXPRESSION,0);
        nextsymbol();
        pos2 = CompileCodeLen;
        Exp1();
        if (CompileCodeLen==pos2) Lerror(ERR_INVALID_EXPRESSION,0);
        InsTmp(pos,TRUE);
        _CodeAddByte(orxor);
            TraceByte( operator_middle );
        orxor = (symbol==xor_sy)? OP_XOR : OP_OR;
    }
} /* Exp0 */

/* ----------------- Exp1 ----------------- */
static void __CDECL
Exp1( void )
{
    CTYPE    pos, pos2;

    pos = CompileCodeLen;
    Exp2();
    while (symbol == and_sy) {    /* Logical AND  */
        if (CompileCodeLen==pos) Lerror(ERR_INVALID_EXPRESSION,0);
        nextsymbol();
        pos2 = CompileCodeLen;
        Exp2();
        if (CompileCodeLen==pos2) Lerror(ERR_INVALID_EXPRESSION,0);
        InsTmp(pos,TRUE);
        _CodeAddByte( OP_AND );
            TraceByte( operator_middle );
    }
} /* Exp1 */

/* ----------------- Exp2 ----------------- */
static void __CDECL
Exp2( void )
{
    enum  symboltype  _symbol;
    CTYPE    pos, pos2;

    pos = CompileCodeLen;
    Exp3();
    _symbol = symbol;

    /* DO NOT CHANGE THE ORDER OF THIS SYMBOLS */
    if  ((symbol >= eq_sy)  && (symbol <= dgt_sy)) {
        if (CompileCodeLen==pos) Lerror(ERR_INVALID_EXPRESSION,0);
        nextsymbol();
        pos2 = CompileCodeLen;
        Exp3();
        if (CompileCodeLen==pos2) Lerror(ERR_INVALID_EXPRESSION,0);
/****
//        if (!InsTmp(pos,FALSE)) {    * do we need to add a pushtmp *
*****/
            InsTmp(pos,TRUE);    /* add the pushtmp byte */
            switch (_symbol) {
                case eq_sy  : _CodeAddByte(OP_EQ);   break;
                case ne_sy  : _CodeAddByte(OP_NE);   break;
                case gt_sy  : _CodeAddByte(OP_GT);   break;
                case ge_sy  : _CodeAddByte(OP_GE);   break;
                case lt_sy  : _CodeAddByte(OP_LT);   break;
                case le_sy  : _CodeAddByte(OP_LE);   break;
                case deq_sy : _CodeAddByte(OP_DEQ);  break;
                case dne_sy : _CodeAddByte(OP_DNE);  break;
                case dgt_sy : _CodeAddByte(OP_DGT);  break;
                case dge_sy : _CodeAddByte(OP_DGE);  break;
                case dlt_sy : _CodeAddByte(OP_DLT);  break;
                case dle_sy : _CodeAddByte(OP_DLE);  break;
                default:
                    Lerror(ERR_INTERPRETER_FAILURE,0);
            }
/*****
//        } else {
//            switch (_symbol) {
//                case eq_sy  : _CodeAddByte(OP_TEQ);   break;
//                case ne_sy  : _CodeAddByte(OP_TNE);   break;
//                case gt_sy  : _CodeAddByte(OP_TGT);   break;
//                case ge_sy  : _CodeAddByte(OP_TGE);   break;
//                case lt_sy  : _CodeAddByte(OP_TLT);   break;
//                case le_sy  : _CodeAddByte(OP_TLE);   break;
//                case deq_sy : _CodeAddByte(OP_TDEQ);  break;
//                case dne_sy : _CodeAddByte(OP_TDNE);  break;
//                case dgt_sy : _CodeAddByte(OP_TDGT);  break;
//                case dge_sy : _CodeAddByte(OP_TDGE);  break;
//                case dlt_sy : _CodeAddByte(OP_TDLT);  break;
//                case dle_sy : _CodeAddByte(OP_TDLE);  break;
//                default:
//                    Lerror(ERR_INTERPRETER_FAILURE,0);
//            }
//        }
*****/
        TraceByte( operator_middle );
    }
} /* Exp2 */

/* ----------------- Exp3 ----------------- */
static void __CDECL
Exp3( void )
{
    int   _Concat;
    int   _Pblank;
    CTYPE    pos, pos2;

    pos = CompileCodeLen;
    Exp4();
    _Concat = (symbol==concat_sy);
    _Pblank = symbolPrevBlank;

    /* UNTIL NOT_SY there must be prefix and starting '(' operators */
    while ((symbol <= not_sy) ||  _Concat) {
        if (CompileCodeLen==pos) Lerror(ERR_INVALID_EXPRESSION,0);
        if (_Concat) nextsymbol();
        pos2 = CompileCodeLen;
        Exp4();
        if (CompileCodeLen==pos2) Lerror(ERR_INVALID_EXPRESSION,0);
        InsTmp(pos,TRUE);    /* add the pushtmp byte */
        if (_Concat || !_Pblank)
            _CodeAddByte(OP_CONCAT);
        else
            _CodeAddByte(OP_BCONCAT);

        TraceByte( operator_middle );

        _Concat = (symbol==concat_sy);
        _Pblank = symbolPrevBlank;
    }
} /* Exp3 */

/* ----------------- Exp4 ----------------- */
static void __CDECL
Exp4( void )
{
    enum symboltype _symbol;
    CTYPE    pos, pos2;

    pos = CompileCodeLen;
    Exp5();
    _symbol = symbol;

    while ((symbol==plus_sy) || (symbol==minus_sy)) {
        if (CompileCodeLen==pos) Lerror(ERR_INVALID_EXPRESSION,0);
        nextsymbol();
        pos2 = CompileCodeLen;
        Exp5();
        if (CompileCodeLen==pos2) Lerror(ERR_INVALID_EXPRESSION,0);
        InsTmp(pos,TRUE);
        if (_symbol==plus_sy)
            _CodeAddByte(OP_ADD);
        else
            _CodeAddByte(OP_SUB);
        TraceByte( operator_middle );
        _symbol = symbol;
    }
} /* Exp4 */

/* ----------------- Exp5 ----------------- */
static void __CDECL
Exp5( void )
{
    enum  symboltype _symbol;
    CTYPE    pos, pos2;

    pos = CompileCodeLen;
    Exp6();
    _symbol = symbol;

    /* ORDER IS IMPORTANT */
    while ((symbol >= times_sy) && (symbol<=intdiv_sy)) {
        if (CompileCodeLen==pos) Lerror(ERR_INVALID_EXPRESSION,0);
        nextsymbol();
        pos2 = CompileCodeLen;
        Exp6();
        if (CompileCodeLen==pos2) Lerror(ERR_INVALID_EXPRESSION,0);
        InsTmp(pos,TRUE);
        switch (_symbol) {
            case times_sy  : _CodeAddByte(OP_MUL);   break;
            case div_sy    : _CodeAddByte(OP_DIV);   break;
            case intdiv_sy : _CodeAddByte(OP_IDIV);  break;
            case mod_sy    : _CodeAddByte(OP_MOD);   break;
            default:
                Lerror(ERR_INTERPRETER_FAILURE,0);
        }
        TraceByte( operator_middle );
        _symbol = symbol;
    }
}  /* Exp5 */

/* ----------------- Exp6 ----------------- */
static void __CDECL
Exp6( void )
{
    CTYPE    pos, pos2;

    pos = CompileCodeLen;
    Exp7();
    while (symbol==power_sy) {
        if (CompileCodeLen==pos) Lerror(ERR_INVALID_EXPRESSION,0);
        nextsymbol();
        pos2 = CompileCodeLen;
        Exp7();
        if (CompileCodeLen==pos2) Lerror(ERR_INVALID_EXPRESSION,0);
        InsTmp(pos,TRUE);
        _CodeAddByte(OP_POW);
            TraceByte( operator_middle );
    }
} /* Exp6 */

/* ----------------- Exp7 ----------------- */
static void __CDECL
Exp7( void )
{
    enum symboltype _symbol;
    int  prefix;
    CTYPE    pos;

    pos = CompileCodeLen;
    _symbol = symbol;

    if ((symbol==not_sy) || (symbol==minus_sy)) {
        nextsymbol();
        prefix = TRUE;
    } else
        prefix = FALSE;

    if (!prefix && (symbol==plus_sy))
        nextsymbol();

    Exp8();
    if (prefix) {
        if (CompileCodeLen==pos) Lerror(ERR_INVALID_EXPRESSION,0);
        InsTmp(pos,TRUE);
        if (_symbol==not_sy)
            _CodeAddByte(OP_NOT);
        else
            _CodeAddByte(OP_NEG);
        TraceByte( operator_middle );
    }
} /* Exp7 */

/* ----------------- Exp8 ----------------- */
static void __CDECL
Exp8( void )
{
    if (symbol == ident_sy) {
        _CodeAddByte(OP_LOAD);
            _CodeAddPtr(SYMBOLADD2LITS);
            TraceByte( variable_middle );
        nextsymbol();
    } else
    if (symbol==literal_sy) {
        _CodeAddByte(OP_PUSH);
            _CodeAddPtr(SYMBOLADD2LITS_KEY);
            TraceByte( litteral_middle );
        nextsymbol();
    } else
    if (symbol == function_sy) {
        C_function();
        _mustbe(ri_parent,ERR_UNMATCHED_PARAN,0);
    } else
    if (symbol==le_parent) {
        nextsymbol();
        Exp0();
        _mustbe(ri_parent,ERR_UNMATCHED_PARAN,0);
    }
} /* Exp8 */

/* -------------------------------------------------------------- */
/*  ÝFunction¨ ::= ÝIdentifier¨(ÝÝExpression¨Ý,ÝExpression¨¨...¨) */
/* -------------------------------------------------------------- */
static void __CDECL
C_function( void )
{
    int    ia,line,realarg=0;
    word    existarg=0,bp=1,lastarg; /* bit mapped, if arguments exist */
    void    *lbl;

    line = symboline;    /* keep line number */

    lbl = _AddLabel( FT_FUNCTION, UNKNOWN_LABEL );

    /* add a space in stack, for the result string */
    if ((exp_ct==exp_assign) && (exp_pos==CompileCodeLen))
        exp_ct = exp_normal;
    else
        _CodeAddByte(OP_PUSHTMP);

    nextsymbol();
    ia = lastarg = 0;

    if (symbol != ri_parent) {
        if (symbol != comma_sy) {
            Exp0();
            realarg++;
            lastarg = ia+1;
            existarg |= bp;    /* argument exist */
        }
        ia++;
        bp <<= 1;    /* increase bit position */

        while (symbol==comma_sy) {
            nextsymbol();
            if (ia>=MAXARGS)
                Lerror(ERR_INCORRECT_CALL,0);
            if (! ((symbol==comma_sy) || (symbol==ri_parent))) {
                Exp0();
                lastarg = ia+1;
                realarg++;
                existarg |= bp;
            }
            ia++;
            bp <<= 1;    /* increase bit position */
        }
    }

    _CodeAddByte(OP_CALL);
        _CodeAddPtr(lbl);    /* call pointer */
        _CodeAddByte(lastarg);    /* arguments    */
        _CodeAddByte(realarg);    /* real args    */
        _CodeAddWord(existarg);    /* which exist    */
        _CodeAddWord(line);    /* symbol line    */
        _CodeAddByte(CT_FUNCTION);    /* call type */
    TraceByte( function_middle );
} /* C_function */
