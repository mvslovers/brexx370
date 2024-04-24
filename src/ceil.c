//
// Created by PeterJ on 01.05.2020.
//
#include "lstring.h"
#include <math.h>
/* ------------------- Ceil ------------------ */
void __CDECL
Lceil( const PLstr to, const PLstr num )
{
    LINT(*to)  = ceil(Lrdreal(num));
    LTYPE(*to) = LINTEGER_TY;
    LLEN(*to)  = sizeof(long);
} /* Ceil */
