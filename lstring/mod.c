/*
 * $Id: mod.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: mod.c,v $
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

#include "lerror.h"
#include "lstring.h"

/* ------------------ Lmod ----------------- */
void __CDECL
Lmod( const PLstr to, const PLstr A, const PLstr B )
{
    if(A->type==1 && B->type==1) {  // integer modulo
        if (LINT(*B) == 0) Lerror(ERR_ARITH_OVERFLOW, 0);

        LINT(*to)  = LINT(*A) % LINT(*B);
        LTYPE(*to) = LINTEGER_TY;
        LLEN(*to)  = sizeof(long);
    } else {                 // non integer Modulo  input parms will be converted to floats
        Lstr p0,p1;
        LINITSTR(p0)         // copy input parms into temp field, to keep original fields
        Lfx(&p0,64);
        LINITSTR(p1)
        Lfx(&p1,64);
        Lstrcpy(&p0, A);
        Lstrcpy(&p1, B);

        L2REAL(&p0);
        L2REAL(&p1);
        if (LREAL(p1) == 0) Lerror(ERR_ARITH_OVERFLOW, 0);

        LREAL(*to) = (double) (LREAL(p0) - (long) (LREAL(p0) / LREAL(p1)) * LREAL(p1));
        LTYPE(*to) = LREAL_TY;
        LLEN(*to)  = sizeof(double);
        LFREESTR(p0);
        LFREESTR(p1);
    }

} /* Lmod */
