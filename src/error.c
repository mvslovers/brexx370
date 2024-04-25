/*
 * $Id: error.c,v 1.10 2008/07/15 07:40:25 bnv Exp $
 * $Log: error.c,v $
 * Revision 1.10  2008/07/15 07:40:25  bnv
 * #include changed from <> to ""
 *
 * Revision 1.9  2006/01/26 10:25:11  bnv
 * Windows CE support
 *
 * Revision 1.8  2004/08/16 15:28:44  bnv
 * Spaces
 *
 * Revision 1.7  2004/04/30 15:29:44  bnv
 * const removed
 *
 * Revision 1.6  2003/10/30 13:16:28  bnv
 * Variable name change
 *
 * Revision 1.5  2002/08/22 12:31:28  bnv
 * Removed CR's
 *
 * Revision 1.4  2002/06/11 12:37:38  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:51:48  bnv
 * Header -> Id
 *
 * Revision 1.2  1999/11/26 13:13:47  bnv
 * Changed: To use the new macros
 *
 * Revision 1.1  1998/07/02 17:34:50  bnv
 * Initial revision
 *
 */

#include <stdarg.h>
#include "lstring.h"

#include "rexx.h"
#include "trace.h"
#include "compile.h"
#include "interpre.h"
#include "variable.h"
#include "nextsymb.h"

/* --- Global variable --- */
Lstr	errmsg;			/* initialise string from beggining  */

/* ---------------- RxHaltTrap ----------------- */
void __CDECL
RxHaltTrap( int cnd )
{
	if (_proc[_rx_proc].condition & SC_HALT)
		RxSignalCondition(SC_HALT);
	else
		Lerror(ERR_PROG_INTERRUPT,0);
} /* RxHaltTrap */

/* ---------------- RxSignalCondition -------------- */
void __CDECL
RxSignalCondition( int cnd )
{
	PBinLeaf	leaf;
	RxFunc	*func;
	PLstr	cndstr;

/*///////// first we need to terminate all the interpret strings */
	switch (cnd) {
		case SC_ERROR:
			cndstr = _proc[_rx_proc].lbl_error;
			break;
		case SC_HALT:
			cndstr = _proc[_rx_proc].lbl_halt;
			break;
		case SC_NOVALUE:
			cndstr = _proc[_rx_proc].lbl_novalue;
			break;
		case SC_NOTREADY:
			cndstr = _proc[_rx_proc].lbl_notready;
			break;
		case SC_SYNTAX:
			cndstr = _proc[_rx_proc].lbl_syntax;
			break;
	}
	leaf = BinFind(&_labels,cndstr);
	if (leaf==NULL || ((RxFunc*)(leaf->value))->label==UNKNOWN_LABEL) {
		if (cnd==SC_SYNTAX) /* disable the error handling */
			_proc[_rx_proc].condition &= ~SC_SYNTAX;
		Lerror(ERR_UNEXISTENT_LABEL,1,cndstr);
	}
	func = (RxFunc*)(leaf->value);
	RxSetSpecialVar(SIGLVAR,TraceCurline(NULL,FALSE));
	Rxcip = (CIPTYPE*)((byte huge *)Rxcodestart + (size_t)(func->label));
	longjmp(_error_trap,JMP_CONTINUE);
} /* RxSignalCondition */

/* ------------------ Rerror ------------------- */
void __CDECL
Rerror( const int _errno, const int subno, ... )
{
	int	line;
	RxFile	*rxf;
#ifndef WIN
	va_list	ap;
#endif

	if (_proc[_rx_proc].condition & SC_SYNTAX) {
		RxSetSpecialVar(RCVAR,_errno);
		if (symbolptr==NULL)	/* we are in intepret	*/
			RxSignalCondition(SC_SYNTAX);
		else {			/* we are in compile	*/
			rxReturnCode = _errno;
			longjmp(_error_trap,JMP_ERROR);
		}
	} else {
		line = TraceCurline(&rxf,TRUE);
		if (symbolptr==NULL)	/* we are in intepret */
			RxSetSpecialVar(SIGLVAR,line);

#ifndef WIN
		va_start(ap,subno);
		Lerrortext(&errmsg,_errno,subno,&ap);
		va_end(ap);

		if (LLEN(errmsg)==0)
			fprintf(STDERR," +++ Ooops unknown error %d.%d +++\n",_errno,subno);
		else {
			LASCIIZ(errmsg);
			if (subno==0)
				fprintf(STDERR,
					"Error %d running %s, line %d: %s\n",
						_errno,
						LSTR(rxf->name),
						line,
						LSTR(errmsg));
			else
				fprintf(STDERR,
					"Error %d.%d running %s, line %d: %s\n",
						_errno,
						subno,
						LSTR(rxf->name),
						line,
						LSTR(errmsg));
		}
#else
		{
			PUTS("Error ");
			PUTINT(_errno,0,10);
			PUTS(" running ");
			PUTS(LSTR(rxf->name));
			PUTS(" line ");
			PUTINT(line,0,10);
			PUTS(": ");
			Lerrortext(&errmsg,_errno,subno,NULL);
			Lprint(NULL,&errmsg);
			PUTCHAR('\n');
		}
#endif
		rxReturnCode = _errno;
		longjmp(_exit_trap,JMP_EXIT);
	}
} /* Rerror */
