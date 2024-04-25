/*
 * $Id: lines.c,v 1.7 2008/07/15 07:40:54 bnv Exp $
 * $Log: lines.c,v $
 * Revision 1.7  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.6  2008/07/14 13:08:16  bnv
 * MVS,CMS support
 *
 * Revision 1.5  2004/03/26 22:51:11  bnv
 * Changed to handle FIFO, devices and files
 *
 * Revision 1.4  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.2  1999/11/26 12:52:25  bnv
 * Changed: To use the new macros.
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#if !defined(WIN) && !defined(__CMS__) && !defined(__MVS__)
#    include <sys/stat.h>
#    include <unistd.h>
#endif

#include "lstring.h"

/* ---------------- Llines ------------------- */
long __CDECL
Llines( FILEP f )
{
    long    pos,l;
    int    ch,prev;

#if !defined(WIN) && !defined(__CMS__) && !defined(__MVS__)
    struct stat buf;
    fstat(fileno(f),&buf);
    if (S_ISCHR(buf.st_mode) || S_ISFIFO(buf.st_mode))
        return !FEOF(f);
#endif

    pos = FTELL(f);        /* read current position */
    l = 0;
    prev = -1;
    while (1) {
        ch = FGETC(f);
        if (ch==-1) {
            if (prev!=-1 && prev!='\n') l++;
            break;
        }
        if (ch=='\n') l++;
        prev = ch;
    }
    FSEEK(f,pos,SEEK_SET);
    return l;
} /* Llines */
