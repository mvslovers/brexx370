/*
 * $Id: template.c,v 1.7 2008/07/15 07:40:25 bnv Exp $
 * $Log: template.c,v $
 * Revision 1.7  2008/07/15 07:40:25  bnv
 * #include changed from <> to ""
 *
 * Revision 1.6  2004/08/16 15:29:30  bnv
 * Changed: name of mnemonic operands from xxx_mn to O_XXX
 *
 * Revision 1.5  2003/08/04 01:29:58  bnv
 * Insert TMP before the NEG!
 *
 * Revision 1.4  2002/06/11 12:37:38  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:51:48  bnv
 * Header -> Id
 *
 * Revision 1.2  1999/11/26 13:13:47  bnv
 * Changed: To use the new macros.
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

/* ----------- vrefp --------- */
/* variable reference position */
static void
vrefp( void )
{
    nextsymbol();    /* skip left parenthesis */

    if (symbol != ident_sy)
    Lerror( ERR_STRING_EXPECTED,7,&symbolstr);

    _CodeAddByte( OP_LOAD );
        _CodeAddPtr( SYMBOLADD2LITS );
        TraceByte( nothing_middle );
    nextsymbol();

    _mustbe(ri_parent,ERR_INV_VAR_REFERENCE,1);
} /* vrefp */

/* -------- position ------- */
/* variable reference position */
static void
position(void)
{
    int    type;

    if (symbol==le_parent)
        vrefp();
    else
    if (symbol==literal_sy) {
        type = _Lisnum(&symbolstr);
        if (type==LREAL_TY)
            Lerror(ERR_INVALID_INTEGER,4,&symbolstr);
        else
        if (type==LSTRING_TY)
            Lerror(ERR_INVALID_TEMPLATE,2,&symbolstr);
        _CodeAddByte(OP_PUSH);
            _CodeAddPtr(SYMBOLADD2LITS_KEY);
            TraceByte( nothing_middle );
        nextsymbol();
    } else
        Lerror(ERR_INVALID_TEMPLATE,2,&symbolstr);
    _CodeAddByte(OP_TOINT);
} /* position */

/* -------------------------------------------------------------- */
/*  template_list := template | [template] ',' [template_list]    */
/*  template   := (trigger | target | Msg38.1)+                   */
/*  target     := VAR_SYMBOL | '.'                                */
/*  trigger    := pattern | positional                            */
/*  pattern    := STRING | vrefp                                  */
/*  vrefp      := '(' (VAR_SYMBOL | Msg19.7) (')' | Msg46.1)      */
/*  positional := absolute_pos | relative_pos                     */
/*  absolute_pos := NUMBER | '=' position                         */
/*  position   := NUMBER | vrefp  | Msg38.2                       */
/*  relative_pos := ('+' | '-') position                          */
/* -------------------------------------------------------------- */
void __CDECL
C_template(void)
{
    void    *target_ptr=NULL;
    bool    trigger, dot=FALSE;
    bool    sign;
    int    type;
    CTYPE    pos;

    _CodeAddByte(OP_PARSE);
    while ((symbol!=semicolon_sy) && (symbol!=comma_sy)) {
        trigger = FALSE;
        switch (symbol) {
            case ident_sy:
            case dot_sy:
                if (target_ptr || dot) {
                    /* trigger space */
                    trigger = TRUE;
                    _CodeAddByte(OP_TR_SPACE);
                    /* do not go to next symbol */
                } else {
                    if (symbol==ident_sy)
                        target_ptr = SYMBOLADD2LITS;
                    else
                        dot = TRUE;
                    nextsymbol();
                }
                break;

            case minus_sy:
            case plus_sy:
                trigger = TRUE;
                sign = (symbol==minus_sy);
                nextsymbol();
                pos = CompileCodeLen;
                position();
                if (sign) {
                    _CodeInsByte(pos,OP_PUSHTMP);
                    _CodeAddByte(OP_NEG);
                    TraceByte( nothing_middle );
                }
                _CodeAddByte(OP_TR_REL);
                break;

            case literal_sy:
                trigger = TRUE;

                if (symbolisstr) {
                    _CodeAddByte(OP_PUSH);
                        _CodeAddPtr(SYMBOLADD2LITS_KEY);
                        TraceByte( nothing_middle );
                    _CodeAddByte(OP_TR_LIT);
                    nextsymbol();
                } else {
                    type = _Lisnum(&symbolstr);
                    if (type==LREAL_TY)
                        Lerror(ERR_INVALID_INTEGER,4,&symbolstr);
                    else
                    if (type==LSTRING_TY)
                        Lerror(ERR_INVALID_TEMPLATE,1,&symbolstr);

                    _CodeAddByte(OP_PUSH);
                        _CodeAddPtr(SYMBOLADD2LITS_KEY);
                        TraceByte( nothing_middle );
                    _CodeAddByte(OP_TOINT);
                    _CodeAddByte(OP_TR_ABS);
                    nextsymbol();
                }
                break;

            case le_parent:
                trigger = TRUE;
                vrefp();
                _CodeAddByte(OP_TR_LIT);
                break;

            case eq_sy:
                trigger = TRUE;
                nextsymbol();
                position();
                _CodeAddByte(OP_TOINT);
                _CodeAddByte(OP_TR_ABS);
                break;

            default:
                Lerror(ERR_INVALID_TEMPLATE,0);
        } /* end of switch */
        if (trigger) {
            if (target_ptr) {
                _CodeAddByte(OP_CREATE);
                    _CodeAddPtr(target_ptr);
                _CodeAddByte(OP_PVAR);
                    TraceByte( other_middle );
                target_ptr = NULL;
            } else
            if (dot) {
                _CodeAddByte(OP_PDOT);
                    TraceByte( dot_middle );
                dot = FALSE;
            }
        }
    } /* end of while */

    if (target_ptr) {    /* assign the remaining part */
        _CodeAddByte(OP_TR_END);
        _CodeAddByte(OP_CREATE);
            _CodeAddPtr(target_ptr);
        _CodeAddByte(OP_PVAR);
            TraceByte( other_middle );
    } else
    if (dot) {
        _CodeAddByte(OP_TR_END);
        _CodeAddByte(OP_PDOT);
            TraceByte( dot_middle );
    }

    _CodeAddByte(OP_POP);
        _CodeAddByte(1);
} /* C_template */
