/*
 * $Id: trace.c,v 1.10 2011/05/17 06:53:10 bnv Exp $
 * $Log: trace.c,v $
 * Revision 1.10  2011/05/17 06:53:10  bnv
 * Added SQLite
 *
 * Revision 1.9  2009/09/14 14:00:56  bnv
 * __DEBUG__ format correction
 *
 * Revision 1.8  2008/07/15 07:40:25  bnv
 * #include changed from <> to ""
 *
 * Revision 1.7  2004/04/30 15:27:34  bnv
 * Type changes
 *
 * Revision 1.6  2003/10/30 13:16:28  bnv
 * Variable name change
 *
 * Revision 1.5  2002/06/11 12:37:38  bnv
 * Added: CDECL
 *
 * Revision 1.4  2001/06/25 18:51:23  bnv
 * Added: Memory check in debug version when the trace is enabled.
 *
 * Revision 1.3  1999/11/26 13:13:47  bnv
 * Changed: To use the new macros.
 * Changed: To support 64-bit cpus.
 *
 * Revision 1.2  1999/03/10 16:55:35  bnv
 * A bracket addition to keep compiler happy.
 *
 * Revision 1.1  1998/07/02 17:34:50  bnv
 * Initial revision
 *
 */

#define __TRACE_C__

#include <stdlib.h>
#include "lstring.h"

#include "rexx.h"
#include "trace.h"
#include "compile.h"
#include "interpre.h"
#include "variable.h"
#include "nextsymb.h"

/* ---------- function prototypes ------------- */
void    __CDECL RxInitInterStr();

/* ---------- Extern variables ---------------- */
extern    Clause    *CompileClause;        /* compile clauses    */
extern    int    CompileCurClause;    /* current clause    */
extern    ErrorMsg errortextÝ¨;        /* from lstring/errortxt.c */
extern    bool    _in_nextsymbol;        /* from nextsymb.c    */
extern    int    _trace;            /* from interpret.c    */
extern    PLstr    RxStckÝ¨;        /*     -//-        */
extern    int    RxStckTop;        /*     -//-        */
extern    Lstr    _tmpstrÝ¨;        /*     -//-        */

static    char    TraceCharÝ¨ = {' ','>','L','V','C','O','F','.'};

/* ----------------- TraceCurline ----------------- */
int __CDECL
TraceCurline( RxFile **rxf, int print )
{
    size_t    line;
    size_t    cl, codepos;
    char    *ch, *chend;

    if (symbolptr==NULL) {    /* we are in intepret */
        if (CompileClause==NULL) {
            if (rxf) *rxf = rxFileList;
            return -1;
        }

        codepos = (size_t)((byte huge *)Rxcip - (byte huge *)Rxcodestart);
        /* search for clause */
        cl = 0;
        while (CompileClauseÝcl¨.ptr) {
            if (CompileClauseÝcl¨.code >= codepos)
                break;
            cl++;
        }
        cl--;
        line  = CompileClauseÝcl¨.line;
        ch    = CompileClauseÝcl¨.ptr;
        chend = CompileClauseÝcl+1¨.ptr;
        if (chend==NULL)
            for (chend=ch; *chend!='\n'; chend++) /*do nothing*/;;
        _nesting = _rx_proc + CompileClauseÝcl¨.nesting;
        if (rxf)
            *rxf = CompileClauseÝ cl ¨.fptr;
    } else {        /* we are in compile  */
        if (CompileCurClause==0)
            cl = 0;
        else
            cl = CompileCurClause-1;

        _nesting   = CompileClauseÝ cl ¨.nesting;
        if (rxf) {
            if (CompileCurClause==0)
                *rxf = CompileRxFile;
            else
                *rxf = CompileClauseÝ cl ¨.fptr;
        }
        if (_in_nextsymbol) {
            line = symboline;
            ch   = symbolptr;
            while (ch>symbolprevptr)
                if (*ch--=='\n') line--;
            ch = symbolprevptr;
        } else
        if (cl==0) {
            line = 1;
            ch   = (char*)LSTR((*rxf)->file);
        } else {
            cl   = CompileCurClause-1;
            line = CompileClauseÝ cl ¨.line;
            ch   = CompileClauseÝ cl ¨.ptr;
        }
        for (chend=ch; *chend!=';' && *chend!='\n'; chend++) /*do nothing*/;;
    }

#ifndef WIN
    if (print) {
        int    i;

        fprintf(STDERR,"%6zd *-* ",line);
        for (i=1; i<_nesting; i++) fputc(' ',STDERR);

        while (*ch && ch<chend) {
            if (*ch!='\n')
                fputc(*ch,STDERR);
            ch++;
        }
        fputc('\n',STDERR);
    }
#else
    if (print) {
        int    i;

        PUTINT(line,6,10);
        PUTS(" *-* ");
        for (i=1; i<_nesting; i++) PUTCHAR(' ');

        while (*ch && ch<chend) {
            if (*ch!='\n')
                PUTCHAR(*ch);
            ch++;
        }
        PUTCHAR('\n');
    }
#endif
    return line;
} /* TraceCurline */

