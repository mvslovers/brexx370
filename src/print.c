/*
 * $Id: print.c,v 1.15 2017/01/12 11:11:06 bnv Exp $
 * $Log: print.c,v $
 * Revision 1.15  2017/01/12 11:11:06  bnv
 * Updated gcvt
 *
 * Revision 1.13  2011/06/20 08:31:19  bnv
 * removed the FCVT and GCVT replaced with sprintf
 *
 * Revision 1.12  2009/06/02 09:40:53  bnv
 * MVS/CMS corrections
 *
 * Revision 1.11  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.10  2008/07/14 13:08:16  bnv
 * MVS,CMS support
 *
 * Revision 1.9  2004/08/16 15:25:53  bnv
 * Changed: to buffered printing for WCE
 *
 * Revision 1.8  2004/03/26 22:52:08  bnv
 * Increased conversion accurary of floats
 *
 * Revision 1.7  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.6  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.5  1999/11/26 12:52:25  bnv
 * Added: Windows CE support
 * Changed: the ANSI_PRINTF to keep the gcc compiler happy
 *
 * Revision 1.4  1999/05/26 16:47:42  bnv
 * Gene corrections in RXCONIO
 *
 * Revision 1.3  1999/03/10 16:55:55  bnv
 * Correction for RXCONIO
 *
 * Revision 1.2  1999/02/10 15:45:16  bnv
 * RXCONIO support by Generoso Martello
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#include "lstring.h"

#ifdef RXCONIO
#	define ANSI_FPRINTF(fd,fs,ff)	if (fd==STDOUT) \
				cprintf(fs,ff); else fprintf(fd,fs,ff)
#	define ANSI_FPUTS(fd,fs)	if (fd==STDOUT) \
				cprintf(fs); else fprintf(fd,fs)
#else
#	define ANSI_FPRINTF(fd,fs,ff)	fprintf(fd,fs,ff)
#	define ANSI_FPUTS(fd,fs)	fprintf(fd,fs)
#endif

/* ---------------- Lprint ------------------- */
void __CDECL
Lprint( FILEP f, const PLstr str )
{
	size_t	l;
	char	*c;
	char	s[64];

#ifndef WIN
	if (str==NULL) {
		ANSI_FPUTS(f,"<NULL>");
		return;
	}
#endif

	switch (LTYPE(*str)) {
		case LSTRING_TY:
			c = LSTR(*str);
#if defined(WIN) || defined(WCE)
			if (f==STDOUT) {
				l = 0;
				LASCIIZ(*str);
				while (l<LLEN(*str)) {
					PUTS(c);
					l += STRLEN(c);
				}
			} else
				for (l=0; l<LLEN(*str); l++)
					FPUTC(*c++,f);
#else
			for (l=0; l<LLEN(*str); l++)
#ifdef RXCONIO
				if (f==STDOUT) {
					putch(*c++);
				} else
#endif
				FPUTC(*c++,f);
#endif
			break;

		case LINTEGER_TY:
#ifdef WIN
			FPUTS(LTOA(LINT(*str),s,10), f);
#else
			ANSI_FPRINTF(f,"%ld", LINT(*str));
#endif
			break;

		case LREAL_TY:
#if defined(HAVE_GCVT)
			GCVT(LREAL(*str),lNumericDigits,s);
#else
			snprintf(s, sizeof(s), "%.*g", lNumericDigits, LREAL(*str));
#endif
#ifdef WIN
			FPUTS(s, f);
#else
			ANSI_FPUTS(f, s);
//			ANSI_FPRINTF(f, lFormatStringToReal, LREAL(*str));
#endif
			break;
	}
} /* Lprint */
