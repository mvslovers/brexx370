#include <stdio.h>
#include "lstring.h"

/* ---------------- Lread ------------------- */
void __CDECL
Lread( FILEP f, const PLstr line, long size )
{
	long	l;
	char	*c;
	int	ci;

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
		Lfx(line,LREADINCSIZE);
		l = 0;

            while ((ci=FGETC(f))!='\n') {
                if (ci==EOF) break;
                c = LSTR(*line) + l;
                *c = ci;
                if ((size_t) (++l) >= LMAXLEN(*line))
                    Lfx(line, (size_t)l+LREADINCSIZE);
            }
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
			Lfx(line,LREADINCSIZE);
			l = 0;
			while ((ci=FGETC(f))!=EOF) {
				c = LSTR(*line) + l;
				*c = ci;
				if ((size_t) (++l) >= LMAXLEN(*line))
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
