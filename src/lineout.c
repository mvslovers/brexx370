/*
 * $Id: lineout.c,v 1.6 2008/07/15 07:40:54 bnv Exp $
 * $Log: lineout.c,v $
 * Revision 1.6  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.5  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.4  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.3  1999/11/26 12:52:25  bnv
 * Changed: To use the new macros.
 *
 * Revision 1.2  1999/03/15 15:25:53  bnv
 * Corrected: initial value to prev
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#include "lstring.h"

/* ---------------- Llineout ------------------- */
int __CDECL
Llineout( FILEP f, const PLstr line, long *curline, long start )
{
    int    ch,prev='\n';

    /* find current line */
    if (start>=0) {
        if (*curline>start) {
            *curline = 1;
            FSEEK(f,0,SEEK_SET);
        }
        while (start>*curline) {
            ch = FGETC(f);
            if (ch==-1) {
                if (prev!='\n') (*curline)++;
                break;
            }
            if (ch=='\n') (*curline)++;
            prev = ch;
        }
        while (start > *curline) {
            FPUTC('\n',f);
            (*curline)++;
        }
    }

    Lwrite(f,line,TRUE);
    (*curline)++;
    return 0;        /* if everything ok */
} /* Llineout */
