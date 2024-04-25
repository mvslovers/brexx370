/*
 * $Id: soundex.c,v 1.5 2008/07/15 07:40:54 bnv Exp $
 * $Log: soundex.c,v $
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
 * Nothing important.
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#include <ctype.h>
#include <string.h>
#include "lstring.h"

/* ------------------------* Soundex *--------------------------- */
#define MAX_LENGTH     20    /* max # of chars to check    */
#define SOUNDEX_LENGTH  4    /* length of Soundex code    */

#define ALPHA_OFFSET    65    /* ALPHA_OFFSET is decimal    */
                /* value of 'A' in ASCII character set    */
void __CDECL
Lsoundex( const PLstr to, const PLstr str )
{
    /* ctable contains the Soundex value of each
       letter in alphabetical order. 0 represents
       letters which are to be ignored. */
    char        *code, *name;
    static char    ctableÝ¨ =  { "01230120022455012623010202" };
    char        prior=' ', c;
    short        i, y=0;
    word        len;


    /* ---- initialise ---- */
    L2STR(str);
    LZEROSTR(*to);
    Lfx(to,SOUNDEX_LENGTH);

    len = LLEN(*str);
    code = LSTR(*to);
    name = LSTR(*str);
    if (len==0) return;

    /* convert name to all upper case */
    if (len > MAX_LENGTH) len = MAX_LENGTH;

    /* generate 1st character of Soundex code */
    codeÝ0¨ = l2uÝ(byte)nameÝ0¨¨;
    y=1;


    if (l2uÝ(byte)nameÝ0¨¨=='K')    /* modifications */
        codeÝ0¨ = 'C';
    else
    if (l2uÝ(byte)nameÝ0¨¨=='P' && l2uÝ(byte)nameÝ1¨¨=='H')
        codeÝ0¨ = 'F';

    /* loop through the rest of name, until code complete */
    for (i=1; i<len; i++) {
        c = l2uÝ(byte)nameÝi¨¨;
            /* skip non alpha */
        if (!ISALPHA(c))
            continue;

            /* skip succesive occurance */
        if (c==prior)  continue;
        prior = c;

            /* lookup letter in table   */
        c -= ALPHA_OFFSET;
        if (ctableÝ(byte)c¨=='0')
            continue;    /* ignore this letter */

        codeÝy++¨ = ctableÝ(byte)c¨;    /* add to code */

        if (y >= SOUNDEX_LENGTH) break;    /* code is complete */
    }
    while (y < SOUNDEX_LENGTH) codeÝy++¨ = '0';   /* pad code with zeros */
    codeÝy¨ = '\0';
    LLEN(*to) = y;
} /* Lsoundex */
