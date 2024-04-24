//
// Created by PeterJ on 01.05.2020.
//
#include "lstring.h"
#include <math.h>
/* ------------------- Floor ------------------ */
void __CDECL
Lfloor( const PLstr to, const PLstr num )
{
    LINT(*to)  = floor(Lrdreal(num));
    LTYPE(*to) = LINTEGER_TY;
    LLEN(*to)  = sizeof(long);
} /* Floor */
