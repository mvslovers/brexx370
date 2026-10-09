//
// Created by PeterJ on 05.05.2020.
//

#include "lerror.h"
#include "lstring.h"

/* ---------------- Lround ----------------- */
/* It added 5/10^(n+1) and then let snprintf() round as well, so
 * ROUND(3.141,2) was 3.15 (#386). Now the value is formatted with three
 * more places and rounded once, half away from zero, on its digits:
 * that also takes 2.675 to 2.68, which a double holds as 2.67499... */
void __CDECL
Lround( const PLstr to, const PLstr from, long n) {
    double value = Lrdreal(from);	/* read, do not convert (#305) */
    char  *s;
    size_t len;
    size_t keep;
    long   i;
    int    zero = 1;

    if (n < 0 || n > 64) Lerror(ERR_INCORRECT_CALL, 0);

    Lfx(to, (size_t) n + 48);
    s = (char *) LSTR(*to);
    snprintf(s, LMAXLEN(*to) - 1, "%.*f", (int) n + 3, value);
    len = STRLEN(s);
    keep = len - 3;                 /* up to the n-th place */
    if (n == 0) keep--;             /* and without the point */

    if (s[len - 3] >= '5') {        /* carry into the places kept */
        for (i = (long) keep - 1; i >= 0; i--) {
            if (s[i] == '.') continue;
            if (s[i] == '-') break;
            if (s[i] != '9') { s[i]++; break; }
            s[i] = '0';
        }
        if (i < 0 || s[i] == '-') { /* 9.995 -> 10.00 */
            i++;
            memmove(s + i + 1, s + i, keep - (size_t) i);
            s[i] = '1';
            keep++;
        }
    }
    s[keep] = '\0';

    for (i = 0; s[i]; i++)          /* -0.001 rounds to 0.00, not -0.00 */
        if (s[i] >= '1' && s[i] <= '9') zero = 0;
    if (zero && s[0] == '-') {
        memmove(s, s + 1, keep);
        keep--;
    }

    LTYPE(*to) = LSTRING_TY;
    LLEN(*to)  = keep;
} /* Lround */
