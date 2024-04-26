/*
 * $Id: nextsymb.c,v 1.8 2008/07/15 07:40:25 bnv Exp $
 * $Log: nextsymb.c,v $
 * Revision 1.8  2008/07/15 07:40:25  bnv
 * #include changed from <> to ""
 *
 * Revision 1.7  2004/04/30 15:25:41  bnv
 * Spaces...
 *
 * Revision 1.6  2004/03/27 08:34:21  bnv
 * Corrected: Line number was not restored after the comma at the end of the line
 *
 * Revision 1.5  2003/01/30 08:22:37  bnv
 * Corrected: comment after the comma_sy search
 *
 * Revision 1.4  2002/06/11 12:37:38  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:51:48  bnv
 * Header -> Id
 *
 * Revision 1.2  1999/11/26 13:13:47  bnv
 * Changed: Some spaces to tabs.
 *
 * Revision 1.1  1998/07/02 17:34:50  bnv
 * Initial revision
 *
 */

#define  __NEXTSYMB_C__

#include "lerror.h"
#include "lstring.h"
#include "nextsymb.h"

static PLstr    ProgStr;    /* pointer that holds the program string*/
static int    InitNextch;    /* NextChar initialised?        */
static bool    NextBlank;    /* Next char is blank            */
static bool    commentfound;    /* if comment found in nextchar        */

bool    _in_nextsymbol;        /* Used only to track error inside nextsymb*/

/* ------------------- function prototypes ----------------------- */
static void literal(void);
static void identifier(int isnumber);

/* --------------------------------------------------------------- */
/*  return the next character and advance the input stream by one  */
/*  also it searches for comments                                  */
/* --------------------------------------------------------------- */
static void
nextchar(int instring)
{
    int    level=0;

    commentfound = FALSE;

getnextchar:
    if (instring!=-1) {
        if (*symbolptr=='\n') symboline++;
        symbolptr++;
    } else
        instring=FALSE;

    if (!instring && *symbolptr=='/' && *(symbolptr+1)=='*') {
        /* search for comment */
        commentfound = TRUE;
        symbolptr += 2;
        level++;
        for (;;) {
            while ((*symbolptr!='*') && (*symbolptr!='/')) {
                if (*symbolptr=='\n') symboline++;
                symbolptr++;
                if (*symbolptr == 0)
                    Lerror(ERR_UNMATCHED_QUOTE,1);
            };
            symbolptr++;
            if ((*(symbolptr-1)=='/') && (*symbolptr=='*')) {
                level++;
                symbolptr++;
            } else
            if ((*(symbolptr-1)=='*') && (*symbolptr=='/')) {
                --level;
                if (!level) goto getnextchar;
                symbolptr++;
            }
        }
    }
} /* nextchar */

/* --------------- InitNextsymbol -------------------- */
void __CDECL
InitNextsymbol( PLstr str )
{
    Lcat(str,"\n");    /* We must have a least one new line at the end */

    ProgStr   = str;
    LASCIIZ(*ProgStr);        /* Put a zero at the end */
    symbol    = semicolon_sy;
    symbolptr = LSTR(*ProgStr);
    symboline = 1;

    /* Skip first line,  '#!/bin/rexx' */
    if (symbolptr[0]=='#' && symbolptr[1]=='!') {
        while (*symbolptr!='\n') symbolptr++;
        symboline++;
    }

    InitNextch = FALSE;
    NextBlank  = FALSE;
    symbolstat = normal_st;
} /* InitNextsymbol */

