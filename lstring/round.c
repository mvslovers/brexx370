//
// Created by PeterJ on 05.05.2020.
//

#include "lstring.h"

/* ---------------- Lround ----------------- */
void __CDECL
Lround( const PLstr to, const PLstr from, long n) {
    int i;
    double add;
    double value = Lrdreal(from);	/* read, do not convert (#305) */

    Lfx(to,n+15);

    add=5.0;
    if (value<0) add=-add;
    for (i=0;i<=n;i++) add=add/10;

// the PC Version round does not work correctly as snprintf rounds
// in the MVS version snprintf does not, we therefore need to add 0.xx5
// which is stripped off by snprintf later

    snprintf(LSTR(*to), LMAXLEN(*to), "%.*f", (int)n, value+add);
    LTYPE(*to) = LSTRING_TY;
    LLEN(*to)  = STRLEN(LSTR(*to));
} /* Lround */