/* ---------------- TraceSet -------------------- */
void __CDECL
TraceSet( PLstr trstr )
{
    unsigned char *ch;

    L2STR(trstr);
    Lupper(trstr);
    LASCIIZ(*trstr);
    ch = LSTR(*trstr);
    if (*ch=='!') {
        ch++;
    } else
    if (*ch=='?') {
        _procÝ_rx_proc¨.interactive_trace
            = 1 - _procÝ_rx_proc¨.interactive_trace;
        if (_procÝ_rx_proc¨.interactive_trace)
#ifndef WIN
            fprintf(STDERR,"       +++ %s +++\n",errortextÝ2¨.errormsg);
#else
            PUTS("       +++ ");
            PUTS(errortextÝ0¨.errormsg);
            PUTS(" +++\n");
#endif
        ch++;
    }

    switch (*ch) {
        case 'A':
            _procÝ_rx_proc¨.trace = all_trace;
            break;
        case 'C':
            _procÝ_rx_proc¨.trace = commands_trace;
            break;
        case 'E':
            _procÝ_rx_proc¨.trace = error_trace;
            break;
/*
///        case 'F':
///            _procÝ_rx_proc¨.trace = ;
///            break;
*/
        case 'I':
            _procÝ_rx_proc¨.trace = intermediates_trace;
            break;
        case 'L':
            _procÝ_rx_proc¨.trace = labels_trace;
            break;
        case 'N':
            _procÝ_rx_proc¨.trace = normal_trace;
            break;
        case 'O':
            _procÝ_rx_proc¨.trace = off_trace;
            _procÝ_rx_proc¨.interactive_trace = FALSE;
            break;
        case 'R':
            _procÝ_rx_proc¨.trace = results_trace;
            break;
        case 'S':
            _procÝ_rx_proc¨.trace = scan_trace;
            break;
#ifdef __DEBUG__
        case 'D':
            __debug__ = 1-__debug__;
            if (__debug__)
                printf("\n\nInternal DEBUG starting...\n");
            else
                printf("\n\nInternal DEBUG ended\n");
            break;
#endif
        default:
            Lerror(ERR_INVALID_TRACE,1,trstr);
    }
} /* TraceSet */

/* --------------------- TraceByte -------------------- */
void __CDECL
TraceByte( int middlechar )
{
    byte    tracebyte=0;

    tracebyte |= (middlechar & TB_MIDDLECHAR);
    tracebyte |= TB_TRACE;

    _CodeAddByte( tracebyte );
} /* TraceByte */

/* ------------------ TraceClause ----------------- */
void __CDECL
TraceClause( void )
{
    if (_procÝ_rx_proc¨.interactive_trace) {
        /* return if user specified a string for interactive trace */
        if (TraceInteractive(TRUE))
            return;
    }
    TraceCurline(NULL,TRUE);
#ifdef __DEBUG__
    mem_chk();
#endif
} /* TraceClause */

/* ------------------ TraceInstruction ----------------- */
void __CDECL
TraceInstruction( CIPTYPE inst )
{
    if ((inst & TB_MIDDLECHAR) != nothing_middle)
        if (_procÝ_rx_proc¨.trace == intermediates_trace) {
            int    i;
#ifndef WIN
            fprintf(STDERR,"       >%c>  ",TraceCharÝ inst & TB_MIDDLECHAR ¨);
            for (i=0; i<_nesting; i++) fputc(' ',STDERR);
            fputc('\"',STDERR);
            Lprint(STDERR,RxStckÝRxStckTop¨);
            fprintf(STDERR,"\"\n");
#else
            PUTS("       >");
            PUTCHAR(TraceCharÝ inst & TB_MIDDLECHAR ¨);
            PUTS(">  ");
            for (i=0; i<_nesting; i++) PUTCHAR(' ');
            PUTCHAR('\"');
            Lprint(NULL,RxStckÝRxStckTop¨);
            PUTS("\"\n");
#endif
        }
} /* TraceInstruction */

/* ---------------- TraceInteractive ------------------- */
int __CDECL
TraceInteractive( int frominterpret )
{
    /* Read the interactive string into a tmp var */
    RxStckTop++;
    RxStckÝRxStckTop¨ = &(_tmpstrÝRxStckTop¨);

    Lread(STDIN,RxStckÝRxStckTop¨,LREADLINE);
    if (!LLEN(*RxStckÝRxStckTop¨)) {
        RxStckTop--;
        return FALSE;
    }

    _trace = FALSE;

    RxInitInterStr();
    _procÝ_rx_proc¨.calltype = CT_INTERACTIVE;
    if (frominterpret) {
        _procÝ_rx_proc¨.calltype = CT_INTERACTIVE;
        /* lets go again to NEWCLAUSE */
#ifdef ALIGN
        _procÝ_rx_proc¨.ip-=sizeof(dword);
#else
        _procÝ_rx_proc¨.ip--;
#endif
    }
    return TRUE;
} /* TraceInteractive */
