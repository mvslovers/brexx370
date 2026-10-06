/*
 * $Id: write.c,v 1.8 2008/07/15 07:40:54 bnv Exp $
 * $Log: write.c,v $
 * Revision 1.8  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.7  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.6  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.5  1999/11/26 12:52:25  bnv
 * Changed: To use the new macros
 *
 * Revision 1.4  1999/05/26 16:47:42  bnv
 * Gene corrections in RXCONIO
 *
 * Revision 1.3  1999/03/10 16:55:55  bnv
 * Added MSC support
 *
 * Revision 1.2  1999/02/10 15:45:16  bnv
 * RXCONIO support by Generoso Martello
 *
 * Revision 1.1  1998/07/02 17:20:58  bnv
 * Initial Version
 *
 */

#include "lstring.h"

/* ---------------- Lwrite ------------------- */
void __CDECL
Lwrite( FILEP f, const PLstr line, const bool newline)
{
	long	l;
	char	*c;

	L2STR(line);
	c = LSTR(*line);
	l = LLEN(*line);
#ifdef __MVS__
	/* one fwrite(), not one FPUTC per byte: libc370's fputc() takes an
	 * ENQ and a DEQ for every byte, fwrite() locks once per call and
	 * writes the same bytes through the same __fputc() */
	if (l > 0)
		fwrite(c, 1, (size_t)l, f);
	l = 0;
#endif
	while (l--)
#ifdef RXCONIO
		if (f==STDOUT) {
			putch(*c++);
		} else
#endif
		FPUTC(*c++,f);
	if (newline)
		FPUTC('\n',f);
} /* Lwrite */
