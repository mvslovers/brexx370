//
// Created by PeterJ on 05.05.2020.
//

#include "lstring.h"

/* ---------------- Lround ----------------- */
void __CDECL
Lround( const PLstr to, const PLstr from, long n) {
    int i;
    double add;

    L2REAL(from);
    Lfx(to,n+15);

    add=5.0;
    if (LREAL(*from)<0) add=-add;
    for (i=0;i<=n;i++) add=add/10;

// the PC Version round does not work correctly as snprintf rounds
// in the MVS version snprintf does not, we therefore need to add 0.xx5
// which is stripped off by snprintf later

    snprintf(LSTR(*to), LMAXLEN(*to), "%.*f", (int)n, LREAL(*from)+add);
    LLEN(*to) = STRLEN(LSTR(*to));
    LTYPE(*to) = LSTRING_TY;
} /* Lround */
