/*
 * $Id: sub.c,v 1.5 2008/07/15 07:40:54 bnv Exp $
 * $Log: sub.c,v $
 * Revision 1.5  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.4  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.2  1999/11/26 12:52:25  bnv
 * Changed: To use lLastScannedNumber.
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#include "lerror.h"
#include "lstring.h"

/* ---------------- Lsub ------------------- */
void __CDECL
Lsub( const PLstr to, const PLstr A, const PLstr B)
{
	_Laddsub(to, A, B, TRUE);
} /* Lsub */
