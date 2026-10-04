/*
 * $Id: sign.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: sign.c,v $
 * Revision 1.4  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.3  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.2  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#include "lstring.h"

/* ------------------ Lsign --------------------- */
int __CDECL
Lsign( const PLstr num )
{
	double	r;

	Lrdnum(num, &r);	/* read, do not convert (#305) */
	if (r < 0) return -1;
	if (r > 0) return  1;
	return 0;
} /* Lsign */