/* --------------------------------------------------------------- */
/*            P A R S E   next  B A S I C   S Y M B O L            */
/*  Return the next basic symbol and advance the input stream      */
/* --------------------------------------------------------------- */
void __CDECL
nextsymbol(void)
{
#define NEXTCHAR    {*(ns++)=*symbolptr; LLEN(symbolstr)++; nextchar(FALSE);}

    char    *Psymbolptr, *ns;
    int    _lineno;

    if (!InitNextch) {
        /* call nextchar to search for comments */
        nextchar(-1);    /* initialise */
        commentfound = FALSE;
        InitNextch = TRUE;
    }
    /* make the type always to be LSTRING */
    LTYPE(symbolstr) = LSTRING_TY;
    LLEN(symbolstr) = 0;

    _in_nextsymbol = TRUE;
    symbolPrevBlank = NextBlank;
    NextBlank = FALSE;
_NEXTSYMBOL:

    while (*symbolptr==' ' || *symbolptr=='\t')
        nextchar(FALSE);

    ns = LSTR(symbolstr);

    symbolprevptr = symbolptr;

    switch (l2u[(byte)*symbolptr]) {
        case '0':    case '1':    case '2':
        case '3':    case '4':    case '5':
        case '6':    case '7':    case '8':
        case '9':
            symbol = literal_sy;
            identifier(TRUE);
            break;

        case 'A':    case 'B':    case 'C':
        case 'D':    case 'E':    case 'F':
        case 'G':    case 'H':    case 'I':
        case 'J':    case 'K':    case 'L':
        case 'M':    case 'N':    case 'O':
        case 'P':    case 'Q':    case 'R':
        case 'S':    case 'T':    case 'U':
        case 'V':    case 'W':    case 'X':
        case 'Y':    case 'Z':

        case '@':
        case '#':
        case '$':
        case '_':
        case '?':
        case '!':
            symbol = ident_sy;
            identifier(FALSE);
            break;

        case '/':
            NEXTCHAR;
            if (*symbolptr=='/')  {
                symbol = mod_sy;
                NEXTCHAR;
            } else
            if (*symbolptr=='=')  {
                NEXTCHAR;
                if (*symbolptr=='=')  {
                    symbol = dne_sy;
                    NEXTCHAR;
                }  else
                    symbol = ne_sy;
            } else
                symbol = div_sy;
            break;

        case '-':
            symbol = minus_sy;
            NEXTCHAR;
            break;

        case '*':
            NEXTCHAR;
            if (*symbolptr=='/')
                Lerror(ERR_INVALID_EXPRESSION,0);
            if (*symbolptr=='*')  {
                symbol = power_sy;
                NEXTCHAR;
            } else
                symbol = times_sy;
            break;

        case '~':
        case '¬':
        case '\\':
            NEXTCHAR;
            switch (*symbolptr)  {
                case '=':
                    NEXTCHAR;
                    if (*symbolptr=='=') {
                        symbol = dne_sy;
                        NEXTCHAR;
                    } else
                        symbol = ne_sy;
                    break;

                case '>':
                    NEXTCHAR;
                    if (*symbolptr=='>') {
                        symbol = dle_sy;
                        NEXTCHAR;
                    } else
                        symbol = le_sy;
                    break;

                case '<':
                    NEXTCHAR;
                    if (*symbolptr=='<') {
                        symbol = dge_sy;
                        NEXTCHAR;
                    } else
                        symbol = ge_sy;
                    break;

                default:
                    symbol = not_sy;
            }
            break;

        case '%':
            symbol = intdiv_sy;
            NEXTCHAR;
            break;

        case '(':
            symbol = le_parent;
            NEXTCHAR;
            break;

        case ')':
            symbol = ri_parent;
            NEXTCHAR;
            break;

#ifndef MSDOS
    /* Only for UNIX where \r is not recognised as \n */
        case '\r':
            NEXTCHAR;
#endif
        case '\n':
        case ';':
            symbol = semicolon_sy;
            NEXTCHAR;
            break;

        case ',':
            NEXTCHAR;
            Psymbolptr = symbolptr;
            _lineno = symboline;
            nextsymbol();
            NextBlank = FALSE;
            symbolPrevBlank = TRUE;
            if (symbol==semicolon_sy &&
                _lineno!=symboline) goto _NEXTSYMBOL;
            symbolptr = Psymbolptr;
            symboline = _lineno;
            symbol = comma_sy;
            NextBlank = FALSE;
            symbolPrevBlank = TRUE;
            commentfound = FALSE;
            break;

        case '.':
            Psymbolptr = symbolptr+1;
            if (    *Psymbolptr !=' '   &&
                *Psymbolptr !=','   &&
                *Psymbolptr !='\n'  &&
                *Psymbolptr !='\r'  &&
                *Psymbolptr !='\t'  &&
                *Psymbolptr !=';' )  {
                    symbol = literal_sy;
                    identifier(TRUE);
            } else {
                symbol = dot_sy;
                NEXTCHAR;
            }
            break;

        case '|':
            NEXTCHAR;
            if (*symbolptr=='|')  {
                symbol = concat_sy;
                NEXTCHAR;
            } else
                symbol = or_sy;
            break;

        case '&':
            NEXTCHAR;
            if (*symbolptr=='&')  {
                symbol = xor_sy;
                NEXTCHAR;
            } else
                symbol = and_sy;
            break;

        case '+':
            symbol = plus_sy;
            NEXTCHAR;
            break;

        case '=':
            NEXTCHAR;
            switch (*symbolptr)  {
                case '=':
                    NEXTCHAR;
                    symbol = deq_sy;
                    break;

                case '>':
                    NEXTCHAR;
                    if (*symbolptr=='>') {
                        NEXTCHAR;
                        symbol = dge_sy;
                    } else
                        symbol = ge_sy;
                    break;

                case '<':
                    NEXTCHAR;
                    if (*symbolptr=='<') {
                        NEXTCHAR;
                        symbol = dle_sy;
                    } else
                        symbol = le_sy;
                    break;

                default:
                    symbol = eq_sy;
            }
            break;

        case '<':
            NEXTCHAR;
            switch (*symbolptr)  {
                case '<':
                    NEXTCHAR;
                    if (*symbolptr=='=') {
                        symbol = dle_sy;
                        NEXTCHAR;
                    } else
                        symbol = dlt_sy;
                    break;

                case '=':
                    symbol = le_sy;
                    NEXTCHAR;
                    break;

                case '>':
                    symbol = ne_sy;
                    NEXTCHAR;
                    break;

                default:
                    symbol = lt_sy;
            }
            break;

        case '>':
            NEXTCHAR;
            switch (*symbolptr)  {
                case '>':
                    NEXTCHAR;
                    if (*symbolptr=='=') {
                        symbol = dge_sy;
                        NEXTCHAR;
                    } else
                        symbol = dgt_sy;
                    break;

                case '=':
                    symbol = ge_sy;
                    NEXTCHAR;
                    break;

                case '<':
                    symbol = ne_sy;
                    NEXTCHAR;
                    break;

                default:
                    symbol = gt_sy;
            }
            break;

        case '\'':
        case '\"':
            literal();
            break;

        case ':':
            Lerror(ERR_SYMBOL_EXPECTED,0);
            break;

        case 0:
            _in_nextsymbol = FALSE;
            if ((symbolstat == in_do_st) ||
                (symbolstat == in_if_st))
                Lerror(ERR_INCOMPLETE_STRUCT,0);
            else
            if (symbolstat == in_if_init_st)
                Lerror(ERR_THEN_EXPECTED,0);
            else
            if (symbolstat != normal_st)
                Lerror(ERR_SYMBOL_EXPECTED,0);
            symbol = exit_sy;
            break;

        default:
            Lerror(ERR_INVALID_CHAR,0);
    }
    if (    *symbolptr== ' ' ||
        *symbolptr=='\t' ||
        *symbolptr== ',' )
            NextBlank = TRUE;
    _in_nextsymbol = FALSE;
} /* nextsymbol */

