//
// Created by PeterJ on 09.05.2020.
//
#include "lstring.h"
#include "lerror.h"
/* ---------------- Ld2p ----------------------- */
void __CDECL
Ld2p( const PLstr to, const PLstr from, long plen, long n) {
    char *ch, *f, sign;
    int r = 0, j = 0 , i;

    if (plen == 0) plen = 6;
    Lfx(to, n + 15);
// Step 1 create STRING variable of given value
    if (LTYPE(*from)==LINTEGER_TY && n==0) {
       snprintf(LSTR(*to), LMAXLEN(*to), "%*i",0, LINT(*from));
    } else if (LTYPE(*from)==LREAL_TY) {
        snprintf(LSTR(*to), LMAXLEN(*to), "%.*f", n, LREAL(*from));
    } else {
        L2REAL(from);
        snprintf(LSTR(*to), LMAXLEN(*to), "%.*f", n, LREAL(*from));
    }
// Step 2 Analyse string byte by byte, fetch sign, drop decimal point
    ch = LSTR(*to);
    if (*ch == '-') {   /* accept one sign */
        sign = 'D';
        ch++;
    } else {
        sign = 'F';
        if (*ch == '+') ch++;
    }

    while (*ch) {
      if (*ch != '.') {
         LSTR(*to)[j] = *ch;
         j++;
      }
      ch++;
    }
    LSTR(*to)[j] = sign;    // add sign character
    j++;
// Step 3 Convert into decimal numbers, 2 per byte
    ch = LSTR(*to);
    f = LSTR(*to);
    i=0;
    if (j % 2 == 1) {
       ch[r++] = HEXVAL(f[i]);
       i++;
    }
    for (; i < j; i += 2)
        ch[r++] = (HEXVAL(f[i]) << 4) | HEXVAL(f[i + 1]);
    LLEN(*to) = r;
    LTYPE(*to) = LSTRING_TY;
// Step 4 format to requested length
    if (plen==r) return ;  // has already required length, return!
    if (plen<r) Lerror(ERR_ARITH_OVERFLOW,0);   // packed overflow
    Lstrcpy( from,to );    //  Save packed value in from Var.
       //  add leading zerors if length is too short
    for (i=0; i < plen-r; i++) ch[i] =HEXVAL('0');
       //  move saved packed value behind formatted zeros
    for (j=0; j < r; j++) {
        ch[i++] = LSTR(*from)[j];
    }
    LLEN(*to) = plen;
}