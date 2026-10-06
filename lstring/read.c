#include <stdio.h>
#include <string.h>
#include "lstring.h"

#ifdef __MVS__
/* libc370's fgetc() takes an ENQ and a DEQ for every byte; fgets() and
 * fread() lock once per call. So lines are read with fgets(). It stops
 * after the first '\n', so the first '\n' in a zeroed buffer is the
 * end of the line, whatever X'00' the record holds before it. */

/* One line into line, without its '\n'; returns its length */
static long
readLine( FILEP f, const PLstr line )
{
	long	l = 0;
	char	*p;
	char	*nl;
	size_t	room;

	Lfx(line,LREADINCSIZE);
	while (1) {
		room = (size_t)LMAXLEN(*line) - (size_t)l;
		p = (char *)LSTR(*line) + l;
		memset(p, 0, room);
		if (fgets(p, (int)room, f) == NULL) break;	/* EOF */
		nl = memchr(p, '\n', room);
		if (nl != NULL) {
			l += (long)(nl - p);
			break;
		}
		if (FEOF(f)) {			/* last line without '\n' */
			l += (long)strlen(p);
			break;
		}
		l += (long)room - 1;		/* buffer full: go on */
		Lfx(line, (size_t)l+LREADINCSIZE);
	}
	return l;
} /* readLine */
#endif

/* ---------------- Lskipline ------------------- */
/* Read past the next '\n'. Returns 1 if one was read, 0 at the end of
 * the file; *any tells whether any byte was read at all, so a last line
 * without '\n' can be counted. */
int __CDECL
Lskipline( FILEP f, int *any )
{
#ifdef __MVS__
	char	buf[256];

	*any = 0;
	while (1) {
		memset(buf, 0, sizeof(buf));
		if (fgets(buf, (int)sizeof(buf), f) == NULL) return 0;
		*any = 1;
		if (memchr(buf, '\n', sizeof(buf)) != NULL) return 1;
	}
#else
	int	ch;

	*any = 0;
	while ((ch = FGETC(f)) != EOF) {
		*any = 1;
		if (ch == '\n') return 1;
	}
	return 0;
#endif
} /* Lskipline */

/* ---------------- Lread ------------------- */
void __CDECL
Lread( FILEP f, const PLstr line, long size )
{
	long	l;
	char	*c;
#ifndef __MVS__
	int	ci;
#endif

	/* We use the fgetc and not the fread to get rid of the 0x0D */
	if (size>0) {
        int iRead = 0;
        l = 0;
        Lfx(line,(size_t)size);
        c = (char *)LSTR(*line);
        iRead = (int)fread(c, 1, size, f);
        if (iRead != 0) l = iRead;
	} else
	if (size==0) {			/* Read a single line */
#ifdef __MVS__
		l = readLine(f, line);
#else
		Lfx(line,LREADINCSIZE);
		l = 0;

            while ((ci=FGETC(f))!='\n') {
                if (ci==EOF) break;
                c = LSTR(*line) + l;
                *c = ci;
                if ((size_t) (++l) >= LMAXLEN(*line))
                    Lfx(line, (size_t)l+LREADINCSIZE);
            }
#endif
	} else {			/* Read entire file */
#ifdef __MVS__
		size = 0; /* Always do it the slow way: so no-seek (JCL inline) files work. */
#	else
        l = FTELL(f);
		if (l>=0) {
			FSEEK(f,0L,SEEK_END);
			size = FTELL(f) - l + 1;
			FSEEK(f,l,SEEK_SET);
		}
#endif
		if (size>0) {
			Lfx(line,(size_t)size);
			c = LSTR(*line);
			l = 0;
			while (1) {
				int ch = FGETC(f);
				if (ch==EOF) break;
				*c++ = ch;
				l++;
			}
			/*??? if (*c=='\n') l--; // If it is binary then wrong! */
		}
		else {	/* probably STDIN */
			/* In blocks, not one FGETC per byte: libc370's fgetc()
			 * takes an ENQ and a DEQ for every byte, and reading a
			 * 550-line exec that way took over five seconds. fread()
			 * locks once and hands back the same bytes. */
			Lfx(line,LREADINCSIZE);
			l = 0;
			while (1) {
				size_t	n = fread(LSTR(*line)+l, 1,
						(size_t)LMAXLEN(*line)-(size_t)l, f);
				if (n==0) break;
				l += (long)n;
				if ((size_t)l >= LMAXLEN(*line))
					Lfx(line, (size_t)l+LREADINCSIZE);
			}
		}
	}
	LLEN(*line) = l;
	LTYPE(*line) = LSTRING_TY;
#ifdef __MVS__
	LASCIIZ(*line);
#endif
} /* Lread */