/* --------------------------------------------------------------- */
/*      find the identifier                                        */
/* --------------------------------------------------------------- */
static void
identifier(int isnumber)
{
    char    *s;
    int    l;     /* length */     /* -+-  l > maxlen ? */
    int    hasDot=FALSE, hasExp=FALSE;

    symbolisstr   = FALSE;
    symbolhasdot  = 0;
    s = LSTR(symbolstr);
    l = 0;

    for (;;) {
        if (l>LMAXLEN(symbolstr))
            Lerror(ERR_TOO_LONG_STRING,0);

        if (commentfound &&
            *symbolptr!='(' && *symbolptr!=':') {
            commentfound = FALSE;
            *s='\0';
            LLEN(symbolstr) = l;
            goto Nleave;
        }

        switch (l2u[(byte)*symbolptr]) {
            case '0':   case '1':    case '2':
            case '3':   case '4':    case '5':
            case '6':   case '7':    case '8':
            case '9':
                *s++ = *symbolptr;
                l++;
                nextchar(FALSE);
                break;

            case 'A':   case 'B':    case 'C':
            case 'D':   case 'E':    case 'F':
            case 'G':   case 'H':    case 'I':
            case 'J':   case 'K':    case 'L':
            case 'M':   case 'N':    case 'O':
            case 'P':   case 'Q':    case 'R':
            case 'S':   case 'T':    case 'U':
            case 'V':   case 'W':    case 'X':
            case 'Y':   case 'Z':

            case '@':
            case '#':
            case '$':
            case '_':
            case '?':
            case '!':
                *s = l2u[(byte)*symbolptr];
                if (isnumber) {
                    if (*s=='E') {
                        if (hasExp)
                            isnumber = FALSE;
                        hasExp = TRUE;
                    } else
                        isnumber = FALSE;
                }
                s++; l++;
                nextchar(FALSE);
                break;

            case '+':
            case '-':
                if (isnumber) {
                    if (*(s-1)=='E') {
                        *s++ = *symbolptr; l++;
                        nextchar(FALSE);
                    } else {
                        *s='\0';
                        LLEN(symbolstr) = l;
                        goto Nleave;
                    }
                } else {
                    *s='\0';
                    LLEN(symbolstr) = l;
                    goto Nleave;
                }
                break;

            case '.':
                *s++ = *symbolptr; l++;
                if (!symbolhasdot)    /* position of first */
                    symbolhasdot = l;    /* dot */
                nextchar(FALSE);
                if (isnumber) {
                    if (hasDot)
                        isnumber = FALSE;
                    hasDot = TRUE;
                    symbolhasdot = 0;
                }
                break;

            case '(':
                nextchar(FALSE);
                *s='\0';
                LLEN(symbolstr) = l;
                symbol = function_sy;
                return;

            case ':':
                nextchar(FALSE);
                *s='\0';
                LLEN(symbolstr) = l;
                symbol = label_sy;
                return;

            case '\t':
            case ' ':
                NextBlank = TRUE;
                *s='\0';
                LLEN(symbolstr)=l;
                while (*symbolptr==' '||*symbolptr=='\t')
                    nextchar(FALSE);

                /* literal finished and it is not a label? */
                if (*symbolptr!=':')
                    goto Nleave;

                /* literal is label */
                symbol = label_sy;
                nextchar(FALSE);
                return;

            default:
                *s='\0';
                LLEN(symbolstr) = l;
                goto Nleave;
        }  /* end of switch */
    } /* end of for */
Nleave:
    if (symbol!=ident_sy) return ;

    if (symbolhasdot == LLEN(symbolstr))
        symbolhasdot = 0;    /* treat is as a variable */

    if (symbolstat == in_do_init_st)  {
             if (!Lcmp(&symbolstr,"BY"   ))  symbol = by_sy;
        else if (!Lcmp(&symbolstr,"FOR"  ))  symbol = for_sy;
        else if (!Lcmp(&symbolstr,"TO"   ))  symbol = to_sy;
        else if (!Lcmp(&symbolstr,"UNTIL"))  symbol = until_sy;
        else if (!Lcmp(&symbolstr,"WHILE"))  symbol = while_sy;
    } else
    if (symbolstat == in_parse_value_st) {
        if (!Lcmp(&symbolstr,"WITH" ))  symbol = with_sy;
    } else
    if (symbolstat == in_if_init_st) {
        if (!Lcmp(&symbolstr,"THEN" ))  symbol = then_sy;
    }
} /* identifier */

