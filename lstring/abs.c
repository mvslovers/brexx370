/*
 * $Id: abs.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: abs.c,v $
 * Revision 1.4  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.3  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.2  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.1  1998/07/02 17:16:35  bnv
 * Initial revision
 *
 */

#include <math.h>
#include "lstring.h"

/* ------------------ Labs ---------------------- */
void __CDECL
Labs( const PLstr to, const PLstr num )
{
	double	r;

	/* read, do not convert the caller's number (#305) */
	if (Lrdnum(num, &r) == LINTEGER_TY) {
		if ((long) r == INT32_MIN)	/* no integer (#110) */
			Lrcpy(to,-(double)INT32_MIN);
		else
			Licpy(to,labs((long) r));
	} else
		Lrcpy(to,fabs(r));
} /* Labs */
