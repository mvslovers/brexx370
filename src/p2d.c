//
// Created by PeterJ on 10.05.2020.
//
#include "lstring.h"
#include "lerror.h"

/* ---------------- Lp2d ----------------------- */
void __CDECL
Lp2d( const PLstr to, const PLstr from, long dummy, long fraction) {
    char sign;
    int r = 0, i;
    unsigned char *re, *ar;

    L2STR(from);
    Lfx(to, 2 * LLEN(*from));

    re = LSTR(*to);
    ar = LSTR(*from);

    for (i = 0, r = 0; i < LLEN(*from); i++) {
        re[r++] = chex[(ar[i] >> 4) & 0x0F];
        re[r++] = chex[ar[i] & 0x0F];
    }
    LTYPE(*to) = LSTRING_TY;
    LLEN(*to) = r - 1;
    sign = LSTR(*to)[r - 1];
    // convert to integer value
    L2INT(to);

    if (sign == 'D' || sign == 'B') {LINT(*to) = -LINT(*to);}
    else if (sign == 'A' || sign == 'C' || sign=='F') {}
    else {
        printf("Invalid Packed Sign %c\n", sign);
        Lerror(ERR_INVALID_HEX_CONST,0);
    }
    if (fraction==0) return;     // if not a decimal number return value as integer
    L2REAL(to);                  // convert to a real number
    // divide by 10 to create appropriate decimal fraction
    for (i=1; i<=fraction;i++) LREAL(*to)=LREAL(*to)/10;
    snprintf(LSTR(*to), LMAXLEN(*to), "%.*f", fraction, LREAL(*to));
    LTYPE(*to) = LSTRING_TY;
    LLEN(*to)  = STRLEN(LSTR(*to));
 }