/* --------------------------------------------------------------- */
/*  extract a literal symbol                                       */
/* --------------------------------------------------------------- */
static void
literal(void)
{
    char    quote;
    char    *s;
    int    l;      /* length of symbolstr */
    Lstr    A;

    symbolhasdot = 0;
    symbol = literal_sy;
    quote  = *symbolptr;
    s = LSTR(symbolstr);
    l = 0;
    symbolisstr = TRUE;

    for (;;)  {            /* -+-  l > maxlen ? */
        nextchar(TRUE);
        if (l>=LMAXLEN(symbolstr))
            Lerror(ERR_TOO_LONG_STRING,0);
        if (*symbolptr==quote) {
            nextchar(FALSE);    /* quote ended?? */
            if (*symbolptr == '(') {
                *s = '\0';
                LLEN(symbolstr) = l;
                symbol = function_sy;
                nextchar(FALSE);
                return;
            } else
            if (commentfound) {    /* a comment was inside */
                commentfound = FALSE;
                *s = '\0';
                LLEN(symbolstr) = l;
                return;
            } else
            if (STRCHR("bBxXhH",*symbolptr)) {
                /* check next char */
                char    nc=l2u[(byte)*(symbolptr+1)];

                *s = '\0';
                LLEN(symbolstr) = l;

                if (IN_RANGE('0',nc,'9') ||
                    IN_RANGE('A',nc,'Z') ||
                    nc=='@' || nc=='#' || nc=='$' ||
                    nc=='_' || nc=='?' || nc=='!' ||
                    nc=='.')
                    return;

                LINITSTR(A);

                switch (l2u[(byte)*symbolptr]) {
                    case 'B':
                        if (!Ldatatype(&symbolstr,'B'))
                            Lerror(ERR_INVALID_HEX_CONST,0);
                        Lb2x(&A,&symbolstr);
                        Lx2c(&symbolstr,&A);
                        break;
                    case 'H':
                        if (!Ldatatype(&symbolstr,'X'))
                            Lerror(ERR_INVALID_HEX_CONST,0);
                        Lx2d(&A,&symbolstr,0);
                        Lstrcpy(&symbolstr,&A);
                        break;
                    case 'X':
                        if (!Ldatatype(&symbolstr,'X'))
                            Lerror(ERR_INVALID_HEX_CONST,0);
                        Lx2c(&A,&symbolstr);
                        Lstrcpy(&symbolstr,&A);
                        break;
                }
                nextchar(FALSE);
                LFREESTR(A);
                return;
            } else
            if (*symbolptr==quote) {
                *s++ = *symbolptr; l++;
            }  else  {
                *s = '\0';
                LLEN(symbolstr) = l;
                return;
            }
        } else
        if (*symbolptr == '\n') {
            *s++ = ' '; l++;
        } else
        if (*symbolptr == 0)
            Lerror(ERR_UNMATCHED_QUOTE,
                (quote=='\'')?2:3);
        else {
            *s++ = *symbolptr;
            l++;
        }
    }
} /* literal */
