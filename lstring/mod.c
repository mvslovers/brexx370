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
        double q,m;
        LstrDefine(p0,64);
        LstrDefine(p1,64);

        Lstrcpy(&p0, A);
        Lstrcpy(&p1, B);

        L2REAL(&p0);
        L2REAL(&p1);
        if (LREAL(p1) == 0) Lerror(ERR_ARITH_OVERFLOW, 0);

        /* Ldectrunc keeps 15 digits of the quotient (#254): from 1E15 on
           the integer part is lost, which was a wrong remainder (#460) */
        q = Lfpdiv(LREAL(p0), LREAL(p1));
        if (q >= 1E15 || q <= -1E15) Lerror(ERR_ARITH_OVERFLOW, 0);
        LREAL(*to) = LREAL(p0) - Ldectrunc(q) * LREAL(p1);
        /* from 1E13 on the rounding to 15 digits can carry into the
           integer part: the remainder then has the wrong sign */
        if (q >= 1E13 || q <= -1E13) {
            m = (LREAL(p1) < 0) ? -LREAL(p1) : LREAL(p1);
            if (LREAL(p0) >= 0 ? LREAL(*to) < 0 : LREAL(*to) > 0)
                LREAL(*to) += (LREAL(p0) >= 0) ? m : -m;
        }
        LTYPE(*to) = LREAL_TY;
        LLEN(*to)  = sizeof(double);
        LFREESTR(p0);
        LFREESTR(p1);
    }

} /* Lmod */
