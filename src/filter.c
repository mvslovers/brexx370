//
// Created by PeterJ on 30.04.2020.
// Drops all characters defined in input table from string
//

#include "lstring.h"

/* ---------------- Lfilter ------------------- */
void __CDECL
Lfilter( const PLstr to, const PLstr from, const PLstr tablein,const char action) {
    int i, j, k = -1;

    Lstrcpy(to, from);
    L2STR(to);
    L2STR(tablein);

    if (LLEN(*tablein) == 0 || LLEN(*to) == 0) { return; }  // nothing to change
    if (action=='D') {
        // Analysis of string, drop chars which are in input table
        for (i = 0; i < LLEN(*to); i++) {
            for (j = 0; j < LLEN(*tablein); j++) {
                if (LSTR(*to)[i] == LSTR(*tablein)[j]) { goto dropChar; }  // drop char the fast way
            }
            k++;                          // set to next character position
            LSTR(*to)[k] = (byte) LSTR(*to)[i]; // transfer char as relevant
            dropChar:;
        }
    }else {
        // Analysis of string, drop chars which are in input table
        for (i = 0; i < LLEN(*to); i++) {
            for (j = 0; j < LLEN(*tablein); j++) {
                if (LSTR(*to)[i] == LSTR(*tablein)[j]) { goto keepChar; } // drop char the fast way
            }
            continue;
            keepChar:
            k++;                          // set to next character position
            LSTR(*to)[k] = (byte) LSTR(*to)[i]; // transfer char as relevant
        }
    }
// String analysis completed
    k++;                // set to real length (+1)
    LLEN(*to) = (size_t) k;
} /* Lfilter */
